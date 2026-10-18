#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

[[ $# -eq 1 ]] || ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"

readonly sources=(
    src/01-bare-cancellation.ash
    src/02-compensated-cancellation.ash
    src/03-commit.ash
    src/04-nested-completion.ash
    src/05-live-inner-cancellation.ash
    src/06-removed-interpreter.ash
    src/07-surviving-interpreter.ash
    src/journal.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"

# These expected outcomes, states, closing orders, snapshots and suffix counts
# were calculated from the protocol before running its implementation.
readonly accepted=(
    01-bare-cancellation
    02-compensated-cancellation
    03-commit
    04-nested-completion
    05-live-inner-cancellation
    07-surviving-interpreter
)
for entry in "${accepted[@]}"; do
    if "$ASH_DOC_ASH_BIN" "$unit_root/src/$entry.ash" \
        > "$ASH_DOC_VERIFY_DIR/$entry.stdout" \
        2> "$ASH_DOC_VERIFY_DIR/$entry.stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 0 ]] || ash_doc_fail "$entry exited $status, expected 0"
    [[ ! -s $ASH_DOC_VERIFY_DIR/$entry.stderr ]] ||
        ash_doc_fail "$entry wrote unexpected standard error"
done

python3 - "$unit_root" "$ASH_DOC_VERIFY_DIR" <<'PY'
from pathlib import Path
import sys

unit, captures = map(Path, sys.argv[1:])
expected = {
    "01-bare-cancellation": "Observation(Cancelled(Requested), 15, 1, 15, 0) : Observation",
    "02-compensated-cancellation": "Observation(Cancelled(Requested), 10, 1, 10, 0) : Observation",
    "03-commit": "Observation(Committed(15), 15, 1, 15, 0) : Observation",
    "04-nested-completion": "((Committed(17), Observation(Committed(17), 17, 21, 1717, 0)), (Cancelled(Requested), Observation(Committed(15), 15, 21, 1515, 0)), (Committed(17), Observation(Cancelled(Requested), 10, 21, 1710, 0))) : ((JournalOutcome, Observation), (JournalOutcome, Observation), (JournalOutcome, Observation))",
    "05-live-inner-cancellation": "Observation(Cancelled(Requested), 10, 21, 1510, 0) : Observation",
    "07-surviving-interpreter": "Observation(Cancelled(Requested), 10, 1, 10, 0) : Observation",
}
readme = (unit / "README.md").read_text()
for entry, wanted in expected.items():
    actual = (captures / f"{entry}.stdout").read_text()
    assert actual == wanted + "\n", (entry, wanted, actual)
    # Every supplied complete success transcript agrees with this same capture.
    marker = f"<!-- result: src/{entry}.ash -->\n```text\n"
    if entry != "04-nested-completion":
        assert readme.count(marker) == 1, entry
        displayed = readme.split(marker, 1)[1].split("\n```", 1)[0]
        assert displayed == f"$ ash rolling-back-a-cancellable-journal/src/{entry}.ash\n{wanted}", entry

# The matrix is a selected view of one complete captured three-scenario value.
# Independent expected full values above check the implementation; these checks
# tie each displayed row to its own part of that same capture.
matrix = (captures / "04-nested-completion.stdout").read_text()
rows = [
    ("both commit", "Committed(17)", "Committed(17)", 17, 21, 1717, 0),
    ("inner cancels", "Cancelled(Requested)", "Committed(15)", 15, 21, 1515, 0),
    ("outer cancels", "Committed(17)", "Cancelled(Requested)", 10, 21, 1710, 0),
]
positions = []
for label, inner, outer, state, order, states, suffix in rows:
    part = f"({inner}, Observation({outer}, {state}, {order}, {states}, {suffix}))"
    positions.append(matrix.index(part))
    row = f"| {label} | `{inner}` | `{outer}` | {state} | {order} | {states} | {suffix} |"
    assert row in readme, row
assert positions == sorted(positions)

# Check the rejection's causal spans against syntax and structural containment,
# independently of the exact English rendering and JSON fixture comparison.
import json
fixture = json.loads((unit / "checks/06-removed-interpreter.diagnostic.json").read_text())
assert fixture["reason"] == "effect.cleanup-context"
labels = fixture["labels"]
assert [label["relationship"] for label in labels] == [
    "discard", "cleanup_action", "abandoned_handler"]
source = (unit / "src/06-removed-interpreter.ash").read_bytes()
discard, action, handler = labels
for label in labels:
    assert label["path"] == "src/06-removed-interpreter.ash"
    assert 0 <= label["byte_start"] < label["byte_end"] <= len(source)
assert source[discard["byte_start"]:discard["byte_end"]] == b"discard"
assert source[action["byte_start"]:action["byte_end"]].startswith(b"(cleanup Journal.report_close {")
assert source[handler["byte_start"]:handler["byte_end"]].startswith(b"handle (cleanup Journal.report_close {")
assert handler["byte_start"] < action["byte_start"] < action["byte_end"] < handler["byte_end"] < discard["byte_start"]
assert source.count(b"with Journal.Closing {") == 2
assert b"perform Journal.Closing.closed 0" in source
module = (unit / "src/journal.ash").read_text()
repair = (unit / "src/07-surviving-interpreter.ash").read_text()
assert "report_close ()" in repair
assert "report_close ignored = perform Closing.closed 1" in module
assert repair.index("with Journal.Cancel<Flag>") < repair.index("with Journal.Closing")
assert repair.index("resource cell<Flag>") < repair.index("cleanup close_journal")
nested = (unit / "src/04-nested-completion.ash").read_text()
assert "Journal.Committed(value) => Cell.write (recorded_inner, value)" in nested
assert "Journal.Cancelled(reason) => Cell.write (recorded_inner, 0)" in nested
assert nested.index("match inner_outcome") < nested.index("match cancel_outer")
assert nested.index("match cancel_outer") < nested.index("let recorded = Cell.read recorded_inner")
assert "match recorded == 0" in nested
assert "false => Journal.Committed recorded" in nested
assert "true => Journal.Cancelled Journal.Requested" in nested
assert "Cell.write (state, snapshot)" in repair

# Also test the reduced rejection with only the two inner handler positions
# exchanged. Keep both source interpreters and the very same action request.
import shutil
minimal = captures / "placement-repair"
minimal.mkdir(exist_ok=True)
shutil.copyfile(unit / "src/journal.ash", minimal / "journal.ash")
old = """    handle {
        handle (cleanup Journal.report_close {
            let ignored = perform Journal.Cancel<Attempt>.cancel Journal.Requested
            Journal.Committed 15
        }) with Journal.Closing {
            closed owner => resume ()
        }
    } with Journal.Cancel<Attempt> {
        cancel reason => {
            let ignored = discard
            Journal.Cancelled reason
        }
    }
"""
new = """    handle {
        handle (cleanup Journal.report_close {
            let ignored = perform Journal.Cancel<Attempt>.cancel Journal.Requested
            Journal.Committed 15
        }) with Journal.Cancel<Attempt> {
            cancel reason => {
                let ignored = discard
                Journal.Cancelled reason
            }
        }
    } with Journal.Closing {
        closed owner => resume ()
    }
"""
original = source.decode()
assert original.count(old) == 1
(minimal / "entry.ash").write_text(original.replace(old, new))
PY

ash_doc_run_accepted "$ASH_DOC_VERIFY_DIR/placement-repair" entry.ash \
    'Cancelled(Requested) : JournalOutcome'
ash_doc_run_rejected "$unit_root" src/06-removed-interpreter.ash 1
ash_doc_check_human "$unit_root" src/06-removed-interpreter.ash "$content_root/cases"
ash_doc_finish 8
