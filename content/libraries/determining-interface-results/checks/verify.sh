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

ash_doc_run_rejected "$unit_root" src/02-name-only.ash 1
ash_doc_check_human "$unit_root" src/02-name-only.ash "$unit_root/src"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 3
