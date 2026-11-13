-- SPDX-License-Identifier: GPL-3.0-or-later
-- 共享底部操作行，5 个基础键盘布局共用

---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")
local func_key_text_size = safe_require("nekocat.font_offset").func_key_text_size

---@param opts { mode_switch: boolean? }
---@return { action: KeyboardRow }
return function(opts)
  local action = row {
    keys = {
      key(merge(S.num, key {
        click = "KeyboardNumber",
        label_symbol = { { text = "ic@calculator-variant" } },
        popup = { "Calculator", "LiquidHistory", "LiquidEmoji", "ThemeReload", "Deploy" },
        has_menu = "Tab",
        width = 0.15,
        key_text_size = func_key_text_size
      })),
      key(merge(S.switch, key {
        click = "/",
        label_symbol = { { text = "'", scale = 1.5 } },
        long_click = "/",
        swipe_up = "'",
        hint = { { text = "ic@lightbulb-outline" } },
        swipe_down = "HintSwitch",
        has_menu = "Semicolon",
        width = 0.11
      })),
      key(merge(S.comma, key {
        label = { { text = "，" } },
        click = ",",
        long_click = "[",
        swipe_up = "[",
        hint = { { text = "ic@palette-swatch-outline" } },
        swipe_down = "ThemeList",
        width = 0.1,
        key_text_size = func_key_text_size,
        key_text_offset_y = -2
      })),
      key(merge(S.space, key {
        label = { { text = "schema_name" } },
        click = "Space",
        long_click = "VoiceAssist",
        hint = { { text = "◕ ‿ ◕" } },
        swipe_down = "LiquidEmoji",
        key_text_size = 15,
        key_text_offset_y = 1
      })),
      key(merge(S.period, key {
        label = { { text = "。" } },
        click = ".",
        long_click = "]",
        swipe_up = "]",
        hint = { { text = "ic@list-box-outline" } },
        swipe_down = "SchemeList",
        width = 0.1,
        key_text_size = func_key_text_size,
        key_text_offset_y = -1
      })),
      key(merge(S.switch, key {
        click = opts.mode_switch and "ModeSwitch" or "Keyboard45Eng",
        label_symbol = { { text = "ic@keyboard-settings-outline" } },
        long_click = "KeyboardList",
        hint = { { text = "ic@web" } },
        swipe_down = "IMESwitch",
        has_menu = "Escape",
        width = 0.11,
        key_text_offset_y = 1
      })),
      key(merge(S.enter, key {
        label = { { text = "enter_labels" } },
        click = "Enter",
        long_click = "ColorList",
        width = 0.15,
        key_text_size = func_key_text_size
      }))
    }
  }

  return { action = action }
end
