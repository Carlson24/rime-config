return keyboard {
  name            = "基础26键",
  author          = "Carlson24(鹤衔春雪)",
  ascii_mode      = false,
  label_transform = "UPPERCASE",
  rows            = {
    row {
      keys = {
        key { click = "q", long_click = "1" },
        key { click = "w", long_click = "2" },
        key { click = "e", long_click = "3" },
        key { click = "r", long_click = "4" },
        key { click = "t", long_click = "5" },
        key { click = "y", long_click = "6" },
        key { click = "u", long_click = "7" },
        key { click = "i", long_click = "8" },
        key { click = "o", long_click = "9" },
        key { click = "p", long_click = "0" }
      }
    },
    row {
      keys = {
        key { click = "", spacer = true, width = 0.05 },
        key { click = "a", long_click = "~" },
        key { click = "s", long_click = "!" },
        key { click = "d", long_click = "@" },
        key { click = "f", long_click = "#" },
        key { click = "g", long_click = "%" },
        key { click = "h", long_click = "\"" },
        key { click = "j", long_click = "'" },
        key { click = "k", long_click = "*" },
        key { click = "l", long_click = "?" },
        key { click = "", spacer = true, width = 0.05 }
      },
    },
    row {
      keys = {
        key { click = "Shift", width = 0.15 },
        key { click = "z", long_click = "1" },
        key { click = "x", long_click = "2" },
        key { click = "c", long_click = "3" },
        key { click = "v", long_click = "4" },
        key { click = "b", long_click = "5" },
        key { click = "n", long_click = "6" },
        key { click = "m", long_click = "7" },
        key { click = "BackSpace", width = 0.15 }
      }
    }
  }
}
