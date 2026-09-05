-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪45键 Trime 主题 YAML
-- 时尚·壹:森 · 零度 (s1/s2)

local IMG = "思无邪/时尚·壹/森 · 零度/"
local IMG_D = "思无邪/时尚·壹/森 · 零度  •  深色/"

local sld = {
  --------------------------------------------------------------------------
  -- s1: 森 · 零度 (亮色)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  s1 = merge(safe_require("nekocat.colors.latte"), {
    name                                   = "森 · 零度",
    dark_scheme                            = "s2",

    -- 基础色
    back_color                             = "#D1D2CF",
    keyboard_back_color                    = IMG .. "jp.9.png",
    candidate_background                   = IMG .. "ztl.9.png",

    -- 候选区
    text_color                             = "#303336",
    candidate_text_color                   = "#303336",
    hilited_candidate_back_color           = "0x00",
    hilited_candidate_text_color           = "#DC143C",
    hilited_text_color                     = "#FF1900",
    hilited_comment_text_color             = "#DC143C",
    hilited_label_color                    = "#2E81FF",
    comment_text_color                     = "#FF1900",
    label_color                            = "#2E81FF",

    -- 按键
    key_back_color                         = IMG .. "zj.9.png",
    hilited_key_back_color                 = IMG .. "zjh.9.png",
    key_text_color                         = "#303336",
    key_symbol_color                       = "#303336",

    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#303336",
    hilited_off_key_back_color             = IMG .. "zjh.9.png",
    on_key_text_color                      = "#AA5034",

    -- 弹出气泡
    popup_back_color                       = "#D1D2CF",
    hilited_popup_back_color               = "#363B39",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "zjh.9.png",
    clipboard_category_back_color          = IMG .. "zj.9.png",
    clipboard_category_selected_back_color = IMG .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "zj.9.png",
    liquid_keyboard_divider_color          = "#D1D2CF",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "tg.9.png",
    comma_key_back_color                   = IMG .. "zj.9.png",
    comma_hilited_key_back_color           = IMG .. "zjh.9.png",
    period_key_back_color                  = IMG .. "zj.9.png",
    period_hilited_key_back_color          = IMG .. "zjh.9.png",
    shift_key_back_color                   = IMG .. "gn.9.png",
    clear_key_back_color                   = IMG .. "gn.9.png",
    lookup_key_back_color                  = IMG .. "gn.9.png",
    backspace_key_back_color               = IMG .. "tg.9.png",
    num_key_back_color                     = IMG .. "tg.9.png",
    space_key_back_color                   = IMG .. "kg.9.png",
    enter_key_back_color                   = IMG .. "hc.9.png",
    enter_key_text_color                   = "#CFD0CC",
    enter_key_symbol_color                 = "#CFD0CC",
    enter_hilited_key_text_color           = "#303336",
    enter_hilited_key_symbol_color         = "#303336",
    kp1_key_back_color                     = IMG .. "1.9.png",
    kp1_hilited_key_back_color             = IMG .. "1h.9.png"
  }),

  --------------------------------------------------------------------------
  -- s2: 森 · 零度  •  深色 (暗色)
  --------------------------------------------------------------------------
  s2 = merge(safe_require("nekocat.colors.mocha"), {
    name                                   = "森 · 零度  •  深色",
    light_scheme                           = "s1",

    -- 基础色
    back_color                             = "#2D2F2E",
    keyboard_back_color                    = IMG_D .. "jp.9.png",
    candidate_background                   = IMG_D .. "ztl.9.png",

    -- 候选区
    text_color                             = "#E9E9E9",
    candidate_text_color                   = "#E9E9E9",
    hilited_candidate_back_color           = "0x00",
    hilited_candidate_text_color           = "#FF6666",
    hilited_text_color                     = "#FF6666",
    hilited_comment_text_color             = "#FF6666",
    hilited_label_color                    = "#2E81FF",
    comment_text_color                     = "#FF6666",
    label_color                            = "#2E81FF",

    -- 按键
    key_back_color                         = IMG_D .. "zj.9.png",
    hilited_key_back_color                 = IMG_D .. "zjh.9.png",
    key_text_color                         = "#E9E9E9",
    key_symbol_color                       = "#E9E9E9",

    -- Shift/功能键
    off_key_back_color                     = IMG_D .. "gn.9.png",
    off_key_text_color                     = "#E9E9E9",
    hilited_off_key_back_color             = IMG_D .. "zjh.9.png",
    on_key_text_color                      = "#E57C5C",

    -- 弹出气泡
    popup_back_color                       = "#2D2F2E",
    hilited_popup_back_color               = "#636460",

    -- 剪贴板
    clipboard_entry_back_color             = IMG_D .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG_D .. "zjh.9.png",
    clipboard_category_back_color          = IMG_D .. "zj.9.png",
    clipboard_category_selected_back_color = IMG_D .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG_D .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG_D .. "zj.9.png",
    liquid_keyboard_divider_color          = "#2D2F2E",

    -- 独立按键配色
    func_key_back_color                    = IMG_D .. "tg.9.png",
    comma_key_back_color                   = IMG_D .. "zj.9.png",
    comma_hilited_key_back_color           = IMG_D .. "zjh.9.png",
    period_key_back_color                  = IMG_D .. "zj.9.png",
    period_hilited_key_back_color          = IMG_D .. "zjh.9.png",
    shift_key_back_color                   = IMG_D .. "gn.9.png",
    clear_key_back_color                   = IMG_D .. "gn.9.png",
    lookup_key_back_color                  = IMG_D .. "gn.9.png",
    backspace_key_back_color               = IMG_D .. "tg.9.png",
    num_key_back_color                     = IMG_D .. "tg.9.png",
    space_key_back_color                   = IMG_D .. "kg.9.png",
    enter_key_back_color                   = IMG_D .. "hc.9.png",
    enter_key_text_color                   = "#CFD0CC",
    enter_key_symbol_color                 = "#CFD0CC",
    kp1_key_back_color                     = IMG_D .. "1.9.png",
    kp1_hilited_key_back_color             = IMG_D .. "1h.9.png"
  })
}

return sld
