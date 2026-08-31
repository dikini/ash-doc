#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/lists.ash"
readonly same_result_entry="$unit_root/src/01-same-result.ash"
readonly counted_entry="$unit_root/src/02-counted-work.ash"
readonly invariant_entry="$unit_root/src/03-accumulator-invariant.ash"
readonly wrong_initial_entry="$unit_root/src/04-wrong-initial-accumulator.ash"
readonly sources=(
    src/lists.ash
    src/01-same-result.ash
    src/02-counted-work.ash
    src/03-accumulator-invariant.ash
    src/04-wrong-initial-accumulator.ash
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

    if ! awk -v section_start="$1" -v section_end="$2" '
        $0 == section_start {
            start_seen = 1
            inside = 1
        }
        inside && section_end != "" && $0 == section_end {
            end_seen = 1
            exit
        }
        inside {
            print
        }
        END {
            if (!start_seen || (section_end != "" && !end_seen)) {
                exit 2
            }
        }
    ' "$library"; then
        ash_doc_fail \
            "ash_doc_section could not find its required adjacent signatures"
    fi
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

ash_doc_assert_suffix() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_suffix requires source, suffix, and claim"
    fi

    local section=$1
    local expected_suffix=$2
    local claim=$3

    [[ $section == *"$expected_suffix" ]] || ash_doc_fail "$claim"
}

ash_doc_assert_readme_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail \
            "ash_doc_assert_readme_line_once requires expected line and claim"
    fi

    local expected_line=$1
    local claim=$2
    local actual_count
    actual_count=$(grep -Fxc -- "$expected_line" "$readme" || true)

    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected 1)"
}

append_section=$(ash_doc_section \
    'pub append : List<A> -> List<A> -> List<A>' \
    'pub reverse_through_append : List<A> -> List<A>')
append_reverse_section=$(ash_doc_section \
    'pub reverse_through_append : List<A> -> List<A>' \
    'append_revisits : List<A> -> List<A> -> (List<A>, Int)')
append_revisits_section=$(ash_doc_section \
    'append_revisits : List<A> -> List<A> -> (List<A>, Int)' \
    'reverse_revisits : List<A> -> (List<A>, Int)')
reverse_revisits_section=$(ash_doc_section \
    'reverse_revisits : List<A> -> (List<A>, Int)' \
    'pub reverse_through_append_with_revisits : List<A> -> (List<A>, Int)')
counted_append_reverse_section=$(ash_doc_section \
    'pub reverse_through_append_with_revisits : List<A> -> (List<A>, Int)' \
    'pub fold_left : (B -> A -> B) -> B -> List<A> -> B')
fold_left_section=$(ash_doc_section \
    'pub fold_left : (B -> A -> B) -> B -> List<A> -> B' \
    'pub prepend : List<A> -> A -> List<A>')
prepend_section=$(ash_doc_section \
    'pub prepend : List<A> -> A -> List<A>' \
    'pub reverse_with_accumulator : List<A> -> List<A>')
accumulator_reverse_section=$(ash_doc_section \
    'pub reverse_with_accumulator : List<A> -> List<A>' \
    'fold_left_visits : (B -> A -> B) -> B -> Int -> List<A> -> (B, Int)')
fold_left_visits_section=$(ash_doc_section \
    'fold_left_visits : (B -> A -> B) -> B -> Int -> List<A> -> (B, Int)' \
    'pub reverse_with_accumulator_and_visits : List<A> -> (List<A>, Int)')
counted_accumulator_reverse_section=$(ash_doc_section \
    'pub reverse_with_accumulator_and_visits : List<A> -> (List<A>, Int)' \
    '')
same_result_entry_source=$(<"$same_result_entry")
counted_entry_source=$(<"$counted_entry")
invariant_entry_source=$(<"$invariant_entry")
wrong_initial_entry_source=$(<"$wrong_initial_entry")
readonly append_section append_reverse_section append_revisits_section
readonly reverse_revisits_section fold_left_section prepend_section
readonly accumulator_reverse_section fold_left_visits_section
readonly counted_append_reverse_section counted_accumulator_reverse_section
readonly same_result_entry_source counted_entry_source invariant_entry_source
readonly wrong_initial_entry_source

ash_doc_assert_word_count \
    "$append_section" append 4 \
    "append must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$append_section" 'append Empty right = right' 1 \
    "append must return the right list when the left list is Empty"
ash_doc_assert_phrase_count \
    "$append_section" 'let appended_rest = append rest right' 1 \
    "append must obtain one recursively appended left rest"
ash_doc_assert_phrase_count \
    "$append_section" 'More(first, appended_rest)' 1 \
    "append must copy one left More after obtaining the appended rest"

