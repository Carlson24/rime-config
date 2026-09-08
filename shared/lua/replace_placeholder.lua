-- lua_filter@*replace_placeholder
-- 功能：
--   1. taichi 过滤：注释中含 ☯ 的候选整条丢弃（作为隐藏标记）
--   2. 文本替换：对指定类型候选，将 strftime 占位符（如 %y年）替换为实际时间，支持 字%N 重复与 %% 转义
--   3. 类型符号：按 super_comment/cand_type 配置为候选注释追加类型标记（防重复）

local M = {}

-- 局部化 string.gsub，避免每候选重复查找表（性能优化）
local gsub = string.gsub

-- ☯（U+262F）UTF-8 字节：隐藏标记
local TAICHI_MARK = "\226\152\175"

-- 需要做文本替换的候选类型
local TARGET_TYPES = {
  abbrev = true,
  user_table = true,
}

-- 完整 strftime：% + 任意单个 ASCII 字母交由 os.date 求值
-- （不支持/未知码经 pcall 防护后原样保留，避免 os.date 抛错）
-- 已知不支持会原样保留：%f %i %k %l %o %s %v %E %J %K %L %N %O
-- 自定义中文令牌：%Q 星期全称、%q 星期简称、%P 中文时段（已占用）
-- %% 为转义：%%y 输出字面 %y，%% 输出字面 %
-- 字%N（N 为一位数字）：将前一字符重复 N 次，如 令%3 -> 令令令
local ESC = "\1"
local UTF8_CHAR = (utf8 and utf8.charpattern) or "[\0-\x7F\xC2-\xFD][\x80-\xBF]*"

-- 中文星期表，下标对应 os.date("*t").wday（1=星期日 … 7=星期六）
local WEEKDAY_FULL = { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" }
local WEEKDAY_SHORT = { "周日", "周一", "周二", "周三", "周四", "周五", "周六" }

-- 按小时划分中文时段（%P 用）
local function zh_period(hour)
  if hour < 6 then
    return "凌晨"
  elseif hour < 12 then
    return "上午"
  elseif hour < 14 then
    return "中午"
  elseif hour < 18 then
    return "下午"
  end
  return "晚上"
end

local function strftime_expand(code)
  -- pcall 防护：os.date 遇不支持码会抛错，捕获后原样返回 %X
  local ok, res = pcall(os.date, "%" .. code)
  if ok then
    return res
  end
  return "%" .. code
end

-- 自定义令牌优先，其余回退 os.date（%Q/%q/%P 占用了 os.date 不支持的字母）
local function custom_expand(code, dt)
  if code == "Q" then
    return WEEKDAY_FULL[dt.wday]
  elseif code == "q" then
    return WEEKDAY_SHORT[dt.wday]
  elseif code == "P" then
    return zh_period(dt.hour)
  end
  return strftime_expand(code)
end

local function repeat_expand(char, count)
  local n = tonumber(count)
  if n and n > 0 then
    return string.rep(char, n)
  end
  -- %0 或非法数字：保留原样
  return char .. "%" .. count
end

-- 占位符替换流水线：%% 转义保护 → 令牌展开（自定义 + strftime）→ 字%N 重复 → 还原 %%
local function replace_formats(text)
  local s = text:gsub("%%%%", ESC)
  local dt = os.date("*t")
  s = s:gsub("%%(%a)", function(code)
    return custom_expand(code, dt)
  end)
  s = s:gsub("(" .. UTF8_CHAR .. ")%%(%d)", repeat_expand)
  return s:gsub(ESC, "%%")
end

-- 取候选真实类型：优先 cand.type，Shadow/Uniquified 则回溯 get_genuine()
local function fast_type(c)
  local t = c.type
  if t then
    return t
  end
  local g = c.get_genuine and c:get_genuine() or nil
  return (g and g.type) or ""
end

function M.init(env)
  local cfg = env.engine and env.engine.schema and env.engine.schema.config

  -- taichi 过滤硬编码开启
  env.enable_taichi_filter = true

  -- 读取 super_comment/cand_type 类型符号映射并预转义（避免每候选重复 gsub）
  env.cand_type_symbols = {}
  env.cand_type_symbols_escaped = {}
  local map = cfg and cfg:get_map("super_comment/cand_type")
  if map then
    for _, key in ipairs(map:keys()) do
      local val = cfg:get_string("super_comment/cand_type/" .. key)
      if val and val ~= "" then
        env.cand_type_symbols[key] = val
        env.cand_type_symbols_escaped[key] = gsub(val, "[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
      end
    end
  end
end

function M.fini(env)
end

function M.func(input, env)
  for cand in input:iter() do
    -- 1. taichi 过滤：注释含 ☯ 的候选不 yield（整条丢弃）
    local skip = env.enable_taichi_filter and cand.comment and cand.comment:find(TAICHI_MARK)
    if not skip then
      local ctype = fast_type(cand)
      local text_changed = false
      local comment_changed = false
      local new_text = cand.text
      local genuine = cand:get_genuine()
      local current_comment = genuine.comment or ""

      -- 2. 文本替换：仅对目标类型候选
      if TARGET_TYPES[ctype] then
        new_text = replace_formats(cand.text)
        text_changed = new_text ~= cand.text
      end

      -- 3. 类型符号追加：按真实类型查映射，命中且注释未以该符号结尾才追加
      local symbol = env.cand_type_symbols[ctype]
      if symbol and symbol ~= "" and current_comment ~= "~" then
        local escaped_symbol = env.cand_type_symbols_escaped[ctype]
        if not escaped_symbol then
          escaped_symbol = gsub(symbol, "[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
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

      -- 文本变更须重建候选（ShadowCandidate），仅注释变更可直改 genuine.comment
      if text_changed then
        yield(ShadowCandidate(cand, cand.type, new_text, current_comment))
      elseif comment_changed then
        genuine.comment = current_comment
        yield(cand)
      else
        yield(cand)
      end
    end
  end
end

return M
