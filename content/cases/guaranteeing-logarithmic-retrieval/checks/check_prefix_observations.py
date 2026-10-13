"""Check five displayed fields and one summary against the matrix capture.

This recognizes only this fixture's tuple, Scenario, PrefixCheck, and List
shape. Python's AST supplies syntax and exact source ranges; nothing is
evaluated, and every admitted node is checked against the closed shape.
"""

import ast
from pathlib import Path
import re
import sys


TYPE = "(Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)"
LABELS = (
    "Ascending `1` to `7`", "Descending `7` to `1`", "Left-left `3, 2, 1`",
    "Left-right `3, 1, 2`", "Right-left `1, 3, 2`", "Right-right `1, 2, 3`",
)
PREFIX_COUNTS = (7, 7, 3, 3, 3, 3)
MARKER = re.compile(r"<!-- observation: prefix-matrix#([a-z_]+\.[a-z_0-9]+) -->")
SUMMARY = "<!-- summary: prefix-matrix -->"
HEADERS = ("Input order", "Empty", "Prefix checks", "Final flags")


def call_arguments(node, name, arity):
    if (not isinstance(node, ast.Call) or not isinstance(node.func, ast.Name)
            or node.func.id != name or node.keywords or len(node.args) != arity):
        raise ValueError(f"captured value must use {name} with {arity} positional fields")
    return node.args


def true_flag(node):
    if not isinstance(node, ast.Name) or node.id != "true":
        raise ValueError("every captured observation flag must be true")


def prefix_check(node):
    for flag in call_arguments(node, "PrefixCheck", 4):
        true_flag(flag)


def list_items(node, check_item):
    items = []
    while not (isinstance(node, ast.Name) and node.id == "End"):
        item, node = call_arguments(node, "More", 2)
        check_item(item)
        items.append(item)
    return items


def captured_fields(capture):
    if not capture.endswith("\n") or capture.count("\n") != 1:
        raise ValueError("capture must retain one complete stdout line")
    line = capture[:-1]
    if line.count(" : ") != 1:
        raise ValueError("capture must retain one value and its captured type")
    value, captured_type = line.split(" : ")
    if captured_type != TYPE:
        raise ValueError("captured type must retain the six-Scenario tuple")
    try:
        root = ast.parse(value, mode="eval").body
    except SyntaxError as error:
        raise ValueError("invalid captured value syntax") from error
    if not isinstance(root, ast.Tuple) or len(root.elts) != 6:
        raise ValueError("captured tuple must retain six Scenario values")
    scenarios = []
    for node in root.elts:
        empty, checks, lookups = call_arguments(node, "Scenario", 3)
        true_flag(empty)
        prefixes = list_items(checks, prefix_check)
        final_flags = list_items(lookups, true_flag)
        scenarios.append((empty, prefixes, lookups, final_flags))
    counts = tuple(len(prefixes) for _, prefixes, _, _ in scenarios)
    if counts != PREFIX_COUNTS:
        raise ValueError("captured prefix cardinalities must remain 7, 7, 3, 3, 3, 3")
    if tuple(len(flags) for _, _, _, flags in scenarios) != tuple(n + 1 for n in counts):
        raise ValueError("captured final cardinalities must include every association and absence")
    empty, prefixes, lookups, _ = scenarios[2]
    selected = {
        "left_left.empty": empty,
        "left_left.prefix_1": prefixes[0],
        "left_left.prefix_2": prefixes[1],
        "left_left.prefix_3": prefixes[2],
        "left_left.lookups": lookups,
    }
    observations = {name: ast.get_source_segment(value, node)
                    for name, node in selected.items()}
    rows = [(label, f"`{ast.get_source_segment(value, empty)}`", str(len(prefixes)), str(len(flags)))
            for label, (empty, prefixes, _, flags) in zip(LABELS, scenarios)]
    return observations, rows


def cells(line):
    if not line.startswith("|") or not line.endswith("|"):
        raise ValueError("summary must use a four-column Markdown table")
    return tuple(cell.strip() for cell in line[1:-1].split("|"))


def check_observations(document, capture):
    expected, expected_rows = captured_fields(capture)
    seen = set()
    summary_seen = False
    lines = document.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        match = MARKER.fullmatch(line)
        if match:
            name = match[1]
            if name not in expected:
                raise ValueError(f"unknown observation: {name}")
            if name in seen:
                raise ValueError(f"duplicate observation: {name}")
            index += 1
            while index < len(lines) and not lines[index].strip():
                index += 1
            if index == len(lines) or lines[index] != "```text":
                raise ValueError("observation marker must immediately precede a text fence")
            start = index + 1
            index = start
            while index < len(lines) and lines[index] != "```":
                index += 1
            if index == len(lines):
                raise ValueError(f"unclosed text fence for observation {name}")
            if "\n".join(lines[start:index]) != expected[name]:
                raise ValueError(f"observation {name} differs from captured value")
            seen.add(name)
        elif line == SUMMARY:
            if summary_seen:
                raise ValueError("duplicate summary")
            index += 1
            while index < len(lines) and not lines[index].strip():
                index += 1
            table = []
            while index < len(lines) and lines[index].startswith("|"):
                table.append(cells(lines[index]))
                index += 1
            if (len(table) != 8 or table[0] != HEADERS
                    or len(table[1]) != 4
                    or any(not re.fullmatch(r":?-+:?", cell) for cell in table[1])
                    or table[2:] != expected_rows):
                raise ValueError("summary differs from captured scenarios")
            summary_seen = True
            # The first following line may itself carry a marker.
            continue
        elif "<!-- observation:" in line:
            raise ValueError("malformed observation marker")
        elif "<!-- summary:" in line:
            raise ValueError("malformed summary marker")
        elif re.match(r"^(`{3,}|~{3,})", line):
            fence = re.match(r"^(`{3,}|~{3,})", line)[1]
            index += 1
            while index < len(lines) and not re.fullmatch(
                    rf"{re.escape(fence[0])}{{{len(fence)},}}\s*", lines[index]):
                index += 1
        index += 1
    missing = expected.keys() - seen
    if missing:
        raise ValueError("missing required observation: " + ", ".join(sorted(missing)))
    if not summary_seen:
        raise ValueError("missing required summary")
    return len(seen)


def main():
    if len(sys.argv) != 3:
        print("usage: check_prefix_observations.py README.md fixtures/prefix-matrix.stdout", file=sys.stderr)
        return 1
    try:
        count = check_observations(Path(sys.argv[1]).read_text(), Path(sys.argv[2]).read_text())
    except (OSError, ValueError) as error:
        print(f"verify: {error}", file=sys.stderr)
        return 1
    print(f"Verified {count} captured value fields and six scenarios with 26 prefix checks.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
