-- lua/super_processor.lua
-- @amzxyz
-- https://github.com/amzxyz/rime-wanxiang
-- 全能按键处理器：整合 字母选词、符号快打、声调回退、以词定字
--
-- 用法: 在 schema.yaml 中 engine/processors 列表添加 - lua_processor@*super_processor

local wanxiang                   = require("wanxiang")
local M                          = {}

local utf8_len                   = utf8.len

local K_REJECT, K_ACCEPT, K_NOOP = 0, 1, 2

-- 1. 全局常量定义 (Constants)

-- [LetterSelector] 字母选词键码映射 (qwert...)
local LETTER_SEL_MAP             = {
  [0x71] = 1,
  [0x77] = 2,
  [0x65] = 3,
  [0x72] = 4,
  [0x74] = 5,
  [0x79] = 6,
  [0x75] = 7,
  [0x69] = 8,
  [0x6F] = 9,
  [0x70] = 10
}

-- [QuickSymbol] 默认符号映射表
local SYMBOL_DEFAULT             = {
  q = "：",
  w = "？",
  e = "（",
  r = "）",
  t = "	",
  y = "·",
  u = "『",
  i = "』",
  o = "〖",
  p = "〗",
  a = "！",
  s = "……",
  d = "、",
  f = "“",
  g = "”",
  h = "‘",
  j = "’",
  k = "【",
  l = "】",
  z = "。",
  x = "？",
  c = "！",
  v = "——",
  b = "%",
  n = "《",
  m = "》"
}

-- 2. 核心辅助函数 (Utilities)

-- 压缩连续声调 (ToneFallback 使用)
local function compress_runs_keep_last(text)
  local changed = false
  local out = text:gsub("([67890])([67890]+)", function(_, tail)
    changed = true
    return tail:sub(-1)
  end)
  return out, changed
end
-- 执行符号快打 (双端通用)
local function execute_quick_symbol(env, ctx, text)
  local qkey = string.match(text, env.qs_trigger)
  if qkey then
    local symbol = env.qs_mapping[qkey]
    if symbol and symbol ~= "" then
      env.engine:commit_text(symbol)
      ctx:clear()
      return true
    end
  end
  return false
end
-- 3. 初始化与资源管理 (Init & Fini)

function M.init(env)
  local engine = env.engine
  local config = engine.schema.config
  local context = engine.context

  -- [1] 配置加载 (按功能模块分类)

  env.sc_first_key = nil
  env.sc_last_key = nil
  env.is_t9 = false
  if wanxiang.get_input_method_type then
    local im_type = wanxiang.get_input_method_type(env)
    if im_type == "t9" then
      env.is_t9 = true
    end
  end
  if config then
    -- 以词定字配置
    env.sc_first_key = config:get_string("key_binder/select_first_character")
    env.sc_last_key = config:get_string("key_binder/select_last_character")
  end

  -- [LetterSelector] 字母选词状态位
  env.ls_active = false

  -- [ToneFallback] 声调容错
  env.tone_state = "idle"
  env.lookup_key = config:get_string("wanxiang_lookup/key") or "`"

  -- [QuickSymbol] 符号快打
  env.qs_trigger = "^([a-z])/$"
  env.qs_mapping = {}
  for k, v in pairs(SYMBOL_DEFAULT) do env.qs_mapping[k] = v end
  local ok_map, map = pcall(function() return config:get_map("quick_symbol_text/symkey") end)
  if ok_map and map then
    local ok_keys, keys = pcall(function() return map:keys() end)
    if ok_keys and keys then
      for _, key in ipairs(keys) do
        local v = config:get_string("quick_symbol_text/symkey/" .. key)
        if v then env.qs_mapping[tostring(key)] = v end
      end
    end
  end

  -- [2] 统一 Update Notifier (状态缓存与自动处理)

  env.conn_update = context.update_notifier:connect(function(ctx)
    local input = ctx.input or ""
    -- A. [ToneFallback] 执行声调压缩
    local t_state = env.tone_state or "idle"
    env.tone_state = "idle"

    if t_state == "compress" and input ~= "" then
      local caret = (ctx.caret_pos ~= nil) and ctx.caret_pos or #input
      if caret < 0 then caret = 0 end
      if caret > #input then caret = #input end

      local left              = (caret > 0) and input:sub(1, caret) or ""
      local left_new, changed = compress_runs_keep_last(left)

      if changed then
        if caret > 0 then ctx:pop_input(caret) end
        if #left_new > 0 then ctx:push_input(left_new) end
        -- push_input 会自动触发下一次 update_notifier，所以这里可以更新本地 input
        input = ctx.input or ""
      end
    end

    -- B. [LetterSelector] 缓存激活状态
    env.ls_active = false
    if not ctx.composition:empty() then
      local s = ctx.composition:back()
      if s and (s:has_tag("Snumber") or s:has_tag("Ndate")) then
        env.ls_active = true
      end
    end

    -- C. [QuickSymbol] 自动上屏逻辑
    execute_quick_symbol(env, ctx, input)
  end)
end

function M.fini(env)
  if env.conn_update then
    env.conn_update:disconnect(); env.conn_update = nil
  end
  env.memory = nil
end

-- 4. 逻辑分发处理 (Handlers)

