local offset = safe_require("nekocat.font_offset").lsspdynamic

local keyboard = keyboard(merge(safe_require("nekocat.layouts.38keys3x5b1_hint"), keyboard {
  name = "鸢鸣万象·3x5b1动态键盘",
  dynamic_mode = true,
  dynamic_original = "wanxiang_yoemin",
  rows = {
    [2] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b1_bzy" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b1_pcy" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b1_msy" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b1_rf" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b1_zhz" }))
      }
    },
    [3] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b1_d" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b1_t" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b1_n" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b1_l" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b1_chc" }))
      }
    },
    [4] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b1_gj" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b1_kq" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b1_hx" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b1_wy" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b1_shs" }))
      }
    }
  }
}))

return keyboard
