local macchiato = {
  rosewater = "0xf4dbd6",
  flamingo  = "0xf0c6c6",
  pink      = "0xf5bde6",
  mauve     = "0xc6a0f6",
  red       = "0xed8796",
  maroon    = "0xee99a0",
  peach     = "0xf5a97f",
  yellow    = "0xeed49f",
  green     = "0xa6da95",
  teal      = "0x8bd5ca",
  sky       = "0x91d7e3",
  sapphire  = "0x7dc4e4",
  blue      = "0x8aadf4",
  lavender  = "0xb7bdf8",
  text      = "0xcad3f5",
  subtext1  = "0xb8c0e0",
  subtext0  = "0xa5adcb",
  overlay2  = "0x939ab7",
  overlay1  = "0x8087a2",
  overlay0  = "0x6e738d",
  surface2  = "0x5b6078",
  surface1  = "0x494d64",
  surface0  = "0x363a4f",
  base      = "0x24273a",
  mantle    = "0x1e2030",
  crust     = "0x181926",
  none      = "0x000000"
}

---@type SchemeColors
local scheme = {
  -- 模式切换
  light_scheme                           = "Catppuccin Latte",
  dark_scheme                            = "Catppuccin Macchiato",

  -- Catppuccin 调色板键
  rosewater                              = macchiato.rosewater,
  flamingo                               = macchiato.flamingo,
  pink                                   = macchiato.pink,
  mauve                                  = macchiato.mauve,
  red                                    = macchiato.red,
  maroon                                 = macchiato.maroon,
  peach                                  = macchiato.peach,
  yellow                                 = macchiato.yellow,
  green                                  = macchiato.green,
  teal                                   = macchiato.teal,
  sky                                    = macchiato.sky,
  sapphire                               = macchiato.sapphire,
  blue                                   = macchiato.blue,
  lavender                               = macchiato.lavender,
  text                                   = macchiato.text,
  subtext1                               = macchiato.subtext1,
  subtext0                               = macchiato.subtext0,
  overlay2                               = macchiato.overlay2,
  overlay1                               = macchiato.overlay1,
  overlay0                               = macchiato.overlay0,
  surface2                               = macchiato.surface2,
  surface1                               = macchiato.surface1,
  surface0                               = macchiato.surface0,
  base                                   = macchiato.base,
  mantle                                 = macchiato.mantle,
  crust                                  = macchiato.crust,
  none                                   = macchiato.none,

  -- 基础色
  back_color                             = macchiato.base,
  text_color                             = macchiato.text,
  border_color                           = macchiato.teal,

  -- 候选区
  candidate_text_color                   = macchiato.text,
  candidate_background                   = macchiato.base,
  comment_text_color                     = macchiato.maroon,
  hilited_candidate_text_color           = macchiato.red,
  hilited_candidate_back_color           = macchiato.none,
  hilited_candidate_button_color         = macchiato.none,
  hilited_comment_text_color             = macchiato.red,
  hilited_label_color                    = macchiato.blue,
  hilited_text_color                     = macchiato.maroon,
  hilited_back_color                     = macchiato.base,
  label_color                            = macchiato.blue,
  candidate_border_color                 = macchiato.sky,
  candidate_separator_color              = macchiato.sky,

  -- 预编辑
  text_back_color                        = macchiato.base,

  -- 按键
  key_back_color                         = macchiato.base,
  key_border_color                       = macchiato.surface2,
  key_text_color                         = macchiato.text,
  key_symbol_color                       = macchiato.text,
  hilited_key_back_color                 = macchiato.surface2,
  hilited_key_text_color                 = macchiato.text,
  hilited_key_symbol_color               = macchiato.text,
  off_key_back_color                     = macchiato.surface2,
  off_key_text_color                     = macchiato.text,
  off_key_symbol_color                   = macchiato.text,
  on_key_back_color                      = macchiato.surface2,
  on_key_text_color                      = macchiato.maroon,
  on_key_symbol_color                    = macchiato.maroon,
  hilited_off_key_back_color             = macchiato.base,
  hilited_off_key_text_color             = macchiato.text,
  hilited_off_key_symbol_color           = macchiato.text,
  hilited_on_key_back_color              = macchiato.base,
  hilited_on_key_text_color              = macchiato.maroon,
  hilited_on_key_symbol_color            = macchiato.maroon,

  -- 弹出气泡
  popup_back_color                       = macchiato.base,
  popup_text_color                       = macchiato.text,
  hilited_popup_back_color               = macchiato.lavender,
  hilited_popup_text_color               = macchiato.base,

  -- 键盘
  keyboard_back_color                    = macchiato.mantle,
  keyboard_background                    = macchiato.mantle,
  liquid_keyboard_background             = macchiato.mantle,
  shadow_color                           = macchiato.text,
  root_background                        = macchiato.base,

  -- 长文本
  long_text_color                        = macchiato.text,
  long_text_back_color                   = macchiato.base,

  -- T9 侧栏
  t9_side_back_color                     = macchiato.surface2,
  t9_side_hilited_back_color             = macchiato.base,
  t9_side_text_color                     = macchiato.text,
  t9_side_border_color                   = macchiato.surface2,
  t9_side_spacing_color                  = macchiato.overlay0,

  -- 剪贴板
  clipboard_category_back_color          = macchiato.base,
  clipboard_category_selected_back_color = macchiato.surface2,
  clipboard_category_selected_text_color = macchiato.text,
  clipboard_entry_back_color             = macchiato.base,
  clipboard_checkbox_color               = macchiato.surface2,
  hilited_clipboard_entry_back_color     = macchiato.surface2,

  -- 自定义配色
  fix_key_text_color                     = macchiato.base,
  fix_key_symbol_color                   = macchiato.base
}

return scheme
