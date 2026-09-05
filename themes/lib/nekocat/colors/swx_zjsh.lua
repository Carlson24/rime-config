-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪45键 Trime 主题 YAML
-- 时尚·贰: 指尖生花 (ss/ss0)

local IMG = "思无邪/时尚·贰/指尖生花/"
local IMG_D = "思无邪/时尚·贰/指尖生花  •  深色/"

local zjsh = {
  --------------------------------------------------------------------------
  -- ss: 指尖生花 (亮色)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  s3 = merge(safe_require("nekocat.colors.latte"), {
    name                                   = "指尖生花",
    dark_scheme                            = "s4",

    -- 基础色
    back_color                             = "#D4E0D6",
    keyboard_back_color                    = IMG .. "jp.9.png",
    candidate_background                   = IMG .. "ztl.9.png",

    -- 候选区
    text_color                             = "#28402F",
    candidate_text_color                   = "#28402F",
    hilited_candidate_back_color           = "0x00",
    hilited_candidate_text_color           = "#DC143C",
    hilited_text_color                     = "#FF1900",
    hilited_comment_text_color             = "#DC143C",
    hilited_label_color                    = "#2E81FF",
    comment_text_color                     = "#FF1900",
    label_color                            = "#2E81FF",

    -- 按键
    key_back_color                         = IMG .. "w.9.png",
    hilited_key_back_color                 = IMG .. "gl.9.png",
    key_text_color                         = "#36573F",
    key_symbol_color                       = "#36573F",

    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#36573F",
    hilited_off_key_back_color             = IMG .. "gl.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#D4E0D6",
    hilited_popup_back_color               = "#FEB096",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "w.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "gl.9.png",
    clipboard_category_back_color          = IMG .. "w.9.png",
    clipboard_category_selected_back_color = IMG .. "gl.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "w.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "w.9.png",
    liquid_keyboard_divider_color          = "#D4E0D6",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "w.9.png",
    shift_key_back_color                   = IMG .. "gn.9.png",
    clear_key_back_color                   = IMG .. "gn.9.png",
    lookup_key_back_color                  = IMG .. "gn.9.png",
    w_key_back_color                       = IMG .. "q.9.png",
    r_key_back_color                       = IMG .. "q.9.png",
    u_key_back_color                       = IMG .. "q.9.png",
    o_key_back_color                       = IMG .. "q.9.png",
    s_key_back_color                       = IMG .. "q.9.png",
    f_key_back_color                       = IMG .. "f.9.png",
    g_key_back_color                       = IMG .. "g.9.png",
    h_key_back_color                       = IMG .. "h.9.png",
    k_key_back_color                       = IMG .. "q.9.png",
    x_key_back_color                       = IMG .. "q.9.png",
    v_key_back_color                       = IMG .. "q.9.png",
    n_key_back_color                       = IMG .. "q.9.png",
    semicolon_key_back_color               = IMG .. "q.9.png",
    num_key_back_color                     = IMG .. "sz.9.png",
    space_key_back_color                   = IMG .. "q.9.png",
    backspace_key_back_color               = IMG .. "tg.9.png",
    backspace_key_text_color               = "#FFF2C6",
    enter_key_back_color                   = IMG .. "hc.9.png",
    period_key_text_color                  = "#36573F",
    kp1_key_back_color                     = IMG .. "1.9.png",
    kp3_key_back_color                     = IMG .. "q.9.png",
    kp5_key_back_color                     = IMG .. "5.9.png",
    kp7_key_back_color                     = IMG .. "q.9.png",
    kp9_key_back_color                     = IMG .. "q.9.png",
    kp0_key_back_color                     = IMG .. "q.9.png"
  }),

  --------------------------------------------------------------------------
  -- ss0: 指尖生花  •  深色 (暗色)
  --------------------------------------------------------------------------
  s4 = merge(safe_require("nekocat.colors.mocha"), {
    name                                   = "指尖生花  •  深色",
    light_scheme                           = "s3",

    -- 基础色
    back_color                             = "#313432",
    keyboard_back_color                    = IMG_D .. "jp.9.png",
    candidate_background                   = IMG_D .. "ztl.9.png",

    -- 候选区
    text_color                             = "#E9F5EC",
    candidate_text_color                   = "#E9F5EC",
    hilited_candidate_back_color           = "0x00",
    hilited_candidate_text_color           = "#FF6666",
    hilited_text_color                     = "#FF6666",
    hilited_comment_text_color             = "#FF6666",
    hilited_label_color                    = "#2E81FF",
    comment_text_color                     = "#FF6666",
    label_color                            = "#2E81FF",

    -- 按键
    key_back_color                         = IMG_D .. "w.9.png",
    hilited_key_back_color                 = IMG_D .. "gl.9.png",
    key_text_color                         = "#DFEFE3",
    key_symbol_color                       = "#DFEFE3",

    -- Shift/功能键
    off_key_back_color                     = IMG_D .. "gn.9.png",
    off_key_text_color                     = "#DDEDE1",
    hilited_off_key_back_color             = IMG_D .. "gl.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#313432",
    hilited_popup_back_color               = "#634A42",

    -- 剪贴板
    clipboard_entry_back_color             = IMG_D .. "w.9.png",
    hilited_clipboard_entry_back_color     = IMG_D .. "gl.9.png",
    clipboard_category_back_color          = IMG_D .. "w.9.png",
    clipboard_category_selected_back_color = IMG_D .. "gl.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG_D .. "w.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG_D .. "w.9.png",
    liquid_keyboard_divider_color          = "#313432",

    -- 独立按键配色
    func_key_back_color                    = IMG_D .. "w.9.png",
    shift_key_back_color                   = IMG_D .. "gn.9.png",
    clear_key_back_color                   = IMG_D .. "gn.9.png",
    lookup_key_back_color                  = IMG_D .. "gn.9.png",
    w_key_back_color                       = IMG_D .. "q.9.png",
    r_key_back_color                       = IMG_D .. "q.9.png",
    u_key_back_color                       = IMG_D .. "q.9.png",
    o_key_back_color                       = IMG_D .. "q.9.png",
    s_key_back_color                       = IMG_D .. "q.9.png",
    f_key_back_color                       = IMG_D .. "f.9.png",
    g_key_back_color                       = IMG_D .. "g.9.png",
    h_key_back_color                       = IMG_D .. "h.9.png",
    k_key_back_color                       = IMG_D .. "q.9.png",
    x_key_back_color                       = IMG_D .. "q.9.png",
    v_key_back_color                       = IMG_D .. "q.9.png",
    n_key_back_color                       = IMG_D .. "q.9.png",
    semicolon_key_back_color               = IMG_D .. "q.9.png",
    num_key_back_color                     = IMG_D .. "sz.9.png",
    space_key_back_color                   = IMG_D .. "q.9.png",
    backspace_key_back_color               = IMG_D .. "tg.9.png",
    backspace_key_text_color               = "#FFF2C6",
    enter_key_back_color                   = IMG_D .. "hc.9.png",
    kp1_key_back_color                     = IMG_D .. "1.9.png",
    kp3_key_back_color                     = IMG_D .. "q.9.png",
    kp5_key_back_color                     = IMG_D .. "5.9.png",
    kp7_key_back_color                     = IMG_D .. "q.9.png",
    kp9_key_back_color                     = IMG_D .. "q.9.png",
    kp0_key_back_color                     = IMG_D .. "q.9.png"
  })
}

return zjsh
