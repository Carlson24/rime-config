local hint_offset = safe_require("nekocat.font_offset").auxhint

--- 生成虎码助记按键：统一 overlay2 配色与 justify 排版，非末行自动补换行
---@param lines string[][] 每行的字形列表
---@return TextKey
local function tiger_key(lines)
  local hint = {}
  for i, chars in ipairs(lines) do
    local text = {}
    for j, ch in ipairs(chars) do
      text[j] = ch
    end
    if i < #lines then
      text[#text + 1] = "\n"
    end
    hint[i] = { text = text, color = "overlay2", align = "justify" }
  end
  return key(merge(hint_offset, key {
    label = { { align = "left", valign = "top" } },
    hint = hint
  }))
end

local keyboard = keyboard(merge(safe_require("nekocat.layouts.47keys"), keyboard {
  name = "虎码助记",
  label_transform = "UPPERCASE",
  rows = {
    [1] = safe_require("nekocat.layouts._number_row").composing_row,
    [2] = row {
      keys = {
        [1] = tiger_key { { "目", "田", "牛" }, { "老", "耳", "食" }, { "井", "齐", "臣" } },
        [2] = tiger_key { { "宀", "冫", "彳", "象" }, { "乍", "兔", "页" }, { "龟", "鱼", "五" } },
        [3] = tiger_key { { "木", "彡", "𠂉" }, { "也", "欠", "见" }, { "穴", "干" } },
        [4] = tiger_key { { "又", "竹", "口", "巾" }, { "⽎", "七", "皮", "了" }, { "非", "之", "瓦" } },
        [5] = tiger_key { { "丿", "阝", "衣", "斤" }, { "疋", "用", "弗", "三" }, { "革", "龙", "雨" } },
        [6] = tiger_key { { "小", "车", "爪" }, { "四", "至", "酉" }, { "曲", "瓜", "卜" } },
        [7] = tiger_key { { "手", "白" }, { "辶", "廴" }, { "工", "隹" } },
        [8] = tiger_key { { "丶", "立", "糸", "幺" }, { "乡", "艮", "舟" }, { "予", "册", "丩" } },
        [9] = tiger_key { { "日", "贝", "几" }, { "矢", "自" }, { "川", "尤" } },
        [10] = tiger_key { { "刀", "长", "米", "戈" }, { "弋", "儿", "行", "走" }, { "足", "臼", "鼠", "黑" } }
      }
    },
    [3] = row {
      keys = {
        [2] = tiger_key { { "勹", "乙", "丰", "耒", "未" }, { "门", "鬼", "丁", "疒", "六" }, { "舌", "缶", "皿", "片" } },
        [3] = tiger_key { { "言", "力", "止" }, { "屮", "各" }, { "尚", "甲" } },
        [4] = tiger_key { { "口", "黾" }, { "里", "由" }, { "无", "民" } },
        [5] = tiger_key { { "一", "示", "且" }, { "亡", "辰" }, { "骨", "㡀" } },
        [6] = tiger_key { { "土", "士", "丨" }, { "高", "羊", "歹" }, { "句", "韦" } },
        [7] = tiger_key { { "八", "心", "子" }, { "攵", "夂", "夫" }, { "谷", "壴" } },
        [8] = tiger_key { { "人", "入" }, { "仑", "豕" }, { "斗", "亼" } },
        [9] = tiger_key { { "水", "⼛", "寸" }, { "九", "㠯", "亥" }, { "母", "毋" } },
        [10] = tiger_key { { "艹", "卅", "廿", "夕" }, { "卌", "方", "生", "千" }, { "而", "牙", "齿" } }
      }
    },
    [4] = row {
      keys = {
        [2] = tiger_key { { "金", "卩", "亠", "可" }, { "甘", "羽", "习", "身" }, { "虎", "豆", "麻" } },
        [3] = tiger_key { { "禾", "⺈", "厂" }, { "广", "鹿", "鸟" }, { "乌", "束", "音" } },
        [4] = tiger_key { { "火", "业", "尸" }, { "虫", "古", "不" }, { "及", "支", "飞" } },
        [5] = tiger_key { { "匕", "月", "西", "文", "乃" }, { "山", "㐄", "毛", "气" }, { "已", "己", "巳", "禸" } },
        [6] = tiger_key { { "女", "乂", "彐", "弓" }, { "聿", "云", "面", "𠂎" }, { "氏", "卯", "卵" } },
        [7] = tiger_key { { "十", "马", "王", "勹" }, { "匚", "戊", "辛" }, { "甫", "黄", "鬲" } },
        [8] = tiger_key { { "大", "犬", "豸", "冂" }, { "二", "两", "石" }, { "户", "巴", "光" } }
      }
    }
  }
}))

return keyboard
