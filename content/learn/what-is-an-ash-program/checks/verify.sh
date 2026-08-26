#!/usr/bin/env bash

set -euo pipefail

readonly expected_pin=dca16039923475c48025c5f17beadeb6bcb6a4bf
readonly unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly readme="$unit_root/README.md"
readonly sources=(
    src/01-literal.ash
    src/02-addition.ash
    src/03-precedence.ash
    src/04-grouping.ash
    src/05-function-call.ash
    src/06-composition.ash
    src/07-missing-main.ash
)

fail() {
    printf 'verify: %s\n' "$1" >&2
    exit 1
}

if [[ $# -ne 1 ]]; then
    fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

readonly ash_lang_dir=$1
actual_pin=$(git -C "$ash_lang_dir" rev-parse HEAD 2>/dev/null) ||
    fail "the argument is not an ash-lang checkout"
readonly actual_pin

[[ $actual_pin == "$expected_pin" ]] ||
    fail "ash-lang HEAD is $actual_pin, expected $expected_pin"

[[ -z $(git -C "$ash_lang_dir" status --short) ]] ||
    fail "the ash-lang checkout must be clean"

for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] ||
        fail "missing canonical source: $source"
done

[[ -f $readme ]] || fail "missing unit README.md"

verification_dir=$(mktemp -d "${TMPDIR:-/tmp}/ash-doc-first-unit.XXXXXX")
readonly verification_dir
trap 'rm -rf "$verification_dir"' EXIT

check_displayed_source() {
    local source=$1
    local extracted="$verification_dir/extracted.ash"
    local marker="<!-- source: $source -->"

    awk -v marker="$marker" '
        $0 == marker {
            seen = 1
            next
        }
        seen && $0 == "```ash" {
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
            if (!seen || !inside || !closed) {
                exit 2
            }
        }
    ' "$readme" > "$extracted" ||
        fail "missing marked Ash block for $source"

    if ! cmp -s "$unit_root/$source" "$extracted"; then
        diff -u "$unit_root/$source" "$extracted" >&2 || true
        fail "displayed Ash differs from $source"
    fi
}

for source in "${sources[@]}"; do
    check_displayed_source "$source"
done

CARGO_TARGET_DIR="$verification_dir/target" \
    cargo build \
        --quiet \
        --locked \
        --manifest-path "$ash_lang_dir/Cargo.toml"
readonly ash_bin="$verification_dir/target/debug/ash"

run_accepted() {
    local source=$1
    local expected=$2
    local stdout_file="$verification_dir/stdout"
    local stderr_file="$verification_dir/stderr"
    local expected_file="$verification_dir/expected"
    local status

    if "$ash_bin" "$unit_root/$source" \
        > "$stdout_file" 2> "$stderr_file"; then
        status=0
    else
        status=$?
    fi

    [[ $status -eq 0 ]] ||
        fail "$source exited with status $status, expected 0"
    [[ ! -s $stderr_file ]] ||
        fail "$source wrote unexpected standard error"

    printf '%s\n' "$expected" > "$expected_file"
    if ! cmp -s "$expected_file" "$stdout_file"; then
        diff -u "$expected_file" "$stdout_file" >&2 || true
        fail "$source produced unexpected standard output"
    fi
}

run_rejected() {
    local source=src/07-missing-main.ash
    local stdout_file="$verification_dir/stdout"
    local stderr_file="$verification_dir/stderr"
    local status

    if "$ash_bin" "$unit_root/$source" \
        > "$stdout_file" 2> "$stderr_file"; then
        status=0
    else
        status=$?
    fi

    [[ $status -eq 1 ]] ||
        fail "$source exited with status $status, expected 1"
    [[ ! -s $stdout_file ]] ||
        fail "$source wrote unexpected standard output"
    [[ $(sed -n '1p' "$stderr_file") == entry.missing-main ]] ||
        fail "$source did not report entry.missing-main"
    grep -Fq ': this entry module declares no local main' "$stderr_file" ||
        fail "$source did not retain the causal entry label"
}

run_accepted src/01-literal.ash '42 : Int'
run_accepted src/02-addition.ash '42 : Int'
run_accepted src/03-precedence.ash '7 : Int'
run_accepted src/04-grouping.ash '9 : Int'
run_accepted src/05-function-call.ash '42 : Int'
run_accepted src/06-composition.ash '42 : Int'
run_rejected

printf 'Verified 7 canonical sources and displayed blocks at %s.\n' \
    "$expected_pin"
