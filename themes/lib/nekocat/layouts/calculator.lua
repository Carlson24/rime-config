---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")

local keyboard = keyboard {
  name = "计算器",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  key_symbol_offset_y = -4,
  key_text_offset_y = 1,
  rows = {
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { label = { { text = "avg" } }, click = "Avg", label_symbol = { { text = "var" } }, long_click = "Var" },
        key { label = { { text = "asum" } }, click = "Arithsum", label_symbol = { { text = "gsum" } }, long_click = "Geosum" },
        key { label = { { text = "sin" } }, click = "Sin", label_symbol = { { text = "asin" } }, long_click = "Asin" },
        key { label = { { text = "cos" } }, click = "Cos", label_symbol = { { text = "acos" } }, long_click = "Acos" },
        key { label = { { text = "tan" } }, click = "Tan", label_symbol = { { text = "atan" } }, popup = { "Atan", "Atan2" } },
        key(merge(S.backspace, { click = "BackSpace", key_text_size = 20 })),
        key { spacer = true, width = 0.02 }
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { label = { { text = "log" } }, click = "Log", label_symbol = { { text = "ldexp" } }, long_click = "Ldexp" },
        key { label = { { text = "ln" } }, click = "Loge", label_symbol = { { text = "exp" } }, long_click = "Exp" },
        key { label = { { text = "sqrt" } }, click = "Sqrt", label_symbol = { { text = "nroot" } }, long_click = "Nroot" },
        key { label = { { text = "base" } }, click = "Base", label_symbol = { { text = "unit" } }, long_click = "Unit" },
        key { click = "^", label_symbol = { { text = "fact" } }, long_click = "Fact", key_text_offset_y = 7 },
        key { click = "/", label_symbol = { { text = "mod" } }, long_click = "Mod" },
        key { spacer = true, width = 0.02 }
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { click = "(", label_symbol = { { text = "ceil" } }, long_click = "Ceil" },
        key { click = ")", label_symbol = { { text = "floor" } }, long_click = "Floor" },
        key { click = "7" },
        key { click = "8" },
        key { click = "9" },
        key { click = "*", long_click = "×" },
        key { spacer = true, width = 0.02 }
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { click = "Left", label_symbol = { { text = "deg" } }, long_click = "Deg" },
        key { click = "Right", label_symbol = { { text = "rad" } }, long_click = "Rad" },
        key { click = "4" },
        key(merge(S.kp5, key { click = "5" })),
        key { click = "6" },
        key { click = "-" },
        key { spacer = true, width = 0.02 }
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { click = "=", label_symbol = { { text = "rand" } }, long_click = "Rand" },
        key { ascii_label = { { text = "π" } }, label = { { text = "π" } }, click = "pi", long_click = "e" },
        key { click = "1" },
        key { click = "2" },
        key { click = "3" },
        key { click = "+" },
        key { spacer = true, width = 0.02 }
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key(merge(S.num, { ascii_label = { { text = "返回" } }, label = { { text = "返回" } }, click = "KeyboardDefault" })),
        key(merge(S.func, { ascii_label = { { text = "算式" } }, label = { { text = "算式" } }, click = "Formula" })),
        key { click = "," },
        key { click = "0" },
        key { click = "." },
        key(merge(S.enter, { click = "Enter", key_text_size = 20 })),
        key { spacer = true, width = 0.02 }
      }
    }
  }
}

return keyboard
