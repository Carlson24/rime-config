#!/usr/bin/env python3
"""Convert OpenCC dictionaries to librime rewriter source format.

OpenCC format:  key<TAB>value(s)   (multiple values separated by spaces)
Rewriter format: key<TAB>value      (one value per line)

Comments (#) and blank lines are preserved; the rewriter compiler skips them.
"""
import os
import sys

SRC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "opencc")
DST_DIR = os.path.dirname(os.path.abspath(__file__))

FILES = [
    "CJK_Compatibility_Ideographs.txt",
    "STPhrases.txt",
    "STPhrases_GeneratedFromRegionalPhrases.txt",
    "STCharacters.txt",
    "HKVariantsPhrases.txt",
    "HKVariants.txt",
    "TWVariantsPhrases.txt",
    "TWVariants.txt",
]


def convert(src_path: str, dst_path: str) -> tuple[int, int]:
    split_rows = 0
    out_lines = []
    with open(src_path, encoding="utf-8") as f:
        for raw in f:
            line = raw.rstrip("\r\n")
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                out_lines.append(line)
                continue
            if "\t" not in line:
                raise ValueError(f"missing TAB separator: {line!r}")
            key, _, values = line.partition("\t")
            if not key:
                raise ValueError(f"empty key: {line!r}")
            for value in values.split(" "):
                if not value:
                    continue
                out_lines.append(f"{key}\t{value}")
                split_rows += 1
    with open(dst_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out_lines) + "\n")
    return split_rows, len(out_lines)


def main() -> int:
    total_splits = 0
    total_lines = 0
    for name in FILES:
        src = os.path.join(SRC_DIR, name)
        dst = os.path.join(DST_DIR, name)
        if not os.path.isfile(src):
            print(f"ERROR: missing source {src}", file=sys.stderr)
            return 1
        splits, lines = convert(src, dst)
        total_splits += splits
        total_lines += lines
        print(f"{name}: {lines} lines ({splits} values split)")
    print(f"total: {total_lines} lines ({total_splits} multi-value rows split)")
    return 0


if __name__ == "__main__":
    sys.exit(main())