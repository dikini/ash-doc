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

# Derived from the event policy and B(A(payload)), before executing the sources.
readonly public_result='PublicEvent(1, 7) : PublicEvent'
readonly ordered_result='(InternalEvent(1, 7, 0), Snapshot(InternalEvent(1, 7, 424242), Snapshot(InternalEvent(1, 7, 0), End))) : (InternalEvent, Snapshots)'
readonly early_result='(InternalEvent(1, 7, 0), Snapshot(InternalEvent(1, 7, 424242), End)) : (InternalEvent, Snapshots)'
readonly nested_result='(InternalEvent(1, 7, 424242), PublicEvent(1, 7), Snapshot(InternalEvent(1, 7, 424242), End)) : (InternalEvent, PublicEvent, Snapshots)'
readonly copied_result='PublicEvent(1, 424242) : PublicEvent'

readonly sources=(
    src/01-public-view.ash
    src/02-snapshot-order.ash
    src/03-early-collector.ash
    src/04-nested-root.ash
    src/05-copy-secret.ash
    src/06-type-changing-registration.ash
    src/07-internal-to-public.ash
    src/events.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-public-view.ash "$public_result"
ash_doc_run_accepted "$unit_root" src/02-snapshot-order.ash "$ordered_result"
ash_doc_run_accepted "$unit_root" src/03-early-collector.ash "$early_result"
ash_doc_run_accepted "$unit_root" src/04-nested-root.ash "$nested_result"
ash_doc_run_accepted "$unit_root" src/05-copy-secret.ash "$copied_result"
ash_doc_run_rejected "$unit_root" src/06-type-changing-registration.ash 1
ash_doc_run_rejected "$unit_root" src/07-internal-to-public.ash 1
ash_doc_check_human "$unit_root" src/06-type-changing-registration.ash "$unit_root/src"
ash_doc_check_human "$unit_root" src/07-internal-to-public.ash "$unit_root/src"

# Keep displayed complete success observations tied to the same literal oracles
# used above for the complete CLI captures, including value and result type.
python3 - "$unit_root" \
    "$public_result" "$ordered_result" "$early_result" \
    "$nested_result" "$copied_result" <<'PY_CHECK'
from pathlib import Path
import json
import re
import sys

unit = Path(sys.argv[1])
readme = (unit / "README.md").read_text()
entries = [
    "01-public-view.ash", "02-snapshot-order.ash", "03-early-collector.ash",
    "04-nested-root.ash", "05-copy-secret.ash",
]
assert readme.count("<!-- observation:") == len(entries)
for entry, expected in zip(entries, sys.argv[2:], strict=True):
    marker = f"<!-- observation: src/{entry} -->"
    assert readme.count(marker) == 1, entry
    match = re.search(
        re.escape(marker)
        + r"\n<!-- markdownlint-disable MD013 -->\n```text\n(.*?)\n```",
        readme, re.S,
    )
    assert match and match[1] == f"$ ash {entry}\n{expected}", entry

# Assert the source placements that explain why equal-typed callbacks see
# different values. The braces below are lexical scopes in these small files.
def publication_path(entry):
    source = (unit / "src" / entry).read_text().split("main () = ", 1)[1]
    scopes = []
    found = []
    for line in source.splitlines():
        if "perform Events.InternalFeed.publish" in line:
            found.append(tuple(scopes))
        for _ in range(line.count("}")):
            scopes.pop()
        if "{" in line:
            assert line.count("{") == 1, entry
            scopes.append(line.split("{", 1)[0].strip())
    assert not scopes, entry
    assert len(found) == 1, entry
    return found[0]

assert publication_path("02-snapshot-order.ash") == (
    "handle", "let final_event = hook Events.InternalFeed",
    "register Events.InternalFeed Events.snapshot",
    "register Events.InternalFeed Events.redact",
    "register Events.InternalFeed Events.snapshot",
)
assert publication_path("03-early-collector.ash") == (
    "handle", "let final_event = hook Events.InternalFeed",
    "register Events.InternalFeed Events.snapshot",
    "register Events.InternalFeed Events.redact",
)
assert publication_path("04-nested-root.ash") == (
    "handle", "let internal = hook Events.InternalFeed",
    "register Events.InternalFeed Events.redact", "hook Events.InternalFeed",
    "register Events.InternalFeed Events.snapshot",
)
for entry in entries[1:4]:
    source = (unit / "src" / entry).read_text()
    assert "} with Events.CollectInternal {" in source, entry
    assert "Events.Snapshot(event, later)" in source, entry
    assert "resume ()" in source, entry

module = (unit / "src/events.ash").read_text()
assert "pub type InternalEvent = InternalEvent(Int, Int, Int)" in module
assert "pub type PublicEvent = PublicEvent(Int, Int)" in module
assert "pub collect_public : PublicEvent -> PublicEvent" in module
assert "public_view (InternalEvent(event_id, code, ignored_secret)) = {\n    PublicEvent(event_id, code)" in module
assert "redact (InternalEvent(event_id, code, ignored_secret)) = {\n    InternalEvent(event_id, code, 0)" in module
assert "snapshot event = {\n    let ignored = perform CollectInternal.capture event\n    event\n}" in module
nested = (unit / "src/04-nested-root.ash").read_text()
assert "Events.collect_public (Events.public_view internal)" in nested
wrong = (unit / "src/05-copy-secret.ash").read_text()
assert "Events.InternalEvent(event_id, ignored_code, secret)" in wrong
assert "Events.PublicEvent(event_id, secret)" in wrong

# Match the semantic labels to the exact source relationships explained in
# the chapter; fixture equality alone would not explain what those bytes mean.
causes = {
    "06-type-changing-registration": (
        "type.mismatch", [
            ("expression", "src/06-type-changing-registration.ash",
             "register Events.InternalFeed Events.public_view {\n"
             "        perform Events.InternalFeed.publish "
             "(Events.InternalEvent(1, 7, 424242))\n    }"),
        ],
    ),
    "07-internal-to-public": (
        "type.argument", [
            ("argument", "src/07-internal-to-public.ash",
             "(Events.InternalEvent(1, 7, 424242))"),
            ("function_domain", "src/events.ash", "collect_public"),
            ("application", "src/07-internal-to-public.ash",
             "Events.collect_public (Events.InternalEvent(1, 7, 424242))"),
        ],
    ),
}
for stem, (reason, expected_labels) in causes.items():
    fixture = json.loads((unit / "checks" / f"{stem}.diagnostic.json").read_text())
    assert fixture["reason"] == reason, stem
    assert len(fixture["labels"]) == len(expected_labels), stem
    for label, (relationship, path, excerpt) in zip(
        fixture["labels"], expected_labels, strict=True,
    ):
        assert (label["relationship"], label["path"]) == (relationship, path), stem
        source = (unit / path).read_bytes()
        assert source[label["byte_start"]:label["byte_end"]].decode() == excerpt, stem
PY_CHECK

# Execute both concrete repairs in temporary sibling modules. No extra
# checked-in example or alternate compiler build is needed for these edits.
repair_root=$(mktemp -d "$ASH_DOC_VERIFY_DIR/repairs.XXXXXX")
cp "$unit_root/src/events.ash" "$repair_root/events.ash"
python3 - "$unit_root" "$repair_root" <<'PY_REPAIR'
from pathlib import Path
import sys

unit, repairs = map(Path, sys.argv[1:])
registration = (unit / "src/06-type-changing-registration.ash").read_text()
registration = registration.replace("main : Unit -> Events.InternalEvent",
                                    "main : Unit -> Events.PublicEvent")
registration = registration.replace("Events.InternalFeed", "Events.PublicFeed")
registration = registration.replace("Events.public_view {", "Events.collect_public {")
registration = registration.replace(
    "(Events.InternalEvent(1, 7, 424242))",
    "(Events.public_view (Events.InternalEvent(1, 7, 424242)))",
)
assert "register Events.PublicFeed Events.collect_public" in registration
(repairs / "06-repaired.ash").write_text(registration)
argument = (unit / "src/07-internal-to-public.ash").read_text()
assert argument.count("(Events.InternalEvent(1, 7, 424242))") == 1
argument = argument.replace(
    "(Events.InternalEvent(1, 7, 424242))",
    "(Events.public_view (Events.InternalEvent(1, 7, 424242)))",
)
(repairs / "07-repaired.ash").write_text(argument)
PY_REPAIR
ash_doc_run_accepted "$repair_root" 06-repaired.ash "$public_result"
ash_doc_run_accepted "$repair_root" 07-repaired.ash "$public_result"
ash_doc_finish 8
