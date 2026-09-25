#!/usr/bin/env bash
set -euo pipefail

cd "../shared/rewriter" || exit

xh="flypy/00_xh.txt"
fl="flypy/11_fl.txt"
qmc="flypy/51_qmc.txt"
commit="flypy_commit.txt"

[[ ! -f "$commit" ]] || rm -f "$commit"
touch "$commit"

awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $1}' "$xh" >"$commit"
awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $1}' "$fl" >>"$commit"
awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $1}' "$qmc" >>"$commit"

awk -F'\t' '{
    if ((length($2) == 1 || length($2) == 2 || length($2) == 3 || length($2) == 4) && length($1) == 1) {
        next
    }
    if (length($2) == 4 && length($1) == 2) {
        next
    }
    if (length($2) == 4 && length($1) == 3) {
        next
    }
    print
}' "$commit" >"tmp.txt"
mv "tmp.txt" "$commit"
