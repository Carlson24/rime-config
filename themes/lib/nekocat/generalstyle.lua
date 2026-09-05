local font_combo = {
  "LXGW975YuanSC-400W.ttf", "OpenMoji.ttf", "CarlsonFont.ttf",
  "WenJinMinchoP0-Regular.otf", "WenJinMinchoP2-Regular.otf", "WenJinMinchoP3-Regular.otf"
}

-- ========================================================================
-- 全局样式 (GeneralStyle)
-- 每个属性后注释说明其类型和用途，可注释掉使用默认值
-- ========================================================================
local gs = style {
  -- 键盘
  horizontal_gap = 2,                         -- [int] 键水平间距 (px)
  vertical_gap = 1,                           -- [int] 键盘行距 (px)
  round_corner = 10,                          -- [float] 按键圆角半径
  content_padding = 4,                        -- [int] 裁切边距
  key_border = 1,                             -- [int] 按键边框宽度
  key_shadow_radius = 0,                      -- [float] 按键阴影半径
  key_shadow_direction = { "right", "down" }, -- [string] 按键阴影位置

  -- 键盘边距（竖屏）
  keyboard_padding = 2,        -- [int] 左右与屏幕的距离离
  keyboard_padding_bottom = 0, -- [int] 底部距离（避免触发全面屏手势）
  keyboard_padding_top = 0,    -- [int] 顶部距离

  -- 键盘边距（横屏）
  keyboard_padding_land = 40,       -- [int] 横屏左右距离
  keyboard_padding_land_bottom = 0, -- [int] 横屏底部距离

  -- 候选栏
  candidate_view_height = 35,          -- [int] 候选区高度
  candidate_padding = 7,               -- [int] 候选项内边距
  candidate_spacing = 1.0,             -- [float] 候选间距
  candidate_text_vertical_bias = 0.85, -- [float] 候选文本垂直偏移
  candidate_border = 0,                -- [int] 候选边框
  candidate_border_round = 0,          -- [float] 候选边框圆角
  candidate_corner_radius = 10,        -- [float] 候选项圆角半径
  candidate_label = true,              -- [bool] 候选序号
  candidate_label_size = 15,           -- [int] 候选序号字号

  -- 编码注释
  comment_height = 3,           -- [int] 编码提示区高度
  comment_vertical_bias = 0.1,  -- [float] 注释垂直偏移 (overlay 模式)
  comment_position = "OVERLAY", -- [CommentPosition] 位置: RIGHT | TOP | OVERLAY

  -- 悬浮提示
  popup_bottom_margin = 68, -- [int] 底部边距
  popup_width = 38,         -- [int] 宽度
  popup_height = 50,        -- [int] 高度
  popup_key_height = 52,    -- [int] 键高度

  -- 回车键文本
  enter_label_mode = 3, -- [int] ActionLabel 模式: 0=不使用 1=仅action 2=优先 3=fallback
  enter_labels = {      -- [EnterLabel] 回车键文本
    go = "ic@web",
    done = "ic@check",
    next = "ic@keyboard_return",
    pre = "ic@keyboard_return",
    search = "ic@magnify",
    send = "ic@keyboard_return",
    default = "ic@keyboard_return"
  },

  -- 侧栏
  sidebar_round_corner = -1, -- [float] 侧栏圆角 (-1 = 跟随 round_corner)

  -- 其他
  auto_caps = false,                        -- [bool] 自动句首大写
  -- background_folder = "backgrounds",     -- [string] 背景图存放子目录
  reset_ascii_mode_on_focus_change = false, -- [bool] 焦点变更时重置 ascii 模式

  -- 字体/字号
  fonts = {
    candidate = font_combo,
    candidate_size = 19,
    comment = font_combo,
    comment_size = 8,
    key = font_combo,
    key_size = 19,
    key_long_size = 16,
    label = font_combo,
    label_size = 22,
    latin = font_combo,
    symbol = font_combo,
    symbol_size = 10,
    text = font_combo,
    hint = font_combo,
    hint_size = 9,
    hanb = font_combo,
    popup = font_combo,
    popup_size = 20,
    sidebar = font_combo,
    sidebar_size = 18,
    liquid_tabs_size = 18,
    clipboard = font_combo,
    clipboard_size = 13,
    clipboard_category = font_combo,
    clipboard_category_size = 14
  }
}

return gs
