#!/usr/bin/env python3
"""Export Grace Notes xcstrings for en + zh-Hans copy review (batched)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def _unit(entry: dict, lang: str) -> str:
    block = entry.get("localizations", {}).get(lang, {})
    return str(block.get("stringUnit", {}).get("value", ""))


def _load_strings(path: Path) -> dict[str, dict]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("strings", {})


def _sorted_keys(strings: dict[str, dict]) -> list[str]:
    def sort_key(k: str) -> tuple:
        return (0 if k == "" else 1, k.lower())

    return sorted(strings.keys(), key=sort_key)


def _emit_catalog(
    *,
    repo: Path,
    label: str,
    rel: str,
    batch: int | None,
    batch_size: int,
) -> None:
    path = repo / rel
    strings = _load_strings(path)
    keys = [k for k in _sorted_keys(strings) if k != ""]

    offset = 0
    if batch is not None:
        offset = batch * batch_size
        keys = keys[offset : offset + batch_size]

    for i, key in enumerate(keys, start=1):
        entry = strings[key]
        en = _unit(entry, "en")
        zh = _unit(entry, "zh-Hans")
        n = offset + i if batch is not None else i
        print(f"{n}. [{label}] {key}")
        print(f"   {en}（{zh}）")
        print()


def _validate(repo: Path) -> int:
    checks = [
        ("Localizable", "GraceNotes/GraceNotes/Localizable.xcstrings"),
        ("InfoPlist", "GraceNotes/InfoPlist.xcstrings"),
    ]
    code = 0
    for cat, rel in checks:
        path = repo / rel
        strings = _load_strings(path)
        for key in _sorted_keys(strings):
            if key == "":
                continue
            entry = strings[key]
            en = _unit(entry, "en").strip()
            zh = _unit(entry, "zh-Hans").strip()
            if en and not zh:
                print(f"[missing zh-Hans] [{cat}] key={key!r} en={_unit(entry, 'en')!r}", file=sys.stderr)
                code = 1
    return code


def main() -> int:
    parser = argparse.ArgumentParser(description="Export xcstrings batches for copy review.")
    parser.add_argument("--repo", type=Path, default=Path.cwd(), help="Repository root")
    parser.add_argument(
        "--only",
        choices=("localizable", "infoplist"),
        default=None,
        help="Which catalog to export (not used with --validate).",
    )
    parser.add_argument("--batch", type=int, default=None, help="Zero-based batch index (localizable only).")
    parser.add_argument("--batch-size", type=int, default=40)
    parser.add_argument("--validate", action="store_true", help="Verify non-empty en has non-empty zh-Hans.")
    args = parser.parse_args()

    repo = args.repo.resolve()

    if args.validate:
        return _validate(repo)

    if args.only is None:
        print("error: pass --only localizable|infoplist (or use --validate)", file=sys.stderr)
        return 2

    if args.only == "localizable":
        if args.batch is None:
            print("error: --only localizable requires --batch N", file=sys.stderr)
            return 2
        _emit_catalog(
            repo=repo,
            label="Localizable",
            rel="GraceNotes/GraceNotes/Localizable.xcstrings",
            batch=args.batch,
            batch_size=args.batch_size,
        )

    if args.only == "infoplist":
        if args.batch is not None:
            print("warning: --batch is ignored for infoplist", file=sys.stderr)
        _emit_catalog(
            repo=repo,
            label="InfoPlist",
            rel="GraceNotes/InfoPlist.xcstrings",
            batch=None,
            batch_size=args.batch_size,
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
