---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size
local action_rows = safe_require("nekocat.layouts._action_row")({ mode_switch = true })

local keyboard = keyboard {
  name = "7 列布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    row {
      keys = {
        key(merge(S.q, key { click = "q", label_symbol = { { text = { " ", "`" }, align = "justify", scale = 1.5 } }, swipe_up = "`", popup = { "Q" } })),
        key(merge(S.w, key { click = "w", label_symbol = { { text = { " ", "~" }, align = "justify" } }, swipe_up = "~", hint = { { text = "1" } }, swipe_down = "1", popup = { "W" } })),
        key(merge(S.e, key { click = "e", label_symbol = { { text = { " ", "\"" }, align = "justify" } }, swipe_up = "\"", hint = { { text = "2" } }, swipe_down = "2", popup = { "E" } })),
        key(merge(S.t, key { click = "t", label_symbol = { { text = { " ", "^" }, align = "justify" } }, swipe_up = "^", hint = { { text = "3" } }, swipe_down = "3", popup = { "T" } })),
        key(merge(S.i, key { click = "i", label_symbol = { { text = { " ", "_" }, align = "justify" } }, swipe_up = "_", hint = { { text = "4" } }, swipe_down = "4", popup = { "I" } })),
        key(merge(S.o, key { click = "o", label_symbol = { { text = { " ", "&" }, align = "justify" } }, swipe_up = "&", hint = { { text = "5" } }, swipe_down = "5", popup = { "O" } })),
        key(merge(S.p, key { click = "p", label_symbol = { { text = { " ", "\\" }, align = "justify" } }, swipe_up = "\\", popup = { "P" } }))
      }
    },
    row {
      keys = {
        key(merge(S.a, key { click = "a", label_symbol = { { text = { " ", ":" }, align = "justify" } }, swipe_up = ":", popup = { "A", "·", "§" } })),
        key(merge(S.s, key { click = "s", label_symbol = { { text = { " ", "+" }, align = "justify" } }, swipe_up = "+", hint = { { text = "6" } }, swipe_down = "6", popup = { "S" } })),
        key(merge(S.r, key { click = "r", label_symbol = { { text = { " ", "-" }, align = "justify" } }, swipe_up = "-", hint = { { text = "7" } }, swipe_down = "7", popup = { "R" } })),
        key(merge(S.y, key { click = "y", label_symbol = { { text = { " ", "#" }, align = "justify" } }, swipe_up = "#", hint = { { text = "8" } }, swipe_down = "8", popup = { "Y" } })),
        key(merge(S.u, key { click = "u", label_symbol = { { text = { " ", "(" }, align = "justify" } }, swipe_up = "(", hint = { { text = "9" } }, swipe_down = "9", popup = { "U" } })),
        key(merge(S.k, key { click = "k", label_symbol = { { text = { " ", ")" }, align = "justify" } }, swipe_up = ")", hint = { { text = "0" } }, swipe_down = "0", popup = { "K" } })),
        key(merge(S.l, key { click = "l", label_symbol = { { text = { " ", ";" }, align = "justify" } }, swipe_up = ";", popup = { "L" } }))
      }
    },
    row {
      keys = {
        key(merge(S.z, key { click = "z", label_symbol = { { text = { " ", "ic@page-first", "!" }, align = "justify" } }, swipe_up = "!", popup = { "Z", "Page_Up" } })),
        key(merge(S.d, key { click = "d", label_symbol = { { text = { " ", "*" }, align = "justify" } }, swipe_up = "*", popup = { "D", "×" } })),
        key(merge(S.f, key { click = "f", label_symbol = { { text = { " ", "=" }, align = "justify" } }, swipe_up = "=", popup = { "F", "÷" } })),
        key(merge(S.g, key { click = "g", label_symbol = { { text = { " ", "ic@apps", "%" }, align = "justify" } }, swipe_up = "%", swipe_down = "KeyboardEditor", popup = { "G", "WindowMenu" } })),
        key(merge(S.h, key { click = "h", label_symbol = { { text = { " ", "<" }, align = "justify" } }, swipe_up = "<", popup = { "H" } })),
        key(merge(S.j, key { click = "j", label_symbol = { { text = { " ", ">" }, align = "justify" } }, swipe_up = ">", popup = { "J" } })),
        key(merge(S.m, key { click = "m", label_symbol = { { text = { " ", "ic@page-last", "?" }, align = "justify" } }, swipe_up = "?", popup = { "M", "¿", "Page_Down" } }))
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@keyboard-caps" } }, key_text_size = func_key_text_size })),
        key(merge(S.x, key { click = "x", label_symbol = { { text = { " ", "ic@select-all", "@" }, align = "justify" } }, swipe_up = "@", popup = { "SelectAll", "X" } })),
        key(merge(S.c, key { click = "c", label_symbol = { { text = { " ", "ic@content-cut", "|" }, align = "justify" } }, swipe_up = "|", popup = { "Cut", "C" } })),
        key(merge(S.v, key { click = "v", label_symbol = { { text = { " ", "ic@content-copy", "$" }, align = "justify" } }, swipe_up = "$", swipe_down = "WindowClipboard", popup = { "Copy", "V" } })),
        key(merge(S.b, key { click = "b", label_symbol = { { text = { " ", "ic@content-paste", "{" }, align = "justify" } }, swipe_up = "{", popup = { "Paste", "B" } })),
        key(merge(S.n, key { click = "n", label_symbol = { { text = { " ", "ic@ideogram-cjk", "}" }, align = "justify" } }, swipe_up = "}", popup = { "ZiTools", "N" } })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size }))
      }
    },
    action_rows.action,
    action_rows.extra
  }
}

return keyboard
