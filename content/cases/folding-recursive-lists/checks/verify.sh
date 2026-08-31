#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/lists.ash"
readonly fold_entry="$unit_root/src/01-fold.ash"
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

ash_doc_section() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_section requires start and end lines"
    fi

    awk -v section_start="$1" -v section_end="$2" '
        $0 == section_start {
            inside = 1
        }
        inside && section_end != "" && $0 == section_end {
            exit
        }
        inside {
            print
        }
    ' "$library"
}

ash_doc_assert_word_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail \
            "ash_doc_assert_word_count requires source, word, count, and claim"
    fi

    local section=$1
    local word=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Eow "$word" <<< "$section" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_phrase_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail \
            "ash_doc_assert_phrase_count requires source, phrase, count, and claim"
    fi

    local section=$1
    local phrase=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fo "$phrase" <<< "$section" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected $expected_count)"
}

fold_section=$(ash_doc_section \
    'pub fold : (A -> B -> B) -> B -> List<A> -> B' \
    'pub sum : List<Int> -> Int')
sum_section=$(ash_doc_section \
    'pub sum : List<Int> -> Int' \
    'pub length : List<A> -> Int')
length_section=$(ash_doc_section \
    'pub length : List<A> -> Int' \
    'pub map : (A -> B) -> List<A> -> List<B>')
map_section=$(ash_doc_section \
    'pub map : (A -> B) -> List<A> -> List<B>' \
    'pub filter : (A -> Bool) -> List<A> -> List<A>')
filter_section=$(ash_doc_section \
    'pub filter : (A -> Bool) -> List<A> -> List<A>' \
    'pub first_and_visits : List<A> -> (Option<A>, Int)')
first_section=$(ash_doc_section \
    'pub first_and_visits : List<A> -> (Option<A>, Int)' \
    '')
fold_entry_source=$(<"$fold_entry")
readonly fold_section sum_section length_section map_section filter_section
readonly first_section fold_entry_source

ash_doc_assert_phrase_count \
    "$fold_section" 'fold combine base Empty = base' 1 \
    "fold must have exactly one base equation"
ash_doc_assert_phrase_count \
    "$fold_section" 'fold combine base rest' 1 \
    "fold must make exactly one recursive call in its More equation"
ash_doc_assert_phrase_count \
    "$fold_section" 'let folded_rest = fold combine base rest' 1 \
    "fold must obtain the folded rest before combining"
ash_doc_assert_phrase_count \
    "$fold_section" 'combine first folded_rest' 1 \
    "fold must make exactly one complete combiner call per More"
ash_doc_assert_word_count \
    "$fold_section" fold 4 \
    "fold must contain only its signature, equations, and one recursive use"
ash_doc_assert_word_count \
    "$fold_section" combine 4 \
    "fold must contain only its parameters and one complete combiner call"

for definition in sum length map filter; do
    [[ $(grep -ow "$definition" "$library" | wc -l) -eq 2 ]] ||
        ash_doc_fail "$definition must not define another traversal"
done

ash_doc_assert_word_count \
    "$sum_section" fold 1 "sum must use fold exactly once"
ash_doc_assert_phrase_count \
    "$sum_section" 'sum list = fold (fn(first) {' 1 \
    "sum must begin directly with its one fold"
ash_doc_assert_word_count \
    "$length_section" fold 1 "length must use fold exactly once"
ash_doc_assert_phrase_count \
    "$length_section" 'length list = fold (fn(ignored) {' 1 \
    "length must begin directly with its one fold"
ash_doc_assert_word_count \
    "$map_section" fold 1 "map must use fold exactly once"
ash_doc_assert_phrase_count \
    "$map_section" 'map transform list = fold (fn(first) {' 1 \
    "map must begin directly with its one fold"
ash_doc_assert_word_count \
    "$map_section" More 1 "map must construct exactly one More per combiner"
ash_doc_assert_word_count \
    "$map_section" transform 2 \
    "map must apply its transform exactly once per combiner"
ash_doc_assert_phrase_count \
    "$map_section" 'More(transform first, mapped_rest)' 1 \
    "map must construct its output More from the transformed first and rest"
ash_doc_assert_word_count \
    "$filter_section" fold 1 "filter must use fold exactly once"
ash_doc_assert_phrase_count \
    "$filter_section" 'filter keep list = fold (fn(first) {' 1 \
    "filter must begin directly with its one fold"
ash_doc_assert_word_count \
    "$filter_section" More 1 \
    "filter must construct exactly one More in its retained branch"
ash_doc_assert_word_count \
    "$filter_section" keep 2 \
    "filter must apply its predicate exactly once per combiner"
ash_doc_assert_phrase_count \
    "$filter_section" 'match keep first {' 1 \
    "filter must apply its predicate directly in its one match"
ash_doc_assert_phrase_count \
    "$filter_section" 'true => More(first, filtered_rest)' 1 \
    "filter must construct More only in its retained branch"
ash_doc_assert_phrase_count \
    "$filter_section" 'false => filtered_rest' 1 \
    "filter must reuse the folded rest in its rejected branch"
ash_doc_assert_word_count \
    "$first_section" first_and_visits 2 \
    "first_and_visits must not define another traversal"
ash_doc_assert_word_count \
    "$first_section" fold 1 "first_and_visits must use fold exactly once"
ash_doc_assert_phrase_count \
    "$first_section" 'first_and_visits list = fold (fn(first) {' 1 \
    "first_and_visits must begin directly with its one fold"
ash_doc_assert_phrase_count \
    "$first_section" '(Some(first), visits + 1)' 1 \
    "first_and_visits must count exactly one visit per combiner"
ash_doc_assert_phrase_count \
    "$fold_entry_source" 'Lists.sum' 1 \
    "the fold entry must invoke sum exactly once"
ash_doc_assert_phrase_count \
    "$fold_entry_source" 'Lists.length' 1 \
    "the fold entry must invoke length exactly once"

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
