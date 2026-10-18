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
    src/01-zeroed-bytes.ash
    src/02-write-and-read.ash
    src/03-acquisition-failure.ash
    src/04-invalid-index.ash
    src/05-invalid-byte.ash
    src/06-nested-acquisition.ash
    src/07-handle-escape.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_run_native_accepted "$unit_root" src/01-zeroed-bytes.ash 'Success(Success(0))' 'Outcome<Outcome<Int>>'
ash_doc_run_native_accepted "$unit_root" src/02-write-and-read.ash 'Success(Success(42))' 'Outcome<Outcome<Int>>'
ash_doc_run_native_accepted "$unit_root" src/03-acquisition-failure.ash '(Failure(InvalidLength), 0)' '(Outcome<Int>, Int)'
ash_doc_run_native_accepted "$unit_root" src/04-invalid-index.ash 'Success(Failure(InvalidIndex))' 'Outcome<Outcome<Int>>'
ash_doc_run_native_accepted "$unit_root" src/05-invalid-byte.ash 'Success(Checked(Failure(InvalidByte), Success(0)))' 'Outcome<Checked>'
ash_doc_run_native_accepted "$unit_root" src/06-nested-acquisition.ash 'Success(Failure(InvalidLength))' 'Outcome<Outcome<Int>>'
ash_doc_run_rejected "$unit_root" src/07-handle-escape.ash 1 native
ash_doc_check_human "$unit_root" src/07-handle-escape.ash "$unit_root/src" native
ash_doc_finish 7
