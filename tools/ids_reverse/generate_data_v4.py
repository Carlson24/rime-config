#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_data.py
Build high-performance inverted index and metadata for Rime IDS fuzzy character search.
Supports all 97,680+ Unicode CJK characters up to Unicode 16.0 (Basic + Ext A~I).
"""

import os
import re
import json
import collections
import unicodedata
import pypinyin

BABELSTONE_IDS_PATH = "IDS_raw.TXT"
ZITOOLS_LV2_PATH = "ids_zitools.txt"
ZITOOLS_LV1_PATH = "ids_lv1.txt"
EQUIVALENT_UNIFIED_PATH = "EquivalentUnifiedIdeograph.txt"
CHARSET_PATH = "wanxiang_charset.dict.yaml"
VARIANTS_PATH = "ids_variants.txt"
OUTPUT_INDEX = "ids_index.txt"
OUTPUT_META = "ids_meta.txt"

# Component equivalence mapping (bidirectional aliases)
EQUIV_GROUPS = [
    {'氵', '水', '⺡', '氺'},
    {'灬', '火', '⺣'},
    {'亻', '人', '𠆢', '⺅'},
    {'扌', '手', '龵'},
    {'忄', '心', '⺖', '⺗'},
    {'⺼', '月', '肉', '⺝'},
    {'艹', '艸', '⺾', '⻀'},
    {'礻', '示', '⺬'},
    {'衤', '衣', '⺭', '𧘇'},
    {'釒', '金', '钅', '⻐'},
    {'飠', '食', '饣', '⻠', '⻡', '𩙿'},
    {'糹', '糸', '纟', '⺰', '⺱'},
    {'犭', '犬', '⺲'},
    {'辶', '辵', '⻌', '⻍'},
    {'阝', '阜', '邑', '⻖', '⻗'},
    {'王', '⺩', '𤣩'},
    {'⺆', '冂'},
    {'攵', '攴', '⺙'},
    {'耂', '老', '⺹'},
    {'足', '⻊', '𧾷'},
    {'四', '罒', '网', '⺫'},
    {'竹', '⺮', '𥫗'},
    {'刀', '刂', '⺈', '⺉'},
    {'羊', '⺶', '⺷', '𦍌'},
    {'言', '讠', '訁'},
    {'号', '號'},
    {'牛', '牜', '⺧'},
    {'龍', '龙'},
    {'馬', '马'},
    {'鳥', '鸟'},
    {'魚', '鱼'},
    {'車', '车'},
    {'門', '门'},
    {'見', '见'},
    {'貝', '贝'},
    {'頁', '页'},
    {'風', '风'},
    {'齒', '齿'},
    {'日', '曰'},
    {'長', '长', '⻑', '镸'},
    # Unicode 笔画扩展区 (CJK Strokes) 与标准汉字笔画等价归一
    {'丿', '㇒', '㇓'},                                # 撇
    {'一', '㇐'},                                # 横
    {'丨', '㇑', '亅', '㇚'},                                # 竖
    {'丶', '㇔', '㇣'},                          # 点
    {'乀', '乁', '㇏'},                          # 捺
    {'乙', '乚', '乛', '𠃊', '𠃍', '𠃋', '𠃌', '㇄', '㇅', '㇆', '㇇', '㇈', '㇉', '㇊', '㇋', '㇌', '㇍', '㇎', '㇕', '㇖', '㇗', '㇘', '㇛', '㇜', '㇞', '㇟', '㇠', '㇡', '㇢', '㇂', '㇁', '㇃'}, # 折/弯/钩
    {'㇀', '㇙', '㇝'},                                      # 提
]

# Andrew West BabelStone IDS unencoded component placeholders {N} mapping
CURLY_MAP = {
    1: '灬', 2: '⺈', 3: '⺈', 4: '冖', 5: '叚', 6: '段', 7: '十', 8: '乚', 9: '丨', 10: '凡',
    11: '火', 12: '龙', 13: '虍', 14: '夬', 15: '氏', 16: '鼠', 17: '良', 18: '艮', 19: '更', 20: '丸',
    21: '祭', 22: '与', 23: '与', 24: '水', 25: '衣', 26: '齐', 27: '幺', 28: '弋', 29: '几', 30: '彐',
    31: '西', 32: '冖', 33: '隹', 34: '勹', 35: '几', 36: '百', 37: '睿', 38: '囊', 39: '卯', 40: '馬',
    41: '册', 42: '彐', 43: '⺕', 44: '十', 45: '丬', 46: '电', 47: '鳥', 48: '㐄', 49: '丨', 50: '𠃌',
    51: '馬', 52: '马', 53: '鸟', 54: '烏', 55: '鹿', 56: '无', 57: '在', 58: '卯', 59: '灬', 60: '龜',
    61: '臧', 62: '十', 64: '龟', 65: '龟', 66: '黾', 67: '口', 68: '黑', 69: '戠', 70: '业', 71: '臼',
    72: '爪', 73: '目', 74: '良', 75: '爵', 76: '长', 77: '至', 78: '亚', 79: '亞', 80: '冖', 81: '厷',
    82: '聿', 83: '亠', 84: '厂', 85: '广', 86: '灬', 87: '亠', 88: '人', 89: '龟', 90: '龜', 91: '黾',
    92: '龟', 93: '绳', 94: '其', 95: '尸', 96: '勿', 97: '戈', 98: '曹', 99: '册', 100: '辶',
    101: '癶', 102: '癶', 103: '又', 104: '辛', 105: '戉', 106: '免', 107: '炎', 108: '冂', 109: '千',
    110: '冂', 111: '口', 112: '臼', 113: '冂', 114: '土', 115: '西', 116: '心', 117: '正', 118: '厂',
    119: '己', 120: '弓', 121: '四', 122: '且'
}
def is_valid_comp(comp):
    return len(comp) == 1 and ord(comp) > 127 and comp not in '{}'

# Unicode CJK Strokes and Basic Stroke Characters definitions
STROKE_DATA = {
    # Unicode 笔画扩展区 (U+31C0 ~ U+31E3)
    '㇀': {'name': '提', 'pys': ['ti'], 'py_display': 'tí', 'cp': 0x31C0},
    '㇁': {'name': '弯钩', 'pys': ['wan', 'gou', 'zhe'], 'py_display': 'wāngōu', 'cp': 0x31C1},
    '㇂': {'name': '斜钩', 'pys': ['xie', 'gou', 'zhe'], 'py_display': 'xiégōu', 'cp': 0x31C2},
    '㇃': {'name': '扁斜钩', 'pys': ['xie', 'gou', 'zhe', 'bian'], 'py_display': 'biǎnxiégōu', 'cp': 0x31C3},
    '㇄': {'name': '竖弯', 'pys': ['shu', 'wan', 'zhe'], 'py_display': 'shùwān', 'cp': 0x31C4},
    '㇅': {'name': '横折折', 'pys': ['heng', 'zhe'], 'py_display': 'héngzhézhé', 'cp': 0x31C5},
    '㇆': {'name': '横折钩', 'pys': ['heng', 'zhe', 'gou'], 'py_display': 'héngzhégōu', 'cp': 0x31C6},
    '㇇': {'name': '横撇', 'pys': ['heng', 'pie', 'zhe'], 'py_display': 'héngpiě', 'cp': 0x31C7},
    '㇈': {'name': '横折弯钩', 'pys': ['heng', 'zhe', 'wan', 'gou'], 'py_display': 'héngzhéwāngōu', 'cp': 0x31C8},
    '㇉': {'name': '竖折弯钩', 'pys': ['shu', 'zhe', 'wan', 'gou'], 'py_display': 'shùzhéwāngōu', 'cp': 0x31C9},
    '㇊': {'name': '横折提', 'pys': ['heng', 'zhe', 'ti'], 'py_display': 'héngzhétí', 'cp': 0x31CA},
    '㇋': {'name': '横折折撇', 'pys': ['heng', 'zhe', 'pie'], 'py_display': 'héngzhézhépiě', 'cp': 0x31CB},
    '㇌': {'name': '横撇弯钩', 'pys': ['heng', 'pie', 'wan', 'gou', 'zhe'], 'py_display': 'héngpiěwāngōu', 'cp': 0x31CC},
    '㇍': {'name': '横折弯', 'pys': ['heng', 'zhe', 'wan'], 'py_display': 'héngzhéwān', 'cp': 0x31CD},
    '㇎': {'name': '横折折折', 'pys': ['heng', 'zhe'], 'py_display': 'héngzhézhézhé', 'cp': 0x31CE},
    '㇏': {'name': '捺', 'pys': ['na'], 'py_display': 'nà', 'cp': 0x31CF},
    '㇐': {'name': '横', 'pys': ['heng'], 'py_display': 'héng', 'cp': 0x31D0},
    '㇑': {'name': '竖', 'pys': ['shu'], 'py_display': 'shù', 'cp': 0x31D1},
    '㇒': {'name': '撇', 'pys': ['pie'], 'py_display': 'piě', 'cp': 0x31D2},
    '㇓': {'name': '竖撇', 'pys': ['shu', 'pie'], 'py_display': 'shùpiě', 'cp': 0x31D3},
    '㇔': {'name': '点', 'pys': ['dian'], 'py_display': 'diǎn', 'cp': 0x31D4},
    '㇕': {'name': '横折', 'pys': ['heng', 'zhe'], 'py_display': 'héngzhé', 'cp': 0x31D5},
    '㇖': {'name': '横钩', 'pys': ['heng', 'gou', 'zhe'], 'py_display': 'hénggōu', 'cp': 0x31D6},
    '㇗': {'name': '竖折', 'pys': ['shu', 'zhe'], 'py_display': 'shùzhé', 'cp': 0x31D7},
    '㇘': {'name': '竖弯折', 'pys': ['shu', 'wan', 'zhe'], 'py_display': 'shùwānzhé', 'cp': 0x31D8},
    '㇙': {'name': '竖提', 'pys': ['shu', 'ti'], 'py_display': 'shùtí', 'cp': 0x31D9},
    '㇚': {'name': '竖钩', 'pys': ['shu', 'gou'], 'py_display': 'shùgōu', 'cp': 0x31DA},
    '㇛': {'name': '撇点', 'pys': ['pie', 'dian', 'zhe'], 'py_display': 'piědiǎn', 'cp': 0x31DB},
    '㇜': {'name': '撇折', 'pys': ['pie', 'zhe'], 'py_display': 'piězhé', 'cp': 0x31DC},
    '㇝': {'name': '提捺', 'pys': ['ti', 'na'], 'py_display': 'tínà', 'cp': 0x31DD},
    '㇞': {'name': '竖折折', 'pys': ['shu', 'zhe'], 'py_display': 'shùzhézhé', 'cp': 0x31DE},
    '㇟': {'name': '竖弯钩', 'pys': ['shu', 'wan', 'gou', 'zhe'], 'py_display': 'shùwāngōu', 'cp': 0x31DF},
    '㇠': {'name': '横斜弯钩', 'pys': ['heng', 'xie', 'wan', 'gou', 'zhe'], 'py_display': 'héngxiéwāngōu', 'cp': 0x31E0},
    '㇡': {'name': '横折折折钩', 'pys': ['heng', 'zhe', 'gou'], 'py_display': 'héngzhézhézhégōu', 'cp': 0x31E1},
    '㇢': {'name': '撇钩', 'pys': ['pie', 'gou', 'zhe'], 'py_display': 'piěgōu', 'cp': 0x31E2},
    '㇣': {'name': '圈', 'pys': ['quan'], 'py_display': 'quān', 'cp': 0x31E3},

    # 常用基本笔画字符
    '乙': {'name': '折', 'pys': ['zhe', 'yi', 'wan', 'gou'], 'py_display': 'yǐ', 'cp': 0x4E59},
    '乚': {'name': '弯钩', 'pys': ['zhe', 'yin', 'wan', 'gou'], 'py_display': 'yǐn', 'cp': 0x4E5A},
    '乛': {'name': '横钩', 'pys': ['zhe', 'ya', 'gou', 'heng'], 'py_display': 'yà', 'cp': 0x4E5B},
    '𠃊': {'name': '竖折', 'pys': ['zhe', 'yin', 'shu'], 'py_display': 'yǐn', 'cp': 0x200CA},
    '𠃍': {'name': '横折', 'pys': ['zhe', 'heng'], 'py_display': 'héngzhé', 'cp': 0x200CD},
    '𠃋': {'name': '撇折', 'pys': ['zhe', 'pie'], 'py_display': 'piězhé', 'cp': 0x200CB},
    '𠃌': {'name': '横折钩', 'pys': ['zhe', 'gun', 'gou', 'heng'], 'py_display': 'gǔn', 'cp': 0x200CC},
    '亅': {'name': '竖钩', 'pys': ['shu', 'jue', 'gou'], 'py_display': 'jué', 'cp': 0x4E85},
    '一': {'name': '横', 'pys': ['heng', 'yi'], 'py_display': 'yī', 'cp': 0x4E00},
    '丨': {'name': '竖', 'pys': ['shu', 'gun'], 'py_display': 'gǔn', 'cp': 0x4E28},
    '丿': {'name': '撇', 'pys': ['pie'], 'py_display': 'piě', 'cp': 0x4E3F},
    '丶': {'name': '点', 'pys': ['dian', 'zhu'], 'py_display': 'zhǔ', 'cp': 0x4E36},
    '乀': {'name': '捺', 'pys': ['na', 'fu'], 'py_display': 'fú', 'cp': 0x4E40},
    '乁': {'name': '捺', 'pys': ['na', 'yi'], 'py_display': 'yí', 'cp': 0x4E41},
}

# Common single-syllable pinyin mappings for radicals and components
RADICAL_PINYIN = {
    '氵': ['shui'],
    '水': ['shui'],
    '氺': ['shui'],
    '⺡': ['shui'],
    '艹': ['cao'],
    '艸': ['cao'],
    '⺾': ['cao'],
    '⻀': ['cao'],
    '阝': ['er', 'fu', 'yi'],
    '卩': ['er', 'jie'],
    '⻖': ['er', 'fu'],
    '⻗': ['er', 'yi'],
    '亻': ['ren'],
    '人': ['ren'],
    '彳': ['ren', 'chi'],
    '⺅': ['ren'],
    '𠆢': ['ren'],
    '扌': ['shou'],
    '手': ['shou'],
    '龵': ['shou'],
    '忄': ['xin'],
    '心': ['xin'],
    '⺖': ['xin'],
    '⺗': ['xin'],
    '灬': ['huo', 'biao'],
    '火': ['huo'],
    '⺣': ['huo', 'biao'],
    '宀': ['bao', 'gai', 'mian'],
    '冖': ['tu', 'gai', 'mi'],
    '钅': ['jin'],
    '釒': ['jin'],
    '金': ['jin'],
    '⻐': ['jin'],
    '讠': ['yan'],
    '訁': ['yan'],
    '言': ['yan'],
    '纟': ['si', 'mi'],
    '糹': ['si', 'mi'],
    '糸': ['mi', 'si'],
    '⺰': ['si', 'mi'],
    '⺱': ['si', 'mi'],
    '犭': ['quan'],
    '犬': ['quan'],
    '⺲': ['quan'],
    '辶': ['zou', 'chuo'],
    '辵': ['chuo'],
    '⻌': ['zou', 'chuo'],
    '⻍': ['zou', 'chuo'],
    '礻': ['shi'],
    '示': ['shi'],
    '⺬': ['shi'],
    '衤': ['yi'],
    '衣': ['yi'],
    '⺭': ['yi'],
    '𧘇': ['yi'],
    '饣': ['shi'],
    '飠': ['shi'],
    '食': ['shi'],
    '⻠': ['shi'],
    '⻡': ['shi'],
    '𩙿': ['shi'],
    '口': ['kou'],
    '囗': ['kou', 'wei'],
    '木': ['mu'],
    '日': ['ri'],
    '曰': ['ri'],
    '月': ['yue'],
    '肉': ['rou'],
    '⺼': ['rou', 'yue'],
    '⺝': ['yue', 'rou'],
    '冫': ['shui', 'bing', 'liang'],
    '疒': ['bing'],
    '广': ['guang'],
    '穴': ['xue'],
    '竹': ['zhu'],
    '⺮': ['zhu'],
    '𥫗': ['zhu'],
    '雨': ['yu'],
    '门': ['men'],
    '門': ['men'],
    '车': ['che'],
    '車': ['che'],
    '牛': ['niu'],
    '牜': ['niu'],
    '⺧': ['niu'],
    '羊': ['yang'],
    '⺶': ['yang'],
    '⺷': ['yang'],
    '𦍌': ['yang'],
    '虫': ['chong'],
    '足': ['zu'],
    '⻊': ['zu'],
    '𧾷': ['zu'],
    '王': ['wang', 'yu'],
    '玉': ['yu'],
    '⺩': ['wang', 'yu'],
    '𤣩': ['wang', 'yu'],
    '刀': ['dao'],
    '刂': ['dao'],
    '⺈': ['dao'],
    '⺉': ['dao'],
    '土': ['tu'],
    '士': ['shi'],
    '石': ['shi'],
    '女': ['nv', 'nu'],
    '子': ['zi'],
    '弓': ['gong'],
    '方': ['fang'],
    '巾': ['jin'],
    '山': ['shan'],
    '田': ['tian'],
    '目': ['mu'],
    '禾': ['he'],
    '鸟': ['niao'],
    '鳥': ['niao'],
    '鱼': ['yu'],
    '魚': ['yu'],
    '羽': ['yu'],
    '舟': ['zhou'],
    '米': ['mi'],
    '贝': ['bei'],
    '貝': ['bei'],
    '走': ['zou'],
    '身': ['shen'],
    '辛': ['xin'],
    '辰': ['chen'],
    '里': ['li'],
    '马': ['ma'],
    '馬': ['ma'],
    '骨': ['gu'],
    '鬼': ['gui'],
    '音': ['yin'],
    '页': ['ye'],
    '頁': ['ye'],
    '风': ['feng'],
    '風': ['feng'],
    '鹿': ['lu'],
    '麻': ['ma'],
    '黑': ['hei'],
    '龙': ['long'],
    '龍': ['long'],
    '龟': ['gui'],
    '龜': ['gui'],
    '齿': ['chi'],
    '齊': ['qi'],
    '齐': ['qi'],
    '角': ['jiao'],
    '皿': ['min'],
    '力': ['li'],
    '又': ['you'],
    '十': ['shi'],
    '厂': ['chang'],
    '卜': ['bu'],
    '八': ['ba'],
    '儿': ['er'],
    '几': ['ji'],
    '二': ['er'],
    '寸': ['cun'],
    '小': ['xiao'],
    '尸': ['shi'],
    '户': ['hu'],
    '戶': ['hu'],
    '文': ['wen'],
    '斗': ['dou'],
    '斤': ['jin'],
    '无': ['wu'],
    '欠': ['qian'],
    '止': ['zhi'],
    '歹': ['dai'],
    '殳': ['shu'],
    '毋': ['wu'],
    '比': ['bi'],
    '毛': ['mao'],
    '氏': ['shi'],
    '气': ['qi'],
    '爪': ['zhua'],
    '父': ['fu'],
    '爻': ['yao'],
    '爿': ['pan', 'qiang'],
    '片': ['pian'],
    '牙': ['ya'],
    '玄': ['xuan'],
    '瓜': ['gua'],
    '瓦': ['wa'],
    '甘': ['gan'],
    '生': ['sheng'],
    '用': ['yong'],
    '疋': ['pi'],
    '白': ['bai'],
    '皮': ['pi'],
    '矢': ['shi'],
    '老': ['lao'],
    '⺹': ['lao'],
    '耒': ['lei'],
    '耳': ['er'],
    '聿': ['yu'],
    '臣': ['chen'],
    '自': ['zi'],
    '至': ['zhi'],
    '臼': ['jiu'],
    '舌': ['she'],
    '舛': ['chuan'],
    '艮': ['gen'],
    '色': ['se'],
    '虍': ['hu'],
    '血': ['xue'],
    '行': ['xing'],
    '见': ['jian'],
    '見': ['jian'],
    '谷': ['gu'],
    '豆': ['dou'],
    '豕': ['shi'],
    '豸': ['zhi'],
    '赤': ['chi'],
    '酉': ['you'],
    '采': ['cai'],
    '隹': ['zhui'],
    '革': ['ge'],
    '韋': ['wei'],
    '韦': ['wei'],
    '韭': ['jiu'],
    '香': ['xiang'],
    '高': ['gao'],
    '髟': ['biao'],
    '鬥': ['dou'],
    '鬯': ['chang'],
    '鬲': ['ge', 'li'],
    '鹵': ['lu'],
    '卤': ['lu'],
    '麥': ['mai'],
    '麦': ['mai'],
    '黃': ['huang'],
    '黄': ['huang'],
    '黍': ['shu'],
    '黹': ['zhi'],
    '黽': ['min'],
    '黾': ['min'],
    '鼎': ['ding'],
    '鼓': ['gu'],
    '鼠': ['shu'],
    '鼻': ['bi'],
    '齒': ['chi'],
    '龍': ['long'],
    '龜': ['gui'],
    '龠': ['yue'],
    '乂': ['yi', 'cha'],
    '匚': ['fang', 'kuang'],
    '冂': ['jiong', 'kuang', 'tong'],
    '凵': ['qian', 'kuang', 'kan'],
    '勹': ['bao', 'gou'],
    '彡': ['shan', 'pie'],
    '罒': ['si', 'wang'],
    '四': ['si'],
    '网': ['wang'],
    '⺫': ['wang', 'si'],
    '丬': ['pan', 'qiang', 'zhuang', 'jiang'],
    '攵': ['pu', 'wen', 'fanwen'],
    '攴': ['pu', 'wen'],
    '⺙': ['pu', 'wen'],
    '夂': ['zhi', 'wen', 'zhewen', 'dong'],
    '夊': ['sui', 'wen'],
    '龸': ['dang'],
    '⺌': ['xiao'],
    '⺕': ['shan'],
    '龶': ['feng'],
    '亠': ['wen', 'tou'],
    '爫': ['zhua', 'zhao'],
    '长': ['chang', 'zhang'],
    '長': ['chang', 'zhang'],
    '⻑': ['chang', 'zhang'],
    '镸': ['chang', 'zhang'],
}

# Merge all STROKE_DATA into RADICAL_PINYIN
for _st_ch, _st_info in STROKE_DATA.items():
    if _st_ch not in RADICAL_PINYIN:
        RADICAL_PINYIN[_st_ch] = []
    for _py in _st_info['pys']:
        if _py not in RADICAL_PINYIN[_st_ch]:
            RADICAL_PINYIN[_st_ch].append(_py)

# Merge Excel Sheet 2 (难认拆字部件读音对照表) mappings
_base_dir = os.path.dirname(os.path.abspath(__file__)) if '__file__' in globals() else 'data'
_excel_pinyin_path = os.path.join(_base_dir, "excel_sheet2_pinyin.json")
if not os.path.exists(_excel_pinyin_path):
    _excel_pinyin_path = "excel_sheet2_pinyin.json"
if os.path.exists(_excel_pinyin_path):
    with open(_excel_pinyin_path, 'r', encoding='utf-8') as _ef:
        _excel_pys = json.load(_ef)
        for _c, _pys in _excel_pys.items():
            if _c not in RADICAL_PINYIN:
                RADICAL_PINYIN[_c] = []
            for _py in _pys:
                if _py not in RADICAL_PINYIN[_c]:
                    RADICAL_PINYIN[_c].append(_py)
    print(f"Loaded {len(_excel_pys)} component mappings from Excel Sheet 2 (excel_sheet2_pinyin.json).")

# Standard Kangxi radicals and common atomic radicals that should not be decomposed further when computing direct keys
BASIC_RADICALS = set(
    '一丨丿丶乙亅二亠人儿入八冂冖冫几凵刀力勹匕匚匸十卜卩厂厶又'
    '口囗土士夂夕大女子宀寸小尢尸屮山巛工己巾干幺广廴廾弋弓彐彡彳'
    '心戈戶手支攴文斗斤方无日曰月木欠止歹殳毋比毛氏气水火爪父爻爿片牙牛犬'
    '玄瓜瓦甘生用田疋疒癶白皮皿目矛矢石示禸禾穴立'
    '竹米糸缶网羊羽老而耒耳聿肉臣自至臼舌舛舟艮色艸虍虫血行衣襾'
    '見角言谷豆豕豸貝赤走足身車辛辰辵邑酉釆里'
    '金長門阜隶隹雨靑非面革韋韭音頁風飛食首香'
    '馬骨高髟鬥鬯鬲鬼魚鳥鹵鹿麥麻黃黍黑黹黽鼎鼓鼠鼻齊齒龍龜龠'
    '讠钅纟饣氵忄扌艹灬⺡⺣⺅龵⺖⺗⺝⺾⻀⺬⺭⻐⻑⻠⻡⺰⺱⺲⻌⻍⻖⻗⺩⺮⺈⺉⺶⺷⺧'
    '贝车见页风门鸟鱼马长龙齿'
)

STROKE_CHARS = set('一丨丿丶乙亅⺀𠄌')
def is_stroke_char(c):
    if not c:
        return False
    if c in STROKE_CHARS:
        return True
    if len(c) == 1:
        cp = ord(c)
        return 0x31C0 <= cp <= 0x31EF
    return False

def expand_direct_components(subs, char_tree, max_variants=16):
    """
    Expand composite/intermediate components in direct_subs (e.g. 畐 -> [𠮛, 田] -> [一, 口, 田])
    so users can type natural intuitive components and get Tier 1 direct matching.
    Prune overly deep leaf expansions into pure single strokes to avoid file bloat and false matches.
    """
    if not subs:
        return []
    results = [subs]
    queue = [subs]
    while queue and len(results) < max_variants:
        curr = queue.pop(0)
        for i, c in enumerate(curr):
            if c not in BASIC_RADICALS and c in char_tree:
                children = char_tree[c]
                if children and children != [c]:
                    new_seq = curr[:i] + children + curr[i+1:]
                    # If this expansion turns entirely into 2+ primitive strokes, do not keep it unless the character itself is small (len(subs) <= 2)
                    if len(new_seq) >= 2 and all(is_stroke_char(x) for x in new_seq) and len(subs) > 2:
                        continue
                    if new_seq not in results:
                        results.append(new_seq)
                        queue.append(new_seq)
                        if len(results) >= max_variants:
                            break
    return results

def load_character_priorities():
    """Load character priority weights. Common characters get higher priority."""
    weights = {}
    
    # 1. 通用规范汉字表 (8,105 chars)
    if os.path.exists(CHARSET_PATH):
        try:
            with open(CHARSET_PATH, 'r', encoding='utf-8', errors='ignore') as f:
                rank = 0
                for line in f:
                    if '\t' in line:
                        ch = line.split('\t')[0].strip()
                        if len(ch) == 1:
                            rank += 1
                            weights[ch] = 2000000 - rank
        except Exception as e:
            print("Warning: could not read wanxiang_charset:", e)
            
    return weights

def calculate_char_weight(ch, weights):
    if ch == '𰻝' and '𰻞' in weights:
        return weights['𰻞'] - 1
    if ch in weights:
        return weights[ch]
    cp = ord(ch)
    # CJK Unified Ideographs Basic (U+4E00 ~ U+9FFF)
    if 0x4E00 <= cp <= 0x9FFF:
        return 1000000 - (cp - 0x4E00)
    # CJK Compatibility Ideographs (U+F900 ~ U+FAFF)
    elif 0xF900 <= cp <= 0xFAFF:
        return 600000 - (cp - 0xF900)
    # CJK Unified Ideographs Extension A (U+3400 ~ U+4DBF)
    elif 0x3400 <= cp <= 0x4DBF:
        return 500000 - (cp - 0x3400)
    # Kangxi Radicals (U+2F00 ~ U+2FDF)
    elif 0x2F00 <= cp <= 0x2FDF:
        return 400000 - (cp - 0x2F00)
    # CJK Radicals Supplement (U+2E80 ~ U+2EFF)
    elif 0x2E80 <= cp <= 0x2EFF:
        return 300000 - (cp - 0x2E80)
    # CJK Strokes (U+31C0 ~ U+31EF)
    elif 0x31C0 <= cp <= 0x31EF:
        return 350000 - (cp - 0x31C0)
    # CJK Compatibility Ideographs Supplement (U+2F800 ~ U+2FA1F)
    elif 0x2F800 <= cp <= 0x2FA1F:
        return 150000 - (cp - 0x2F800)
    # CJK Unified Ideographs Extension B ~ J (U+20000+)
    else:
        return max(1, 100000 - (cp - 0x20000))

BLOCK_NAMES = [
    '基本', '扩A', '扩B', '扩C', '扩D', '扩E', '扩F', '扩G',
    '扩H', '扩I', '扩J', '兼容区', '兼容补充', '部首补充', '康熙部首', '笔画', 'CJK'
]
BLOCK_TO_ID = {name: i for i, name in enumerate(BLOCK_NAMES)}

def get_unicode_block(cp):
    if 0x4E00 <= cp <= 0x9FFF:
        name = '基本'
    elif 0x3400 <= cp <= 0x4DBF:
        name = '扩A'
    elif 0x20000 <= cp <= 0x2A6DF:
        name = '扩B'
    elif 0x2A700 <= cp <= 0x2B739:
        name = '扩C'
    elif 0x2B740 <= cp <= 0x2B81D:
        name = '扩D'
    elif 0x2B820 <= cp <= 0x2CEAD:
        name = '扩E'
    elif 0x2CEB0 <= cp <= 0x2EBE0:
        name = '扩F'
    elif 0x30000 <= cp <= 0x3134A:
        name = '扩G'
    elif 0x31350 <= cp <= 0x323AF:
        name = '扩H'
    elif 0x2EBF0 <= cp <= 0x2EE5D:
        name = '扩I'
    elif 0x323B0 <= cp <= 0x3347F:
        name = '扩J'
    elif 0xF900 <= cp <= 0xFAFF:
        name = '兼容区'
    elif 0x2F800 <= cp <= 0x2FA1F:
        name = '兼容补充'
    elif 0x2E80 <= cp <= 0x2EFF:
        name = '部首补充'
    elif 0x2F00 <= cp <= 0x2FDF:
        name = '康熙部首'
    elif 0x31C0 <= cp <= 0x31EF:
        name = '笔画'
    else:
        name = 'CJK'
    return BLOCK_TO_ID[name], name

def main():
    print("Step 1: Parsing IDS database...")
    char_tree = {}
    char_all_trees = collections.defaultdict(list)
    char_primary_ids = {}
    
    idc = set('⿰⿱⿲⿳⿴⿵⿶⿷⿸⿹⿺⿻⿼⿽⿾⿿〾㇯？')
    
    def parse_babelstone_file(filepath):
        if not os.path.exists(filepath): return
        print(f"Loading base BabelStone IDS from {filepath}...")
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'): continue
                parts = line.split('\t')
                if len(parts) >= 3 and parts[0].startswith('U+'):
                    ch = parts[1]
                    selected = parts[2]
                    for p in parts[2:]:
                        if '(G' in p or ('^' in p and not selected.startswith('^')):
                            selected = p
                            break
                    def replace_curly(match):
                        m = match.group(1)
                        if m.isdigit():
                            num = int(m)
                            if num == 88: return '亼'
                            if num in CURLY_MAP: return CURLY_MAP[num]
                            return ''
                        if len(m) == 1 and ord(m) > 127: return m
                        return ''
                    clean_seq = re.sub(r'\(.*?\)', '', selected).replace('^', '').replace('$', '').strip()
                    clean_seq = re.sub(r'\{([^{}]+)\}', replace_curly, clean_seq)
                    if ch not in char_primary_ids:
                        char_primary_ids[ch] = clean_seq
                    subs = [tok for tok in clean_seq if tok not in idc and tok != ch and is_valid_comp(tok)]
                    if subs:
                        if ch not in char_tree:
                            char_tree[ch] = subs
                        char_all_trees[ch].append(subs)

    def parse_zitools_file(filepath, is_primary_source=False):
        if not os.path.exists(filepath): return
        mode_label = "primary authentic (Level 1)" if is_primary_source else "normalized (Level 2)"
        print(f"Loading zi.tools IDS {mode_label} from {filepath}...")
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'): continue
                parts = line.split('\t')
                if len(parts) >= 2 and len(parts[0]) == 1 and not parts[0].startswith('U+'):
                    ch = parts[0]
                    all_raw = []
                    for col_idx, col in enumerate(parts[1:]):
                        for item in col.split(';'):
                            item = item.strip()
                            if item:
                                all_raw.append((col_idx, item))
                    if not all_raw: continue

                    selected = all_raw[0][1]
                    for col_idx, item in all_raw:
                        if col_idx == 0 and any(tag in item for tag in ('(.)', '(G)', '(.,')):
                            selected = item
                            break
                    clean_seq = re.sub(r'\([a-zA-Z0-9\.,_\-]+\)$', '', selected).strip()
                    clean_seq = re.sub(r'#\(([^()]+)\)', r'\1', clean_seq).replace('#', '')
                    clean_seq = re.sub(r'\{([^{}]+)\}', r'\1', clean_seq).strip()
                    if not clean_seq:
                        clean_seq = ch

                    is_valid_ids = len(clean_seq) > 0 and clean_seq[0] in idc
                    prior_is_valid = ch in char_primary_ids and len(char_primary_ids[ch]) > 0 and char_primary_ids[ch][0] in idc

                    if is_valid_ids:
                        if is_primary_source or not prior_is_valid:
                            char_primary_ids[ch] = clean_seq
                    elif not prior_is_valid:
                        char_primary_ids[ch] = ch

                    primary_tokens = [c for c in clean_seq if c not in idc and c != ch and not c.isspace() and is_valid_comp(c)]
                    if primary_tokens:
                        if is_primary_source or ch not in char_tree:
                            char_tree[ch] = primary_tokens

                    seen_trees = set(tuple(t) for t in char_all_trees[ch])
                    if primary_tokens and tuple(primary_tokens) not in seen_trees:
                        seen_trees.add(tuple(primary_tokens))
                        if is_primary_source:
                            char_all_trees[ch].insert(0, primary_tokens)
                        else:
                            char_all_trees[ch].append(primary_tokens)

                    for col_idx, item in all_raw:
                        c_clean = re.sub(r'\([a-zA-Z0-9\.,_\-]+\)$', '', item).strip()
                        c_clean = re.sub(r'#\(([^()]+)\)', r'\1', c_clean).replace('#', '')
                        c_clean = re.sub(r'\{([^{}]+)\}', r'\1', c_clean).strip()
                        if c_clean and c_clean != ch:
                            tokens = [c for c in c_clean if c not in idc and c != ch and not c.isspace() and is_valid_comp(c)]
                            if tokens:
                                sig = tuple(tokens)
                                if sig not in seen_trees:
                                    seen_trees.add(sig)
                                    char_all_trees[ch].append(tokens)

    parse_babelstone_file(BABELSTONE_IDS_PATH)
    parse_zitools_file(ZITOOLS_LV2_PATH, is_primary_source=False)
    parse_zitools_file(ZITOOLS_LV1_PATH, is_primary_source=True)

    # Step 1a2: Injecting intuitive decomposing trees for characters with missing/variant/pseudo components
    INTUITIVE_CUSTOM_TREES = {
        # 步：下半部为少去一撇（步字底），支持 止 + 少
        '步': [['止', '少']],
        # 祭：左上为肉/月（变体），或多一点的夕；右上为又；下方为示。支持 月又示 / 夕又示 / 肉又示
        '祭': [['月', '又', '示'], ['夕', '又', '示'], ['肉', '又', '示']],
        # 象：上方为刀字头(⺈/刀)，中间为横放的日(日/口)，整体含豕变形。支持 刀豕 / 刀日豕 / 刀日 / ⺈豕 / ⺈日豕 / ⺈日
        '象': [['刀', '豕'], ['刀', '日', '豕'], ['刀', '日'], ['⺈', '豕'], ['⺈', '日', '豕'], ['⺈', '日']],
        # 𰻝 简体 biáng: 支持 长马长
        '𰻝': [['长', '马', '长'], ['穴', '长', '马', '长'], ['穴', '马', '心']],
        # 𰻞 繁体 biáng: 支持 长马长 / 長馬長
        '𰻞': [['长', '马', '长'], ['長', '馬', '長'], ['穴', '长', '马', '长'], ['穴', '马', '心']],
    }
    for _ich, _itrees in INTUITIVE_CUSTOM_TREES.items():
        if _ich not in char_tree:
            char_tree[_ich] = _itrees[0]
        for _it in _itrees:
            char_all_trees[_ich].append(_it)

    print(f"Loaded {len(char_tree)} characters with structure across all IDS sources.")

    print("Step 1b: Injecting Kangxi Radicals, Compatibility Ideographs, and Radicals Supplement...")
    eq_unified_map = {}
    if os.path.exists(EQUIVALENT_UNIFIED_PATH):
        try:
            with open(EQUIVALENT_UNIFIED_PATH, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'): continue
                    parts = [p.strip() for p in line.split(';')]
                    if len(parts) >= 2:
                        src = parts[0]
                        target = parts[1].split()[0]
                        if '..' in src:
                            s, e = src.split('..')
                            for cp in range(int(s, 16), int(e, 16) + 1):
                                eq_unified_map[cp] = int(target, 16)
                        else:
                            eq_unified_map[int(src, 16)] = int(target, 16)
        except Exception as e:
            print("Warning: failed to read EquivalentUnifiedIdeograph.txt:", e)

    def resolve_unified_char(cp, ch):
        norm = unicodedata.normalize('NFKD', ch)
        if norm != ch and len(norm) == 1:
            return norm
        if cp in eq_unified_map:
            return chr(eq_unified_map[cp])
        if cp == 0x2E80:
            return '冫'
        return None

    supplementary_ranges = [
        range(0x2F00, 0x2FD6),   # 康熙部首 (U+2F00 ~ U+2FD5)
        range(0x2E80, 0x2EF4),   # CJK 部首补充 (U+2E80 ~ U+2EF3)
        range(0x31C0, 0x31E4),   # CJK 笔画扩展 (U+31C0 ~ U+31E3)
        range(0xF900, 0xFB00),   # CJK 兼容汉字 (U+F900 ~ U+FAFF)
        range(0x2F800, 0x2FA20), # CJK 兼容汉字补充 (U+2F800 ~ U+2FA1F)
    ]

    injected_count = 0
    for rng in supplementary_ranges:
        for cp in rng:
            ch = chr(cp)
            if ch in char_tree and ch in char_primary_ids:
                continue
            try:
                uname = unicodedata.name(ch)
            except ValueError:
                continue
            if ch in STROKE_DATA:
                injected_count += 1
                st_name = STROKE_DATA[ch]['name']
                char_primary_ids[ch] = st_name
                canon_ch = resolve_unified_char(cp, ch)
                if canon_ch and canon_ch in char_tree:
                    char_tree[ch] = list(char_tree[canon_ch])
                    char_all_trees[ch].append(list(char_tree[canon_ch]))
                else:
                    char_tree[ch] = [ch]
                    char_all_trees[ch].append([ch])
                continue

            canon = resolve_unified_char(cp, ch)
            if canon:
                injected_count += 1
                if canon in char_primary_ids:
                    char_primary_ids[ch] = char_primary_ids[canon]
                else:
                    char_primary_ids[ch] = canon
                if canon in char_tree:
                    char_tree[ch] = list(char_tree[canon])
                else:
                    char_tree[ch] = [canon]

    print(f"Injected {injected_count} supplementary characters (Kangxi, Compatibility, Radical Supplement, Strokes).")
    print(f"Total structured characters: {len(char_tree)}.")

    print("Step 2: Computing recursive component closure and counts...")
    def get_counts(ch, memo, visiting):
        if ch in memo: return memo[ch]
        if ch in visiting: return collections.Counter()
        visiting.add(ch)
        counts = collections.Counter()
        if ch in char_tree:
            for sub in char_tree[ch]:
                counts[sub] += 1
                for k, v in get_counts(sub, memo, visiting).items():
                    counts[k] += v
        visiting.remove(ch)
        memo[ch] = counts
        return counts

    memo = {}
    all_char_counts = {}
    for ch in char_tree:
        base_counts = collections.Counter(get_counts(ch, memo, set()))
        for alt_subs in char_all_trees.get(ch, []):
            alt_counts = collections.Counter()
            for sub in alt_subs:
                alt_counts[sub] += 1
                for k, v in get_counts(sub, memo, set()).items():
                    alt_counts[k] += v
            for k, v in alt_counts.items():
                base_counts[k] = max(base_counts[k], v)
        all_char_counts[ch] = base_counts

    # Build equiv lookup
    equiv_map = collections.defaultdict(set)
    for group in EQUIV_GROUPS:
        for item in group:
            equiv_map[item].update(group)

    print("Step 3: Building inverted index with component expansion...")
    weights = load_character_priorities()
    inverted = collections.defaultdict(list) # comp_key -> list of (char, weight)

    expanded_counts_by_char = {}
    for ch, counts in all_char_counts.items():
        w = calculate_char_weight(ch, weights)
        # Apply component equivalents:
        # An alias acquires the MAXIMUM count of any member present in this character.
        # NEVER sum across alias variants, because different IDS sources/trees use different
        # representations of the same radical (e.g. ⺼ vs 月 or 氵 vs 水).
        expanded_counts = collections.Counter(counts)
        for group in EQUIV_GROUPS:
            max_in_group = max((counts[c] for c in group if c in counts), default=0)
            if max_in_group > 0:
                for c in group:
                    expanded_counts[c] = max(expanded_counts[c], max_in_group)
        expanded_counts_by_char[ch] = expanded_counts

        for comp, count in expanded_counts.items():
            if not is_valid_comp(comp): continue
            inverted[comp].append((ch, w))
            # Multiplicity keys (e.g. 木*2, 木*3) - exclude primitive strokes (e.g. ㇚*2, 一*3) to avoid index bloat
            if not is_stroke_char(comp):
                for k in range(2, min(count + 1, 5)):
                    inverted[f"{comp}*{k}"].append((ch, w))

    print("Step 4: Sorting postings by character frequency...")
    sorted_inverted = {}
    for comp, char_list in inverted.items():
        # Sort by weight descending
        char_list.sort(key=lambda x: x[1], reverse=True)
        # Combine into continuous string
        sorted_inverted[comp] = "".join(x[0] for x in char_list)

    print("Step 5: Adding Pinyin mappings to inverted index...")
    # Map pinyin directly to component strings
    pinyin_to_comps = collections.defaultdict(set)
    for comp in list(sorted_inverted.keys()):
        if '*' in comp: continue
        if comp in RADICAL_PINYIN:
            for py in RADICAL_PINYIN[comp]:
                pinyin_to_comps[py].add(comp)
        else:
            try:
                pys = pypinyin.pinyin(comp, style=pypinyin.Style.NORMAL, errors='ignore')
                if pys and pys[0]:
                    py_str = "".join(pys[0]).lower()
                    if py_str.isalpha():
                        pinyin_to_comps[py_str].add(comp)
            except Exception:
                pass

    # Ensure all components and strokes defined in RADICAL_PINYIN are added
    for comp, py_list in RADICAL_PINYIN.items():
        for py in py_list:
            pinyin_to_comps[py].add(comp)

    print(f"Mapped {len(pinyin_to_comps)} pinyin keys to components.")

    print(f"Step 6: Writing {OUTPUT_INDEX}...")
    RADICAL_PREFERRED_ORDER = {
        'zhe': [
            '乙', '乚', '乛', '𠃊', '𠃍', '𠃋', '𠃌',
            '㇕', '㇗', '㇄', '㇅', '㇆', '㇇', '㇈', '㇉', '㇊',
            '㇋', '㇌', '㇍', '㇎', '㇖', '㇘', '㇛', '㇜', '㇞',
            '㇟', '㇠', '㇡', '㇢', '㇂', '㇁', '亅', '㇃',
            '𠃉', '𠃑', '𠄌', '𠄎', '𡿨', '𬼂'
        ],
        'shui': ['氵', '水', '氺', '⺡', '冫'],
        'cao': ['艹', '艸', '⺾', '⻀', '屮', '廾', '卄'],
        'er': ['阝', '卩', '⻖', '⻗', '儿', '兒'],
        'ren': ['亻', '人', '彳', '⺅', '𠆢', '𠂉'],
        'shou': ['扌', '手', '龵'],
        'huo': ['灬', '火', '⺣'],
        'xin': ['忄', '心', '⺖', '⺗'],
        'jin': ['钅', '金', '釒', '⻐'],
        'yan': ['讠', '言', '訁'],
        'si': ['纟', '糸', '糹', '⺰', '⺱', '丝', '厶', '龴'],
        'quan': ['犭', '犬', '⺲'],
        'zou': ['辶', '辵', '⻌', '⻍', '龰', '廴'],
        'wen': ['文', '攵', '夂', '夊', '亠', '⺙', '攴'],
        'dang': ['龸', '当', '當'],
        'xiao': ['小', '⺌', '𡭔'],
        'shan': ['山', '⺕', '彐', '𫜹', '𬼖'],
        'feng': ['丰', '龶'],
        'ge': ['鬲', '戈', '革', '𭠍'],
        'pan': ['爿', '丬'],
        'zhua': ['爪', '爫'],
        'chang': ['长', '長', '厂', '鬯'],
        'zhang': ['长', '長'],
        'kuang': ['凵', '冂', '匚', '匸', 'コ'],
        'gai': ['宀', '冖', '龸', '𰃮'],
        'xing': ['兴', '𭕄'],
        'juan': ['龹', '卷', '券'],
        'heng': ['一', '㇐'],
        'shu': ['丨', '亅', '㇑'],
        'pie': ['丿', '㇒'],
        'dian': ['丶', '乀', '㇔'],
        'qian': ['佥', '僉', '㑒', '䒑'],
        'dong': ['东', '東', '𫠣'],
        'chuan': ['川', '巛', '𫶧'],
        'mu': ['木', '目', '母', '亩'],
        'kou': ['口', '囗'],
        'tu': ['土', '士'],
        'ri': ['日', '曰'],
        'yue': ['月', '肉', '⺝', '⺼'],
        'tian': ['田'],
        'he': ['禾'],
        'mi': ['米'],
        'nv': ['女'],
        'zi': ['子'],
        'ma': ['马', '馬'],
        'niao': ['鸟', '鳥'],
        'yu': ['鱼', '魚', '雨', '羽', '玉'],
        'bai': ['白', '百'],
        'shi': ['十', '石', '士', '尸', '示', '食', '矢', '氏', '礻', '饣', '丆', '𠂇'],
        'che': ['车', '車'],
        'fang': ['方', '匚'],
        'gong': ['工', '弓', '共'],
        'wang': ['王', '网', '罒', '⺫'],
        'li': ['力', '立', '里', '刂'],
        'dao': ['刀', '刂', '⺈'],
        'chi': ['尺', '齿', '彳', '赤'],
        'zhu': ['竹', '⺮', '主'],
    }

    def comp_sort_key(py, c):
        if py in RADICAL_PREFERRED_ORDER and c in RADICAL_PREFERRED_ORDER[py]:
            return (0, RADICAL_PREFERRED_ORDER[py].index(c))
        is_rad = c in RADICAL_PINYIN
        return (1 if is_rad else 2, c)

    with open(OUTPUT_INDEX, 'w', encoding='utf-8') as f:
        # Write pinyin -> components mappings first
        for py, comps in sorted(pinyin_to_comps.items()):
            sorted_comps = sorted(comps, key=lambda c: comp_sort_key(py, c))
            f.write(f"@py\t{py}\t{' '.join(sorted_comps)}\n")
        
        # Write component -> chars postings
        for comp, char_str in sorted(sorted_inverted.items()):
            f.write(f"{comp}\t{char_str}\n")

    print(f"Step 7: Writing {OUTPUT_META} (Pinyin, IDS, direct keys, and ranking stats)...")
    canon_map = {}
    for g in EQUIV_GROUPS:
        rep = sorted(g)[0]
        for c in g:
            canon_map[c] = rep

    def canon(c):
        return canon_map.get(c, c)

    def to_key(comps):
        return ",".join(canon(c) for c in comps)

    meta_records = []
    with open(OUTPUT_META, 'w', encoding='utf-8') as f:
        for ch, seq in char_primary_ids.items():
            if ch in STROKE_DATA:
                py_display = STROKE_DATA[ch]['py_display']
                clean_seq = STROKE_DATA[ch]['name']
            else:
                try:
                    pys = pypinyin.pinyin(ch, style=pypinyin.Style.TONE, errors='default')
                    py_display = pys[0][0] if pys and pys[0] else ""
                    if py_display == ch or not py_display:
                        # Fallback to canonical char's pinyin for Kangxi / Compatibility / Radicals
                        canon_ch = resolve_unified_char(ord(ch), ch)
                        if canon_ch:
                            c_pys = pypinyin.pinyin(canon_ch, style=pypinyin.Style.TONE, errors='default')
                            py_display = c_pys[0][0] if c_pys and c_pys[0] and c_pys[0][0] != canon_ch else ""
                        else:
                            py_display = ""
                except Exception:
                    py_display = ""
                clean_seq = re.sub(r'\{([^{}]+)\}', r'\1', seq)
            direct_keys = set()
            all_trees = char_all_trees.get(ch, [])
            if not all_trees and ch in char_tree:
                all_trees = [char_tree[ch]]
            for subs in all_trees:
                if subs:
                    for var_subs in expand_direct_components(subs, char_tree, max_variants=16):
                        direct_keys.add(to_key(var_subs))
            
            counts = all_char_counts.get(ch, collections.Counter())
            # Add multiplicity keys for reduplications (e.g. 森 -> 木,木,木; 品 -> 口,口,口)
            # Only add meaningful radical/semantic components, strictly exclude primitive strokes
            exp_counts = expanded_counts_by_char.get(ch, {})
            for comp, cnt in exp_counts.items():
                c_canon = canon(comp)
                if cnt >= 2 and is_valid_comp(comp) and not is_stroke_char(comp) and not is_stroke_char(c_canon):
                    direct_keys.add(",".join(sorted([c_canon] * cnt)))
            
            keys_str = "|".join(sorted(direct_keys))
            tot_comps = len(counts)
            w = calculate_char_weight(ch, weights)
            freq_score = w
            
            cp = ord(ch)
            block_id, block = get_unicode_block(cp)
            u_code = f"{cp:04X}"
            f.write(f"{ch}\t{py_display}\t{clean_seq}\t{u_code}\t{block}\t{keys_str}\t{tot_comps}\t{freq_score}\n")
            meta_records.append((cp, freq_score, block_id, tot_comps, py_display, clean_seq, keys_str))

    print("Step 8: Building IDS4 single-file data (ids_data.bin)...")
    import struct

    # ---- C2 canon: identical to the runtime CanonMap in src/ids_store.cc ----
    C2 = {
        "氵": "⺡", "水": "⺡", "⺡": "⺡", "氺": "⺡",
        "灬": "⺣", "火": "⺣", "⺣": "⺣",
        "亻": "⺅", "人": "⺅", "𠆢": "⺅", "⺅": "⺅",
        "扌": "龵", "手": "龵", "龵": "龵",
        "忄": "⺖", "心": "⺖", "⺖": "⺖", "⺗": "⺖",
        "⺼": "肉", "月": "肉", "肉": "肉", "⺝": "肉",
        "艹": "⺾", "艸": "⺾", "⺾": "⺾", "⻀": "⺾", "草": "⺾",
        "礻": "⺬", "示": "⺬", "⺬": "⺬",
        "衤": "⺭", "衣": "⺭", "⺭": "⺭", "𧘇": "⺭",
        "釒": "⻐", "金": "⻐", "钅": "⻐", "⻐": "⻐", "⻑": "⻐",
        "飠": "⻠", "食": "⻠", "饣": "⻠", "⻠": "⻠", "⻡": "⻠", "𩙿": "⻠",
        "糹": "⺰", "糸": "⺰", "纟": "⺰", "⺰": "⺰", "⺱": "⺰",
        "犭": "⺲", "犬": "⺲", "⺲": "⺲",
        "辶": "⻌", "辵": "⻌", "⻌": "⻌", "⻍": "⻌",
        "阝": "⻖", "阜": "⻖", "邑": "⻖", "⻖": "⻖", "⻗": "⻖",
        "王": "⺩", "⺩": "⺩", "𤣩": "⺩", "玉": "⺩",
        "⺆": "冂", "冂": "冂",
        "攵": "⺙", "攴": "⺙", "⺙": "⺙",
        "耂": "⺹", "老": "⺹", "⺹": "⺹",
        "足": "⻊", "⻊": "⻊", "𧾷": "⻊",
        "四": "⺫", "罒": "⺫", "网": "⺫", "⺫": "⺫",
        "竹": "⺮", "⺮": "⺮", "𥫗": "⺮",
        "刀": "⺉", "刂": "⺉", "⺈": "⺉", "⺉": "⺉",
        "羊": "⺶", "⺶": "⺶", "⺷": "⺶", "𦍌": "⺶",
        "言": "讠", "讠": "讠", "訁": "讠",
        "号": "号", "號": "号",
        "牛": "牜", "牜": "牜", "⺧": "牜",
        "龍": "龙", "龙": "龙",
        "馬": "马", "马": "马",
        "鳥": "鸟", "鸟": "鸟",
        "魚": "鱼", "鱼": "鱼",
        "車": "车", "车": "车",
        "門": "门", "门": "门",
        "見": "见", "见": "见",
        "貝": "贝", "贝": "贝",
        "頁": "页", "页": "页",
        "風": "风", "风": "风",
        "飛": "飞", "飞": "飞",
        "黽": "黾", "黾": "黾",
        "齊": "齐", "齐": "齐",
        "齒": "齿", "齿": "齿",
        "長": "长", "长": "长",
        "撇": "㇒", "丿": "㇒", "㇒": "㇒",
        "横": "㇐", "一": "㇐", "㇐": "㇐",
        "竖": "㇑", "丨": "㇑", "㇑": "㇑",
        "点": "㇔", "丶": "㇔", "㇔": "㇔",
        "捺": "㇏", "乀": "㇏", "乁": "㇏", "㇏": "㇏",
        "提": "㇀", "㇀": "㇀",
        "折": "乛", "乛": "乛",
        "钩": "亅", "鉤": "亅", "亅": "亅",
    }

    def C2of(s):
        if len(s) >= 2 and s[0] == '{' and s[-1] == '}':
            inner = s[1:-1]
            return C2.get(inner, inner)
        return C2.get(s, s)

    def fnv32(tokens):
        h = 2166136261
        for t in tokens:
            h ^= (t & 0xFF); h = (h * 16777619) & 0xFFFFFFFF
            h ^= (t >> 8) & 0xFF; h = (h * 16777619) & 0xFFFFFFFF
        return h

    # ---- runtime AtomicComponents()，必须逐字一致 ----
    ATOMIC_COMPONENTS = {
        "木", "氵", "水", "火", "灬", "土", "金", "钅", "日", "月", "目", "口",
        "人", "亻", "手", "扌", "心", "忄", "女", "子", "艹", "言", "讠", "石",
        "田", "山", "刀", "刂", "力", "又", "十", "大", "小", "工", "弓", "广",
        "门", "马", "鸟", "鱼", "虫", "犭", "犬", "辶", "宀", "冖", "穴", "竹",
        "⺮", "米", "糸", "纟", "车", "足", "⻊", "雨", "页", "酉", "贝", "走",
        "身", "辛", "辰", "邑", "阝", "阜", "方", "斤", "止", "歹", "殳", "毛",
        "氏", "气", "白", "皮", "皿", "矢", "示", "礻", "禾", "立", "羽", "舟",
        "艮", "见", "角", "谷", "豆", "豕", "豸", "赤", "革", "音", "风", "飞",
        "食", "饣", "首", "香", "骨", "鬼", "黾", "鼎", "鼓", "鼠", "鼻", "齐",
        "齿", "龙", "龟",
        # Canon() 归一后的代表字形
        "⺡", "⺣", "⺅", "龵", "⺖", "⺾", "⺬", "⺭", "⻐", "⻠", "⺰", "⺲",
        "⻌", "⻖", "⺩", "⺙", "⺹", "⻊", "⺫", "⺮", "⺉", "⺶", "㇒", "㇐",
        "㇑", "㇔", "㇏", "㇀", "乛", "亅",
    }

    # ---- dense char id space ----
    MAX_CP = 0x33500
    meta_by_cp = {}
    for rec in meta_records:
        cp = rec[0]
        if cp < MAX_CP:
            meta_by_cp[cp] = rec
    all_cps = set(meta_by_cp.keys())
    for k, v in sorted_inverted.items():
        for ch in v:
            cp = ord(ch)
            if cp < MAX_CP:
                all_cps.add(cp)
    chars = sorted(all_cps)
    N = len(chars)
    id_of_cp = {cp: i for i, cp in enumerate(chars)}

    # ---- 预计算顶层叶子 / 原子部件（与运行时语义一致）----
    primary_ids = {}
    for cp in chars:
        rec = meta_by_cp.get(cp)
        primary_ids[cp] = rec[5] if rec is not None else ""

    leaves_orig = {}    # cp -> [原始字形]
    leaves_canon = {}   # cp -> [Canon 后字形]
    for cp in chars:
        raw = [c for c in primary_ids.get(cp, "")
               if not (0x2FF0 <= ord(c) <= 0x2FFB)]
        if not raw:
            raw = [chr(cp)]
        leaves_orig[cp] = raw
        leaves_canon[cp] = [C2of(c) for c in raw]

    def top_leaves_canon(c):
        cp = ord(c)
        cid = id_of_cp.get(cp)
        if cid is None:
            return [c]
        lv = leaves_canon.get(cp)
        if not lv:
            return [c]
        return lv

    # 与运行时 AtomicDecomposition 的“每顶层字符一份 cache”语义一致。
    def atom_decomp_top(cp):
        cache = {}

        def rec(c, depth):
            if c in cache:
                return cache[c]
            if depth > 2 or c in ATOMIC_COMPONENTS:
                r = [c]
                cache[c] = r
                return r
            lv = top_leaves_canon(c)
            if len(lv) <= 1:
                r = [c]
                cache[c] = r
                return r
            out = []
            for leaf in lv:
                if leaf == c:
                    out.append(leaf)
                else:
                    out.extend(rec(leaf, depth + 1))
            cache[c] = out
            return out

        return rec(C2of(chr(cp)), 0)

    atoms_by_cp = {}
    for cp in chars:
        atoms_by_cp[cp] = atom_decomp_top(cp)

    # ---- token vocabulary（包含预计算叶子/原子用到的全部字形）----
    token_set = set()
    for k in sorted_inverted.keys():
        token_set.add(k.split('*')[0])
    for py, comps in pinyin_to_comps.items():
        for c in comps:
            token_set.add(c)
    for rec in meta_records:
        for var in rec[6].split('|'):
            for c in var.split(','):
                if c:
                    token_set.add(c)
    for cp in chars:
        token_set.update(leaves_orig[cp])
        token_set.update(atoms_by_cp[cp])
    for s in list(token_set):
        token_set.add(C2of(s))
    tokens = sorted(token_set)
    tok_id = {t: i for i, t in enumerate(tokens)}
    NT = len(tokens)
    assert NT <= 65534, NT

    # ---- per-char ALTS / LEAVES / ATOMS / COMPSET / COLD + CHAR ----
    CHAR = bytearray()
    COLD_IDX = bytearray()
    ALTS = bytearray()
    LEAVES = bytearray()
    ATOMS = bytearray()
    CS = bytearray()
    COLD = bytearray()
    for i, cp in enumerate(chars):
        rec = meta_by_cp.get(cp)
        if rec is not None:
            freq_score, block_id, depth = rec[1], rec[2], rec[3]
            py_bytes = rec[4].encode('utf-8')
            ids_bytes = rec[5].encode('utf-8')
            keys_str = rec[6]
        else:
            freq_score, block_id, depth = 0, 0, 0
            py_bytes, ids_bytes, keys_str = b'', b'', ''

        variants = []
        seen_v = set()
        if keys_str:
            for var in keys_str.split('|'):
                tv = tuple(tok_id[C2of(c)] for c in var.split(',') if c and C2of(c) in tok_id)
                if tv and tv not in seen_v:
                    seen_v.add(tv)
                    variants.append(tv)
        groups = {}
        for tv in variants:
            groups.setdefault(len(tv), []).append(tv)
        len_mask = 0
        for L in groups:
            if 1 <= L <= 31:
                len_mask |= (1 << L)
        comp_sorted = sorted({t for tv in variants for t in tv})
        ch_str = chr(cp)
        ctok = tok_id.get(ch_str, tok_id.get(C2of(ch_str), 65535))

        alts_off = len(ALTS)
        ab = bytearray()
        glens = sorted(groups.keys())
        ab.append(len(glens) & 0xFF)
        for L in glens:
            vs = groups[L]
            ab.append(L & 0xFF)
            ab += struct.pack('<H', len(vs))
            for tv in vs:
                for t in tv:
                    ab += struct.pack('<H', t)
                ab += struct.pack('<I', fnv32(tv))
        ALTS += ab

        # LEAVES: u16 n + u16 token[n]；记录 2 字节对齐
        leaf_tokens = [tok_id[c] for c in leaves_orig[cp]]
        leaf_off = len(LEAVES)
        LEAVES += struct.pack('<H', len(leaf_tokens))
        for t in leaf_tokens:
            LEAVES += struct.pack('<H', t)
        if len(LEAVES) & 1:
            LEAVES.append(0)

        # ATOMS: u16 n + u16 token[n]，保持 AtomicDecomposition 的顺序
        atom_tokens = [tok_id[c] for c in atoms_by_cp[cp]]
        atom_off = len(ATOMS)
        ATOMS += struct.pack('<H', len(atom_tokens))
        for t in atom_tokens:
            ATOMS += struct.pack('<H', t)
        if len(ATOMS) & 1:
            ATOMS.append(0)

        cs_off = len(CS)
        CS += struct.pack('<H', len(comp_sorted))
        for t in comp_sorted:
            CS += struct.pack('<H', t)

        cold_off = len(COLD)
        COLD += struct.pack('<H', len(py_bytes)); COLD += py_bytes
        COLD += struct.pack('<H', len(ids_bytes)); COLD += ids_bytes

        CHAR += struct.pack('<IIHBBIII',
                            freq_score & 0xFFFFFFFF,
                            len_mask & 0xFFFFFFFF,
                            ctok,
                            depth & 0xFF,
                            block_id & 0xFF,
                            alts_off,
                            leaf_off,
                            atom_off)
        COLD_IDX += struct.pack('<II', cs_off, cold_off)

    # ---- VARIANTS (异体字映射) ----
    VAR_OFF = [0] * N
    VAR = bytearray()
    variant_lists = {}
    if os.path.exists(VARIANTS_PATH):
        with open(VARIANTS_PATH, 'r', encoding='utf-8') as vf:
            for line in vf:
                line = line.strip()
                if not line or line.startswith('#') or '\t' not in line:
                    continue
                base, vars_str = line.split('\t', 1)
                if len(base) != 1 or ord(base) not in id_of_cp:
                    continue
                seen = set()
                ids = []
                for v in vars_str.split():
                    if len(v) != 1:
                        continue
                    vcp = ord(v)
                    if vcp == ord(base) or vcp not in id_of_cp:
                        continue
                    vid = id_of_cp[vcp]
                    if vid not in seen:
                        seen.add(vid)
                        ids.append(vid)
                if ids:
                    variant_lists[ord(base)] = ids
        print(f"Variants: {len(variant_lists)} base chars, "
              f"{sum(len(v) for v in variant_lists.values())} variant relations.")
    else:
        print(f"[Warning] {VARIANTS_PATH} not found, variants section empty.")
    for i, cp in enumerate(chars):
        VAR_OFF[i] = len(VAR)
        ids = variant_lists.get(cp, [])
        VAR += struct.pack('<H', len(ids))
        for vid in ids:
            VAR += struct.pack('<I', vid)

    # ---- CP2ID / ID2CP ----
    CP2ID = bytearray(MAX_CP * 4)
    for cp, i in id_of_cp.items():
        struct.pack_into('<I', CP2ID, cp * 4, i + 1)
    ID2CP = b''.join(struct.pack('<I', cp) for cp in chars)

    # ---- TOKENS / TOK_CANON / ATOMIC_SET ----
    TB = bytearray()
    TB += struct.pack('<H', NT)
    for t in tokens:
        bs = t.encode('utf-8')
        TB += struct.pack('<H', len(bs)); TB += bs
        TB += struct.pack('<I', ord(t) if len(t) == 1 else 0)
    TOK_CANON = bytearray()
    for t in tokens:
        c = C2of(t)
        TOK_CANON += struct.pack('<H', tok_id.get(c, tok_id[t]))
    atomic_ids = sorted({tok_id[c] for c in ATOMIC_COMPONENTS if c in tok_id})
    AS = bytearray()
    AS += struct.pack('<H', len(atomic_ids))
    for t in atomic_ids:
        AS += struct.pack('<H', t)

    # ---- PY ----
    py_items = sorted(pinyin_to_comps.items())
    PB = bytearray()
    PB += struct.pack('<H', len(py_items))
    for py, comps in py_items:
        ids = set()
        for c in comps:
            if c in tok_id:
                ids.add(tok_id[c])
            c2 = C2of(c)
            if c2 in tok_id:
                ids.add(tok_id[c2])
        ids = sorted(ids, key=lambda t_id: comp_sort_key(py, tokens[t_id]))
        pbs = py.encode('utf-8')
        PB += struct.pack('<H', len(pbs)); PB += pbs
        PB += struct.pack('<H', len(ids))
        for t in ids:
            PB += struct.pack('<H', t)

    # ---- KEY_LOOKUP / KEY_REC / POST ----
    K = 1024
    BITSET_BYTES = ((N + 63) // 64) * 8
    POST = bytearray()

    def align8():
        while len(POST) % 8:
            POST.append(0)

    by_token = {}
    for key in sorted(sorted_inverted.keys()):
        base = key
        mult = 1
        if '*' in key:
            base, m = key.rsplit('*', 1)
            try:
                mult = int(m)
            except ValueError:
                continue
        if base not in tok_id:
            continue
        ids = [id_of_cp[ord(ch)] for ch in sorted_inverted[key] if ord(ch) in id_of_cp]
        cnt = len(ids)
        head_ids = ids[:K]
        align8()
        head_off = len(POST)
        for x in head_ids:
            POST += struct.pack('<I', x)
        kind = 1 if cnt > K else 0
        align8()
        full_off = len(POST)
        if kind == 0:
            for x in sorted(ids):
                POST += struct.pack('<I', x)
        else:
            words = [0] * (BITSET_BYTES // 8)
            for x in ids:
                words[x >> 6] |= (1 << (x & 63))
            for w in words:
                POST += struct.pack('<Q', w)
        by_token.setdefault(tok_id[base], []).append(
            (mult, head_off, len(head_ids), full_off, cnt, kind))

    KEY_LOOKUP = [0] * (NT + 1)
    KEY_REC = bytearray()
    for t in range(NT):
        KEY_LOOKUP[t] = len(KEY_REC) // 20
        for mult, head_off, head_cnt, full_off, full_cnt, kind in sorted(
                by_token.get(t, []), key=lambda x: x[0]):
            KEY_REC += struct.pack('<BBHIIII', mult & 0xFF, kind & 0xFF, 0,
                                   head_off, head_cnt, full_off, full_cnt)
    KEY_LOOKUP[NT] = len(KEY_REC) // 20

    KL = b''.join(struct.pack('<I', x) for x in KEY_LOOKUP)
    CANON = bytes(TOK_CANON)
    VAR_OFF_BLOB = b''.join(struct.pack('<I', x) for x in VAR_OFF)

    # 节区按“冷热”排列：热数据在前，减少首次查询触页跨度。
    # section type ids 必须与 src/ids_store.h 一致。
    sections = [
        (3, bytes(CHAR)), (1, bytes(CP2ID)),
        (12, KL), (13, bytes(KEY_REC)),
        (10, bytes(TB)), (17, CANON), (18, bytes(AS)), (11, bytes(PB)),
        (6, bytes(LEAVES)), (7, bytes(ATOMS)),
        (5, bytes(ALTS)), (8, bytes(CS)),
        (14, bytes(POST)),
        (4, bytes(COLD_IDX)), (9, bytes(COLD)),
        (15, VAR_OFF_BLOB),
        (16, bytes(VAR)),
        (2, ID2CP),
    ]

    header_size = 32
    table_size = 24 * len(sections)
    offset = header_size + table_size
    table = bytearray()
    blobs = []
    for sec_type, data in sections:
        offset = (offset + 7) & ~7  # 8-byte align each section
        table += struct.pack('<IIQQ', sec_type, 0, offset, len(data))
        blobs.append((offset, data))
        offset += len(data)
    header = struct.pack('<4sHHIIIIII', b'IDS4', 1, 0, MAX_CP, N,
                         len(KEY_REC) // 20, len(sections), 0, 0)

    out = "ids_data.bin"
    with open(out, 'wb') as f:
        f.write(header)
        f.write(table)
        written = header_size + table_size
        for off, data in blobs:
            if off > written:
                f.write(b'\x00' * (off - written))
                written = off
            f.write(data)
            written += len(data)

    # ---- self check ----
    assert len(header) == 32
    assert len(table) == table_size
    assert N == len(chars)
    print("IDS4 self-check passed.")
    print(f"chars={N} tokens={NT} keys={len(KEY_REC) // 20} "
          f"post={len(POST)} leaves={len(LEAVES)} atoms={len(ATOMS)}")
    print(f"IDS4 file size: {os.path.getsize(out) / 1024 / 1024:.2f} MB")
    print(f"Index text size: {os.path.getsize(OUTPUT_INDEX) / 1024 / 1024:.2f} MB")
    print(f"Meta text size: {os.path.getsize(OUTPUT_META) / 1024 / 1024:.2f} MB")

    print("Done! Data generation complete.")

if __name__ == '__main__':
    main()
