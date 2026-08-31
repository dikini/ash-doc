#!/usr/bin/env bash

set -euo pipefail

cases_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly cases_root
content_root=$(cd "$cases_root/.." && pwd)
readonly content_root

# shellcheck source=../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

mapfile -t verifiers < <(
    find "$cases_root" \
        -mindepth 3 \
        -maxdepth 3 \
        -type f \
        -path '*/checks/verify.sh' \
        -print |
        LC_ALL=C sort
)
readonly verifiers

[[ ${#verifiers[@]} -gt 0 ]] || ash_doc_fail "no case verifiers found"

readonly index="$cases_root/README.md"
mapfile -t numbered_slots < <(
    awk '
        $0 == "## Cases in order" { inside = 1; next }
        inside && /^[0-9]+\. / {
            number = $1
            sub(/\.$/, "", number)
            print number
        }
    ' "$index"
)
readonly numbered_slots
[[ ${#numbered_slots[@]} -eq 12 ]] ||
    ash_doc_fail "Cases index must expose exactly twelve numbered slots"

for slot_index in "${!numbered_slots[@]}"; do
    expected_slot=$((slot_index + 1))
    [[ ${numbered_slots[$slot_index]} -eq $expected_slot ]] ||
        ash_doc_fail "Cases index slots must remain in strict numeric order"
done

read_slot() {
    if [[ $# -ne 1 ]]; then
        ash_doc_fail "read_slot requires one slot number"
    fi

    awk -v requested="$1" '
        $0 == "## Cases in order" { list = 1; next }
        !list { next }
        /^[0-9]+\. / {
            current = $1
            sub(/\.$/, "", current)
            if (inside && current != requested) {
                exit
            }
            inside = current == requested
        }
        inside { print }
    ' "$index"
}

readonly active_destinations=(
    folding-recursive-lists
    building-finite-lists
    accumulating-list-results
    dictionary-as-list
    folding-branching-data
    searching-ordered-tree
    abstracting-key-order
    protecting-dictionary-invariant
)

for slot in {1..8}; do
    slot_source=$(read_slot "$slot")
    destination=${active_destinations[$((slot - 1))]}
    [[ $(grep -Foc "]($destination/README.md)" <<< "$slot_source") -eq 1 ]] ||
        ash_doc_fail "Cases index slot $slot must retain its active destination"
done

readonly unavailable_slots=(9 10 12)
readonly unavailable_destinations=(
    guaranteeing-logarithmic-retrieval
    resuming-tree-traversal
    choosing-a-search-frontier
)
readonly failure_anchors=(
    red-black-dictionary
    tree-iterator
    search-frontier
)

for unavailable_index in "${!unavailable_slots[@]}"; do
    slot=${unavailable_slots[$unavailable_index]}
    destination=${unavailable_destinations[$unavailable_index]}
    anchor=${failure_anchors[$unavailable_index]}
    slot_source=$(read_slot "$slot")
    [[ $slot_source != *"]($destination/README.md)"* ]] ||
        ash_doc_fail "Cases index slot $slot must not expose an active destination"
    [[ $(grep -Fo '**Unavailable at this target**' <<< "$slot_source" | wc -l) -eq 1 ]] ||
        ash_doc_fail "Cases index slot $slot must carry one unavailable label"
    [[ $(grep -Eo '\]\([^)]*body-free-summary-authentication/README\.md#[^)]+\)' \
        <<< "$slot_source" | wc -l) -eq 1 ]] ||
        ash_doc_fail "Cases index slot $slot must carry one failure-report link"
    [[ $slot_source == *"](../../lab/lib-ash-migration/body-free-summary-authentication/README.md#$anchor)"* ]] ||
        ash_doc_fail "Cases index slot $slot must link its exact failure evidence"
done

slot_eleven=$(read_slot 11)
[[ $(grep -Foc \
    '](implementing-persistent-fifo-frontier/README.md)' \
    <<< "$slot_eleven") -eq 1 ]] ||
    ash_doc_fail "Cases index slot 11 must retain its active destination"
[[ $slot_eleven != *'**Pending migration**'* ]] ||
    ash_doc_fail "Cases index slot 11 must not carry a pending label"

active_case_count=${#verifiers[@]}
indexed_case_count=$(grep -Ec '^[0-9]+\. \[' "$index")
[[ $active_case_count -eq $indexed_case_count ]] ||
    ash_doc_fail \
        "active Case verifier count $active_case_count differs from indexed Case count $indexed_case_count"

for verifier in "${verifiers[@]}"; do
    bash "$verifier" "$1"
done

printf 'Verified %s case(s) at %s.\n' \
    "${#verifiers[@]}" "$ash_doc_expected_pin"
