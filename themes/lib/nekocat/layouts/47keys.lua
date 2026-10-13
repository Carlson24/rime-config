---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size
local action_rows = safe_require("nekocat.layouts._action_row")({ mode_switch = true })

local keyboard = keyboard {
  name = "47 键布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    safe_require("nekocat.layouts._number_row").number_row(),
    row {
      keys = {
        key(merge(S.q, key { click = "q", label_symbol = { { text = { " ", "`" }, align = "justify", scale = 1.5 } }, swipe_up = "`", popup = { "Q" } })),
        key(merge(S.w, key { click = "w", label_symbol = { { text = { " ", "~" }, align = "justify" } }, swipe_up = "~", popup = { "W" } })),
        key(merge(S.e, key { click = "e", label_symbol = { { text = { " ", "+" }, align = "justify" } }, swipe_up = "+", popup = { "E" } })),
        key(merge(S.r, key { click = "r", label_symbol = { { text = { " ", "-" }, align = "justify" } }, swipe_up = "-", popup = { "R" } })),
        key(merge(S.t, key { click = "t", label_symbol = { { text = { " ", "\"" }, align = "justify" } }, swipe_up = "\"", popup = { "T" } })),
        key(merge(S.y, key { click = "y", label_symbol = { { text = { " ", "<" }, align = "justify" } }, swipe_up = "<", popup = { "Y" } })),
        key(merge(S.u, key { click = "u", label_symbol = { { text = { " ", "=" }, align = "justify" } }, swipe_up = "=", popup = { "U" } })),
        key(merge(S.i, key { click = "i", label_symbol = { { text = { " ", ">" }, align = "justify" } }, swipe_up = ">", popup = { "I" } })),
        key(merge(S.o, key { click = "o", label_symbol = { { text = { " ", "_" }, align = "justify" } }, swipe_up = "_", popup = { "O" } })),
        key(merge(S.p, key { click = "p", label_symbol = { { text = { " ", "\\" }, align = "justify" } }, swipe_up = "\\", popup = { "P" } }))
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.05 },
        key(merge(S.a, key { click = "a", label_symbol = { { text = { " ", "?" }, align = "justify" } }, swipe_up = "?", popup = { "A", "?", "¿" } })),
        key(merge(S.s, key { click = "s", label_symbol = { { text = { " ", "×" }, align = "justify" } }, swipe_up = "×", popup = { "S" } })),
        key(merge(S.d, key { click = "d", label_symbol = { { text = { " ", "÷" }, align = "justify" } }, swipe_up = "÷", popup = { "D" } })),
        key(merge(S.f, key { click = "f", label_symbol = { { text = { " ", "{" }, align = "justify" } }, swipe_up = "{", popup = { "F" } })),
        key(merge(S.g, key { click = "g", label_symbol = { { text = { " ", "ic@apps" }, align = "justify" } }, popup = { "G", "WindowMenu" }, swipe_down = "KeyboardEditor" })),
        key(merge(S.h, key { click = "h", label_symbol = { { text = { " ", "}" }, align = "justify" } }, swipe_up = "}", popup = { "H" } })),
        key(merge(S.j, key { click = "j", label_symbol = { { text = { " ", "|" }, align = "justify" } }, swipe_up = "|", popup = { "J" } })),
        key(merge(S.k, key { click = "k", label_symbol = { { text = { " ", ":" }, align = "justify" } }, swipe_up = ":", popup = { "K", "·", "§" } })),
        key(merge(S.l, key { click = "l", label_symbol = { { text = { " ", ";" }, align = "justify" } }, swipe_up = ";", popup = { "L" } })),
        key { spacer = true, width = 0.05 }
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@keyboard-caps" } }, key_text_size = func_key_text_size, width = 0.15 })),
        key(merge(S.z, key { click = "z", label_symbol = { { text = { " ", "ic@select-all" }, align = "justify" } }, popup = { "SelectAll", "Z" } })),
        key(merge(S.x, key { click = "x", label_symbol = { { text = { " ", "ic@content-cut" }, align = "justify" } }, popup = { "Cut", "X" } })),
        key(merge(S.c, key { click = "c", label_symbol = { { text = { " ", "ic@content-copy" }, align = "justify" } }, popup = { "Copy", "C" } })),
        key(merge(S.v, key { click = "v", label_symbol = { { text = { " ", "ic@content-paste" }, align = "justify" } }, popup = { "Paste", "V" }, swipe_down = "WindowClipboard" })),
        key(merge(S.b, key { click = "b", label_symbol = { { text = { " ", "ic@ideogram-cjk" }, align = "justify" } }, popup = { "ZiTools", "B" } })),
        key(merge(S.n, key { click = "n", label_symbol = { { text = { " ", "ic@page-first" }, align = "justify" } }, popup = { "Page_Up", "N" } })),
        key(merge(S.m, key { click = "m", label_symbol = { { text = { " ", "ic@page-last" }, align = "justify" } }, popup = { "Page_Down", "M" } })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size, width = 0.15 }))
      }
    },
    action_rows.action,
    action_rows.extra
  }
}

return keyboard
