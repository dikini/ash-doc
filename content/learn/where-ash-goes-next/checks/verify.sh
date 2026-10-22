#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-twice.ash
    src/02-scale-price.ash
    src/03-cell-tally.ash
)

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_run_accepted \
    "$unit_root" \
    src/01-twice.ash \
    '(21, 21) : (Int, Int)'
ash_doc_run_accepted "$unit_root" src/02-scale-price.ash '60 : Int'
ash_doc_run_accepted "$unit_root" src/03-cell-tally.ash '7 : Int'
ash_doc_finish 3
