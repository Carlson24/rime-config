---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size

local keyboard = keyboard {
  name = "数字布局",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    row {
      keys = {
        key(merge(S.func, { click = "+", long_click = "%" })),
        key(merge(S.kp1, { click = "7" })),
        key(merge(S.kp2, { click = "8" })),
        key(merge(S.kp3, { click = "9" })),
        key(merge(S.func, { click = "*", long_click = "×" }))
      }
    },
    row {
      keys = {
        key(merge(S.func, { click = "-", long_click = "Colon" })),
        key(merge(S.kp4, { click = "4" })),
        key(merge(S.kp5, key { click = "5" })),
        key(merge(S.kp6, { click = "6" })),
        key(merge(S.func, { click = "Slash", long_click = "÷" }))
      }
    },
    row {
      keys = {
        key(merge(S.func, { click = "Paren", long_click = "Bracket" })),
        key(merge(S.kp7, { click = "1" })),
        key(merge(S.kp8, { click = "2" })),
        key(merge(S.kp9, { click = "3" })),
        key(merge(S.backspace, { click = "BackSpace", key_text_size = func_key_text_size }))
      }
    },
    row {
      keys = {
        key(merge(S.num, { ascii_label = { { text = "返回" } }, label = { { text = "返回" } }, click = "KeyboardDefault" })),
        key(merge(S.func, { click = "Space", label_symbol = { { text = "日期" } }, long_click = "N", key_text_size = func_key_text_size })),
        key(merge(S.kp0, { click = "0", long_click = "X" })),
        key(merge(S.func, { click = ".", label_symbol = { { text = "金额" } }, long_click = "S" })),
        key(merge(S.enter, { click = "Enter", key_text_size = func_key_text_size }))
      }
    },
    safe_require("nekocat.layouts._action_row")({}).extra
  }
}

return keyboard
