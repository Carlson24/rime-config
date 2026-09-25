local hint_offset = safe_require("nekocat.font_offset").auxhint_7

local keyboard = keyboard(merge(safe_require("nekocat.layouts.35keys_nonum"), keyboard {
  name = "万象小鹤 7 列",
  label_transform = "UPPERCASE",
  rows = {
    [1] = row {
      keys = {
        [1] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "\u{F801}", "\u{F802}\n" }, color = "rosewater", align = "justify" },
          { text = { "犭", "求", "丘\n" }, color = { "overlay2", "overlay2", "overlay0" }, align = "justify" },
          { text = "iu", color = "blue" }
        } })),
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "亠", "文\n" }, color = "overlay2", align = "justify" },
          { text = { " ", "夂", "攵\n" }, color = "overlay2", align = "justify" },
          { text = { "1", "ei" }, color = { "key_text_color", "blue" }, align = "justify" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "彐", "山\n" }, color = "rosewater", align = "justify" },
          { text = { "\u{F803}", "阝", "卩\n" }, color = "overlay2", align = "justify" },
          { text = { "2", "\u{F82B}", "e" }, color = { "key_text_color", "red", "blue" }, bold = { false, true, false }, align = "justify" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "田\n", color = "overlay2" },
          { text = "土\n", color = "overlay0" },
          { text = { "3", "ue", "üe" }, color = { "key_text_color", "blue", "blue" }, align = "justify" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "虫\n", color = "overlay2" },
          { text = { "彳", "亍\n" }, color = "overlay2", align = "justify" },
          { text = { "4", "ĉ", "i" }, color = { "key_text_color", "red", "blue" }, bold = { false, true, false }, align = "justify" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "日\n", color = "teal" },
          { text = { "月", "目\n" }, color = "overlay2", align = "justify" },
          { text = { "5", "\u{F82A}", "o", "uo" }, color = { "key_text_color", "red", "blue", "blue" }, bold = { false, true, false, false }, align = "justify" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "丿\n", color = "lavender" },
          { text = { "礻", "衤\n" }, color = "rosewater", align = "justify" },
          { text = "ie", color = "blue" }
        } }))
      }
    },
    [2] = row {
      keys = {
        [1] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "一\n", color = "lavender" },
          { text = { "鱼", "凹\n" }, color = { "rosewater", "overlay0" }, align = "justify" },
          { text = { "\u{F82C}", "a", "er" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "纟", "厶\n" }, color = "overlay2", align = "justify" },
          { text = { " ", "龴", "罒\n" }, color = "overlay2", align = "justify" },
          { text = "6", color = "key_text_color" }, { text = " ong iong", color = "blue" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "亻\n", color = "overlay2" },
          { text = "刃\n", color = "overlay0" },
          { text = "7", color = "key_text_color" }, { text = "  uan üan", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "𧘇", "讠\n" }, color = "overlay2", align = "justify" },
          { text = { "⺷", "⺶", "羊\n" }, color = "overlay2", align = "justify" },
          { text = { "8", "un", "ün" }, color = { "key_text_color", "blue", "blue" }, align = "justify" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "饣", "龵\n" }, color = "overlay2", align = "justify" },
          { text = { "𠂇", "氺", "石\n" }, color = "overlay2", align = "justify" },
          { text = { "9", "ŝ", "u" }, color = { "key_text_color", "red", "blue" }, bold = { false, true, false }, align = "justify" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "匚", "冂\n" }, color = "teal", align = "justify" },
          { text = { "凵", "囗", "㠯\n" }, color = { "teal", "teal", "overlay2" }, align = "justify" },
          { text = "0", color = "key_text_color" }, { text = "  uai ing", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "丨", "耂\n" }, color = { "overlay2", "lavender", "overlay2" }, align = "justify" },
          { text = { " ", "立", "龙\n" }, color = "overlay2", align = "justify" },
          { text = { "iang", "uang" }, color = "blue", align = "justify" }
        } }))
      }
    },
    [3] = row {
      keys = {
        [1] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "廴\n", color = "teal" },
          { text = { "辶", "⻊\n" }, color = { "teal", "overlay2" }, align = "justify" },
          { text = "ou", color = "blue" }
        } })),
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "丶", "⺈\n" }, color = { "overlay2", "lavender", "overlay2" }, align = "justify" },
          { text = { "冫", "氵", "刂\n" }, color = "overlay2", align = "justify" },
          { text = { "ai", "iai" }, color = "blue", align = "justify" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "\u{F804}", "\u{F805}\n" }, color = "overlay2", align = "justify" },
          { text = { "龶", "扌", "缶\n" }, color = "overlay2", align = "justify" },
          { text = "en", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "\u{F806}", "艮\n" }, color = "overlay2", align = "justify" },
          { text = { "鬼", "革", "骨\n" }, color = "overlay2", align = "justify" },
          { text = "eng", color = "blue" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "灬", "虍\n" }, color = "overlay2", align = "justify" },
          { text = { " ", "\u{F807}", "黑\n" }, color = "overlay2", align = "justify" },
          { text = "ang", color = "blue" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "龹\n", color = "overlay2" },
          { text = { "钅", "金\n" }, color = "overlay2", align = "justify" },
          { text = "an", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "朩\n", color = "overlay2" },
          { text = "木\n", color = "overlay0" },
          { text = "ian", color = "blue" }
        } }))
      }
    },
    [4] = row {
      keys = {
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "乂", "忄\n" }, color = { "overlay2", "rosewater", "overlay2" }, align = "justify" },
          { text = { "⺍", "⺌", "⺗\n" }, color = "overlay2", align = "justify" },
          { text = { "ia", "ua" }, color = "blue", align = "justify" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "艹\n", color = "overlay2" },
          { text = "廾\n", color = "overlay2" },
          { text = "ao", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "乛\n", color = "lavender" },
          { text = { "⺮", "豸\n" }, color = "overlay2", align = "justify" },
          { text = { "ẑ", "ui", "ü" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { " ", "勹", "冖\n" }, color = { "overlay2", "rosewater", "overlay2" }, align = "justify" },
          { text = { "宀", "丷", "\u{F808}", "疒\n" }, color = "overlay2", align = "justify" },
          { text = "in", color = "blue" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "乀\n", color = "lavender" },
          { text = { "⺧", "牜\n" }, color = "overlay2", align = "justify" },
          { text = "iao", color = "blue" }
        }, popup = { "FlypyIX", "N" } }))
      }
    }
  }
}))

return keyboard
