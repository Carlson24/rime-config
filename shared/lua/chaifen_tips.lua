-- 万象家族 Lua：超级提示、表情、化学式、方程式、简码等提示显示，不占用候选位置
-- 采用内存 store + 运行时字节码缓存；数据几乎不变，无需 LevelDb
-- 支持候选匹配和编码匹配，候选支持方向键高亮遍历
-- https://github.com/amzxyz/rime-wanxiang
--
-- chaifen_tips:
--   数据文件路径已写死，见下方 DEFAULT_FILES。

local wanxiang = require("wanxiang")

local DB_FORMAT_VERSION = "4"
local DEFAULT_FILES = { "lua/data/tips_chaifen.txt" }

-- 模块私有 store 池：相同签名的数据共享同一份内存 store，引用计数管理生命周期。
local STORE_CACHE = {}

-- 解析各文件，构建 key -> value 内存映射（后者覆盖前者），
-- 编码为 "key\tvalue\n" 单串 blob + 偏移索引 pos。
local function build_store(files)
  local map = {}

  for _, file_path in ipairs(files) do
    local file, close = wanxiang.load_file_with_fallback(file_path, "r")

    if file then
      for line in file:lines() do
        local current_line = line:gsub("\r$", "")
        local value, key =
            current_line:match("^([^\t]+)\t([^\t]+)$")

        if key and value then
          map[key] = value
        end
      end

      close()
    end
  end

  local keys = {}
  for k in pairs(map) do
    keys[#keys + 1] = k
  end
  table.sort(keys)

  local data = wanxiang.blob_encode(keys, map)
  local pos = wanxiang.blob_index(data)

  return { data = data, pos = pos }
end

-- 文件内容签名（含缺失文件），保证内容变化时缓存失效重建。
local function files_signature(files)
  local parts = {}
  for i, file_path in ipairs(files) do
    parts[i] = file_path .. "|" .. wanxiang.get_file_signature(file_path)
  end
  return wanxiang.digest_parts(parts)
end

local function store_signature(files)
  return wanxiang.digest_parts({
    "chaifen_tips",
    DB_FORMAT_VERSION,
    files_signature(files),
  })
end

local function connect_store(schema_id)
  local files = DEFAULT_FILES

  local signature = store_signature(files)

  local state = STORE_CACHE[signature]
  if state then
    state.refs = state.refs + 1
    return state.store, signature, false
  end

  local cache_path = wanxiang.store_cache_path("tips", schema_id)
  local store
  local built = false

  local blob = wanxiang.read_store_cache(cache_path, signature)
  if blob then
    store = { data = blob, pos = wanxiang.blob_index(blob) }
  else
    store = build_store(files)
    built = true
    wanxiang.write_store_cache(cache_path, signature, store.data)
  end

  STORE_CACHE[signature] = { store = store, refs = 1 }
  return store, signature, built
end

local function release_store(env)
  local store = env.tips_store
  local signature = env.tips_store_sig

  env.tips_store = nil
  env.tips_store_sig = nil

  if not store or not signature then return end

  local state = STORE_CACHE[signature]
  if not state or state.store ~= store then return end

  state.refs = state.refs - 1
  if state.refs > 0 then return end

  STORE_CACHE[signature] = nil
end

local function fetch_tip(store, key)
  return wanxiang.blob_fetch(store.data, store.pos, key)
end

local function get_tip(env, keys)
  local store = env.tips_store
  if not store then return nil end
  if type(keys) == "string" then keys = { keys } end

  for _, key in ipairs(keys) do
    if key and key ~= "" then
      local value = fetch_tip(store, key)
      if value then return value end
    end
  end

  return nil
end

local function update_tips_prompt(context, env)
  env.current_tip = nil

  if not context:get_option("chaifen_tips") then return end
  if not context.input or context.input == "" or context.input:find("^›") then
    return
  end

  local segment = context.composition:back()
  if not segment then return end

  local candidate = context:get_selected_candidate() or {}

  if segment.selected_index < env.engine.schema.page_size then
    env.current_tip = get_tip(env, { context.input, candidate.text })
  else
    env.current_tip = get_tip(env, candidate.text)
  end

  if env.current_tip then
    segment.prompt = "〔" .. env.current_tip .. "〕"
    env.last_prompt = segment.prompt
  elseif segment.prompt ~= "" and segment.prompt == env.last_prompt then
    segment.prompt = ""
    env.last_prompt = ""
  end
end

local P = {}

function P.init(env)
  if env.tips_update_connection then
    env.tips_update_connection:disconnect()
    env.tips_update_connection = nil
  end

  release_store(env)

  local schema_id = env.engine.schema.schema_id or ""

  local store, signature, built = connect_store(schema_id)
  env.tips_store = store
  env.tips_store_sig = signature
  if built then collectgarbage("collect") end

  env.last_prompt = env.last_prompt or ""

  env.tips_update_connection =
      env.engine.context.update_notifier:connect(function(context)
        update_tips_prompt(context, env)
      end)
end

function P.fini(env)
  if env.tips_update_connection then
    env.tips_update_connection:disconnect()
    env.tips_update_connection = nil
  end

  env.current_tip = nil
  env.last_prompt = nil

  release_store(env)
end

function P.func(key, env)
  return wanxiang.RIME_PROCESS_RESULTS.kNoop
end

return P
