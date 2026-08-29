#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/lists.ash"
readonly sources=(
    src/lists.ash
    src/01-fold.ash
    src/02-map-filter.ash
    src/03-eager-fold.ash
    src/04-wrong-combiner.ash
)

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"

grep -Fqx 'fold combine base More(first, rest) = {' "$library" ||
    ash_doc_fail "fold must open an ordered recursive case"
grep -Fqx '    let folded_rest = fold combine base rest' "$library" ||
    ash_doc_fail "fold must obtain the folded rest before combining"
grep -Fqx '    combine first folded_rest' "$library" ||
    ash_doc_fail "fold must combine first with the folded rest"

for definition in sum length map filter; do
    grep -Eq "^${definition} .* = fold" "$library" ||
        ash_doc_fail "$definition must be defined through fold"
    [[ $(grep -ow "$definition" "$library" | wc -l) -eq 2 ]] ||
        ash_doc_fail "$definition must not define another traversal"
done

grep -Eq '^first_and_visits .* = fold' "$library" ||
    ash_doc_fail "first_and_visits must obtain its result through fold"

ash_doc_run_accepted \
    "$unit_root" src/01-fold.ash '(6, 3) : (Int, Int)'
ash_doc_run_accepted \
    "$unit_root" \
    src/02-map-filter.ash \
    '(More(42, More(43, More(44, Empty))), More(42, Empty)) : (List<Int>, List<Int>)'
ash_doc_run_accepted \
    "$unit_root" src/03-eager-fold.ash '(Some(42), 3) : (Option<Int>, Int)'
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-combiner.ash \
    type.argument \
    'this argument does not match the function domain' \
    1
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-combiner.ash \
    type.argument \
    'expected Bool' \
    1
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-combiner.ash \
    type.argument \
    'found Int' \
    1
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-combiner.ash \
    type.argument \
    'primary: source 0 137..138:' \
    1

ash_doc_finish 5
