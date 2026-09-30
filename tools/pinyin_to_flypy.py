#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 将数字声调拼音词库转换为小鹤双拼（flypy）词库。
#
# 注意: 输入应为数字声调格式（a1 ba4）。若源词库为带调拼音（ā bà），
#       请先运行 tools/tone_convert.py 转换，再使用本脚本：
#         python3 tools/tone_convert.py 带调拼音.txt -o 数字声调.txt
#
# 转换管线:
#   1. 逐音节补临时分隔符 `;`（flypy_pro 规则依赖音节的数字声调 + `;` 尾巴）
#   2. 逐音节应用内嵌的 flypy_pro algebra 规则链 (xform / xlit)
#   3. 去掉临时 `;`，输出纯双拼、保留声调 (`xiang3` → `xl3`)
#
# 输出: 仓库根目录 dicts-flypy/ 下的 `*.flypy.dict.yaml` 词库，
#       头部 name 同步改为 `*.flypy`（供 import_tables 引用）。
#
# 用法:
#   python3 tools/pinyin_to_flypy.py                                  # 默认 dicts-base/*.dict.yaml -> dicts-flypy
#   python3 tools/pinyin_to_flypy.py -i dicts-base/*.dict.yaml -o dicts-flypy
#   python3 tools/pinyin_to_flypy.py -i dicts-base/a.dict.yaml dicts-base/b.dict.yaml -o dicts-flypy

import os
import re
import shutil
import glob
import argparse
from typing import List, Tuple

# ================= 用户配置区 =================
DEFAULT_INPUT_PATTERNS = ["dicts-base/*.dict.yaml"]
OUTPUT_DIR_DEFAULT = "dicts-flypy"
# 非拼音编码词库：直接原样复制，不做转换
COPY_AS_IS_FILES = {
    "en.dict.yaml",
    "mixed.dict.yaml",
    "abbrev.dict.yaml",
    "t9_abbrev.dict.yaml",
}
OUTPUT_SUFFIX = ".flypy"
# =============================================

# ---------- flypy_pro algebra 规则（硬编码自 tools/cover.yaml） ----------
# 变更规则时：改这里即可；tools/cover.yaml 保留为 schema 参照文档。
# 每条: (算子, 参数1, 参数2)
#   xform: (模式, 替换)  —— Boost.Regex 语义，$N 由 build_transformer 转为 Python \g<N>
#   xlit:  (源字符表, 目标字符表)
FLYPY_PRO_RULES: List[Tuple[str, str, str]] = [
    # 零声母
    ("xform", r"^([aoe])(ng)?(\d);", r"$1$1$2$3;"),
    ("xform", r"^n(\d);", r"en$1;"),  # n 使用 en
    ("xform", r"^m(\d);", r"mv$1;"),  # m 使用 mv
    # 处理 z/c/s + ii
    ("xform", r"^zii(\d);", r"Oi$1;"),
    ("xform", r"^cii(\d);", r"Ei$1;"),
    ("xform", r"^sii(\d);", r"Ai$1;"),
    ("xform", r"ii(\d);", r"i$1;"),
    # 尖音 z/c/s + i/v -> o/e/a
    ("xform", r"^z([iv])([a-z]+)(\d);", r"O$1$2$3;"),
    ("xform", r"^c([iv])([a-z]+)(\d);", r"E$1$2$3;"),
    ("xform", r"^s([iv])([a-z]+)(\d);", r"A$1$2$3;"),
    # 团音 g/k/h + i/v -> j/q/x
    ("xform", r"^g([iv])", r"J$1"),
    ("xform", r"^k([iv])", r"Q$1"),
    ("xform", r"^h([iv])", r"X$1"),
    # 韵母处理
    ("xform", r"iai(\d);", r"D$1;"),
    ("xform", r"iu(\d);", r"Q$1;"),
    ("xform", r"[uv]an(\d);", r"R$1;"),
    ("xform", r"[uv]e(\d);", r"T$1;"),
    ("xform", r"[uv]n(\d);", r"Y$1;"),
    ("xform", r"[uv]o(\d);", r"O$1;"),
    ("xform", r"ie(\d);", r"P$1;"),
    ("xform", r"i?ong(\d);", r"S$1;"),
    ("xform", r"ing(\d);", r"K$1;"),
    ("xform", r"[uv]ai(\d);", r"K$1;"),
    ("xform", r"eng(\d);", r"G$1;"),
    ("xform", r"[iu]ang(\d);", r"L$1;"),
    ("xform", r"ang(\d);", r"H$1;"),
    ("xform", r"ian(\d);", r"M$1;"),
    ("xform", r"iao(\d);", r"N$1;"),
    ("xform", r"[iu]a(\d);", r"X$1;"),
    ("xform", r"[uv]i(\d);", r"V$1;"),
    ("xform", r"in(\d);", r"B$1;"),
    ("xform", r"([a-z]+)ai(\d);", r"$1D$2;"),
    ("xform", r"([a-z]+)an(\d);", r"$1J$2;"),
    ("xform", r"([a-z]+)ao(\d);", r"$1C$2;"),
    ("xform", r"([a-z]+)en(\d);", r"$1F$2;"),
    ("xform", r"([a-z]+)ei(\d);", r"$1W$2;"),
    ("xform", r"([a-z]+)ou(\d);", r"$1Z$2;"),
    # zh/ch/sh -> v/i/u
    ("xform", r"^zh", r"V"),
    ("xform", r"^ch", r"I"),
    ("xform", r"^sh", r"U"),
    ("xlit", r"QWERTYUIOPASDFGHJKLZXCVBNM", r"qwertyuiopasdfghjklzxcvbnm"),
]
# =============================================

