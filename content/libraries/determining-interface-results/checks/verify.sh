#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

[[ $# -eq 1 ]] || ash_doc_fail \
    "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"

readonly sources=(
    src/measurement.ash
    src/01-selected.ash
    src/02-name-only.ash
)
for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] ||
        ash_doc_fail "missing canonical source: $source"
done

mapfile -t actual_sources < <(
    find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
mapfile -t expected_sources < <(
    printf '%s\n' "${sources[@]}" | LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${expected_sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

readonly measurement_source="$unit_root/src/measurement.ash"
readonly selected_source="$unit_root/src/01-selected.ash"
readonly name_only_source="$unit_root/src/02-name-only.ash"

[[ $(grep -Fxc \
    'pub interface Measure<Key, Result> where Key -> Result {' \
    "$measurement_source" || true) -eq 1 ]] ||
    ash_doc_fail "Measure must declare the total Key -> Result edge"
[[ $(grep -Fxc '    measure : Key -> Int' \
    "$measurement_source" || true) -eq 1 ]] ||
    ash_doc_fail "measure must omit the dependent Result from its method type"
[[ $(grep -Fxc 'pub impl Measure<Bool, Unit> {' \
    "$measurement_source" || true) -eq 1 ]] ||
    ash_doc_fail "measurement.ash must publish Measure<Bool, Unit>"

[[ $(grep -Fxc 'import measurement (measure, impl Measure)' \
    "$selected_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-selected.ash must select impl Measure"
[[ $(grep -Fxc 'import measurement (measure)' \
    "$name_only_source" || true) -eq 1 ]] ||
    ash_doc_fail "02-name-only.ash must import the method name only"

normalized_selected=$(mktemp "$ASH_DOC_VERIFY_DIR/selected.XXXXXX")
readonly normalized_selected
sed 's/, impl Measure//' "$selected_source" > "$normalized_selected"
cmp -s "$normalized_selected" "$name_only_source" ||
    ash_doc_fail "the entries must differ only by the impl Measure selector"

ash_doc_run_accepted "$unit_root" src/01-selected.ash '42 : Int'

run_ambiguous_rejection() {
    local rejected_stdout rejected_stderr rejected_status
    rejected_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    rejected_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")
    if "$ASH_DOC_ASH_BIN" "$name_only_source" \
        > "$rejected_stdout" 2> "$rejected_stderr"; then
        rejected_status=0
    else
        rejected_status=$?
    fi

    [[ $rejected_status -eq 1 ]] ||
        ash_doc_fail "the name-only source must exit with status 1"
    [[ ! -s $rejected_stdout ]] ||
        ash_doc_fail "the name-only source must write empty stdout"
    [[ $(sed -n '1p' "$rejected_stderr") == 'constraint.ambiguous' ]] ||
        ash_doc_fail "the rejection must report constraint.ambiguous"

    local call_spelling='measure(true)'
    local call_matches=()
    mapfile -t call_matches < <(
        LC_ALL=C grep -aboF "$call_spelling" "$name_only_source" || true
    )
    [[ ${#call_matches[@]} -eq 1 ]] ||
        ash_doc_fail "the name-only source must contain one measure call"
    local call_start=${call_matches[0]%%:*}
    local call_end=$((call_start + 7))

    local import_spelling='import measurement (measure)'
    local import_matches=()
    mapfile -t import_matches < <(
        LC_ALL=C grep -aboF "$import_spelling" "$name_only_source" || true
    )
    [[ ${#import_matches[@]} -eq 1 ]] ||
        ash_doc_fail "the name-only source must contain one measure import"
    local import_start=$(( ${import_matches[0]%%:*} + 20 ))
    local import_end=$((import_start + 7))

    local method_marker='measure : Key -> Int'
    local method_matches=()
    mapfile -t method_matches < <(
        LC_ALL=C grep -aboF "$method_marker" "$measurement_source" || true
    )
    [[ ${#method_matches[@]} -eq 1 ]] ||
        ash_doc_fail "measurement.ash must contain one method signature"
    local method_start=${method_matches[0]%%:*}
    local method_end=$((method_start + ${#method_marker}))
    local interface_start=0
    local interface_end=$((method_end + 2))

    local primary_lines=() related_lines=()
    mapfile -t primary_lines < <(
        LC_ALL=C grep -F 'primary: source ' "$rejected_stderr" || true
    )
    mapfile -t related_lines < <(
        LC_ALL=C grep -F 'related: source ' "$rejected_stderr" || true
    )
    [[ ${#primary_lines[@]} -eq 1 ]] ||
        ash_doc_fail "the rejection must retain one primary cause"
    [[ ${primary_lines[0]} == \
        "primary: source 0 $call_start..$call_end:"* ]] ||
        ash_doc_fail "the primary label must cover the measure occurrence"
    [[ ${#related_lines[@]} -eq 3 ]] ||
        ash_doc_fail "the rejection must retain three related declarations"
    grep -Fqx \
        "related: source 0 $import_start..$import_end: this import made the declaration available" \
        "$rejected_stderr" ||
        ash_doc_fail "the rejection must retain the client's measure import"
    grep -Fqx \
        "related: source 1 $method_start..$method_end: this declaration introduced the interface obligation" \
        "$rejected_stderr" ||
        ash_doc_fail "the rejection must retain the measure declaration"
    [[ ${related_lines[2]} == \
        "related: source 1 $interface_start..$interface_end:"* ]] ||
        ash_doc_fail "the rejection must retain the Measure declaration"
}

run_ambiguous_rejection
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 3
