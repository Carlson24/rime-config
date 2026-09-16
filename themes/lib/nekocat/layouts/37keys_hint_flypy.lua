local keyboard = keyboard(merge(safe_require("nekocat.layouts.37keys"), keyboard {
  name = "万象小鹤·18键",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [1] = key { hint = { { text = "iu", color = "blue" } } },        -- Q
        [2] = key { hint = { { text = "ei e", color = "blue" } } },      -- WE
        [3] = key { hint = { { text = "uan ue üe", color = "blue" } } }, -- RT
        [4] = key { hint = { { text = "un", color = "blue" } } },        -- Y
        [5] = key { hint = { { text = "u", color = "blue" } } },         -- U
        [6] = key { hint = { { text = "i o uo", color = "blue" } } },    -- IO
        [7] = key { hint = { { text = "ie", color = "blue" } } }         -- P
      }
    },
    [3] = row {
      keys = {
        [2] = key { hint = { { text = "a", color = "blue" } } },          -- A
        [3] = key { hint = { { text = "(i)ong ai", color = "blue" } } },  -- SD
        [4] = key { hint = { { text = "en eng", color = "blue" } } },     -- FG
        [5] = key { hint = { { text = "ang", color = "blue" } } },        -- H
        [6] = key { hint = { { text = "an uai ing", color = "blue" } } }, -- JK
        [7] = key { hint = { { text = "iang uang", color = "blue" } } }   -- L
      }
    },
    [4] = row {
      keys = {
        [2] = key { hint = { { text = "ou", color = "blue" } } },       -- Z
        [3] = key { hint = { { text = "ia ua ao", color = "blue" } } }, -- XC
        [4] = key { hint = { { text = "ui ü", color = "blue" } } },     -- V
        [5] = key { hint = { { text = "in iao", color = "blue" } } },   -- BN
        [6] = key { hint = { { text = "ian", color = "blue" } } }       -- M
      }
    }
  }
}))

return keyboard
