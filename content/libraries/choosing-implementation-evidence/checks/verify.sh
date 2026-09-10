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

ash_doc_run_rejected "$unit_root" src/02-name-only.ash 1
ash_doc_check_human "$unit_root" src/02-name-only.ash "$unit_root/src"

ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 3
