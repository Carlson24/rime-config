#!/usr/bin/env bash
# 由 flypy 三个码表生成 shared/lua/data/flypy_fixed.txt
# 不交换列（保持 编码·⇥中文）、过滤、按中文去重（保留最短编码）
set -euo pipefail

# 以脚本位置定位仓库根目录，可在任意目录运行
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rewriter_dir="$repo_root/shared/rewriter"
fixed="$repo_root/shared/lua/data/flypy_fixed.txt"
sym=" " # 第一列编码后追加的固定符号

inputs=(
  "$rewriter_dir/flypy/00_xh.txt"
  "$rewriter_dir/flypy/11_fl.txt"
  "$rewriter_dir/flypy/51_qmc.txt"
)

for f in "${inputs[@]}"; do
  [[ -f "$f" ]] || {
    echo "缺少输入文件: $f" >&2
    exit 1
  }
done

tmp="$(mktemp "$fixed.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

awk -F'\t' -v sym="$sym" 'BEGIN{OFS="\t"}
{
 value = $2; code = $1
  lv = length(value); lc = length(code)
  if ((lc == 1 || lc == 2 || lc == 3 || lc == 4) && lv == 1) next
  if (lc == 4 && lv == 2) next
  if (lc == 4 && lv == 3) next
  if (!(value in best)) {
    order[++n] = value
    best[value] = code
    best_len[value] = lc
  } else if (lc < best_len[value]) {
    best[value] = code
    best_len[value] = lc
  }
}
END { for (i = 1; i <= n; i++) print best[order[i]] sym, order[i] }' \
  "${inputs[@]}" >"$tmp"

mv "$tmp" "$fixed"
trap - EXIT
echo "已生成: $fixed ($(wc -l <"$fixed") 行)"
