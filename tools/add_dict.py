#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import argparse

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_FILE = os.path.join(BASE_DIR, "../shared/dicts", "zi.pro.dict.yaml")
ZIYIN_FILE = os.path.join(BASE_DIR, "../shared/dicts_zian", "zi.zian.pro.dict.yaml")
PRONUNCIATION_FILES = [SOURCE_FILE, ZIYIN_FILE]
TARGET_FILE = os.path.join(BASE_DIR, "../shared/dicts_extra", "zhuaiwen.pro.dict.yaml")
SEARCH_DIRS = [
    os.path.join(BASE_DIR, "../shared/dicts"),
    os.path.join(BASE_DIR, "../shared/dicts_extra"),
]
DEFAULT_FREQ = 10


def load_zi_dict(filepaths):
    """
    加载读音字库，返回 {字: [编码1, 编码2, ...]}。
    按传入顺序合并多个词典，同一字的编码去重并保留顺序（靠前的来源优先）。
    """
    zi_dict = {}
    for filepath in filepaths:
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith("#"):
                        continue
                    parts = line.split("\t")
                    if len(parts) >= 2:
                        char = parts[0].strip()
                        code = parts[1].strip()
                        if char and code:
                            codes = zi_dict.setdefault(char, [])
                            if code not in codes:
                                codes.append(code)
        except FileNotFoundError:
            print(f"错误：源字典文件不存在：{filepath}", file=sys.stderr)
            sys.exit(1)
    return zi_dict


def load_existing_words(dirs):
    """扫描指定目录下所有 .dict.yaml，返回 {词: 所在词典文件名}（词级去重，保留首个出现位置）"""
    existing = {}
    for dir_path in dirs:
        if not os.path.isdir(dir_path):
            continue
        for name in sorted(os.listdir(dir_path)):
            if not name.endswith(".dict.yaml"):
                continue
            filepath = os.path.join(dir_path, name)
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    in_body = False
                    for line in f:
                        if not in_body:
                            if "..." in line:
                                in_body = True
                            continue
                        line = line.strip()
                        if not line or line.startswith("#"):
                            continue
                        word = line.split("\t", 1)[0].strip()
                        if word and word not in existing:
                            existing[word] = name
            except Exception as e:
                print(f"警告：读取 {filepath} 失败：{e}", file=sys.stderr)
    return existing


def append_word_to_dict(word, code_str, freq, target_file):
    """追加词条到目标词典"""
    new_line = f"{word}\t{code_str}\t{freq}\n"
    try:
        with open(target_file, "a", encoding="utf-8") as f:
            f.write(new_line)
        print(f"已追加词条：{word}\t{code_str}\t{freq}")
    except Exception as e:
        print(f"写入目标文件失败：{e}", file=sys.stderr)
        sys.exit(1)


def choose_code_for_char(char, code_list, auto_first=False):
    """
    交互式选择或自动取第一个编码。
    若 auto_first=True，直接返回第一个编码，不交互。
    """
    if auto_first:
        return code_list[0]

    if len(code_list) == 1:
        return code_list[0]

    print(f"\n字“{char}”有多个编码：")
    for idx, code in enumerate(code_list, start=1):
        print(f"  {idx}. {code}")

    while True:
        try:
            choice = input("请选择序号 (1-{}): ".format(len(code_list))).strip()
            if not choice:
                continue
            num = int(choice)
            if 1 <= num <= len(code_list):
                return code_list[num - 1]
            else:
                print(f"请输入 1 到 {len(code_list)} 之间的数字。")
        except ValueError:
            print("请输入有效数字。")


def process_single_word(
    word, freq, zi_dict, target_file, existing_words, interactive=True, force=False
):
    """
    处理单个词条：查重、逐字取编码、追加。
    force=True 时跳过查重，强制追加。
    返回 (成功, 消息)
    """
    if not word:
        return False, "词语为空"

    # 词级查重：先搜索 dicts/ 与 dicts_extra/ 全部词典（强制模式跳过）
    src_file = existing_words.get(word)
    if src_file and not force:
        return False, f"词条“{word}”已存在于 {src_file}，未追加"

    # 逐字取编码
    chosen_codes = []
    for ch in word:
        code_list = zi_dict.get(ch)
        if not code_list:
            return False, f"字“{ch}”在源字典中未找到"
        # 若 interactive 为 False，自动取第一个；否则允许交互
        chosen = choose_code_for_char(ch, code_list, auto_first=not interactive)
        chosen_codes.append(chosen)

    combined_code = " ".join(chosen_codes)

    # 追加
    append_word_to_dict(word, combined_code, freq, target_file)
    note = "（强制追加）" if force else ""
    return True, f"成功追加 {word}\t{combined_code}\t{freq}{note}"


