#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/trees.ash"
readonly size_map_entry="$unit_root/src/01-size-and-map.ash"
readonly shapes_entry="$unit_root/src/02-balanced-and-skewed.ash"
readonly search_entry="$unit_root/src/03-selective-and-fold.ash"
readonly sources=(
    src/trees.ash
    src/01-size-and-map.ash
    src/02-balanced-and-skewed.ash
    src/03-selective-and-fold.ash
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
    'pub type Tree<A> =' \
    'pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B')
fold_tree_section=$(ash_doc_section \
    'pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B' \
    'pub size : Tree<A> -> Int')
size_section=$(ash_doc_section \
    'pub size : Tree<A> -> Int' \
    'pub map_tree : (A -> B) -> Tree<A> -> Tree<B>')
map_tree_section=$(ash_doc_section \
    'pub map_tree : (A -> B) -> Tree<A> -> Tree<B>' \
    'maximum : Natural -> Natural -> Natural')
maximum_section=$(ash_doc_section \
    'maximum : Natural -> Natural -> Natural' \
    'pub nodes_and_height : Tree<A> -> (Int, Natural)')
nodes_and_height_section=$(ash_doc_section \
    'pub nodes_and_height : Tree<A> -> (Int, Natural)' \
    'pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)')
find_counted_section=$(ash_doc_section \
    'pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)' \
    'choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)')
choose_counted_section=$(ash_doc_section \
    'choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)' \
    'pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)')
fold_wrapper_section=$(ash_doc_section \
    'pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)' \
    '')
size_map_entry_source=$(<"$size_map_entry")
shapes_entry_source=$(<"$shapes_entry")
search_entry_source=$(<"$search_entry")
readonly representations_section fold_tree_section size_section
readonly map_tree_section maximum_section nodes_and_height_section
readonly find_counted_section choose_counted_section fold_wrapper_section
readonly size_map_entry_source shapes_entry_source search_entry_source

readonly expected_representations=$'pub type Tree<A> =\n    Empty\n    | Node(Tree<A>, A, Tree<A>)\n\npub type Natural =\n    Zero\n    | Next(Natural)\n\npub type Option<A> =\n    None\n    | Some(A)'
[[ $representations_section == "$expected_representations" ]] ||
    ash_doc_fail \
        "Tree, Natural, and Option must retain their exact representations"

ash_doc_assert_word_count \
    "$fold_tree_section" fold_tree 5 \
    "fold_tree must contain its signature, equations, and two recursive uses"
ash_doc_assert_word_count \
    "$fold_tree_section" combine 5 \
    "fold_tree must carry its combiner through both equations and all uses"
ash_doc_assert_word_count \
    "$fold_tree_section" base 5 \
    "fold_tree must carry its base through both equations and both branches"
ash_doc_assert_word_count \
    "$fold_tree_section" folded_left 2 \
    "fold_tree must bind and combine exactly one left result"
ash_doc_assert_word_count \
    "$fold_tree_section" folded_right 2 \
    "fold_tree must bind and combine exactly one right result"
ash_doc_assert_phrase_count \
    "$fold_tree_section" 'fold_tree combine base Empty = base' 1 \
    "fold_tree must return base at Empty"
ash_doc_assert_phrase_count \
    "$fold_tree_section" \
    'let folded_left = fold_tree combine base left' 1 \
    "fold_tree must fold left exactly once before folding right"
ash_doc_assert_phrase_count \
    "$fold_tree_section" \
    'let folded_right = fold_tree combine base right' 1 \
    "fold_tree must fold right exactly once before combining"
ash_doc_assert_phrase_count \
    "$fold_tree_section" 'combine folded_left value folded_right' 1 \
    "fold_tree must combine the two branch results with the current value"
ash_doc_assert_suffix \
    "$fold_tree_section" \
    $'fold_tree combine base Node(left, value, right) = {\n    let folded_left = fold_tree combine base left\n    let folded_right = fold_tree combine base right\n    combine folded_left value folded_right\n}' \
    "fold_tree must bind left then right before its final combine"

ash_doc_assert_word_count \
    "$size_section" size 2 \
    "size must contain only its signature and definition"
ash_doc_assert_word_count \
    "$size_section" fold_tree 1 \
    "size must invoke fold_tree exactly once"
