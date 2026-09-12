---@diagnostic disable: undefined-global

-- 万象的一些共用工具函数
local wanxiang                = {}

local t_concat                = table.concat

wanxiang.version              = "v114.51.4"

wanxiang.INPUT_METHOD_MARKERS = {
  ["Ⅰ"] = "pinyin", -- 全拼
  ["Ⅱ"] = "zrm", -- 自然码双拼
  ["Ⅲ"] = "flypy", -- 小鹤双拼
  ["Ⅽ"] = "lssp", -- 李氏三拼
  ["ⅱ"] = "t9" -- 拼音九键
}

-- 基础元音 -> 四个带调符号（顺序即 1-4 声）
wanxiang.tone_mark_map        = {
  a = { "ā", "á", "ǎ", "à" },
  o = { "ō", "ó", "ǒ", "ò" },
  e = { "ē", "é", "ě", "è" },
  i = { "ī", "í", "ǐ", "ì" },
  u = { "ū", "ú", "ǔ", "ù" },
  ["ü"] = { "ǖ", "ǘ", "ǚ", "ǜ" },
  n = { "n̄", "ń", "ň", "ǹ" }, -- n̄=n+U+0304
  m = { "m̄", "ḿ", "m̌", "m̀" }
}

-- 数字声调键位：1-5 调 -> 6/7/8/9/0
wanxiang.tone_key_map         = {
  ["1"] = "6",
  ["2"] = "7",
  ["3"] = "8",
  ["4"] = "9",
  ["5"] = "0"
}

-- 全局内容
---@alias PROCESS_RESULT ProcessResult
wanxiang.RIME_PROCESS_RESULTS = {
  kRejected = 0, -- 表示处理器明确拒绝了这个按键，停止处理链但不返回 true
  kAccepted = 1, -- 表示处理器成功处理了这个按键，停止处理链并返回 true
  kNoop = 2      -- 表示处理器没有处理这个按键，继续传递给下一个处理器
}

--- 检测是否为万象专业版
---@param env Env
---@return boolean
function wanxiang.is_pro_scheme(env)
  -- local schema_name = env.engine.schema.schema_name
  -- return schema_name:gsub("PRO$", "") ~= schema_name
  return env.engine.schema.schema_id == "wanxiang_flypy"
      or env.engine.schema.schema_id == "wanxiang_flypy_18keys"
      or env.engine.schema.schema_id == "wanxiang_flypy_14keys"
      or env.engine.schema.schema_id == "wanxiang_l17keys"
      or env.engine.schema.schema_id == "wanxiang_yoemin"
end

-- 以 `tag` 方式检测是否处于反查模式
function wanxiang.is_in_radical_mode(env)
  local seg = env.engine.context.composition:back()
  return seg and (
    seg:has_tag("wanxiang_reverse")
  ) or false
end

---判断是否在命令模式
---@param context Context | nil
---@return boolean
function wanxiang.is_function_mode_active(context)
  if not context or not context.composition or context.composition:empty() then
    return false
  end

  local seg = context.composition:back()
  if not seg then return false end

  return seg:has_tag("Snumber") or -- 数字金额转换 S+数字
      seg:has_tag("unicode") or    -- unicode.lua 输出 Unicode 字符 U+小写字母或数字
      seg:has_tag("calculator") or -- V 键计算器
      seg:has_tag("Ndate")         -- N 日期功能
end

