local keyboard = keyboard(merge(safe_require("nekocat.layouts.35keys"), keyboard {
  name = "自然万象·14键",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [2] = key { hint = { { text = "iu ia ua", color = "blue" } } },
        [3] = key { hint = { { text = "e uan", color = "blue" } } },
        [4] = key { hint = { { text = "ue üe ing uai", color = "blue" } } },
        [5] = key { hint = { { text = "u i", color = "blue" } } },
        [6] = key { hint = { { text = "o uo un", color = "blue" } } }
      }
    },
    [3] = row {
      keys = {
        [2] = key { hint = { { text = "a ong iong", color = "blue" } } },
        [3] = key { hint = { { text = "iang uang en", color = "blue" } } },
        [4] = key { hint = { { text = "eng ang", color = "blue" } } },
        [5] = key { hint = { { text = "an ao", color = "blue" } } },
        [6] = key { hint = { { text = "ai", color = "blue" } } }
      }
    },
    [4] = row {
      keys = {
        [2] = key { hint = { { text = "ei ie", color = "blue" } } },
        [3] = key { hint = { { text = "iao ui ü", color = "blue" } } },
        [4] = key { hint = { { text = "ou in", color = "blue" } } },
        [5] = key { hint = { { text = "ian", color = "blue" } } }
      }
    }
  }
}))

return keyboard
