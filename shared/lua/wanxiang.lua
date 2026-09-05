---@diagnostic disable: undefined-global

-- 万象的一些共用工具函数
local wanxiang                = {}

local t_concat                = table.concat

-- x-release-please-start-version

wanxiang.version              = "v18.0.0"

-- x-release-please-end

-- 全局内容
---@alias PROCESS_RESULT ProcessResult
wanxiang.RIME_PROCESS_RESULTS = {
  kRejected = 0, -- 表示处理器明确拒绝了这个按键，停止处理链但不返回 true
  kAccepted = 1, -- 表示处理器成功处理了这个按键，停止处理链并返回 true
  kNoop = 2      -- 表示处理器没有处理这个按键，继续传递给下一个处理器
}

-- 整个生命周期内不变，缓存判断结果
local is_mobile_device        = nil
-- 判断是否为手机设备
---@author amzxyz
---@return boolean
function wanxiang.is_mobile_device()
  local function _is_mobile_device()
    local dist = rime_api.get_distribution_code_name() or ""
    local user_data_dir = rime_api.get_user_data_dir() or ""
    local sys_dir = rime_api.get_shared_data_dir() or ""
    -- 转换为小写以便比较
    local lower_dist = dist:lower()
    local lower_path = user_data_dir:lower()
    local sys_lower_path = sys_dir:lower()
    -- 主判断：常见移动端输入法
    if lower_dist == "trime" or
        lower_dist == "hamster" or
        lower_dist == "hamster3" or
        lower_dist == "default" or   -- 超越
        lower_dist == "xime" or      -- 曦码
        lower_dist == "lyraime" then -- 灵韵
      return true
    end

    -- 补充判断：路径中包含移动设备特征
    if lower_path:find("/android/") or
        lower_path:find("/mobile/") or
        lower_path:find("/sdcard/") or
        lower_path:find("/data/storage/") or
        lower_path:find("/storage/emulated/") then
      return true
    end

    -- 特定平台判断（Android/Linux）
    if jit and jit.os then
      local os_name = jit.os:lower()
      if os_name:find("android") then
        return true
      end
    end

    -- 所有检查未通过则默认为桌面设备
    return false
  end

  if is_mobile_device == nil then
    is_mobile_device = _is_mobile_device()
  end
  return is_mobile_device
end

local is_special_desktop = nil

--- 判断是否为需要特殊处理的桌面环境（squirrel、Cobra 或 fcitx-rime+library）
---@return boolean
function wanxiang.is_special_desktop()
  if is_special_desktop == nil then
    local dist = rime_api.get_distribution_code_name() or ""
    local sys_dir = rime_api.get_shared_data_dir() or ""
    local lower_dist = dist:lower()
    local lower_sys = sys_dir:lower()

    local exclude = false
    if lower_dist == "squirrel" or lower_dist == "cobra" then
      exclude = true
    elseif lower_dist == "fcitx-rime" and lower_sys:find("library") then
      exclude = true
    end
    is_special_desktop = exclude
  end
  return is_special_desktop
end

--- 检测是否为万象专业版
---@param env Env
---@return boolean
function wanxiang.is_pro_scheme(env)
  -- local schema_name = env.engine.schema.schema_name
  -- return schema_name:gsub("PRO$", "") ~= schema_name
  return env.engine.schema.schema_id == "wanxiang_zrm"
      or env.engine.schema.schema_id == "wanxiang_zrm_18keys"
      or env.engine.schema.schema_id == "wanxiang_zrm_14keys"
      or env.engine.schema.schema_id == "wanxiang_l17keys"
      or env.engine.schema.schema_id == "wanxiang_flypy"
      or env.engine.schema.schema_id == "wanxiang_flypy_18keys"
      or env.engine.schema.schema_id == "wanxiang_flypy_14keys"
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

  return seg:has_tag("number") or  -- number_translator.lua 数字金额转换 R+数字
      seg:has_tag("unicode") or    -- unicode.lua 输出 Unicode 字符 U+小写字母或数字
      --seg:has_tag("punct") or      -- 标点符号 全角半角提示
      seg:has_tag("calculator") or -- super_calculator.lua V键计算器
      seg:has_tag("datetime") or   -- datetime.lua /date /time etc.
      seg:has_tag("Ndate")         -- datetime.lua N日期功能
end

