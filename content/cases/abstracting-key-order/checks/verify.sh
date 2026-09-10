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
readonly missing_order_entry="$unit_root/src/04-missing-order.ash"
readonly sources=(
    src/ordered_trees.ash
    src/01-lookup.ash
    src/02-replace-and-malformed.ash
    src/03-ascending.ash
    src/04-missing-order.ash
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

declared_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/declared-sources.XXXXXX")
actual_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/actual-sources.XXXXXX")
readonly declared_sources_file actual_sources_file
printf '%s\n' "${sources[@]}" | LC_ALL=C sort > "$declared_sources_file"
find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' \
    -printf 'src/%f\n' | LC_ALL=C sort > "$actual_sources_file"
if ! cmp -s "$declared_sources_file" "$actual_sources_file"; then
    diff -u "$declared_sources_file" "$actual_sources_file" >&2 || true
    ash_doc_fail \
        "canonical source set must contain exactly the five declared paths"
fi

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"

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

ash_doc_assert_file_exact() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail \
            "ash_doc_assert_file_exact requires file, source, and claim"
    fi

    local actual_file=$1
    local expected_source=$2
    local claim=$3
    local expected_file
    expected_file=$(mktemp "$ASH_DOC_VERIFY_DIR/expected-source.XXXXXX")
    printf '%s\n' "$expected_source" > "$expected_file"

    if ! cmp -s "$expected_file" "$actual_file"; then
        diff -u "$expected_file" "$actual_file" >&2 || true
        ash_doc_fail "$claim"
    fi
}

library_source=$(<"$library")
lookup_entry_source=$(<"$lookup_entry")
replacement_entry_source=$(<"$replacement_entry")
ascending_entry_source=$(<"$ascending_entry")
missing_order_entry_source=$(<"$missing_order_entry")
readonly library_source lookup_entry_source replacement_entry_source
readonly ascending_entry_source missing_order_entry_source

# Keep mutation-facing claims ahead of section extraction and whole-file checks.
readonly name_import='import ordered_trees as Trees'
readonly implementation_selector='import ordered_trees (impl Order)'
readonly independent_import_channels="${name_import}"$'\n'\
"${implementation_selector}"
for client_source in \
    "$lookup_entry_source" \
    "$replacement_entry_source" \
    "$ascending_entry_source" \
    "$missing_order_entry_source"; do
    ash_doc_assert_phrase_count \
        "$client_source" "$name_import" 1 \
        "each client must retain exactly one qualified name import"
    ash_doc_assert_phrase_count \
        "$client_source" "$implementation_selector" 1 \
        "each client must explicitly select Order implementation evidence"
    ash_doc_assert_contains \
        "$client_source" "$independent_import_channels" \
        "each client must keep name visibility and implementation selection adjacent"
done

ash_doc_assert_phrase_count \
    "$library_source" 'pub interface Order<A> {' 1 \
    "Order must be one public interface"
ash_doc_assert_phrase_count \
    "$library_source" 'compare : A -> A -> Ordering' 1 \
    "Order.compare must retain its exact method type"
ash_doc_assert_phrase_count \
    "$library_source" 'pub impl Order<Natural> {' 1 \
    "Natural order must be one public implementation"
ash_doc_assert_phrase_count \
    "$library_source" 'compare Zero Next(right) = Less' 1 \
    "Natural order must place Zero before every Next value"
ash_doc_assert_phrase_count \
    "$library_source" 'compare Next(left) Zero = Greater' 1 \
    "Natural order must place every Next value after Zero"
ash_doc_assert_phrase_count \
    "$library_source" \
    'compare Next(left) Next(right) = compare left right' 1 \
    "Natural order must recursively compare both Next payloads"
ash_doc_assert_phrase_count \
    "$library_source" \
    'pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>' 1 \
    "lookup must declare exactly one Order<K> requirement"
ash_doc_assert_phrase_count \
    "$library_source" \
    'pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>' 1 \
    "insert must declare exactly one Order<K> requirement"
ash_doc_assert_phrase_count \
    "$library_source" \
    'pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>' 1 \
    "counted lookup must declare exactly one Order<K> requirement"

representations_section=$(ash_doc_section \
    'pub type Tree<K, V> =' \
    'pub interface Order<A> {')
interface_section=$(ash_doc_section \
    'pub interface Order<A> {' \
    'pub impl Order<Natural> {')
implementation_section=$(ash_doc_section \
    'pub impl Order<Natural> {' \
    'pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>')
lookup_section=$(ash_doc_section \
    'pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>' \
    'pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>')
insert_section=$(ash_doc_section \
    'pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>' \
    'pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>')
lookup_counted_section=$(ash_doc_section \
    'pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>' \
    'maximum : Natural -> Natural -> Natural')