ash_doc_assert_word_count \
    "$append_reverse_section" reverse_through_append 4 \
    "append reverse must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$append_reverse_section" \
    'let reversed_rest = reverse_through_append rest' 1 \
    "append reverse must bind one recursively reversed rest"
ash_doc_assert_phrase_count \
    "$append_reverse_section" \
    'append reversed_rest (More(first, Empty))' 1 \
    "append reverse must append the current singleton after reversing the rest"

ash_doc_assert_word_count \
    "$append_revisits_section" append_revisits 4 \
    "append_revisits must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$append_revisits_section" \
    'append_revisits Empty right = (right, 0)' 1 \
    "append_revisits must return the unchanged right list with zero visits at Empty"
ash_doc_assert_phrase_count \
    "$append_revisits_section" \
    'let (appended_rest, later_revisits) = append_revisits rest right' 1 \
    "append_revisits must recurse once on the left rest and retain both results"
ash_doc_assert_phrase_count \
    "$append_revisits_section" \
    '(More(first, appended_rest), later_revisits + 1)' 1 \
    "append_revisits must copy and count the current left More"

ash_doc_assert_word_count \
    "$reverse_revisits_section" reverse_revisits 4 \
    "reverse_revisits must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$reverse_revisits_section" \
    'reverse_revisits Empty = (Empty, 0)' 1 \
    "reverse_revisits must return an empty result with zero visits at Empty"
ash_doc_assert_phrase_count \
    "$reverse_revisits_section" \
    'let (reversed_rest, earlier_revisits) = reverse_revisits rest' 1 \
    "reverse_revisits must obtain the recursive result and its earlier visits"
ash_doc_assert_phrase_count \
    "$reverse_revisits_section" 'let singleton = More(first, Empty)' 1 \
    "reverse_revisits must bind the current singleton"
ash_doc_assert_phrase_count \
    "$reverse_revisits_section" \
    'let (reversed, current_revisits) = append_revisits reversed_rest singleton' 1 \
    "reverse_revisits must apply counted append to the reversed rest and singleton"
ash_doc_assert_phrase_count \
    "$reverse_revisits_section" \
    '(reversed, earlier_revisits + current_revisits)' 1 \
    "reverse_revisits must retain the result and add earlier and current visits"

ash_doc_assert_word_count \
    "$counted_append_reverse_section" \
    reverse_through_append_with_revisits 2 \
    "counted append reverse must contain only its signature and definition"
ash_doc_assert_phrase_count \
    "$counted_append_reverse_section" \
    'reverse_through_append_with_revisits list = reverse_revisits list' 1 \
    "counted append reverse must return its private helper result directly"

ash_doc_assert_word_count \
    "$fold_left_section" fold_left 4 \
    "fold_left must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$fold_left_section" \
    'fold_left combine accumulated Empty = accumulated' 1 \
    "fold_left must return the accumulator at Empty"
ash_doc_assert_phrase_count \
    "$fold_left_section" \
    'let next_accumulated = combine accumulated first' 1 \
    "fold_left must compute the next accumulator from the current More"
ash_doc_assert_suffix \
    "$fold_left_section" \
    $'fold_left combine accumulated More(first, rest) = {\n    let next_accumulated = combine accumulated first\n    fold_left combine next_accumulated rest\n}' \
    "fold_left must continue with the next accumulator as its final expression"

ash_doc_assert_word_count \
    "$prepend_section" prepend 2 \
    "prepend must contain only its signature and definition"
ash_doc_assert_phrase_count \
    "$prepend_section" \
    'prepend accumulated first = More(first, accumulated)' 1 \
    "prepend must place the current input before the accumulated list"

ash_doc_assert_word_count \
    "$accumulator_reverse_section" reverse_with_accumulator 2 \
    "accumulator reverse must contain only its signature and definition"
ash_doc_assert_phrase_count \
    "$accumulator_reverse_section" 'fold_left prepend Empty list' 1 \
    "accumulator reverse must fold left from Empty with prepend"

ash_doc_assert_word_count \
    "$fold_left_visits_section" fold_left_visits 4 \
    "fold_left_visits must contain only its signature, equations, and one recursive use"
ash_doc_assert_phrase_count \
    "$fold_left_visits_section" \
    'fold_left_visits combine accumulated visits Empty = (accumulated, visits)' 1 \
    "fold_left_visits must return its accumulator and visit count at Empty"
ash_doc_assert_phrase_count \
    "$fold_left_visits_section" \
    'let next_accumulated = combine accumulated first' 1 \
    "fold_left_visits must compute one next accumulator per input More"
ash_doc_assert_suffix \
    "$fold_left_visits_section" \
    $'fold_left_visits combine accumulated visits More(first, rest) = {\n    let next_accumulated = combine accumulated first\n    fold_left_visits combine next_accumulated (visits + 1) rest\n}' \
    "fold_left_visits must increment once before its final recursive expression"