CJK_PATTERN = re.compile(
    r"[〇々の𖿲𖿳\u2e80-\u2fdf\u3400-\u4DBF\u4E00-\u9FFF\U00020000-\U0003347F]"
)
IGNORE_CHARS = set("，。？！、：～·＆“”（）「」『』…")

# 仅允许的汉字读音字符（含声调符号），用于校验拼音列合法性
PINYIN_CHARS = "a-z" "āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜ" "üv" "ńňǹḿm̀" "0-9" ";"
PINYIN_TOKEN_RE = re.compile(rf"^[{PINYIN_CHARS}]+$")

# 声调符号标记：输入应为数字声调（a1 ba4），若仍含声调符号需先经 tools/tone_convert.py 转换
TONE_MARK_RE = re.compile(r"[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜńňǹḿ]")


# ---------- flypy 规则链编译 ----------
def build_transformer(rules: List[Tuple[str, str, str]]):
    """
    根据规则列表构建一个可调用的 `flypy(syllable) -> str` 转换器。
    每个音节独立应用整条规则链（与 librime 对词条编码逐音节处理一致）。
    规则硬编码于 FLYPY_PRO_RULES（源自 tools/cover.yaml 的 flypy_pro）。
    """
    xforms = []
    xlit = None
    for op, arg1, arg2 in rules:
        if op == "xform":
            # Boost.Regex 的 $N 替换为 Python 的 \g<N>
            repl = re.sub(r"\$(\d+)", r"\\g<\1>", arg2)
            xforms.append((re.compile(arg1), repl))
        elif op == "xlit":
            table = str.maketrans(arg1, arg2)
            xlit = table
        else:
            raise ValueError(f"未知 algebra 算子: {op}")

    def flypy(syllable: str) -> str:
        s = syllable
        for pat, repl in xforms:
            s = pat.sub(repl, s)
        if xlit is not None:
            s = s.translate(xlit)
        return s

    return flypy


# ---------- 词库行处理 ----------
def is_valid_han_word(word: str) -> bool:
    """汉字列仅允许空白、忽略标点与 CJK 字符，含其余字符返回 False。"""
    return all(
        ch.isspace() or ch in IGNORE_CHARS or CJK_PATTERN.match(ch) for ch in word
    )


def extract_cn_chars(word: str) -> List[str]:
    """提取汉字列中的 CJK 字符（跳过空白与忽略标点）。"""
    return [ch for ch in word if CJK_PATTERN.match(ch)]


def add_suffix_before_extensions(filename: str, suffix: str) -> str:
    if not suffix:
        return filename
    i = filename.find(".")
    return (filename + suffix) if i == -1 else (filename[:i] + suffix + filename[i:])


def build_header_name(filename: str) -> str:
    """由输入文件名推导新词库 name: jichu   → jichu.flypy。"""
    base = filename
    for ext in (".dict.yaml", ".yaml", ".yml", ".txt"):
        if base.endswith(ext):
            base = base[: -len(ext)]
            break
    return base + OUTPUT_SUFFIX


def rewrite_header(line: str, new_name: str) -> str:
    """重写头部 name: 行为新词库名（保留原行尾换行）。"""
    m = re.match(r"^(\s*name\s*:\s*)[^#\s]+(.*)$", line.rstrip("\n"))
    if m:
        nl = "\n" if line.endswith("\n") else ""
        return f"{m.group(1)}{new_name}{m.group(2)}{nl}"
    return line


