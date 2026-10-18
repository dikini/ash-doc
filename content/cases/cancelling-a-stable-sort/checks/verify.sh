#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi
ash_doc_prepare "$1"

# These literal order, count, and trace oracles precede the implementation.
readonly ordered='More(Record(Low, 2), More(Record(Low, 5), More(Record(Normal, 1), More(Record(Normal, 3), More(Record(High, 4), End)))))'
readonly trace='Comparison(4, 5, After, Comparison(3, 5, After, Comparison(3, 4, Before, Comparison(2, 5, Same, Comparison(1, 2, After, Comparison(1, 5, After, Comparison(1, 3, Same, Done)))))))'
readonly six_trace='Comparison(4, 5, After, Comparison(3, 5, After, Comparison(3, 4, Before, Comparison(2, 5, Same, Comparison(1, 2, After, Comparison(1, 5, After, Done))))))'
readonly equal_records='More(Record(Normal, 11), More(Record(Normal, 12), More(Record(Normal, 13), End)))'
readonly equal_trace='Comparison(12, 13, Same, Comparison(11, 12, Same, Done))'
readonly run_type='(Result, Int, Comparisons)'
readonly complete="(Sorted($ordered), 7, $trace)"
readonly zero='(Cancelled, 0, Done)'
readonly six="(Cancelled, 6, $six_trace)"
readonly main_result="($complete, $ordered) : ($run_type, Records)"
readonly budgets_result="($zero, $six, $complete, $complete) : ($run_type, $run_type, $run_type, $run_type)"
readonly small_result="((Sorted(End), 0, Done), (Sorted(More(Record(High, 9), End)), 0, Done), (Sorted($equal_records), 2, $equal_trace)) : ($run_type, $run_type, $run_type)"
readonly unstable_result='More(Record(Normal, 13), More(Record(Normal, 12), More(Record(Normal, 11), End))) : Records'
readonly repaired_result="Sorted($ordered) : Result"

