#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import fnmatch
import glob
import argparse
import re
from typing import List

# ================= 用户配置区 =================
# 映射文件路径（三列：汉字、目标拼音、原始拼音，Tab分隔）
MAP_FILE = "tools/zian_map.csv"

# 默认输出目录（可用 -o/--output-dir 覆盖）
DEFAULT_OUTPUT_DIR = "dicts-zian"

# 默认包含模式（glob风格，如 "*.yaml" 或 "*.dict.yaml"，可用位置参数覆盖）
# 如果为空列表 []，则处理当前目录下所有文件（不推荐）
DEFAULT_INCLUDE_PATTERNS = ["dicts/*.dict.yaml"]

# 要排除的文件名模式（glob风格，如 "*.bak"）
EXCLUDE_PATTERNS = ["en.dict.yaml", "mixed.dict.yaml"]

# 是否递归子目录（True/False）
RECURSIVE = False
# =============================================

# ---------- 从 aux_go.py 移植的分词与对齐 ----------
CJK_PATTERN = re.compile(
    r"[〇々の𖿲𖿳\u2e80-\u2fdf\u3400-\u4DBF\u4E00-\u9FFF\U00020000-\U0003347F]"
)
IGNORE_CHARS = set("，。？！、：～·＆“”（）「」『』…")


def is_valid_han_word(word: str) -> bool:
    """汉字列仅允许空白、忽略标点与 CJK 字符，含其余字符返回 False。"""
    return all(
        ch.isspace() or ch in IGNORE_CHARS or CJK_PATTERN.match(ch) for ch in word
    )


def extract_cn_chars(word: str) -> List[str]:
    """提取汉字列中的 CJK 字符（跳过空白与忽略标点）。"""
    return [ch for ch in word if CJK_PATTERN.match(ch)]


# ---------- 原始功能 ----------
def derive_tone5(hanzi, target_pinyin, orig_pinyin, line_num):
    for label, pinyin in (("目标拼音", target_pinyin), ("原始拼音", orig_pinyin)):
        if not pinyin or not pinyin[-1].isdigit():
            print(
                f"警告：第 {line_num} 行拼音不以数字结尾，跳过派生声调5: "
                f"{hanzi}\t{target_pinyin}\t{orig_pinyin}（{label}={pinyin}）",
                file=sys.stderr,
            )
            return None
    return orig_pinyin[:-1] + "5", target_pinyin[:-1] + "5"


def build_mapping(map_file):
    mapping = {}
    total_lines = 0
    derived_lines = 0
    skipped_lines = 0
    with open(map_file, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) < 3:
                print(
                    f"警告：第 {line_num} 行格式错误（少于3列）: {line}",
                    file=sys.stderr,
                )
                skipped_lines += 1
                continue
            hanzi, target_pinyin, orig_pinyin = parts[0], parts[1], parts[2]
            entry = (orig_pinyin, target_pinyin)
            if entry not in mapping.setdefault(hanzi, []):
                mapping[hanzi].append(entry)
            total_lines += 1
            derived = derive_tone5(hanzi, target_pinyin, orig_pinyin, line_num)
            if derived and derived not in mapping[hanzi]:
                mapping[hanzi].append(derived)
                derived_lines += 1
    return mapping, total_lines, derived_lines, skipped_lines


def process_pinyin_block(block):
    if ";" in block:
        pinyin, rest = block.split(";", 1)
        return pinyin, ";" + rest
    else:
        return block, ""


def replace_in_line(line_parts, mapping):
    if len(line_parts) < 2:
        return False, line_parts

    hanzi_col = line_parts[0]
    pinyin_col = line_parts[1]

    if not is_valid_han_word(hanzi_col):
        print(
            f"警告：汉字列含非中文字符，拼音数与字数不匹配（{line_parts}）",
            file=sys.stderr,
        )
        return False, line_parts

    pinyin_blocks = pinyin_col.split(" ")
    blocks_info = []
    for block in pinyin_blocks:
        pinyin, rest = process_pinyin_block(block)
        blocks_info.append((pinyin, rest))

    # 提取纯拼音列表（带声调数字）
    pinyins = [p for p, _ in blocks_info]

    aligned = extract_cn_chars(hanzi_col)
    if len(aligned) != len(pinyins):
        print(f"警告：拼音数与字数不匹配（{line_parts}）", file=sys.stderr)
        return False, line_parts

    modified = False
    new_blocks = []
    for i, (orig_pinyin, rest) in enumerate(blocks_info):
        hanzi = aligned[i]
        if hanzi and hanzi in mapping:
            for orig_p, target_p in mapping[hanzi]:
                if orig_pinyin == orig_p:
                    orig_pinyin = target_p
                    modified = True
                    break
        new_block = orig_pinyin + rest if rest else orig_pinyin
        new_blocks.append(new_block)

    if modified:
        line_parts[1] = " ".join(new_blocks)
    return modified, line_parts


