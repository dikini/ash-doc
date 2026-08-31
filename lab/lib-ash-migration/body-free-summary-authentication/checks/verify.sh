#!/usr/bin/env bash

set -euo pipefail

readonly modular_pin=dca16039923475c48025c5f17beadeb6bcb6a4bf
readonly lib_pin=d1e323d23390cdad03202ee3df76cd9100556e1d
case_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly case_root
readonly retained_entries=(
    red-black-dictionary/main.ash
    red-black-dictionary/02-build-and-persistence.ash
    tree-iterator/main.ash
    tree-iterator/02-retained-state.ash
    tree-iterator/03-opaque-pattern.ash
    tree-iterator/04-opaque-construction.ash
    search-frontier/main.ash
    search-frontier/02-unreachable-cycle.ash
)

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

for retained_entry in "${retained_entries[@]}"; do
    [[ -f "$case_root/$retained_entry" ]] ||
        fail "missing retained entry: $retained_entry"
done

declared_entries_file="$verify_dir/declared-entries"
actual_entries_file="$verify_dir/actual-entries"
readonly declared_entries_file actual_entries_file
printf '%s\n' "${retained_entries[@]}" | LC_ALL=C sort > "$declared_entries_file"
find "$case_root" -mindepth 2 -maxdepth 2 -type f \
    \( -name 'main.ash' -o -name '[0-9][0-9]-*.ash' \) \
    -printf '%P\n' | LC_ALL=C sort > "$actual_entries_file"
if ! cmp -s "$declared_entries_file" "$actual_entries_file"; then
    diff -u "$declared_entries_file" "$actual_entries_file" >&2 || true
    fail "retained entry set must contain exactly the eight declared paths"
fi

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