ash_doc_assert_word_count \
    "$counted_accumulator_reverse_section" \
    reverse_with_accumulator_and_visits 2 \
    "counted accumulator reverse must contain only its signature and definition"
ash_doc_assert_phrase_count \
    "$counted_accumulator_reverse_section" \
    'reverse_with_accumulator_and_visits list = fold_left_visits prepend Empty 0 list' 1 \
    "counted accumulator reverse must call its private helper from zero visits"

readonly four_element_list='Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))'
readonly four_element_binding="let numbers = $four_element_list"

ash_doc_assert_phrase_count \
    "$same_result_entry_source" "$four_element_binding" 1 \
    "the same-result entry must bind one four-element list"
ash_doc_assert_phrase_count \
    "$same_result_entry_source" \
    'Lists.reverse_through_append numbers' 1 \
    "the same-result entry must run append reverse on the bound list"
ash_doc_assert_phrase_count \
    "$same_result_entry_source" \
    'Lists.reverse_with_accumulator numbers' 1 \
    "the same-result entry must run accumulator reverse on the bound list"
ash_doc_assert_phrase_count \
    "$counted_entry_source" "$four_element_binding" 1 \
    "the counted entry must bind one four-element list for both algorithms"
ash_doc_assert_phrase_count \
    "$counted_entry_source" \
    'Lists.reverse_through_append_with_revisits numbers' 1 \
    "the counted entry must count append reverse on the shared list"
ash_doc_assert_phrase_count \
    "$counted_entry_source" \
    'Lists.reverse_with_accumulator_and_visits numbers' 1 \
    "the counted entry must count accumulator reverse on the shared list"

ash_doc_assert_phrase_count \
    "$invariant_entry_source" \
    'let processed = Lists.More(1, Lists.More(2, Lists.Empty))' 1 \
    "the invariant entry must bind the processed prefix"
ash_doc_assert_phrase_count \
    "$invariant_entry_source" \
    'let remaining = Lists.More(3, Lists.More(4, Lists.Empty))' 1 \
    "the invariant entry must bind the remaining suffix"
ash_doc_assert_phrase_count \
    "$invariant_entry_source" \
    'let accumulated = Lists.fold_left Lists.prepend Lists.Empty processed' 1 \
    "the invariant entry must derive its accumulator by folding the processed prefix"
ash_doc_assert_phrase_count \
    "$invariant_entry_source" \
    'let complete = Lists.fold_left Lists.prepend accumulated remaining' 1 \
    "the invariant entry must finish by folding the remaining input"
ash_doc_assert_phrase_count \
    "$invariant_entry_source" '(processed, accumulated, complete)' 1 \
    "the invariant entry must retain the prefix, accumulator, and complete result"
ash_doc_assert_phrase_count \
    "$wrong_initial_entry_source" "$four_element_binding" 1 \
    "the wrong-initial entry must bind the four-element list"
ash_doc_assert_phrase_count \
    "$wrong_initial_entry_source" \
    'Lists.fold_left Lists.prepend (Lists.More(99, Lists.Empty)) numbers' 1 \
    "the wrong-initial entry must pass the nonempty list as its initial accumulator"

readonly reversed='More(4, More(3, More(2, More(1, Empty))))'
readonly same_result_output="($reversed, $reversed) : (List<Int>, List<Int>)"
readonly counted_output="(($reversed, 6), ($reversed, 4)) : "\
'((List<Int>, Int), (List<Int>, Int))'
readonly invariant_output='(More(1, More(2, Empty)), '\
'More(2, More(1, Empty)), '\
'More(4, More(3, More(2, More(1, Empty))))) : '\
'(List<Int>, List<Int>, List<Int>)'
readonly wrong_initial_output=\
'More(4, More(3, More(2, More(1, More(99, Empty))))) : List<Int>'

ash_doc_assert_readme_line_once \
    "$same_result_output" \
    "README must display the same-result output exactly once"
ash_doc_assert_readme_line_once \
    "$counted_output" \
    "README must display the counted output exactly once"
ash_doc_assert_readme_line_once \
    "$invariant_output" \
    "README must display the invariant output exactly once"
ash_doc_assert_readme_line_once \
    "$wrong_initial_output" \
    "README must display the wrong-initial output exactly once"

ash_doc_run_accepted \
    "$unit_root" \
    src/01-same-result.ash \
    "$same_result_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/02-counted-work.ash \
    "$counted_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/03-accumulator-invariant.ash \
    "$invariant_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/04-wrong-initial-accumulator.ash \
    "$wrong_initial_output"

ash_doc_finish 5