-- 判断码点是否为汉字（避免 utf8.char/utf8.codepoint 往返）
function wanxiang.is_chinese_codepoint(codepoint)
  if not codepoint then return false end
  return
      (codepoint >= 0x4E00 and codepoint <= 0x9FFF)      -- Basic
      or (codepoint >= 0x3400 and codepoint <= 0x4DBF)   -- Ext A
      or (codepoint >= 0x20000 and codepoint <= 0x2A6DF) -- Ext B
      or (codepoint >= 0x2A700 and codepoint <= 0x2B73F) -- Ext C
      or (codepoint >= 0x2B740 and codepoint <= 0x2B81F) -- Ext D
      or (codepoint >= 0x2B820 and codepoint <= 0x2CEAF) -- Ext E
      or (codepoint >= 0x2CEB0 and codepoint <= 0x2EBEF) -- Ext F
      or (codepoint >= 0x30000 and codepoint <= 0x3134F) -- Ext G
      or (codepoint >= 0x31350 and codepoint <= 0x323AF) -- Ext H
      or (codepoint >= 0x2EBF0 and codepoint <= 0x2EE5F) -- Ext I
      or (codepoint >= 0x323B0 and codepoint <= 0x3347F) -- Ext J
      or (codepoint >= 0xF900 and codepoint <= 0xFAFF)   -- Compatibility
      or (codepoint >= 0x2F800 and codepoint <= 0x2FA1F) -- Compatibility Supplement
      or (codepoint >= 0x2E80 and codepoint <= 0x2EFF)   -- Radicals Supplement
      or (codepoint >= 0x2F00 and codepoint <= 0x2FDF)   -- Kangxi Radicals
end

-- 按照优先顺序加载文件：用户目录 > 系统目录 > 原路径兜底
---@param filename string 相对路径
---@return file* | nil, function, string|nil
function wanxiang.load_file_with_fallback(filename, mode)
  mode = mode or "r" -- 默认读取模式

  local _path = filename:gsub("^[\\/]+", "")

  local function is_absolute(path) -- 绝对路径：以 /、\ 或盘符开头
    return path ~= nil
        and (path:sub(1, 1) == "/" or path:sub(1, 1) == "\\" or path:match("^[a-zA-Z]:[\\/]"))
  end

  local function file_exists(path) -- 尝试以读模式打开来判定存在
    local f = io.open(path, "r")
    if f then
      io.close(f)
      return true
    end
    return false
  end

  local file, err
  local function close()
    if not file then return end
    file:close()
    file = nil
  end

  local candidate
  local user_dir   = rime_api.get_user_data_dir()
  local shared_dir = rime_api.get_shared_data_dir()

  if not is_absolute(user_dir) then
    candidate = filename
  else
    local user_path = user_dir .. "/" .. _path
    if file_exists(user_path) then
      candidate = user_path
    elseif not is_absolute(shared_dir) then
      candidate = filename
    else
      local shared_path = shared_dir .. "/" .. _path
      if file_exists(shared_path) then
        candidate = shared_path
      end
    end
  end

  if candidate then
    file, err = io.open(candidate, mode)
  end

  return file, close, err
end

local __input_type_cache = {} -- 缓存首个命中的 id

--- 根据 speller/algebra 中的特殊符号返回输入类型
---@param env Env
---@return string
function wanxiang.get_input_method_type(env)
  local schema_id = env.engine.schema.schema_id or "unknown"

  local cached_id = __input_type_cache[schema_id]
  if cached_id then
    return cached_id
  end

  local cfg       = env.engine.schema.config
  local result_id = "unknown"

  local n         = cfg:get_list_size("speller/algebra")
  for i = 0, n - 1 do
    local s = cfg:get_string(("speller/algebra/@%d"):format(i))
    if s then
      for symbol, id in pairs(wanxiang.INPUT_METHOD_MARKERS) do
        if s:find(symbol, 1, true) then
          if result_id == "unknown" then
            result_id = id -- 只记录第一个命中的 id
          end
        end
      end
    end
  end

  -- 写缓存
  __input_type_cache[schema_id] = result_id

  return result_id
end

-- === 拼音 / 声调工具 =======================================================

-- 带调符号 -> 数字键位（由 tone_mark_map 反向生成，单一数据源）
wanxiang.tone_mark_digit = {}
for _, marks in pairs(wanxiang.tone_mark_map) do
  for i, ch in ipairs(marks) do
    wanxiang.tone_mark_digit[ch] = wanxiang.tone_key_map[tostring(i)]
  end
end

