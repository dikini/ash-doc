#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

readonly sources=(
    src/equality.ash
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
readonly actual_sources
mapfile -t expected_inventory < <(
    printf '%s\n' "${sources[@]}" | LC_ALL=C sort
)
readonly expected_inventory

[[ ${actual_sources[*]} == "${expected_inventory[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

readonly equality_source="$unit_root/src/equality.ash"

[[ $(grep -Fxc 'pub interface Equal<A> {' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must declare one public Equal<A> interface"
[[ $(grep -Fxc 'pub impl Equal<Int> {' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must declare one public Equal<Int> implementation"
[[ $(grep -Fxc 'pub same : (A, A) -> Bool where Equal<A>' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must give same its Equal<A> requirement"
[[ $(grep -Fxc 'same pair = equal pair' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must define same through equal"

readonly selected_source="$unit_root/src/01-selected.ash"

[[ $(grep -Fxc 'import equality (same, impl Equal)' "$selected_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-selected.ash must import same and select impl Equal"
[[ $(grep -Foc 'impl Equal' "$selected_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-selected.ash must contain impl Equal exactly once"
[[ $(grep -Foc 'same((21, 21))' "$selected_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-selected.ash must call same exactly once in main"
[[ $(grep -Eoc '(^|[^[:alnum:]_])equal([^[:alnum:]_]|$)' "$selected_source" || true) -eq 0 ]] ||
    ash_doc_fail "01-selected.ash must not import or call equal directly"

ash_doc_run_accepted "$unit_root" src/01-selected.ash 'true : Bool'

readonly name_only_source="$unit_root/src/02-name-only.ash"

[[ $(grep -Fxc 'import equality (same)' "$name_only_source" || true) -eq 1 ]] ||
    ash_doc_fail "02-name-only.ash must import only same"
[[ $(grep -Foc 'impl Equal' "$name_only_source" || true) -eq 0 ]] ||
    ash_doc_fail "02-name-only.ash must not select impl Equal"
[[ $(grep -Foc 'same((21, 21))' "$name_only_source" || true) -eq 1 ]] ||
    ash_doc_fail "02-name-only.ash must call same exactly once in main"
[[ $(grep -Eoc '(^|[^[:alnum:]_])equal([^[:alnum:]_]|$)' "$name_only_source" || true) -eq 0 ]] ||
    ash_doc_fail "02-name-only.ash must not import or call equal directly"

normalized_selected=$(mktemp "$ASH_DOC_VERIFY_DIR/selected.XXXXXX")
readonly normalized_selected
sed 's/, impl Equal//' "$selected_source" > "$normalized_selected"
cmp -s "$normalized_selected" "$name_only_source" ||
    ash_doc_fail \
        "the two entries must differ only by the impl Equal selector"

run_name_only_rejection() {
    local rejected_stdout
    local rejected_stderr
    local rejected_status
    rejected_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    rejected_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")

    if "$ASH_DOC_ASH_BIN" "$name_only_source" \
        > "$rejected_stdout" 2> "$rejected_stderr"; then
        rejected_status=0
    else
        rejected_status=$?
    fi

    [[ $rejected_status -eq 1 ]] ||
        ash_doc_fail \
            "src/02-name-only.ash exited with status $rejected_status, expected 1"
    [[ ! -s $rejected_stdout ]] ||
        ash_doc_fail "src/02-name-only.ash wrote unexpected standard output"
    [[ $(sed -n '1p' "$rejected_stderr") == 'constraint.unsatisfied' ]] ||
        ash_doc_fail \
            "src/02-name-only.ash did not report constraint.unsatisfied first"

    local call_spelling='same((21, 21))'
    local call_matches=()
    mapfile -t call_matches < <(
        LC_ALL=C grep -aboF "$call_spelling" "$name_only_source" || true
    )
    [[ ${#call_matches[@]} -eq 1 ]] ||
        ash_doc_fail \
            "src/02-name-only.ash must contain one byte-identifiable same call"
    local call_start=${call_matches[0]%%:*}
    local call_end=$((call_start + 4))

    local primary_lines=()
    mapfile -t primary_lines < <(
        LC_ALL=C grep -F 'primary: source 0 ' "$rejected_stderr" || true
    )
    [[ ${#primary_lines[@]} -eq 1 ]] ||
        ash_doc_fail \
            "src/02-name-only.ash must report one primary source-0 label"
    [[ ${primary_lines[0]} == \
        "primary: source 0 $call_start..$call_end:"* ]] ||
        ash_doc_fail \
            "src/02-name-only.ash primary label must cover the same call"

    local import_line='import equality (same)'
    local import_matches=()
    mapfile -t import_matches < <(
        LC_ALL=C grep -aboF "$import_line" "$name_only_source" || true
    )
    [[ ${#import_matches[@]} -eq 1 ]] ||
        ash_doc_fail \
            "src/02-name-only.ash must contain one byte-identifiable import"
    local import_start=${import_matches[0]%%:*}
    local imported_same_start=$((import_start + ${#import_line} - 5))
    local imported_same_end=$((imported_same_start + 4))

    local declaration_marker='pub same : (A, A) -> Bool where Equal<A>'
    local declaration_matches=()
    mapfile -t declaration_matches < <(
        LC_ALL=C grep -aboF "$declaration_marker" "$equality_source" || true
    )
    [[ ${#declaration_matches[@]} -eq 1 ]] ||
        ash_doc_fail \
            "equality.ash must contain one byte-identifiable same declaration"
    local declaration_start=$(( ${declaration_matches[0]%%:*} + 4 ))
    local declaration_end=$((declaration_start + 4))

    local interface_marker='pub interface Equal<A> {'
    local implementation_marker='pub impl Equal<Int> {'
    local interface_matches=()
    local implementation_matches=()
    mapfile -t interface_matches < <(
        LC_ALL=C grep -aboF "$interface_marker" "$equality_source" || true
    )
    mapfile -t implementation_matches < <(
        LC_ALL=C grep -aboF "$implementation_marker" "$equality_source" || true
    )
    [[ ${#interface_matches[@]} -eq 1 && ${#implementation_matches[@]} -eq 1 ]] ||
        ash_doc_fail \
            "equality.ash must contain byte-identifiable interface and implementation declarations"
    local interface_start=${interface_matches[0]%%:*}
    local interface_end=$(( ${implementation_matches[0]%%:*} - 2 ))

    local related_lines=()
    mapfile -t related_lines < <(
        LC_ALL=C grep -F 'related: source ' "$rejected_stderr" || true
    )
    [[ ${#related_lines[@]} -eq 3 ]] ||
        ash_doc_fail \
            "src/02-name-only.ash must report exactly three related labels"

    LC_ALL=C grep -Fxq \
        "related: source 0 $imported_same_start..$imported_same_end: this import made the declaration available" \
        "$rejected_stderr" ||
        ash_doc_fail \
            "the rejection must relate the obligation to the exact same import"
    LC_ALL=C grep -Fxq \
        "related: source 1 $declaration_start..$declaration_end: this declaration introduced the interface obligation" \
        "$rejected_stderr" ||
        ash_doc_fail \
            "the rejection must relate the obligation to the exact same declaration"
    LC_ALL=C grep -Fxq \
        "related: source 1 $interface_start..$interface_end: this interface declaration participates in the failing selection" \
        "$rejected_stderr" ||
        ash_doc_fail \
            "the rejection must relate the obligation to the exact Equal interface"
}

run_name_only_rejection

ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 3
