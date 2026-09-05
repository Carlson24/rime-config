-- ========================================================================
-- 工具栏 (ToolBar)
-- ========================================================================

local function fg(style)
  local f = { font_size = 18, padding = 2, normal = "text_color" }
  if type(style) == "table" then
    f.option_styles = style
  else
    f.style = style
  end
  return f
end

local function make_button(action, style)
  return { action = action, foreground = fg(style) }
end

local tb = toolbar {
  button_font = { "LXGW975YuanSC-400W.ttf" },
  back_style = "ic@chevron-triple-left",
  primary_button = {
    action = "KeyboardSettings",
    background = {
      type = "circle",
      corner_radius = 10,
      highlight = "hilited_candidate_button_color",
      normal = "none",
      vertical_inset = 4,
      horizontal_inset = 0
    },
    foreground = fg("ic@cogs")
  },
  buttons = {
    make_button("HideKeyboard", "ic@keyboard-close"),
    make_button("VoiceSwitch", { "ic@microphone", "ic@stop-circle" }),
    make_button("WindowClipboard", "ic@clipboard-list-outline"),
    make_button("Redo", "ic@rotate-right"),
    make_button("KeyboardEditor", "ic@cursor-move"),
    make_button("Undo", "ic@rotate-left"),
    make_button("FloatingSwitch", { "ic@dock-window", "ic@keyboard-outline" }),
    make_button("KeyboardLayouts", "ic@keyboard-variant")
  }
}

return tb