def process_file(
    input_file, default_freq, zi_dict, target_file, existing_words, force=False
):
    """
    批量处理文件，每行格式：词语 或 词语 词频
    批量模式下**支持交互式选择多音字编码**（每个字都会询问）
    force=True 时跳过查重，所有词条强制追加
    """
    if not os.path.isfile(input_file):
        print(f"错误：输入文件不存在：{input_file}", file=sys.stderr)
        sys.exit(1)

    print("批量模式：每个词条的多音字将依次询问，请准备好输入。")
    success_count = 0
    skip_count = 0
    error_count = 0

    with open(input_file, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            # 解析：词语 词频（可选）
            parts = line.split()
            if not parts:
                continue
            word = parts[0]
            freq = default_freq
            if len(parts) >= 2:
                try:
                    freq = int(parts[1])
                    if freq < 1:
                        freq = 1
                except ValueError:
                    print(
                        f"警告：第 {line_num} 行词频无效，使用默认值 {default_freq}",
                        file=sys.stderr,
                    )

            # 处理（interactive=True，允许交互）
            print(f"\n--- 处理第 {line_num} 行：{word} ---")
            success, msg = process_single_word(
                word,
                freq,
                zi_dict,
                target_file,
                existing_words,
                interactive=True,
                force=force,
            )
            if success:
                success_count += 1
            else:
                if "已存在" in msg:
                    skip_count += 1
                else:
                    error_count += 1
                print(f"第 {line_num} 行：{msg}", file=sys.stderr)

    print(
        f"\n批量处理完成：成功 {success_count}，跳过（已存在）{skip_count}，失败 {error_count}"
    )


def main():
    parser = argparse.ArgumentParser(
        description="添加自定义词条到用户词典，支持单次交互和批量处理（批处理也支持交互选择）。"
    )
    parser.add_argument("word", nargs="?", help="要添加的词语（单次模式）")
    parser.add_argument(
        "-F",
        "--freq",
        type=int,
        default=DEFAULT_FREQ,
        help=f"词频（默认 {DEFAULT_FREQ}）",
    )
    parser.add_argument("-i", "--input", help="批量处理文件，每行一个词条（可带词频）")
    parser.add_argument(
        "--first",
        action="store_true",
        help="强制使用每个字的第一个编码（仅单次模式生效，批处理不受影响）",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="跳过已存在检查，强制追加",
    )
    args = parser.parse_args()

    # 校验
    if not args.word and not args.input:
        print("错误：请指定词语（单次模式）或使用 -i 指定输入文件", file=sys.stderr)
        sys.exit(1)
    if args.word and args.input:
        print("警告：同时指定了词语和文件，将忽略词语，仅处理文件", file=sys.stderr)
        args.word = None

    freq = args.freq
    if freq < 1:
        freq = 1

    # 加载字库（zi.pro 优先，zianyin 补充尖音读音）
    zi_dict = load_zi_dict(PRONUNCIATION_FILES)

    # 加载现有词条用于词级查重
    existing_words = load_existing_words(SEARCH_DIRS)
    print(f"已加载 {len(existing_words)} 个现有词条用于查重")

    # 批量模式（交互）
    if args.input:
        process_file(
            args.input,
            freq,
            zi_dict,
            TARGET_FILE,
            existing_words,
            force=args.force,
        )
        sys.exit(0)

    # 单次模式
    interactive = not args.first  # 若 --first 则非交互
    success, msg = process_single_word(
        args.word,
        freq,
        zi_dict,
        TARGET_FILE,
        existing_words,
        interactive=interactive,
        force=args.force,
    )
    if not success:
        print(f"错误：{msg}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
