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

readonly active_destinations=(
    folding-recursive-lists
    building-finite-lists
    accumulating-list-results
    dictionary-as-list
    folding-branching-data
    searching-ordered-tree
    abstracting-key-order
    protecting-dictionary-invariant
    guaranteeing-logarithmic-retrieval
    resuming-tree-traversal
    implementing-persistent-fifo-frontier
    choosing-a-search-frontier
    numbering-tree-leaves
    measuring-tree-search
    supplying-order-prices
    running-a-scripted-session
    bounding-search-work
    compressing-parent-paths
    reading-a-bounded-message
    controlling-a-hook-pipeline
    preserving-outcomes-through-cleanup
    supplying-a-local-pricing-policy
    querying-an-immutable-world
    rolling-back-a-cancellable-journal
    redacting-before-publication
    checking-proposed-edits
    cancelling-a-stable-sort
)
readonly expected_case_count=${#active_destinations[@]}

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
[[ ${#numbered_slots[@]} -eq $expected_case_count ]] ||
    ash_doc_fail "Cases index must expose exactly $expected_case_count numbered slots"

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

for destination_index in "${!active_destinations[@]}"; do
    slot=$((destination_index + 1))
    slot_source=$(read_slot "$slot")
    destination=${active_destinations[$destination_index]}
    [[ $(grep -Foc "]($destination/README.md)" <<< "$slot_source") -eq 1 ]] ||
        ash_doc_fail "Cases index slot $slot must retain its active destination"
done

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
