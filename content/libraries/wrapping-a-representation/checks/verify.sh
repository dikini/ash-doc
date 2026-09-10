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
    src/01-data-and-newtype.ash
    src/02-no-coercion.ash
    src/03-explicit-conversion.ash
    src/04-distinct-behavior.ash
    src/05-no-inherited-evidence.ash
    src/06-opaque-client.ash
    src/07-hidden-constructor.ash
    src/08-parameterized-wrapper.ash
    src/tickets.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-data-and-newtype.ash '(Tagged(42), 42) : (Tagged, Points)'
ash_doc_run_accepted "$unit_root" src/03-explicit-conversion.ash '42 : Points'
ash_doc_run_accepted "$unit_root" src/04-distinct-behavior.ash '(4, 40) : (Int, Int)'
ash_doc_run_accepted "$unit_root" src/06-opaque-client.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/08-parameterized-wrapper.ash '(42, true) : (Int, Bool)'
ash_doc_run_rejected "$unit_root" src/02-no-coercion.ash 1
ash_doc_check_human "$unit_root" src/02-no-coercion.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/05-no-inherited-evidence.ash 1
ash_doc_check_human "$unit_root" src/05-no-inherited-evidence.ash "$unit_root/src"
ash_doc_fail "L2 is incomplete: opaque-constructor capture awaits the fixed baseline"
