-- ========================================================================
-- 候选工具栏 (CandidatesTool)
-- ========================================================================

local ct = {
  -- 候选页面
  nav_width = 41,                             -- [int] 侧边栏宽度
  button_font = { "LXGW975YuanSC-400W.ttf" }, -- [string[]] 侧边栏字体
  background = "back_color",                  -- [string] 侧边栏背景色
  separator_color = "back_color",             -- [string] 侧边栏分割线颜色
  buttons = {
    { action = "Up",            foreground = { style = "ic@arrow-up-bold", font_size = 14 } },
    { action = "Down",          foreground = { style = "ic@arrow-down-bold", font_size = 14 } },
    { action = "BackSpace",     foreground = { style = "ic@backspace-outline", font_size = 14 } },
    { action = "CommitPreedit", foreground = { style = "ic@keyboard-return", font_size = 14 } }
  },

  -- 候选词长按菜单
  popup_width = 65,                          -- [int] 长按菜单宽度
  popup_font = { "LXGW975YuanSC-400W.ttf" }, -- [string[]] 长按菜单字体
  popup_text_size = 16,                      -- [int] 长按菜单字号
  popup_text_color = "text_color",           -- [string] 长按菜单字体颜色
  popup_background_color = "back_color",     -- [string] 长按菜单背景颜色
  popup = {
    { action = "CandPin", label = "置顶" }
  },
  popup_by_type = {
    pinned = {
      popup_width = 100,
      popup = {
        { action = "CandPin", label = "取消置顶" },
        { action = "CandUp", label = "前移该词" },
        { action = "CandDown", label = "后移该词" },
        { action = "CandDelete", label = "删除该词" }
      }
    },
    user_phrase = {
      popup_width = 100,
      popup = {
        { action = "CandPin", label = "置顶该词" },
        { action = "CandDelete", label = "删除该词" }
      }
    }
  }
}

return ct
