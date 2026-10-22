#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-natural.ash
    src/02-compare.ash
    src/03-to-int.ash
    src/04-to-int-down.ash
    src/05-missing-equal.ash
)

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_run_accepted \
    "$unit_root" \
    src/01-natural.ash \
    'Next(Next(Zero)) : Natural'
ash_doc_run_accepted "$unit_root" src/02-compare.ash 'Less : Ordering'
ash_doc_run_accepted "$unit_root" src/03-to-int.ash '3 : Int'
ash_doc_run_accepted "$unit_root" src/04-to-int-down.ash '(3, 3) : (Int, Int)'
ash_doc_run_rejected "$unit_root" src/05-missing-equal.ash 1
ash_doc_check_human "$unit_root" src/05-missing-equal.ash "$unit_root/.."
ash_doc_finish 5
