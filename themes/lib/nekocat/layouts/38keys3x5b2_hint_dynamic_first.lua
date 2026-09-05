local offset = safe_require("nekocat.font_offset").lsspdynamic

local keyboard = keyboard(merge(safe_require("nekocat.layouts.38keys3x5b2_hint"), keyboard {
  name = "鸢鸣万象·3x5b2动态键盘",
  dynamic_mode = true,
  dynamic_original = "wanxiang_yoemin",
  rows = {
    [2] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b2_bzy" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b2_pcy" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b2_zhz" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b2_msy" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b2_rf" }))
      }
    },
    [3] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b2_d" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b2_t" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b2_chc" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b2_n" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b2_l" }))
      }
    },
    [4] = {
      keys = {
        [2] = key(merge(offset, key { dynamic = "lssp_two_b2_gj" })),
        [3] = key(merge(offset, key { dynamic = "lssp_two_b2_kq" })),
        [4] = key(merge(offset, key { dynamic = "lssp_two_b2_shs" })),
        [5] = key(merge(offset, key { dynamic = "lssp_two_b2_hx" })),
        [6] = key(merge(offset, key { dynamic = "lssp_two_b2_wy" }))
      }
    }
  }
}))

return keyboard
