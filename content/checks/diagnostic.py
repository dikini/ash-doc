"""Compare one JSON diagnostic with a lesson's expected semantic record."""

import difflib
import json
from pathlib import Path
import sys

actual_path, expected_path, unit_path = map(Path, sys.argv[1:])
records = [json.loads(line) for line in actual_path.read_text().splitlines()]
if len(records) != 1:
    sys.exit(f"expected one diagnostic, got {len(records)}")
actual = records[0]
expected = json.loads(expected_path.read_text())
if actual.get("schema_version") != 1:
    sys.exit("expected diagnostic schema version 1")
# Only checkout location varies; preserve every semantic field and label order.
for label in actual["labels"]:
    # Compiler-owned builtin locations are virtual, not checkout paths.
    if not label["path"].startswith("@builtin."):
        label["path"] = str(Path(label["path"]).relative_to(unit_path))
if actual != expected:
    print("".join(difflib.unified_diff(
        json.dumps(expected, ensure_ascii=False, indent=2).splitlines(True),
        json.dumps(actual, ensure_ascii=False, indent=2).splitlines(True),
        fromfile=str(expected_path), tofile="actual diagnostic",
    )), file=sys.stderr)
    sys.exit(1)
