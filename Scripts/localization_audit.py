#!/usr/bin/env python3
"""
Compare Localizable.xcstrings keys to Swift `String(localized:)` / `localized:` usage.

Usage (repo root):
  python3 Scripts/localization_audit.py

Exit 0 always; prints a human-readable report to stdout.
"""
from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "GraceNotes/GraceNotes/Localizable.xcstrings"
SWIFT_ROOTS = [ROOT / "GraceNotes", ROOT / "GraceNotesTests"]

PAT_STRING = re.compile(r'String\(localized:\s*"((?:[^"\\]|\\.)*)"')
PAT_LOCALIZED = re.compile(r"(?<![\w])localized:\s*\"((?:[^\"\\]|\\.)*)\"")
# Keys resolved at runtime (see WeeklyInsightCandidateBuilder+Candidates.renderLocalizedTemplate).
DYNAMIC_TEMPLATE_KEYS = frozenset(
    {
        "review.insights.recurringPeople.observation",
        "review.insights.recurringPeople.action",
        "review.insights.recurringTheme.need.observation",
        "review.insights.recurringTheme.need.action",
        "review.insights.recurringTheme.gratitude.observation",
        "review.insights.recurringTheme.gratitude.action",
        "review.insights.needsGratitudeGap.observation",
        "review.insights.needsGratitudeGap.action",
        "review.insights.continuityShift.observation",
        "review.insights.continuityShift.action",
        "review.insights.reflectionDays.observation",
    }
)


def unescape_swift_string(inner: str) -> str:
    if "\\" in inner:
        return bytes(inner, "utf-8").decode("unicode_escape")
    return inner


def keys_in_swift() -> tuple[set[str], dict[str, list[str]]]:
    found: set[str] = set()
    locations: dict[str, list[str]] = defaultdict(list)
    for base in SWIFT_ROOTS:
        for path in base.rglob("*.swift"):
            text = path.read_text(encoding="utf-8")
            rel = str(path.relative_to(ROOT))
            for pattern in (PAT_STRING, PAT_LOCALIZED):
                for m in pattern.finditer(text):
                    k = unescape_swift_string(m.group(1))
                    found.add(k)
                    locations[k].append(rel)
    return found, dict(locations)


def main() -> None:
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    catalog_keys = set(data.get("strings", {}).keys())

    code_keys, locs = keys_in_swift()

    effective_code = code_keys | DYNAMIC_TEMPLATE_KEYS
    unused = sorted(catalog_keys - effective_code)
    missing = sorted(code_keys - catalog_keys)

    print("=== Grace Notes localization audit ===\n")
    print(f"Catalog keys: {len(catalog_keys)}")
    print(f"Keys referenced in Swift: {len(code_keys)} (+ {len(DYNAMIC_TEMPLATE_KEYS)} dynamic template keys)")
    print(f"Unused in catalog (not referenced): {len(unused)}")
    print(f"Referenced but missing from catalog: {len(missing)}")
    print()

    if missing:
        print("--- Missing from catalog (build will fall back poorly) ---")
        for k in missing:
            print(f"  {k!r}")
        print()

    # Duplicate English strings (same en value, different keys)
    by_en: dict[str, list[str]] = defaultdict(list)
    for key in catalog_keys:
        entry = data["strings"].get(key, {})
        try:
            en = entry["localizations"]["en"]["stringUnit"]["value"]
        except (KeyError, TypeError):
            continue
        by_en[en].append(key)

    dup_groups = [(en, ks) for en, ks in by_en.items() if len(ks) > 1 and en.strip()]
    dup_groups.sort(key=lambda x: -len(x[1]))

    print("--- Duplicate English values (review for accidental copy drift) ---")
    if not dup_groups:
        print("  (none)")
    else:
        for en, ks in dup_groups[:40]:
            print(f"  {en!r} ({len(ks)} keys)")
            for k in sorted(ks):
                print(f"    - {k}")
        if len(dup_groups) > 40:
            print(f"  ... and {len(dup_groups) - 40} more groups")
    print()

    # Multi-use keys (same key, many files)
    multi = [(k, locs[k]) for k in code_keys if len(set(locs[k])) > 1]
    multi.sort(key=lambda x: -len(x[1]))
    print("--- Keys referenced from multiple files (highest fan-out) ---")
    for k, paths in multi[:25]:
        uniq = sorted(set(paths))
        print(f"  {k}")
        for p in uniq[:8]:
            print(f"    {p}")
        if len(uniq) > 8:
            print(f"    ... +{len(uniq) - 8} more")
    print()

    print("--- Unused keys (first 80) ---")
    for k in unused[:80]:
        print(f"  {k}")
    if len(unused) > 80:
        print(f"  ... {len(unused) - 80} more")
    print()
    print(
        "Tip: unused keys are safe to delete after manual review if they are not "
        "loaded dynamically (e.g. String(localized: String.LocalizationValue(key))) "
        "or used from tests only."
    )


if __name__ == "__main__":
    main()
