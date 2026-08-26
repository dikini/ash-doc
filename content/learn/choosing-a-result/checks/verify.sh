#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
learn_root=$(cd "$unit_root/.." && pwd)
readonly learn_root
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-equality.ash
    src/02-choose.ash
    src/03-calculated-choice.ash
    src/04-missing-choice.ash
)

# shellcheck source=../../checks/lib.sh
source "$learn_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-equality.ash 'true : Bool'
ash_doc_run_accepted "$unit_root" src/02-choose.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/03-calculated-choice.ash '42 : Int'
ash_doc_run_rejected \
    "$unit_root" \
    src/04-missing-choice.ash \
    coverage.non-exhaustive \
    'this match does not cover every value' \
    1
ash_doc_finish 4