assert_lib_failure() {
    local label=$1
    local directory=$2
    local entry_file=$3
    local import_line=$4
    local lib_stdout="$verify_dir/$label.lib.stdout"
    local lib_stderr="$verify_dir/$label.lib.stderr"
    local status
    local import_end=${#import_line}

    [[ $(sed -n '1p' "$case_root/$directory/$entry_file") == "$import_line" ]] ||
        fail "$label no longer retains its causal import"

    if "$lib_ash" "$case_root/$directory/$entry_file" \
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
    grep -Fxq \
        "primary: source 0 0..$import_end: a dependency summary failed body-free authentication" \
        "$lib_stderr" ||
        fail "$label lib-ash did not retain its causal import label"
}

run_accepted_case() {
    local label=$1
    local directory=$2
    local library_file=$3
    local library_hash=$4
    local entry_file=$5
    local entry_hash=$6
    local output_hash=$7
    local import_line=$8
    local modular_stdout="$verify_dir/$label.modular.stdout"
    local modular_stderr="$verify_dir/$label.modular.stderr"
    local status
    local actual_output_hash

    assert_hash "$case_root/$directory/$library_file" "$library_hash"
    assert_hash "$case_root/$directory/$entry_file" "$entry_hash"

    if "$modular_ash" "$case_root/$directory/$entry_file" \
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

    assert_lib_failure "$label" "$directory" "$entry_file" "$import_line"
}

assert_exact_occurrence_range() {
    local file=$1
    local spelling=$2
    local expected_start=$3
    local expected_end=$4
    local claim=$5
    local matches=()
    local actual_start actual_end

    mapfile -t matches < <(LC_ALL=C grep -aboF "$spelling" "$file" || true)
    [[ ${#matches[@]} -eq 1 ]] || fail "$claim"
    actual_start=${matches[0]%%:*}
    actual_end=$((actual_start + ${#spelling}))
    [[ $actual_start -eq $expected_start && $actual_end -eq $expected_end ]] ||
        fail "$claim"
}

run_opaque_case() {
    local label=$1
    local directory=$2
    local library_file=$3
    local library_hash=$4
    local entry_file=$5
    local entry_hash=$6
    local import_line=$7
    local member_start=$8
    local member_end=$9
    local declaration_start=${10}
    local declaration_end=${11}
    local modular_stdout="$verify_dir/$label.modular.stdout"
    local modular_stderr="$verify_dir/$label.modular.stderr"
    local status

    assert_hash "$case_root/$directory/$library_file" "$library_hash"
    assert_hash "$case_root/$directory/$entry_file" "$entry_hash"
    assert_exact_occurrence_range \
        "$case_root/$directory/$entry_file" Iterator \
        "$member_start" "$member_end" \
        "$label must retain the exact opaque constructor occurrence"
    assert_exact_occurrence_range \
        "$case_root/$directory/$library_file" 'Iterator(FrameStack<K, V>)' \
        "$declaration_start" "$declaration_end" \
        "$label must retain the causal opaque constructor declaration"

    if "$modular_ash" "$case_root/$directory/$entry_file" \
        > "$modular_stdout" 2> "$modular_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 1 ]] ||
        fail "$label predecessor status is $status, expected 1"
    [[ ! -s $modular_stdout ]] ||
        fail "$label predecessor wrote standard output"
    [[ $(sed -n '1p' "$modular_stderr") == resolve.opaque-constructor ]] ||
        fail "$label predecessor did not report resolve.opaque-constructor"
    grep -Eq "^primary: source 0 $member_start\\.\\.$member_end:" \
        "$modular_stderr" ||
        fail "$label predecessor primary label changed"
    grep -Eq "^related: source 1 $declaration_start\\.\\.$declaration_end:" \
        "$modular_stderr" ||
        fail "$label predecessor causal declaration label changed"
    grep -Fxq 'found Iterator' "$modular_stderr" ||
        fail "$label predecessor constructor spelling changed"

    assert_lib_failure "$label" "$directory" "$entry_file" "$import_line"
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

run_accepted_case \
    red-black-prefix-matrix \
    red-black-dictionary \
    dictionaries.ash \
    9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d \
    main.ash \
    eb56359bf329db9cf8e0c35ecad85efd9c39129b1da59f8024d577703d45282e \
    fbcad839ed0fcb98b146df63d4f478e191c38fe91083fb4b6c2e699b0777c2e1 \
    'import dictionaries as Dictionaries'
run_accepted_case \
    red-black-build-and-persistence \
    red-black-dictionary \
    dictionaries.ash \
    9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d \
    02-build-and-persistence.ash \
    71303da79f31bf9d0071c3c8ffe698d76318a29b9e76865fb862ab67af3edeab \
    5167ead84003a8a4124c8ced8b198b50e3d261e91f5cc6966c2538c492ce4974 \
    'import dictionaries as Dictionaries'
run_accepted_case \
    tree-iterator-sequence \
    tree-iterator \
    dictionaries.ash \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    main.ash \
    fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0 \
    190662c1447e5c5d9d5ae34d0e9dc95d0a157c6dfbf628656baa648a02166c45 \
    'import dictionaries as Dictionaries'
run_accepted_case \
    tree-iterator-retained-state \
    tree-iterator \
    dictionaries.ash \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    02-retained-state.ash \
    5e6be6afdd2de8f12df1b48556a197b71e364a968c113146f5362b20c7d4f3b2 \
    d724b406730669aee7aaaae1413d119b8783190d0b9e8ce95455fbd500d9fe0c \
    'import dictionaries as Dictionaries'
run_opaque_case \
    tree-iterator-opaque-pattern \
    tree-iterator \
    dictionaries.ash \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    03-opaque-pattern.ash \
    334318b3480aaf6550e41dc8bd90ad26cec736cd2cd277e656d8a1af63e86ba8 \
    'import dictionaries as Dictionaries' \
    230 238 523 549
run_opaque_case \
    tree-iterator-opaque-construction \
    tree-iterator \
    dictionaries.ash \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    04-opaque-construction.ash \
    8c656fc6eb7591c46cf162f77b4fa838257bd441dbb80abcd98705e9b9057cea \
    'import dictionaries as Dictionaries' \
    103 111 523 549
run_accepted_case \
    search-frontier-found-paths \
    search-frontier \
    searches.ash \
    d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b \
    main.ash \
    98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692 \
    254dc0d711ed8246b920f1be8b642af6d57a0aaa312a2d944de06fb570aea329 \
    'import searches as Searches'
run_accepted_case \
    search-frontier-unreachable-cycle \
    search-frontier \
    searches.ash \
    d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b \
    02-unreachable-cycle.ash \
    f1ff38eeceed2e155d6edfad4859af2851ab64521dcbfb8b44ac69d5021c21db \
    bf32aeed3acf3194789234d517395cfd9b8b991d86d4122dc8d5ca8b620793a3 \
    'import searches as Searches'

printf 'Verified 8 imported-summary failures (%s) from %s to %s.\n' \
    '2 red-black-dictionary, 4 tree-iterator, 2 search-frontier' \
    "$modular_pin" \
    "$lib_pin"
