-- ========================================================================
-- 悬浮同步输入框 (Sync Input)
-- ========================================================================

local si = sync_input {
  font_size = 18,         -- [float] 字号（未设置时沿用 preedit）
  alpha = 0.8,            -- [float] 背景透明度 (0.0～1.0)
  corner_radius = 8,      -- [float] 圆角 dp
  horizontal_padding = 8, -- [int] 左右内边距 dp
  vertical_padding = 6,   -- [int] 上下内边距 dp
  max_height = 96         -- [int] 最大高度 dp；未设置时约 3 行
}

return si
