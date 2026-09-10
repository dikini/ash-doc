#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
repo_root=$(cd "$unit_root/../.." && pwd)
readonly repo_root

# shellcheck source=../../../content/checks/lib.sh
source "$repo_root/content/checks/lib.sh"

[[ $# -eq 1 ]] || ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" \
    src/tickets.ash src/01-complete-import.ash src/02-type-and-function.ash \
    src/03-function-only.ash src/04-type-only.ash
ash_doc_run_accepted "$unit_root" src/03-function-only.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/04-type-only.ash '42 : Int'
for entry in 01-complete-import 02-type-and-function; do
    ash_doc_run_rejected "$unit_root" "src/$entry.ash" 2
    human_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/lab-stdout.XXXXXX")
    human_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/lab-stderr.XXXXXX")
    status=0
    (cd "$unit_root/src" && "$ASH_DOC_ASH_BIN" --message-format human \
        --locale en "$entry.ash") > "$human_stdout" 2> "$human_stderr" || status=$?
    [[ $status -eq 2 && ! -s $human_stdout ]] || ash_doc_fail "expected compiler failure"
    python3 - "$human_stderr" "$repo_root" "$unit_root/checks/$entry.human.txt" <<'CHECK'
from pathlib import Path
import sys
actual = Path(sys.argv[1]).read_text().replace(sys.argv[2] + "/", "/path/to/ash-doc/")
assert actual == Path(sys.argv[3]).read_text(), "human compiler diagnostic changed"
CHECK
done
printf 'Confirmed opaque-newtype import regression and controls.\n'
