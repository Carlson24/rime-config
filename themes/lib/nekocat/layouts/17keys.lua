---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size

local keyboard = keyboard {
  name = "T9 布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  sidebar_mode = true,
  sidebar_layout = "t9",
  sidebar_width = 0.15,
  sidebar_position = "left",
  sidebar_span_rows = 3,
  sidebar_show_items = 4,
  sidebar_symbols = { "，", "。", "？", "！", "、", "：", "；" },
  rows = {
    row {
      keys = {
        key { spacer = true, width = 0.15 },
        key(merge(S.kp1, { label = { { text = "分词" } }, click = "1", label_symbol = { { text = "`" } }, swipe_up = "`", hint = { { text = "1" } } })),
        key(merge(S.kp2, { label = { { text = "ABC" } }, click = "2", label_symbol = { { text = "#" } }, swipe_up = "#", popup = { "a", "b", "c", "A", "B", "C" }, hint = { { text = "2" } } })),
        key(merge(S.kp3, { label = { { text = "DEF" } }, click = "3", label_symbol = { { text = "@" } }, swipe_up = "@", popup = { "d", "e", "f", "D", "E", "F" }, hint = { { text = "3" } } })),
        key(merge(S.backspace, key { click = "BackSpace", key_text_size = func_key_text_size, width = 0.15 }))
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.15 },
        key(merge(S.kp4, { label = { { text = "GHI" } }, click = "4", label_symbol = { { text = "$" } }, swipe_up = "$", popup = { "g", "h", "i", "G", "H", "I" }, hint = { { text = "4" } } })),
        key(merge(S.kp5, key { label = { { text = "JKL" } }, click = "5", label_symbol = { { text = "%" } }, swipe_up = "%", popup = { "j", "k", "l", "J", "K", "L" }, hint = { { text = "5" } } })),
        key(merge(S.kp6, { label = { { text = "MNO" } }, click = "6", label_symbol = { { text = "&" } }, swipe_up = "&", popup = { "m", "n", "o", "M", "N", "O" }, hint = { { text = "6" } } })),
        key(merge(S.clear, key { click = "SidebarClear", key_text_size = func_key_text_size, width = 0.15 }))
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.15 },
        key(merge(S.kp7, { label = { { text = "PQRS" } }, click = "7", label_symbol = { { text = "+" } }, swipe_up = "+", popup = { "p", "q", "r", "s", "P", "Q", "R", "S" }, hint = { { text = "7" } } })),
        key(merge(S.kp8, { label = { { text = "TUV" } }, click = "8", label_symbol = { { text = "-" } }, swipe_up = "-", popup = { "t", "u", "v", "T", "U", "V" }, hint = { { text = "8" } } })),
        key(merge(S.kp9, { label = { { text = "WXYZ" } }, click = "9", label_symbol = { { text = "=" } }, swipe_up = "=", popup = { "w", "x", "y", "z", "W", "X", "Y", "Z" }, hint = { { text = "9" } } })),
        key(merge(S.func, key { click = "ZiTools", key_text_size = func_key_text_size, width = 0.15 }))
      }
    },
    row {
      keys = {
        key(merge(S.num, key { click = "KeyboardT9Number", label_symbol = { { text = "ic@calculator-variant" } }, popup = { "Calculator", "ThemeReload", "Deploy" }, has_menu = "Tab", key_text_size = func_key_text_size, width = 0.15 })),
        key(merge(S.slash, key { click = "/", label_symbol = { { text = "[" } }, swipe_up = "[", hint = { { text = "ic@list-box-outline" } }, swipe_down = "SchemeList", key_text_size = func_key_text_size, width = 0.13 })),
        key(merge(S.space, { label = { { text = "schema_name" } }, click = "Space", long_click = "VoiceAssist", hint = { { text = "◕ ‿ ◕" } }, swipe_down = "LiquidEmoji", key_text_size = 15, key_text_offset_y = 1 })),
        key(merge(S.switch, key { click = "Keyboard45Eng", label_symbol = { { text = "]" } }, swipe_up = "]", long_click = "KeyboardList", hint = { { text = "ic@web" } }, swipe_down = "IMESwitch", key_text_size = func_key_text_size, width = 0.13 })),
        key(merge(S.enter, key { label = { { text = "enter_labels" } }, click = "Enter", long_click = "ColorList", key_text_size = func_key_text_size, width = 0.15 }))
      }
    },
    safe_require("nekocat.layouts._action_row")({}).extra
  }
}

return keyboard
