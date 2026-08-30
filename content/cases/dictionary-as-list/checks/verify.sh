#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/dictionaries.ash"
readonly ordinary_entry="$unit_root/src/01-ordinary-lookup.ash"
readonly counted_entry="$unit_root/src/02-counted-lookup.ash"
readonly fold_entry="$unit_root/src/03-selective-and-fold.ash"
readonly retained_entry="$unit_root/src/04-retained-versions.ash"
readonly sources=(
    src/dictionaries.ash
    src/01-ordinary-lookup.ash
    src/02-counted-lookup.ash
    src/03-selective-and-fold.ash
    src/04-retained-versions.ash
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

ash_doc_assert_text_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail \
            "ash_doc_assert_text_line_once requires expected line and claim"
    fi

    local expected_line=$1
    local claim=$2
    local actual_count
    actual_count=$(
        awk -v expected="$expected_line" '
            $0 == "```text" { inside = 1; next }
            inside && $0 == "```" { inside = 0; next }
            inside && $0 == expected { count += 1 }
            END { print count + 0 }
        ' "$readme"
    )

    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected 1)"
}

representations_section=$(ash_doc_section \
    'pub type Entry<K, V> =' \
    'pub empty : Unit -> Dictionary<K, V>')
empty_section=$(ash_doc_section \
    'pub empty : Unit -> Dictionary<K, V>' \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>')
insert_section=$(ash_doc_section \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>' \
    'pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>')
lookup_section=$(ash_doc_section \
    'pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>' \
    'pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)')
lookup_counted_section=$(ash_doc_section \
    'pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)' \
    'fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B')
fold_entries_section=$(ash_doc_section \
    'fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B' \
    'prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)')
prefer_current_section=$(ash_doc_section \
    'prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)' \
    'pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)')
fold_wrapper_section=$(ash_doc_section \
    'pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)' \
    '')
ordinary_entry_source=$(<"$ordinary_entry")
counted_entry_source=$(<"$counted_entry")
fold_entry_source=$(<"$fold_entry")
retained_entry_source=$(<"$retained_entry")
readonly representations_section empty_section insert_section lookup_section
readonly lookup_counted_section fold_entries_section prefer_current_section
readonly fold_wrapper_section ordinary_entry_source counted_entry_source
readonly fold_entry_source retained_entry_source

readonly expected_representations=$'pub type Entry<K, V> =\n    Entry(K, V)\n\npub type Dictionary<K, V> =\n    Empty\n    | More(Entry<K, V>, Dictionary<K, V>)\n\npub type Option<A> =\n    None\n    | Some(A)'
[[ $representations_section == "$expected_representations" ]] ||
    ash_doc_fail \
        "Entry, Dictionary, and Option must retain their exact representations"

ash_doc_assert_phrase_count \
    "$empty_section" 'empty () = Empty' 1 \
    "empty must construct Empty"

ash_doc_assert_word_count \
    "$insert_section" insert 2 \
    "insert must contain only its signature and definition"
ash_doc_assert_word_count \
    "$insert_section" Entry 1 \
    "insert must construct exactly one Entry"
ash_doc_assert_word_count \
    "$insert_section" More 1 \
    "insert must construct exactly one front More"
ash_doc_assert_word_count \
    "$insert_section" same_key 0 \
    "insert must not compare keys"
ash_doc_assert_word_count \
    "$insert_section" lookup 0 \
    "insert must not perform lookup"
ash_doc_assert_word_count \
    "$insert_section" fold_entries 0 \
    "insert must not fold entries"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'insert key value dictionary = More(Entry(key, value), dictionary)' 1 \
    "insert must place the prior dictionary directly behind the new entry"

ash_doc_assert_word_count \
    "$lookup_section" lookup 4 \
    "ordinary lookup must contain its signature, equations, and one recursive use"
ash_doc_assert_word_count \
    "$lookup_section" same_key 4 \
    "ordinary lookup must carry equality through its equations and recursive use"
ash_doc_assert_phrase_count \
    "$lookup_section" 'lookup same_key query Empty = None' 1 \
    "ordinary lookup must return None at Empty"
ash_doc_assert_phrase_count \
    "$lookup_section" 'match same_key query key {' 1 \
    "ordinary lookup must apply equality once at the current entry"
ash_doc_assert_phrase_count \
    "$lookup_section" 'true => Some(value)' 1 \
    "ordinary lookup must return the current value after a match"
ash_doc_assert_phrase_count \
    "$lookup_section" 'false => lookup same_key query rest' 1 \
    "ordinary lookup must recurse only after a mismatch"

ash_doc_assert_word_count \
    "$lookup_counted_section" lookup_counted 4 \
    "counted lookup must contain its signature, equations, and one recursive use"
ash_doc_assert_word_count \
    "$lookup_counted_section" same_key 4 \
    "counted lookup must carry equality through its equations and recursive use"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'lookup_counted same_key query Empty = (None, 0)' 1 \
    "counted lookup must return None and zero comparisons at Empty"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'match same_key query key {' 1 \
    "counted lookup must apply equality once at the current entry"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'true => (Some(value), 1)' 1 \
    "counted lookup must count one comparison at a current match"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" \
    'let (found, later_comparisons) = lookup_counted same_key query rest' 1 \
    "counted lookup must recurse and bind its results only after a mismatch"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" '(found, later_comparisons + 1)' 1 \
    "counted lookup must count the current mismatch"
ash_doc_assert_suffix \
    "$lookup_counted_section" \
    $'lookup_counted same_key query More(Entry(key, value), rest) = match same_key query key {\n    true => (Some(value), 1)\n    false => {\n        let (found, later_comparisons) = lookup_counted same_key query rest\n        (found, later_comparisons + 1)\n    }\n}' \
    "counted lookup must keep its recursive binding inside the false arm"

ash_doc_assert_word_count \
    "$fold_entries_section" fold_entries 4 \
    "fold_entries must contain its signature, equations, and one recursive use"
ash_doc_assert_word_count \
    "$fold_entries_section" combine 4 \
    "fold_entries must carry its combiner through both equations and both uses"
ash_doc_assert_phrase_count \
    "$fold_entries_section" \
    'let folded_rest = fold_entries combine base rest' 1 \
    "fold_entries must obtain the complete folded rest exactly once"
ash_doc_assert_phrase_count \
    "$fold_entries_section" 'combine entry folded_rest' 1 \
    "fold_entries must combine the current entry with the folded rest"
ash_doc_assert_suffix \
    "$fold_entries_section" \
    $'fold_entries combine base More(entry, rest) = {\n    let folded_rest = fold_entries combine base rest\n    combine entry folded_rest\n}' \
    "fold_entries must bind the folded rest before its final combine"

ash_doc_assert_word_count \
    "$prefer_current_section" prefer_current 2 \
    "prefer_current must contain only its signature and definition"
ash_doc_assert_word_count \
    "$prefer_current_section" same_key 2 \
    "prefer_current must apply equality once"
ash_doc_assert_phrase_count \
    "$prefer_current_section" 'match same_key query key {' 1 \
    "prefer_current must compare the query with the current key"
ash_doc_assert_phrase_count \
    "$prefer_current_section" 'true => (Some(value), comparisons + 1)' 1 \
    "prefer_current must replace an older result with the current match"
ash_doc_assert_phrase_count \
    "$prefer_current_section" 'false => (found, comparisons + 1)' 1 \
    "prefer_current must retain the folded result after a mismatch"
ash_doc_assert_phrase_count \
    "$prefer_current_section" 'comparisons + 1' 2 \
    "prefer_current must count each current equality application"

ash_doc_assert_word_count \
    "$fold_wrapper_section" lookup_through_fold_counted 2 \
    "fold lookup must contain only its signature and definition"
ash_doc_assert_word_count \
    "$fold_wrapper_section" fold_entries 1 \
    "fold lookup must invoke fold_entries exactly once"
ash_doc_assert_word_count \
    "$fold_wrapper_section" prefer_current 1 \
    "fold lookup must invoke prefer_current exactly once"
ash_doc_assert_phrase_count \
    "$fold_wrapper_section" \
    'fold_entries (prefer_current same_key query) (None, 0) dictionary' 1 \
    "fold lookup must fold from an absent result and zero comparisons"

for complete_entry_source in \
    "$ordinary_entry_source" \
    "$counted_entry_source" \
    "$fold_entry_source" \
    "$retained_entry_source"; do
    ash_doc_assert_phrase_count \
        "$complete_entry_source" 'int_equal left right = left == right' 1 \
        "every entry must define integer equality exactly once"
    ash_doc_assert_word_count \
        "$complete_entry_source" int_equal 4 \
        "every entry must have an equality signature, definition, and two calls"
done

readonly common_chain=$'let empty_dictionary = Dictionaries.empty ()\n    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary\n    let second_dictionary = Dictionaries.insert 2 20 first_dictionary\n    let dictionary = Dictionaries.insert 1 11 second_dictionary'
for front_shadowing_entry_source in \
    "$ordinary_entry_source" \
    "$counted_entry_source" \
    "$fold_entry_source"; do
    ash_doc_assert_phrase_count \
        "$front_shadowing_entry_source" \
        'let empty_dictionary = Dictionaries.empty ()' 1 \
        "each front-shadowing entry must bind one empty dictionary"
    ash_doc_assert_phrase_count \
        "$front_shadowing_entry_source" \
        'let first_dictionary = Dictionaries.insert 1 10 empty_dictionary' 1 \
        "each front-shadowing entry must insert the first binding once"
    ash_doc_assert_phrase_count \
        "$front_shadowing_entry_source" \
        'let second_dictionary = Dictionaries.insert 2 20 first_dictionary' 1 \
        "each front-shadowing entry must insert the second binding once"
    ash_doc_assert_phrase_count \
        "$front_shadowing_entry_source" \
        'let dictionary = Dictionaries.insert 1 11 second_dictionary' 1 \
        "each front-shadowing entry must insert the shadowing binding once"
    [[ $front_shadowing_entry_source == *"$common_chain"* ]] ||
        ash_doc_fail \
            "each front-shadowing entry must retain the ordered insertion chain"
done

readonly retained_chain=$'let empty_dictionary = Dictionaries.empty ()\n    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary\n    let older_dictionary = Dictionaries.insert 2 20 first_dictionary\n    let newer_dictionary = Dictionaries.insert 1 11 older_dictionary'
ash_doc_assert_phrase_count \
    "$retained_entry_source" \
    'let empty_dictionary = Dictionaries.empty ()' 1 \
    "the retained-version entry must bind one empty dictionary"
ash_doc_assert_phrase_count \
    "$retained_entry_source" \
    'let first_dictionary = Dictionaries.insert 1 10 empty_dictionary' 1 \
    "the retained-version entry must insert the first binding once"
ash_doc_assert_phrase_count \
    "$retained_entry_source" \
    'let older_dictionary = Dictionaries.insert 2 20 first_dictionary' 1 \
    "the retained-version entry must bind its older dictionary once"
ash_doc_assert_phrase_count \
    "$retained_entry_source" \
    'let newer_dictionary = Dictionaries.insert 1 11 older_dictionary' 1 \
    "the retained-version entry must use the older dictionary as the new tail"
[[ $retained_entry_source == *"$retained_chain"* ]] ||
    ash_doc_fail \
        "the retained-version entry must retain the ordered insertion chain"

ash_doc_assert_phrase_count \
    "$fold_entry_source" \
    'Dictionaries.lookup_counted int_equal 1 dictionary' 1 \
    "the comparison entry must run selective lookup on query 1 and dictionary"
ash_doc_assert_phrase_count \
    "$fold_entry_source" \
    'Dictionaries.lookup_through_fold_counted int_equal 1 dictionary' 1 \
    "the comparison entry must fold the same query and dictionary"
ash_doc_assert_phrase_count \
    "$retained_entry_source" \
    'Dictionaries.lookup_counted int_equal 1 older_dictionary' 1 \
    "the retained-version entry must look up the older dictionary"
ash_doc_assert_phrase_count \
    "$retained_entry_source" \
    'Dictionaries.lookup_counted int_equal 1 newer_dictionary' 1 \
    "the retained-version entry must look up the newer dictionary"

readonly ordinary_output='(Some(11), None) : (Option<Int>, Option<Int>)'
readonly counted_output='((Some(11), 1), (None, 3)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'
readonly fold_output='((Some(11), 1), (Some(11), 3)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'
readonly retained_output='((Some(10), 2), (Some(11), 1)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'

ash_doc_assert_text_line_once \
    "$ordinary_output" \
    "README must display the ordinary lookup output exactly once"
ash_doc_assert_text_line_once \
    "$counted_output" \
    "README must display the counted lookup output exactly once"
ash_doc_assert_text_line_once \
    "$fold_output" \
    "README must display the selective-and-fold output exactly once"
ash_doc_assert_text_line_once \
    "$retained_output" \
    "README must display the retained-version output exactly once"

ash_doc_run_accepted \
    "$unit_root" \
    src/01-ordinary-lookup.ash \
    "$ordinary_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/02-counted-lookup.ash \
    "$counted_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/03-selective-and-fold.ash \
    "$fold_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/04-retained-versions.ash \
    "$retained_output"

ash_doc_finish 5