def process_dict_file(in_file, out_file, flypy, warnings):
    """转换单个词库：透传头部，数据行 拼音→flypy。"""
    try:
        fin = open(in_file, "r", encoding="utf-8-sig")
        fout = open(out_file, "w", encoding="utf-8", newline="\n")
    except Exception as e:
        print(f"打开文件失败 {in_file} / {out_file}: {e}")
        return

    new_name = build_header_name(os.path.basename(in_file))

    with fin, fout:
        processing = False
        for line in fin:
            if not processing:
                fout.write(rewrite_header(line, new_name))
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

            # 权重列前置（如 zi.dict.yaml: `一  a   759839` 之外的格式）
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

            # 输入应为数字声调格式；若仍含声调符号，提示先运行 tools/tone_convert.py
            if any(TONE_MARK_RE.search(tok) for tok in pinyin_tokens):
                warn = (
                    f"# 警告: 拼音列含声调符号（请先运行 tools/tone_convert.py 转换），跳过"
                    f"（{os.path.basename(in_file)}): {raw}"
                )
                warnings.append(warn)
                fout.write(warn + "\n")
                continue

            cn_chars = extract_cn_chars(han)
            if not is_valid_han_word(han) or len(cn_chars) != len(pinyin_tokens):
                warn = (
                    f"# 警告: 拼音数与字数不匹配（{os.path.basename(in_file)}): {raw}"
                )
                warnings.append(warn)
                fout.write(warn + "\n")
                continue

            # 逐音节: 数字声调 → 补 `;` → flypy 规则链 → 去掉临时 `;`
            converted = []
            for token in pinyin_tokens:
                syllable = flypy(token + ";")
                if not syllable.endswith(";"):
                    warn = f"# 警告: flypy 规则未保留分隔符，跳过（{os.path.basename(in_file)}): {raw}"
                    warnings.append(warn)
                    fout.write(warn + "\n")
                    converted = None
                    break
                converted.append(syllable[:-1])

            if converted is None:
                continue

            new_col2 = " ".join(converted)
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


def glob_has_magic(s: str) -> bool:
    """判断字符串是否含 glob 通配符。"""
    return any(ch in s for ch in "*?[")


def collect_input_files(patterns):
    """展开输入文件列表（支持 glob 字符串），去重保序。"""
    files = []
    for item in patterns:
        if glob_has_magic(item):
            files.extend(sorted(glob.glob(item)))
        else:
            files.append(item)
    seen = set()
    result = []
    for f in files:
        if f not in seen:
            seen.add(f)
            result.append(f)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="批量处理词库：数字声调拼音（a1 ba4）→ flypy 双拼码。"
    )
    parser.add_argument(
        "-i",
        "--input",
        nargs="*",
        default=DEFAULT_INPUT_PATTERNS,
        help="输入词库文件（glob 风格，支持通配符）；默认 dicts-base/*.dict.yaml",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=OUTPUT_DIR_DEFAULT,
        help=f"输出目录，文件名拼 .flypy（默认：{OUTPUT_DIR_DEFAULT}）",
    )
    args = parser.parse_args()

    flypy = build_transformer(FLYPY_PRO_RULES)
    print(f"已加载内嵌 flypy_pro 规则，共 {len(FLYPY_PRO_RULES)} 条")

    input_files = collect_input_files(args.input)
    if not input_files:
        print("没有找到符合条件的输入文件。")
        return

    os.makedirs(args.output_dir, exist_ok=True)
    warnings = []
    for path in input_files:
        if not os.path.isfile(path):
            print(f"跳过不存在的文件: {path}")
            continue
        name = os.path.basename(path)
        if name in COPY_AS_IS_FILES:
            out_copy = os.path.join(args.output_dir, name)
            if os.path.abspath(path) != os.path.abspath(out_copy):
                shutil.copy2(path, out_copy)
                print(f"跳过并原样复制: {name}")
            continue
        out_name = add_suffix_before_extensions(name, OUTPUT_SUFFIX)
        process_dict_file(
            path, os.path.join(args.output_dir, out_name), flypy, warnings
        )

    if warnings:
        print(f"\n共 {len(warnings)} 条警告（已作为 # 注释行写入输出）:")
        for w in warnings:
            print(f"  {w}")


if __name__ == "__main__":
    main()
