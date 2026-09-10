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

readonly sources=(
    src/01-explicit.ash
    src/02-handled.ash
    src/03-different-bonus.ash
    src/04-unhandled.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-explicit.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/02-handled.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/03-different-bonus.ash '45 : Int'
ash_doc_run_rejected "$unit_root" src/04-unhandled.ash 1
ash_doc_check_human "$unit_root" src/04-unhandled.ash "$unit_root/src"

# The comparison in the chapter depends on changing only the handler answer.
normalized=$(mktemp "$ASH_DOC_VERIFY_DIR/bonus.XXXXXX")
sed 's/resume 5/resume 2/' "$unit_root/src/03-different-bonus.ash" > "$normalized"
cmp -s "$normalized" "$unit_root/src/02-handled.ash" ||
    ash_doc_fail "the handled examples must differ only in the supplied bonus"

ash_doc_finish 4
