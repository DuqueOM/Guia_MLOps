#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path


def check_file(filepath):
    MD_PATH = Path(filepath)
    text = MD_PATH.read_text(encoding="utf-8")
    lines = text.splitlines()
    in_code = False
    code_lang = None
    block_start = None
    in_triple = False
    triple_delim = None
    missing_by_block: dict[int, list[int]] = {}

    for i, line in enumerate(lines, start=1):
        if line.startswith("```"):
            if not in_code:
                code_lang = line[3:].strip().lower()
                if code_lang == "python":
                    in_code = True
                    block_start = i
                    in_triple = False
                    triple_delim = None
            else:
                in_code = False
                code_lang = None
                block_start = None
                in_triple = False
                triple_delim = None
            continue

        if not (in_code and code_lang == "python"):
            continue

        raw = line
        stripped = raw.strip()
        if stripped == "":
            continue
        if raw.lstrip().startswith("#"):
            continue

        # ignore triple-quoted docstrings/strings
        if not in_triple:
            found: str | None = None
            for delim in ('"""', "'''"):
                if delim in raw:
                    found = delim
                    break
            if found is not None:
                if raw.count(found) % 2 == 1:
                    in_triple = True
                    triple_delim = found
                continue
        else:
            if (
                triple_delim is not None
                and triple_delim in raw
                and raw.count(triple_delim) % 2 == 1
            ):
                in_triple = False
                triple_delim = None
            continue

        if "#" not in raw:
            if block_start is not None:
                missing_by_block.setdefault(block_start, []).append(i)

    total_missing = sum(len(ls) for ls in missing_by_block.values())
    return total_missing, missing_by_block


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python scanner_detailed.py <markdown_file>")
        sys.exit(1)

    filepath = sys.argv[1]
    total_missing, missing_by_block = check_file(filepath)
    print(f"total_missing: {total_missing}")

    if total_missing > 0:
        print("\nDetailed missing lines:")
        for block_start in sorted(missing_by_block.keys()):
            missing_lines = missing_by_block[block_start]
            print(f"\nBlock starting at line {block_start}:")
            for line_num in missing_lines:
                print(f"  Line {line_num} is missing a comment")