maximum_section=$(ash_doc_section \
    'maximum : Natural -> Natural -> Natural' \
    'pub height : Tree<K, V> -> Natural')
height_section=$(ash_doc_section \
    'pub height : Tree<K, V> -> Natural' \
    '')
readonly representations_section interface_section implementation_section
readonly lookup_section insert_section lookup_counted_section
readonly maximum_section height_section

readonly expected_representations=$'pub type Tree<K, V> =\n    Empty\n    | Node(Tree<K, V>, K, V, Tree<K, V>)\n\npub type Ordering =\n    Less\n    | Equal\n    | Greater\n\npub type Option<A> =\n    None\n    | Some(A)\n\npub type Natural =\n    Zero\n    | Next(Natural)'
[[ $representations_section == "$expected_representations" ]] ||
    ash_doc_fail \
        "Tree, Ordering, Option, and Natural must retain their exact representations"

readonly expected_interface=$'pub interface Order<A> {\n    compare : A -> A -> Ordering\n}'
[[ $interface_section == "$expected_interface" ]] ||
    ash_doc_fail "Order must retain exactly its one compare method"
ash_doc_assert_word_count \
    "$interface_section" compare 1 \
    "Order must contain only one compare method declaration"

ash_doc_assert_phrase_count \
    "$implementation_section" 'compare Zero Zero = Equal' 1 \
    "Natural order must identify two Zero values as equal"
ash_doc_assert_phrase_count \
    "$implementation_section" 'compare left right' 1 \
    "recursive Natural comparison must use exact current evidence"
readonly expected_implementation=$'pub impl Order<Natural> {\n    compare Zero Zero = Equal\n    compare Zero Next(right) = Less\n    compare Next(left) Zero = Greater\n    compare Next(left) Next(right) = compare left right\n}'
[[ $implementation_section == "$expected_implementation" ]] ||
    ash_doc_fail \
        "Natural order must retain its exact public four-equation implementation"

ash_doc_assert_phrase_count \
    "$lookup_section" 'match compare query key {' 1 \
    "lookup must compare the query with the current key exactly once"
ash_doc_assert_phrase_count \
    "$lookup_section" 'Less => lookup query left' 1 \
    "lookup must enter only the left branch after Less without a comparator argument"
ash_doc_assert_phrase_count \
    "$lookup_section" 'Greater => lookup query right' 1 \
    "lookup must enter only the right branch after Greater without a comparator argument"
ash_doc_assert_phrase_count \
    "$lookup_section" 'Equal => Some(value)' 1 \
    "lookup must return the current value after Equal"
ash_doc_assert_phrase_count \
    "$lookup_section" 'lookup query Empty = None' 1 \
    "lookup must return None at Empty"
ash_doc_assert_word_count \
    "$lookup_section" compare 1 \
    "lookup must make one top-level compare method call"
readonly expected_lookup=$'pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>\nlookup query Empty = None\nlookup query Node(left, key, value, right) = match compare query key {\n    Less => lookup query left\n    Equal => Some(value)\n    Greater => lookup query right\n}'
[[ $lookup_section == "$expected_lookup" ]] ||
    ash_doc_fail "lookup must retain its exact constrained equations and selected arms"

ash_doc_assert_phrase_count \
    "$insert_section" 'match compare key current_key {' 1 \
    "insert must compare the incoming key with the stored key exactly once"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'Less => Node(insert key value left, current_key, current_value, right)' 1 \
    "insert must recurse left without a comparator argument and retain the right branch"
ash_doc_assert_phrase_count \
    "$insert_section" 'Equal => Node(left, current_key, value, right)' 1 \
    "insert replacement must retain the stored key and both branches"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'Greater => Node(left, current_key, current_value, insert key value right)' 1 \
    "insert must recurse right without a comparator argument and retain the left branch"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'insert key value Empty = Node(Empty, key, value, Empty)' 1 \
    "insert must construct one keyed node at Empty"
readonly expected_insert=$'pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>\ninsert key value Empty = Node(Empty, key, value, Empty)\ninsert key value Node(left, current_key, current_value, right) = match compare key current_key {\n    Less => Node(insert key value left, current_key, current_value, right)\n    Equal => Node(left, current_key, value, right)\n    Greater => Node(left, current_key, current_value, insert key value right)\n}'
[[ $insert_section == "$expected_insert" ]] ||
    ash_doc_fail "insert must retain its exact constrained equations and selected arms"

ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'lookup_counted query Empty = (None, 0)' 1 \
    "counted lookup must report zero comparisons at Empty"
readonly expected_counted_less=$'Less => {\n        let (found, later_comparisons) = lookup_counted query left\n        (found, later_comparisons + 1)\n    }'
ash_doc_assert_contains \
    "$lookup_counted_section" "$expected_counted_less" \
    "counted lookup must recurse left without a comparator argument and add one"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'Equal => (Some(value), 1)' 1 \
    "counted lookup must report one comparison at Equal"