# ========== 新命名规则 ==========
def generate_output_filename(input_basename):
    """
    生成输出文件名，规则：如果文件名包含 pro，则在 pro 前插入 zian
    如 a.pro.dict.yaml -> a.zian.pro.dict.yaml
    否则直接追加 zian
    如 a.dict.yaml -> a.zian.dict.yaml
    """
    if "pro" in input_basename:
        return input_basename.replace("pro", "zian.pro", 1)
    elif "dict" in input_basename:
        return input_basename.replace("dict", "zian.dict", 1)
    else:
        return input_basename


# ---------- 文件收集与处理 ----------
def is_excluded(filename, exclude_patterns):
    if not exclude_patterns:
        return False
    return any(fnmatch.fnmatch(filename, pat) for pat in exclude_patterns)


def collect_files(include_patterns, exclude_patterns, recursive=False):
    files = set()
    if not include_patterns:
        include_patterns = ["*"]
    for pattern in include_patterns:
        if recursive:
            for root, dirs, filenames in os.walk("."):
                for fname in filenames:
                    if fnmatch.fnmatch(fname, pattern):
                        full_path = os.path.join(root, fname)
                        if full_path.startswith("./"):
                            full_path = full_path[2:]
                        files.add(full_path)
        else:
            for fname in glob.glob(pattern):
                files.add(fname)
    result = []
    for fpath in files:
        basename = os.path.basename(fpath)
        if not is_excluded(basename, exclude_patterns):
            result.append(fpath)
    return sorted(result)


def process_file(input_path, mapping, output_dir=None):
    basename = os.path.basename(input_path)
    dirname = os.path.dirname(input_path)
    new_basename = generate_output_filename(basename)

    if output_dir is None:
        output_dir = dirname
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, new_basename)

    with open(input_path, "r", encoding="utf-8") as fin, open(
        output_path, "w", encoding="utf-8"
    ) as fout:
        in_header = True
        for line in fin:
            if in_header:
                fout.write(line)
                if line.strip() == "...":
                    in_header = False
                continue

            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split("\t")
            matched, new_parts = replace_in_line(parts, mapping)
            if matched:
                fout.write("\t".join(new_parts) + "\n")
    print(f"已生成: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="按尖音映射表转换词库拼音，生成尖音版本词库补丁（自动派生声调5组合）。"
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=DEFAULT_OUTPUT_DIR,
        help=f"输出目录（默认：{DEFAULT_OUTPUT_DIR}）",
    )
    parser.add_argument(
        "include_patterns",
        nargs="*",
        default=DEFAULT_INCLUDE_PATTERNS,
        help="要处理的文件模式（glob 风格），不传则使用默认",
    )
    args = parser.parse_args()

    mapping, total_lines, derived_lines, skipped_lines = build_mapping(MAP_FILE)
    print(
        f"加载映射：总条目数 {total_lines}，派生声调5条目 {derived_lines}，"
        f"不同汉字数 {len(mapping)}，跳过 {skipped_lines} 行"
    )

    if EXCLUDE_PATTERNS:
        print(f"排除模式: {EXCLUDE_PATTERNS}")
    print(f"输出目录: {args.output_dir}")

    files_to_process = collect_files(args.include_patterns, EXCLUDE_PATTERNS, RECURSIVE)
    if not files_to_process:
        print("没有找到符合条件的文件。")
        return

    print(f"共找到 {len(files_to_process)} 个文件待处理：")
    for f in files_to_process:
        print(f"  {f}")

    for fpath in files_to_process:
        if not os.path.isfile(fpath):
            print(f"跳过不存在的文件: {fpath}", file=sys.stderr)
            continue
        process_file(fpath, mapping, args.output_dir)


if __name__ == "__main__":
    main()
