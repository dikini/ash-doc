"""Compare a multi-diagnostic JSON capture with a lesson's expected records.

The shared diagnostic.py retains single-record rejections; the boolean-operator
station declines once per unknown character, so this lesson keeps the
multi-record comparison local.
"""

import difflib
import json
from pathlib import Path
import sys

actual_path, expected_path, unit_path = map(Path, sys.argv[1:])
records = [json.loads(line) for line in actual_path.read_text().splitlines()]
expected = json.loads(expected_path.read_text())
if len(records) != len(expected):
    sys.exit(f"expected {len(expected)} diagnostics, got {len(records)}")
for actual in records:
    if actual.get("schema_version") != 1:
        sys.exit("expected diagnostic schema version 1")
    # Only checkout location varies; preserve every semantic field and label order.
    for label in actual["labels"]:
        # Compiler-owned builtin locations are virtual, not checkout paths.
        if not label["path"].startswith("@builtin."):
            label["path"] = str(Path(label["path"]).relative_to(unit_path))
if records != expected:
    print("".join(difflib.unified_diff(
        json.dumps(expected, ensure_ascii=False, indent=2).splitlines(True),
        json.dumps(records, ensure_ascii=False, indent=2).splitlines(True),
        fromfile=str(expected_path), tofile="actual diagnostics",
    )), file=sys.stderr)
    sys.exit(1)
