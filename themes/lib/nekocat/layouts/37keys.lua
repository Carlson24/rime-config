local S = safe_require("nekocat.colors._key_colors") -- 按键样式
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size
local action_rows = safe_require("nekocat.layouts._action_row")({})

local keyboard = keyboard {
  name = "18 键布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    safe_require("nekocat.layouts._number_row").number_row(),
    row {
      keys = {
        key(merge(S.w, key { label = { { text = " Q " } }, click = "q", label_symbol = { { text = "`" } }, swipe_up = "`", popup = { "Q", "q" } })),
        key(merge(S.e, key { label = { { text = "W E" } }, click = "w", label_symbol = { { text = "\"" } }, swipe_up = "\"", popup = { "W", "E", "w", "e" } })),
        key(merge(S.r, key { label = { { text = "R T" } }, click = "r", label_symbol = { { text = "+" } }, swipe_up = "+", popup = { "R", "T", "r", "t" } })),
        key(merge(S.t, key { label = { { text = " Y " } }, click = "y", label_symbol = { { text = "-" } }, swipe_up = "-", popup = { "Y", "y" }, swipe_down = "KeyboardEditor" })),
        key(merge(S.y, key { label = { { text = " U " } }, click = "u", label_symbol = { { text = ":" } }, swipe_up = ":", popup = { "U", "u" } })),
        key(merge(S.u, key { label = { { text = "I O" } }, click = "i", label_symbol = { { text = "?" } }, swipe_up = "?", popup = { "I", "O", "i", "o", "?", "¿" } })),
        key(merge(S.p, key { label = { { text = " P " } }, click = "p", label_symbol = { { text = "\\" } }, swipe_up = "\\", popup = { "P", "p" } }))
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.05 },
        key(merge(S.s, key { label = { { text = " A " } }, click = "a", label_symbol = { { text = "×" } }, swipe_up = "×", popup = { "A", "a" } })),
        key(merge(S.d, key { label = { { text = "S D" } }, click = "s", label_symbol = { { text = "÷" } }, swipe_up = "÷", popup = { "S", "D", "s", "d" } })),
        key(merge(S.f, key { label = { { text = "F G" } }, click = "f", label_symbol = { { text = "<" } }, swipe_up = "<", popup = { "F", "G", "f", "g" } })),
        key(merge(S.h, key { label = { { text = " H " } }, click = "h", label_symbol = { { text = "=" } }, swipe_up = "=", popup = { "H", "h" } })),
        key(merge(S.j, key { label = { { text = "J K" } }, click = "j", label_symbol = { { text = ">" } }, swipe_up = ">", popup = { "J", "K", "j", "k" } })),
        key(merge(S.k, key { label = { { text = " L " } }, click = "l", label_symbol = { { text = "'" } }, swipe_up = "'", popup = { "L", "l", "·", "§" } })),
        key { spacer = true, width = 0.05 }
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@keyboard-caps" } }, key_text_size = func_key_text_size, width = 0.15 })),
        key(merge(S.x, key { label = { { text = " Z " } }, click = "z", label_symbol = { { text = { "{", "ic@select-all" }, align = "justify" } }, swipe_up = "{", popup = { "SelectAll", "Z", "z" } })),
        key(merge(S.c, key { label = { { text = "X C" } }, click = "x", label_symbol = { { text = { "_", "ic@content-copy" }, align = "justify" } }, swipe_up = "_", popup = { "Copy", "X", "C", "x", "c" } })),
        key(merge(S.v, key { label = { { text = " V " } }, click = "v", label_symbol = { { text = { "}", "ic@content-paste" }, align = "justify" } }, swipe_up = "}", popup = { "Paste", "V", "v" }, swipe_down = "WindowClipboard" })),
        key(merge(S.b, key { label = { { text = "B N" } }, click = "b", label_symbol = { { text = { "|", "ic@content-cut" }, align = "justify" } }, swipe_up = "|", popup = { "Cut", "B", "N", "b", "n" } })),
        key(merge(S.n, key { label = { { text = " M " } }, click = "m", label_symbol = { { text = { "~", "ic@ideogram-cjk" }, align = "justify" } }, swipe_up = "~", popup = { "ZiTools", "M", "m" } })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size, width = 0.15 }))
      }
    },
    action_rows.action,
    action_rows.extra
  }
}

return keyboard
