#!/usr/bin/env python3
"""Drift check: the hard-skeleton CI block is deliberately duplicated across
README (3 languages), PLAYBOOK § 10.0, and the paste-ready templates so each
stays copy-paste-able. This script is the sync mechanism: every copy must stay
byte-identical to the canonical block in templates/ci-hard-skeleton.md, the zh
block must stay exactly 301 chars (a documented claim), and the version number
must agree across SKILL.md, PLAYBOOK.md, and the README badges.

Run: python3 scripts/drift_check.py   (exit 1 on any drift)
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CANON = ROOT / "templates/ci-hard-skeleton.md"

BLOCKS = {
    "zh": (r"## 来源与可核对性（硬要求）.*?内部矛盾）",
           ["README.zh.md", "PLAYBOOK.md", "templates/ci-A1-mapping.md", "templates/ci-B1-narrative.md"]),
    "en": (r"## Sourcing & verifiability.*?internal contradictions\)", ["README.md"]),
    "ja": (r"## ソースと照合可能性（必須要件）.*?内部矛盾）", ["README.ja.md"]),
}
ZH_EXPECTED_LEN = 301

failures = []

canon_text = CANON.read_text(encoding="utf-8")
for lang, (pattern, files) in BLOCKS.items():
    canon_m = re.search(pattern, canon_text, re.S)
    if not canon_m:
        failures.append(f"[{lang}] canonical block missing in {CANON.name}")
        continue
    canon_block = canon_m.group(0)
    if lang == "zh" and len(canon_block) != ZH_EXPECTED_LEN:
        failures.append(f"[zh] canonical block is {len(canon_block)} chars, expected {ZH_EXPECTED_LEN}")
    for rel in files:
        text = (ROOT / rel).read_text(encoding="utf-8")
        m = re.search(pattern, text, re.S)
        if not m:
            failures.append(f"[{lang}] block missing in {rel}")
        elif m.group(0) != canon_block:
            failures.append(f"[{lang}] {rel} drifted from {CANON.name} "
                            f"({len(m.group(0))} vs {len(canon_block)} chars)")

def version_of(pattern, rel):
    m = re.search(pattern, (ROOT / rel).read_text(encoding="utf-8"), re.M)
    return m.group(1) if m else None

versions = {
    "SKILL.md": version_of(r"^version:\s*([\d.]+)", "SKILL.md"),
    "PLAYBOOK.md": version_of(r"^version:\s*([\d.]+)", "PLAYBOOK.md"),
    "README.md badge": version_of(r"skill-v([\d.]+)-blue", "README.md"),
    "README.zh.md badge": version_of(r"skill-v([\d.]+)-blue", "README.zh.md"),
    "README.ja.md badge": version_of(r"skill-v([\d.]+)-blue", "README.ja.md"),
}
if None in versions.values() or len(set(versions.values())) != 1:
    failures.append(f"version mismatch: {versions}")

if failures:
    print("DRIFT CHECK FAILED:")
    for f in failures:
        print(f"  ✗ {f}")
    sys.exit(1)
print(f"drift check OK: {sum(len(f) for _, f in BLOCKS.values()) + 1} skeleton copies in sync, "
      f"zh block = {ZH_EXPECTED_LEN} chars, version = {versions['SKILL.md']} everywhere")
