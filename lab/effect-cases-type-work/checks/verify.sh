#!/usr/bin/env bash

set -euo pipefail
case_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly case_root
# shellcheck source=../../../content/checks/lib.sh
source "$case_root/../../content/checks/lib.sh"
[[ $# -eq 1 ]] || ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"

ash_doc_check_sources "$case_root" "$case_root/README.md" src/minimal.ash
ash_doc_run_accepted "$case_root" src/without-resource.ash '0 : Int'
ash_doc_run_accepted "$case_root" src/one-recursive-call.ash '0 : Int'

check_exhaustion() {
    local entry=$1
    local actual_out actual_err status
    actual_out=$(mktemp "$ASH_DOC_VERIFY_DIR/lab-out.XXXXXX")
    actual_err=$(mktemp "$ASH_DOC_VERIFY_DIR/lab-err.XXXXXX")
    if "$ASH_DOC_ASH_BIN" --message-format human --locale en "$entry" \
        > "$actual_out" 2> "$actual_err"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 2 && ! -s $actual_out ]] ||
        ash_doc_fail "$entry no longer shows the recorded exhaustion; inspect it"
    cmp "$case_root/checks/type-work.stderr" "$actual_err" ||
        ash_doc_fail "$entry has a different internal diagnostic; inspect it"
}

check_exhaustion "$case_root/src/minimal.ash"
readonly drafts=(
    numbering-tree-leaves
    measuring-tree-search
    bounding-search-work
    compressing-parent-paths
)
for draft in "${drafts[@]}"; do
    draft_root="$case_root/drafts/$draft"
    ash_doc_check_sources "$draft_root" "$draft_root/README.md" src/main.ash
    check_exhaustion "$draft_root/src/main.ash"
done
python3 - "$case_root" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
readme = (root / 'README.md').read_text()
message = (root / 'checks/type-work.stderr').read_text()
assert '```text\n' + message + '```' in readme
for expected in (root / 'checks').glob('*.expected.txt'):
    page = root / 'drafts' / expected.name.removesuffix('.expected.txt') / 'README.md'
    assert '```text\n' + expected.read_text() + '```' in page.read_text()
assert len(list(root.rglob('*.ash'))) == 7
PY
printf 'Verified five current type-work failures and two passing controls.\n'
