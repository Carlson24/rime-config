-- Contributed to Project Moran by jack2game (https://github.com/ksqsf/rime-moran/pull/61)
-- Unicode
-- 复制自： https://github.com/shewer/librime-lua-script/blob/main/lua/component/unicode.lua
-- 示例：输入 U62fc 得到「拼」
-- 触发前缀默认为 recognizer/patterns/unicode 的第 2 个字符，即 U
-- 2024.02.26: 限定编码最大值
-- 2025.10.05: 注释改为「U+xxxx【区块标签】」形式
-- 2026.10.06: 补齐 Unicode 18.0 全部区块中文标签（按官方区间，简中命名）

-- Unicode 18.0 全部区块（区间与简体中文名），按起点升序
local BLOCKS = {
  { 0x0000, 0x007F, "基本拉丁字母" }, -- Basic Latin
  { 0x0080, 0x00FF, "拉丁字母补充-1" }, -- Latin-1 Supplement
  { 0x0100, 0x017F, "拉丁字母扩展-A" }, -- Latin Extended-A
  { 0x0180, 0x024F, "拉丁字母扩展-B" }, -- Latin Extended-B
  { 0x0250, 0x02AF, "国际音标扩展" }, -- IPA Extensions
  { 0x02B0, 0x02FF, "占位修饰符号" }, -- Spacing Modifier Letters
  { 0x0300, 0x036F, "组合附加符号" }, -- Combining Diacritical Marks
  { 0x0370, 0x03FF, "希腊字母和科普特字母" }, -- Greek and Coptic
  { 0x0400, 0x04FF, "西里尔字母" }, -- Cyrillic
  { 0x0500, 0x052F, "西里尔字母补充" }, -- Cyrillic Supplement
  { 0x0530, 0x058F, "亚美尼亚字母" }, -- Armenian
  { 0x0590, 0x05FF, "希伯来文字母" }, -- Hebrew
  { 0x0600, 0x06FF, "阿拉伯文字母" }, -- Arabic
  { 0x0700, 0x074F, "叙利亚字母" }, -- Syriac
  { 0x0750, 0x077F, "阿拉伯文补充" }, -- Arabic Supplement
  { 0x0780, 0x07BF, "它拿字母" }, -- Thaana
  { 0x07C0, 0x07FF, "西非书面文字" }, -- NKo
  { 0x0800, 0x083F, "撒玛利亚字母" }, -- Samaritan
  { 0x0840, 0x085F, "曼达安字母" }, -- Mandaic
  { 0x0860, 0x086F, "叙利亚文补充" }, -- Syriac Supplement
  { 0x0870, 0x089F, "阿拉伯字母扩展-B" }, -- Arabic Extended-B
  { 0x08A0, 0x08FF, "阿拉伯字母扩展-A" }, -- Arabic Extended-A
  { 0x0900, 0x097F, "天城文" }, -- Devanagari
  { 0x0980, 0x09FF, "孟加拉文" }, -- Bengali
  { 0x0A00, 0x0A7F, "古木基文" }, -- Gurmukhi
  { 0x0A80, 0x0AFF, "古吉拉特文" }, -- Gujarati
  { 0x0B00, 0x0B7F, "奥里亚文" }, -- Oriya
  { 0x0B80, 0x0BFF, "泰米尔文" }, -- Tamil
  { 0x0C00, 0x0C7F, "泰卢固文" }, -- Telugu
  { 0x0C80, 0x0CFF, "卡纳达文" }, -- Kannada
  { 0x0D00, 0x0D7F, "马拉雅拉姆文" }, -- Malayalam
  { 0x0D80, 0x0DFF, "僧伽罗文" }, -- Sinhala
  { 0x0E00, 0x0E7F, "泰文" }, -- Thai
  { 0x0E80, 0x0EFF, "寮文" }, -- Lao
  { 0x0F00, 0x0FFF, "藏文" }, -- Tibetan
  { 0x1000, 0x109F, "缅甸文" }, -- Myanmar
  { 0x10A0, 0x10FF, "格鲁吉亚字母" }, -- Georgian
  { 0x1100, 0x11FF, "谚文字母" }, -- Hangul Jamo
  { 0x1200, 0x137F, "埃塞俄比亚字母" }, -- Ethiopic
  { 0x1380, 0x139F, "埃塞俄比亚字母补充" }, -- Ethiopic Supplement
  { 0x13A0, 0x13FF, "切罗基文" }, -- Cherokee
  { 0x1400, 0x167F, "统一加拿大原住民音节文字" }, -- Unified Canadian Aboriginal Syllabics
  { 0x1680, 0x169F, "欧甘字母" }, -- Ogham
  { 0x16A0, 0x16FF, "卢恩字母" }, -- Runic
  { 0x1700, 0x171F, "他加禄字母" }, -- Tagalog
  { 0x1720, 0x173F, "哈努诺文" }, -- Hanunoo
  { 0x1740, 0x175F, "布希德字母" }, -- Buhid
  { 0x1760, 0x177F, "塔格班瓦字母" }, -- Tagbanwa
  { 0x1780, 0x17FF, "高棉文" }, -- Khmer
  { 0x1800, 0x18AF, "蒙古文" }, -- Mongolian
  { 0x18B0, 0x18FF, "统一加拿大原住民音节文字扩展" }, -- Unified Canadian Aboriginal Syllabics Extended
  { 0x1900, 0x194F, "林布文" }, -- Limbu
  { 0x1950, 0x197F, "德宏傣文" }, -- Tai Le
  { 0x1980, 0x19DF, "新傣仂文" }, -- New Tai Lue
  { 0x19E0, 0x19FF, "高棉文符号" }, -- Khmer Symbols
  { 0x1A00, 0x1A1F, "布吉文" }, -- Buginese
  { 0x1A20, 0x1AAF, "老傣仂文" }, -- Tai Tham
  { 0x1AB0, 0x1AFF, "组合附加符号扩展" }, -- Combining Diacritical Marks Extended
  { 0x1B00, 0x1B7F, "巴厘字母" }, -- Balinese
  { 0x1B80, 0x1BBF, "巽他字母" }, -- Sundanese
  { 0x1BC0, 0x1BFF, "巴塔克字母" }, -- Batak
  { 0x1C00, 0x1C4F, "绒巴文" }, -- Lepcha
  { 0x1C50, 0x1C7F, "桑塔利文" }, -- Ol Chiki
  { 0x1C80, 0x1C8F, "西里尔字母扩展-C" }, -- Cyrillic Extended-C
  { 0x1C90, 0x1CBF, "格鲁吉亚字母扩展" }, -- Georgian Extended
  { 0x1CC0, 0x1CCF, "巽他字母补充" }, -- Sundanese Supplement
  { 0x1CD0, 0x1CFF, "吠陀扩展" }, -- Vedic Extensions
  { 0x1D00, 0x1D7F, "音标扩展" }, -- Phonetic Extensions
  { 0x1D80, 0x1DBF, "音标扩展补充" }, -- Phonetic Extensions Supplement
  { 0x1DC0, 0x1DFF, "组合附加符号补充" }, -- Combining Diacritical Marks Supplement
  { 0x1E00, 0x1EFF, "拉丁字母扩展附加" }, -- Latin Extended Additional
  { 0x1F00, 0x1FFF, "希腊字母扩展" }, -- Greek Extended
  { 0x2000, 0x206F, "一般标点" }, -- General Punctuation
  { 0x2070, 0x209F, "上标及下标" }, -- Superscripts and Subscripts
  { 0x20A0, 0x20CF, "货币符号" }, -- Currency Symbols
  { 0x20D0, 0x20FF, "符号用组合附加符号" }, -- Combining Diacritical Marks for Symbols
  { 0x2100, 0x214F, "类字母符号" }, -- Letterlike Symbols
  { 0x2150, 0x218F, "数字形式" }, -- Number Forms
  { 0x2190, 0x21FF, "箭头" }, -- Arrows
  { 0x2200, 0x22FF, "数学运算符" }, -- Mathematical Operators
  { 0x2300, 0x23FF, "杂项技术符号" }, -- Miscellaneous Technical
  { 0x2400, 0x243F, "控制图形" }, -- Control Pictures
  { 0x2440, 0x245F, "光学字符识别" }, -- Optical Character Recognition
  { 0x2460, 0x24FF, "带圈字母数字" }, -- Enclosed Alphanumerics
  { 0x2500, 0x257F, "制表符" }, -- Box Drawing
  { 0x2580, 0x259F, "方块元素" }, -- Block Elements
  { 0x25A0, 0x25FF, "几何图形" }, -- Geometric Shapes
  { 0x2600, 0x26FF, "杂项符号" }, -- Miscellaneous Symbols
  { 0x2700, 0x27BF, "装饰符号" }, -- Dingbats
  { 0x27C0, 0x27EF, "杂项数学符号-A" }, -- Miscellaneous Mathematical Symbols-A
  { 0x27F0, 0x27FF, "追加箭头-A" }, -- Supplemental Arrows-A
  { 0x2800, 0x28FF, "点字图案" }, -- Braille Patterns
  { 0x2900, 0x297F, "追加箭头-B" }, -- Supplemental Arrows-B
  { 0x2980, 0x29FF, "杂项数学符号-B" }, -- Miscellaneous Mathematical Symbols-B
  { 0x2A00, 0x2AFF, "补充数学运算符" }, -- Supplemental Mathematical Operators
  { 0x2B00, 0x2BFF, "杂项符号和箭头" }, -- Miscellaneous Symbols and Arrows
  { 0x2C00, 0x2C5F, "格拉哥里字母" }, -- Glagolitic
  { 0x2C60, 0x2C7F, "拉丁字母扩展-C" }, -- Latin Extended-C
  { 0x2C80, 0x2CFF, "科普特字母" }, -- Coptic
  { 0x2D00, 0x2D2F, "格鲁吉亚字母补充" }, -- Georgian Supplement
  { 0x2D30, 0x2D7F, "提非纳文" }, -- Tifinagh
  { 0x2D80, 0x2DDF, "埃塞俄比亚字母扩展" }, -- Ethiopic Extended
  { 0x2DE0, 0x2DFF, "西里尔字母扩展-A" }, -- Cyrillic Extended-A
  { 0x2E00, 0x2E7F, "补充标点" }, -- Supplemental Punctuation
  { 0x2E80, 0x2EFF, "中日韩汉字部首补充" }, -- CJK Radicals Supplement
  { 0x2F00, 0x2FDF, "康熙部首" }, -- Kangxi Radicals
  { 0x2FF0, 0x2FFF, "表意文字描述字符" }, -- Ideographic Description Characters
  { 0x3000, 0x303F, "中日韩符号和标点" }, -- CJK Symbols and Punctuation
  { 0x3040, 0x309F, "平假名" }, -- Hiragana
  { 0x30A0, 0x30FF, "片假名" }, -- Katakana
  { 0x3100, 0x312F, "注音符号" }, -- Bopomofo
  { 0x3130, 0x318F, "谚文兼容字母" }, -- Hangul Compatibility Jamo
  { 0x3190, 0x319F, "汉文训读符号" }, -- Kanbun
  { 0x31A0, 0x31BF, "注音符号扩展" }, -- Bopomofo Extended
  { 0x31C0, 0x31EF, "中日韩笔画" }, -- CJK Strokes
  { 0x31F0, 0x31FF, "片假名语音扩展" }, -- Katakana Phonetic Extensions
  { 0x3200, 0x32FF, "中日韩带圈字符及月份" }, -- Enclosed CJK Letters and Months
  { 0x3300, 0x33FF, "中日韩兼容字符" }, -- CJK Compatibility
  { 0x3400, 0x4DBF, "中日韩统一表意文字扩展区A" }, -- CJK Unified Ideographs Extension A
  { 0x4DC0, 0x4DFF, "易经六十四卦符号" }, -- Yijing Hexagram Symbols
  { 0x4E00, 0x9FFF, "中日韩统一表意文字" }, -- CJK Unified Ideographs
  { 0xA000, 0xA48F, "彝文音节" }, -- Yi Syllables
  { 0xA490, 0xA4CF, "彝文部首" }, -- Yi Radicals
  { 0xA4D0, 0xA4FF, "傈僳文" }, -- Lisu
  { 0xA500, 0xA63F, "瓦伊文" }, -- Vai
  { 0xA640, 0xA69F, "西里尔字母扩展-B" }, -- Cyrillic Extended-B
  { 0xA6A0, 0xA6FF, "巴姆穆文字" }, -- Bamum
  { 0xA700, 0xA71F, "声调修饰符号" }, -- Modifier Tone Letters
  { 0xA720, 0xA7FF, "拉丁字母扩展-D" }, -- Latin Extended-D
  { 0xA800, 0xA82F, "锡尔赫特文" }, -- Syloti Nagri
  { 0xA830, 0xA83F, "通用印度数字形式" }, -- Common Indic Number Forms
  { 0xA840, 0xA87F, "八思巴文" }, -- Phags-pa
  { 0xA880, 0xA8DF, "索拉什特拉文" }, -- Saurashtra
  { 0xA8E0, 0xA8FF, "天城文扩展" }, -- Devanagari Extended
  { 0xA900, 0xA92F, "克耶字母" }, -- Kayah Li
  { 0xA930, 0xA95F, "勒姜字母" }, -- Rejang
  { 0xA960, 0xA97F, "谚文字母扩展-A" }, -- Hangul Jamo Extended-A
  { 0xA980, 0xA9DF, "爪哇字母" }, -- Javanese
  { 0xA9E0, 0xA9FF, "缅甸文扩展-B" }, -- Myanmar Extended-B
  { 0xAA00, 0xAA5F, "占文" }, -- Cham
  { 0xAA60, 0xAA7F, "缅甸文扩展-A" }, -- Myanmar Extended-A
  { 0xAA80, 0xAADF, "傣越文" }, -- Tai Viet
  { 0xAAE0, 0xAAFF, "梅泰文扩展" }, -- Meetei Mayek Extensions
  { 0xAB00, 0xAB2F, "埃塞俄比亚字母扩展-A" }, -- Ethiopic Extended-A
  { 0xAB30, 0xAB6F, "拉丁字母扩展-E" }, -- Latin Extended-E
  { 0xAB70, 0xABBF, "切罗基文补充" }, -- Cherokee Supplement
  { 0xABC0, 0xABFF, "梅泰文" }, -- Meetei Mayek
  { 0xAC00, 0xD7AF, "谚文音节" }, -- Hangul Syllables
  { 0xD7B0, 0xD7FF, "谚文字母扩展-B" }, -- Hangul Jamo Extended-B
  { 0xD800, 0xDB7F, "高半代用区" }, -- High Surrogates
  { 0xDB80, 0xDBFF, "高半私人代用区" }, -- High Private Use Surrogates
  { 0xDC00, 0xDFFF, "低半代用区" }, -- Low Surrogates
  { 0xE000, 0xF8FF, "私用区" }, -- Private Use Area
  { 0xF900, 0xFAFF, "中日韩兼容表意文字" }, -- CJK Compatibility Ideographs
  { 0xFB00, 0xFB4F, "字母表达形式" }, -- Alphabetic Presentation Forms
  { 0xFB50, 0xFDFF, "阿拉伯字母表达形式-A" }, -- Arabic Presentation Forms-A
  { 0xFE00, 0xFE0F, "变体选择符" }, -- Variation Selectors
  { 0xFE10, 0xFE1F, "竖排形式" }, -- Vertical Forms
  { 0xFE20, 0xFE2F, "组合用半符号" }, -- Combining Half Marks
  { 0xFE30, 0xFE4F, "中日韩兼容形式" }, -- CJK Compatibility Forms
  { 0xFE50, 0xFE6F, "小写变体形式" }, -- Small Form Variants
  { 0xFE70, 0xFEFF, "阿拉伯字母表达形式-B" }, -- Arabic Presentation Forms-B
  { 0xFF00, 0xFFEF, "半角及全角字符" }, -- Halfwidth and Fullwidth Forms
  { 0xFFF0, 0xFFFF, "特殊" }, -- Specials
  { 0x10000, 0x1007F, "线形文字B音节文字" }, -- Linear B Syllabary
  { 0x10080, 0x100FF, "线形文字B表意文字" }, -- Linear B Ideograms
  { 0x10100, 0x1013F, "爱琴海数字" }, -- Aegean Numbers
  { 0x10140, 0x1018F, "古希腊数字" }, -- Ancient Greek Numbers
  { 0x10190, 0x101CF, "古代符号" }, -- Ancient Symbols
  { 0x101D0, 0x101FF, "斐斯托斯圆盘" }, -- Phaistos Disc
  { 0x10280, 0x1029F, "吕基亚字母" }, -- Lycian
  { 0x102A0, 0x102DF, "卡里亚字母" }, -- Carian
  { 0x102E0, 0x102FF, "科普特闰余数字" }, -- Coptic Epact Numbers
  { 0x10300, 0x1032F, "古意大利字母" }, -- Old Italic
  { 0x10330, 0x1034F, "哥特字母" }, -- Gothic
  { 0x10350, 0x1037F, "古彼尔姆文" }, -- Old Permic
  { 0x10380, 0x1039F, "乌加里特字母" }, -- Ugaritic
  { 0x103A0, 0x103DF, "古波斯楔形文字" }, -- Old Persian
  { 0x10400, 0x1044F, "德瑟雷特字母" }, -- Deseret
  { 0x10450, 0x1047F, "萧伯纳字母" }, -- Shavian
  { 0x10480, 0x104AF, "奥斯曼亚字母" }, -- Osmanya
  { 0x104B0, 0x104FF, "欧塞奇字母" }, -- Osage
  { 0x10500, 0x1052F, "爱尔巴桑字母" }, -- Elbasan
  { 0x10530, 0x1056F, "高加索阿尔巴尼亚文" }, -- Caucasian Albanian
  { 0x10570, 0x105BF, "维斯库奇文" }, -- Vithkuqi
  { 0x105C0, 0x105FF, "托特里文" }, -- Todhri
  { 0x10600, 0x1077F, "线形文字A" }, -- Linear A
  { 0x10780, 0x107BF, "拉丁字母扩展-F" }, -- Latin Extended-F
  { 0x10800, 0x1083F, "塞浦路斯音节文字" }, -- Cypriot Syllabary
  { 0x10840, 0x1085F, "帝国亚拉姆文" }, -- Imperial Aramaic
  { 0x10860, 0x1087F, "帕尔迈拉字母" }, -- Palmyrene
  { 0x10880, 0x108AF, "纳巴泰字母" }, -- Nabataean
  { 0x108E0, 0x108FF, "哈特拉文" }, -- Hatran
  { 0x10900, 0x1091F, "腓尼基字母" }, -- Phoenician
  { 0x10920, 0x1093F, "吕底亚字母" }, -- Lydian
  { 0x10940, 0x1095F, "锡德文" }, -- Sidetic
  { 0x10980, 0x1099F, "麦罗埃文圣书体" }, -- Meroitic Hieroglyphs
  { 0x109A0, 0x109FF, "麦罗埃文草书体" }, -- Meroitic Cursive
  { 0x10A00, 0x10A5F, "佉卢文" }, -- Kharoshthi
  { 0x10A60, 0x10A7F, "古南阿拉伯字母" }, -- Old South Arabian
  { 0x10A80, 0x10A9F, "古北阿拉伯字母" }, -- Old North Arabian
  { 0x10AC0, 0x10AFF, "摩尼字母" }, -- Manichaean
  { 0x10B00, 0x10B3F, "阿维斯陀字母" }, -- Avestan
  { 0x10B40, 0x10B5F, "碑刻帕提亚文" }, -- Inscriptional Parthian
  { 0x10B60, 0x10B7F, "碑刻巴列维文" }, -- Inscriptional Pahlavi
  { 0x10B80, 0x10BAF, "诗篇巴列维文" }, -- Psalter Pahlavi
  { 0x10C00, 0x10C4F, "古突厥文" }, -- Old Turkic
  { 0x10C80, 0x10CFF, "古匈牙利字母" }, -- Old Hungarian
  { 0x10D00, 0x10D3F, "哈乃斐罗兴亚文" }, -- Hanifi Rohingya
  { 0x10D40, 0x10D8F, "加莱文" }, -- Garay
  { 0x10E60, 0x10E7F, "卢米文数字" }, -- Rumi Numeral Symbols
  { 0x10E80, 0x10EBF, "雅兹迪文" }, -- Yezidi
  { 0x10EC0, 0x10EFF, "阿拉伯字母扩展-C" }, -- Arabic Extended-C
  { 0x10F00, 0x10F2F, "古粟特字母" }, -- Old Sogdian
  { 0x10F30, 0x10F6F, "粟特字母" }, -- Sogdian
  { 0x10F70, 0x10FAF, "回鹘字母" }, -- Old Uyghur
  { 0x10FB0, 0x10FDF, "花剌子模字母" }, -- Chorasmian
  { 0x10FE0, 0x10FFF, "埃利迈文" }, -- Elymaic
  { 0x11000, 0x1107F, "婆罗米文" }, -- Brahmi
  { 0x11080, 0x110CF, "凯提文" }, -- Kaithi
  { 0x110D0, 0x110FF, "索拉僧平文字" }, -- Sora Sompeng
  { 0x11100, 0x1114F, "查克马文" }, -- Chakma
  { 0x11150, 0x1117F, "马哈佳尼文" }, -- Mahajani
  { 0x11180, 0x111DF, "夏拉达文" }, -- Sharada
  { 0x111E0, 0x111FF, "古僧伽罗文数字" }, -- Sinhala Archaic Numbers
  { 0x11200, 0x1124F, "科杰基文" }, -- Khojki
  { 0x11280, 0x112AF, "穆尔塔尼文" }, -- Multani
  { 0x112B0, 0x112FF, "库达瓦迪文" }, -- Khudawadi
  { 0x11300, 0x1137F, "古兰塔文" }, -- Grantha
  { 0x11380, 0x113FF, "图卢-提加拉里文" }, -- Tulu-Tigalari
  { 0x11400, 0x1147F, "纽瓦字母" }, -- Newa
  { 0x11480, 0x114DF, "底罗仆多文" }, -- Tirhuta
  { 0x11580, 0x115FF, "悉昙文字" }, -- Siddham
  { 0x11600, 0x1165F, "莫迪文" }, -- Modi
  { 0x11660, 0x1167F, "蒙古文补充" }, -- Mongolian Supplement
  { 0x11680, 0x116CF, "塔克里文" }, -- Takri
  { 0x116D0, 0x116FF, "缅甸文扩展-C" }, -- Myanmar Extended-C
  { 0x11700, 0x1174F, "阿洪姆文" }, -- Ahom
  { 0x11800, 0x1184F, "多格拉文" }, -- Dogra
  { 0x118A0, 0x118FF, "瓦兰齐地文" }, -- Warang Citi
  { 0x11900, 0x1195F, "岛屿字母" }, -- Dives Akuru
  { 0x119A0, 0x119FF, "南迪城文" }, -- Nandinagari
  { 0x11A00, 0x11A4F, "札那巴札尔方形字母" }, -- Zanabazar Square
  { 0x11A50, 0x11AAF, "索永布文字" }, -- Soyombo
  { 0x11AB0, 0x11ABF, "加拿大原住民音节文字扩展-A" }, -- Unified Canadian Aboriginal Syllabics Extended-A
  { 0x11AC0, 0x11AFF, "包钦豪文" }, -- Pau Cin Hau
  { 0x11B00, 0x11B5F, "天城文扩展-A" }, -- Devanagari Extended-A
  { 0x11B60, 0x11B7F, "夏拉达文补充" }, -- Sharada Supplement
  { 0x11BC0, 0x11BFF, "苏努瓦尔文" }, -- Sunuwar
  { 0x11C00, 0x11C6F, "拜克舒基文" }, -- Bhaiksuki
  { 0x11C70, 0x11CBF, "玛钦文" }, -- Marchen
  { 0x11D00, 0x11D5F, "马萨拉姆贡德文字" }, -- Masaram Gondi
  { 0x11D60, 0x11DAF, "贡贾拉贡德文字" }, -- Gunjala Gondi
  { 0x11DB0, 0x11DEF, "托隆希基文" }, -- Tolong Siki
  { 0x11DF0, 0x11DFF, "孟加拉文补充" }, -- Bengali Supplement
  { 0x11EE0, 0x11EFF, "望加锡文" }, -- Makasar
  { 0x11F00, 0x11F5F, "卡维文" }, -- Kawi
  { 0x11FB0, 0x11FBF, "老傈僳文补充" }, -- Lisu Supplement
  { 0x11FC0, 0x11FFF, "泰米尔文补充" }, -- Tamil Supplement
  { 0x12000, 0x123FF, "楔形文字" }, -- Cuneiform
  { 0x12400, 0x1247F, "楔形文字数字和标点符号" }, -- Cuneiform Numbers and Punctuation
  { 0x12480, 0x1254F, "早期王朝楔形文字" }, -- Early Dynastic Cuneiform
  { 0x12550, 0x1268F, "古楔形文字数字" }, -- Archaic Cuneiform Numerals
  { 0x12F90, 0x12FFF, "塞浦路斯-米诺斯文字" }, -- Cypro-Minoan
  { 0x13000, 0x1342F, "埃及圣书体" }, -- Egyptian Hieroglyphs
  { 0x13430, 0x1345F, "埃及圣书体格式控制" }, -- Egyptian Hieroglyph Format Controls
  { 0x13460, 0x143FF, "埃及圣书体扩展-A" }, -- Egyptian Hieroglyphs Extended-A
  { 0x14400, 0x1467F, "安纳托利亚象形文字" }, -- Anatolian Hieroglyphs
  { 0x16100, 0x1613F, "古隆凯玛文" }, -- Gurung Khema
  { 0x16800, 0x16A3F, "巴姆穆文字补充" }, -- Bamum Supplement
  { 0x16A40, 0x16A6F, "默禄文" }, -- Mro
  { 0x16A70, 0x16ACF, "唐萨文" }, -- Tangsa
  { 0x16AD0, 0x16AFF, "巴萨文" }, -- Bassa Vah
  { 0x16B00, 0x16B8F, "救世苗文" }, -- Pahawh Hmong
  { 0x16D40, 0x16D7F, "基拉特拉伊文" }, -- Kirat Rai
  { 0x16E40, 0x16E9F, "梅德法伊德林文" }, -- Medefaidrin
  { 0x16EA0, 0x16EDF, "贝里亚埃尔菲" }, -- Beria Erfe
  { 0x16F00, 0x16F9F, "柏格理苗文" }, -- Miao
  { 0x16FE0, 0x16FFF, "表意符号和标点符号" }, -- Ideographic Symbols and Punctuation
  { 0x17000, 0x187FF, "西夏文" }, -- Tangut
  { 0x18800, 0x18AFF, "西夏文部件" }, -- Tangut Components
  { 0x18B00, 0x18CFF, "契丹小字" }, -- Khitan Small Script
  { 0x18D00, 0x18D7F, "西夏文补充" }, -- Tangut Supplement
  { 0x18D80, 0x18DFF, "西夏文部件补充" }, -- Tangut Components Supplement
  { 0x18E00, 0x1919F, "女真文" }, -- Jurchen
  { 0x191A0, 0x191DF, "女真文部首" }, -- Jurchen Radicals
  { 0x1AFF0, 0x1AFFF, "假名扩展-B" }, -- Kana Extended-B
  { 0x1B000, 0x1B0FF, "假名补充" }, -- Kana Supplement
  { 0x1B100, 0x1B12F, "假名扩展-A" }, -- Kana Extended-A
  { 0x1B130, 0x1B16F, "小型假名扩展" }, -- Small Kana Extension
  { 0x1B170, 0x1B2FF, "女书" }, -- Nushu
  { 0x1BC00, 0x1BC9F, "杜普雷速记" }, -- Duployan
  { 0x1BCA0, 0x1BCAF, "速记格式控制符" }, -- Shorthand Format Controls
  { 0x1CC00, 0x1CEBF, "遗留计算符号补充" }, -- Symbols for Legacy Computing Supplement
  { 0x1CEC0, 0x1CEFF, "杂项符号补充" }, -- Miscellaneous Symbols Supplement
  { 0x1CF00, 0x1CFCF, "赞玫尼圣歌音乐符号" }, -- Znamenny Musical Notation
  { 0x1D000, 0x1D0FF, "拜占庭音乐符号" }, -- Byzantine Musical Symbols
  { 0x1D100, 0x1D1FF, "音乐符号" }, -- Musical Symbols
  { 0x1D200, 0x1D24F, "古希腊音乐记号" }, -- Ancient Greek Musical Notation
  { 0x1D250, 0x1D28F, "音乐符号补充" }, -- Musical Symbols Supplement
  { 0x1D2C0, 0x1D2DF, "卡克托维克数字" }, -- Kaktovik Numerals
  { 0x1D2E0, 0x1D2FF, "玛雅数字" }, -- Mayan Numerals
  { 0x1D300, 0x1D35F, "太玄经符号" }, -- Tai Xuan Jing Symbols
  { 0x1D360, 0x1D37F, "算筹" }, -- Counting Rod Numerals
  { 0x1D400, 0x1D7FF, "字母和数字符号" }, -- Mathematical Alphanumeric Symbols
  { 0x1D800, 0x1DAAF, "萨顿书写符号" }, -- Sutton SignWriting
  { 0x1DB00, 0x1DBFF, "杂项符号和箭头扩展" }, -- Miscellaneous Symbols and Arrows Extended
  { 0x1DF00, 0x1DFFF, "拉丁字母扩展-G" }, -- Latin Extended-G
  { 0x1E000, 0x1E02F, "格拉哥里字母补充" }, -- Glagolitic Supplement
  { 0x1E030, 0x1E08F, "西里尔字母扩展-D" }, -- Cyrillic Extended-D
  { 0x1E100, 0x1E14F, "创世纪苗文" }, -- Nyiakeng Puachue Hmong
  { 0x1E290, 0x1E2BF, "投投文" }, -- Toto
  { 0x1E2C0, 0x1E2FF, "文乔字母" }, -- Wancho
  { 0x1E4D0, 0x1E4FF, "蒙达里字母" }, -- Nag Mundari
  { 0x1E5D0, 0x1E5FF, "奥纳尔文" }, -- Ol Onal
  { 0x1E6C0, 0x1E6FF, "侥文" }, -- Tai Yo
  { 0x1E7E0, 0x1E7FF, "埃塞俄比亚字母扩展-B" }, -- Ethiopic Extended-B
  { 0x1E800, 0x1E8DF, "门德基卡库文" }, -- Mende Kikakui
  { 0x1E900, 0x1E95F, "阿德拉姆字母" }, -- Adlam
  { 0x1EC70, 0x1ECBF, "印度西亚格数字" }, -- Indic Siyaq Numbers
  { 0x1ED00, 0x1ED4F, "奥斯曼西亚格数字" }, -- Ottoman Siyaq Numbers
  { 0x1EE00, 0x1EEFF, "阿拉伯字母数字符号" }, -- Arabic Mathematical Alphabetic Symbols
  { 0x1F000, 0x1F02F, "麻将牌" }, -- Mahjong Tiles
  { 0x1F030, 0x1F09F, "多米诺骨牌" }, -- Domino Tiles
  { 0x1F0A0, 0x1F0FF, "扑克牌" }, -- Playing Cards
  { 0x1F100, 0x1F1FF, "带圈字母数字补充" }, -- Enclosed Alphanumeric Supplement
  { 0x1F200, 0x1F2FF, "带圈表意文字补充" }, -- Enclosed Ideographic Supplement
  { 0x1F300, 0x1F5FF, "杂项符号和象形文字" }, -- Miscellaneous Symbols and Pictographs
  { 0x1F600, 0x1F64F, "表情符号" }, -- Emoticons
  { 0x1F650, 0x1F67F, "装饰性符号" }, -- Ornamental Dingbats
  { 0x1F680, 0x1F6FF, "交通和地图符号" }, -- Transport and Map Symbols
  { 0x1F700, 0x1F77F, "炼金术符号" }, -- Alchemical Symbols
  { 0x1F780, 0x1F7FF, "几何图形扩展" }, -- Geometric Shapes Extended
  { 0x1F800, 0x1F8FF, "追加箭头-C" }, -- Supplemental Arrows-C
  { 0x1F900, 0x1F9FF, "补充符号和象形文字" }, -- Supplemental Symbols and Pictographs
  { 0x1FA00, 0x1FA6F, "棋类符号" }, -- Chess Symbols
  { 0x1FA70, 0x1FAFF, "符号和象形文字扩展-A" }, -- Symbols and Pictographs Extended-A
  { 0x1FB00, 0x1FBFF, "遗留计算符号" }, -- Symbols for Legacy Computing
  { 0x20000, 0x2A6DF, "中日韩统一表意文字扩展区B" }, -- CJK Unified Ideographs Extension B
  { 0x2A700, 0x2B73F, "中日韩统一表意文字扩展区C" }, -- CJK Unified Ideographs Extension C
  { 0x2B740, 0x2B81F, "中日韩统一表意文字扩展区D" }, -- CJK Unified Ideographs Extension D
  { 0x2B820, 0x2CEAF, "中日韩统一表意文字扩展区E" }, -- CJK Unified Ideographs Extension E
  { 0x2CEB0, 0x2EBEF, "中日韩统一表意文字扩展区F" }, -- CJK Unified Ideographs Extension F
  { 0x2EBF0, 0x2EE5F, "中日韩统一表意文字扩展区I" }, -- CJK Unified Ideographs Extension I
  { 0x2F800, 0x2FA1F, "中日韩兼容表意文字补充区" }, -- CJK Compatibility Ideographs Supplement
  { 0x30000, 0x3134F, "中日韩统一表意文字扩展区G" }, -- CJK Unified Ideographs Extension G
  { 0x31350, 0x323AF, "中日韩统一表意文字扩展区H" }, -- CJK Unified Ideographs Extension H
  { 0x323B0, 0x3347F, "中日韩统一表意文字扩展区J" }, -- CJK Unified Ideographs Extension J
  { 0x3D000, 0x3FC3F, "小篆" }, -- Seal
  { 0xE0000, 0xE007F, "标签" }, -- Tags
  { 0xE0100, 0xE01EF, "变体选择符补充" }, -- Variation Selectors Supplement
  { 0xF0000, 0xFFFFF, "补充私人使用区-A" }, -- Supplementary Private Use Area-A
  { 0x100000, 0x10FFFF, "补充私人使用区-B" } -- Supplementary Private Use Area-B
}

-- 返回码点所属 Unicode 区块的中文标签；未分配码点返回 nil
local function get_charset_label(code)
  if not code then return nil end
  for i = 1, #BLOCKS do
    local b = BLOCKS[i]
    if code < b[1] then return nil end
    if code <= b[2] then return b[3] end
  end
  return nil
end

-- code 为实际字符码点；base/offset 用于扩展候选显示
local function format_comment(code, base, offset)
  local s = string.format("U+%04X", base or code)
  if offset then s = s .. string.format("~%X", offset) end
  local label = get_charset_label(code)
  if label then s = s .. "【" .. label .. "】" end
  return s
end

local function unicode(input, seg, env)
  -- 获取 recognizer/patterns/unicode 的第 2 个字符作为触发前缀
  env.unicode_keyword = env.unicode_keyword or
      env.engine.schema.config:get_string("recognizer/patterns/unicode"):sub(2, 2) or "U"
  if seg:has_tag("unicode") and env.unicode_keyword ~= "" and input:sub(1, 1) == env.unicode_keyword then
    local ucodestr = input:match(env.unicode_keyword .. "(%x+)")
    if ucodestr and #ucodestr > 1 then
      local code = tonumber(ucodestr, 16)
      if code > 0x10FFFF then
        yield(Candidate("unicode", seg.start, seg._end, "数值超限！", ""))
        return
      end
      local text = utf8.char(code)
      yield(Candidate("unicode", seg.start, seg._end, text, format_comment(code)))
      if code < 0x10000 then
        for i = 0, 15 do
          local cp = code * 16 + i
          local text = utf8.char(cp)
          yield(Candidate("unicode", seg.start, seg._end, text, format_comment(cp, code, i)))
        end
      end
    end
  end
end

return unicode
