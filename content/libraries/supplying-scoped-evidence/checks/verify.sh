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
    src/01-local-value.ash
    src/02-returned-closure.ash
    src/03-exact-method.ash
    src/04-identity-escape.ash
    src/05-no-local-key.ash
    src/06-before-evidence.ash
    src/07-duplicate-evidence.ash
    src/08-disjoint-scopes.ash
    src/09-retained-method.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-local-value.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/02-returned-closure.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/03-exact-method.ash '42 : Int'
ash_doc_run_accepted "$unit_root" src/08-disjoint-scopes.ash '(41, 42) : (Int, Int)'
ash_doc_run_accepted "$unit_root" src/09-retained-method.ash '42 : Int'
ash_doc_run_rejected "$unit_root" src/04-identity-escape.ash 1
ash_doc_check_human "$unit_root" src/04-identity-escape.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/05-no-local-key.ash 1
ash_doc_check_human "$unit_root" src/05-no-local-key.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/06-before-evidence.ash 1
ash_doc_check_human "$unit_root" src/06-before-evidence.ash "$unit_root/src"
ash_doc_run_rejected "$unit_root" src/07-duplicate-evidence.ash 1
ash_doc_check_human "$unit_root" src/07-duplicate-evidence.ash "$unit_root/src"
ash_doc_finish 9
