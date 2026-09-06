local font_offset = safe_require("nekocat.font_offset")
local hint_offset = font_offset.auxhint

local keyboard = keyboard(merge(safe_require("nekocat.layouts.47keys"), keyboard {
  name = "自然万象",
  label_transform = "UPPERCASE",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [1] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "䒑", "犭", "丌\n" }, color = { "rosewater", "rosewater", "overlay2" }, align = "justify" },
          { text = { "欠", "气", "且\n" }, color = "overlay2", align = "justify" },
          { text = "iu", color = "blue" }
        } })),
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "亠", "夂", "夊\n" }, color = "rosewater", align = "justify" },
          { text = { "攵", "瓦", "王\n" }, color = { "rosewater", "overlay2", "overlay2" }, align = "justify" },
          { text = "[iu]a", color = "blue" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "阝", "卩", "二\n" }, color = { "rosewater", "rosewater", "overlay2" }, align = "justify" },
          { text = { "而", "儿", "耳\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82E}", "e" }, color = { "red", "blue" }, bold = { true, false }, align = "justify" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "亻", "人", "入\n" }, color = "rosewater", align = "justify" },
          { text = { "壬", "肉", "刃\n" }, color = "overlay2", align = "justify" },
          { text = "[uü]an", color = "blue" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "土", "田", "屯\n" }, color = "overlay2", align = "justify" },
          { text = { "它", "太", "台\n" }, color = "overlay2", align = "justify" },
          { text = { "[uü]e" }, color = "blue" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "讠", "衤", "业\n" }, color = "rosewater", align = "justify" },
          { text = { "乁", "㇈", "丫\n" }, color = "rosewater", align = "justify" },
          { text = "uai ing", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "礻", "饣", "石\n" }, color = "rosewater", align = "justify" },
          { text = { "尸", "十", "士\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82C}", "u" }, color = { "red", "blue" }, bold = { true, false }, align = "justify" }
        } })),
        [8] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "㐅", "厂", "虫\n" }, color = "rosewater", align = "justify" },
          { text = { "川", "巛", "叉\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82B}", "i" }, color = { "red", "blue" }, bold = { true, false }, align = "justify" }
        } })),
        [9] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "日", "月\n" }, color = "rosewater", align = "justify" },
          { text = { "目", "曰\n" }, color = "rosewater", align = "justify" },
          { text = { "\u{F82D}", "u?o" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [10] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "丿", "彡", "𤴔\n" }, color = { "lavender", "rosewater", "rosewater" }, align = "justify" },
          { text = { "疋", "攴", "片\n" }, color = "overlay2", align = "justify" },
          { text = "[uü]n", color = "blue" }
        } }))
      }
    },
    [3] = row {
      keys = {
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "丨", "一", "乛\n" }, color = "lavender", align = "justify" },
          { text = { "亅", "𠃋", "〇\n" }, color = "rosewater", align = "justify" },
          { text = { "\u{F82F}", "a", "er" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "纟", "罒", "龴\n" }, color = "rosewater", align = "justify" },
          { text = { "巳", "厶", "三\n" }, color = "overlay2", align = "justify" },
          { text = " i?ong", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "丶", "乀", "⺈\n" }, color = { "lavender", "lavender", "rosewater" }, align = "justify" },
          { text = { "冫", "氵", "刂\n" }, color = "rosewater", align = "justify" },
          { text = "[iu]ang", color = "blue" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "扌", "丰", "缶\n" }, color = { "rosewater", "overlay2", "overlay2" }, align = "justify" },
          { text = { "反", "方", "父\n" }, color = "overlay2", align = "justify" },
          { text = "en", color = "blue" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "乚", "𠄎", "勹\n" }, color = "rosewater", align = "justify" },
          { text = { "广", "㠯", "弓\n" }, color = { "rosewater", "rosewater", "overlay2" }, align = "justify" },
          { text = "eng", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "灬", "火", "户\n" }, color = "rosewater", align = "justify" },
          { text = { "虍", "厷", "禾\n" }, color = { "rosewater", "rosewater", "overlay2" }, align = "justify" },
          { text = "ang", color = "blue" }
        } })),
        [8] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "钅", "金", "巾\n" }, color = { "rosewater", "overlay2", "overlay2" }, align = "justify" },
          { text = { "几", "九", "己\n" }, color = "overlay2", align = "justify" },
          { text = "an", color = "blue" }
        } })),
        [9] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "匚", "冂", "凵\n" }, color = "rosewater", align = "justify" },
          { text = { "囗", "丂", "口\n" }, color = "rosewater", align = "justify" },
          { text = "ao", color = "blue" }
        } })),
        [10] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "六", "力", "立\n" }, color = "rosewater", align = "justify" },
          { text = { "卤", "耒", "龙\n" }, color = "overlay2", align = "justify" },
          { text = "i?ai", color = "blue" }
        } }))
      }
    },
    [4] = row {
      keys = {
        [2] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "⻊", "廴", "辶\n" }, color = "rosewater", align = "justify" },
          { text = { "卆", "走", "子\n" }, color = "overlay2", align = "justify" },
          { text = "ei", color = "blue", align = "justify" }
        } })),
        [3] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "彳", "心", "忄\n" }, color = "rosewater", align = "justify" },
          { text = { "⺌", "⺗", "小\n" }, color = "overlay2", align = "justify" },
          { text = "ie", color = "blue" }
        } })),
        [4] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "艹", "卄", "廾\n" }, color = { "rosewater", "overlay2", "overlay2" }, align = "justify" },
          { text = { "屮", "卝", "廿\n" }, color = "overlay2", align = "justify" },
          { text = "iao", color = "blue", align = "justify" }
        } })),
        [5] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "⺮", "𠂤", "爫\n" }, color = "rosewater", align = "justify" },
          { text = { "隹", "爪", "豸\n" }, color = "overlay2", align = "justify" },
          { text = { "\u{F82A}", "ui", "ü" }, color = { "red", "blue", "blue" }, bold = { true, false, false }, align = "justify" }
        } })),
        [6] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "冖", "宀", "丷\n" }, color = "rosewater", align = "justify" },
          { text = { "疒", "八", "卜\n" }, color = { "rosewater", "overlay2", "overlay2" }, align = "justify" },
          { text = "ou", color = "blue" }
        } })),
        [7] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "女", "⺧", "牜\n" }, color = "rosewater", align = "justify" },
          { text = { "牛", "年", "鸟\n" }, color = "overlay2", align = "justify" },
          { text = "in", color = "blue" }
        } })),
        [8] = key(merge(hint_offset, key { label = { { align = "left", valign = "top" } }, hint = {
          { text = { "木", "皿", "门\n" }, color = "rosewater", align = "justify" },
          { text = { "马", "毛", "丏\n" }, color = "overlay2", align = "justify" },
          { text = "ian", color = "blue" }
        } }))
      }
    }
  }
}))

return keyboard