readonly expected_counted_greater=$'Greater => {\n        let (found, later_comparisons) = lookup_counted query right\n        (found, later_comparisons + 1)\n    }'
ash_doc_assert_contains \
    "$lookup_counted_section" "$expected_counted_greater" \
    "counted lookup must recurse right without a comparator argument and add one"
ash_doc_assert_phrase_count \
    "$lookup_counted_section" 'match compare query key {' 1 \
    "counted lookup must compare the query with the current key exactly once"
ash_doc_assert_word_count \
    "$lookup_counted_section" compare 1 \
    "counted lookup must make one top-level compare method call"
readonly expected_lookup_counted=$'pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>\nlookup_counted query Empty = (None, 0)\nlookup_counted query Node(left, key, value, right) = match compare query key {\n    Less => {\n        let (found, later_comparisons) = lookup_counted query left\n        (found, later_comparisons + 1)\n    }\n    Equal => (Some(value), 1)\n    Greater => {\n        let (found, later_comparisons) = lookup_counted query right\n        (found, later_comparisons + 1)\n    }\n}'
[[ $lookup_counted_section == "$expected_lookup_counted" ]] ||
    ash_doc_fail \
        "counted lookup must retain its exact constrained base and selected arms"

readonly expected_maximum=$'maximum : Natural -> Natural -> Natural\nmaximum Zero right = right\nmaximum left Zero = left\nmaximum Next(left) Next(right) = Next(maximum left right)'
[[ $maximum_section == "$expected_maximum" ]] ||
    ash_doc_fail "maximum must retain its exact private three equations"
readonly expected_height=$'pub height : Tree<K, V> -> Natural\nheight Empty = Zero\nheight Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))'
[[ $height_section == "$expected_height" ]] ||
    ash_doc_fail "height must retain its exact public two equations"

expected_library="${expected_representations}"$'\n\n'\
"${expected_interface}"$'\n\n'\
"${expected_implementation}"$'\n\n'\
"${expected_lookup}"$'\n\n'\
"${expected_insert}"$'\n\n'\
"${expected_lookup_counted}"$'\n\n'\
"${expected_maximum}"$'\n\n'\
"${expected_height}"
readonly expected_library
ash_doc_assert_file_exact \
    "$library" "$expected_library" \
    "ordered_trees.ash must retain its exact complete source"

readonly valid_tree_binding=$'let valid = Trees.Node(\n        Trees.Node(Trees.Empty, one, 10, Trees.Empty),\n        two,\n        20,\n        Trees.Node(Trees.Empty, three, 30, Trees.Empty)\n    )'
readonly valid_lookup_calls=$'(\n        Trees.lookup_counted three valid,\n        Trees.lookup_counted Trees.Zero valid\n    )'
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
    "the lookup entry must run both counted queries without comparator arguments"
ash_doc_assert_word_count \
    "$lookup_entry_source" lookup_counted 2 \
    "the lookup entry must run exactly two counted lookups"

readonly malformed_binding=$'let malformed = Trees.Node(\n        Trees.Node(Trees.Empty, two, 20, Trees.Empty),\n        one,\n        10,\n        Trees.Empty\n    )'
readonly replacement_calls=$'(\n        Trees.lookup one original,\n        Trees.lookup one replaced,\n        Trees.lookup two malformed\n    )'
ash_doc_assert_contains \
    "$replacement_entry_source" "$malformed_binding" \
    "the malformed entry must place two in the left branch of one"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" 'Trees.lookup two malformed' 1 \
    "the malformed observation must query its misplaced key two"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'let with_two = Trees.insert two 20 Trees.Empty' 1 \
    "the replacement entry must first insert two into Empty"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'let original = Trees.insert one 10 with_two' 1 \
    "the replacement entry must derive original by inserting one"
ash_doc_assert_phrase_count \
    "$replacement_entry_source" \
    'let replaced = Trees.insert one 99 original' 1 \
    "the replacement entry must derive replaced from retained original"
ash_doc_assert_contains \
    "$replacement_entry_source" "$replacement_calls" \
    "the replacement entry must observe original, replaced, then malformed"

ash_doc_assert_phrase_count \
    "$ascending_entry_source" \
    'let after_one = Trees.insert one 10 Trees.Empty' 1 \
    "the ascending entry must insert one before two"
ash_doc_assert_phrase_count \
    "$ascending_entry_source" \
    'let after_two = Trees.insert two 20 after_one' 1 \
    "the ascending entry must insert two after one"
ash_doc_assert_phrase_count \
    "$ascending_entry_source" \
    'let after_three = Trees.insert three 30 after_two' 1 \
    "the ascending entry must insert three after two"
