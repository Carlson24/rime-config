local frappe = {
  rosewater = "0xf2d5cf",
  flamingo  = "0xeebebe",
  pink      = "0xf4b8e4",
  mauve     = "0xca9ee6",
  red       = "0xe78284",
  maroon    = "0xea999c",
  peach     = "0xef9f76",
  yellow    = "0xe5c890",
  green     = "0xa6d189",
  teal      = "0x81c8be",
  sky       = "0x99d1db",
  sapphire  = "0x85c1dc",
  blue      = "0x8caaee",
  lavender  = "0xbabbf1",
  text      = "0xc6d0f5",
  subtext1  = "0xb5bfe2",
  subtext0  = "0xa5adce",
  overlay2  = "0x949cbb",
  overlay1  = "0x838ba7",
  overlay0  = "0x737994",
  surface2  = "0x626880",
  surface1  = "0x51576d",
  surface0  = "0x414559",
  base      = "0x303446",
  mantle    = "0x292c3c",
  crust     = "0x232634",
  none      = "0x000000"
}

---@type SchemeColors
local scheme = {
  -- 模式切换
  light_scheme                           = "Catppuccin Latte",
  dark_scheme                            = "Catppuccin Frappe",

  -- Catppuccin 调色板键
  rosewater                              = frappe.rosewater,
  flamingo                               = frappe.flamingo,
  pink                                   = frappe.pink,
  mauve                                  = frappe.mauve,
  red                                    = frappe.red,
  maroon                                 = frappe.maroon,
  peach                                  = frappe.peach,
  yellow                                 = frappe.yellow,
  green                                  = frappe.green,
  teal                                   = frappe.teal,
  sky                                    = frappe.sky,
  sapphire                               = frappe.sapphire,
  blue                                   = frappe.blue,
  lavender                               = frappe.lavender,
  text                                   = frappe.text,
  subtext1                               = frappe.subtext1,
  subtext0                               = frappe.subtext0,
  overlay2                               = frappe.overlay2,
  overlay1                               = frappe.overlay1,
  overlay0                               = frappe.overlay0,
  surface2                               = frappe.surface2,
  surface1                               = frappe.surface1,
  surface0                               = frappe.surface0,
  base                                   = frappe.base,
  mantle                                 = frappe.mantle,
  crust                                  = frappe.crust,
  none                                   = frappe.none,

  -- 基础色
  back_color                             = frappe.base,
  text_color                             = frappe.text,
  border_color                           = frappe.teal,

  -- 候选区
  candidate_text_color                   = frappe.text,
  candidate_background                   = frappe.base,
  comment_text_color                     = frappe.maroon,
  hilited_candidate_text_color           = frappe.red,
  hilited_candidate_back_color           = frappe.none,
  hilited_candidate_button_color         = frappe.none,
  hilited_comment_text_color             = frappe.red,
  hilited_label_color                    = frappe.blue,
  hilited_text_color                     = frappe.maroon,
  hilited_back_color                     = frappe.base,
  label_color                            = frappe.blue,
  candidate_border_color                 = frappe.sky,
  candidate_separator_color              = frappe.sky,

  -- 预编辑
  text_back_color                        = frappe.base,

  -- 按键
  key_back_color                         = frappe.base,
  key_border_color                       = frappe.surface2,
  key_text_color                         = frappe.text,
  key_symbol_color                       = frappe.text,
  hilited_key_back_color                 = frappe.surface2,
  hilited_key_text_color                 = frappe.text,
  hilited_key_symbol_color               = frappe.text,
  off_key_back_color                     = frappe.surface2,
  off_key_text_color                     = frappe.text,
  off_key_symbol_color                   = frappe.text,
  on_key_back_color                      = frappe.surface2,
  on_key_text_color                      = frappe.maroon,
  on_key_symbol_color                    = frappe.maroon,
  hilited_off_key_back_color             = frappe.base,
  hilited_off_key_text_color             = frappe.text,
  hilited_off_key_symbol_color           = frappe.text,
  hilited_on_key_back_color              = frappe.base,
  hilited_on_key_text_color              = frappe.maroon,
  hilited_on_key_symbol_color            = frappe.maroon,

  -- 弹出气泡
  popup_back_color                       = frappe.base,
  popup_text_color                       = frappe.text,
  hilited_popup_back_color               = frappe.lavender,
  hilited_popup_text_color               = frappe.base,

  -- 键盘
  keyboard_back_color                    = frappe.mantle,
  keyboard_background                    = frappe.mantle,
  liquid_keyboard_background             = frappe.mantle,
  shadow_color                           = frappe.text,
  root_background                        = frappe.base,

  -- 长文本
  long_text_color                        = frappe.text,
  long_text_back_color                   = frappe.base,

  -- T9 侧栏
  t9_side_back_color                     = frappe.surface2,
  t9_side_hilited_back_color             = frappe.base,
  t9_side_text_color                     = frappe.text,
  t9_side_border_color                   = frappe.surface2,
  t9_side_spacing_color                  = frappe.overlay0,

  -- 剪贴板
  clipboard_category_back_color          = frappe.base,
  clipboard_category_selected_back_color = frappe.surface2,
  clipboard_category_selected_text_color = frappe.text,
  clipboard_entry_back_color             = frappe.base,
  clipboard_checkbox_color               = frappe.surface2,
  hilited_clipboard_entry_back_color     = frappe.surface2,
}

return scheme
