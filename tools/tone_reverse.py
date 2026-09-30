#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 批量处理词库：将数字声调拼音列还原为带调拼音，输出完整词库结构。
# 这是 tools/tone_convert.py 的逆转换。
#
# 转换规则:
#   xiang3 → xiǎng        (声调数字还原到韵母正确位置)
#   lv4   → lǜ            (非 j/q/x/y 后的 v 还原为 ü)
#   jv2   → jú            (j/q/x/y 后的 v 还原为无点 u)
#   lve4  → lüè           (v→ü，但声调标在 e 上)
#   xie5  → xie           (轻声 5 不标调，与正向「无调补 5」语义对称)
#   n2    → ń             (鼻音 n/m/ng/hm 带调预置映射)
#   已带调 → 原样返回     (脚本可重复运行)
#
# 用法（词库批处理，输入可为多个文件，支持 shell glob 展开）:
#   python3 tools/tone_reverse.py -i dicts-base/*.dict.yaml -o dicts-tone
#   python3 tools/tone_reverse.py -i dicts-base/a.dict.yaml dicts-base/b.dict.yaml -o dicts-tone
#
# 行为:
#   - 头部透传；数据行「汉字\t拼音列\t权重」仅把拼音列还原带调，其余列保持不变
#   - 输出文件与输入同名（jichu.dict.yaml → dicts-tone/jichu.dict.yaml）
#   - 权重列前置（`一  a  重`）也正确处理
#   - 空行与 # 注释行原样保留
#   - 字数与拼音数不匹配、或拼音列含无效字符的数据行：写 # 警告: 注释行并跳过
#   - 非拼音编码词库（en/mixed/abbrev/t9_abbrev）原样复制，不做转换

import os
import re
import argparse
import unicodedata
from typing import List, Tuple

# ================= 用户配置区 =================
OUTPUT_DIR_DEFAULT = "dicts-tone"
# 非拼音编码词库：直接原样复制，不做转换
COPY_AS_IS_FILES = {
    "en.dict.yaml",
    "mixed.dict.yaml",
    "abbrev.dict.yaml",
    "t9_abbrev.dict.yaml",
}
# =============================================

CJK_PATTERN = re.compile(
    r"[〇々の𖿲𖿳\u2e80-\u2fdf\u3400-\u4DBF\u4E00-\u9FFF\U00020000-\U0003347F]"
)
IGNORE_CHARS = set("，。？！、：～·＆“”（）「」『』…")

# 仅允许的汉字读音字符（含声调符号），用于校验拼音列合法性
PINYIN_CHARS = (
    "a-z" "āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜ" "üv" "ńňǹḿm̀" "0-9" ";"
)
PINYIN_TOKEN_RE = re.compile(rf"^[{PINYIN_CHARS}]+$")

# 已带调标记：输入若已含声调符号则原样保留（不重复转换）
TONE_MARK_RE = re.compile(r"[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜńňǹḿ]")

# 元音 → 1/2/3/4 声带调字符（5 声轻声不标调）
VOWEL_TONE_MAP = {
    "a": "āáǎà",
    "o": "ōóǒò",
    "e": "ēéěè",
    "i": "īíǐì",
    "u": "ūúǔù",
    "ü": "ǖǘǚǜ",
}

# 鼻音独立音节带调预置映射（声调数字 → 带调形式）
NASAL_TONE_MAP = {
    "n": {2: "ń", 3: "ň", 4: "ǹ"},
    "m": {2: "ḿ", 4: "m̀"},
    "ng": {2: "ńg", 3: "ňg", 4: "ǹg"},
    "hm": {2: "hḿ"},
}


# ---------- 数字声调 → 带调拼音 ----------
def find_tone_pos(base: str) -> int:
    """定位标调元音位置：a > o > e，否则取最后一个 i/u/ü。无则 -1。"""
    for ch in "aoe":
        idx = base.find(ch)
        if idx != -1:
            return idx
    for idx in range(len(base) - 1, -1, -1):
        if base[idx] in "iuü":
            return idx
    return -1


def restore_v(base: str) -> str:
    """还原 v：j/q/x/y 后 → u（拼音书写惯例），其余 → ü。"""
    chars = list(base)
    for i, ch in enumerate(chars):
        if ch == "v":
            prev = base[i - 1] if i > 0 else ""
            chars[i] = "u" if prev in "jqxy" else "ü"
    return "".join(chars)


def apply_tone(base: str, tone: int) -> str:
    """在标调位置叠加声调符号。"""
    idx = find_tone_pos(base)
    if idx == -1:
        return base
    ch = base[idx]
    table = VOWEL_TONE_MAP.get(ch)
    if table is None:
        return base
    return base[:idx] + table[tone - 1] + base[idx + 1 :]


def convert_digit_to_tone(pinyin: str) -> str:
    """
    将数字声调拼音还原为带调拼音。
    已带调（含声调符号）或无数字尾巴的拼音原样返回。
    声调数字 5（轻声）不标调。
    """
    if TONE_MARK_RE.search(pinyin):
        return pinyin
    if not re.search(r"[1-5]$", pinyin):
        return pinyin

    base, tone = pinyin[:-1], int(pinyin[-1])

    # 鼻音音节（n/m/ng/hm）：带调映射；5 声不标调
    if base in NASAL_TONE_MAP and tone != 5:
        return NASAL_TONE_MAP[base].get(tone, base)

    base = restore_v(base)
    if tone == 5:
        return base

    return apply_tone(base, tone)


