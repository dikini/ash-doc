#!/usr/bin/env bash

set -euo pipefail

effects_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly effects_root
content_root=$(cd "$effects_root/.." && pwd)
readonly content_root

# shellcheck source=../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

mapfile -t verifiers < <(
    find "$effects_root" \
        -mindepth 3 \
        -maxdepth 3 \
        -type f \
        -path '*/checks/verify.sh' \
        -print |
        LC_ALL=C sort
)
readonly verifiers

[[ ${#verifiers[@]} -gt 0 ]] || ash_doc_fail "no effects lesson verifiers found"

readonly index="$effects_root/README.md"
indexed_lesson_count=$(grep -Ec '^[0-9]+\. \[' "$index" || true)
readonly indexed_lesson_count
[[ ${#verifiers[@]} -eq $indexed_lesson_count ]] ||
    ash_doc_fail \
        "active effects verifier count ${#verifiers[@]} differs from indexed lesson count $indexed_lesson_count"

for verifier in "${verifiers[@]}"; do
    bash "$verifier" "$1"
done

printf 'Verified %s effects lesson(s) at %s.\n' \
    "${#verifiers[@]}" "$ash_doc_expected_pin"
