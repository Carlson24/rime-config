local mocha = {
  rosewater = "0xf5e0dc",
  flamingo  = "0xf2cdcd",
  pink      = "0xf5c2e7",
  mauve     = "0xcba6f7",
  red       = "0xf38ba8",
  maroon    = "0xeba0ac",
  peach     = "0xfab387",
  yellow    = "0xf9e2af",
  green     = "0xa6e3a1",
  teal      = "0x94e2d5",
  sky       = "0x89dceb",
  sapphire  = "0x74c7ec",
  blue      = "0x89b4fa",
  lavender  = "0xb4befe",
  text      = "0xcdd6f4",
  subtext1  = "0xbac2de",
  subtext0  = "0xa6adc8",
  overlay2  = "0x9399b2",
  overlay1  = "0x7f849c",
  overlay0  = "0x6c7086",
  surface2  = "0x585b70",
  surface1  = "0x45475a",
  surface0  = "0x313244",
  base      = "0x1e1e2e",
  mantle    = "0x181825",
  crust     = "0x11111b",
  none      = "0x000000"
}

---@type SchemeColors
local scheme = {
  -- 模式切换
  light_scheme                           = "Catppuccin Latte",
  dark_scheme                            = "Catppuccin Mocha",

  -- Catppuccin 调色板键
  rosewater                              = mocha.rosewater,
  flamingo                               = mocha.flamingo,
  pink                                   = mocha.pink,
  mauve                                  = mocha.mauve,
  red                                    = mocha.red,
  maroon                                 = mocha.maroon,
  peach                                  = mocha.peach,
  yellow                                 = mocha.yellow,
  green                                  = mocha.green,
  teal                                   = mocha.teal,
  sky                                    = mocha.sky,
  sapphire                               = mocha.sapphire,
  blue                                   = mocha.blue,
  lavender                               = mocha.lavender,
  text                                   = mocha.text,
  subtext1                               = mocha.subtext1,
  subtext0                               = mocha.subtext0,
  overlay2                               = mocha.overlay2,
  overlay1                               = mocha.overlay1,
  overlay0                               = mocha.overlay0,
  surface2                               = mocha.surface2,
  surface1                               = mocha.surface1,
  surface0                               = mocha.surface0,
  base                                   = mocha.base,
  mantle                                 = mocha.mantle,
  crust                                  = mocha.crust,
  none                                   = mocha.none,

  -- 基础色
  back_color                             = mocha.base,
  text_color                             = mocha.text,
  border_color                           = mocha.teal,

  -- 候选区
  candidate_text_color                   = mocha.text,
  candidate_background                   = mocha.base,
  comment_text_color                     = mocha.maroon,
  hilited_candidate_text_color           = mocha.red,
  hilited_candidate_back_color           = mocha.none,
  hilited_candidate_button_color         = mocha.none,
  hilited_comment_text_color             = mocha.red,
  hilited_label_color                    = mocha.blue,
  hilited_text_color                     = mocha.maroon,
  hilited_back_color                     = mocha.base,
  label_color                            = mocha.blue,
  candidate_border_color                 = mocha.sky,
  candidate_separator_color              = mocha.sky,

  -- 预编辑
  text_back_color                        = mocha.base,

  -- 按键
  key_back_color                         = mocha.base,
  key_border_color                       = mocha.surface2,
  key_text_color                         = mocha.text,
  key_symbol_color                       = mocha.text,
  hilited_key_back_color                 = mocha.surface2,
  hilited_key_text_color                 = mocha.text,
  hilited_key_symbol_color               = mocha.text,
  off_key_back_color                     = mocha.surface2,
  off_key_text_color                     = mocha.text,
  off_key_symbol_color                   = mocha.text,
  on_key_back_color                      = mocha.surface2,
  on_key_text_color                      = mocha.maroon,
  on_key_symbol_color                    = mocha.maroon,
  hilited_off_key_back_color             = mocha.base,
  hilited_off_key_text_color             = mocha.text,
  hilited_off_key_symbol_color           = mocha.text,
  hilited_on_key_back_color              = mocha.base,
  hilited_on_key_text_color              = mocha.maroon,
  hilited_on_key_symbol_color            = mocha.maroon,

  -- 弹出气泡
  popup_back_color                       = mocha.base,
  popup_text_color                       = mocha.text,
  hilited_popup_back_color               = mocha.lavender,
  hilited_popup_text_color               = mocha.base,

  -- 键盘
  keyboard_back_color                    = mocha.mantle,
  keyboard_background                    = mocha.mantle,
  liquid_keyboard_background             = mocha.mantle,
  shadow_color                           = mocha.text,
  root_background                        = mocha.base,

  -- 长文本
  long_text_color                        = mocha.text,
  long_text_back_color                   = mocha.base,

  -- T9 侧栏
  t9_side_back_color                     = mocha.surface2,
  t9_side_hilited_back_color             = mocha.base,
  t9_side_text_color                     = mocha.text,
  t9_side_border_color                   = mocha.surface2,
  t9_side_spacing_color                  = mocha.overlay0,

  -- 剪贴板
  clipboard_category_back_color          = mocha.base,
  clipboard_category_selected_back_color = mocha.surface2,
  clipboard_category_selected_text_color = mocha.text,
  clipboard_entry_back_color             = mocha.base,
  clipboard_checkbox_color               = mocha.surface2,
  hilited_clipboard_entry_back_color     = mocha.surface2,

  -- 自定义配色
  fix_key_text_color                     = mocha.base,
  fix_key_symbol_color                   = mocha.base
}

return scheme
