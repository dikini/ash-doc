#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/ordered_trees.ash"
readonly lookup_entry="$unit_root/src/01-lookup.ash"
readonly replacement_entry="$unit_root/src/02-replace-and-malformed.ash"
readonly ascending_entry="$unit_root/src/03-ascending.ash"
readonly sources=(
    src/ordered_trees.ash
    src/01-lookup.ash
    src/02-replace-and-malformed.ash
    src/03-ascending.ash
)

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
[[ -f $library ]] ||
    ash_doc_fail "missing canonical source: src/ordered_trees.ash"
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

ash_doc_assert_contains() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail \
            "ash_doc_assert_contains requires source, substring, and claim"
    fi

    local source=$1
    local expected=$2
    local claim=$3

    [[ $source == *"$expected"* ]] || ash_doc_fail "$claim"
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
    'pub type Tree<K, V> =' \
    'pub compare_natural : Natural -> Natural -> Ordering')
compare_natural_section=$(ash_doc_section \
    'pub compare_natural : Natural -> Natural -> Ordering' \
    'pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>')
lookup_section=$(ash_doc_section \
    'pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>' \
    'pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>')
insert_section=$(ash_doc_section \
    'pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>' \
    'pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)')
lookup_counted_section=$(ash_doc_section \
    'pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)' \
    'maximum : Natural -> Natural -> Natural')
maximum_section=$(ash_doc_section \
    'maximum : Natural -> Natural -> Natural' \
    'pub height : Tree<K, V> -> Natural')
height_section=$(ash_doc_section \
    'pub height : Tree<K, V> -> Natural' \
    '')
library_source=$(<"$library")
lookup_entry_source=$(<"$lookup_entry")
replacement_entry_source=$(<"$replacement_entry")
ascending_entry_source=$(<"$ascending_entry")
readonly representations_section compare_natural_section lookup_section
readonly insert_section lookup_counted_section maximum_section height_section
readonly library_source lookup_entry_source replacement_entry_source
readonly ascending_entry_source

readonly expected_representations=$'pub type Tree<K, V> =\n    Empty\n    | Node(Tree<K, V>, K, V, Tree<K, V>)\n\npub type Ordering =\n    Less\n    | Equal\n    | Greater\n\npub type Option<A> =\n    None\n    | Some(A)\n\npub type Natural =\n    Zero\n    | Next(Natural)'
[[ $representations_section == "$expected_representations" ]] ||
    ash_doc_fail \
        "Tree, Ordering, Option, and Natural must retain their exact representations"

ash_doc_assert_phrase_count \
    "$compare_natural_section" \
    'compare_natural Zero Next(right) = Less' 1 \
    "compare_natural must order Zero before every Next value"
ash_doc_assert_phrase_count \
    "$compare_natural_section" \
    'compare_natural Next(left) Next(right) = compare_natural left right' 1 \
    "compare_natural must structurally compare both Next payloads"
ash_doc_assert_phrase_count \
    "$compare_natural_section" 'compare_natural Zero Zero = Equal' 1 \
    "compare_natural must identify two Zero values as equal"
ash_doc_assert_phrase_count \
    "$compare_natural_section" \
    'compare_natural Next(left) Zero = Greater' 1 \
    "compare_natural must order every Next value after Zero"
readonly expected_compare_natural=$'pub compare_natural : Natural -> Natural -> Ordering\ncompare_natural Zero Zero = Equal\ncompare_natural Zero Next(right) = Less\ncompare_natural Next(left) Zero = Greater\ncompare_natural Next(left) Next(right) = compare_natural left right'
[[ $compare_natural_section == "$expected_compare_natural" ]] ||
    ash_doc_fail "compare_natural must retain its exact four equations"

ash_doc_assert_phrase_count \
    "$lookup_section" 'Less => lookup compare query left' 1 \
    "lookup must enter only the left branch after Less"
ash_doc_assert_phrase_count \
    "$lookup_section" 'Greater => lookup compare query right' 1 \
    "lookup must enter only the right branch after Greater"
ash_doc_assert_phrase_count \
    "$lookup_section" 'lookup compare query Empty = None' 1 \
    "lookup must return None at Empty"
ash_doc_assert_phrase_count \
    "$lookup_section" 'match compare query key {' 1 \
    "lookup must compare the query with the current key exactly once"
