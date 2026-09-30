#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 按尖音映射表转换词库拼音，生成尖音版本词库补丁（自动派生声调5组合）。
#
# 输入: 数字声调词库（如 dicts-base/，由 tools/tone_convert.py 生成）
# 输出: 补丁词库（只含被尖音替换的词条），文件名 *.zian.dict.yaml，name 改为 *.zian
#       与 shared/wanxiang.zian.dict.yaml 的 import_tables（dicts_zian/*.zian）对应。
#
# 用法（多文件/glob）:
#   python3 tools/zian_go.py                                  # 默认 dicts-base/*.dict.yaml -> dicts-zian
#   python3 tools/zian_go.py -i dicts-base/*.dict.yaml -o dicts-zian
#   python3 tools/zian_go.py -i dicts-base/a.dict.yaml dicts-base/b.dict.yaml -o dicts-zian
#
# 行为:
#   - 头部透传，name: 改为 *.zian
#   - 数据行「汉字\t拼音列\t权重」逐字匹配尖音映射（兼容分号辅助码）
#   - 仅输出被改写（matched）的词条；未命中词条不写入（补丁模式）
#   - 无效行写 # 警告: 注释行，终端逐条输出全部警告
#   - 非拼音编码词库（en/mixed/abbrev/t9_abbrev）直接跳过，不输出
#   - 自动派生声调5映射（如 zii1 <-> zii5）

import os
import re
import glob
import argparse
from typing import List, Tuple

# ================= 用户配置区 =================
MAP_FILE = "tools/zian_map.csv"
DEFAULT_INPUT_PATTERNS = ["dicts-base/*.dict.yaml"]
DEFAULT_OUTPUT_DIR = "dicts-zian"
# 非拼音编码词库：直接跳过，不输出（en/mixed/abbrev/t9_abbrev）
COPY_AS_IS_FILES = {
    "en.dict.yaml",
    "mixed.dict.yaml",
    "abbrev.dict.yaml",
    "t9_abbrev.dict.yaml",
}
OUTPUT_SUFFIX = ".zian"
# =============================================

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


# ---------- 尖音映射表加载 ----------
def derive_tone5(hanzi, target_pinyin, orig_pinyin):
    """由 xN 派生 x5 映射（轻声）。任一侧不以数字结尾则跳过。"""
    for label, pinyin in (("目标拼音", target_pinyin), ("原始拼音", orig_pinyin)):
        if not pinyin or not pinyin[-1].isdigit():
            print(
                f"警告: 映射拼音不以数字结尾，跳过派生声调5: "
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
                    f"警告: 第 {line_num} 行格式错误（少于3列）: {line}",
                    file=sys.stderr,
                )
                skipped_lines += 1
                continue
            hanzi, target_pinyin, orig_pinyin = parts[0], parts[1], parts[2]
            entry = (orig_pinyin, target_pinyin)
            if entry not in mapping.setdefault(hanzi, []):
                mapping[hanzi].append(entry)
            total_lines += 1
            derived = derive_tone5(hanzi, target_pinyin, orig_pinyin)
            if derived and derived not in mapping[hanzi]:
                mapping[hanzi].append(derived)
                derived_lines += 1
    return mapping, total_lines, derived_lines, skipped_lines


# ---------- 词条处理 ----------
def process_pinyin_block(block):
    """拆出拼音与分号后的辅助码部分，返回 (pinyin, rest)。"""
    if ";" in block:
        pinyin, rest = block.split(";", 1)
        return pinyin, ";" + rest
    else:
        return block, ""


def replace_in_line(line_parts, mapping, basename, warnings):
    """
    逐字匹配尖音映射，替换命中拼音。
    返回 (matched, new_line_parts, warned)。
    warned=True 表示该行为无效行（已写警告注释文本到 warnings）。
    """
    if len(line_parts) < 2:
        return False, line_parts, False

    hanzi_col = line_parts[0]
    pinyin_col = line_parts[1]

    if not is_valid_han_word(hanzi_col):
        warn = f"# 警告: 汉字列含非中文字符，跳过（{basename}): {'\t'.join(line_parts)}"
        warnings.append(warn)
        return False, line_parts, True

    pinyin_blocks = pinyin_col.split(" ")
    blocks_info = []
    for block in pinyin_blocks:
        pinyin, rest = process_pinyin_block(block)
        blocks_info.append((pinyin, rest))

    pinyins = [p for p, _ in blocks_info]
    aligned = extract_cn_chars(hanzi_col)
    if len(aligned) != len(pinyins):
        warn = f"# 警告: 拼音数与字数不匹配，跳过（{basename}): {'\t'.join(line_parts)}"
        warnings.append(warn)
        return False, line_parts, True

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
    return modified, line_parts, False


