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

# Hand-derived finite oracles, fixed before implementing either calculation.
readonly original='Item(10, Item(20, Item(30, End)))'
readonly valid='Item(10, Item(25, Item(35, End)))'
readonly repeated='Item(10, Item(27, Item(30, End)))'
readonly forbidden='Item(99, Item(20, Item(30, End)))'
readonly result_type='(Result, Bool)'
readonly decisions_type='(Decision, Decision, Decision)'
readonly artifacts_type='(Artifact, Artifact, Artifact)'
readonly boundary_result="((Reject(ForbiddenPosition(0)), Reject(MissingPosition(7)), Reject(CandidateMismatch)), (Allow, Allow, Reject(CandidateMismatch)), ($valid, $repeated, $original), ($valid, $repeated, $original)) : ($decisions_type, $decisions_type, $artifacts_type, $artifacts_type)"

readonly sources=(
    src/01-allow.ash
    src/02-reject.ash
    src/03-cancel.ash
    src/04-batch-boundaries.ash
    src/05-approve-all.ash
    src/06-double-resume.ash
    src/07-missing-resume.ash
    src/08-resume-once.ash
    src/09-owned-discard.ash
    src/controller.ash
    src/edits.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-allow.ash "(Completed($valid), true) : $result_type"
ash_doc_run_accepted "$unit_root" src/02-reject.ash "(Rejected(ScriptedRejection), true) : $result_type"
ash_doc_run_accepted "$unit_root" src/03-cancel.ash "(Cancelled, false) : $result_type"
ash_doc_run_accepted "$unit_root" src/04-batch-boundaries.ash "$boundary_result"
ash_doc_run_accepted "$unit_root" src/05-approve-all.ash "(Completed($forbidden), true) : $result_type"
ash_doc_run_accepted "$unit_root" src/08-resume-once.ash 'true : Bool'
ash_doc_run_accepted "$unit_root" src/09-owned-discard.ash 'false : Bool'
ash_doc_run_rejected "$unit_root" src/06-double-resume.ash 1
ash_doc_run_rejected "$unit_root" src/07-missing-resume.ash 1
ash_doc_check_human "$unit_root" src/06-double-resume.ash "$unit_root/src"
ash_doc_check_human "$unit_root" src/07-missing-resume.ash "$unit_root/src"
# All displayed observations derive from the same literal full-result oracles
# checked above. In particular, 04's list and table select one CLI result's fields.
python3 - "$unit_root" "$boundary_result" \
    "(Completed($valid), true) : $result_type" \
    "(Rejected(ScriptedRejection), true) : $result_type" \
    "(Cancelled, false) : $result_type" \
    "(Completed($forbidden), true) : $result_type" \
    'true : Bool' 'false : Bool' <<'PY_CHECK'
import json
from pathlib import Path
import re
import sys

unit = Path(sys.argv[1])
readme = (unit / "README.md").read_text()
entries = [
    "01-allow.ash", "02-reject.ash", "03-cancel.ash", "05-approve-all.ash",
    "08-resume-once.ash", "09-owned-discard.ash",
]
assert readme.count("<!-- observation:") == len(entries)
for entry, expected in zip(entries, sys.argv[3:], strict=True):
    marker = f"<!-- observation: src/{entry} -->"
    assert readme.count(marker) == 1, entry
    match = re.search(
        re.escape(marker)
        + r"\n<!-- markdownlint-disable MD013 -->\n```text\n(.*?)\n```",
        readme, re.S,
    )
    assert match and match[1] == f"$ ash {entry}\n{expected}", entry

# Split only complete tuple fields, preserving constructor spelling exactly.
def tuple_fields(value):
    assert value[0] == "(" and value[-1] == ")", value
    depth, start, fields = 0, 1, []
    for index, token in enumerate(value[1:-1], 1):
        if token == "(":
            depth += 1
        elif token == ")":
            depth -= 1
        elif token == "," and depth == 0:
            fields.append(value[start:index].strip())
            start = index + 1
        assert depth >= 0, value
    assert depth == 0, value
    fields.append(value[start:-1].strip())
    return fields

boundary_value = sys.argv[2].split(" : ", 1)[0]
groups = [tuple_fields(group) for group in tuple_fields(boundary_value)]
assert [len(group) for group in groups] == [3, 3, 3, 3]

def table_rows(marker):
    assert readme.count(marker) == 1, marker
    remainder = readme.split(marker, 1)[1]
    rows = []
    for line in remainder.splitlines():
        if line.startswith("|"):
            rows.append([cell.strip() for cell in line.split("|")[1:-1]])
        elif rows:
            break
    assert rows and all(re.fullmatch(r"[- :]+", cell) for cell in rows[1])
    return rows[2:]

marker = "<!-- boundary-decisions: src/04-batch-boundaries.ash -->"
assert readme.count(marker) == 1
selected = readme.split(marker, 1)[1].split("\nThe third and fourth groups", 1)[0]
items = re.findall(r"^- (.*?)(?=\n- |\Z)", selected.strip(), re.M | re.S)
inputs = [
    "First group, `0 := 10`, unchanged candidate",
    "First group, `7 := 99`, unchanged candidate",
    "First group, valid edits, unchanged candidate",
    "Second group, `1 := 25`, then `1 := 27`",
    "Second group, empty edits, original candidate",
    "Second group, empty edits, changed candidate",
]
assert [" ".join(item.split()) for item in items] == [
    f"{proposed}: `{decision}`."
    for proposed, decision in zip(inputs, groups[0] + groups[1], strict=True)
]
artifacts = table_rows("<!-- boundary-artifacts: src/04-batch-boundaries.ash -->")
assert artifacts == [
    [label, f"`{worker}`", f"`{model}`"]
    for label, worker, model in zip(
        ["Valid", "Repeated position", "Empty"], groups[2], groups[3], strict=True,
    )
]

worker = (unit / "src/edits.ash").read_text()
controller = (unit / "src/controller.ash").read_text()
boundaries = (unit / "src/04-batch-boundaries.ash").read_text()

def definition(source, name):
    match = re.search(rf"^(?:pub )?{name} : .*?(?=^(?:pub )?\w+ : |\Z)",
                      source, re.M | re.S)
    assert match, name
    return match[0]

# The proposal supplies only edits and a candidate. Authoritative original and
# permission inputs remain controller-owned, including at the actual review.
assert "pub type Proposal = Proposal(Edits, Artifact)" in worker
assert "pub validate : Edits.Proposal -> Edits.Decision" in controller
assert "validate (Edits.Proposal(edits, candidate))" in controller
assert "original () = Edits.Item(10, Edits.Item(20, Edits.Item(30, Edits.End)))" in controller
assert "allowed_positions () = Edits.Item(1, Edits.Item(2, Edits.End))" in controller
inspection = definition(controller, "inspect_edits")
assert "match position_exists (original (), 0, position) {" in inspection
assert inspection.index("Edits.MissingPosition") < inspection.index("match permitted")
assert "match permitted (allowed_positions (), position) {" in inspection
assert "false => Problem (Edits.ForbiddenPosition position)" in inspection
assert "true => inspect_edits rest" in inspection
validation = definition(controller, "validate")
assert "match inspect_edits edits {" in validation
assert "Problem(reason) => Edits.Reject reason" in validation
assert "Accepted => match same_artifact (candidate, model (original (), edits)) {" in validation
assert "true => Edits.Allow" in validation
assert "false => Edits.Reject Edits.CandidateMismatch" in validation
same = definition(controller, "same_artifact")
assert "same_artifact (Edits.End, Edits.End) = true" in same
assert "true => same_artifact (left_rest, right_rest)" in same
assert "same_artifact (left, right) = false" in same

# Distinct recursion preserves the independent comparison: worker reconstruction
# uses a reversed prefix and unchanged suffix; the model visits all indices.
assert "import " not in worker
model = definition(controller, "model_at") + definition(controller, "model")
for forbidden_call in ["worker_candidate", "make_proposal", "replace_from", "rebuild"]:
    assert forbidden_call not in model, forbidden_call
assert "model_at (Edits.End, index, position, value) = Edits.End" in model
assert "let selected = match index == position {" in model
assert "Edits.Item(selected, model_at (rest, index + 1, position, value))" in model
assert "model (model_at (artifact, 0, position, value), rest)" in model
assert "model (artifact, Edits.NoEdits) = artifact" in model
assert "rebuild (Item(value, prefix), suffix) = rebuild (prefix, Item(value, suffix))" in worker
replacement = definition(worker, "replace_from")
assert "true => rebuild (prefix, Item(value, suffix))" in replacement
assert "position, value, index + 1, Item(current, prefix), suffix" in replacement
assert "worker_candidate (updated, rest)" in worker
assert "edits, worker_candidate (original, edits)" in worker

# Preserve the actual script/continuation boundary and executable suffix marker.
body = definition(worker, "worker")
assert "let decision = perform Review.propose proposal\n    let ignored = perform AfterReview.reached ()\n    match decision {" in body
assert "let Proposal(ignored_edits, candidate) = proposal\n            Completed candidate" in body
assert "Reject(reason) => Rejected reason" in body
run = definition(controller, "run_proposal")
assert "let result = handle (Edits.worker proposal) with Edits.Review {" in run
assert "propose offered => match script {" in run
assert "Check => resume (validate offered)" in run
assert "Refuse => resume (Edits.Reject Edits.ScriptedRejection)" in run
assert "Cancel => {\n                let ignored = discard\n                Edits.Cancelled\n            }" in run
assert "(result, false)\n} with Edits.AfterReview {" in run
assert "let (result, ignored_later) = resume ()\n        (result, true)" in run
for name in ["01-allow", "02-reject", "03-cancel"]:
    source = (unit / "src" / f"{name}.ash").read_text()
    assert "Controller.run Controller." in source
wrong = (unit / "src/05-approve-all.ash").read_text()
assert "Edits.Edit(0, 99)" in wrong
assert "Edits.make_proposal (Controller.original (), forbidden_edits)" in wrong
assert "propose ignored => resume Edits.Allow" in wrong
assert "Controller.validate" not in wrong
assert "Edits.More(Edits.Edit(0, 10), Edits.NoEdits), original" in boundaries
assert "Edits.More(Edits.Edit(7, 99), Edits.NoEdits), original" in boundaries
assert "Edits.Edit(1, 25), Edits.More(Edits.Edit(1, 27), Edits.NoEdits)" in boundaries
for batch in ["valid", "repeated", "Edits.NoEdits"]:
    assert f"Controller.model (original, {batch})" in boundaries
assert "(valid_candidate, repeated_candidate, empty_candidate)" in boundaries

# Inspect the causal labels independently of human transcript agreement.
for stem, reason, excerpt in [
    ("06-double-resume", "effect.resume-already-consumed", "resume result"),
    ("07-missing-resume", "effect.resume-not-consumed", "false"),
]:
    fixture = json.loads((unit / "checks" / f"{stem}.diagnostic.json").read_text())
    assert fixture["reason"] == reason, stem
    assert len(fixture["labels"]) == 1, stem
    label = fixture["labels"][0]
    assert (label["role"], label["relationship"]) == ("primary", "continuation_usage")
    assert label["path"] == f"src/{stem}.ash"
    source = (unit / label["path"]).read_bytes()
    assert source[label["byte_start"]:label["byte_end"]].decode() == excerpt, stem
# The rejection explanations depend on the capability's preceding state,
# not just on the bytes selected by the final diagnostic label.
double = (unit / "src/06-double-resume.ash").read_text()
assert "propose ignored => {\n        let result = resume true\n        resume result\n    }" in double
assert double.count("resume ") == 2
missing = (unit / "src/07-missing-resume.ash").read_text()
assert "propose ignored => false\n}" in missing
assert "resume " not in missing and "discard" not in missing
once = (unit / "src/08-resume-once.ash").read_text()
assert "let result = resume true\n        result" in once
assert once.count("resume ") == 1
stop = (unit / "src/09-owned-discard.ash").read_text()
assert "let ignored = discard\n        false" in stop
assert "resume " not in stop
PY_CHECK
ash_doc_finish 11
