-- SPDX-License-Identifier: GPL-3.0-or-later
-- 思无邪系列配色方案
-- 移植自 思无邪45键 Trime 主题 YAML
-- 纯真: 彩虹 (e1)

local IMG = "思无邪/纯真/彩虹/"

local colors = {
  --------------------------------------------------------------------------
  -- e1: 彩虹 (单方案，无暗色模式)
  --------------------------------------------------------------------------
  ---@type SchemeColors
  e1 = merge(safe_require("nekocat.colors.latte"), {
    name                                   = "彩虹",

    -- 基础色
    back_color                             = "#DED4CE",
    keyboard_back_color                    = "#DED4CE",
    candidate_background                   = IMG .. "ztl.9.png",

    -- 候选区
    text_color                             = "#454545",
    candidate_text_color                   = "#454545",
    hilited_candidate_back_color           = "0x00",
    hilited_candidate_text_color           = "#F04E46",
    hilited_text_color                     = "#FF1900",
    hilited_comment_text_color             = "#F04E46",
    hilited_label_color                    = "#2E81FF",
    comment_text_color                     = "#FF1900",
    label_color                            = "#2E81FF",

    -- 按键
    key_back_color                         = IMG .. "zj.9.png",
    hilited_key_back_color                 = IMG .. "zjh.9.png",
    key_text_color                         = "#454545",
    key_symbol_color                       = "#454545",

    -- Shift/功能键
    off_key_back_color                     = IMG .. "gn.9.png",
    off_key_text_color                     = "#404040",
    hilited_off_key_back_color             = IMG .. "zjh.9.png",
    on_key_text_color                      = "#E9300E",

    -- 弹出气泡
    popup_back_color                       = "#DED4CE",
    hilited_popup_back_color               = "#FF9090",

    -- 剪贴板
    clipboard_entry_back_color             = IMG .. "zj.9.png",
    hilited_clipboard_entry_back_color     = IMG .. "zjh.9.png",
    clipboard_category_back_color          = IMG .. "zj.9.png",
    clipboard_category_selected_back_color = IMG .. "zjh.9.png",

    -- 侧边栏
    sidebar_back_color                     = IMG .. "zj.9.png",

    -- 流体键盘
    liquid_keyboard_background             = IMG .. "zj.9.png",
    liquid_keyboard_divider_color          = "#DED4CE",

    -- 独立按键配色
    func_key_back_color                    = IMG .. "gn.9.png",
    space_key_back_color                   = IMG .. "zj.9.png",
    enter_key_back_color                   = IMG .. "hc.9.png",
    enter_key_text_color                   = "#353535",

    -- 字母键独立配色
    q_key_back_color                       = IMG .. "q.9.png",
    w_key_back_color                       = IMG .. "w.9.png",
    e_key_back_color                       = IMG .. "e.9.png",
    r_key_back_color                       = IMG .. "r.9.png",
    t_key_back_color                       = IMG .. "t.9.png",
    y_key_back_color                       = IMG .. "y.9.png",
    u_key_back_color                       = IMG .. "u.9.png",
    i_key_back_color                       = IMG .. "i.9.png",
    o_key_back_color                       = IMG .. "o.9.png",
    p_key_back_color                       = IMG .. "p.9.png",
    a_key_back_color                       = IMG .. "a.9.png",
    s_key_back_color                       = IMG .. "s.9.png",
    d_key_back_color                       = IMG .. "d.9.png",
    f_key_back_color                       = IMG .. "f.9.png",
    g_key_back_color                       = IMG .. "g.9.png",
    h_key_back_color                       = IMG .. "h.9.png",
    j_key_back_color                       = IMG .. "j.9.png",
    k_key_back_color                       = IMG .. "k.9.png",
    l_key_back_color                       = IMG .. "l.9.png",
    z_key_back_color                       = IMG .. "z.9.png",
    x_key_back_color                       = IMG .. "x.9.png",
    c_key_back_color                       = IMG .. "c.9.png",
    v_key_back_color                       = IMG .. "v.9.png",
    b_key_back_color                       = IMG .. "b.9.png",
    n_key_back_color                       = IMG .. "n.9.png",
    m_key_back_color                       = IMG .. "m.9.png"
  })
}

return colors
