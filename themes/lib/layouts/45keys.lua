local S = safe_require("key_style") -- 按键样式

return keyboard(merge(S.offset, keyboard {
  name = "45 键布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    row {
      height = 0.13,
      keys = {
        key(merge(S.number, key { click = "1", label_symbol = { { text = "!" } }, swipe_up = "!" })),
        key(merge(S.number, key { click = "2", label_symbol = { { text = "@" } }, swipe_up = "@" })),
        key(merge(S.number, key { click = "3", label_symbol = { { text = "#" } }, swipe_up = "#" })),
        key(merge(S.number, key { click = "4", label_symbol = { { text = "$" } }, swipe_up = "$" })),
        key(merge(S.number, key { click = "5", label_symbol = { { text = "%" } }, swipe_up = "%" })),
        key(merge(S.number, key { click = "6", label_symbol = { { text = "^" } }, swipe_up = "^" })),
        key(merge(S.number, key { click = "7", label_symbol = { { text = "&" } }, swipe_up = "&" })),
        key(merge(S.number, key { click = "8", label_symbol = { { text = "*" } }, swipe_up = "*" })),
        key(merge(S.number, key { click = "9", label_symbol = { { text = "(" } }, swipe_up = "(" })),
        key(merge(S.number, key { click = "0", label_symbol = { { text = ")" } }, swipe_up = ")" }))
      }
    },
    row {
      keys = {
        key(merge(S.qwert, key { click = "q", label_symbol = { { text = "`" } }, swipe_up = "`", popup = { "Q" } })),
        key(merge(S.qwert, key { click = "w", label_symbol = { { text = "~" } }, swipe_up = "`", popup = { "W" } })),
        key(merge(S.qwert, key { click = "e", label_symbol = { { text = "+" } }, swipe_up = "`", popup = { "E" } })),
        key(merge(S.qwert, key { click = "r", label_symbol = { { text = "-" } }, swipe_up = "`", popup = { "R" } })),
        key(merge(S.qwert, key { click = "t", label_symbol = { { text = "=" } }, swipe_up = "`", popup = { "T" } })),
        key(merge(S.qwert, key { click = "y", label_symbol = { { text = "_" } }, swipe_up = "`", popup = { "Y" } })),
        key(merge(S.qwert, key { click = "u", label_symbol = { { text = "{" } }, swipe_up = "`", popup = { "U" } })),
        key(merge(S.qwert, key { click = "i", label_symbol = { { text = "}" } }, swipe_up = "`", popup = { "I" } })),
        key(merge(S.qwert, key { click = "o", label_symbol = { { text = "ic@delete-forever" } }, popup = { "O", "CandDelete" } })),
        key(merge(S.qwert, key { click = "p", label_symbol = { { text = "ic@pin" } }, popup = { "P", "CandTop" } }))
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.05 },
        key(merge(S.asdfg, key { click = "a", label_symbol = { { text = "ic@select-all" } }, popup = { "A", "SelectAll" } })),
        key(merge(S.asdfg, key { click = "s", label_symbol = { { text = ":" } }, swipe_up = ":", popup = { "S" } })),
        key(merge(S.asdfg, key { click = "d", label_symbol = { { text = "|" } }, swipe_up = "|", popup = { "D" } })),
        key(merge(S.asdfg, key { click = "f", label_symbol = { { text = ";" } }, swipe_up = ";", popup = { "F", "·", "§" } })),
        key(merge(S.asdfg, key { click = "g", label_symbol = { { text = "ic@apps" } }, popup = { "G", "KeyboardMenu" } })),
        key(merge(S.asdfg, key { click = "h", label_symbol = { { text = "?" } }, swipe_up = "?", popup = { "H", "?", "¿" } })),
        key(merge(S.asdfg, key { click = "j", label_symbol = { { text = "ic@pan-left" } }, popup = { "J", "CandLeft" } })),
        key(merge(S.asdfg, key { click = "k", label_symbol = { { text = "ic@pan-right" } }, popup = { "K", "CandRight" } })),
        key(merge(S.asdfg, key { click = "l", label_symbol = { { text = "ic@lock-reset" } }, popup = { "L", "CandReset" } })),
        key { spacer = true, width = 0.05 }
      }
    },
    row {
      keys = {
        key(merge(S.shift, key { click = "Shift", double_click = "CapsLock", label_symbol = { { text = "ic@apple-keyboard-caps" } }, width = 0.15 })),
        key(merge(S.zxcvb, key { click = "z", label_symbol = { { text = "\\" } }, swipe_up = "\\", popup = { "Z" } })),
        key(merge(S.zxcvb, key { click = "x", label_symbol = { { text = "ic@content-cut" } }, popup = { "X", "Cut" } })),
        key(merge(S.zxcvb, key { click = "c", label_symbol = { { text = "ic@content-copy" } }, popup = { "C", "Copy" } })),
        key(merge(S.zxcvb, key { click = "v", label_symbol = { { text = "ic@content-paste" } }, popup = { "V", "Paste" } })),
        key(merge(S.zxcvb, key { click = "b", label_symbol = { { text = "/" } }, swipe_up = "/", popup = { "B", "ZiTools" } })),
        key(merge(S.zxcvb, key { click = "n", label_symbol = { { text = "<" } }, swipe_up = "<", popup = { "N" } })),
        key(merge(S.zxcvb, key { click = "m", label_symbol = { { text = ">" } }, swipe_up = ">", popup = { "M" } })),
        key(merge(S.backspace, key { click = "BackSpace", width = 0.15 }))
      }
    },
    row {
      keys = {
        key(merge(S.symbol, key { click = "KeyboardNumber", label_symbol = { { text = "ic@calculator-variant" } }, popup = { "Calculator", "ThemeReload", "Deploy" }, has_menu = "Tab", width = 0.15 })),
        key(merge(S.punct, key { click = "'", label_symbol = { { text = "\"" } }, swipe_up = "\"", hint = { { text = "ic@lightbulb-outline" } }, swipe_down = "HintSwitch" })),
        key(merge(S.punct, key { label = { { text = "，" } }, click = ",", label_symbol = { { text = "[" } }, swipe_up = "[", hint = { { text = "ic@web" } }, swipe_down = "IMESwitch" })),
        key { label = { { text = "天文馆的猫" } }, click = "Space", long_click = "VoiceAssist", hint = { { text = "◕ ‿ ◕" } }, swipe_down = "KeyboardClipboard", width = 0.3, key_text_offset_y = 1 },
        key(merge(S.punct, key { label = { { text = "。" } }, click = ".", label_symbol = { { text = "]" } }, swipe_up = "]", hint = { { text = "ic@list-box-outline" } }, swipe_down = "SchemeList" })),
        key(merge(S.switch, key { click = "ModeSwitch", label_symbol = { { text = "ic@keyboard-settings-outline" } }, hint = { { text = "ic@palette-swatch-outline" } }, swipe_down = "ThemeSwitch" })),
        key(merge(S.enter, key { label = { { text = "enter_labels" } }, click = "Enter", width = 0.15 }))
      }
    }
  }
}))
