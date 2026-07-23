local ST = {}

ST.offset = keyboard {
  key_symbol_offset_x = 0,
  key_symbol_offset_y = 3,
  key_text_offset_y = 0,
  key_hint_offset_y = -3,
  key_press_offset_y = 2
}

ST.off_key = key {
  key_back_color = "off_key_back_color",
  key_text_color = "off_key_text_color",
  key_symbol_color = "off_key_symbol_color",
  hilited_key_back_color = "hilited_off_key_back_color",
  hilited_key_text_color = "hilited_off_key_text_color",
  hilited_key_symbol_color = "hilited_off_key_symbol_color"
}

ST.func = key(merge(ST.off_key, {
  key_text_size = 23,
  symbol_text_size = 8,
  key_text_offset_y = -1,
  key_text_color = "fix_key_text_color",
  key_symbol_color = "fix_key_symbol_color"
}))

ST.number = key(merge(ST.off_key, {
  key_text_size = 20,
  symbol_text_size = 8.5,
  key_text_offset_y = 4,
  key_symbol_offset_y = -0.5,
}))

ST.qwert = key {
  key_back_color = "base",
  key_border_color = "surface1",
  hilited_key_back_color = "surface1"
}

ST.asdfg = key {
  key_back_color = "mantle",
  key_border_color = "surface2",
  hilited_key_back_color = "surface2"
}

ST.zxcvb = key {
  key_back_color = "crust",
  key_border_color = "surface2",
  hilited_key_back_color = "surface2"
}

ST.shift = key(merge(ST.func, {
  key_back_color = "sapphire",
  key_border_color = "sapphire",
  hilited_key_back_color = "teal"
}))

ST.backspace = key(merge(ST.func, {
  key_back_color = "pink",
  key_border_color = "pink",
  hilited_key_back_color = "flamingo"
}))

ST.symbol = key(merge(ST.func, {
  key_back_color = "sky",
  key_border_color = "sky",
  hilited_key_back_color = "blue"
}))

ST.punct = key(merge(ST.func, {
  key_back_color = "rosewater",
  key_border_color = "rosewater",
  hilited_key_back_color = "peach"
}))

ST.switch = key(merge(ST.func, {
  key_back_color = "sapphire",
  key_border_color = "sapphire",
  hilited_key_back_color = "teal"
}))

ST.enter = key(merge(ST.func, {
  key_back_color = "lavender",
  key_border_color = "lavender",
  hilited_key_back_color = "overlay2"
}))

ST.menu = key {
  key_text_size = 40,
  symbol_text_size = 12,
  key_back_color = "keyboard_background",
  key_border_color = "keyboard_background"
}

return ST
