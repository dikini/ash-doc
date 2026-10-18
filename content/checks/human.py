"""Check this edition's displayed human transcript; JSON owns semantic checks."""

import difflib
from pathlib import Path
import re
import sys

actual_path = Path(sys.argv[1])
unit = Path(sys.argv[2]).resolve()
entry, argument = sys.argv[3:5]
mode = sys.argv[5] if len(sys.argv) == 6 else "ordinary"
if mode not in ("ordinary", "native"):
    sys.exit("unknown capture mode")
readme = unit / "README.md"
marker = f"<!-- diagnostic: {entry} -->"
text = readme.read_bytes().decode("utf-8")
if text.count(marker) != 1:
    sys.exit(f"{readme}: expected one marker for {entry}")
match = re.search(
    re.escape(marker) + r"\n<!-- markdownlint-disable MD013 -->\n```text\n(.*?)\n```",
    text, re.DOTALL,
)
if not match:
    sys.exit(f"{readme}: missing complete text fence for {entry}")
actual = actual_path.read_bytes().decode("utf-8")
if "\x1b" in actual or actual.startswith("{") or not actual.endswith("\n"):
    sys.exit("expected complete plain human output, without ANSI or JSON fallback")
# The compiler canonicalizes source paths. Nothing else is normalized.
repo = unit.parents[2]
actual = actual.replace(str(repo) + "/", "/path/to/ash-doc/")
expected = match.group(1) + "\n"
root_option = ' --root ffi="$ASH_LIBRARIES"' if mode == "native" else ""
observed = f"$ ash --message-format human --locale en{root_option} {argument}\n" + actual
if observed != expected:
    print("".join(difflib.unified_diff(
        expected.splitlines(True), observed.splitlines(True),
        fromfile=str(readme), tofile="captured human transcript",
    )), file=sys.stderr)
    sys.exit(1)
