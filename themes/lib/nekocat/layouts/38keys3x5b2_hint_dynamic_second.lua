-- SPDX-License-Identifier: GPL-3.0-or-later
-- LSSP 动态第二码键盘工厂（3x5b2）
-- 数据与生成逻辑见 _lssp_data / _lssp_factory

local factory = safe_require("nekocat.layouts._lssp_factory")

return factory.make_second({
  tag = "b2_",
  label = "3x5b2",
  order = { 1, 2, 4, 5, 3 },
  base = "nekocat.layouts.38keys3x5b2_hint_dynamic_first"
})
