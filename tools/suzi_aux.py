import pandas as pd
import chardet
import os


# ---------------------------------
# 工具函数：检测文件编码
# ---------------------------------
def detect_encoding(filepath):
    with open(filepath, "rb") as f:
        raw = f.read(10000)
        result = chardet.detect(raw)
        return result["encoding"]


# ---------------------------------
# 主流程
# ---------------------------------
A_FILE = "flypy_suzi.pro.dict.yaml"
CSV_FILE = "aux_code.csv"

# 1. 如果 CSV 不存在，创建空文件并写入表头
if not os.path.exists(CSV_FILE):
    pd.DataFrame(columns=["字", "辅码"]).to_csv(
        CSV_FILE, index=False, encoding="utf-8-sig"
    )
    print(f"已创建新的 {CSV_FILE}，请检查表头是否正确。")

# 2. 检测编码
enc_a = detect_encoding(A_FILE)
enc_csv = detect_encoding(CSV_FILE)  # 用于读取现有 CSV
print(f"A 编码: {enc_a}, CSV 编码: {enc_csv}")

# 3. 读取现有 CSV，获取已存在的 '#' 列的值集合（用于去重）
try:
    df_existing = pd.read_csv(CSV_FILE, encoding=enc_csv)
    existing_keys = set(df_existing["字"].astype(str).tolist())  # 确保字符串比较
except Exception as e:
    print(f"读取 CSV 出错: {e}")
    exit()

print(f"现有 CSV 中已有 {len(existing_keys)} 个不重复的 key。")


# 5. 读取 A 文件，按规则生成待追加的行
new_rows = []
skipped_dup = 0
skipped_no_b = 0

with open(A_FILE, "r", encoding=enc_a) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        key = parts[0]
        col2 = parts[1]
        a_value = col2.split(";", 1)[1] if ";" in col2 else ""

        # 去重检查
        if key in existing_keys:
            skipped_dup += 1
            continue

        new_rows.append([key, a_value])

print(
    f"处理完成: 跳过已存在的 key {skipped_dup} 个，跳过无匹配 B 的 key {skipped_no_b} 个，新增 {len(new_rows)} 行。"
)

# 6. 如果存在新行，追加到 CSV
if new_rows:
    new_df = pd.DataFrame(new_rows, columns=df_existing.columns.tolist())
    df_combined = pd.concat([df_existing, new_df], ignore_index=True)
    df_combined.to_csv(CSV_FILE, index=False, encoding="utf-8-sig")
    print(f"成功追加 {len(new_rows)} 行到 {CSV_FILE}")
else:
    print("没有需要追加的新行。")