readonly sources=(
    src/01-complete.ash
    src/02-budgets.ash
    src/03-small-inputs.ash
    src/04-unstable.ash
    src/05-double-resume.ash
    src/06-single-resume.ash
    src/reference.ash
    src/sort.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-complete.ash "$main_result"
ash_doc_run_accepted "$unit_root" src/02-budgets.ash "$budgets_result"
ash_doc_run_accepted "$unit_root" src/03-small-inputs.ash "$small_result"
ash_doc_run_accepted "$unit_root" src/04-unstable.ash "$unstable_result"
ash_doc_run_accepted "$unit_root" src/06-single-resume.ash "$repaired_result"
ash_doc_run_rejected "$unit_root" src/05-double-resume.ash 1
ash_doc_check_human "$unit_root" src/05-double-resume.ash "$unit_root/src"

# The full literal observations have just been compared byte for byte with
# actual CLI captures. Check their properties without the Ash comparator or
# reference implementation, and derive every displayed component from them.
python3 - "$unit_root" "$main_result" "$budgets_result" "$small_result" \
    "$unstable_result" "$repaired_result" <<'PY_CHECK'
from collections import Counter
import json
from pathlib import Path
import re
import sys

unit = Path(sys.argv[1])
readme = (unit / "README.md").read_text()
observations = dict(zip(
    ["01-complete.ash", "02-budgets.ash", "03-small-inputs.ash",
     "04-unstable.ash", "06-single-resume.ash"], sys.argv[2:], strict=True,
))

def parse(text):
    value = text.split(" : ", 1)[0]
    tokens = re.findall(r"[A-Za-z_][A-Za-z_0-9]*|[0-9]+|[(),]", value)
    assert re.sub(r"\s+", "", value) == "".join(tokens), value
    position = 0

    def item():
        nonlocal position
        name = tokens[position]
        position += 1
        if name.isdigit():
            return int(name)
        if name == "(":
            name = "Tuple"
            position -= 1
        arguments = []
        if position < len(tokens) and tokens[position] == "(":
            position += 1
            if tokens[position] != ")":
                while True:
                    arguments.append(item())
                    if tokens[position] != ",":
                        break
                    position += 1
            assert tokens[position] == ")"
            position += 1
        return name, tuple(arguments)

    result = item()
    assert position == len(tokens)
    return result

def fields(node, name, arity):
    assert node[0] == name and len(node[1]) == arity, node
    return node[1]

def records(node):
    result = []
    while node != ("End", ()):
        record, node = fields(node, "More", 2)
        priority, identifier = fields(record, "Record", 2)
        assert not priority[1] and priority[0] in ["Low", "Normal", "High"]
        assert isinstance(identifier, int)
        result.append((priority[0], identifier))
    return result

def trace(node):
    result = []
    while node != ("Done", ()):
        left, right, ordering, node = fields(node, "Comparison", 4)
        assert not ordering[1]
        result.append((left, right, ordering[0]))
    return result

def run(node):
    result, used, calls = fields(node, "Tuple", 3)
    calls = trace(calls)
    assert isinstance(used, int) and used == len(calls)
    return result, used, calls

# Hand-declared input and answers, independent of either Ash algorithm.
original = [("Normal", 1), ("Low", 2), ("Normal", 3), ("High", 4), ("Low", 5)]
expected = [("Low", 2), ("Low", 5), ("Normal", 1), ("Normal", 3), ("High", 4)]
expected_calls = [
    (4, 5, "After"), (3, 5, "After"), (3, 4, "Before"), (2, 5, "Same"),
    (1, 2, "After"), (1, 5, "After"), (1, 3, "Same"),
]
rank = {"Low": 0, "Normal": 1, "High": 2}

def assert_stable(input_records, output_records):
    assert Counter(input_records) == Counter(output_records)
    assert all(rank[left[0]] <= rank[right[0]]
               for left, right in zip(output_records, output_records[1:]))
    for priority in rank:
        assert [identifier for key, identifier in output_records if key == priority] == [
            identifier for key, identifier in input_records if key == priority
        ]

complete, reference = fields(parse(observations["01-complete.ash"]), "Tuple", 2)
result, used, calls = run(complete)
output = records(fields(result, "Sorted", 1)[0])
assert output == expected and [identifier for _, identifier in output] == [2, 5, 1, 3, 4]
assert_stable(original, output)
assert records(reference) == expected
assert_stable(original, records(reference))
assert used == 7 and calls == expected_calls
priorities = dict((identifier, priority) for priority, identifier in original)
for left, right, ordering in calls:
    difference = rank[priorities[left]] - rank[priorities[right]]
    assert ordering == ("Before" if difference < 0 else "Same" if difference == 0 else "After")
assert [Counter(left for left, _, _ in calls)[identifier] for identifier in [5, 4, 3, 2, 1]] == [0, 1, 2, 1, 3]

budgets = fields(parse(observations["02-budgets.ash"]), "Tuple", 4)
for budget, value, wanted_count in zip([0, 6, 7, 8], budgets, [0, 6, 7, 7], strict=True):
    outcome, count, prefix = run(value)
    assert count == wanted_count and count <= budget
    assert prefix == expected_calls[:count]
    if budget in [0, 6]:
        assert outcome == ("Cancelled", ())
    else:
        actual = records(fields(outcome, "Sorted", 1)[0])
        assert actual == expected
        assert_stable(original, actual)

small = fields(parse(observations["03-small-inputs.ash"]), "Tuple", 3)
for value, wanted_input, wanted_count, wanted_trace in zip(
    small,
    [[], [("High", 9)], [("Normal", 11), ("Normal", 12), ("Normal", 13)]],
    [0, 0, 2], [[], [], [(12, 13, "Same"), (11, 12, "Same")]], strict=True,
):
    outcome, count, actual_trace = run(value)
    actual = records(fields(outcome, "Sorted", 1)[0])
    assert actual == wanted_input and count == wanted_count
    assert actual_trace == wanted_trace
    assert_stable(wanted_input, actual)
wrong = records(parse(observations["04-unstable.ash"]))
equal_input = [("Normal", 11), ("Normal", 12), ("Normal", 13)]
assert wrong == [("Normal", 13), ("Normal", 12), ("Normal", 11)]
assert Counter(wrong) == Counter(equal_input)
assert [identifier for _, identifier in wrong] != [identifier for _, identifier in equal_input]
assert records(fields(parse(observations["06-single-resume.ash"]), "Sorted", 1)[0]) == expected

# Exact full success transcripts and tables summarizing the same captures.
assert readme.count("<!-- observation:") == 3
for entry in ["03-small-inputs.ash", "04-unstable.ash", "06-single-resume.ash"]:
    marker = f"<!-- observation: src/{entry} -->"
    assert readme.count(marker) == 1
    match = re.search(re.escape(marker) + r"\n<!-- markdownlint-disable MD013 -->\n```text\n(.*?)\n```", readme, re.S)
    assert match and match[1] == f"$ ash {entry}\n{observations[entry]}"

def table(marker):
    assert readme.count(marker) == 1, marker
    rows = []
    for line in readme.split(marker, 1)[1].splitlines():
        if line.startswith("|"):
            rows.append([cell.strip() for cell in line.split("|")[1:-1]])
        elif rows:
            break
    assert rows and all(re.fullmatch(r"[- :]+", cell) for cell in rows[1])
    return rows[2:]

assert table("<!-- comparison-trace: src/01-complete.ash -->") == [
    [str(index), f"`{left}`", f"`{right}`", f"`{ordering}`"]
    for index, (left, right, ordering) in enumerate(calls, 1)
]
assert table("<!-- complete-records: src/01-complete.ash -->") == [
    [str(index), f"`{priority}`", f"`{identifier}`", f"`{ref_priority}`", f"`{ref_id}`"]
    for index, ((priority, identifier), (ref_priority, ref_id)) in enumerate(
        zip(output, records(reference), strict=True)
    )
]
assert table("<!-- budget-observations: src/02-budgets.ash -->") == [
    [f"`{budget}`", f"`{run(value)[0][0]}`", f"`{run(value)[1]}`", row_range]
    for budget, value, row_range in zip([0, 6, 7, 8], budgets, ["None", "1–6", "1–7", "1–7"], strict=True)
]
assert readme.index("<!-- comparison-trace:") < readme.index("## Bound source work")
assert "0 + 1 + 2 + 1 + 3 = 7" in readme
assert "assumes a nonnegative budget" in readme

sort_source = (unit / "src/sort.ash").read_text()
reference_source = (unit / "src/reference.ash").read_text()

def definition(source, name):
    match = re.search(rf"^(?:pub )?{name} : .*?(?=^(?:pub )?\w+ : |\Z)", source, re.M | re.S)
    assert match, name
    return match[0]

# Tie action and tail-first recursion are the algorithmic causes taught here.
insertion = definition(sort_source, "insert")
assert insertion.count("compare (record, current)") == 1
assert insertion.count("perform Compare.allow ()") == 1
assert "let ignored = perform Compare.allow ()\n    match compare (record, current) {" in insertion
assert "insert (record, End) = More(record, End)" in insertion
assert "Before => More(record, More(current, rest))" in insertion
assert "Same => More(record, More(current, rest))" in insertion
assert "After => More(current, insert (record, rest))" in insertion
assert "let ordered_tail = stable_sort rest\n    insert (record, ordered_tail)" in sort_source
comparison = definition(sort_source, "compare")
assert comparison.count("order (") == 1
assert "let ordering = order (left, right)\n    let ignored = perform Trace.compared (left_id, right_id, ordering)\n    ordering" in comparison
assert parse(definition(sort_source, "sample").split("sample () = ", 1)[1].strip())
assert records(parse(definition(sort_source, "sample").split("sample () = ", 1)[1].strip())) == original
assert records(parse(definition(sort_source, "equals").split("equals () = ", 1)[1].strip())) == equal_input
for left in rank:
    for right in rank:
        wanted = "Before" if rank[left] < rank[right] else "Same" if left == right else "After"
        assert f"order ({left}, {right}) = {wanted}" in sort_source

# Permission denial must neither charge work nor construct a partial Sorted.
runner = definition(sort_source, "run")
assert "resource cell<R> used = 0" in runner
assert "let result = handle (Sorted (stable_sort records)) with Compare {" in runner
assert "allow () => match Cell.read used == budget {" in runner
assert "true => {\n                    let ignored = discard\n                    Cancelled\n                }" in runner
assert "false => {\n                    let count = Cell.read used\n                    let ignored = Cell.write (used, count + 1)\n                    resume ()\n                }" in runner
assert runner.count("Cell.write") == 1 and runner.count("Sorted") == 1
assert "(result, Cell.read used, Done)\n    } with Trace {" in runner
assert "let (result, count, later) = resume ()\n            (result, count, Comparison(left_id, right_id, ordering, later))" in runner
for forbidden in ["Sort.insert", "Sort.compare", "Sort.stable_sort", "Sort.run", "Sort.order"]:
    assert forbidden not in reference_source, forbidden
assert "! {" not in reference_source
for name, priority in [("keep_low", "Low"), ("keep_normal", "Normal"), ("keep_high", "High")]:
    filtering = definition(reference_source, name)
    assert f"Sort.{priority} => Sort.More(record, {name} rest)" in filtering
    assert f"other => {name} rest" in filtering
assert "keep_low records, append (keep_normal records, keep_high records)" in reference_source
wrong_source = (unit / "src/04-unstable.ash").read_text()
assert wrong_source.count("Sort.compare (record, current)") == 1
assert wrong_source.count("perform Sort.Compare.allow ()") == 1
assert "let ignored = perform Sort.Compare.allow ()\n    match Sort.compare (record, current) {" in wrong_source
assert "Sort.Same => Sort.More(current, insert_after (record, rest))" in wrong_source
assert "let ordered_tail = unstable_sort rest\n    insert_after (record, ordered_tail)" in wrong_source

# Bind the label to the second identical text occurrence, and preserve the
# prior use within that same clause. Source state explains the rejection.
double = (unit / "src/05-double-resume.ash").read_text()
assert "allow () => {\n        let ignored = resume ()\n        resume ()\n    }" in double
assert double.count("resume ()") == 2
first = double.index("resume ()")
second = double.index("resume ()", first + len("resume ()"))
fixture = json.loads((unit / "checks/05-double-resume.diagnostic.json").read_text())
assert fixture["reason"] == "effect.resume-already-consumed"
assert len(fixture["labels"]) == 1
label = fixture["labels"][0]
assert (label["role"], label["relationship"], label["path"]) == (
    "primary", "continuation_usage", "src/05-double-resume.ash",
)
assert (label["byte_start"], label["byte_end"]) == (second, second + len("resume ()"))
assert double.encode()[label["byte_start"]:label["byte_end"]] == b"resume ()"
repaired = (unit / "src/06-single-resume.ash").read_text()
assert "allow () => {\n            let result = resume ()\n            result\n        }" in repaired
assert "Sort.Sorted (Sort.stable_sort (Sort.sample ()))" in repaired
PY_CHECK
ash_doc_finish 8
