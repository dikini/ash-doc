#!/usr/bin/env bash

set -euo pipefail

readonly modular_pin=dca16039923475c48025c5f17beadeb6bcb6a4bf
readonly lib_pin=d1e323d23390cdad03202ee3df76cd9100556e1d
case_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly case_root

fail() {
    printf 'verify: %s\n' "$1" >&2
    exit 1
}

if [[ $# -ne 2 ]]; then
    fail "usage: checks/verify.sh /path/to/modular-ash /path/to/lib-ash"
fi

readonly modular_dir=$1
readonly lib_dir=$2
verify_dir=$(mktemp -d "${TMPDIR:-/tmp}/ash-doc-lib-migration.XXXXXX")
readonly verify_dir
trap 'rm -rf -- "$verify_dir"' EXIT

check_checkout() {
    local checkout=$1
    local expected=$2
    local actual
    actual=$(git -C "$checkout" rev-parse HEAD 2>/dev/null) ||
        fail "$checkout is not an Ash checkout"
    [[ $actual == "$expected" ]] ||
        fail "$checkout is at $actual, expected $expected"
    [[ -z $(git -C "$checkout" status --short) ]] ||
        fail "$checkout must be clean"
}

check_checkout "$modular_dir" "$modular_pin"
check_checkout "$lib_dir" "$lib_pin"

(
    cd "$modular_dir"
    CARGO_TARGET_DIR="$verify_dir/modular-target" \
        cargo build --quiet --locked
)
(
    cd "$lib_dir"
    CARGO_TARGET_DIR="$verify_dir/lib-target" \
        cargo build --quiet --locked
)

readonly modular_ash="$verify_dir/modular-target/debug/ash"
readonly lib_ash="$verify_dir/lib-target/debug/ash"

assert_hash() {
    local file=$1
    local expected=$2
    local actual
    actual=$(sha256sum "$file" | cut -d' ' -f1)
    [[ $actual == "$expected" ]] ||
        fail "$file has hash $actual, expected $expected"
}

assert_dependency_reaches_entry_contract() {
    local label=$1
    local directory=$2
    local library_file=$3
    local dependency_stdout="$verify_dir/$label.dependency.stdout"
    local dependency_stderr="$verify_dir/$label.dependency.stderr"
    local status

    if "$lib_ash" "$case_root/$directory/$library_file" \
        > "$dependency_stdout" 2> "$dependency_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 1 ]] ||
        fail "$label dependency status is $status, expected 1"
    [[ ! -s $dependency_stdout ]] ||
        fail "$label dependency wrote unexpected standard output"
    [[ $(sed -n '1p' "$dependency_stderr") == entry.missing-main ]] ||
        fail "$label dependency did not reach the entry contract"
}

assert_dependency_runs() {
    local label=$1
    local directory=$2
    local library_file=$3
    local output_hash=$4
    local dependency_stdout="$verify_dir/$label.dependency.stdout"
    local dependency_stderr="$verify_dir/$label.dependency.stderr"
    local status
    local actual_output_hash

    if "$lib_ash" "$case_root/$directory/$library_file" \
        > "$dependency_stdout" 2> "$dependency_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 0 ]] ||
        fail "$label dependency status is $status, expected 0"
    [[ ! -s $dependency_stderr ]] ||
        fail "$label dependency wrote unexpected standard error"
    actual_output_hash=$(sha256sum "$dependency_stdout" | cut -d' ' -f1)
    [[ $actual_output_hash == "$output_hash" ]] ||
        fail "$label dependency output changed"
}

run_case() {
    local label=$1
    local directory=$2
    local library_file=$3
    local library_hash=$4
    local entry_hash=$5
    local output_hash=$6
    local import_line=$7
    local modular_stdout="$verify_dir/$label.modular.stdout"
    local modular_stderr="$verify_dir/$label.modular.stderr"
    local lib_stdout="$verify_dir/$label.lib.stdout"
    local lib_stderr="$verify_dir/$label.lib.stderr"
    local status
    local actual_output_hash
    local import_end=${#import_line}

    assert_hash "$case_root/$directory/$library_file" "$library_hash"
    assert_hash "$case_root/$directory/main.ash" "$entry_hash"
    [[ $(sed -n '1p' "$case_root/$directory/main.ash") == "$import_line" ]] ||
        fail "$label no longer retains its causal import"

    if "$modular_ash" "$case_root/$directory/main.ash" \
        > "$modular_stdout" 2> "$modular_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 0 ]] ||
        fail "$label predecessor status is $status, expected 0"
    [[ ! -s $modular_stderr ]] ||
        fail "$label predecessor wrote standard error"
    actual_output_hash=$(sha256sum "$modular_stdout" | cut -d' ' -f1)
    [[ $actual_output_hash == "$output_hash" ]] ||
        fail "$label predecessor output changed"

    if "$lib_ash" "$case_root/$directory/main.ash" \
        > "$lib_stdout" 2> "$lib_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 2 ]] ||
        fail "$label lib-ash status is $status, expected 2"
    [[ ! -s $lib_stdout ]] ||
        fail "$label lib-ash wrote standard output"
    [[ $(sed -n '1p' "$lib_stderr") == resolve.internal-state ]] ||
        fail "$label lib-ash did not report resolve.internal-state"
    grep -Eq "^primary: source [0-9]+ 0\\.\\.$import_end: a dependency summary failed body-free authentication$" \
        "$lib_stderr" ||
        fail "$label lib-ash did not retain its causal import label"
}

assert_dependency_reaches_entry_contract \
    search-frontier \
    search-frontier \
    searches.ash
assert_dependency_runs \
    red-black-dictionary \
    red-black-dictionary \
    dictionaries.ash \
    6c159135693e2dff8d81dc97fb60fafcebfeb9b0c09cb4deebec4757e4a716fc
assert_dependency_reaches_entry_contract \
    tree-iterator \
    tree-iterator \
    dictionaries.ash

run_case \
    search-frontier \
    search-frontier \
    searches.ash \
    d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b \
    98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692 \
    254dc0d711ed8246b920f1be8b642af6d57a0aaa312a2d944de06fb570aea329 \
    'import searches as Searches'
run_case \
    red-black-dictionary \
    red-black-dictionary \
    dictionaries.ash \
    9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d \
    eb56359bf329db9cf8e0c35ecad85efd9c39129b1da59f8024d577703d45282e \
    fbcad839ed0fcb98b146df63d4f478e191c38fe91083fb4b6c2e699b0777c2e1 \
    'import dictionaries as Dictionaries'
run_case \
    tree-iterator \
    tree-iterator \
    dictionaries.ash \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0 \
    190662c1447e5c5d9d5ae34d0e9dc95d0a157c6dfbf628656baa648a02166c45 \
    'import dictionaries as Dictionaries'

printf 'Verified 3 imported-summary failures (%s) from %s to %s.\n' \
    'search-frontier, red-black-dictionary, tree-iterator' \
    "$modular_pin" \
    "$lib_pin"
