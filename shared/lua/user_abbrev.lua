-- user_abbrev.lua 一个rime 简码滤镜
-- https://github.com/amzxyz/rime-wanxiang
-- @amzxyz

local M = {}

-- 性能优化：本地化常用库函数
local s_match = string.match
local s_format = string.format
local s_byte = string.byte
local s_sub = string.sub
local s_gsub = string.gsub
local s_find = string.find
local s_upper = string.upper
local t_sort = table.sort
local DB_FORMAT_VERSION = "7"

-- 模块私有 store 池：相同签名的数据共享同一份内存 store，引用计数管理生命周期。
local STORE_CACHE = {}
local VALUE_SEPARATOR = "\\t"
local VALUE_SEPARATOR_LEN = #VALUE_SEPARATOR
local EXACT_CACHE_PREFIX = "\1"

-- 基础依赖
local wanxiang = require("wanxiang")

local function clear_array(t)
  for i = #t, 1, -1 do t[i] = nil end
end

local function clear_table(t)
  for key in pairs(t) do t[key] = nil end
end

local function generate_files_signature(tasks)
  local parts = {}
  local seen = {}

  for _, task in ipairs(tasks) do
    if not seen[task.path] then
      seen[task.path] = true
      parts[#parts + 1] = (task.source or task.path) .. "|" .. wanxiang.get_file_signature(task.path)
    end
  end

  return wanxiang.digest_parts(parts)
end

local function each_file_value(cfg_root, callback)
  local function each_item(item)
    if not item then return end

    if item.type == "kList" then
      local list = item:get_list()
      for i = 0, list.size - 1 do
        local value = list:get_value_at(i)
        if value then callback(value) end
      end
    elseif item.type == "kScalar" then
      local value = item:get_value()
      if value then callback(value) end
    end
  end

  each_item(cfg_root:get("files"))
  each_item(cfg_root:get("file"))
end

local function task_signature(task)
  return (task.source or "")
end

local function tasks_signature(tasks)
  local parts = {}
  for i, task in ipairs(tasks) do
    parts[i] = task_signature(task)
  end
  return wanxiang.digest_parts(parts)
end

local function next_value(value, start)
  local pos = s_find(value, VALUE_SEPARATOR, start, true)
  if pos then
    return s_sub(value, start, pos - 1), pos + VALUE_SEPARATOR_LEN
  end
  if start == 1 then return value, nil end
  return s_sub(value, start), nil
end

local function parse_source_line(line)
  local key, value = s_match(line, "^([^\t]+)\t+(.+)$")
  if not key or not value or key == "" or value == "" then return nil, nil end
  value = s_gsub(value, "\t", VALUE_SEPARATOR)
  return key, value
end

local function fetch_aggregate(store, key)
  return wanxiang.blob_fetch(store.data, store.pos, key)
end

local function fetch_exact_cached(store, key, query_cache)
  local cache_key = EXACT_CACHE_PREFIX .. key
  local value = query_cache[cache_key]
  if value ~= nil then return value or nil end

  value = fetch_aggregate(store, key)
  query_cache[cache_key] = value or false
  return value
end

-- 构建内存 store：所有任务逐行解析，按 key 聚合，
-- 编码为 "key\tvalue\n" 单串 blob + 偏移索引 pos。
local function build_store(tasks)
  local map = {}
  local written = {}
  local invalid_count = 0

  for _, task in ipairs(tasks) do
    local file, close = wanxiang.load_file_with_fallback(task.path, "r")

    if file then
      for line in file:lines() do
        if line ~= "" and not s_match(line, "^%s*#") then
          local key, value = parse_source_line(line)

          if key and value then
            value = s_match(value, "^%s*(.-)%s*$")
            local store_key = key

            if written[store_key] then
              local existing = map[store_key]
              if existing then
                map[store_key] = existing .. VALUE_SEPARATOR .. value
              end
            else
              map[store_key] = value
              written[store_key] = true
            end
          else
            invalid_count = invalid_count + 1
          end
        end
      end

      close()
    end
  end

  if log and log.warning and invalid_count > 0 then
    log.warning(s_format(
      "user_abbrev: 已跳过 %d 行无效数据，格式必须为 key<真实Tab>候选1\\t候选2",
      invalid_count
    ))
  end

  local keys = {}
  for k in pairs(map) do
    keys[#keys + 1] = k
  end
  t_sort(keys)

  local data = wanxiang.blob_encode(keys, map)
  local pos = wanxiang.blob_index(data)

  return { data = data, pos = pos }
end

-- 连接 store：优先命中模块级缓存，其次读 blob 缓存，最后从文本重建。
local function connect_store(tasks, current_version, schema_id)
  local files_sig = generate_files_signature(tasks)
  local tasks_sig = tasks_signature(tasks)
  local signature = wanxiang.digest_parts({
    "user_abbrev",
    current_version,
    DB_FORMAT_VERSION,
    files_sig,
    tasks_sig,
    schema_id
  })

  local entry = STORE_CACHE[signature]
  if entry then
    entry.refs = entry.refs + 1
    return entry.store, signature, false
  end

  local cache_path = wanxiang.store_cache_path("abbrev", schema_id)
  local store
  local built = false

  local blob = wanxiang.read_store_cache(cache_path, signature)
  if blob then
    store = { data = blob, pos = wanxiang.blob_index(blob) }
  else
    store = build_store(tasks)
    built = true
    if store then
      wanxiang.write_store_cache(cache_path, signature, store.data)
    end
  end

  if not store then return nil, signature, built end

  STORE_CACHE[signature] = { store = store, refs = 1 }
  return store, signature, built
end

-- 释放当前组件引用，并在最后一个使用者退出时回收 store。
local function release_store(env)
  local store = env.store
  local signature = env.store_sig

  env.store = nil
  env.store_sig = nil

  if not store or not signature then return end

  local entry = STORE_CACHE[signature]
  if not entry or entry.store ~= store then return end

  entry.refs = entry.refs - 1
  if entry.refs > 0 then return end

  STORE_CACHE[signature] = nil
end

-- 模块接口
function M.init(env)
  if env.store then release_store(env) end

  env.query_cache = {}
  local ns = env.name_space
  ns = s_gsub(ns, "^%*", "")
  ns = string.match(ns, "([^%.]+)$") or ns
  local config = env.engine.schema.config

  -- 1. 获取根节点 Map 对象
  local cfg_root = config:get_map(ns)

  -- 2. 读取基础配置
  local delimiter = config:get_string("speller/delimiter") or " '"
  env.speller_delimiter = delimiter:sub(2, 2)

  local current_version = "v0.0.2"
  if wanxiang and wanxiang.version then
    current_version = wanxiang.version
  end

  env.rule = nil
  local tasks = {}

  -- 3. 读取扁平单规则配置（永久启用的简码规则）
  if cfg_root then
    -- 解析 tags（限定作用输入段；不写 tags 则作用于所有段）
    local target_tags = nil
    local tag_keys = { "tag", "tags" }
    for _, key in ipairs(tag_keys) do
      local tag_item = cfg_root:get(key)
      if tag_item then
        if not target_tags then target_tags = {} end
        if tag_item.type == "kList" then
          local list = tag_item:get_list()
          for k = 0, list.size - 1 do
            local val = list:get_value_at(k)
            local str = val and val:get_string()
            if str then target_tags[str] = true end
          end
        elseif tag_item.type == "kScalar" then
          local val = tag_item:get_value()
          local str = val and val:get_string()
          if str then target_tags[str] = true end
        end
      end
    end

    env.rule = {
      tags = target_tags
    }

    -- 解析文件路径列表
    each_file_value(cfg_root, function(file_value)
      local source = file_value:get_string()
      if source and source ~= "" then
        tasks[#tasks + 1] = {
          source = source,
          path = source
        }
      end
    end)

    -- 只使用当前方案的任务，隔离方案数据
    local current_id = env.engine.schema.schema_id or ""

    local store, signature, rebuilt = connect_store(tasks, current_version, current_id)
    env.store = store
    env.store_sig = signature

    if rebuilt then
      tasks = nil
      collectgarbage("collect")
    end
  end
end

function M.fini(env)
  env.query_cache = nil
  env.rule = nil

  release_store(env)
end

function M.func(input, env)
  local ctx = env.engine.context
  local store = env.store
  local rule = env.rule
  local query_cache = env.query_cache
  if not query_cache then
    query_cache = {}
    env.query_cache = query_cache
  end

  if not ctx:is_composing() or ctx.input == "" then
    clear_table(query_cache)
    for cand in input:iter() do yield(cand) end
    return
  end

  if not rule or not store then
    for cand in input:iter() do yield(cand) end
    return
  end

  local seg = ctx.composition:back()
  local current_seg_tags = seg and seg.tags or {}
  local input_code = ctx.input
  if seg then input_code = s_sub(ctx.input, seg.start + 1, seg._end) end

  -- 规则永久启用，仅按 tags 过滤作用输入段
  if rule.tags then
    local matched = false
    for req_tag in pairs(rule.tags) do
      if current_seg_tags[req_tag] then
        matched = true
        break
      end
    end
    if not matched then
      for cand in input:iter() do yield(cand) end
      return
    end
  end

  local global_yielded = {}
  local seen_texts = {}
  local abbrev_cands = {}
  local abbrev_start = seg and seg.start or 0
  local abbrev_end = seg and seg._end or #ctx.input

  local function make_abbrev_candidate(item)
    local cand = Candidate(item.cand_type, abbrev_start, abbrev_end, item.text, "")
    cand.quality = item.quality
    if item.preedit then cand.preedit = item.preedit end
    return cand
  end

  local query_source = s_match(ctx.input, "^[a-zA-Z]+$") and ctx.input or input_code
  local query_code = s_gsub(query_source, env.speller_delimiter, "")
  local query_has_upper = s_find(query_code, "[A-Z]") ~= nil
  local upper_query = nil

  if query_code ~= "" then
    -- 单次精确取数；大写回退保留。
    local val = fetch_exact_cached(store, query_code, query_cache)

    if not val and not query_has_upper then
      if not upper_query then upper_query = s_upper(query_code) end
      val = fetch_exact_cached(store, upper_query, query_cache)
    end

    if val then
      local value_pos = 1

      while value_pos do
        local p
        p, value_pos = next_value(val, value_pos)
        if p ~= "" and not seen_texts[p] then
          seen_texts[p] = true
          abbrev_cands[#abbrev_cands + 1] = {
            text = p,
            cand_type = "abbrev",
            quality = 999
          }
        end
      end
    end
  end

  -- 惰性流式输出主候选：不在首个 yield 前物化整个候选流，
  -- 避免强制计算全部输入候选（大词典下单码可达上千候选）造成数十毫秒尖峰。
  -- 通过窥探首个候选类型决定简码位置：顶部为 user_table/pinned 时让位在其后，
  -- 否则简码仍置顶。
  local function trim_space(str)
    if not str or str == "" then return "" end

    local first = s_byte(str, 1)
    local last = s_byte(str, #str)
    if first > 32 and last > 32 then return str end
    return s_match(str, "^%s*(.-)%s*$")
  end

  local function yield_dedup(cand)
    local dedup_key = trim_space(cand.text)
    if not global_yielded[dedup_key] then
      global_yielded[dedup_key] = true
      yield(cand)
    end
  end

  local function is_priority(cand)
    return cand.type == "user_table" or cand.type == "pinned"
  end

  local next_candidate, iterator_state = input:iter()
  local first = next_candidate(iterator_state)

  if not first then
    for _, item in ipairs(abbrev_cands) do
      yield_dedup(make_abbrev_candidate(item))
    end
    return
  end

  if is_priority(first) then
    local cand = first
    while cand and is_priority(cand) do
      yield_dedup(cand)
      cand = next_candidate(iterator_state)
    end
    for _, item in ipairs(abbrev_cands) do
      yield_dedup(make_abbrev_candidate(item))
    end
    if cand then yield_dedup(cand) end
    for cand in next_candidate, iterator_state do
      yield_dedup(cand)
    end
  else
    for _, item in ipairs(abbrev_cands) do
      yield_dedup(make_abbrev_candidate(item))
    end
    yield_dedup(first)
    for cand in next_candidate, iterator_state do
      yield_dedup(cand)
    end
  end
end

return M