---判断文件是否存在
function wanxiang.file_exists(filename)
  local f = io.open(filename, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
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

-- 判断字符是否为汉字
function wanxiang.IsChineseCharacter(text)
  return wanxiang.is_chinese_codepoint(utf8.codepoint(text))
end

---按照优先顺序获取文件：用户目录 > 系统目录
---@param filename string 相对路径
---@retur string | nil
-- 辅助函数：检测路径是否为绝对路径（以 / 或盘符开头）
local function is_absolute_path(path)
  if not path then return false end
  if path:sub(1, 1) == "/" or path:sub(1, 1) == "\\" then
    return true
  end
  if path:match("^[a-zA-Z]:[\\/]") then
    return true
  end
  return false
end

function wanxiang.get_filename_with_fallback(filename)
  local _path = filename:gsub("^[\\/]+", "")

  local user_dir = rime_api.get_user_data_dir()

  if not is_absolute_path(user_dir) then
    return filename
  end
  local user_path = user_dir .. "/" .. _path
  if wanxiang.file_exists(user_path) then
    return user_path
  end

  local shared_dir = rime_api.get_shared_data_dir()

  if not is_absolute_path(shared_dir) then
    return filename
  end
  local shared_path = shared_dir .. "/" .. _path
  if wanxiang.file_exists(shared_path) then
    return shared_path
  end

  return nil
end

-- 按照优先顺序加载文件：用户目录 > 系统目录
---@param filename string 相对路径
---@retur file* | nil, function
function wanxiang.load_file_with_fallback(filename, mode)
  mode = mode or "r" -- 默认读取模式

  local _filename = wanxiang.get_filename_with_fallback(filename)

  local file, err
  local function close()
    if not file then return end
    file:close()
    file = nil
  end

  if _filename then
    file, err = io.open(_filename, mode)
  end

  return file, close, err
end

local USER_ID_DEFAULT = "unknown"
---作为「小狼毫」和「仓」 `rime_api.get_user_id()` 的一个 workaround
---详见：
---1. https://github.com/rime/weasel/pull/1649
---2. https://github.com/rime/librime/issues/1038
---@return string
function wanxiang.get_user_id()
  local user_id = rime_api.get_user_id()
  if user_id ~= USER_ID_DEFAULT then return user_id end

  local user_data_dir = rime_api.get_user_data_dir()
  local installation_path = user_data_dir .. "/installation.yaml"
  local installation_file, _ = io.open(installation_path, "r")
  if not installation_file then return user_id end

  for line in installation_file:lines() do
    local key, value = line:match('^([^#:]+):%s+"?([^"]%S+[^"])"?')
    if key == "installation_id" then
      user_id = value
      break
    end
  end

  installation_file:close()
  return user_id
end

wanxiang.INPUT_METHOD_MARKERS = {
  ["Ⅰ"] = "pinyin", -- 全拼
  ["Ⅱ"] = "zrm", -- 自然码双拼
  ["Ⅲ"] = "flypy", -- 小鹤双拼
  ["Ⅽ"] = "lssp", -- 李氏三拼
  ["ⅲ"] = "ⅲ", -- 间接辅助标记：命中则额外返回 md="ⅲ"
  ["ⅱ"] = "t9" -- 拼音九键
}

local __input_type_cache      = {} -- 缓存首个命中的 id（兼容旧用法）
local __input_md_cache        = {} -- 新增：是否命中“ⅲ”（若命中则为 "ⅲ"，否则为 nil）

--- 根据 speller/algebra 中的特殊符号返回输入类型：
--- - 若未命中“ⅲ”，只返回 id（保持旧行为）
--- - 若命中“ⅲ”，返回两个值：id, "ⅲ"
---@param env Env
---@return string                -- id
---@return string|nil            -- md（仅在命中“ⅲ”时返回 "ⅲ"）
function wanxiang.get_input_method_type(env)
  local schema_id = env.engine.schema.schema_id or "unknown"

  -- 命中缓存则按是否有 md 决定返回 1 个或 2 个值
  local cached_id = __input_type_cache[schema_id]
  if cached_id then
    local cached_md = __input_md_cache[schema_id]
    if cached_md then
      return cached_id, cached_md -- 返回两个值：id, "ⅲ"
    else
      return cached_id            -- 只返回 id
    end
  end

  local cfg       = env.engine.schema.config
  local result_id = "unknown"
  local md        = nil -- 只有命中“ⅲ”时设为 "ⅲ"

  local n         = cfg:get_list_size("speller/algebra")
  for i = 0, n - 1 do
    local s = cfg:get_string(("speller/algebra/@%d"):format(i))
    if s then
      -- 不提前返回：需要把整段都扫描完，才能知道是否命中“ⅲ”
      for symbol, id in pairs(wanxiang.INPUT_METHOD_MARKERS) do
        if s:find(symbol, 1, true) then
          if symbol == "ⅲ" or id == "ⅲ" then
            md = "ⅲ" -- 记录辅助标记
          else
            if result_id == "unknown" then
              result_id = id -- 只记录第一个“正常映射”的 id
            end
          end
        end
      end
    end
  end

  -- 写缓存
  __input_type_cache[schema_id] = result_id
  __input_md_cache[schema_id]   = md -- 命中则为 "ⅲ"，否则为 nil

  -- 返回：命中“ⅲ”→两个值；否则一个值
  if md then
    return result_id, md
  else
    return result_id
  end
end

-- === 拼音 / 声调工具 =======================================================

-- 基础元音 -> 四个带调符号（顺序即 1-4 声）
wanxiang.tone_mark_map = {
  a = { 'ā', 'á', 'ǎ', 'à' },
  o = { 'ō', 'ó', 'ǒ', 'ò' },
  e = { 'ē', 'é', 'ě', 'è' },
  i = { 'ī', 'í', 'ǐ', 'ì' },
  u = { 'ū', 'ú', 'ǔ', 'ù' },
  ['ü'] = { 'ǖ', 'ǘ', 'ǚ', 'ǜ' },
  n = { 'n̄', 'ń', 'ň', 'ǹ' },  -- n̄=n+U+0304
  m = { 'm̄', 'ḿ', 'm̌', 'm̀' },
}

-- 数字声调键位：1-5 调 -> 6/7/8/9/0
wanxiang.tone_key_map = {
  ['1'] = '6',
  ['2'] = '7',
  ['3'] = '8',
  ['4'] = '9',
  ['5'] = '0',
}

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

-- === 按键映射展开 ==========================================================

local KEYMAP_SRC = "qwertyuiopasdfghjklzxcvbnm"
local KEYMAP_TARGETS = {
  ["18"] = "qwwrryuiipassffhjjlzxxvbbm",
  ["14"] = "qqeettuuooaaddggjjlzzccbbm",
  ["t9"] = "79378984672733445559928266"
}

--- 根据 keymap ID 构建字符展开表 (逆xlit)
--- "18" → {w={w,e}, r={r,t}, i={i,o}, s={s,d}, f={f,g}, j={j,k}, x={x,c}, b={b,n}}
--- "14" → {q={q,w}, e={e,r}, t={t,y}, u={u,i}, o={o,p}, a={a,s}, d={d,f}, g={g,h}, j={j,k}, z={z,x}, c={c,v}, b={b,n}}
--- 返回 table<目标字符, {源字符...}> | nil (26键返回 nil)
function wanxiang.build_keymap_expand(keymap_id)
  if not KEYMAP_TARGETS[keymap_id] then return nil end
  local tgt = KEYMAP_TARGETS[keymap_id]
  local expand = {}
  for i = 1, #tgt do
    local tc = tgt:sub(i, i)
    local sc = KEYMAP_SRC:sub(i, i)
    if not expand[tc] then expand[tc] = {} end
    local found = false
    for _, c in ipairs(expand[tc]) do
      if c == sc then
        found = true; break
      end
    end
    if not found then table.insert(expand[tc], sc) end
  end
  for c, exps in pairs(expand) do
    if #exps == 1 and exps[1] == c then
      expand[c] = nil
    end
  end
  return next(expand) and expand or nil
end

--- 根据 keymap ID 构建字符逆展开表 (输入字符 → 能产生它的按键集合)
--- 与 build_keymap_expand 互为反向：preimage[字母] = {字母} ∪ {p : 字母 ∈ expand[p]}
--- "18" → {e={e,w}, t={t,r}, o={o,i}, d={d,s}, g={g,f}, k={k,j}, c={c,x}, n={n,b}}
--- "t9" → {a={a,2}, b={b,2}, ... , z={z,9}}
--- 返回 table<字母, {可输入字符...}> | nil (26键返回 nil)
function wanxiang.build_keymap_preimage(keymap_id)
  local expand = wanxiang.build_keymap_expand(keymap_id)
  if not expand then return nil end
  local pre = {}
  for i = 97, 122 do
    local l = string.char(i)
    local set = { l }
    for p, letters in pairs(expand) do
      for _, le in ipairs(letters) do
        if le == l then
          local dup = false
          for _, s in ipairs(set) do
            if s == p then
              dup = true
              break
            end
          end
          if not dup then set[#set + 1] = p end
        end
      end
    end
    pre[l] = set
  end
  return pre
end

--- 生成输入码的所有按键展开候选 (笛卡尔积)
--- code: 输入编码, expand: 展开表, max: 候选上限(默认32)
--- 返回有序列表 {原始码, 展开1, 展开2, ...}
function wanxiang.expand_keymap_code(code, expand, max)
  if not expand then return { code } end
  max = max or 64

  -- 一次性预分拆为固定段 / 可展开段交错序列
  local segs, sn = {}, 0
  local last = 1
  for i = 1, #code do
    local e = expand[code:sub(i, i)]
    if e then
      if i > last then
        sn = sn + 1; segs[sn] = code:sub(last, i - 1)
      end
      sn = sn + 1; segs[sn] = e
      last = i + 1
    end
  end
  if last <= #code then
    sn = sn + 1; segs[sn] = code:sub(last)
  end
  if sn == 0 then return { code } end

  -- 递归时仅操作 buffer，只在叶子节点做一次 concat
  local results = {}
  local buf, bn = {}, 0

  local function visit(i)
    if #results >= max then return end
    if i > sn then
      results[#results + 1] = t_concat(buf, "", 1, bn)
      return
    end
    local s = segs[i]
    if type(s) == "string" then
      bn = bn + 1; buf[bn] = s
      visit(i + 1)
      bn = bn - 1
    else
      for _, c in ipairs(s) do
        bn = bn + 1; buf[bn] = c
        visit(i + 1)
        bn = bn - 1
      end
    end
  end

  visit(1)
  return results
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

-- === 只读数据缓存（packed blob + 偏移索引，供 super_replacer / super_tips 共用） ===
-- 数据几乎不会改变，因此不再使用 LevelDb。为把数据尽量少地放进 Lua 堆，
-- 将 key->value 映射编码为单个 "key\tvalue\n" 大字符串（按 key 字节序排列），
-- 用数字偏移索引做二分查找与前缀扫描；缓存文件直接存该 blob，跨运行时可移植。

local STORE_CACHE_MAGIC = "WXRB"
local STORE_CACHE_VERSION = 1

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

--- 前缀扫描：等价于原 LevelDb 的有序 query(prefix)。
--- handler(key, value) 按 key 字节序被依次调用，仅匹配 key 以 prefix 开头的记录。
function wanxiang.blob_query_prefix(data, pos, prefix, handler)
  local n = #pos - 1
  local lo, hi = 1, n
  while lo <= hi do
    local mid = m_floor((lo + hi) / 2)
    if blob_key_at(data, pos, mid) < prefix then
      lo = mid + 1
    else
      hi = mid - 1
    end
  end

  while lo <= n do
    local s = pos[lo]
    if s_find(data, prefix, s, true) ~= s then break end
    local tab = s_find(data, "\t", s, true)
    handler(s_sub(data, s, tab - 1), s_sub(data, tab + 1, pos[lo + 1] - 2))
    lo = lo + 1
  end
end

--- 缓存文件路径：<user_data>/build/<kind>_<schema_id>.lub
function wanxiang.store_cache_path(kind, schema_id)
  local dir = rime_api.get_user_data_dir() or ""
  return dir .. "/build/" .. kind .. "_" .. schema_id .. ".lub"
end

--- 写 blob 缓存（头：魔数 + 版本 + 签名长度 + 签名，后接 blob）。
--- 任何失败返回 false，调用方静默回退为纯内存构建。
function wanxiang.write_store_cache(path, signature, blob)
  if not blob then return false end
  local sig_len = #signature
  if sig_len > 255 then return false end
  local header = STORE_CACHE_MAGIC
      .. string.char(STORE_CACHE_VERSION, sig_len)
      .. signature
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

  return content:sub(7 + sig_len)
end

return wanxiang
