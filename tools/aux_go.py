import os
import re
import csv
import shutil
import unicodedata
import argparse
from typing import List

# ================= 用户配置区 =================
INPUT_DIR_DEFAULT = "dicts"
OUTPUT_ROOT_DEFAULT = "."
CSV_PATH = "tools/aux_code.csv"
BLACKLIST_FILES = {"mixed.dict.yaml", "en.dict.yaml"}
# =============================================

CJK_PATTERN = re.compile(
    r"[〇々の𖿲𖿳\u2e80-\u2fdf\u3400-\u4DBF\u4E00-\u9FFF\U00020000-\U0003347F]"
)
IGNORE_CHARS = set("，。？！、：～·＆“”（）「」『』…")

COMBINING_TONE = {
    "\u0304": "1",  # combining macron → 一声
    "\u0301": "2",  # combining acute → 二声
    "\u030c": "3",  # combining caron → 三声
    "\u0300": "4",  # combining grave → 四声
    "\u0307": "5",  # combining dot above → 轻声（第五声）
}


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


# ---------- CSV 加载 ----------
def load_flypy_aux(csv_path: str) -> dict:
    """从 CSV 加载 flypy 辅助码，返回 {汉字: 辅码}。"""
    aux_map = {}
    with open(csv_path, "r", encoding="utf-8-sig", errors="ignore") as f:
        reader = csv.DictReader(f)
        headers = [h.strip() for h in reader.fieldnames]
        print(f"列标题：{headers}")

        col = "辅码"
        if col not in headers:
            print(f"警告：CSV 中未找到列 '{col}'")
            return aux_map

        for row in reader:
            han = row.get(headers[0], "").strip()
            if not han:
                continue
            cell = row.get(col)
            if cell is None:
                continue
            letters_blocks = re.findall(r"[a-zA-Z]+", cell)
            aux_code = ",".join(block.lower() for block in letters_blocks)
            if aux_code:
                aux_map[han] = aux_code

    return aux_map


# ---------- 处理单个词库文件 ----------
def process_dict_file(in_file, out_file, aux_map, sep=";", add_aux=True):
    passthrough_set = {"的\td\t1000", "了\tl\t999", "吗\tm\t999", "吧\tb\t999"}
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
            if not raw or raw.lstrip().startswith("#"):
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

            if re.fullmatch(r"\d+", col2 or ""):
                col3, col2 = col2, ""

            if raw.strip() in passthrough_set:
                fout.write(raw + "\n")
                continue

            pinyins = [convert_tone(py) for py in (col2.split(" ") if col2 else [])]

            cn_chars = extract_cn_chars(han)
            if not is_valid_han_word(han) or len(cn_chars) != len(pinyins):
                warn = f"# 警告: 拼音数与字数不匹配（{in_file}) => {raw}"
                print(warn)
                fout.write(warn + "\n")
                continue

            aligned_aux = [aux_map.get(ch, "") for ch in cn_chars]

            new_cols = [
                f"{py}{sep}{aux_val}" if add_aux else py
                for py, aux_val in zip(pinyins, aligned_aux)
            ]
            new_col2 = " ".join(new_cols)
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


# ---------- 批量处理 ----------
def collect_dict_files(input_dir):
    return [
        entry
        for entry in os.scandir(input_dir)
        if entry.is_file() and entry.name.endswith((".yaml", ".yml", ".txt"))
    ]


def process_dicts(
    input_dir,
    out_root,
    aux_map,
    add_aux,
    out_suffix,
    files_blacklist=None,
    sep=";",
):
    valid_files = collect_dict_files(input_dir)
    if not valid_files:
        print("输入目录内没有匹配的文件。")
        return

    out_dir = os.path.join(out_root, "dicts-pro" if add_aux else "dicts-base")
    os.makedirs(out_dir, exist_ok=True)

    for entry in valid_files:
        in_file = entry.path
        name = entry.name
        if files_blacklist and name in files_blacklist:
            out_copy = os.path.join(out_dir, name)
            if os.path.abspath(in_file) != os.path.abspath(out_copy):
                shutil.copy2(in_file, out_copy)
                print(f"跳过并原样复制: {name}")
        else:
            out_name = add_suffix_before_extensions(name, out_suffix)
            out_file = os.path.join(out_dir, out_name)
            process_dict_file(in_file, out_file, aux_map, sep=sep, add_aux=add_aux)


# ========== 入口 ==========
def main():
    parser = argparse.ArgumentParser(
        description="批量处理词库：转换拼音并生成 pro（含辅助码）与 base（仅拼音）两个版本。"
    )
    parser.add_argument(
        "-i",
        "--input-dir",
        default=INPUT_DIR_DEFAULT,
        help=f"输入原始词库目录（默认：{INPUT_DIR_DEFAULT}）",
    )
    parser.add_argument(
        "-o",
        "--output-root",
        default=OUTPUT_ROOT_DEFAULT,
        help=f"输出根目录，将生成其下的 dicts-pro 与 dicts-base（默认：{OUTPUT_ROOT_DEFAULT}）",
    )
    args = parser.parse_args()

    flypy_aux = load_flypy_aux(CSV_PATH)
    print(f"已加载 flypy 辅助码，共 {len(flypy_aux)} 条")

    process_dicts(
        args.input_dir,
        args.output_root,
        flypy_aux,
        add_aux=True,
        out_suffix=".pro",
        files_blacklist=BLACKLIST_FILES,
        sep=";",
    )
    process_dicts(
        args.input_dir,
        args.output_root,
        {},
        add_aux=False,
        out_suffix="",
        files_blacklist=BLACKLIST_FILES,
    )


if __name__ == "__main__":
    main()
