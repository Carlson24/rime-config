#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 添加自定义词条到用户词典（zhuaiwen.dict.yaml），输出 flypy 编码格式。
#
# 编码规则:
#   - 每个字从 zi 源（flypy 编码词库）取其 flypy 码（多音字交互选择）
#   - 按「字级绑定」查 zian_map.csv：把映射中的原拼音转成 flypy，
#     与所选 flypy 码同构比对；命中则取得该字的尖音 flypy 码
#   - 词条追加：标准 flypy 一条；若有尖音码且不同，再追加尖音一条
#
# 依赖:
#   - tools/zian_map.csv       三列：汉字 / 尖音全拼 / 原全拼
#   - shared/dicts/zi.flypy.dict.yaml  字 → flypy 码（来源可自行配置）
#
# 用法:
#   python3 tools/add_dict.py 词语                 # 单次
#   python3 tools/add_dict.py 词语 -F 20           # 指定词频
#   python3 tools/add_dict.py -i words.txt         # 批量（每行: 词语 [词频]）
#   python3 tools/add_dict.py 词语 --first         # 自动取第一个编码
#   python3 tools/add_dict.py 词语 -f              # 跳过查重强制追加

import sys
import os
import argparse

from pinyin_to_flypy import build_transformer, FLYPY_PRO_RULES

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_FILE = os.path.join(BASE_DIR, "shared", "dicts", "zi.flypy.dict.yaml")
MAP_FILE = os.path.join(BASE_DIR, "tools", "zian_map.csv")
TARGET_FILE = os.path.join(
    BASE_DIR, "shared", "dicts_extra", "zhuaiwen.flypy.dict.yaml"
)
SEARCH_DIRS = [
    os.path.join(BASE_DIR, "shared", "dicts"),
    os.path.join(BASE_DIR, "shared", "dicts_extra"),
]
DEFAULT_FREQ = 10
BODY_MARKER = "# --- zhuaiwen ---"

# flypy 转换器（全拼 → flypy 码），规则硬编码于 pinyin_to_flypy.FLPY_PRO_RULES
FLYPY = build_transformer(FLYPY_PRO_RULES)


def load_zi_dict(filepath):
    """
    加载读音字库（flypy 编码），返回 {字: [flypy码1, flypy码2, ...]}。
    同一字的编码去重并保留顺序；编码中的辅助码后缀（分号部分）剥离。
    """
    zi_dict = {}
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
                        code = code.split(";", 1)[0]  # 剥离辅助码
                        codes = zi_dict.setdefault(char, [])
                        if code not in codes:
                            codes.append(code)
    except FileNotFoundError:
        print(f"错误：源字典文件不存在：{filepath}", file=sys.stderr)
        sys.exit(1)
    return zi_dict


def derive_tone5(hanzi, target_pinyin, orig_pinyin):
    """由拼音派生轻声（声调5）映射条目：ji4 -> ji5，zii4 -> zii5"""
    if not orig_pinyin or not orig_pinyin[-1].isdigit():
        return None
    return orig_pinyin[:-1] + "5", target_pinyin[:-1] + "5"


