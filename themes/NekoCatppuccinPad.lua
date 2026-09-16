-- SPDX-License-Identifier: GPL-3.0-or-later

-- LyraIME 主题 NekoCatppuccin

local theme = theme {
  -- ========================================================================
  -- 元数据
  -- ========================================================================
  name = "NekoCatppuccinPad",
  version = "5.6",
  author = "Carlson24(鹤衔春雪)",

  style = merge(safe_require("nekocat.generalstyle"), style {
    keyboard_height = 295,      -- [int] 竖屏键盘高度 (px)
    keyboard_height_land = 150, -- [int] 横屏键盘高度 (px)
    candidate_view_height = 40  -- [int] 候选区高度
  }),

  fallback_colors = safe_require("nekocat.colors._key_colors").fallback_colors,

  preset_color_schemes = safe_require("nekocat.color_schemes"),

  preedit = safe_require("nekocat.preedit"),

  window = safe_require("nekocat.candidates_windows"),

  candidates_tool = safe_require("nekocat.candidates_tool"),

  tool_bar = safe_require("nekocat.toolbar"),

  preset_keys = safe_require("nekocat.preset_keys"),

  preset_keyboards = safe_require("nekocat.textkeyboard"),

  liquid_keyboard = safe_require("nekocat.liquid_keyboard")
}

return theme
