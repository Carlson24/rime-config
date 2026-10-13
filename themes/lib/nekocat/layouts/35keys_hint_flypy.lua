local keyboard = keyboard(merge(safe_require("nekocat.layouts.35keys"), keyboard {
  name = "万象小鹤·14键",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [2] = key { hint = { { text = "iu ei", color = "blue" } } },
        [3] = key { hint = { { text = "e uan", color = "blue" } } },
        [4] = key { hint = { { text = "ue üe un", color = "blue" } } },
        [5] = key { hint = { { text = "u i", color = "blue" } } },
        [6] = key { hint = { { text = "o uo ie", color = "blue" } } }
      }
    },
    [3] = row {
      keys = {
        [2] = key { hint = { { text = "a ong iong", color = "blue" } } },
        [3] = key { hint = { { text = "ai en", color = "blue" } } },
        [4] = key { hint = { { text = "eng ang", color = "blue" } } },
        [5] = key { hint = { { text = "an uai ing", color = "blue" } } },
        [6] = key { hint = { { text = "iang uang", color = "blue" } } }
      }
    },
    [4] = row {
      keys = {
        [2] = key { hint = { { text = "ou ia ua", color = "blue" } } },
        [3] = key { hint = { { text = "ao ui ü", color = "blue" } } },
        [4] = key { hint = { { text = "in iao", color = "blue" } } },
        [5] = key { hint = { { text = "ian", color = "blue" } } }
      }
    }
  }
}))

return keyboard
