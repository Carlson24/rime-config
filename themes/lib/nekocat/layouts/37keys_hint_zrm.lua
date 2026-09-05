local keyboard = keyboard(merge(safe_require("nekocat.layouts.37keys"), keyboard {
  name = "自然万象·18键",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [1] = key { hint = { { text = "iu", color = "blue" } } },
        [2] = key { hint = { { text = "ia ua e", color = "blue" } } },
        [3] = key { hint = { { text = "uan ue üe", color = "blue" } } },
        [4] = key { hint = { { text = "ing uai", color = "blue" } } },
        [5] = key { hint = { { text = "u", color = "blue" } } },
        [6] = key { hint = { { text = "i o io", color = "blue" } } },
        [7] = key { hint = { { text = "un", color = "blue" } } }
      }
    },
    [3] = row {
      keys = {
        [2] = key { hint = { { text = "a", color = "blue" } } },
        [3] = key { hint = { { text = "(i)ong i|uang", color = "blue" } } },
        [4] = key { hint = { { text = "en eng", color = "blue" } } },
        [5] = key { hint = { { text = "ang", color = "blue" } } },
        [6] = key { hint = { { text = "an ao", color = "blue" } } },
        [7] = key { hint = { { text = "ai", color = "blue" } } }
      }
    },
    [4] = row {
      keys = {
        [2] = key { hint = { { text = "ei", color = "blue" } } },
        [3] = key { hint = { { text = "ie iao", color = "blue" } } },
        [4] = key { hint = { { text = "ui ü", color = "blue" } } },
        [5] = key { hint = { { text = "ou in", color = "blue" } } },
        [6] = key { hint = { { text = "ian", color = "blue" } } }
      }
    }
  }
}))

return keyboard
