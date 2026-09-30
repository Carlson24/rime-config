#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 批量处理词库：将带声调的拼音列转换为数字声调表示，输出完整词库结构。
#
# 转换规则:
#   xiǎng → xiang3        (声调 1-4 转末尾数字)
#   lǜ   → lv4            (ü → v，j/q/x/y 后的 u 也转为 v)
#   bà   → ba4
#   无调 → 补 5           (轻声/无调补 5)
#   已带数字 → 原样返回   (a1 ba4 保持不动，脚本可重复运行)
#
# 用法（词库批处理，输入可为多个文件，支持 shell glob 展开）:
#   python3 tools/tone_convert.py -i dicts/*.dict.yaml -o dicts-base
#   python3 tools/tone_convert.py -i dicts/a.dict.yaml dicts/b.dict.yaml -o dicts-base
#
# 行为:
#   - 头部透传；数据行「汉字\t拼音列\t权重」仅把拼音列转数字，其余列保持不变
#   - 输出文件与输入同名（jichu.dict.yaml → dicts-base/jichu.dict.yaml）
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
OUTPUT_DIR_DEFAULT = "dicts-base"
# 权重列前置文件的输入词库（zi.dict.yaml 等），无需特殊处理，见数据行解析
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
    "a-z" "āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜ" "üv" "ńňǹḿm̀" "0-9"
)
PINYIN_TOKEN_RE = re.compile(rf"^[{PINYIN_CHARS}]+$")

COMBINING_TONE = {
    "\u0304": "1",  # combining macron → 一声
    "\u0301": "2",  # combining acute → 二声
    "\u030c": "3",  # combining caron → 三声
    "\u0300": "4",  # combining grave → 四声
    "\u0307": "5",  # combining dot above → 轻声（第五声）
}


# ---------- 拼音 → 数字声调 ----------
def convert_tone(pinyin: str, add_tone5: bool = True) -> str:
    """
    将带声调的拼音转换为数字声调表示。
    已经带有声调数字（1-5）的拼音不会被处理。
    声调数字始终放在末尾。
    """
    if re.search(r"[1-5]$", pinyin):
        return pinyin

    nfd = unicodedata.normalize("NFD", pinyin)
    has_tone = False
    tone_digit = ""
    result = []
    i = 0

    while i < len(nfd):
        char = nfd[i]
        if char in COMBINING_TONE:
            has_tone = True
            tone_digit = COMBINING_TONE[char]
            i += 1
            continue
        if unicodedata.category(char).startswith("M"):
            i += 1
            continue
        if char == "u" and i + 1 < len(nfd) and nfd[i + 1] == "\u0308":
            result.append("v")  # u + combining diaeresis = ü
            i += 2
            continue
        result.append(char)
        i += 1

    if has_tone:
        result.append(tone_digit)
    elif add_tone5:
        result.append("5")

    # j/q/x/y 声母后的 u 实为 ü，转为 v
    if len(result) >= 2 and result[0] in "jqxy" and result[1] == "u":
        result[1] = "v"

    return "".join(result)


# ---------- 词库行处理 ----------
def is_valid_han_word(word: str) -> bool:
    """汉字列仅允许空白、忽略标点与 CJK 字符，含其余字符返回 False。"""
    return all(
        ch.isspace() or ch in IGNORE_CHARS or CJK_PATTERN.match(ch) for ch in word
    )


def extract_cn_chars(word: str) -> List[str]:
    """提取汉字列中的 CJK 字符（跳过空白与忽略标点）。"""
    return [ch for ch in word if CJK_PATTERN.match(ch)]


def convert_pinyin_tokens(tokens: List[str]) -> List[str]:
    """将拼音 token 列表逐项转为数字声调。"""
    return [convert_tone(tok) for tok in tokens]


def process_dict_file(in_file, out_file, warnings, copy_as_is=False):
    """转换单个词库：带调拼音列 → 数字声调列。"""
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
        description="批量处理词库：带调拼音列 → 数字声调列（xiǎng → xiang3）。"
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