-- 规范化拼音中的 v：
-- jqxy 后 -> u，nlzcs 后 -> ü
local normalize_v_memo = {}
function wanxiang.normalize_v(s)
  if not s or s == "" then return s end
  local cached = normalize_v_memo[s]
  if cached ~= nil then return cached end
  local r = s:gsub("^([jqxy])v", "%1u"):gsub("^([nlzcs])v", "%1ü")
  normalize_v_memo[s] = r
  return r
end

-- 将数字声调拼音（如 yuan4）逆向转换为带调拼音（如 yuàn）
local tone_mark_memo = {}
function wanxiang.tone_number_to_mark(py)
  if not py or py == "" then return py end
  local cached = tone_mark_memo[py]
  if cached ~= nil then return cached end
  local body, digit = py:match("^(.*)([1-5])$")
  if not body or not digit then return py end
  body = wanxiang.normalize_v(body)
  if digit == "5" then return body end
  local tone = tonumber(digit)
  local target
  if body:find("a") then
    target = "a"
  elseif body:find("o") then
    target = "o"
  elseif body:find("e") then
    target = "e"
  elseif body:find("iu$") then
    target = "u"
  elseif body:find("ui$") then
    target = "i"
  elseif body:find("i") then
    target = "i"
  elseif body:find("u") then
    target = "u"
  elseif body:find("ü") then
    target = "ü"
  elseif body == "ng" or body == "n" then
    target = "n"
  elseif body == "m" then
    target = "m"
  end
  if not target then return py end
  local mark = wanxiang.tone_mark_map[target][tone]
  local result
  if body:match("^[zcs]ii") then
    result = (body:gsub("^([zcs]i)i", "%1" .. mark))
  else
    result = (body:gsub(target, mark, 1))
  end
  tone_mark_memo[py] = result
  return result
end

-- 数字声调拼音 -> 无调拼音（如 yuan4 -> yuan），并规范化 v
local tone_plain_memo = {}
function wanxiang.tone_number_to_plain(py)
  if not py or py == "" then return py end
  local cached = tone_plain_memo[py]
  if cached ~= nil then return cached end
  local r = wanxiang.normalize_v(py:gsub("[1-5]$", ""))
  tone_plain_memo[py] = r
  return r
end

-- 转义 Lua 模式中的正则魔法字符，返回可直接用于 string.find/gsub/match 的 pattern
function wanxiang.escape_pattern(s)
  if not s then return "" end
  return s:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
end

wanxiang._file_signature_cache = setmetatable({}, { __mode = "k" })

local function _hash_bytes(hash, value)
  for i = 1, #value do
    hash = (hash * 131 + string.byte(value, i)) % 4294967296
  end
  return hash
end

