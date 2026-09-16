local keyboard = keyboard(merge(safe_require("nekocat.layouts.36keys"), keyboard {
  name = "万象·乱序 17",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [2] = key { hint = { { text = "a ia ua", color = "blue" } } },
        [3] = key { hint = { { text = "en in", color = "blue" } } },
        [4] = key { hint = { { text = "ang iao", color = "blue" } } },
        [5] = key { hint = { { text = "ao iong", color = "blue" } } },
        [6] = key { hint = { { text = "uai uan", color = "blue" } } },
        [7] = key { hint = { { text = "ie uo", color = "blue" } } }
      }
    },
    [3] = row {
      keys = {
        [2] = key { hint = { { text = "ai ue", color = "blue" } } },
        [3] = key { hint = { { text = "u", color = "blue" } } },
        [4] = key { hint = { { text = "eng ing", color = "blue" } } },
        [5] = key { hint = { { text = "e", color = "blue" } } },
        [6] = key { hint = { { text = "i", color = "blue" } } },
        [7] = key { hint = { { text = "an", color = "blue" } } }
      }
    },
    [4] = row {
      keys = {
        [2] = key { hint = { { text = "iang ui", color = "blue" } } },
        [3] = key { hint = { { text = "ian uang", color = "blue" } } },
        [4] = key { hint = { { text = "ei un", color = "blue" } } },
        [5] = key { hint = { { text = "iu ou", color = "blue" } } },
        [6] = key { hint = { { text = "er ong", color = "blue" } } }
      }
    }
  }
}))

return keyboard