def load_zian_map(map_file):
    """
    加载尖音映射表（三列：汉字、尖音全拼、原全拼），返回 {字: {原全拼: 尖音全拼}}。
    同时为每条派生声调5（轻声）映射。
    """
    mapping = {}
    total_lines = 0
    derived_lines = 0
    skipped_lines = 0
    try:
        with open(map_file, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split("\t")
                if len(parts) < 3:
                    print(
                        f"警告：第 {line_num} 行格式错误（少于3列）：{line}",
                        file=sys.stderr,
                    )
                    skipped_lines += 1
                    continue
                hanzi, target_pinyin, orig_pinyin = parts[0], parts[1], parts[2]
                if not (hanzi and target_pinyin and orig_pinyin):
                    print(
                        f"警告：第 {line_num} 行存在空列，跳过：{line}",
                        file=sys.stderr,
                    )
                    skipped_lines += 1
                    continue
                char_map = mapping.setdefault(hanzi, {})
                if orig_pinyin not in char_map:
                    char_map[orig_pinyin] = target_pinyin
                    total_lines += 1
                derived = derive_tone5(hanzi, target_pinyin, orig_pinyin)
                if derived and derived[0] not in char_map:
                    char_map[derived[0]] = derived[1]
                    derived_lines += 1
    except FileNotFoundError:
        print(f"错误：映射文件不存在：{map_file}", file=sys.stderr)
        sys.exit(1)
    print(
        f"加载尖音映射：总条目数 {total_lines}，派生声调5条目 {derived_lines}，"
        f"不同汉字数 {len(mapping)}，跳过 {skipped_lines} 行"
    )
    return mapping


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


def sort_dict_file(target_file):
    """
    重排目标词典正文（BODY_MARKER 行之后的词语区）。
    按词分组，组间键 (字数, 该组第一条编码首字符)，组内保持原序。
    标记行及之前内容（含标点区）保持不变。
    """
    with open(target_file, "r", encoding="utf-8") as f:
        lines = f.read().split("\n")

    sep_idx = next(
        (i for i, l in enumerate(lines) if l.strip() == BODY_MARKER),
        None,
    )
    if sep_idx is None:
        return
    header = lines[: sep_idx + 1]
    body = [l for l in lines[sep_idx + 1 :] if l.strip()]

    groups = {}
    order = []
    for l in body:
        word = l.split("\t", 1)[0].strip()
        if word not in groups:
            groups[word] = []
            order.append(word)
        groups[word].append(l)

    def key(word):
        code = groups[word][0].split("\t", 1)[1].strip()
        return (len(word), code[0])

    sorted_words = sorted(order, key=key)
    out = list(header)
    for w in sorted_words:
        out.extend(groups[w])
    text = "\n".join(out).rstrip("\n") + "\n"
    with open(target_file, "w", encoding="utf-8") as f:
        f.write(text)


def to_flypy(pinyin_full):
    """全拼（带声调数字）转 flypy 码；含分号辅助码时剥离再转。"""
    if ";" in pinyin_full:
        pinyin_full = pinyin_full.split(";", 1)[0]
    return FLYPY(pinyin_full + ";")[:-1]


def choose_code_for_char(char, code_list, auto_first=False):
    """交互式选择或自动取第一个 flypy 码。"""
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


def match_zian_for_flypy(char, flypy_code, zian_map):
    """
    字级绑定：将该字在 zian_map 中所有 (原全拼 → 尖音全拼) 对的原全拼
    转成 flypy 码，与传入的 flypy 码同构比对，返回所有命中的尖音 flypy 码列表。
    例如 剪 ji码 jm3，zian_map 键 jian3→flypy jm3 命中 → 尖音 zian3→flypy om3。
    """
    if char not in zian_map:
        return []
    hits = []
    for orig_pinyin, zian_pinyin in zian_map[char].items():
        if to_flypy(orig_pinyin) == flypy_code:
            hits.append(to_flypy(zian_pinyin))
    return hits


def choose_zian_code(char, flypy_code, zian_map, auto_first=False):
    """
    为该字的所选 flypy 码确定尖音 flypy 码。
    多个命中时交互选择；无命中返回 None。
    """
    hits = match_zian_for_flypy(char, flypy_code, zian_map)
    if not hits:
        return None
    if len(hits) == 1 or auto_first:
        return hits[0]

    print(f"\n字“{char}”（{flypy_code}）有多个尖音编码：")
    for idx, code in enumerate(hits, start=1):
        print(f"  {idx}. {code}")
    while True:
        try:
            choice = input("请选择序号 (1-{}): ".format(len(hits))).strip()
            if not choice:
                continue
            num = int(choice)
            if 1 <= num <= len(hits):
                return hits[num - 1]
            print(f"请输入 1 到 {len(hits)} 之间的数字。")
        except ValueError:
            print("请输入有效数字。")


def process_single_word(
    word,
    freq,
    zi_dict,
    zian_map,
    target_file,
    existing_words,
    interactive=True,
    force=False,
):
    """
    处理单个词条：查重、逐字取 flypy 码并绑定尖音、追加。
    每个字取 flypy 码；再按字级绑定查尖音映射，命中则生成尖音 flypy 码。
    若整词存在尖音且与标准不同，追加两条（标准在前、尖音在后），否则追加标准一条。
    force=True 时跳过查重，强制追加。
    返回 (成功, 消息)
    """
    if not word:
        return False, "词语为空"

    src_file = existing_words.get(word)
    if src_file and not force:
        return False, f"词条“{word}”已存在于 {src_file}，未追加"

    zi_codes = []
    zian_codes = []
    for ch in word:
        code_list = zi_dict.get(ch)
        if not code_list:
            return False, f"字“{ch}”在源字典中未找到"
        flypy_code = choose_code_for_char(ch, code_list, auto_first=not interactive)
        zi_codes.append(flypy_code)
        zian_codes.append(
            choose_zian_code(ch, flypy_code, zian_map, auto_first=not interactive)
        )

    zi_combined = " ".join(zi_codes)
    # 尖音版本：命中的字替换为尖音码，未命中保持标准码
    zian_parts = [z if z is not None else c for z, c in zip(zian_codes, zi_codes)]
    zian_combined = " ".join(zian_parts)

    # 追加：有尖音且不同则两条，否则一条
    combined_codes = [zi_combined]
    if zian_combined != zi_combined:
        combined_codes.append(zian_combined)
    for combined_code in combined_codes:
        append_word_to_dict(word, combined_code, freq, target_file)

    appended = len(combined_codes)
    note = "（强制追加）" if force else ""
    return True, f"成功追加 {appended} 条 {word}\t{freq}{note}"


def process_file(
    input_file,
    default_freq,
    zi_dict,
    zian_map,
    target_file,
    existing_words,
    force=False,
):
    """
    批量处理文件，每行格式：词语 或 词语 词频。
    批量模式下多音字/多尖音会交互询问。
    """
    if not os.path.isfile(input_file):
        print(f"错误：输入文件不存在：{input_file}", file=sys.stderr)
        sys.exit(1)

    print("批量模式：多音字/多尖音将依次询问，请准备好输入。")
    success_count = 0
    skip_count = 0
    error_count = 0

    with open(input_file, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue

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

            print(f"\n--- 处理第 {line_num} 行：{word} ---")
            success, msg = process_single_word(
                word,
                freq,
                zi_dict,
                zian_map,
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
        description="添加自定义词条到用户词典（flypy 编码，自动绑定尖音），支持单次交互和批量处理。"
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

    if not args.word and not args.input:
        print("错误：请指定词语（单次模式）或使用 -i 指定输入文件", file=sys.stderr)
        sys.exit(1)
    if args.word and args.input:
        print("警告：同时指定了词语和文件，将忽略词语，仅处理文件", file=sys.stderr)
        args.word = None

    freq = args.freq
    if freq < 1:
        freq = 1

    zi_dict = load_zi_dict(SOURCE_FILE)
    zian_map = load_zian_map(MAP_FILE)

    existing_words = load_existing_words(SEARCH_DIRS)
    print(f"已加载 {len(existing_words)} 个现有词条用于查重")

    if args.input:
        process_file(
            args.input,
            freq,
            zi_dict,
            zian_map,
            TARGET_FILE,
            existing_words,
            force=args.force,
        )
        sort_dict_file(TARGET_FILE)
        sys.exit(0)

    interactive = not args.first
    success, msg = process_single_word(
        args.word,
        freq,
        zi_dict,
        zian_map,
        TARGET_FILE,
        existing_words,
        interactive=interactive,
        force=args.force,
    )
    if not success:
        print(f"错误：{msg}", file=sys.stderr)
        sys.exit(1)
    sort_dict_file(TARGET_FILE)


if __name__ == "__main__":
    main()
