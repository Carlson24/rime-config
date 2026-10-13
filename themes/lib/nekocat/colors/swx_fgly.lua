-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪45键 Trime 主题 YAML
-- 国风·贰: 清 · 浮光掠影 (j7/j8)

local IMG = "思无邪/国风·贰/清 · 浮光掠影/"
local IMG_D = "思无邪/国风·贰/清 · 浮光掠影  •  深色/"

local fgly = {
  --------------------------------------------------------------------------
  -- j7: 清 · 浮光掠影 (亮色)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  j7 = merge(safe_require("nekocat.colors.latte"), {
    name                                   = "清 · 浮光掠影",
    dark_scheme                            = "j8",

    -- 基础色
    back_color                             = "#EAEAF3",
    keyboard_back_color                    = IMG .. "jp.9.png",
    candidate_background                   = IMG .. "ztl.9.png",

    -- 候选区
    text_color                             = "#414B5C",
    candidate_text_color                   = "#414B5C",
    hilited_candidate_back_color           = "0x00",
    hilited_candidate_text_color           = "#BA4444",
    hilited_text_color                     = "#FF1900",
    hilited_comment_text_color             = "#BA4444",
    hilited_label_color                    = "#2E81FF",
    comment_text_color                     = "#FF1900",
    label_color                            = "#2E81FF",

    -- 按键
    key_back_color                         = IMG .. "zj.9.png",
    hilited_key_back_color                 = IMG .. "zjh.9.png",
    key_text_color                         = "#414B5C",
    key_symbol_color                       = "#414B5C",

    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#414B5C",
    hilited_off_key_back_color             = IMG .. "zjh.9.png",
    on_key_text_color                      = "#BA4444",

    -- 弹出气泡
    popup_back_color                       = "#EAEAF3",
    hilited_popup_back_color               = "#BC4747",
    hilited_popup_text_color               = "#DDDDDD",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "zjh.9.png",
    clipboard_category_back_color          = IMG .. "zj.9.png",
    clipboard_category_selected_back_color = IMG .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "zj.9.png",
    liquid_keyboard_divider_color          = "#EAEAF3",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "gnf.9.png",
    g_key_back_color                       = IMG .. "g.9.png",
    comma_key_back_color                   = IMG .. "zj.9.png",
    comma_hilited_key_back_color           = IMG .. "zjh.9.png",
    period_key_back_color                  = IMG .. "zj.9.png",
    period_hilited_key_back_color          = IMG .. "zjh.9.png",
    shift_key_back_color                   = IMG .. "gn.9.png",
    clear_key_back_color                   = IMG .. "gn.9.png",
    lookup_key_back_color                  = IMG .. "gn.9.png",
    backspace_key_back_color               = IMG .. "tg.9.png",
    backspace_key_text_color               = "#DDDDDD",
    num_key_back_color                     = IMG .. "sz.9.png",
    space_key_back_color                   = IMG .. "kg.9.png",
    enter_key_back_color                   = IMG .. "hc.9.png",
    enter_key_text_color                   = "#414B5C",
    enter_key_symbol_color                 = "#414B5C",
    kp5_key_back_color                     = IMG .. "5.9.png"
  }),

  --------------------------------------------------------------------------
  -- j8: 清 · 浮光掠影  •  深色 (暗色)
  --------------------------------------------------------------------------
  j8 = merge(safe_require("nekocat.colors.mocha"), {
    name                                   = "清 · 浮光掠影  •  深色",
    light_scheme                           = "j7",

    -- 基础色
    back_color                             = "#1B201C",
    keyboard_back_color                    = IMG_D .. "jp.9.png",
    candidate_background                   = IMG_D .. "ztl.9.png",

    -- 候选区
    text_color                             = "#D9E6FA",
    candidate_text_color                   = "#D9E6FA",
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
    key_text_color                         = "#D6E4FB",
    key_symbol_color                       = "#D6E4FB",

    -- Shift/功能键
    off_key_back_color                     = IMG_D .. "gn.9.png",
    off_key_text_color                     = "#E8F2FF",
    hilited_off_key_back_color             = IMG_D .. "zjh.9.png",
    on_key_text_color                      = "#E55C5C",

    -- 弹出气泡
    popup_back_color                       = "#1B201C",
    hilited_popup_back_color               = "#BC4747",

    -- 剪贴板
    clipboard_entry_back_color             = IMG_D .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG_D .. "zjh.9.png",
    clipboard_category_back_color          = IMG_D .. "zj.9.png",
    clipboard_category_selected_back_color = IMG_D .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG_D .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG_D .. "zj.9.png",
    liquid_keyboard_divider_color          = "#1B201C",

    -- 独立按键配色
    func_key_back_color                    = IMG_D .. "gnf.9.png",
    g_key_back_color                       = IMG_D .. "g.9.png",
    comma_key_back_color                   = IMG_D .. "zj.9.png",
    comma_hilited_key_back_color           = IMG_D .. "zjh.9.png",
    period_key_back_color                  = IMG_D .. "zj.9.png",
    period_hilited_key_back_color          = IMG_D .. "zjh.9.png",
    shift_key_back_color                   = IMG_D .. "gn.9.png",
    clear_key_back_color                   = IMG_D .. "gn.9.png",
    lookup_key_back_color                  = IMG_D .. "gn.9.png",
    backspace_key_back_color               = IMG_D .. "tg.9.png",
    num_key_back_color                     = IMG_D .. "sz.9.png",
    num_key_text_color                     = "#414B5C",
    num_key_symbol_color                   = "#414B5C",
    space_key_back_color                   = IMG_D .. "kg.9.png",
    enter_key_back_color                   = IMG_D .. "hc.9.png",
    kp5_key_back_color                     = IMG_D .. "5.9.png"
  })
}

return fgly
