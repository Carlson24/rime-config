-- ========================================================================
-- 配色方案 (ColorScheme)
-- 使用 Catppuccin 调色板：Latte (亮色) + Mocha (暗色)
-- ========================================================================

local cs = {
  scheme("default", safe_require("nekocat.colors.swx_hbhh").e5),
  scheme("default_dark", safe_require("nekocat.colors.swx_hbhh").e6),
  scheme("e1", safe_require("nekocat.colors.swx_colors").e1),
  scheme("j1", safe_require("nekocat.colors.swx_lzyy").j1),
  scheme("j2", safe_require("nekocat.colors.swx_lzyy").j2),
  scheme("j3", safe_require("nekocat.colors.swx_xgsq").j3),
  scheme("j4", safe_require("nekocat.colors.swx_xgsq").j4),
  scheme("j7", safe_require("nekocat.colors.swx_fgly").j7),
  scheme("j8", safe_require("nekocat.colors.swx_fgly").j8),
  scheme("s1", safe_require("nekocat.colors.swx_sld").s1),
  scheme("s2", safe_require("nekocat.colors.swx_sld").s2),
  scheme("s3", safe_require("nekocat.colors.swx_zjsh").s3),
  scheme("s4", safe_require("nekocat.colors.swx_zjsh").s4)
}

return cs
