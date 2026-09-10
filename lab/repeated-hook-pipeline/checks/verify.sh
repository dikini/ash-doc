#!/usr/bin/env bash
set -euo pipefail
case_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly case_root
repo_root=$(cd "$case_root/../.." && pwd)
readonly repo_root
# shellcheck source=../../../content/checks/lib.sh
source "$repo_root/content/checks/lib.sh"
[[ $# -eq 1 ]] || ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"
lesson_root="$repo_root/content/cases/controlling-a-hook-pipeline"
readonly lesson_root
bash "$lesson_root/checks/verify.sh" "$1"
ash_doc_check_sources "$case_root" "$case_root/README.md" src/three-runs.ash
actual_out=$(mktemp "$ASH_DOC_VERIFY_DIR/hook-out.XXXXXX")
actual_err=$(mktemp "$ASH_DOC_VERIFY_DIR/hook-err.XXXXXX")
if "$ASH_DOC_ASH_BIN" --message-format human --locale en \
    --root "demo=$lesson_root/src" "$case_root/src/three-runs.ash" \
    > "$actual_out" 2> "$actual_err"; then
    status=0
else
    status=$?
fi
[[ $status -eq 2 && ! -s $actual_out ]] ||
    ash_doc_fail "combined entry no longer has the recorded failure; inspect it"
cmp "$case_root/checks/type-work.stderr" "$actual_err" ||
    ash_doc_fail "combined entry has a different diagnostic; inspect it"
python3 - "$case_root" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
message = (root / 'checks/type-work.stderr').read_text()
assert '```text\n' + message + '```' in (root / 'README.md').read_text()
PY
printf 'Verified the combined-entry failure and three passing pipeline controls.\n'
