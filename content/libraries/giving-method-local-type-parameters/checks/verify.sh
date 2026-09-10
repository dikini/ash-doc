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
    src/api.ash
    src/carrier.ash
    src/01-map-pair.ash
    src/02-missing-method-parameters.ash
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

readonly api_source="$unit_root/src/api.ash"
readonly carrier_source="$unit_root/src/carrier.ash"
readonly entry_source="$unit_root/src/01-map-pair.ash"
readonly rejected_source="$unit_root/src/02-missing-method-parameters.ash"

[[ $(grep -Fxc '    map<A, B> : (A -> B, F<A>) -> F<B>' \
    "$api_source" || true) -eq 1 ]] ||
    ash_doc_fail "Functor.map must declare the ordered local parameters A and B"
[[ $(grep -Fxc \
    'map_pair (numbers, flags) = (map((to_bool, numbers)), map((to_int, flags)))' \
    "$api_source" || true) -eq 1 ]] ||
    ash_doc_fail "map_pair must use map at both element-type pairs"
[[ $(grep -Fxc 'pub impl Functor<Box> {' "$carrier_source" || true) -eq 1 ]] ||
    ash_doc_fail "carrier.ash must publish the Functor<Box> implementation"
[[ $(grep -Fxc 'import carrier (Box, impl Functor)' \
    "$entry_source" || true) -eq 1 ]] ||
    ash_doc_fail "the entry must select Functor evidence independently"

ash_doc_run_accepted \
    "$unit_root" src/01-map-pair.ash \
    '(Box(true), Box(42)) : (Box<Bool>, Box<Int>)'

[[ $(grep -Fxc '    map : (A -> B, F<A>) -> F<B>' \
    "$rejected_source" || true) -eq 1 ]] ||
    ash_doc_fail "the rejected method must omit its local parameter list"
[[ $(grep -Foc 'map<A, B>' "$rejected_source" || true) -eq 0 ]] ||
    ash_doc_fail "the rejected method must not declare A or B"

ash_doc_run_rejected "$unit_root" src/02-missing-method-parameters.ash 1
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 4
