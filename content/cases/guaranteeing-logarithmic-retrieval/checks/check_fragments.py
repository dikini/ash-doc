"""Verify this lesson's named text fragments against dictionaries.ash."""

from pathlib import Path
import re
import sys


OPERATIONS = ("restore_three", "restore", "insert_colored", "blacken_root", "insert")
MARKER = re.compile(r"<!-- (excerpt|signature): ([^#\s]+)#([a-z_]+) -->")
SIGNATURE = re.compile(r"(?:pub )?([a-z_]+) :")


def canonical_fragments(source):
    lines = source.splitlines()
    representation_start = lines.index("type Color =")
    representation_end = lines.index("type BalanceCheck =")
    fragments = {
        ("excerpt", "representation"):
        "\n".join(lines[representation_start:representation_end]).strip("\n")
    }
    signatures = [(i, match[1]) for i, line in enumerate(lines)
                  if (match := SIGNATURE.match(line))]
    for name in OPERATIONS:
        matches = [i for i, candidate in signatures if candidate == name]
        if len(matches) != 1:
            raise ValueError(f"canonical source must have one {name} signature")
        start = matches[0]
        end = next((i for i, _ in signatures if i > start), len(lines))
        fragments["signature", name] = lines[start]
        fragments["excerpt", name] = "\n".join(lines[start:end]).strip("\n")
    return fragments


def check_fragments(document, source):
    expected = canonical_fragments(source)
    seen = set()
    lines = document.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        match = MARKER.fullmatch(line)
        if match:
            kind, path, name = match.groups()
            if path != "src/dictionaries.ash":
                raise ValueError(f"unknown source in fragment marker: {path}")
            key = kind, name
            if key not in expected:
                raise ValueError(f"unknown fragment: {kind} {name}")
            index += 1
            while index < len(lines) and not lines[index].strip():
                index += 1
            if index == len(lines) or lines[index] != "```text":
                raise ValueError("fragment marker must immediately precede a text fence")
            start = index + 1
            index = start
            while index < len(lines) and lines[index] != "```":
                index += 1
            if index == len(lines):
                raise ValueError(f"unclosed text fence for {kind} {name}")
            if key in seen:
                raise ValueError(f"duplicate fragment: {kind} {name}")
            actual = "\n".join(lines[start:index])
            if actual != expected[key]:
                raise ValueError(f"{kind} {name} differs from canonical source")
            seen.add(key)
        elif "<!-- excerpt:" in line or "<!-- signature:" in line:
            raise ValueError("malformed fragment marker")
        elif re.match(r"^(`{3,}|~{3,})", line):
            # Other fences contain complete programs, output, or schematic work.
            fence = re.match(r"^(`{3,}|~{3,})", line)[1]
            index += 1
            while index < len(lines) and not re.fullmatch(
                    rf"{re.escape(fence[0])}{{{len(fence)},}}\s*", lines[index]):
                index += 1
        index += 1
    missing = expected.keys() - seen
    if missing:
        names = ", ".join(f"{kind} {name}" for kind, name in sorted(missing))
        raise ValueError(f"missing required fragment: {names}")
    return len(seen)


def main():
    if len(sys.argv) != 3:
        print("usage: check_fragments.py README.md src/dictionaries.ash", file=sys.stderr)
        return 1
    try:
        count = check_fragments(Path(sys.argv[1]).read_text(),
                                Path(sys.argv[2]).read_text())
    except (OSError, ValueError) as error:
        print(f"verify: {error}", file=sys.stderr)
        return 1
    print(f"Verified {count} exact source fragments as non-executable text.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