ash_doc_assert_word_count \
    "$size_section" left_size 2 \
    "size must bind and use its left result exactly once"
ash_doc_assert_word_count \
    "$size_section" right_size 2 \
    "size must bind and use its right result exactly once"
ash_doc_assert_phrase_count \
    "$size_section" 'left_size + right_size + 1' 1 \
    "size must add the current Node exactly once"
ash_doc_assert_suffix \
    "$size_section" '}) 0 tree' \
    "size must use zero as its Empty result"

ash_doc_assert_word_count \
    "$map_tree_section" map_tree 2 \
    "map_tree must contain only its signature and definition"
ash_doc_assert_word_count \
    "$map_tree_section" fold_tree 1 \
    "map_tree must invoke fold_tree exactly once"
ash_doc_assert_word_count \
    "$map_tree_section" transform 2 \
    "map_tree must apply its transformation once"
ash_doc_assert_word_count \
    "$map_tree_section" mapped_left 2 \
    "map_tree must bind and use its mapped left result exactly once"
ash_doc_assert_word_count \
    "$map_tree_section" mapped_right 2 \
    "map_tree must bind and use its mapped right result exactly once"
ash_doc_assert_word_count \
    "$map_tree_section" Node 1 \
    "map_tree must construct exactly one Node per combiner application"
ash_doc_assert_word_count \
    "$map_tree_section" Empty 1 \
    "map_tree must use Empty as its base"
ash_doc_assert_phrase_count \
    "$map_tree_section" \
    'Node(mapped_left, transform value, mapped_right)' 1 \
    "map_tree must preserve left and right mapped positions"
ash_doc_assert_suffix \
    "$map_tree_section" '}) Empty tree' \
    "map_tree must use Empty as its Empty result"

ash_doc_assert_phrase_count \
    "$maximum_section" \
    'maximum Next(left) Next(right) = Next(maximum left right)' 1 \
    "maximum must decrease both nonzero heights together"
readonly expected_maximum=$'maximum : Natural -> Natural -> Natural\nmaximum Zero right = right\nmaximum left Zero = left\nmaximum Next(left) Next(right) = Next(maximum left right)'
[[ $maximum_section == "$expected_maximum" ]] ||
    ash_doc_fail "maximum must retain its exact three equations"
ash_doc_assert_word_count \
    "$maximum_section" maximum 5 \
    "maximum must contain its signature, equations, and recursive use"
ash_doc_assert_word_count \
    "$maximum_section" Natural 3 \
    "maximum must retain its Natural signature"
ash_doc_assert_word_count \
    "$maximum_section" Zero 2 \
    "maximum must cover zero on either side"
ash_doc_assert_word_count \
    "$maximum_section" Next 3 \
    "maximum must match and rebuild nonzero heights"
ash_doc_assert_word_count \
    "$maximum_section" left 4 \
    "maximum must retain the left height through its equations"
ash_doc_assert_word_count \
    "$maximum_section" right 4 \
    "maximum must retain the right height through its equations"

ash_doc_assert_phrase_count \
    "$nodes_and_height_section" \
    'Next(maximum left_height right_height)' 1 \
    "nodes_and_height must add one level above the greater branch height"
ash_doc_assert_phrase_count \
    "$nodes_and_height_section" 'left_nodes + right_nodes + 1' 1 \
    "nodes_and_height must add the current Node exactly once"
ash_doc_assert_suffix \
    "$nodes_and_height_section" '}) (0, Zero) tree' \
    "nodes_and_height must use zero nodes and zero height at Empty"
ash_doc_assert_word_count \
    "$nodes_and_height_section" nodes_and_height 2 \
    "nodes_and_height must contain only its signature and definition"
ash_doc_assert_word_count \
    "$nodes_and_height_section" fold_tree 1 \
    "nodes_and_height must invoke fold_tree exactly once"
for summary_word in left_summary right_summary left_nodes right_nodes \
    left_height right_height; do
    ash_doc_assert_word_count \
        "$nodes_and_height_section" "$summary_word" 2 \
        "nodes_and_height must bind and use $summary_word exactly once"
done
ash_doc_assert_word_count \
    "$nodes_and_height_section" Next 1 \
    "nodes_and_height must add exactly one height level per Node"
