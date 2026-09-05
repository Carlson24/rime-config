-- SPDX-License-Identifier: GPL-3.0-or-later
-- 共享数字行 (0-9)，5 个基础键盘布局共用
-- 共享选字/声调行，7 个 hint 布局共用

---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local symoffset = safe_require("nekocat.font_offset").num_key_symbol_offset_y
local textoffset = safe_require("nekocat.font_offset").num_key_text_offset_y

local NUMS = {
  { "1", "!", "①" }, { "2", "@", "②" }, { "3", "#", "③" }, { "4", "$", "④" }, { "5", "%", "⑤" },
  { "6", "^", "⑥" }, { "7", "&", "⑦" }, { "8", "*", "⑧" }, { "9", "(", "⑨" }, { "0", ")", "⓪" }
}

local function num_key(digit, symbol, down)
  return key(merge(S["num" .. digit], key {
    click = digit,
    label_symbol = { { text = { "ic@numeric-" .. digit .. "-circle-outline", symbol }, align = { "left", "right" } } },
    long_click = symbol,
    swipe_up = symbol,
    swipe_down = down,
    key_text_offset_y = textoffset,
    key_symbol_offset_y = symoffset
  }))
end

return {
  number_row = function()
    local keys = {}
    for i, n in ipairs(NUMS) do
      keys[i] = num_key(n[1], n[2], n[3])
    end
    return row {
      height = 0.13,
      keys = keys
    }
  end,

  composing_row = row {
    keys = {
      [1] = key { composing = "SelectCandOne" },
      [2] = key { composing = "SelectCandTwo" },
      [3] = key { composing = "SelectCandThree" },
      [4] = key { composing = "SelectCandFour" },
      [5] = key { composing = "SelectCandFive" },
      [6] = key { composing = "SelectToneOne" },
      [7] = key { composing = "SelectToneTwo" },
      [8] = key { composing = "SelectToneThree" },
      [9] = key { composing = "SelectToneFour" },
      [10] = key { composing = "SelectToneNull" }
    }
  }
}
