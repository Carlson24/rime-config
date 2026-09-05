-- 用于微调不同字体设计差异导致的问题
-- 也用于微调多布局字号差异

local M = {}

M.auxhint = key {
  key_text_offset_y = -4,
  key_text_size = 18
}

M.lsspdynamic = key {
  key_symbol_offset_y = -1,
  key_hint_offset_y = 1
}

M.num_key_symbol_offset_y = -1
M.num_key_text_offset_y = 2
M.func_key_text_size = 23
M.lssp_key_text_size = 21
M.lssp_func_key_text_size = 20

return M
