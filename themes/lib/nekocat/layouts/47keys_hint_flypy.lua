local hint_offset = safe_require("nekocat.font_offset").auxhint

local keyboard = keyboard(merge(safe_require("nekocat.layouts.47keys"), keyboard {
  name = "万象小鹤",
  label_transform = "UPPERCASE",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [1] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "\u{F801}", "\u{F802}\n" }, color = "rosewater", align = "justify" },
          { text = { "犭", "求\n" }, color = "overlay2", align = "justify" },
          { text = "iu", color = "blue" }
        } })),
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "亠", "文\n" }, color = "overlay2", align = "justify" },
          { text = { "夂", "攵\n" }, color = "overlay2", align = "justify" },
          { text = "ei", color = "blue" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "彐", "山\n" }, color = "rosewater", align = "justify" },
          { text = { "\u{F803}", "阝", "卩\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82E}", "e" }, color = { "red", "blue" }, bold = { true, false }, align = "justify" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "亻\n", color = "overlay2" },
          { text = "刃\n", color = "overlay0" },
          { text = "[uü]an", color = "blue" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "田\n", color = "overlay2" },
          { text = "土\n", color = "overlay0" },
          { text = "[uü]e", color = "blue" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "\u{F809}", "讠\n" }, color = "overlay2", align = "justify" },
          { text = { "⺷", "⺶", "羊\n" }, color = "overlay2", align = "justify" },
          { text = "[uü]n", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "饣", "龵\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F80A}", "氺", "石\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82C}", "u" }, color = { "red", "blue" }, bold = { true, false }, align = "justify" }
        } })),
        [8] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "虫\n", color = "overlay2" },
          { text = { "彳", "亍\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82B}", "i" }, color = { "red", "blue" }, bold = { true, false }, align = "justify" }
        } })),
        [9] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "日\n", color = "teal" },
          { text = { "月", "目\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82D}", "u?o" }, color = { "red", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [10] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "丿\n", color = "lavender" },
          { text = { "礻", "衤\n" }, color = "rosewater", align = "justify" },
          { text = "ie", color = "blue" }
        } }))
      }
    },
    [3] = row {
      keys = {
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "一\n", color = "lavender" },
          { text = { "鱼", "凹\n" }, color = { "rosewater", "overlay0" }, align = "justify" },
          { text = { "\u{F82F}", "a", "er" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "纟", "厶\n" }, color = "overlay2", align = "justify" },
          { text = { "龴", "罒\n" }, color = "overlay2", align = "justify" },
          { text = "i?ong", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "丶", "⺈\n" }, color = { "lavender", "overlay2" }, align = "justify" },
          { text = { "冫", "氵", "刂\n" }, color = "overlay2", align = "justify" },
          { text = "i?ai", color = "blue" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "\u{F804}", "\u{F805}\n" }, color = "overlay2", align = "justify" },
          { text = { "龶", "扌", "缶\n" }, color = "overlay2", align = "justify" },
          { text = "en", color = "blue" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "\u{F806}", "艮\n" }, color = "overlay2", align = "justify" },
          { text = { "鬼", "革", "骨\n" }, color = "overlay2", align = "justify" },
          { text = "eng", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "灬", "虍\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F807}", "黑\n" }, color = "overlay2", align = "justify" },
          { text = "ang", color = "blue" }
        } })),
        [8] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "龹\n", color = "overlay2" },
          { text = { "钅", "金\n" }, color = "overlay2", align = "justify" },
          { text = "an", color = "blue" }
        } })),
        [9] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "匚", "冂\n" }, color = "teal", align = "justify" },
          { text = { "凵", "囗", "㠯\n" }, color = { "teal", "teal", "overlay2" }, align = "justify" },
          { text = "uai ing", color = "blue" }
        } })),
        [10] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "丨", "耂\n" }, color = { "lavender", "overlay2" }, align = "justify" },
          { text = { "立", "龙\n" }, color = "overlay2", align = "justify" },
          { text = "[iu]ang", color = "blue" }
        } }))
      }
    },
    [4] = row {
      keys = {
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "廴\n", color = "teal" },
          { text = { "辶", "⻊\n" }, color = { "teal", "overlay2" }, align = "justify" },
          { text = "ou", color = "blue" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "乂", "忄\n" }, color = { "rosewater", "overlay2" }, align = "justify" },
          { text = { "⺍", "⺌", "⺗\n" }, color = "overlay2", align = "justify" },
          { text = "[iu]a", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "艹\n", color = "overlay2" },
          { text = "廾\n", color = "overlay2" },
          { text = "ao", color = "blue" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "𪛙\n", color = "lavender" },
          { text = { "⺮", "豸\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82A}", "ui", "ü" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "勹", "冖", "宀\n" }, color = { "rosewater", "overlay2", "overlay2" }, align = "justify" },
          { text = { "丷", "\u{F808}", "疒\n" }, color = "overlay2", align = "justify" },
          { text = "in", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "乀\n", color = "lavender" },
          { text = { "⺧", "牜\n" }, color = "overlay2", align = "justify" },
          { text = "iao", color = "blue" }
        } })),
        [8] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = "朩\n", color = "overlay2" },
          { text = "木\n", color = "overlay0" },
          { text = "ian", color = "blue" }
        } }))
      }
    }
  }
}))

return keyboard
