-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪45键 Trime 主题 YAML
-- 国风·贰: 宋 · 落纸云烟 (j1/j2)

local IMG = "思无邪/国风·贰/宋 · 落纸云烟/"
local IMG_D = "思无邪/国风·贰/宋 · 落纸云烟  •  深色/"

local lzyy = {
  --------------------------------------------------------------------------
  -- j1: 宋 · 落纸云烟 (亮色)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  j1 = merge(safe_require("nekocat.colors.latte"), {
    name                                   = "宋 · 落纸云烟",
    dark_scheme                            = "j2",

    -- 基础色
    back_color                             = "#CDC2BF",
    keyboard_back_color                    = IMG .. "jp.9.png",
    candidate_background                   = IMG .. "ztl.9.png",

    -- 候选区
    text_color                             = "#403A38",
    candidate_text_color                   = "#403A38",
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
    key_text_color                         = "#5F5856",
    key_symbol_color                       = "#5F5856",

    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#5F5856",
    hilited_off_key_back_color             = IMG .. "zj.9.png",
    on_key_text_color                      = "#AA5034",

    -- 弹出气泡
    popup_back_color                       = "#CDC2BF",
    hilited_popup_back_color               = "#D16241",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "zjh.9.png",
    clipboard_category_back_color          = IMG .. "zj.9.png",
    clipboard_category_selected_back_color = IMG .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "zj.9.png",
    liquid_keyboard_divider_color          = "#CDC2BF",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "kgh.9.png",
    comma_key_back_color                   = IMG .. "zj.9.png",
    comma_hilited_key_back_color           = IMG .. "zjh.9.png",
    period_key_back_color                  = IMG .. "zj.9.png",
    period_hilited_key_back_color          = IMG .. "zjh.9.png",
    shift_key_back_color                   = IMG .. "gn.9.png",
    clear_key_back_color                   = IMG .. "gn.9.png",
    lookup_key_back_color                  = IMG .. "gn.9.png",
    backspace_key_back_color               = IMG .. "tg.9.png",
    backspace_hilited_key_back_color       = IMG .. "hc.9.png",
    num_key_back_color                     = IMG .. "sz.9.png",
    space_key_back_color                   = IMG .. "kg.9.png",
    space_hilited_key_back_color           = IMG .. "kgh.9.png",
    enter_key_back_color                   = IMG .. "hc.9.png",
    enter_hilited_key_back_color           = IMG .. "sz.9.png",
    backspace_key_text_color               = "#F3EFEE",
    enter_key_text_color                   = "#F3EFEE",
    enter_key_symbol_color                 = "#F3EFEE",
    enter_hilited_key_text_color           = "#5F5856",
    enter_hilited_key_symbol_color         = "#5F5856"
  }),

  --------------------------------------------------------------------------
  -- j2: 宋 · 落纸云烟  •  深色 (暗色)
  --------------------------------------------------------------------------
  j2 = merge(safe_require("nekocat.colors.mocha"), {
    name                                   = "宋 · 落纸云烟  •  深色",
    light_scheme                           = "j1",

    -- 基础色
    back_color                             = "#3C3736",
    keyboard_back_color                    = IMG_D .. "jp.9.png",
    candidate_background                   = IMG_D .. "ztl.9.png",

    -- 候选区
    text_color                             = "#EBDDD8",
    candidate_text_color                   = "#EBDDD8",
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
    key_text_color                         = "#EBDDD8",
    key_symbol_color                       = "#EBDDD8",

    -- Shift/功能键
    off_key_back_color                     = IMG_D .. "gn.9.png",
    off_key_text_color                     = "#EBDDD8",
    hilited_off_key_back_color             = IMG_D .. "zj.9.png",
    on_key_text_color                      = "#E57C5C",

    -- 弹出气泡
    popup_back_color                       = "#3C3736",
    hilited_popup_back_color               = "#D16241",

    -- 剪贴板
    clipboard_entry_back_color             = IMG_D .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG_D .. "zjh.9.png",
    clipboard_category_back_color          = IMG_D .. "zj.9.png",
    clipboard_category_selected_back_color = IMG_D .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG_D .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG_D .. "zj.9.png",
    liquid_keyboard_divider_color          = "#3C3736",

    -- 独立按键配色
    func_key_back_color                    = IMG_D .. "gnf.9.png",
    comma_key_back_color                   = IMG_D .. "zj.9.png",
    comma_hilited_key_back_color           = IMG_D .. "zjh.9.png",
    period_key_back_color                  = IMG_D .. "zj.9.png",
    period_hilited_key_back_color          = IMG_D .. "zjh.9.png",
    shift_key_back_color                   = IMG_D .. "gn.9.png",
    clear_key_back_color                   = IMG_D .. "gn.9.png",
    lookup_key_back_color                  = IMG_D .. "gn.9.png",
    backspace_key_back_color               = IMG_D .. "tg.9.png",
    num_key_back_color                     = IMG_D .. "sz.9.png",
    space_key_back_color                   = IMG_D .. "kg.9.png",
    enter_key_back_color                   = IMG_D .. "sz.9.png"
  })
}

return lzyy
