-- ========================================================================
-- 悬浮同步输入框 (Sync Input)
-- ========================================================================

local si = sync_input {
  font_size = 18,         -- [float] 字号（未设置时沿用 preedit）
  alpha = 0.8,            -- [float] 背景透明度 (0.0～1.0)
  corner_radius = 8,      -- [float] 圆角 dp
  horizontal_padding = 8, -- [int] 左右内边距 dp
  vertical_padding = 6,   -- [int] 上下内边距 dp
  button = btn {          -- [ToolBar.Button] 右侧按键，可配置任意键盘动作
    action = "Enter",     -- 点击动作，未配置时默认 Return
    long_press_action = "HideKeyboard",
    size = { 40, -1 },    -- 宽度 dp；高度始终跟随单行输入框
    foreground = fg {
      style = "ic@keyboard_return",
      normal = "text_color",
      highlight = "hilited_candidate_button_color",
      font_size = 18,
      padding = 2
    },
    background = bg {
      normal = "none",
      highlight = "hilited_candidate_button_color",
      corner_radius = 10,
      horizontal_inset = 0,
      vertical_inset = 4
    }
  }
}

return si
