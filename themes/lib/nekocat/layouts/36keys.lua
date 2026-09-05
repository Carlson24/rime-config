---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size
local action_rows = safe_require("nekocat.layouts._action_row")({})

local keyboard = keyboard {
  name = "乱序 17 布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    safe_require("nekocat.layouts._number_row").number_row(),
    row {
      keys = {
        key(merge(S.lookup, key { click = "ReverseLookup", width = 0.11 })),
        key(merge(S.e, key { label = { { text = "H P" } }, click = "h", label_symbol = { { text = "\"" } }, swipe_up = "`", popup = { "H", "P", "A", "h", "p", "a" } })),
        key(merge(S.r, key { label = { { text = "Sh" } }, click = "s", label_symbol = { { text = "+" } }, swipe_up = "~", popup = { "U", "u" } })),
        key(merge(S.t, key { label = { { text = "Zh" } }, click = "z", label_symbol = { { text = "-" } }, swipe_up = "{", popup = { "V", "v" } })),
        key(merge(S.y, key { label = { { text = " B " } }, click = "b", label_symbol = { { text = ":" } }, swipe_up = "}", popup = { "B", "b" } })),
        key(merge(S.u, key { label = { { text = "oXv" } }, click = "x", label_symbol = { { text = "?" } }, swipe_up = "+", popup = { "O", "X", "o", "x", "?", "¿" } })),
        key(merge(S.i, key { label = { { text = "M S" } }, click = "m", label_symbol = { { text = "\\" } }, swipe_up = "=", popup = { "M", "S", "m", "s" } }))
      }
    },
    row {
      keys = {
        key(merge(S.slash, key { click = "/", width = 0.11 })),
        key(merge(S.d, key { label = { { text = " L " } }, click = "l", label_symbol = { { text = "×" } }, swipe_up = "×", popup = { "L", "l" } })),
        key(merge(S.f, key { label = { { text = " D " } }, click = "d", label_symbol = { { text = "÷" } }, swipe_up = "÷", popup = { "D", "d", "U", "u" } })),
        key(merge(S.g, key { label = { { text = " Y " } }, click = "y", label_symbol = { { text = "<" } }, swipe_up = "<", popup = { "Y", "y" }, swipe_down = "KeyboardEditor" })),
        key(merge(S.h, key { label = { { text = "W Z" } }, click = "w", label_symbol = { { text = "=" } }, swipe_up = "=", popup = { "W", "Z", "E", "w", "z", "e" } })),
        key(merge(S.j, key { label = { { text = "J K" } }, click = "j", label_symbol = { { text = ">" } }, swipe_up = ">", popup = { "J", "K", "I", "j", "k", "i" } })),
        key(merge(S.k, key { label = { { text = "N R" } }, click = "n", label_symbol = { { text = ";" } }, swipe_up = ";", popup = { "N", "R", "n", "r", "·", "§" } }))
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@keyboard-caps" } }, key_text_size = func_key_text_size, width = 0.11 })),
        key(merge(S.x, key { label = { { text = "Ch" } }, click = "c", label_symbol = { { text = { "{", "ic@select-all" }, align = "justify" } }, swipe_up = "{", popup = { "SelectAll", "I", "i" } })),
        key(merge(S.c, key { label = { { text = "Q~" } }, click = "q", label_symbol = { { text = { "_", "ic@content-copy" }, align = "justify" } }, swipe_up = "_", popup = { "Copy", "Q", "q" } })),
        key(merge(S.v, key { label = { { text = " G " } }, click = "g", label_symbol = { { text = { "}", "ic@content-paste" }, align = "justify" } }, swipe_up = "}", popup = { "Paste", "G", "g" }, swipe_down = "WindowClipboard" })),
        key(merge(S.b, key { label = { { text = "F C" } }, click = "f", label_symbol = { { text = { "|", "ic@content-cut" }, align = "justify" } }, swipe_up = "|", popup = { "Cut", "F", "C", "f", "c" } })),
        key(merge(S.n, key { label = { { text = " T " } }, click = "t", label_symbol = { { text = { "~", "ic@ideogram-cjk" }, align = "justify" } }, swipe_up = "~", popup = { "ZiTools", "T", "t" } })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size }))
      }
    },
    action_rows.action,
    action_rows.extra
  }
}

return keyboard
