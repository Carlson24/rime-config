---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors") -- 按键样式
local func_key_text_size = safe_require("nekocat.font_offset").lssp_func_key_text_size
local main_key_text_size = safe_require("nekocat.font_offset").lssp_key_text_size
local action_rows = safe_require("nekocat.layouts._action_row")({})

local keyboard = keyboard {
  name = "李氏三拼3x5b3布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    safe_require("nekocat.layouts._number_row").number_row(),
    row {
      keys = {
        key(merge(S.lookup, key { click = "ReverseLookup", key_text_size = func_key_text_size, width = 0.11 })),
        key(merge(S.u, key { label = { { text = "zh z" } }, click = "t", label_symbol = { { text = { "V/Z", " ", "\\" }, align = "justify" } }, swipe_up = "\\", popup = { "V", "Z", "v", "z" }, key_text_size = main_key_text_size })),
        key(merge(S.e, key { label = { { text = "b zy" } }, click = "q", label_symbol = { { text = { "B/A", " ", "\"" }, align = "justify" } }, swipe_up = "\"", popup = { "B", "A", "b", "a" }, key_text_size = main_key_text_size })),
        key(merge(S.r, key { label = { { text = "p cy" } }, click = "w", label_symbol = { { text = { "P/E", " ", "+" }, align = "justify" } }, swipe_up = "+", popup = { "P", "E", "p", "e" }, key_text_size = main_key_text_size })),
        key(merge(S.t, key { label = { { text = "m sy" } }, click = "e", label_symbol = { { text = { "M/O", " ", "-" }, align = "justify" } }, swipe_up = "-", popup = { "M", "O", "m", "o" }, swipe_down = "KeyboardEditor", key_text_size = main_key_text_size })),
        key(merge(S.y, key { label = { { text = "r f" } }, click = "r", label_symbol = { { text = { "R/F", " ", ":" }, align = "justify" } }, swipe_up = ":", popup = { "R", "F", "r", "f" }, key_text_size = main_key_text_size })),
        key(merge(S.up, key { click = "Up", key_text_size = func_key_text_size, width = 0.11 }))
      }
    },
    row {
      keys = {
        key(merge(S.slash, key { click = "/", key_text_size = func_key_text_size, width = 0.11 })),
        key(merge(S.j, key { label = { { text = "ch c" } }, click = "g", label_symbol = { { text = { "I/C", "𠃋", ";" }, align = "justify", color = { "text", "mauve", "text" } } }, swipe_up = ";", popup = { "I", "C", "i", "c", "·", "§" }, swipe_down = "Z", key_text_size = main_key_text_size })),
        key(merge(S.d, key { label = { { text = "d" } }, click = "a", label_symbol = { { text = { "D", "一", "<" }, align = "justify", color = { "text", "mauve", "text" } } }, swipe_up = "<", popup = { "D", "d" }, swipe_down = "H", key_text_size = main_key_text_size })),
        key(merge(S.f, key { label = { { text = "t" } }, click = "s", label_symbol = { { text = { "T", "丨", "=" }, align = "justify", color = { "text", "mauve", "text" } } }, swipe_up = "=", popup = { "T", "t" }, swipe_down = "S", key_text_size = main_key_text_size })),
        key(merge(S.g, key { label = { { text = "n" } }, click = "d", label_symbol = { { text = { "N", "丿", ">" }, align = "justify", color = { "text", "mauve", "text" } } }, swipe_up = ">", popup = { "N", "n" }, swipe_down = "P", key_text_size = main_key_text_size })),
        key(merge(S.h, key { label = { { text = "l" } }, click = "f", label_symbol = { { text = { "L", "丶", "?" }, align = "justify", color = { "text", "mauve", "text" } } }, swipe_up = "?", popup = { "L", "l" }, swipe_down = "N", key_text_size = main_key_text_size })),
        key(merge(S.down, key { click = "Down", key_text_size = func_key_text_size, width = 0.11 }))
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@keyboard-caps" } }, key_text_size = func_key_text_size, width = 0.11 })),
        key(merge(S.n, key { label = { { text = "sh s" } }, click = "b", label_symbol = { { text = { "U/S", "ic@ideogram-cjk", "~" }, align = "justify" } }, swipe_up = "~", popup = { "ZiTools", "U", "S", "u", "s" }, key_text_size = main_key_text_size })),
        key(merge(S.x, key { label = { { text = "g j" } }, click = "z", label_symbol = { { text = { "G/J", "ic@select-all", "{" }, align = "justify" } }, swipe_up = "{", popup = { "SelectAll", "G", "J", "g", "j" }, key_text_size = main_key_text_size })),
        key(merge(S.c, key { label = { { text = "k q" } }, click = "x", label_symbol = { { text = { "K/Q", "ic@content-copy", "_" }, align = "justify" } }, swipe_up = "_", popup = { "Copy", "K", "Q", "k", "q" }, key_text_size = main_key_text_size })),
        key(merge(S.v, key { label = { { text = "h x" } }, click = "c", label_symbol = { { text = { "H/X", "ic@content-paste", "}" }, align = "justify" } }, swipe_up = "}", popup = { "Paste", "H", "X", "h", "x" }, swipe_down = "WindowClipboard", key_text_size = main_key_text_size })),
        key(merge(S.b, key { label = { { text = "w y" } }, click = "v", label_symbol = { { text = { "W/Y", "ic@content-cut", "|" }, align = "justify" } }, swipe_up = "|", popup = { "Cut", "W", "Y", "w", "y" }, key_text_size = main_key_text_size })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size, width = 0.11 }))
      }
    },
    action_rows.action,
    action_rows.extra
  }
}

return keyboard
