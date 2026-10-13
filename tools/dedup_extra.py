#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
以 shared/dicts 为数据源，对目标 Rime 词库文件按第一列文本去重。

用法:
    python3 tools/dedup_extra.py <目标词库.dict.yaml> [--source DIR] [--dry-run] [--out FILE]

兼容的条目格式:
    文本
    文本\t编码
    文本\t编码\t权重
"""

import os
import sys
import argparse
import glob


def load_source_texts(source_dir):
    """收集数据源目录下所有 *.dict.yaml 的第一列文本。"""
    texts = set()
    patterns = glob.glob(os.path.join(source_dir, "*.dict.yaml"))
    for filepath in patterns:
        with open(filepath, "r", encoding="utf-8") as f:
            for line in f:
                line = line.rstrip("\n")
                if not line or line.startswith("#"):
                    continue
                texts.add(line.split("\t")[0])
    return texts, len(patterns)


def split_header_body(lines):
    """拆分为头部（注释 + YAML front matter，含结束行）与数据段。"""
    front_start = None
    for i, line in enumerate(lines):
        if line.rstrip("\n") == "---":
            front_start = i
            break
    if front_start is None:
        return lines, []
    for i in range(front_start + 1, len(lines)):
        if lines[i].rstrip("\n") == "...":
            return lines[: i + 1], lines[i + 1:]
    return lines, []


def parse_entries(body):
    """解析数据段，返回 [(第一列文本, 原始行)]。"""
    entries = []
    for line in body:
        if not line or line.startswith("#"):
            continue
        text = line.rstrip("\n").split("\t")[0]
        entries.append((text, line))
    return entries


def main():
    parser = argparse.ArgumentParser(description="以 shared/dicts 为数据源对目标词库按第一列去重")
    parser.add_argument("target", help="目标词库文件路径")
    parser.add_argument("--source", default=None, help="数据源目录（默认仓库 shared/dicts）")
    parser.add_argument("--dry-run", action="store_true", help="只统计，不写文件")
    parser.add_argument("--out", default=None, help="输出文件（默认原地覆盖目标文件）")
    args = parser.parse_args()

    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    source_dir = args.source or os.path.join(base_dir, "shared", "dicts")
    target = args.target

    if not os.path.isfile(target):
        print(f"错误：目标文件不存在 {target}", file=sys.stderr)
        sys.exit(1)

    source_texts, n_files = load_source_texts(source_dir)
    print(f"数据源：{source_dir}（{n_files} 个词库，唯一文本 {len(source_texts)} 个）")

    with open(target, "r", encoding="utf-8") as f:
        lines = f.read().splitlines(keepends=True)

    header, body = split_header_body(lines)
    entries = parse_entries(body)
    kept = [line for text, line in entries if text not in source_texts]
    removed = len(entries) - len(kept)

    print(f"目标：{target}")
    print(f"词条总数：{len(entries)}，移除 {removed}，保留 {len(kept)}")

    if args.dry_run:
        print("（dry-run：未写文件）")
        return

    if not header:
        print("警告：未识别到 YAML front matter，将跳过头部并改写整份文件", file=sys.stderr)

    content = "".join(header) + "".join(kept)
    if lines and lines[-1] and not lines[-1].endswith("\n"):
        content += "\n"

    out_path = args.out or target
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"已写入：{out_path}")


if __name__ == "__main__":
    main()