readonly ascending_calls=$'(\n        after_three,\n        Trees.height after_three,\n        Trees.lookup_counted three after_three\n    )'
ash_doc_assert_contains \
    "$ascending_entry_source" "$ascending_calls" \
    "the ascending entry must observe after_three without a comparator argument"

accepted_entries_source="${lookup_entry_source}"$'\n'\
"${replacement_entry_source}"$'\n'\
"${ascending_entry_source}"
readonly accepted_entries_source
ash_doc_assert_phrase_count \
    "$accepted_entries_source" 'Trees.compare_natural' 0 \
    "accepted entries must not retain the old explicit comparator"

ash_doc_assert_phrase_count \
    "$missing_order_entry_source" \
    'let tree = Trees.Node(Trees.Empty, 1, 10, Trees.Empty)' 1 \
    "the missing-order entry must construct exactly one Int-key node"
ash_doc_assert_phrase_count \
    "$missing_order_entry_source" 'Trees.Node(' 1 \
    "the missing-order entry must construct exactly one tree node"
ash_doc_assert_phrase_count \
    "$missing_order_entry_source" 'Trees.lookup 1 tree' 1 \
    "the missing-order entry must retain its exact failing Trees.lookup line"
ash_doc_assert_phrase_count \
    "$missing_order_entry_source" "$implementation_selector" 1 \
    "the missing-order entry must select available Order facts before proving Order<Int> is absent"

readonly expected_lookup_entry=$'import ordered_trees as Trees\nimport ordered_trees (impl Order)\n\nmain : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))\nmain () = {\n    let one = Trees.Next(Trees.Zero)\n    let two = Trees.Next(one)\n    let three = Trees.Next(two)\n    let valid = Trees.Node(\n        Trees.Node(Trees.Empty, one, 10, Trees.Empty),\n        two,\n        20,\n        Trees.Node(Trees.Empty, three, 30, Trees.Empty)\n    )\n    (\n        Trees.lookup_counted three valid,\n        Trees.lookup_counted Trees.Zero valid\n    )\n}'
readonly expected_replacement_entry=$'import ordered_trees as Trees\nimport ordered_trees (impl Order)\n\nmain : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)\nmain () = {\n    let one = Trees.Next(Trees.Zero)\n    let two = Trees.Next(one)\n    let with_two = Trees.insert two 20 Trees.Empty\n    let original = Trees.insert one 10 with_two\n    let replaced = Trees.insert one 99 original\n    let malformed = Trees.Node(\n        Trees.Node(Trees.Empty, two, 20, Trees.Empty),\n        one,\n        10,\n        Trees.Empty\n    )\n    (\n        Trees.lookup one original,\n        Trees.lookup one replaced,\n        Trees.lookup two malformed\n    )\n}'
readonly expected_ascending_entry=$'import ordered_trees as Trees\nimport ordered_trees (impl Order)\n\nmain : Unit -> (Trees.Tree<Trees.Natural, Int>, Trees.Natural, (Trees.Option<Int>, Int))\nmain () = {\n    let one = Trees.Next(Trees.Zero)\n    let two = Trees.Next(one)\n    let three = Trees.Next(two)\n    let after_one = Trees.insert one 10 Trees.Empty\n    let after_two = Trees.insert two 20 after_one\n    let after_three = Trees.insert three 30 after_two\n    (\n        after_three,\n        Trees.height after_three,\n        Trees.lookup_counted three after_three\n    )\n}'
readonly expected_missing_order_entry=$'import ordered_trees as Trees\nimport ordered_trees (impl Order)\n\nmain : Unit -> Trees.Option<Int>\nmain () = {\n    let tree = Trees.Node(Trees.Empty, 1, 10, Trees.Empty)\n    Trees.lookup 1 tree\n}'

ash_doc_assert_file_exact \
    "$lookup_entry" "$expected_lookup_entry" \
    "the lookup entry must retain its exact complete source"
ash_doc_assert_file_exact \
    "$replacement_entry" "$expected_replacement_entry" \
    "the replacement and malformed entry must retain its exact complete source"
ash_doc_assert_file_exact \
    "$ascending_entry" "$expected_ascending_entry" \
    "the ascending entry must retain its exact complete source"
ash_doc_assert_file_exact \
    "$missing_order_entry" "$expected_missing_order_entry" \
    "the missing-order entry must retain its exact complete source"

ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"

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
grep -Fxq \
    "The \`Order<Int>\` obligation belongs to the \`Trees.lookup\` occurrence." \
    "$readme" ||
    ash_doc_fail \
        "README must retain the exact causal sentence for the missing-order occurrence"

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
ash_doc_run_rejected "$unit_root" src/04-missing-order.ash 1
ash_doc_check_human "$unit_root" src/04-missing-order.ash "$unit_root/.."

ash_doc_finish 5