ash_doc_assert_phrase_count \
    "$lookup_section" 'Equal => Some(value)' 1 \
    "lookup must return the current value after Equal"
ash_doc_assert_word_count \
    "$lookup_section" lookup 5 \
    "lookup must contain its signature, equations, and two recursive uses"
ash_doc_assert_word_count \
    "$lookup_section" compare 5 \
    "lookup must carry one comparator to one current application and two selected recursions"
ash_doc_assert_word_count \
    "$lookup_section" left 2 \
    "lookup must bind the left branch and enter it only after Less"
ash_doc_assert_word_count \
    "$lookup_section" right 2 \
    "lookup must bind the right branch and enter it only after Greater"
ash_doc_assert_word_count \
    "$lookup_section" let 0 \
    "lookup must not eagerly bind either branch result"
readonly expected_lookup=$'pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>\nlookup compare query Empty = None\nlookup compare query Node(left, key, value, right) = match compare query key {\n    Less => lookup compare query left\n    Equal => Some(value)\n    Greater => lookup compare query right\n}'
[[ $lookup_section == "$expected_lookup" ]] ||
    ash_doc_fail "lookup must retain its exact two equations and selected arms"

readonly expected_insert_less='Less => Node(insert compare key value left, current_key, current_value, right)'
ash_doc_assert_phrase_count \
    "$insert_section" "$expected_insert_less" 1 \
    "insert must recurse left and retain the right branch after Less"
ash_doc_assert_phrase_count \
    "$insert_section" 'current_key, value' 1 \
    "insert replacement must retain the stored representative key"
readonly expected_insert_equal='Equal => Node(left, current_key, value, right)'
ash_doc_assert_phrase_count \
    "$insert_section" "$expected_insert_equal" 1 \
    "insert replacement must change only the value and retain both branches"
readonly expected_insert_greater='Greater => Node(left, current_key, current_value, insert compare key value right)'
ash_doc_assert_phrase_count \
    "$insert_section" "$expected_insert_greater" 1 \
    "insert must recurse right and retain the left branch after Greater"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'insert compare key value Empty = Node(Empty, key, value, Empty)' 1 \
    "insert must construct one keyed node at Empty"
ash_doc_assert_phrase_count \
    "$insert_section" 'match compare key current_key {' 1 \
    "insert must compare the incoming key with the stored key exactly once"
readonly expected_insert=$'pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>\ninsert compare key value Empty = Node(Empty, key, value, Empty)\ninsert compare key value Node(left, current_key, current_value, right) = match compare key current_key {\n    Less => Node(insert compare key value left, current_key, current_value, right)\n    Equal => Node(left, current_key, value, right)\n    Greater => Node(left, current_key, current_value, insert compare key value right)\n}'
[[ $insert_section == "$expected_insert" ]] ||
    ash_doc_fail "insert must retain its exact base and three comparison arms"

ash_doc_assert_phrase_count \
    "$lookup_counted_section" \
    'lookup_counted compare query Empty = (None, 0)' 1 \
    "counted lookup must report zero comparisons at Empty"
readonly expected_counted_less=$'Less => {\n        let (found, later_comparisons) = lookup_counted compare query left\n        (found, later_comparisons + 1)\n    }'
ash_doc_assert_contains \
    "$lookup_counted_section" "$expected_counted_less" \
    "counted lookup must add the current Less comparison"
readonly expected_counted_greater=$'Greater => {\n        let (found, later_comparisons) = lookup_counted compare query right\n        (found, later_comparisons + 1)\n    }'
ash_doc_assert_contains \
    "$lookup_counted_section" "$expected_counted_greater" \
    "counted lookup must add the current Greater comparison"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'match compare query key {' 1 \
    "counted lookup must compare the query with the current key exactly once"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'Equal => (Some(value), 1)' 1 \
    "counted lookup must report one comparison at Equal"
ash_doc_assert_word_count \
    "$lookup_counted_section" left 2 \
    "counted lookup must bind and enter the left branch exactly once"
ash_doc_assert_word_count \
    "$lookup_counted_section" right 2 \
    "counted lookup must bind and enter the right branch exactly once"
ash_doc_assert_word_count \
    "$lookup_counted_section" found 4 \
    "counted lookup must bind and return each recursive result exactly once"
ash_doc_assert_word_count \
    "$lookup_counted_section" later_comparisons 4 \
    "counted lookup must bind and increment both recursive counts"
