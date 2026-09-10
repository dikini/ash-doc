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
    src/01-pure-callback.ash
    src/02-pure-contract.ash
    src/03-open-row.ash
    src/04-known-effect.ash
    src/05-unknown-union.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-pure-callback.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/03-open-row.ash '(42, 44) : (Int, Int)'
ash_doc_run_accepted "$unit_root" src/04-known-effect.ash '43 : Int'
ash_doc_run_rejected "$unit_root" src/02-pure-contract.ash 1
ash_doc_check_human "$unit_root" src/02-pure-contract.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/05-unknown-union.ash 1
ash_doc_check_human "$unit_root" src/05-unknown-union.ash "$unit_root/src"

ash_doc_finish 5