-- [QuickSymbol] 拦截触发键，防止进入 Speller
local function handle_quick_symbol_intercept(key, env, ctx)
  local kc = key.keycode
  if kc < 0x20 or kc > 0x7E then return false end

  local input = ctx.input or ""
  local next_input = input .. string.char(kc)

  if execute_quick_symbol(env, ctx, next_input) then
    return true
  end
  return false
end

-- [Letter Selector] 字母选词
local function handle_letter_select(key, env, ctx)
  if not env.ls_active then return false end
  if key:ctrl() or key:alt() or key:super() then return false end
  local idx = LETTER_SEL_MAP[key.keycode]
  if not idx then return false end

  if ctx.composition:empty() then return false end
  local seg = ctx.composition:back()
  if not seg or not seg.menu then return false end

  local count = seg.menu:prepare(9)
  if idx < 1 or idx > count then return false end

  ctx:select(idx - 1)
  return true
end

-- [Select Character] 以词定字逻辑 (New!)
local function handle_select_character(key, env, ctx)
  -- 检查配置是否存在
  if not (env.sc_first_key or env.sc_last_key) then return false end
  -- 判断是否在命令模式，如果是，则关闭以词定字，释放占用的按键/符号
  if wanxiang.is_function_mode_active and wanxiang.is_function_mode_active(ctx) then
    return false
  end
  -- 状态检查：必须在输入中或有候选菜单
  if not (ctx:is_composing() or ctx:has_menu()) then return false end

  -- 键值与字符双重匹配（解决 Rime 返回 "bracketleft" 无法匹配 "[" 的问题）
  local repr = key:repr()
  local ch = ""
  if key.keycode >= 0x20 and key.keycode <= 0x7E then
    ch = string.char(key.keycode)
  end

  local is_first = (env.sc_first_key and (repr == env.sc_first_key or ch == env.sc_first_key))
  local is_last  = (env.sc_last_key and (repr == env.sc_last_key or ch == env.sc_last_key))
  if not (is_first or is_last) then return false end

  -- 获取当前选中的候选词或输入
  local text = ctx.input
  local cand = ctx:get_selected_candidate()
  if cand then text = cand.text end

  -- 执行上屏
  if utf8_len(text) > 1 then
    if is_first then
      -- 上屏第一个字 (sub: 1 到 第二个字偏移量-1)
      env.engine:commit_text(utf8.sub(text, 1, 1))
      ctx:clear()
      return true -- Accepted
    elseif is_last then
      -- 上屏最后一个字 (sub: 最后一个字偏移量)
      env.engine:commit_text(utf8.sub(text, -1))
      ctx:clear()
      return true -- Accepted
    end
  end
  return false
end

-- [ToneFallback] 数字键声调回退逻辑
local function handle_tone_digit(key, env, ctx)
  local kc = key.keycode
  local input = ctx.input or ""
  local r = key:repr() or ""

  local digit_str = nil
  if r:match("^[0-9]$") then
    digit_str = r
  end

  if digit_str then
    if key:ctrl() or key:alt() or key:super() then return false end

    -- 只要是 T9 九键方案，数字键就是打字编码键，放行给底层
    if env.is_t9 then
      env.tone_state = "idle"
      return false
    end

    local is_func_mode = false
    if wanxiang.is_function_mode_active then
      is_func_mode = wanxiang.is_function_mode_active(ctx)
    end
    local is_first_cand_has_eng = false
    local cand = ctx:get_selected_candidate()
    if cand then
      if cand.text:match("[a-zA-Z]") then
        is_first_cand_has_eng = true
      end
    end

    if input:find(env.lookup_key, 1, true) or is_func_mode or is_first_cand_has_eng then
      env.tone_state = "idle"
    else
      env.tone_state = "compress"
      local caret = (ctx.caret_pos ~= nil) and ctx.caret_pos or #input
      if caret > #input then caret = #input end
      local left = (caret > 0) and input:sub(1, caret) or ""
      local _, changed = compress_runs_keep_last(left)
      if changed then return true end
    end
  else
    -- 非数字键重置状态，保证声调压缩不越界
    env.tone_state = "idle"
  end

  return false
end
-- 5. 主入口函数 (Main Logic Flow)
function M.func(key, env)
  local ctx = env.engine.context

  -- 1. 优先处理按键释放
  if key:release() then
    return K_NOOP
  end

  local kc = key.keycode

  -- 2. QuickSymbol 拦截 (a-z + /)
  if handle_quick_symbol_intercept(key, env, ctx) then
    return K_ACCEPT
  end

  -- 3. Select Character 以词定字
  if handle_select_character(key, env, ctx) then
    return K_ACCEPT
  end

  -- 4. (q-o + 特定 Tag)[Letter Selector] 字母选词
  if env.ls_active and (LETTER_SEL_MAP[kc] ~= nil) then
    if handle_letter_select(key, env, ctx) then return K_ACCEPT end
  end

  -- 5. 数字键 (声调回退)
  if kc >= 0x30 and kc <= 0x39 then
    if handle_tone_digit(key, env, ctx) then return K_ACCEPT end
  else
    -- 非数字键，重置声调状态
    env.tone_state = "idle"
  end

  return K_NOOP
end

return M
