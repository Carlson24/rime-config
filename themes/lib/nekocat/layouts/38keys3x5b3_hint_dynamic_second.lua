-- SPDX-License-Identifier: GPL-3.0-or-later
-- LSSP 动态第二码键盘工厂（3x5b3）
-- 数据与生成逻辑见 _lssp_data / _lssp_factory

local factory = safe_require("nekocat.layouts._lssp_factory")

return factory.make_second({
  tag = "b3_",
  label = "3x5b3",
  order = { 2, 3, 4, 5, 1 },
  base = "nekocat.layouts.38keys3x5b3_hint_dynamic_first"
})