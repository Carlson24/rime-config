local latte = {
  rosewater = "0xdc8a78",
  flamingo  = "0xdd7878",
  pink      = "0xea76cb",
  mauve     = "0x8839ef",
  red       = "0xd20f39",
  maroon    = "0xe64553",
  peach     = "0xfe640b",
  yellow    = "0xdf8e1d",
  green     = "0x40a02b",
  teal      = "0x179299",
  sky       = "0x04a5e5",
  sapphire  = "0x209fb5",
  blue      = "0x1e66f5",
  lavender  = "0x7287fd",
  text      = "0x4c4f69",
  subtext1  = "0x5c5f77",
  subtext0  = "0x6c6f85",
  overlay2  = "0x7c7f93",
  overlay1  = "0x8c8fa1",
  overlay0  = "0x9ca0b0",
  surface2  = "0xacb0be",
  surface1  = "0xbcc0cc",
  surface0  = "0xccd0da",
  base      = "0xeff1f5",
  mantle    = "0xe6e9ef",
  crust     = "0xdce0e8",
  none      = "0x000000",
}

---@type SchemeColors
local scheme = {
  -- 模式切换
  light_scheme                           = "Catppuccin Latte",
  dark_scheme                            = "Catppuccin Mocha",

  -- Catppuccin 调色板键
  rosewater                              = latte.rosewater,
  flamingo                               = latte.flamingo,
  pink                                   = latte.pink,
  mauve                                  = latte.mauve,
  red                                    = latte.red,
  maroon                                 = latte.maroon,
  peach                                  = latte.peach,
  yellow                                 = latte.yellow,
  green                                  = latte.green,
  teal                                   = latte.teal,
  sky                                    = latte.sky,
  sapphire                               = latte.sapphire,
  blue                                   = latte.blue,
  lavender                               = latte.lavender,
  text                                   = latte.text,
  subtext1                               = latte.subtext1,
  subtext0                               = latte.subtext0,
  overlay2                               = latte.overlay2,
  overlay1                               = latte.overlay1,
  overlay0                               = latte.overlay0,
  surface2                               = latte.surface2,
  surface1                               = latte.surface1,
  surface0                               = latte.surface0,
  base                                   = latte.base,
  mantle                                 = latte.mantle,
  crust                                  = latte.crust,
  none                                   = latte.none,

  -- 基础色
  back_color                             = latte.base,
  text_color                             = latte.text,
  border_color                           = latte.teal,

  -- 候选区
  candidate_text_color                   = latte.text,
  candidate_background                   = latte.base,
  comment_text_color                     = latte.maroon,
  hilited_candidate_text_color           = latte.red,
  hilited_candidate_back_color           = latte.none,
  hilited_candidate_button_color         = latte.none,
  hilited_comment_text_color             = latte.red,
  hilited_label_color                    = latte.blue,
  hilited_text_color                     = latte.maroon,
  hilited_back_color                     = latte.base,
  label_color                            = latte.blue,
  candidate_border_color                 = latte.sky,
  candidate_separator_color              = latte.sky,

  -- 预编辑
  text_back_color                        = latte.base,

  -- 按键
  key_back_color                         = latte.base,
  key_border_color                       = latte.surface2,
  key_text_color                         = latte.text,
  key_symbol_color                       = latte.text,
  hilited_key_back_color                 = latte.surface2,
  hilited_key_text_color                 = latte.text,
  hilited_key_symbol_color               = latte.text,
  off_key_back_color                     = latte.surface2,
  off_key_text_color                     = latte.text,
  off_key_symbol_color                   = latte.text,
  on_key_back_color                      = latte.surface2,
  on_key_text_color                      = latte.maroon,
  on_key_symbol_color                    = latte.maroon,
  hilited_off_key_back_color             = latte.base,
  hilited_off_key_text_color             = latte.text,
  hilited_off_key_symbol_color           = latte.text,
  hilited_on_key_back_color              = latte.base,
  hilited_on_key_text_color              = latte.maroon,
  hilited_on_key_symbol_color            = latte.maroon,

  -- 弹出气泡
  popup_back_color                       = latte.base,
  popup_text_color                       = latte.text,
  hilited_popup_back_color               = latte.lavender,
  hilited_popup_text_color               = latte.base,

  -- 键盘
  keyboard_back_color                    = latte.mantle,
  keyboard_background                    = latte.mantle,
  liquid_keyboard_background             = latte.mantle,
  shadow_color                           = latte.text,
  root_background                        = latte.base,

  -- 长文本
  long_text_color                        = latte.text,
  long_text_back_color                   = latte.base,

  -- T9 侧栏
  t9_side_back_color                     = latte.surface2,
  t9_side_hilited_back_color             = latte.base,
  t9_side_text_color                     = latte.text,
  t9_side_border_color                   = latte.surface2,
  t9_side_spacing_color                  = latte.overlay0,

  -- 剪贴板
  clipboard_category_back_color          = latte.base,
  clipboard_category_selected_back_color = latte.surface2,
  clipboard_category_selected_text_color = latte.text,
  clipboard_entry_back_color             = latte.base,
  clipboard_checkbox_color               = latte.surface2,
  hilited_clipboard_entry_back_color     = latte.surface2,
}

return scheme
