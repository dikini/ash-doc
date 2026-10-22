#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-comment.ash
    src/02-negative-one.ash
    src/03-subtract.ash
    src/04-less-than.ash
    src/05-boolean-and.ash
    src/06-both.ash
    src/07-bool-plus-int.ash
)

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

# src/05-boolean-and.ash declines with two diagnostics, one per unknown
# character; the shared ash_doc_run_rejected retains single-record
# rejections, so this lesson keeps that one capture lesson-local.
ash_doc_run_rejected_multi() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail \
            "ash_doc_run_rejected_multi requires a unit, entry, and status"
    fi

    local rejected_unit_root=$1 rejected_entry=$2 rejected_expected_status=$3
    local rejected_stdout rejected_stderr rejected_status
    rejected_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    rejected_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")

    if "$ASH_DOC_ASH_BIN" --message-format json \
        "$rejected_unit_root/$rejected_entry" \
        > "$rejected_stdout" 2> "$rejected_stderr"; then
        rejected_status=0
    else
        rejected_status=$?
    fi
    [[ $rejected_status -eq $rejected_expected_status ]] ||
        ash_doc_fail "$rejected_entry exited with status $rejected_status, expected $rejected_expected_status"
    [[ ! -s $rejected_stdout ]] ||
        ash_doc_fail "$rejected_entry wrote unexpected standard output"
    python3 "$unit_root/checks/multi_diagnostic.py" \
        "$rejected_stderr" \
        "$rejected_unit_root/checks/05-boolean-and.diagnostic.json" \
        "$rejected_unit_root" ||
        ash_doc_fail "$rejected_entry did not retain its expected diagnostics"
}

ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_run_rejected "$unit_root" src/01-comment.ash 1
ash_doc_check_human "$unit_root" src/01-comment.ash "$unit_root/.."
ash_doc_run_rejected "$unit_root" src/02-negative-one.ash 1
ash_doc_check_human "$unit_root" src/02-negative-one.ash "$unit_root/.."
ash_doc_run_rejected "$unit_root" src/03-subtract.ash 1
ash_doc_check_human "$unit_root" src/03-subtract.ash "$unit_root/.."
ash_doc_run_rejected "$unit_root" src/04-less-than.ash 1
ash_doc_check_human "$unit_root" src/04-less-than.ash "$unit_root/.."
ash_doc_run_rejected_multi "$unit_root" src/05-boolean-and.ash 1
ash_doc_check_human "$unit_root" src/05-boolean-and.ash "$unit_root/.."
ash_doc_run_accepted "$unit_root" src/06-both.ash 'true : Bool'
ash_doc_run_rejected "$unit_root" src/07-bool-plus-int.ash 1
ash_doc_check_human "$unit_root" src/07-bool-plus-int.ash "$unit_root/.."
ash_doc_finish 7
