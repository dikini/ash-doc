"""Verify this lesson's closed set of non-executable source fragments."""

from pathlib import Path
import re
import sys


OPERATIONS = ("restore_three", "restore", "insert_colored", "blacken_root", "insert")
PREFIX_OPERATIONS = ("has_value", "is_none", "prefix_run", "lookup_checks", "scenario")
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


def prefix_fragments(source):
    lines = source.splitlines()

    def section(start, end):
        return "\n".join(lines[lines.index(start):lines.index(end)]).strip("\n")

    fragments = {
        ("excerpt", "imports"): "\n".join(lines[:2]),
        ("excerpt", "representation"): section(
            "type PrefixCheck =", "has_value : Int -> Dictionaries.Option<Int> -> Bool"),
        ("excerpt", "keys"): section(
            "    let one = Dictionaries.Next(Dictionaries.Zero)",
            "    let ascending = Dictionaries.More("),
        ("excerpt", "left_left"): section(
            "    let left_left = Dictionaries.More(", "    let left_right = Dictionaries.More("),
        ("excerpt", "matrix_calls"): "\n".join(lines[lines.index("    ("):-1]),
    }
    signatures = [(i, match[1]) for i, line in enumerate(lines)
                  if (match := SIGNATURE.match(line))]
    for name in (*PREFIX_OPERATIONS, "main"):
        matches = [i for i, candidate in signatures if candidate == name]
        if len(matches) != 1:
            raise ValueError(f"canonical source must have one {name} signature")
        start = matches[0]
        fragments["signature", name] = lines[start]
        if name != "main":
            end = next(i for i, _ in signatures if i > start)
            fragments["excerpt", name] = "\n".join(lines[start:end]).strip("\n")
    return fragments


def check_fragments(document, source, prefix_source=None):
    sources = {"src/dictionaries.ash": canonical_fragments(source)}
    if prefix_source is not None:
        sources["src/01-prefix-matrix.ash"] = prefix_fragments(prefix_source)
    expected = {(path, kind, name): code
                for path, fragments in sources.items()
                for (kind, name), code in fragments.items()}
    seen = set()
    lines = document.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        match = MARKER.fullmatch(line)
        if match:
            kind, path, name = match.groups()
            if path not in sources:
                raise ValueError(f"unknown source in fragment marker: {path}")
            key = path, kind, name
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
        names = ", ".join(f"{path}#{name} ({kind})" for path, kind, name in sorted(missing))
        raise ValueError(f"missing required fragment: {names}")
    return len(seen)


def main():
    if len(sys.argv) not in (3, 4):
        print("usage: check_fragments.py README.md src/dictionaries.ash [src/01-prefix-matrix.ash]", file=sys.stderr)
        return 1
    try:
        count = check_fragments(
            Path(sys.argv[1]).read_text(), Path(sys.argv[2]).read_text(),
            Path(sys.argv[3]).read_text() if len(sys.argv) == 4 else None,
        )
    except (OSError, ValueError) as error:
        print(f"verify: {error}", file=sys.stderr)
        return 1
    print(f"Verified {count} exact source fragments as non-executable text.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
