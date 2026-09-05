-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪45键 Trime 主题 YAML
-- 国风·贰: 元 · 弦歌三千 (j3/j4)

local IMG = "思无邪/国风·贰/元 · 弦歌三千/"
local IMG_D = "思无邪/国风·贰/元 · 弦歌三千  •  深色/"

local xgsq = {
  --------------------------------------------------------------------------
  -- j3: 元 · 弦歌三千 (亮色)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  j3 = merge(safe_require("nekocat.colors.latte"), {
    name                         = "元 · 弦歌三千",
    dark_scheme                  = "j4",

    -- 基础色
    back_color                   = "#CDD9E6",
    -- keyboard_back_color          = IMG .. "jp.9.png",
    keyboard_back_color          = "#CDD9E6",
    candidate_background         = IMG .. "ztl.9.png",

    -- 候选区
    text_color                   = "#697A8D",
    candidate_text_color         = "#697A8D",
    hilited_candidate_back_color = "0x00",
    hilited_candidate_text_color = "#FF6666",
    hilited_text_color           = "#FF6666",
    hilited_comment_text_color   = "#FF6666",
    hilited_label_color          = "#2E81FF",
    comment_text_color           = "#FF6666",
    label_color                  = "#2E81FF",

    -- 按键
    key_back_color               = IMG .. "zj.9.png",
    hilited_key_back_color       = IMG .. "zjh.9.png",
    key_text_color               = "#455361",
    key_symbol_color             = "#455361",


    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#455361",
    hilited_off_key_back_color             = IMG .. "zjh.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#CDD9E6",
    hilited_popup_back_color               = "#687A8B",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "zjh.9.png",
    clipboard_category_back_color          = IMG .. "zj.9.png",
    clipboard_category_selected_back_color = IMG .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "zj.9.png",
    liquid_keyboard_divider_color          = "#CDD9E6",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "gnf.9.png",
    g_key_back_color                       = IMG .. "g.9.png",
    g_hilited_key_back_color               = IMG .. "gh.9.png",
    kp5_key_back_color                     = IMG .. "5.9.png",
    comma_key_back_color                   = IMG .. "zj.9.png",
    comma_hilited_key_back_color           = IMG .. "zjh.9.png",
    period_key_back_color                  = IMG .. "zj.9.png",
    period_hilited_key_back_color          = IMG .. "zjh.9.png",
    backspace_key_back_color               = IMG .. "tg.9.png",
    clear_key_back_color                   = IMG .. "gn.9.png",
    shift_key_back_color                   = IMG .. "gn.9.png",
    lookup_key_back_color                  = IMG .. "gn.9.png",
    num_key_back_color                     = IMG .. "sz.9.png",
    space_key_back_color                   = IMG .. "kg.9.png",
    enter_key_back_color                   = IMG .. "hc.9.png",
    enter_key_text_color                   = "#D0E0EF",
    enter_key_symbol_color                 = "#D0E0EF",
    enter_hilited_key_text_color           = "#455361",
    enter_hilited_key_symbol_color         = "#455361"
  }),

  --------------------------------------------------------------------------
  -- j4: 元 · 弦歌三千  •  深色 (暗色)
  --------------------------------------------------------------------------
  j4 = merge(safe_require("nekocat.colors.mocha"), {
    name                                   = "元 · 弦歌三千  •  深色",
    light_scheme                           = "j3",

    -- 基础色
    back_color                             = "#272B2F",
    keyboard_back_color                    = "#272B2F",
    candidate_background                   = IMG_D .. "ztl.9.png",

    -- 候选区
    text_color                             = "#E1EBF5",
    candidate_text_color                   = "#E1EBF5",
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
    key_text_color                         = "#D0E0EF",
    key_symbol_color                       = "#D0E0EF",

    -- Shift/功能键
    off_key_back_color                     = IMG_D .. "gn.9.png",
    off_key_text_color                     = "#D0E0EF",
    hilited_off_key_back_color             = IMG_D .. "zjh.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#272B2F",
    hilited_popup_back_color               = "#687A8B",

    -- 剪贴板
    clipboard_entry_back_color             = IMG_D .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG_D .. "zjh.9.png",
    clipboard_category_back_color          = IMG_D .. "zj.9.png",
    clipboard_category_selected_back_color = IMG_D .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG_D .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG_D .. "zj.9.png",
    liquid_keyboard_divider_color          = "#272B2F",

    -- 独立按键配色
    func_key_back_color                    = IMG_D .. "gnf.9.png",
    g_key_back_color                       = IMG_D .. "g.9.png",
    g_hilited_key_back_color               = IMG_D .. "gh.9.png",
    kp5_key_back_color                     = IMG_D .. "5.9.png",
    comma_key_back_color                   = IMG_D .. "zj.9.png",
    comma_hilited_key_back_color           = IMG_D .. "zjh.9.png",
    period_key_back_color                  = IMG_D .. "zj.9.png",
    period_hilited_key_back_color          = IMG_D .. "zjh.9.png",
    backspace_key_back_color               = IMG_D .. "tg.9.png",
    clear_key_back_color                   = IMG_D .. "gn.9.png",
    shift_key_back_color                   = IMG_D .. "gn.9.png",
    lookup_key_back_color                  = IMG_D .. "gn.9.png",
    num_key_back_color                     = IMG_D .. "sz.9.png",
    space_key_back_color                   = IMG_D .. "kg.9.png",
    enter_key_back_color                   = IMG_D .. "hc.9.png"
  })
}

return xgsq
