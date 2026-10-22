#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-greeting.ash
    src/02-escapes.ash
    src/03-byte-length.ash
    src/04-to-utf8.ash
    src/05-string-equality.ash
)

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_run_accepted "$unit_root" src/01-greeting.ash '"Hello, Ash!" : String'
ash_doc_run_accepted "$unit_root" src/02-escapes.ash '"line one\nline two" : String'
ash_doc_run_accepted "$unit_root" src/03-byte-length.ash '3 : Int'
ash_doc_run_accepted "$unit_root" src/04-to-utf8.ash '[97, 10, 98] : Bytes'
ash_doc_run_rejected "$unit_root" src/05-string-equality.ash 1
ash_doc_check_human "$unit_root" src/05-string-equality.ash "$unit_root/.."
ash_doc_finish 5