ash_doc_assert_word_count \
    "$nodes_and_height_section" maximum 1 \
    "nodes_and_height must compare branch heights exactly once"
ash_doc_assert_word_count \
    "$nodes_and_height_section" Zero 1 \
    "nodes_and_height must use zero height exactly once"
ash_doc_assert_word_count \
    "$nodes_and_height_section" ignored 1 \
    "nodes_and_height must ignore each current value"

ash_doc_assert_phrase_count \
    "$find_counted_section" 'find_counted matches Empty = (None, 0)' 1 \
    "direct search must return absence with zero visits at Empty"
ash_doc_assert_phrase_count \
    "$find_counted_section" 'match matches value {' 1 \
    "direct search must apply its predicate at the current Node"
ash_doc_assert_phrase_count \
    "$find_counted_section" 'true => (Some(value), 1)' 1 \
    "direct search must return the current match after one visit"
ash_doc_assert_phrase_count \
    "$find_counted_section" \
    'let (left_found, left_visits) = find_counted matches left' 1 \
    "direct search must recurse left after a current mismatch"
ash_doc_assert_phrase_count \
    "$find_counted_section" \
    'Some(found) => (Some(found), left_visits + 1)' 1 \
    "direct search must count the current mismatch before returning a left match"
ash_doc_assert_phrase_count \
    "$find_counted_section" \
    'let (right_found, right_visits) = find_counted matches right' 1 \
    "direct search must recurse right after left absence"
ash_doc_assert_phrase_count \
    "$find_counted_section" \
    '(right_found, left_visits + right_visits + 1)' 1 \
    "direct search must include right visits and the current mismatch"
ash_doc_assert_suffix \
    "$find_counted_section" \
    $'find_counted matches Node(left, value, right) = match matches value {\n    true => (Some(value), 1)\n    false => {\n        let (left_found, left_visits) = find_counted matches left\n        match left_found {\n            Some(found) => (Some(found), left_visits + 1)\n            None => {\n                let (right_found, right_visits) = find_counted matches right\n                (right_found, left_visits + right_visits + 1)\n            }\n        }\n    }\n}' \
    "direct search must recurse right only after left absence"
ash_doc_assert_word_count \
    "$find_counted_section" find_counted 5 \
    "direct search must contain its signature, equations, and two recursive uses"
ash_doc_assert_word_count \
    "$find_counted_section" matches 5 \
    "direct search must carry its predicate through equations and calls"
ash_doc_assert_word_count \
    "$find_counted_section" left_found 2 \
    "direct search must inspect its left result exactly once"
ash_doc_assert_word_count \
    "$find_counted_section" right_found 2 \
    "direct search must return its right result exactly once"
ash_doc_assert_word_count \
    "$find_counted_section" left_visits 3 \
    "direct search must count left visits on both continuation paths"
ash_doc_assert_word_count \
    "$find_counted_section" right_visits 2 \
    "direct search must bind and count right visits exactly once"
ash_doc_assert_word_count \
    "$find_counted_section" Some 3 \
    "direct search must construct and inspect present results"
ash_doc_assert_word_count \
    "$find_counted_section" None 2 \
    "direct search must construct and inspect absent results"

ash_doc_assert_phrase_count \
    "$choose_counted_section" \
    'let visits = left_visits + right_visits + 1' 1 \
    "folded search must count the current Node"
ash_doc_assert_phrase_count \
    "$choose_counted_section" 'match matches value {' 1 \
    "folded search must apply its predicate at every current Node"
ash_doc_assert_phrase_count \
    "$choose_counted_section" \
    'Some(found) => (Some(found), visits)' 1 \
    "folded search must prefer a found left result after a current mismatch"
ash_doc_assert_phrase_count \
    "$choose_counted_section" 'true => (Some(value), visits)' 1 \
    "folded search must prefer a current match"
ash_doc_assert_phrase_count \
    "$choose_counted_section" 'None => (right_found, visits)' 1 \
    "folded search must choose the right result after left absence"
ash_doc_assert_suffix \
    "$choose_counted_section" \
    $'choose_counted matches (left_found, left_visits) value (right_found, right_visits) = {\n    let visits = left_visits + right_visits + 1\n    match matches value {\n        true => (Some(value), visits)\n        false => match left_found {\n            Some(found) => (Some(found), visits)\n            None => (right_found, visits)\n        }\n    }\n}' \
    "folded search must retain current-left-right result priority"
