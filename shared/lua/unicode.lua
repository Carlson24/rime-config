-- Contributed to Project Moran by jack2game (https://github.com/ksqsf/rime-moran/pull/61)
-- Unicode
-- 复制自： https://github.com/shewer/librime-lua-script/blob/main/lua/component/unicode.lua
-- 示例：输入 U62fc 得到「拼」
-- 触发前缀默认为 recognizer/patterns/unicode 的第 2 个字符，即 U
-- 2024.02.26: 限定编码最大值
-- 2025.10.05: 注释改为「U+xxxx【区块标签】」形式

-- 返回 CJK 码点所属区块标签，非 CJK 待补充
local function get_charset_label(code)
  if not code then return nil end
  if code >= 0x4E00 and code <= 0x9FFF then return "基本" end
  if code >= 0x3400 and code <= 0x4DBF then return "扩A" end
  if code >= 0x20000 and code <= 0x2A6DF then return "扩B" end
  if code >= 0x2A700 and code <= 0x2B73F then return "扩C" end
  if code >= 0x2B740 and code <= 0x2B81F then return "扩D" end
  if code >= 0x2B820 and code <= 0x2CEAF then return "扩E" end
  if code >= 0x2CEB0 and code <= 0x2EBEF then return "扩F" end
  if code >= 0x2EBF0 and code <= 0x2EE5F then return "扩I" end
  if code >= 0x30000 and code <= 0x3134F then return "扩G" end
  if code >= 0x31350 and code <= 0x323AF then return "扩H" end
  if code >= 0x323B0 and code <= 0x3347F then return "扩J" end
  if code >= 0xF900 and code <= 0xFAFF then return "兼容" end
  if code >= 0x2F800 and code <= 0x2FA1F then return "兼容" end
  return nil
end

-- code 为实际字符码点；base/offset 用于扩展候选显示
local function format_comment(code, base, offset)
  local s = string.format("U+%04X", base or code)
  if offset then s = s .. string.format("~%X", offset) end
  local label = get_charset_label(code)
  if label then s = s .. "【" .. label .. "】" end
  return s
end

local function unicode(input, seg, env)
  -- 获取 recognizer/patterns/unicode 的第 2 个字符作为触发前缀
  env.unicode_keyword = env.unicode_keyword or
      env.engine.schema.config:get_string("recognizer/patterns/unicode"):sub(2, 2) or "U"
  if seg:has_tag("unicode") and env.unicode_keyword ~= "" and input:sub(1, 1) == env.unicode_keyword then
    local ucodestr = input:match(env.unicode_keyword .. "(%x+)")
    if ucodestr and #ucodestr > 1 then
      local code = tonumber(ucodestr, 16)
      if code > 0x10FFFF then
        yield(Candidate("unicode", seg.start, seg._end, "数值超限！", ""))
        return
      end
      local text = utf8.char(code)
      yield(Candidate("unicode", seg.start, seg._end, text, format_comment(code)))
      if code < 0x10000 then
        for i = 0, 15 do
          local cp = code * 16 + i
          local text = utf8.char(cp)
          yield(Candidate("unicode", seg.start, seg._end, text, format_comment(cp, code, i)))
        end
      end
    end
  end
end

return unicode
