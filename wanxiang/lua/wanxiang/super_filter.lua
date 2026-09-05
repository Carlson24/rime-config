-- @amzxyz  https://github.com/amzxyz/rime-wanxiang
-- 提供以下核心修饰与兜底能力：
-- 功能 A：转义序列解析（常驻）
--         将候选词中的 \n, \t, \s(空格) 等文本转义符格式化为实际效果。

local M    = {}

-- 性能优化：本地化字符串函数
local gsub = string.gsub

local function fast_type(c)
  local t = c.type
  if t then
    return t
  end

  local g = c.get_genuine and c:get_genuine() or nil
  return (g and g.type) or ""
end

-- 1. 内部常量与工具函数
local escape_map = {
  ["\\n"] = "\n",
  ["\\r"] = "\r",
  ["\\t"] = "\t",
  ["\\s"] = " ",
  ["\\z"] = "\226\128\139",
}

local utf8_char_pattern = utf8.charpattern

-- 正则转义符预编译（避免每次候选都拼接 pattern）
local escape_repeat_pattern = "(" .. utf8_char_pattern .. ")\\(%d+)"

local time_map = {}
local week_table_big = { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" }
local week_table_small = { "周日", "周一", "周二", "周三", "周四", "周五", "周六" }

local time_tokens_pattern = "%%[AGHIMNOPWSYdjlmopwy]"

-- 2. 核心：处理动态时间
local function process_datetime_internal(s, dt)
  if not string.find(s, time_tokens_pattern) then
    return s
  end

  local h12 = dt.hour % 12
  if h12 == 0 then
    h12 = 12
  end

  local ampm = (dt.hour < 12) and "am" or "pm"
  local raw_tz = os.date("%z") or "+0800"
  local zh_period = (dt.hour < 6 and "凌晨"
    or dt.hour < 12 and "上午"
    or dt.hour < 13 and "中午"
    or dt.hour < 18 and "下午"
    or "晚上")

  time_map.Y = string.format("%04d", dt.year)
  time_map.y = string.format("%02d", dt.year % 100)
  time_map.m = string.format("%02d", dt.month)
  time_map.d = string.format("%02d", dt.day)
  time_map.N = tostring(dt.month)
  time_map.j = tostring(dt.day)
  time_map.W = week_table_big[dt.wday]
  time_map.w = week_table_small[dt.wday]
  time_map.H = string.format("%02d", dt.hour)
  time_map.G = tostring(dt.hour)
  time_map.I = string.format("%02d", h12)
  time_map.l = tostring(h12)
  time_map.M = string.format("%02d", dt.min)
  time_map.S = string.format("%02d", dt.sec)
  time_map.p = ampm
  time_map.P = ampm:upper()
  time_map.O = raw_tz
  time_map.o = raw_tz
  time_map.A = zh_period

  return s:gsub("%%(%a)", function(char)
    return time_map[char] or ("%" .. char)
  end)
end

-- 3. 转义处理
local function apply_escape_fast(text, dt)
  if not text or text == "" then
    return text, false
  end
  if not string.find(text, "\\", 1, true)
     and not string.find(text, time_tokens_pattern) then
    return text, false
  end

  local blocks = {}
  local s = text:gsub("%[%[(.-)%]%]", function(txt)
    blocks[#blocks + 1] = txt
    return "\0BLK" .. #blocks .. "\0"
  end)

  s = s:gsub("\\[ntrsz]", escape_map)

  s = s:gsub(escape_repeat_pattern, function(char, count)
    local n = tonumber(count)
    if n and n > 0 and n < 200 then
      return string.rep(char, n)
    end
    return char .. "\\" .. count
  end)

  s = process_datetime_internal(s, dt)

  s = s:gsub("\0BLK(%d+)\0", function(i)
    return blocks[tonumber(i)] or ""
  end)

  return s, s ~= text
end

local function format_and_autocap(cand, env, dt, ctype)
  local text = cand.text
  if not text or text == "" then
    return cand
  end

  -- 1. 处理转义字符
  local t2, text_changed = apply_escape_fast(text, dt)

  -- 2. 处理尾巴符号追加
  local genuine = cand:get_genuine()
  local current_comment = genuine.comment or ""
  local ctype_key = ctype or fast_type(cand)
  local symbol = env.cand_type_symbols[ctype_key]
  local comment_changed = false

  if symbol and symbol ~= "" and current_comment ~= "~" then
    -- 防重判断，避免因为各种原因重复追加（symbol 已预转义）
    local escaped_symbol = env.cand_type_symbols_escaped[ctype_key]
    if not escaped_symbol then
      escaped_symbol = symbol:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
    end
    if not current_comment:match(escaped_symbol .. "$") then
      if current_comment ~= "" then
        current_comment = current_comment .. " " .. symbol
      else
        current_comment = symbol
      end
      comment_changed = true
    end
  end

  -- 分流处理！保住 spans 物理边界
  if text_changed then
    local nc = Candidate(cand.type, cand.start, cand._end, t2, current_comment)
    nc.preedit = cand.preedit
    return nc
  elseif comment_changed then
    genuine.comment = current_comment
    return cand
  else
    -- 如果文本和注释都没变，直接放行原候选词，节省性能
    return cand
  end
end

function M.init(env)
  local cfg = env.engine and env.engine.schema and env.engine.schema.config

  env.enable_taichi_filter = true

  -- 读取全局类型符号配置
  env.cand_type_symbols = {}
  local map = cfg and cfg:get_map("super_comment/cand_type")
  if map then
    for _, key in ipairs(map:keys()) do
      local val = cfg:get_string("super_comment/cand_type/" .. key)
      if val and val ~= "" then
        env.cand_type_symbols[key] = val
      end
    end
  end
  -- 预转义 symbol，避免每个候选重复 gsub
  env.cand_type_symbols_escaped = {}
  for k, v in pairs(env.cand_type_symbols) do
    env.cand_type_symbols_escaped[k] = v:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
  end
end

function M.fini(env)
end

function M.func(input, env)
  local current_dt = os.date("*t")
  local suppress_set = {}

  for cand in input:iter() do
    local text = cand.text

    if not suppress_set[text] then
      suppress_set[text] = true

      local skip = env.enable_taichi_filter and cand.comment and cand.comment:find("\226\152\175")
      if not skip then
        yield(format_and_autocap(cand, env, current_dt, fast_type(cand)))
      end
    end
  end
end

return M
