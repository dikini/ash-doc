#!/usr/bin/env bash

readonly ash_doc_expected_pin=40c964c69c007ba81ec6bdbac34e31ad24fec9c7

ash_doc_fail() {
    printf 'verify: %s\n' "$1" >&2
    exit 1
}

ash_doc_prepare() {
    if [[ $# -ne 1 ]]; then
        ash_doc_fail "ash_doc_prepare requires one ash-lang checkout"
    fi

    local ash_lang_dir=$1
    local actual_pin
    actual_pin=$(git -C "$ash_lang_dir" rev-parse HEAD 2>/dev/null) ||
        ash_doc_fail "the argument is not an ash-lang checkout"

    [[ $actual_pin == "$ash_doc_expected_pin" ]] ||
        ash_doc_fail \
            "ash-lang HEAD is $actual_pin, expected $ash_doc_expected_pin"
    [[ -z $(git -C "$ash_lang_dir" status --short) ]] ||
        ash_doc_fail "the ash-lang checkout must be clean"

    if [[ -n ${ASH_DOC_PREPARED_PIN:-} ]]; then
        [[ $ASH_DOC_PREPARED_PIN == "$ash_doc_expected_pin" ]] ||
            ash_doc_fail "the prepared Ash binary has the wrong pin"
        [[ -x ${ASH_DOC_ASH_BIN:-} ]] ||
            ash_doc_fail "the prepared Ash binary is unavailable"
        [[ -d ${ASH_DOC_VERIFY_DIR:-} ]] ||
            ash_doc_fail "the prepared verification directory is unavailable"
        return
    fi

    ASH_DOC_VERIFY_DIR=$(mktemp -d \
        "${TMPDIR:-/tmp}/ash-doc-content.XXXXXX")
    readonly ASH_DOC_VERIFY_DIR
    export ASH_DOC_VERIFY_DIR
    trap 'rm -rf "$ASH_DOC_VERIFY_DIR"' EXIT

    (
        cd "$ash_lang_dir" || exit 1
        CARGO_TARGET_DIR="$ASH_DOC_VERIFY_DIR/target" \
            cargo build --quiet --locked
    )

    ASH_DOC_ASH_BIN="$ASH_DOC_VERIFY_DIR/target/debug/ash"
    ASH_DOC_PREPARED_PIN=$actual_pin
    readonly ASH_DOC_ASH_BIN ASH_DOC_PREPARED_PIN
    export ASH_DOC_ASH_BIN ASH_DOC_PREPARED_PIN
}

ash_doc_check_sources() {
    if [[ $# -lt 3 ]]; then
        ash_doc_fail \
            "ash_doc_check_sources requires a unit, README, and source"
    fi

    local check_unit_root=$1
    local check_readme=$2
    shift 2

    [[ -f $check_readme ]] || ash_doc_fail "missing unit README.md"

    local check_expected_blocks=$#
    local check_actual_blocks
    check_actual_blocks=$(grep -cx '```ash' "$check_readme" || true)
    [[ $check_actual_blocks -eq $check_expected_blocks ]] ||
        ash_doc_fail \
            "README.md has an unmarked or missing executable Ash block"

    local check_source
    for check_source in "$@"; do
        [[ -f "$check_unit_root/$check_source" ]] ||
            ash_doc_fail "missing canonical source: $check_source"

        local check_extracted
        check_extracted=$(mktemp "$ASH_DOC_VERIFY_DIR/extracted.XXXXXX")
        local check_marker="<!-- source: $check_source -->"

        awk -v marker="$check_marker" '
            $0 == marker {
                seen += 1
                next
            }
            seen == 1 && $0 == "```ash" {
                inside = 1
                next
            }
            inside && $0 == "```" {
                closed = 1
                exit
            }
            inside {
                print
            }
            END {
                if (seen != 1 || !inside || !closed) {
                    exit 2
                }
            }
        ' "$check_readme" > "$check_extracted" ||
            ash_doc_fail \
                "missing unique marked Ash block for $check_source"

        if ! cmp -s \
            "$check_unit_root/$check_source" "$check_extracted"; then
            diff -u \
                "$check_unit_root/$check_source" \
                "$check_extracted" >&2 || true
            ash_doc_fail "displayed Ash differs from $check_source"
        fi
    done
}

ash_doc_run_accepted() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail \
            "ash_doc_run_accepted requires a unit, entry, and output"
    fi

    local accepted_unit_root=$1
    local accepted_entry=$2
    local accepted_expected=$3
    local accepted_stdout
    local accepted_stderr
    local accepted_expected_file
    local accepted_status
    accepted_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    accepted_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")
    accepted_expected_file=$(mktemp "$ASH_DOC_VERIFY_DIR/expected.XXXXXX")

    if "$ASH_DOC_ASH_BIN" "$accepted_unit_root/$accepted_entry" \
        > "$accepted_stdout" 2> "$accepted_stderr"; then
        accepted_status=0
    else
        accepted_status=$?
    fi

    [[ $accepted_status -eq 0 ]] ||
        ash_doc_fail \
            "$accepted_entry exited with status $accepted_status, expected 0"
    [[ ! -s $accepted_stderr ]] ||
        ash_doc_fail "$accepted_entry wrote unexpected standard error"

    printf '%s\n' "$accepted_expected" > "$accepted_expected_file"
    if ! cmp -s "$accepted_expected_file" "$accepted_stdout"; then
        diff -u "$accepted_expected_file" "$accepted_stdout" >&2 || true
        ash_doc_fail "$accepted_entry produced unexpected standard output"
    fi
}

ash_doc_run_rejected() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_run_rejected requires a unit, entry, and status"
    fi

    local rejected_unit_root=$1
    local rejected_entry=$2
    local rejected_expected_status=$3
    local rejected_stdout rejected_stderr rejected_status
    local rejected_stem=${rejected_entry##*/}
    rejected_stem=${rejected_stem%.ash}
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
    python3 "$(dirname "${BASH_SOURCE[0]}")/diagnostic.py" \
        "$rejected_stderr" \
        "$rejected_unit_root/checks/$rejected_stem.diagnostic.json" \
        "$rejected_unit_root" ||
        ash_doc_fail "$rejected_entry did not retain its expected diagnostic"
}

ash_doc_check_human() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_check_human requires a unit, entry, and working directory"
    fi

    local human_unit_root=$1 human_entry=$2 human_cwd=$3
    local human_argument human_stdout human_stderr human_status
    human_argument=$(python3 -c \
        'import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
        "$human_unit_root/$human_entry" "$human_cwd")
    human_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/human-stdout.XXXXXX")
    human_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/human-stderr.XXXXXX")

    if (
        cd "$human_cwd" || exit 1
        "$ASH_DOC_ASH_BIN" --message-format human --locale en "$human_argument"
    ) > "$human_stdout" 2> "$human_stderr"; then
        human_status=0
    else
        human_status=$?
    fi
    [[ $human_status -eq 1 ]] ||
        ash_doc_fail "$human_entry human capture exited $human_status, expected 1"
    [[ ! -s $human_stdout ]] ||
        ash_doc_fail "$human_entry human capture wrote unexpected standard output"
    python3 "$(dirname "${BASH_SOURCE[0]}")/human.py" \
        "$human_stderr" "$human_unit_root" "$human_entry" "$human_argument" ||
        ash_doc_fail "$human_entry displayed human transcript differs"
}

ash_doc_finish() {
    if [[ $# -ne 1 ]]; then
        ash_doc_fail "ash_doc_finish requires a source count"
    fi

    printf 'Verified %s canonical sources and displayed blocks at %s.\n' \
        "$1" "$ash_doc_expected_pin"
}
