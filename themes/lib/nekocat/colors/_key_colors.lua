-- SPDX-License-Identifier: GPL-3.0-or-later
-- 按键独立配色生成器
--
-- 为 63 个按键生成配色引用，读取 SchemeColors 表中的独立配色键名。
-- 四级回退链：{key_id}_{field} → {row_group}_{field} → {func}_{field} → {field}
--   - qwertyuiop          → top_row
--   - asdfghjkl           → home_row
--   - zxcvbnm             → bottom_row
--   - num0～num9          → num_row
--   - shift/enter/…       → func
--   - func/space/行分组   → 直接回退全局
--
-- 模块返回一个预计算的样式表，直接包含 63 个 key() 片段。
-- 所有颜色字段引用行分组键名（如 "num_row_key_back_color"）或全局键名（如 "key_back_color"），
-- 由主题引擎运行时解析。无需传入 scheme_colors 即可直接使用。
--
-- 用法（配色方案中）：
--   scheme("my", {
--     key_back_color         = "0x1e1e2e",
--     a_key_back_color       = "0xFF0000",        -- 逐键覆盖（可选）
--     num_row_key_back_color = "0x00FF00",        -- 行分组覆盖
--     func_key_back_color    = "0x0000FF",        -- 功能键分组覆盖
--   })
--
-- 用法（键盘布局中）：
--   local S = safe_require("nekocat.colors._key_colors")
--   key(merge(S.a,       { click = "a",       label = "a" })),
--   key(merge(S.shift,   { click = "Shift_L" })),
--   key(merge(S.num0,    { click = "0",       label = "0" })),
--   key(merge(S.c,       { click = "c",       label = "c" })),  -- 无独立配色，回退全局
--
-- 逐键精确覆盖（需要 scheme_colors 时）：
--   local override = S.make_letter_key_styles(my_scheme_colors)
--   key(merge(override.a, { click = "a", label = "a" })),

local FALLBACK_ROWS = {
  q = "top_row",
  w = "top_row",
  e = "top_row",
  r = "top_row",
  t = "top_row",
  y = "top_row",
  u = "top_row",
  i = "top_row",
  o = "top_row",
  p = "top_row",
  a = "home_row",
  s = "home_row",
  d = "home_row",
  f = "home_row",
  g = "home_row",
  h = "home_row",
  j = "home_row",
  k = "home_row",
  l = "home_row",
  z = "bottom_row",
  x = "bottom_row",
  c = "bottom_row",
  v = "bottom_row",
  b = "bottom_row",
  n = "bottom_row",
  m = "bottom_row",
  num0 = "num_row",
  num1 = "num_row",
  num2 = "num_row",
  num3 = "num_row",
  num4 = "num_row",
  num5 = "num_row",
  num6 = "num_row",
  num7 = "num_row",
  num8 = "num_row",
  num9 = "num_row",
  kp0 = "mainkey",
  kp1 = "mainkey",
  kp2 = "mainkey",
  kp3 = "mainkey",
  kp4 = "mainkey",
  kp5 = "mainkey",
  kp6 = "mainkey",
  kp7 = "mainkey",
  kp8 = "mainkey",
  kp9 = "mainkey",
  shift = "func",
  backspace = "func",
  num = "func",
  delete = "func",
  comma = "func",
  period = "func",
  slash = "func",
  semicolon = "func",
  ctrl = "func",
  alt = "func",
  enter = "func",
  switch = "func",
  tab = "func",
  capslock = "func",
  escape = "func",
  clear = "func",
  up = "func",
  down = "func",
  left = "func",
  right = "func",
  lookup = "func",
  num_row = "func",
  top_row = "mainkey",
  home_row = "mainkey",
  bottom_row = "mainkey"
}

local KEY_IDS = {
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
  "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
  "u", "v", "w", "x", "y", "z",
  "num0", "num1", "num2", "num3", "num4",
  "num5", "num6", "num7", "num8", "num9",
  "kp0", "kp1", "kp2", "kp3", "kp4",
  "kp5", "kp6", "kp7", "kp8", "kp9",
  "func", "shift", "backspace", "num", "delete",
  "comma", "period", "slash", "semicolon", "ctrl", "alt",
  "enter", "space", "switch", "tab", "capslock", "escape",
  "clear", "up", "down", "left", "right", "lookup",
  "num_row", "top_row", "home_row", "bottom_row", "mainkey"
}

local COLOR_FIELDS = {
  "key_back_color",
  "key_text_color",
  "key_symbol_color",
  "key_border_color",
  "hilited_key_back_color",
  "hilited_key_text_color",
  "hilited_key_symbol_color"
}

--- 基于逐键配色名计算 63 个按键的预建样式表。
--- 每个字段引用 {key_id}_{field} 键名（如 "num0_key_back_color"），
--- 颜色值由 fallback_colors 在运行时逐级回退到实际色值。
--- 返回 { a = key{key_back_color="a_key_back_color", ...}, num0 = key{...}, ... }
local function make_row_group_styles()
  local styles = {}
  for _, key_id in ipairs(KEY_IDS) do
    local fields = {}
    for _, field in ipairs(COLOR_FIELDS) do
      fields[field] = key_id .. "_" .. field
    end
    styles[key_id] = key(fields)
  end
  return styles
end

--- 构建 fallback_colors 映射表：{key_id}_{field} → 回退键名
---
--- 例如：num0_key_back_color → num_row_key_back_color → key_back_color
--- 例如：shift_key_back_color → func_key_back_color → key_back_color
---
--- 用于主题根表 fallback_colors，由主题引擎在运行时逐级回退解析颜色。
---@return { [string]: string }
local function build_fallback_colors()
  local fc = {}
  for _, key_id in ipairs(KEY_IDS) do
    local row = FALLBACK_ROWS[key_id]
    for _, field in ipairs(COLOR_FIELDS) do
      local key_specific = key_id .. "_" .. field
      if row then
        fc[key_specific] = row .. "_" .. field
      else
        fc[key_specific] = field
      end
    end
  end
  return fc
end

local M = make_row_group_styles()

--- 基于 scheme_colors 生成逐键精确覆盖的样式表。
---
--- 四级回退链：{key_id}_{field} → {row_group}_{field} → {field}
---   - qwertyuiop → top_row / asdfghjkl → home_row / zxcvbnm → bottom_row / num0～9 → num_row
---   - shift/backspace/enter/… → func
---   - func/space/行分组 → 直接回退全局 field
---
--- 返回值中颜色字段均为 SchemeColors 键名字符串，由主题引擎运行时解析为实际色值。
---
--- 用法：
---   local ks = safe_require("nekocat.colors._key_colors")
---   local styles = ks.make_letter_key_styles(my_scheme_colors)
---   key(merge(styles.a, { click = "a", label = "a" })),
---
---@param scheme_colors SchemeColors  # 配色方案的 colors 表
---@return KeyColorStyles             # 全部按键的配色引用
local function make_letter_key_styles(scheme_colors)
  local styles = {}

  for _, key_id in ipairs(KEY_IDS) do
    local fields = {}
    for _, field in ipairs(COLOR_FIELDS) do
      local specific = key_id .. "_" .. field
      if scheme_colors[specific] then
        fields[field] = specific
      else
        local row = FALLBACK_ROWS[key_id]
        if row then
          local row_specific = row .. "_" .. field
          fields[field] = scheme_colors[row_specific] or field
        else
          fields[field] = field
        end
      end
    end
    styles[key_id] = key(fields)
  end

  return styles
end

M.make_letter_key_styles = make_letter_key_styles
M.fallback_colors = build_fallback_colors()
M.build_fallback_colors = build_fallback_colors

return M
