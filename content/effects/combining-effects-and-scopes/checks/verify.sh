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
    src/00-pure-calculation.ash
    src/01-finished.ash
    src/02-stopped.ash
    src/03-different-policy.ash
    src/04-unhandled-policy.ash
    src/05-empty-input.ash
    src/scoring.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/00-pure-calculation.ash 'Finished(46) : Outcome'
ash_doc_run_accepted "$unit_root" src/01-finished.ash '(Finished(46), 2, 1) : (Outcome, Int, Int)'
ash_doc_run_accepted "$unit_root" src/02-stopped.ash '(Stopped(22), 2, 1) : (Outcome, Int, Int)'
ash_doc_run_accepted "$unit_root" src/03-different-policy.ash '(Finished(52), 2, 1) : (Outcome, Int, Int)'
ash_doc_run_accepted "$unit_root" src/05-empty-input.ash '(Finished(0), 0, 1) : (Outcome, Int, Int)'
ash_doc_run_rejected "$unit_root" src/04-unhandled-policy.ash 1
ash_doc_check_human "$unit_root" src/04-unhandled-policy.ash "$unit_root/src"
ash_doc_finish 7
