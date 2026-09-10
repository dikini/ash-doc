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
    src/01-copied-result.ash
    src/02-live-access.ash
    src/03-handle-escape.ash
    src/04-closure-escape.ash
    src/05-two-acquisitions.ash
    src/06-payload-escape.ash
    src/07-aggregate-escape.ash
    src/08-copied-payload.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-copied-result.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/02-live-access.ash '2 : Int'
ash_doc_run_accepted "$unit_root" src/05-two-acquisitions.ash '(10, 2) : (Int, Int)'
ash_doc_run_accepted "$unit_root" src/08-copied-payload.ash '42 : Int'
ash_doc_run_rejected "$unit_root" src/03-handle-escape.ash 1
ash_doc_check_human "$unit_root" src/03-handle-escape.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/04-closure-escape.ash 1
ash_doc_check_human "$unit_root" src/04-closure-escape.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/06-payload-escape.ash 1
ash_doc_check_human "$unit_root" src/06-payload-escape.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/07-aggregate-escape.ash 1
ash_doc_check_human "$unit_root" src/07-aggregate-escape.ash "$unit_root/src"
ash_doc_finish 8