ash_doc_assert_word_count \
    "$choose_counted_section" choose_counted 2 \
    "choose_counted must contain only its signature and definition"
ash_doc_assert_word_count \
    "$choose_counted_section" matches 2 \
    "choose_counted must apply its predicate once"
for result_word in left_found right_found left_visits right_visits; do
    ash_doc_assert_word_count \
        "$choose_counted_section" "$result_word" 2 \
        "choose_counted must bind and use $result_word exactly once"
done
ash_doc_assert_word_count \
    "$choose_counted_section" visits 4 \
    "choose_counted must return the complete visit count on every path"
ash_doc_assert_word_count \
    "$choose_counted_section" Some 3 \
    "choose_counted must construct and inspect present results"
ash_doc_assert_word_count \
    "$choose_counted_section" None 1 \
    "choose_counted must inspect left absence once"

ash_doc_assert_word_count \
    "$fold_wrapper_section" find_through_fold_counted 2 \
    "folded search wrapper must contain only its signature and definition"
ash_doc_assert_word_count \
    "$fold_wrapper_section" fold_tree 1 \
    "folded search wrapper must invoke fold_tree exactly once"
ash_doc_assert_word_count \
    "$fold_wrapper_section" choose_counted 1 \
    "folded search wrapper must invoke choose_counted exactly once"
ash_doc_assert_word_count \
    "$fold_wrapper_section" matches 2 \
    "folded search wrapper must pass its predicate once"
ash_doc_assert_word_count \
    "$fold_wrapper_section" None 1 \
    "folded search wrapper must start with an absent result"
ash_doc_assert_phrase_count \
    "$fold_wrapper_section" \
    'fold_tree (choose_counted matches) (None, 0) tree' 1 \
    "folded search wrapper must fold from absence and zero visits"
readonly expected_fold_wrapper=$'pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)\nfind_through_fold_counted matches tree = fold_tree (choose_counted matches) (None, 0) tree'
[[ $fold_wrapper_section == "$expected_fold_wrapper" ]] ||
    ash_doc_fail "folded search wrapper must retain its exact two-line form"

ash_doc_assert_word_count \
    "$size_map_entry_source" Node 3 \
    "the size-and-map entry must build exactly three Nodes"
ash_doc_assert_word_count \
    "$size_map_entry_source" Empty 4 \
    "the size-and-map entry must close exactly four empty branches"
ash_doc_assert_word_count \
    "$size_map_entry_source" tree 3 \
    "the size-and-map entry must bind and use one tree twice"
ash_doc_assert_word_count \
    "$size_map_entry_source" size 1 \
    "the size-and-map entry must call size exactly once"
ash_doc_assert_word_count \
    "$size_map_entry_source" map_tree 1 \
    "the size-and-map entry must call map_tree exactly once"
ash_doc_assert_word_count \
    "$size_map_entry_source" increment 3 \
    "the size-and-map entry must define and pass increment once"
readonly balanced_tree_binding=$'let tree = Trees.Node(\n        Trees.Node(Trees.Empty, 1, Trees.Empty),\n        2,\n        Trees.Node(Trees.Empty, 3, Trees.Empty)\n    )'
ash_doc_assert_contains \
    "$size_map_entry_source" "$balanced_tree_binding" \
    "the size-and-map entry must retain its exact balanced tree"
ash_doc_assert_phrase_count \
    "$size_map_entry_source" 'Trees.size tree' 1 \
    "the size-and-map entry must measure its tree"
ash_doc_assert_phrase_count \
    "$size_map_entry_source" 'Trees.map_tree increment tree' 1 \
    "the size-and-map entry must map the same tree"
ash_doc_assert_phrase_count \
    "$size_map_entry_source" \
    '(Trees.size tree, Trees.map_tree increment tree)' 1 \
    "the size-and-map entry must return size before its mapped tree"

