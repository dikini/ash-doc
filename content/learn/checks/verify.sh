#!/usr/bin/env bash

set -euo pipefail

learn_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly learn_root
content_root=$(cd "$learn_root/.." && pwd)
readonly content_root

# shellcheck source=../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

mapfile -t verifiers < <(
    find "$learn_root" \
        -mindepth 3 \
        -maxdepth 3 \
        -type f \
        -path '*/checks/verify.sh' \
        -print |
        LC_ALL=C sort
)
readonly verifiers

[[ ${#verifiers[@]} -gt 0 ]] || ash_doc_fail "no lesson verifiers found"

for verifier in "${verifiers[@]}"; do
    bash "$verifier" "$1"
done

printf 'Verified %s learning lesson(s) at %s.\n' \
    "${#verifiers[@]}" "$ash_doc_expected_pin"
