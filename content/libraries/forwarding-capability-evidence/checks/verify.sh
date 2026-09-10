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
    src/capability_facade.ash
    src/names_only_facade.ash
    src/01-forwarded.ash
    src/02-names-only.ash
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
lesson_one_equality="$content_root/libraries/choosing-implementation-evidence/src/equality.ash"
readonly lesson_one_equality

cmp -s "$lesson_one_equality" "$equality_source" ||
    ash_doc_fail "equality.ash must remain byte-identical to lesson 1"
[[ $(grep -Fxc 'pub interface Equal<A> {' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must declare one public Equal<A> interface"
[[ $(grep -Fxc 'pub impl Equal<Int> {' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must declare one public Equal<Int> implementation"
[[ $(grep -Fxc 'pub same : (A, A) -> Bool where Equal<A>' "$equality_source" || true) -eq 1 ]] ||
    ash_doc_fail "equality.ash must retain same's Equal<A> requirement"

readonly capability_facade="$unit_root/src/capability_facade.ash"
readonly names_only_facade="$unit_root/src/names_only_facade.ash"

[[ $(grep -Fxc \
    'pub import equality (Equal, equal, same, impl Equal)' \
    "$capability_facade" || true) -eq 1 ]] ||
    ash_doc_fail "capability_facade.ash must forward names and impl Equal"
[[ $(wc -l < "$capability_facade") -eq 1 ]] ||
    ash_doc_fail "capability_facade.ash must remain one import declaration"
[[ $(grep -Fxc \
    'pub import equality (Equal, equal, same)' \
    "$names_only_facade" || true) -eq 1 ]] ||
    ash_doc_fail "names_only_facade.ash must forward names only"
[[ $(wc -l < "$names_only_facade") -eq 1 ]] ||
    ash_doc_fail "names_only_facade.ash must remain one import declaration"

normalized_capability_facade=$(mktemp "$ASH_DOC_VERIFY_DIR/facade.XXXXXX")
readonly normalized_capability_facade
sed 's/, impl Equal//' "$capability_facade" > "$normalized_capability_facade"
cmp -s "$normalized_capability_facade" "$names_only_facade" ||
    ash_doc_fail "the facades must differ only by the impl Equal selector"

readonly forwarded_source="$unit_root/src/01-forwarded.ash"

[[ $(grep -Fxc \
    'import capability_facade (same, impl Equal)' \
    "$forwarded_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-forwarded.ash must select impl Equal through the facade"
[[ $(grep -Foc 'impl Equal' "$forwarded_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-forwarded.ash must contain one impl Equal selector"
[[ $(grep -Foc 'same((21, 21))' "$forwarded_source" || true) -eq 1 ]] ||
    ash_doc_fail "01-forwarded.ash must call same exactly once"
[[ $(grep -Foc 'import equality' "$forwarded_source" || true) -eq 0 ]] ||
    ash_doc_fail "01-forwarded.ash must not bypass the facade"
[[ $(grep -Eoc \
    '(^|[^[:alnum:]_])equal([^[:alnum:]_]|$)' \
    "$forwarded_source" || true) -eq 0 ]] ||
    ash_doc_fail "01-forwarded.ash must not call equal directly"

ash_doc_run_accepted "$unit_root" src/01-forwarded.ash 'true : Bool'

readonly name_only_source="$unit_root/src/02-names-only.ash"

[[ $(grep -Fxc \
    'import names_only_facade (same)' \
    "$name_only_source" || true) -eq 1 ]] ||
    ash_doc_fail "02-names-only.ash must import same through the names-only facade"
[[ $(grep -Foc 'impl Equal' "$name_only_source" || true) -eq 0 ]] ||
    ash_doc_fail "02-names-only.ash must not select impl Equal"
[[ $(grep -Foc 'same((21, 21))' "$name_only_source" || true) -eq 1 ]] ||
    ash_doc_fail "02-names-only.ash must call same exactly once"
[[ $(grep -Foc 'import equality' "$name_only_source" || true) -eq 0 ]] ||
    ash_doc_fail "02-names-only.ash must not bypass the facade"
[[ $(grep -Eoc \
    '(^|[^[:alnum:]_])equal([^[:alnum:]_]|$)' \
    "$name_only_source" || true) -eq 0 ]] ||
    ash_doc_fail "02-names-only.ash must not call equal directly"

normalized_forwarded=$(mktemp "$ASH_DOC_VERIFY_DIR/forwarded.XXXXXX")
readonly normalized_forwarded
sed \
    -e 's/capability_facade/names_only_facade/' \
    -e 's/, impl Equal//' \
    "$forwarded_source" > "$normalized_forwarded"
cmp -s "$normalized_forwarded" "$name_only_source" ||
    ash_doc_fail \
        "the entries must differ only by facade path and impl Equal selector"

ash_doc_run_rejected "$unit_root" src/02-names-only.ash 1

ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 5
