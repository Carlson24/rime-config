local keyboard = keyboard(merge(safe_require("nekocat.layouts.38keys3x5b3"), keyboard {
  name = "万象·李氏三拼3x5b3",
  rows = {
    [1] = row {
      keys = {
        [1] = key { composing = "SelectCandOne" },
        [2] = key { composing = "SelectCandTwo" },
        [3] = key { composing = "SelectCandThree" },
        [4] = key { composing = "SelectCandFour" },
        [5] = key { composing = "SelectCandFive" }
      }
    },
    [2] = {
      keys = {
        [2] = key { hint = { { text = "er üan", color = "blue" } } },
        [3] = key { hint = { { text = "a an ang", color = "blue" } } },
        [4] = key { hint = { { text = "ai ei ao", color = "blue" } } },
        [5] = key { hint = { { text = "o ou ong", color = "blue" } } },
        [6] = key { hint = { { text = "e en eng", color = "blue" } } }
      }
    },
    [3] = {
      keys = {
        [2] = key { hint = { { text = "ü", color = "blue" } } },
        [3] = key { hint = { { text = "ia ian iang", color = "blue" } } },
        [4] = key { hint = { { text = "i iai iao", color = "blue" } } },
        [5] = key { hint = { { text = "io iu iong", color = "blue" } } },
        [6] = key { hint = { { text = "ie in ing", color = "blue" } } }
      }
    },
    [4] = {
      keys = {
        [2] = key { hint = { { text = "üe ün", color = "blue" } } },
        [3] = key { hint = { { text = "ua uan uang", color = "blue" } } },
        [4] = key { hint = { { text = "uai ui", color = "blue" } } },
        [5] = key { hint = { { text = "uo u", color = "blue" } } },
        [6] = key { hint = { { text = "∅ un ueng", color = "blue" } } }
      }
    }
  }
}))

return keyboard