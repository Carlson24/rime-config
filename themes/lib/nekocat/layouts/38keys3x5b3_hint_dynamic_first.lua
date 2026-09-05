local offset = safe_require("nekocat.font_offset").lsspdynamic

local keyboard = keyboard(merge(safe_require("nekocat.layouts.38keys3x5b3_hint"), keyboard {
  name = "鸢鸣万象·3x5b3动态键盘",
  dynamic_mode = true,
  dynamic_original = "wanxiang_yoemin",
  rows = {
    [2] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b3_zhz" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b3_bzy" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b3_pcy" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b3_msy" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b3_rf" }))
      }
    },
    [3] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b3_chc" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b3_d" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b3_t" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b3_n" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b3_l" }))
      }
    },
    [4] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b3_shs" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b3_gj" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b3_kq" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b3_hx" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b3_wy" }))
      }
    }
  }
}))

return keyboard