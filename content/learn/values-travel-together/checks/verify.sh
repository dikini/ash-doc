#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-pair.ash
    src/02-pair-input.ash
    src/03-local-pattern.ash
    src/04-triple-is-not-a-pair.ash
)

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_run_accepted \
    "$unit_root" src/01-pair.ash '(42, true) : (Int, Bool)'
ash_doc_run_accepted "$unit_root" src/02-pair-input.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/03-local-pattern.ash '42 : Int'
ash_doc_run_rejected "$unit_root" src/04-triple-is-not-a-pair.ash 1
ash_doc_check_human "$unit_root" src/04-triple-is-not-a-pair.ash "$unit_root/.."
ash_doc_finish 4
