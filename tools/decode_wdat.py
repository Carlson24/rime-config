#!/usr/bin/env python3
"""decode_wdat.py — 把 WindInput WDAT v6 词典(.wdat)还原为可读 TSV。

格式说明(WindInput datformat.rs):
  [Header 48B]
    magic "WDAT" | version u32 | dat_size u32 | leaf_count u32
    dat_off | leaf_off | entry_off | str_off | abbrev_off | meta_off | entry_count | char_map_off
  [DAT Base: dat_size*4][DAT Check: dat_size*4][DAT MaxW: dat_size*4]
  [LeafTable: leaf_count*8]   {entry_off u32, entry_len u16, _ u16}
  [EntryRecords: entry_count*22] {text_off u32, text_len u16, weight i32, order u32, boundary u64}
  [StringPool]   [CharMap 1028B]   [Meta 可选]

DAT 语义:
  t = base[s] + c, check[t] == s 校验; c=0 终止符, base[t] < 0 为叶, 叶索引 = -base[t]-1。
  从根状态 0 DFS 收集全部码串, 每叶经 LeafTable 定位 EntryRecords 区间。

输出 TSV 每行: text \t code \t weight \t order \t boundary
"""

import argparse
import struct
import sys

MAGIC = b"WDAT"
HEADER_SIZE = 48
LEAF_SIZE = 8
ENTRY_SIZE = 22
CHARMAP_SIZE = 1028


class Wdat:
    def __init__(self, path):
        with open(path, "rb") as f:
            self.buf = f.read()
        if self.buf[:4] != MAGIC:
            raise ValueError(f"invalid wdat magic: {self.buf[:4]!r}")
        rd = lambda off: struct.unpack_from("<I", self.buf, off)[0]
        self.version = rd(4)
        if self.version != 6:
            print(f"warning: version={self.version}, expected 6", file=sys.stderr)
        self.dat_size = rd(8)
        self.leaf_count = rd(12)
        self.dat_off = rd(16)
        self.leaf_off = rd(20)
        self.entry_off = rd(24)
        self.str_off = rd(28)
        self.abbrev_off = rd(32)
        self.meta_off = rd(36)
        self.entry_count = rd(40)
        self.char_map_off = rd(44)

        self.check_off = self.dat_off + self.dat_size * 4
        self.maxw_off = self.check_off + self.dat_size * 4
        self.base = struct.unpack_from(f"<{self.dat_size}i", self.buf, self.dat_off)
        self.check = struct.unpack_from(f"<{self.dat_size}i", self.buf, self.check_off)
        self.maxw = struct.unpack_from(f"<{self.dat_size}i", self.buf, self.maxw_off)

        self.max_code = struct.unpack_from("<i", self.buf, self.char_map_off)[0]
        cm = struct.unpack_from("<256i", self.buf, self.char_map_off + 4)
        self.rev_map = [0] * (self.max_code + 1)
        for b, c in enumerate(cm):
            if 0 < c <= self.max_code:
                self.rev_map[c] = b

    def in_range(self, t):
        return 0 <= t < self.dat_size

    def terminal_leaf(self, s):
        t = self.base[s]
        if not self.in_range(t) or self.check[t] != s:
            return None
        bt = self.base[t]
        if bt >= 0:
            return None
        return -bt - 1

    def iter_codes(self):
        """DFS 根状态 0, 产出 (code_bytes, leaf_idx)。"""
        stack = [(0, b"")]
        while stack:
            s, path = stack.pop()
            leaf = self.terminal_leaf(s)
            if leaf is not None:
                yield path, leaf
            b = self.base[s]
            if b < 0:
                continue
            for c in range(1, self.max_code + 1):
                t = b + c
                if self.in_range(t) and self.check[t] == s:
                    stack.append((t, path + bytes([self.rev_map[c]])))

    def leaf_entries(self, leaf):
        o = self.leaf_off + leaf * LEAF_SIZE
        eoff, elen = struct.unpack_from("<IH", self.buf, o)
        out = []
        for i in range(elen):
            r = self.entry_off + eoff + i * ENTRY_SIZE
            toff, tlen = struct.unpack_from("<IH", self.buf, r)
            weight = struct.unpack_from("<i", self.buf, r + 6)[0]
            order = struct.unpack_from("<I", self.buf, r + 10)[0]
            boundary = struct.unpack_from("<Q", self.buf, r + 14)[0]
            text = self.buf[self.str_off + toff : self.str_off + toff + tlen].decode(
                "utf-8", "replace"
            )
            out.append((text, weight, order, boundary))
        return out


def main():
    ap = argparse.ArgumentParser(
        description="Decode WindInput WDAT v6 dictionary to readable TSV"
    )
    ap.add_argument("wdat", help="path to .wdat file")
    ap.add_argument("-o", "--out", help="output TSV path (default: <wdat>.tsv)")
    ap.add_argument("--stats", action="store_true", help="print stats to stderr")
    args = ap.parse_args()

    w = Wdat(args.wdat)
    out_path = args.out or (args.wdat.rsplit(".", 1)[0] + ".tsv")

    rows = []
    keys = 0
    entries = 0
    for code, leaf in w.iter_codes():
        keys += 1
        code_s = code.decode("utf-8")
        for text, weight, order, boundary in w.leaf_entries(leaf):
            entries += 1
            rows.append((order, code_s, text))

    # 按 order(词库自然序)升序输出
    rows.sort(key=lambda r: r[0])
    with open(out_path, "w", encoding="utf-8") as f:
        for order, code_s, text in rows:
            f.write(f"{code_s}\t{text}\n")

    print(f"wrote {out_path}: {keys} keys / {entries} entries", file=sys.stderr)

    if args.stats:
        import collections

        weights = []
        orders = []
        bounds = collections.Counter()
        codes_len = collections.Counter()
        for code, leaf in w.iter_codes():
            codes_len[len(code)] += 1
            for text, weight, order, boundary in w.leaf_entries(leaf):
                weights.append(weight)
                orders.append(order)
                bounds[boundary] += 1
        print(f"keys by code-len: {dict(sorted(codes_len.items()))}", file=sys.stderr)
        print(
            f"weight min/median/max: {min(weights)}/{sorted(weights)[len(weights)//2]}/{max(weights)}",
            file=sys.stderr,
        )
        print(f"order range: {min(orders)}..{max(orders)}", file=sys.stderr)
        print(
            f"boundary distinct: {len(bounds)} (nonzero: {sum(v for k,v in bounds.items() if k)})",
            file=sys.stderr,
        )
        print(
            f"abbrev_off={w.abbrev_off} meta_off={w.meta_off} (0 = 无)", file=sys.stderr
        )


if __name__ == "__main__":
    main()