readonly expected_lookup_counted=$'pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)\nlookup_counted compare query Empty = (None, 0)\nlookup_counted compare query Node(left, key, value, right) = match compare query key {\n    Less => {\n        let (found, later_comparisons) = lookup_counted compare query left\n        (found, later_comparisons + 1)\n    }\n    Equal => (Some(value), 1)\n    Greater => {\n        let (found, later_comparisons) = lookup_counted compare query right\n        (found, later_comparisons + 1)\n    }\n}'
[[ $lookup_counted_section == "$expected_lookup_counted" ]] ||
    ash_doc_fail "counted lookup must retain its exact base and selected arms"

ash_doc_assert_phrase_count \
    "$height_section" \
    'height Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))' 1 \
    "height must add one above the maximum of both branch heights"
readonly expected_maximum=$'maximum : Natural -> Natural -> Natural\nmaximum Zero right = right\nmaximum left Zero = left\nmaximum Next(left) Next(right) = Next(maximum left right)'
[[ $maximum_section == "$expected_maximum" ]] ||
    ash_doc_fail "maximum must retain its exact private three equations"
readonly expected_height=$'pub height : Tree<K, V> -> Natural\nheight Empty = Zero\nheight Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))'
[[ $height_section == "$expected_height" ]] ||
    ash_doc_fail "height must retain its exact public two equations"

expected_library="${expected_representations}"$'\n\n'\
"${expected_compare_natural}"$'\n\n'\
"${expected_lookup}"$'\n\n'\
"${expected_insert}"$'\n\n'\
"${expected_lookup_counted}"$'\n\n'\
"${expected_maximum}"$'\n\n'\
"${expected_height}"
readonly expected_library
[[ $library_source == "$expected_library" ]] ||
    ash_doc_fail \
        "ordered_trees.ash must retain its exact complete source"

readonly valid_tree_binding=$'let valid = Trees.Node(\n        Trees.Node(Trees.Empty, one, 10, Trees.Empty),\n        two,\n        20,\n        Trees.Node(Trees.Empty, three, 30, Trees.Empty)\n    )'
readonly valid_lookup_calls=$'(\n        Trees.lookup_counted Trees.compare_natural three valid,\n        Trees.lookup_counted Trees.compare_natural Trees.Zero valid\n    )'
for natural_binding in \
    'let one = Trees.Next(Trees.Zero)' \
    'let two = Trees.Next(one)' \
    'let three = Trees.Next(two)'; do
    ash_doc_assert_phrase_count \
        "$lookup_entry_source" "$natural_binding" 1 \
        "the lookup entry must retain each exact unary key binding"
done
ash_doc_assert_contains \
    "$lookup_entry_source" "$valid_tree_binding" \
    "the lookup entry must retain its exact valid balanced tree"
ash_doc_assert_contains \
    "$lookup_entry_source" "$valid_lookup_calls" \
    "the lookup entry must run both counted queries on the same valid tree"
ash_doc_assert_phrase_count \
    "$lookup_entry_source" 'let valid = Trees.Node(' 1 \
    "the lookup entry must bind exactly one observed tree"
ash_doc_assert_word_count \
    "$lookup_entry_source" lookup_counted 2 \
    "the lookup entry must run exactly two counted lookups"
readonly expected_lookup_entry=$'import ordered_trees as Trees\n\nmain : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))\nmain () = {\n    let one = Trees.Next(Trees.Zero)\n    let two = Trees.Next(one)\n    let three = Trees.Next(two)\n    let valid = Trees.Node(\n        Trees.Node(Trees.Empty, one, 10, Trees.Empty),\n        two,\n        20,\n        Trees.Node(Trees.Empty, three, 30, Trees.Empty)\n    )\n    (\n        Trees.lookup_counted Trees.compare_natural three valid,\n        Trees.lookup_counted Trees.compare_natural Trees.Zero valid\n    )\n}'
[[ $lookup_entry_source == "$expected_lookup_entry" ]] ||
    ash_doc_fail "the lookup entry must retain its exact complete source"