readonly balanced_shape_binding=$'let balanced = Trees.Node(\n        Trees.Node(Trees.Empty, 1, Trees.Empty),\n        2,\n        Trees.Node(Trees.Empty, 3, Trees.Empty)\n    )'
readonly skewed_shape_binding=$'let skewed = Trees.Node(\n        Trees.Empty,\n        1,\n        Trees.Node(\n            Trees.Empty,\n            2,\n            Trees.Node(Trees.Empty, 3, Trees.Empty)\n        )\n    )'
readonly shape_calls=$'(\n        Trees.nodes_and_height balanced,\n        Trees.nodes_and_height skewed\n    )'
ash_doc_assert_contains \
    "$shapes_entry_source" "$balanced_shape_binding" \
    "the shape entry must retain its exact balanced three-node tree"
ash_doc_assert_contains \
    "$shapes_entry_source" "$skewed_shape_binding" \
    "the skewed entry must retain its exact three-node right chain"
ash_doc_assert_word_count \
    "$shapes_entry_source" Node 6 \
    "the shape entry must build two three-Node trees"
ash_doc_assert_word_count \
    "$shapes_entry_source" Empty 8 \
    "the shape entry must close eight empty branches"
ash_doc_assert_word_count \
    "$shapes_entry_source" balanced 2 \
    "the shape entry must bind and measure balanced once"
ash_doc_assert_word_count \
    "$shapes_entry_source" skewed 2 \
    "the shape entry must bind and measure skewed once"
ash_doc_assert_word_count \
    "$shapes_entry_source" nodes_and_height 2 \
    "the shape entry must measure each tree once"
ash_doc_assert_contains \
    "$shapes_entry_source" "$shape_calls" \
    "the shape entry must measure balanced before skewed"

ash_doc_assert_word_count \
    "$search_entry_source" Node 3 \
    "the search entry must build exactly three Nodes"
ash_doc_assert_word_count \
    "$search_entry_source" Empty 4 \
    "the search entry must close exactly four empty branches"
ash_doc_assert_word_count \
    "$search_entry_source" tree 3 \
    "the search entry must bind and search one tree twice"
ash_doc_assert_word_count \
    "$search_entry_source" is_42 4 \
    "the search entry must define and pass is_42 twice"
ash_doc_assert_word_count \
    "$search_entry_source" find_counted 1 \
    "the search entry must call direct search exactly once"
ash_doc_assert_word_count \
    "$search_entry_source" find_through_fold_counted 1 \
    "the search entry must call folded search exactly once"
ash_doc_assert_phrase_count \
    "$search_entry_source" 'is_42 value = value == 42' 1 \
    "the search entry must match only 42"
readonly search_tree_binding=$'let tree = Trees.Node(\n        Trees.Node(Trees.Empty, 1, Trees.Empty),\n        42,\n        Trees.Node(Trees.Empty, 2, Trees.Empty)\n    )'
readonly search_calls=$'(\n        Trees.find_counted is_42 tree,\n        Trees.find_through_fold_counted is_42 tree\n    )'
ash_doc_assert_contains \
    "$search_entry_source" "$search_tree_binding" \
    "the search entry must retain its exact root-match tree"
ash_doc_assert_phrase_count \
    "$search_entry_source" \
    'Trees.find_counted is_42 tree' 1 \
    "the search entry must run direct search with is_42 and tree"
ash_doc_assert_phrase_count \
    "$search_entry_source" \
    'Trees.find_through_fold_counted is_42 tree' 1 \
    "the search entry must run folded search with the same predicate and tree"
ash_doc_assert_contains \
    "$search_entry_source" "$search_calls" \
    "the search entry must return direct before folded search"

readonly size_map_output='(3, Node(Node(Empty, 2, Empty), 3, Node(Empty, 4, Empty))) : (Int, Tree<Int>)'
readonly shapes_output='((3, Next(Next(Zero))), (3, Next(Next(Next(Zero))))) : '\
'((Int, Natural), (Int, Natural))'
readonly search_output='((Some(42), 1), (Some(42), 3)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'

ash_doc_assert_text_line_once \
    "$size_map_output" \
    "README must display the size-and-map output exactly once"
ash_doc_assert_text_line_once \
    "$shapes_output" \
    "README must display the balanced-and-skewed output exactly once"
ash_doc_assert_text_line_once \
    "$search_output" \
    "README must display the selective-and-fold output exactly once"

ash_doc_run_accepted \
    "$unit_root" \
    src/01-size-and-map.ash \
    "$size_map_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/02-balanced-and-skewed.ash \
    "$shapes_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/03-selective-and-fold.ash \
    "$search_output"

ash_doc_finish 4