def convert_pinyin_tokens(tokens: List[str]) -> List[str]:
    """将拼音 token 列表逐项还原（含分号辅助码保留）。"""
    result = []
    for tok in tokens:
        if ";" in tok:
            pinyin, rest = tok.split(";", 1)
            result.append(convert_digit_to_tone(pinyin) + ";" + rest)
        else:
            result.append(convert_digit_to_tone(tok))
    return result


# ---------- 词库行处理 ----------
def is_valid_han_word(word: str) -> bool:
    """汉字列仅允许空白、忽略标点与 CJK 字符，含其余字符返回 False。"""
    return all(
        ch.isspace() or ch in IGNORE_CHARS or CJK_PATTERN.match(ch) for ch in word
    )


def extract_cn_chars(word: str) -> List[str]:
    """提取汉字列中的 CJK 字符（跳过空白与忽略标点）。"""
    return [ch for ch in word if CJK_PATTERN.match(ch)]


def process_dict_file(in_file, out_file, warnings):
    """转换单个词库：数字声调拼音列 → 带调拼音列。"""
    try:
        fin = open(in_file, "r", encoding="utf-8-sig")
        fout = open(out_file, "w", encoding="utf-8", newline="\n")
    except Exception as e:
        print(f"打开文件失败 {in_file} / {out_file}: {e}")
        return

    with fin, fout:
        processing = False
        for line in fin:
            if not processing:
                fout.write(line)
                if "..." in line:
                    processing = True
                continue

            raw = line.rstrip("\n").rstrip("\r")
            stripped = raw.strip()
            if not raw or stripped.startswith("#"):
                fout.write(raw + "\n")
                continue

            parts = raw.split("\t")
            if len(parts) == 1:
                fout.write(raw + "\n")
                continue

            han = parts[0]
            col2 = parts[1] if len(parts) > 1 else ""
            col3 = parts[2] if len(parts) > 2 else ""
            col4 = parts[3] if len(parts) > 3 else ""

            # 权重列前置（如 zi.dict.yaml: `一  a   759839`）
            if re.fullmatch(r"\d+", col2 or ""):
                col3, col2 = col2, ""

            pinyin_tokens = col2.split(" ") if col2 else []

            # 拼音列合法性：任一 token 含拼音/声调字符之外的内容则跳过（如第三列混入汉字）
            if not pinyin_tokens or not all(
                PINYIN_TOKEN_RE.match(tok) for tok in pinyin_tokens
            ):
                warn = f"# 警告: 拼音列含无效字符，跳过（{os.path.basename(in_file)}): {raw}"
                warnings.append(warn)
                fout.write(warn + "\n")
                continue

            cn_chars = extract_cn_chars(han)
            if not is_valid_han_word(han) or len(cn_chars) != len(pinyin_tokens):
                warn = f"# 警告: 拼音数与字数不匹配（{os.path.basename(in_file)}): {raw}"
                warnings.append(warn)
                fout.write(warn + "\n")
                continue

            new_col2 = " ".join(convert_pinyin_tokens(pinyin_tokens))

            if col4:
                fout.write(
                    f"{han}\t{new_col2}\t{col3}\t{col4}\n"
                    if col3
                    else f"{han}\t{new_col2}\t\t{col4}\n"
                )
            else:
                fout.write(
                    f"{han}\t{new_col2}\t{col3}\n" if col3 else f"{han}\t{new_col2}\n"
                )

    print(f"已处理: {os.path.basename(out_file)}")


def main():
    parser = argparse.ArgumentParser(
        description="批量处理词库：数字声调拼音列 → 带调拼音列（xiang3 → xiǎng）。"
    )
    parser.add_argument(
        "-i",
        "--input",
        nargs="*",
        required=True,
        help="输入词库文件，可多个（支持 shell glob 展开）",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=OUTPUT_DIR_DEFAULT,
        help=f"输出目录，文件与输入同名（默认：{OUTPUT_DIR_DEFAULT}）",
    )
    args = parser.parse_args()

    if not args.input:
        print("请通过 -i 指定至少一个输入词库文件")
        return

    os.makedirs(args.output_dir, exist_ok=True)

    # 支持 glob 字符串未被 shell 展开的情形
    input_files = []
    for item in args.input:
        if glob_has_magic(item):
            import glob

            input_files.extend(sorted(glob.glob(item)))
        else:
            input_files.append(item)

    warnings = []
    for path in input_files:
        if not os.path.isfile(path):
            print(f"跳过不存在的文件: {path}")
            continue
        name = os.path.basename(path)
        out_path = os.path.join(args.output_dir, name)
        if name in COPY_AS_IS_FILES:
            import shutil

            shutil.copy2(path, out_path)
            print(f"跳过并原样复制: {name}")
            continue
        process_dict_file(path, out_path, warnings)

    if warnings:
        print(f"\n共 {len(warnings)} 条警告（已作为 # 注释行写入输出）:")
        for w in warnings:
            print(f"  {w}")


def glob_has_magic(s: str) -> bool:
    """判断字符串是否含 glob 通配符。"""
    return any(ch in s for ch in "*?[")


if __name__ == "__main__":
    main()