-- SPDX-License-Identifier: GPL-3.0-or-later
-- LSSP 动态第二码 / 第三码键盘工厂（共享逻辑）
-- 3x5b1 / 3x5b2 共用同一份拼音数据 _lssp_data，
-- 由 variant 参数决定命名前缀、列序、显示名与基础模板。
-- variant = { tag, label, order, base }
--   tag   命名前缀标记，如 "" / "b2_"
--   label 显示名变体，如 "3x5b1" / "3x5b2"
--   order 每行 5 键的列序映射（b1 恒等 {1,2,3,4,5}，b2 {1,2,4,5,3}）
--   base  基础动态键盘模块名（如 nekocat.layouts.38keys3x5b1_hint_dynamic_first）

local DATA = safe_require("nekocat.layouts._lssp_data")

local function make_second(variant)
  local tag = variant.tag
  local order = variant.order
  local prefix = "lssp_three_" .. tag
  local label = variant.label
  local base = variant.base

  local function make_cell(data)
    if data == false then
      return key { label = { { color = "overlay1" } } }
    end
    return key { dynamic = prefix .. data.d, label = { { text = data.t } } }
  end

  local default_rows = {
    { "default_aanang",    "default_aieiao",  "default_oouong",   "default_eeneng",  "default_ervan" },
    { "default_iaianiang", "default_iaiiiao", "default_ioiuiong", "default_ieining", "default_v" },
    { "default_uauanuang", "default_uaiui",   "default_uou",      "default_unueng",  "default_vevn" }
  }
  local template_rows = {}
  for ri, row_defaults in ipairs(default_rows) do
    local keys = {}
    for ci, df in ipairs(row_defaults) do
      keys[order[ci] + 1] = key { label = { { text = "∅" } }, key_text_size = 13, dynamic = prefix .. df }
    end
    template_rows[ri + 1] = { keys = keys }
  end

  local template = keyboard(merge(safe_require(base), keyboard {
    name = "鸢鸣万象·" .. label .. "动态第二码模板",
    rows = template_rows
  }))

  local function make(name_suffix, rows_data)
    local rows = {}
    for idx, row_cells in ipairs(rows_data) do
      local keys = {}
      for ci, cd in ipairs(row_cells) do
        keys[order[ci] + 1] = make_cell(cd)
      end
      rows[idx + 1] = { keys = keys }
    end
    return keyboard(merge(template, keyboard {
      name = "鸢鸣万象·" .. label .. "动态第二码" .. name_suffix,
      rows = rows
    }))
  end

  local result = {}
  for n, e in pairs(DATA.SECOND_CODE_DATA) do
    result["lssp_two_" .. tag .. n] = make(n, e)
  end
  return result
end

local function make_third(variant)
  local tag = variant.tag
  local order = variant.order
  local prefix = "lssp_three_" .. tag
  local label = variant.label
  local base = variant.base

  local function make_key_text(val)
    if val then
      return key { label = { { text = val } } }
    else
      return key { label = { { color = "overlay1" } } }
    end
  end

  local function make_row(cells)
    local keys = {}
    for i, v in ipairs(cells) do
      keys[order[i] + 1] = make_key_text(v)
    end
    return { keys = keys }
  end

  local function make_original_key()
    return key { label = { { text = "∅" } }, key_text_size = 18, dynamic = ".original" }
  end

  local function make_original_row()
    return { keys = { [2] = make_original_key(), [3] = make_original_key(), [4] = make_original_key(), [5] = make_original_key(), [6] = make_original_key() } }
  end

  local template = keyboard(merge(safe_require(base), keyboard {
    name = "鸢鸣万象·" .. label .. "动态第三码模板",
    rows = {
      [2] = make_original_row(),
      [3] = make_original_row(),
      [4] = make_original_row()
    }
  }))

  local function make(name_suffix, rows_data)
    local rows = {}
    for idx, cells in ipairs(rows_data) do
      rows[idx + 1] = make_row(cells)
    end
    return keyboard(merge(template, keyboard {
      name = "鸢鸣万象·" .. label .. "动态第三码" .. name_suffix,
      rows = rows
    }))
  end

  local result = {}
  for key, rows_data in pairs(DATA.TONE_DATA) do
    result[prefix .. key] = make(key, rows_data)
  end
  return result
end

return {
  make_second = make_second,
  make_third = make_third
}