readonly malformed_binding=$'let malformed = Trees.Node(\n        Trees.Node(Trees.Empty, two, 20, Trees.Empty),\n        one,\n        10,\n        Trees.Empty\n    )'
readonly replacement_calls=$'(\n        Trees.lookup Trees.compare_natural one original,\n        Trees.lookup Trees.compare_natural one replaced,\n        Trees.lookup Trees.compare_natural two malformed\n    )'
ash_doc_assert_contains \
    "$replacement_entry_source" "$malformed_binding" \
    "the malformed entry must place two in the left branch of one"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'Trees.lookup Trees.compare_natural two malformed' 1 \
    "the malformed observation must query its misplaced key two"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'let with_two = Trees.insert Trees.compare_natural two 20 Trees.Empty' 1 \
    "the replacement entry must first insert two into Empty"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'let original = Trees.insert Trees.compare_natural one 10 with_two' 1 \
    "the replacement entry must derive original by inserting one"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'let replaced = Trees.insert Trees.compare_natural one 99 original' 1 \
    "the replacement entry must derive replaced from retained original"
ash_doc_assert_contains \
    "$replacement_entry_source" "$replacement_calls" \
    "the replacement entry must observe original, replaced, then malformed"
readonly expected_replacement_entry=$'import ordered_trees as Trees\n\nmain : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)\nmain () = {\n    let one = Trees.Next(Trees.Zero)\n    let two = Trees.Next(one)\n    let with_two = Trees.insert Trees.compare_natural two 20 Trees.Empty\n    let original = Trees.insert Trees.compare_natural one 10 with_two\n    let replaced = Trees.insert Trees.compare_natural one 99 original\n    let malformed = Trees.Node(\n        Trees.Node(Trees.Empty, two, 20, Trees.Empty),\n        one,\n        10,\n        Trees.Empty\n    )\n    (\n        Trees.lookup Trees.compare_natural one original,\n        Trees.lookup Trees.compare_natural one replaced,\n        Trees.lookup Trees.compare_natural two malformed\n    )\n}'
[[ $replacement_entry_source == "$expected_replacement_entry" ]] ||
    ash_doc_fail \
        "the replacement and malformed entry must retain its exact complete source"

ash_doc_assert_phrase_count \
    "$ascending_entry_source" \
    'let after_one = Trees.insert Trees.compare_natural one 10 Trees.Empty' 1 \
    "the ascending entry must insert one before two"
ash_doc_assert_phrase_count \
    "$ascending_entry_source" \
    'let after_two = Trees.insert Trees.compare_natural two 20 after_one' 1 \
    "the ascending entry must insert two after one"
ash_doc_assert_phrase_count \
    "$ascending_entry_source" \
    'let after_three = Trees.insert Trees.compare_natural three 30 after_two' 1 \
    "the ascending entry must insert three after two"
readonly ascending_calls=$'(\n        after_three,\n        Trees.height after_three,\n        Trees.lookup_counted Trees.compare_natural three after_three\n    )'
ash_doc_assert_contains \
    "$ascending_entry_source" "$ascending_calls" \
    "the ascending entry must observe one after_three value in all positions"
readonly expected_ascending_entry=$'import ordered_trees as Trees\n\nmain : Unit -> (Trees.Tree<Trees.Natural, Int>, Trees.Natural, (Trees.Option<Int>, Int))\nmain () = {\n    let one = Trees.Next(Trees.Zero)\n    let two = Trees.Next(one)\n    let three = Trees.Next(two)\n    let after_one = Trees.insert Trees.compare_natural one 10 Trees.Empty\n    let after_two = Trees.insert Trees.compare_natural two 20 after_one\n    let after_three = Trees.insert Trees.compare_natural three 30 after_two\n    (\n        after_three,\n        Trees.height after_three,\n        Trees.lookup_counted Trees.compare_natural three after_three\n    )\n}'
[[ $ascending_entry_source == "$expected_ascending_entry" ]] ||
    ash_doc_fail "the ascending entry must retain its exact complete source"

readonly lookup_output='((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))'
readonly replacement_output='(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)'
readonly ascending_output='(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : '\
'(Tree<Natural, Int>, Natural, (Option<Int>, Int))'

ash_doc_assert_text_line_once \
    "$lookup_output" \
    "README must display the valid lookup output exactly once"
ash_doc_assert_text_line_once \
    "$replacement_output" \
    "README must display the replacement and malformed output exactly once"
ash_doc_assert_text_line_once \
    "$ascending_output" \
    "README must display the ascending insertion output exactly once"

ash_doc_run_accepted \
    "$unit_root" \
    src/01-lookup.ash \
    "$lookup_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/02-replace-and-malformed.ash \
    "$replacement_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/03-ascending.ash \
    "$ascending_output"

ash_doc_finish 4
