-- ========================================================================
-- 预编辑区 (Preedit)
-- ========================================================================

local pt = preedit {
  horizontal_padding = 8, -- [int] 横向内边距
  top_end_radius = 10,    -- [float] 上端圆角
  alpha = 0.8,            -- [float] 透明度 (0.0～1.0)
  foreground = {          -- [Foreground] 前景样式
    font_size = 16        -- [float] 字号
  }
}

return pt
