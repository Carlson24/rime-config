---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size
local action_rows = safe_require("nekocat.layouts._action_row")({})

local keyboard = keyboard {
  name = "14 键布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    safe_require("nekocat.layouts._number_row").number_row(),
    row {
      keys = {
        key(merge(S.lookup, key { click = "ReverseLookup", width = 0.11 })),
        key(merge(S.e, key { label = { { text = "Q W" } }, click = "q", label_symbol = { { text = "\"" } }, swipe_up = "\"", popup = { "Q", "W", "q", "w" } })),
        key(merge(S.r, key { label = { { text = "E R" } }, click = "e", label_symbol = { { text = "+" } }, swipe_up = "+", popup = { "E", "R", "e", "r" } })),
        key(merge(S.t, key { label = { { text = "T Y" } }, click = "t", label_symbol = { { text = "-" } }, swipe_up = "-", popup = { "T", "Y", "t", "y" } })),
        key(merge(S.y, key { label = { { text = "U I" } }, click = "u", label_symbol = { { text = ":" } }, swipe_up = ":", popup = { "U", "I", "u", "i" } })),
        key(merge(S.u, key { label = { { text = "O P" } }, click = "o", label_symbol = { { text = "\\" } }, swipe_up = "\\", popup = { "O", "P", "o", "p" } }))
      }
    },
    row {
      keys = {
        key(merge(S.slash, key { click = "/", width = 0.11 })),
        key(merge(S.a, key { label = { { text = "A S" } }, click = "a", label_symbol = { { text = "<" } }, swipe_up = "<", popup = { "A", "S", "a", "s" } })),
        key(merge(S.f, key { label = { { text = "D F" } }, click = "d", label_symbol = { { text = "=" } }, swipe_up = "=", popup = { "D", "F", "d", "f" } })),
        key(merge(S.g, key { label = { { text = "G H" } }, click = "g", label_symbol = { { text = ">" } }, swipe_up = ">", popup = { "G", "H", "g", "h" }, swipe_down = "KeyboardEditor" })),
        key(merge(S.h, key { label = { { text = "J K" } }, click = "j", label_symbol = { { text = "?" } }, swipe_up = "?", popup = { "J", "K", "j", "k", "?", "¿" } })),
        key(merge(S.l, key { label = { { text = " L " } }, click = "l", label_symbol = { { text = ";" } }, swipe_up = ";", popup = { "L", "l", "·", "§" } }))
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@keyboard-caps" } }, key_text_size = func_key_text_size, width = 0.11 })),
        key(merge(S.x, key { label = { { text = "Z X" } }, click = "z", label_symbol = { { text = { "{", "ic@select-all" }, align = "justify" } }, swipe_up = "{", popup = { "SelectAll", "Z", "X", "z", "x" } })),
        key(merge(S.c, key { label = { { text = "C V" } }, click = "c", label_symbol = { { text = { "_", "ic@content-copy" }, align = "justify" } }, swipe_up = "_", popup = { "Copy", "C", "V", "c", "v" } })),
        key(merge(S.v, key { label = { { text = "B N" } }, click = "b", label_symbol = { { text = { "}", "ic@content-paste" }, align = "justify" } }, swipe_up = "}", popup = { "Paste", "B", "N", "b", "n" }, swipe_down = "WindowClipboard" })),
        key(merge(S.m, key { label = { { text = " M " } }, click = "m", label_symbol = { { text = { "~", "ic@content-cut" }, align = "justify" } }, swipe_up = "|", popup = { "Cut", "M", "m" } })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size }))
      }
    },
    action_rows.action,
    action_rows.extra
  }
}

return keyboard
