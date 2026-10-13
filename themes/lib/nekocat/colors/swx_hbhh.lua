-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪46键 Trime 主题 YAML
-- 纯真: 灰白/灰黑 (e5/e6)

local IMG = "思无邪/纯真/灰白/"
local IMG_D = "思无邪/纯真/灰黑/"

local hbhh = {
  --------------------------------------------------------------------------
  -- e5: 灰白 (亮色)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  e5 = merge(safe_require("nekocat.colors.latte"), {
    name                                   = "灰白",
    dark_scheme                            = "default_dark",

    -- 基础色
    back_color                             = "#FDFDFD",
    keyboard_back_color                    = "#D0D3DC",
    candidate_background                   = IMG .. "ztl.9.png",

    -- 候选区
    text_color                             = "#535353",
    candidate_text_color                   = "#535353",
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
    key_text_color                         = "#535353",
    key_symbol_color                       = "#535353",

    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#323232",
    hilited_off_key_back_color             = IMG .. "gnh.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#FDFDFD",
    hilited_popup_back_color               = "#3266A0",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "zjh.9.png",
    clipboard_category_back_color          = IMG .. "zj.9.png",
    clipboard_category_selected_back_color = IMG .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "zj.9.png",
    liquid_keyboard_divider_color          = "#D0D3DC",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "gn.9.png",
    func_hilited_key_back_color            = IMG .. "gnh.9.png",
    comma_key_back_color                   = IMG .. "zj.9.png",
    comma_hilited_key_back_color           = IMG .. "zjh.9.png",
    period_key_back_color                  = IMG .. "zj.9.png",
    period_hilited_key_back_color          = IMG .. "zjh.9.png",
    enter_key_back_color                   = IMG .. "hc.9.png",
    enter_hilited_key_back_color           = IMG .. "hch.9.png",
    enter_key_text_color                   = "#F9F9F9",
    enter_key_symbol_color                 = "#F9F9F9"
  }),

  --------------------------------------------------------------------------
  -- e6: 灰黑 (暗色)
  --------------------------------------------------------------------------
  e6 = merge(safe_require("nekocat.colors.mocha"), {
    name                                   = "灰黑",
    light_scheme                           = "default",

    -- 基础色
    back_color                             = "#3A3A3A",
    keyboard_back_color                    = "#292929",
    candidate_background                   = IMG_D .. "ztl.9.png",

    -- 候选区
    text_color                             = "#DDDDDD",
    candidate_text_color                   = "#DDDDDD",
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
    key_text_color                         = "#DDDDDD",
    key_symbol_color                       = "#DDDDDD",

    -- Shift/功能键
    off_key_back_color                     = IMG_D .. "gn.9.png",
    off_key_text_color                     = "#DDDDDD",
    hilited_off_key_back_color             = IMG_D .. "gnh.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#3A3A3A",
    hilited_popup_back_color               = "#3266A0",

    -- 剪贴板
    clipboard_entry_back_color             = IMG_D .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG_D .. "zjh.9.png",
    clipboard_category_back_color          = IMG_D .. "zj.9.png",
    clipboard_category_selected_back_color = IMG_D .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG_D .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG_D .. "zj.9.png",
    liquid_keyboard_divider_color          = "#3A3A3A",

    -- 独立按键配色
    func_key_back_color                    = IMG_D .. "gn.9.png",
    func_hilited_key_back_color            = IMG_D .. "gnh.9.png",
    comma_key_back_color                   = IMG_D .. "zj.9.png",
    comma_hilited_key_back_color           = IMG_D .. "zjh.9.png",
    period_key_back_color                  = IMG_D .. "zj.9.png",
    period_hilited_key_back_color          = IMG_D .. "zjh.9.png"
  })
}

return hbhh