function wanxiang.digest_parts(parts)
  local hash = 2166136261
  local bytes = 0
  for i = 1, #parts do
    local part = parts[i] or ""
    bytes = bytes + #part
    hash = _hash_bytes(hash, tostring(#part))
    hash = _hash_bytes(hash, ":")
    hash = _hash_bytes(hash, part)
    hash = _hash_bytes(hash, "|")
  end
  return string.format("%08x:%d:%d", hash, #parts, bytes)
end

function wanxiang.get_file_signature(path)
  local cached = wanxiang._file_signature_cache[path]
  if cached then return cached end
  local file, close = wanxiang.load_file_with_fallback(path, "rb")
  if not file then
    wanxiang._file_signature_cache[path] = "missing"
    return "missing"
  end
  local size = file:seek("end") or 0
  local parts = { tostring(size) }
  if size > 0 then
    file:seek("set", 0)
    parts[#parts + 1] = file:read(64) or ""
    local tail_pos = size - 64
    if tail_pos < 0 then tail_pos = 0 end
    file:seek("set", tail_pos)
    parts[#parts + 1] = file:read(64) or ""
    file:seek("set", math.floor(size / 2))
    parts[#parts + 1] = file:read(64) or ""
  end
  close()
  cached = wanxiang.digest_parts(parts)
  wanxiang._file_signature_cache[path] = cached
  return cached
end

-- === 只读数据缓存（packed blob + 偏移索引，供 user_abbrev / super_tips 共用） ===
-- 数据几乎不会改变，因此不再使用 LevelDb。为把数据尽量少地放进 Lua 堆，
-- 将 key->value 映射编码为单个 "key\tvalue\n" 大字符串（按 key 字节序排列），
-- 用数字偏移索引做二分查找与前缀扫描；缓存文件直接存该 blob，跨运行时可移植。

local STORE_CACHE_MAGIC = "WXRB"
local STORE_CACHE_VERSION = 2

local s_find = string.find
local s_sub = string.sub
local m_floor = math.floor

--- 把已按 key 字节序排序的 keys 与映射 map 编码为 blob 单串。
function wanxiang.blob_encode(keys, map)
  local parts = {}
  for i = 1, #keys do
    local k = keys[i]
    parts[i] = k .. "\t" .. map[k] .. "\n"
  end
  return t_concat(parts)
end

--- 扫描 blob 建立记录起点索引（含哨兵 pos[n+1] = #data+1）。
function wanxiang.blob_index(data)
  local pos = { 1 }
  local p = 1
  while true do
    p = s_find(data, "\n", p, true)
    if not p then break end
    pos[#pos + 1] = p + 1
    p = p + 1
  end
  if pos[#pos] ~= #data + 1 then
    pos[#pos + 1] = #data + 1
  end
  return pos
end

local function blob_key_at(data, pos, mid)
  local s = pos[mid]
  local tab = s_find(data, "\t", s, true)
  return s_sub(data, s, tab - 1)
end

--- 精确查找：二分返回 key 对应的 value，未命中返回 nil。
function wanxiang.blob_fetch(data, pos, key)
  local n = #pos - 1
  local lo, hi = 1, n
  while lo <= hi do
    local mid = m_floor((lo + hi) / 2)
    local k = blob_key_at(data, pos, mid)
    if k < key then
      lo = mid + 1
    elseif k > key then
      hi = mid - 1
    else
      local s = pos[mid]
      local tab = s_find(data, "\t", s, true)
      return s_sub(data, tab + 1, pos[mid + 1] - 2)
    end
  end
  return nil
end

--- 缓存文件路径：<user_data>/build/<kind>_<schema_id>.lub
function wanxiang.store_cache_path(kind, schema_id)
  local dir = rime_api.get_user_data_dir() or ""
  return dir .. "/build/" .. kind .. "_" .. schema_id .. ".lub"
end

--- 写 blob 缓存（头：魔数 + 版本 + 签名长度 + 签名 + 换行，后接 blob）。
--- 换行使首条数据记录独立成行，不与签名粘连。
--- 任何失败返回 false，调用方静默回退为纯内存构建。
function wanxiang.write_store_cache(path, signature, blob)
  if not blob then return false end
  local sig_len = #signature
  if sig_len > 255 then return false end
  local header = STORE_CACHE_MAGIC
      .. string.char(STORE_CACHE_VERSION, sig_len)
      .. signature .. "\n"
  local file, err = io.open(path, "wb")
  if not file then return false end
  local written = file:write(header, blob)
  file:close()
  return written ~= nil
end

--- 读 blob 缓存并校验签名；不匹配或读取失败返回 nil。
--- 返回值是 blob 字符串，需再经 wanxiang.blob_index 建索引。
function wanxiang.read_store_cache(path, signature)
  local file, err = io.open(path, "rb")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  if not content then return nil end

  if content:sub(1, 4) ~= STORE_CACHE_MAGIC then return nil end
  if content:byte(5) ~= STORE_CACHE_VERSION then return nil end
  local sig_len = content:byte(6)
  if not sig_len then return nil end
  if content:sub(7, 6 + sig_len) ~= signature then return nil end
  if content:byte(7 + sig_len) ~= 0x0a then return nil end

  return content:sub(8 + sig_len)
end

return wanxiang
