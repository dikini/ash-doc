#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/lists.ash"
readonly map_entry="$unit_root/src/03-map-produced-list.ash"
readonly sources=(
    src/lists.ash
    src/01-unfold.ash
    src/02-counted-unfold.ash
    src/03-map-produced-list.ash
    src/04-wrong-seed.ash
)

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
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

unfold_section=$(ash_doc_section \
    'pub unfold : (S -> Step<S, A>) -> S -> List<A>' \
    'pub unfold_counted : (S -> Step<S, A>) -> S -> (List<A>, Int)')
counted_section=$(ash_doc_section \
    'pub unfold_counted : (S -> Step<S, A>) -> S -> (List<A>, Int)' \
    'pub map : (A -> B) -> List<A> -> List<B>')
map_section=$(ash_doc_section \
    'pub map : (A -> B) -> List<A> -> List<B>' \
    'pub repeat_step : Int -> Natural -> Step<Natural, Int>')
repeat_section=$(ash_doc_section \
    'pub repeat_step : Int -> Natural -> Step<Natural, Int>' \
    '')
map_entry_source=$(<"$map_entry")
readonly unfold_section counted_section map_section repeat_section
readonly map_entry_source

ash_doc_assert_word_count \
    "$unfold_section" unfold 3 \
    "unfold must contain only its signature, definition, and one recursive use"
ash_doc_assert_phrase_count \
    "$unfold_section" 'match transition state' 1 \
    "unfold must apply its transition once before matching"
ash_doc_assert_phrase_count \
    "$unfold_section" 'Stop => Empty' 1 \
    "unfold must turn Stop into Empty exactly once"
ash_doc_assert_phrase_count \
    "$unfold_section" 'Emit(value, next_state)' 1 \
    "unfold must expose one emitted value and next state"
ash_doc_assert_phrase_count \
    "$unfold_section" \
    'let produced_rest = unfold transition next_state' 1 \
    "unfold must obtain the recursive rest exactly once"
ash_doc_assert_phrase_count \
    "$unfold_section" 'More(value, produced_rest)' 1 \
    "unfold must construct one More after obtaining the recursive rest"

ash_doc_assert_word_count \
    "$counted_section" unfold_counted 3 \
    "counted unfold must contain one recursive use"
ash_doc_assert_phrase_count \
    "$counted_section" 'match transition state' 1 \
    "counted unfold must apply its transition once before matching"
ash_doc_assert_phrase_count \
    "$counted_section" 'Stop => (Empty, 1)' 1 \
    "counted unfold must count the transition that returns Stop"
ash_doc_assert_phrase_count \
    "$counted_section" \
    'let (produced_rest, later_steps) = unfold_counted transition next_state' 1 \
    "counted unfold must obtain exactly one recursive result"
ash_doc_assert_phrase_count \
    "$counted_section" \
    '(More(value, produced_rest), later_steps + 1)' 1 \
    "counted unfold must add one for each emitting transition"

ash_doc_assert_word_count \
    "$map_section" map 4 \
    "map must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$map_section" 'map transform Empty = Empty' 1 \
    "map must preserve the empty form"
ash_doc_assert_phrase_count \
    "$map_section" 'let mapped_rest = map transform rest' 1 \
    "map must obtain exactly one recursively mapped rest"
ash_doc_assert_phrase_count \
    "$map_section" 'More(transform first, mapped_rest)' 1 \
    "map must construct one transformed More after the recursive rest"

ash_doc_assert_word_count \
    "$repeat_section" repeat_step 3 \
    "repeat_step must contain only its signature and two equations"
ash_doc_assert_phrase_count \
    "$repeat_section" 'repeat_step value Zero = Stop' 1 \
    "repeat_step must stop at Zero"
ash_doc_assert_phrase_count \
    "$repeat_section" \
    'repeat_step value Next(rest) = Emit(value, rest)' 1 \
    "repeat_step must continue with the direct rest field"

ash_doc_assert_phrase_count \
    "$map_entry_source" \
    'let produced = Lists.unfold (Lists.repeat_step 42) three' 1 \
    "the map entry must bind the complete produced list"
ash_doc_assert_phrase_count \
    "$map_entry_source" \
    'let mapped = Lists.map increment produced' 1 \
    "the map entry must map the bound produced list"
ash_doc_assert_phrase_count \
    "$map_entry_source" '(produced, mapped)' 1 \
    "the map entry must retain both complete lists"

produced_line=$(grep -nF \
    'let produced = Lists.unfold (Lists.repeat_step 42) three' \
    "$map_entry" | cut -d: -f1)
mapped_line=$(grep -nF \
    'let mapped = Lists.map increment produced' \
    "$map_entry" | cut -d: -f1)
result_line=$(grep -nF '(produced, mapped)' "$map_entry" | cut -d: -f1)
readonly produced_line mapped_line result_line

[[ $produced_line -lt $mapped_line && $mapped_line -lt $result_line ]] ||
    ash_doc_fail \
        "the map entry must produce, map, and retain the lists in that order"

readonly mapped_output='(More(42, More(42, More(42, Empty))), '\
'More(43, More(43, More(43, Empty)))) : (List<Int>, List<Int>)'

ash_doc_run_accepted \
    "$unit_root" \
    src/01-unfold.ash \
    'More(42, More(42, More(42, Empty))) : List<Int>'
ash_doc_run_accepted \
    "$unit_root" \
    src/02-counted-unfold.ash \
    '(More(42, More(42, More(42, Empty))), 4) : (List<Int>, Int)'
ash_doc_run_accepted \
    "$unit_root" \
    src/03-map-produced-list.ash \
    "$mapped_output"
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-seed.ash \
    type.argument \
    'this argument does not match the function domain' \
    1
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-seed.ash \
    type.argument \
    'expected Natural' \
    1
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-seed.ash \
    type.argument \
    'found Bool' \
    1
ash_doc_run_rejected \
    "$unit_root" \
    src/04-wrong-seed.ash \
    type.argument \
    'primary: source 0 100..104:' \
    1

ash_doc_finish 5
