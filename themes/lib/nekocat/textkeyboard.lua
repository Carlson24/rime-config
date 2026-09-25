-- ========================================================================
-- 预设键盘布局 (TextKeyboard)
-- ========================================================================

---@type { [string]: TextKeyboard }
local tk = {
  default               = safe_require("nekocat.layouts.47keys"),
  calculator            = safe_require("nekocat.layouts.calculator"),
  editor                = safe_require("nekocat.layouts.editor"),
  number                = safe_require("nekocat.layouts.number"),
  settings              = safe_require("nekocat.layouts.settings"),
  wanxiang_pro          = safe_require("nekocat.layouts.47keys_hint_flypy"),
  wanxiang_flypy        = safe_require("nekocat.layouts.35keys_nonum_hint_flypy"),
  wanxiang_flypy_18keys = safe_require("nekocat.layouts.37keys_hint_flypy"),
  wanxiang_flypy_14keys = safe_require("nekocat.layouts.35keys_hint_flypy"),
  wanxiang_l17keys      = safe_require("nekocat.layouts.36keys_hint"),
  wanxiang_t9           = safe_require("nekocat.layouts.17keys"),
  triple_pinyin_lssp    = safe_require("nekocat.layouts.38keys3x5b1_hint"),
  wanxiang_yoemin       = safe_require("nekocat.layouts.38keys3x5b1_hint_dynamic_first"),
  wanxiang_english      = merge(safe_require("nekocat.layouts.47keys"), keyboard { name = "万象英文" }),
  t9_number             = merge(safe_require("nekocat.layouts.number"), keyboard { ascii_mode = true }),
  english               = merge(safe_require("nekocat.layouts.47keys"),
    keyboard { name = "英文布局", ascii_mode = true, rows = { [5] = { keys = { [6] = key { click = "KeyboardDefault" } } } } })
}

-- 李氏三拼 3x5b1 动态第二码: 15 个键盘由工厂模块数据驱动生成
local lssp_two_b1 = safe_require("nekocat.layouts.38keys3x5b1_hint_dynamic_second")
for k, v in pairs(lssp_two_b1) do
  tk[k] = v
end

-- 李氏三拼 3x5b1 动态第三码: 全部 207 个键盘由工厂模块数据驱动生成
local third_b1 = safe_require("nekocat.layouts.38keys3x5b1_hint_dynamic_third")
for k, v in pairs(third_b1) do
  tk[k] = v
end

return tk
