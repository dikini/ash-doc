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
    src/01-permitted.ash
    src/02-rejected.ash
    src/03-without-enrichment.ash
    src/pipeline.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-permitted.ash '(Delivered(Request(1, true)), Step(1, Step(2, Step(3, Step(4, End))))) : (Result, Steps)'
ash_doc_run_accepted "$unit_root" src/02-rejected.ash '(Rejected, Step(1, Step(2, End))) : (Result, Steps)'
ash_doc_run_accepted "$unit_root" src/03-without-enrichment.ash '(Delivered(Request(1, false)), Step(1, Step(2, Step(4, End)))) : (Result, Steps)'
ash_doc_finish 4
