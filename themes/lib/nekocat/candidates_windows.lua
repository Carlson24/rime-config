-- ========================================================================
-- 候选窗口 / 悬浮窗 (Window)
-- ========================================================================

local cw = window {
  insets = { vertical = 2, horizontal = 2 }, -- [Padding] 窗口内边距
  item_padding = { horizontal = 4 },         -- [Padding] 候选项内边距
  min_width = 0,                             -- [int] 最小宽度
  corner_radius = 5,                         -- [float] 窗口圆角
  border = 1,                                -- [int] 边框宽度
  shadow = 10,                               -- [float] 阴影半径
  alpha = 0.85,                              -- [float] 透明度 (0.0～1.0)
  foreground = {                             -- [Foreground] 前景样式
    label_font_size = 16,                    -- [float] 序号字号
    text_font_size = 18,                     -- [float] 文本字号
    comment_font_size = 12                   -- [float] 注释字号
  }
}

return cw