# ---------- 命名规则 ----------
def generate_output_filename(input_basename):
    """
    生成输出文件名：
      a.dict.yaml      -> a.zian.dict.yaml
      a.pro.dict.yaml  -> a.zian.pro.dict.yaml
    """
    if "pro" in input_basename:
        return input_basename.replace("pro", "zian.pro", 1)
    elif "dict" in input_basename:
        return input_basename.replace("dict", "zian.dict", 1)
    else:
        return input_basename


def build_header_name(filename: str) -> str:
    """由输出文件名推导新词库 name: a.zian.dict.yaml -> a.zian。"""
    base = filename
    for ext in (".dict.yaml", ".yaml", ".yml", ".txt"):
        if base.endswith(ext):
            base = base[: -len(ext)]
            break
    return base


def rewrite_header(line: str, new_name: str) -> str:
    """重写头部 name: 行为新词库名（保留原行尾换行）。"""
    m = re.match(r"^(\s*name\s*:\s*)[^#\s]+(.*)$", line.rstrip("\n"))
    if m:
        nl = "\n" if line.endswith("\n") else ""
        return f"{m.group(1)}{new_name}{m.group(2)}{nl}"
    return line


# ---------- 文件处理 ----------
def process_file(input_path, mapping, output_dir, warnings):
    basename = os.path.basename(input_path)
    new_basename = generate_output_filename(basename)

    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, new_basename)
    header_name = build_header_name(new_basename)

    with open(input_path, "r", encoding="utf-8") as fin, open(
        output_path, "w", encoding="utf-8", newline="\n"
    ) as fout:
        processing = False
        for line in fin:
            if not processing:
                fout.write(rewrite_header(line, header_name))
                if "..." in line:
                    processing = True
                continue

            raw = line.rstrip("\n").rstrip("\r")
            if not raw:
                fout.write(raw + "\n")
                continue

            stripped = raw.strip()
            if stripped.startswith("#"):
                # 注释行（含来自上游的 # 警告: 注释）原样透传
                fout.write(raw + "\n")
                continue

            parts = raw.split("\t")
            matched, new_parts, warned = replace_in_line(
                parts, mapping, basename, warnings
            )
            if warned:
                # 无效行：写警告注释行到输出
                fout.write(warnings[-1] + "\n")
                continue
            if matched:
                # 保留完整列（第3列权重等），仅替换第2列拼音
                fout.write("\t".join(new_parts) + "\n")

    print(f"已处理: {new_basename}")


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
        description="按尖音映射表转换词库拼音，生成尖音版本词库补丁（自动派生声调5组合）。"
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
        default=DEFAULT_OUTPUT_DIR,
        help=f"输出目录，文件名拼 .zian（默认：{DEFAULT_OUTPUT_DIR}）",
    )
    args = parser.parse_args()

    mapping, total_lines, derived_lines, skipped_lines = build_mapping(MAP_FILE)
    print(
        f"加载映射: 总条目数 {total_lines}，派生声调5条目 {derived_lines}，"
        f"不同汉字数 {len(mapping)}，跳过 {skipped_lines} 行"
    )

    input_files = collect_input_files(args.input)
    if not input_files:
        print("没有找到符合条件的输入文件。")
        return

    warnings = []
    for fpath in input_files:
        if not os.path.isfile(fpath):
            print(f"跳过不存在的文件: {fpath}", file=sys.stderr)
            continue
        name = os.path.basename(fpath)
        if name in COPY_AS_IS_FILES:
            print(f"跳过（非拼音编码词库）: {name}")
            continue
        process_file(fpath, mapping, args.output_dir, warnings)

    if warnings:
        print(f"\n共 {len(warnings)} 条警告（已作为 # 注释行写入输出）:")
        for w in warnings:
            print(f"  {w}")


if __name__ == "__main__":
    main()
