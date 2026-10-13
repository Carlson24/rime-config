import sys
from collections import defaultdict

# 存储两种统计结果
col1_only = defaultdict(list)  # key: 第一列 -> [(文件名, 行号, 第二列)]
col1_col2 = defaultdict(list)  # key: (第一列, 第二列) -> [(文件名, 行号)]

for filepath in sys.argv[1:]:
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, 1):
                line = line.rstrip("\n")
                if not line:
                    continue
                parts = line.split("\t")
                if len(parts) < 1:
                    continue
                col1 = parts[0]
                col2 = parts[1] if len(parts) > 1 else ""  # 无第二列置为空字符串

                # 记录到两种结构
                col1_only[col1].append((filepath, line_num, col2))
                col1_col2[(col1, col2)].append((filepath, line_num))
    except FileNotFoundError:
        print(f"警告：文件 {filepath} 不存在，已跳过", file=sys.stderr)

# ---------- 输出第一部分：仅第一列重复 ----------
print("=" * 60)
print("【报告一】第一列完全相同（无论第二列是否相同）")
print("=" * 60)

first = True
for col1, locations in col1_only.items():
    if len(locations) > 1:  # 只显示出现多次的
        if not first:
            print("\n" + "-" * 40)  # 分割线
        first = False
        print(f"第一列值: {col1}")
        for fname, lnum, col2 in locations:
            print(f"  - {fname} 第 {lnum} 行, 第二列 = {col2}")

if first:
    print("（无重复）")

# ---------- 输出第二部分：第一列+第二列组合重复 ----------
print("\n" + "=" * 60)
print("【报告二】第一列和第二列组合完全相同")
print("=" * 60)

first = True
for (col1, col2), locations in col1_col2.items():
    if len(locations) > 1:
        if not first:
            print("\n" + "-" * 40)  # 分割线
        first = False
        print(f"组合 (第一列={col1}, 第二列={col2})")
        for fname, lnum in locations:
            print(f"  - {fname} 第 {lnum} 行")

if first:
    print("（无重复）")
