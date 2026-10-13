#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/dictionaries.ash"
readonly prefix_entry="$unit_root/src/01-prefix-matrix.ash"
readonly persistence_entry="$unit_root/src/02-build-and-persistence.ash"
readonly repair_entry="$unit_root/src/03-repair.ash"
readonly prefix_fixture="$unit_root/fixtures/prefix-matrix.stdout"
readonly sources=(
    src/dictionaries.ash
    src/01-prefix-matrix.ash
    src/02-build-and-persistence.ash
    src/03-repair.ash
)

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"
[[ -f $library ]] ||
    ash_doc_fail "missing canonical source: src/dictionaries.ash"

declared_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/declared-sources.XXXXXX")
actual_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/actual-sources.XXXXXX")
readonly declared_sources_file actual_sources_file
printf '%s\n' "${sources[@]}" | LC_ALL=C sort > "$declared_sources_file"
find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' \
    -printf 'src/%f\n' | LC_ALL=C sort > "$actual_sources_file"
if ! cmp -s "$declared_sources_file" "$actual_sources_file"; then
    diff -u "$declared_sources_file" "$actual_sources_file" >&2 || true
    ash_doc_fail \
        "canonical source set must contain exactly the four declared paths"
fi

ash_doc_section() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_section requires a source, start, and end line"
    fi

    if ! awk -v section_start="$2" -v section_end="$3" '
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
    ' "$1"; then
        ash_doc_fail \
            "ash_doc_section could not find its required adjacent signatures"
    fi
}

ash_doc_assert_phrase_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail \
            "ash_doc_assert_phrase_count requires source, phrase, count, and claim"
    fi

    local source=$1
    local phrase=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fo "$phrase" <<< "$source" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected $expected_count)"
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

ash_doc_assert_exact() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_exact requires source, expected, and claim"
    fi

    local source=$1
    local expected=$2
    local claim=$3

    [[ $source == "$expected" ]] || ash_doc_fail "$claim"
}

ash_doc_assert_sha256() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_sha256 requires file, hash, and claim"
    fi

    local file=$1
    local expected=$2
    local claim=$3
    local actual
    actual=$(sha256sum "$file")
    actual=${actual%% *}

    [[ $actual == "$expected" ]] ||
        ash_doc_fail "$claim (found $actual, expected $expected)"
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

library_source=$(<"$library")
persistence_source=$(<"$persistence_entry")
repair_source=$(<"$repair_entry")
readonly library_source persistence_source repair_source

# Keep every mutation-facing source claim ahead of hashes and executions.
ash_doc_assert_phrase_count \
    "$library_source" 'type Color =' 1 \
    "Color must be one private two-form type"
ash_doc_assert_phrase_count \
    "$library_source" 'pub type Color =' 0 \
    "Color must remain private"
ash_doc_assert_phrase_count \
    "$library_source" 'type BalanceCheck =' 1 \
    "BalanceCheck must be one private two-form type"
ash_doc_assert_phrase_count \
    "$library_source" 'pub opaque type Dictionary<K, V> =' 1 \
    "Dictionary must remain one public opaque nominal"
ash_doc_assert_phrase_count \
    "$library_source" \
    '| Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)' 1 \
    "Dictionary.Node must retain its private color and ordered payload"

representations_section=$(ash_doc_section \
    "$library" 'pub type Ordering =' 'pub interface Order<A> {')
order_section=$(ash_doc_section \
    "$library" 'pub interface Order<A> {' \
    'pub empty : Unit -> Dictionary<K, V>')
lookup_section=$(ash_doc_section \
    "$library" \
    'pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>' \
    'restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>')
restore_three_section=$(ash_doc_section \
    "$library" \
    'restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>' \
    'restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>')
restore_section=$(ash_doc_section \
    "$library" \
    'restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>' \
    'insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>')
insert_colored_section=$(ash_doc_section \
    "$library" \
    'insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>' \
    'blacken_root : Dictionary<K, V> -> Dictionary<K, V>')
blacken_section=$(ash_doc_section \
    "$library" 'blacken_root : Dictionary<K, V> -> Dictionary<K, V>' \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>')
insert_section=$(ash_doc_section \
    "$library" \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>' \
    'fold_left : (B -> A -> B) -> B -> List<A> -> B')
fold_section=$(ash_doc_section \
    "$library" 'fold_left : (B -> A -> B) -> B -> List<A> -> B' \
    'insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>')
insert_entry_section=$(ash_doc_section \
    "$library" \
    'insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>' \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>')
build_section=$(ash_doc_section \
    "$library" \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>' \
    'above_lower : Option<K> -> K -> Bool where Order<K>')
lower_section=$(ash_doc_section \
    "$library" 'above_lower : Option<K> -> K -> Bool where Order<K>' \
    'below_upper : K -> Option<K> -> Bool where Order<K>')
upper_section=$(ash_doc_section \
    "$library" 'below_upper : K -> Option<K> -> Bool where Order<K>' \
    'both : Bool -> Bool -> Bool')
valid_section=$(ash_doc_section \
    "$library" \
    'valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>' \
    'is_black : Dictionary<K, V> -> Bool')
color_section=$(ash_doc_section \
    "$library" 'is_black : Dictionary<K, V> -> Bool' \
    'balance_summary : Dictionary<K, V> -> BalanceCheck')
balance_section=$(ash_doc_section \
    "$library" 'balance_summary : Dictionary<K, V> -> BalanceCheck' \
    'balance_holds : Dictionary<K, V> -> Bool')
balance_holds_section=$(ash_doc_section \
    "$library" 'balance_holds : Dictionary<K, V> -> Bool' \
    'root_is_black : Dictionary<K, V> -> Bool')
root_section=$(ash_doc_section \
    "$library" 'root_is_black : Dictionary<K, V> -> Bool' \
    'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>')
invariant_section=$(ash_doc_section \
    "$library" \
    'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>' \
    'main : Unit -> (Bool, Bool, Bool, Bool, Bool)')
main_section=$(ash_doc_section \
    "$library" 'main : Unit -> (Bool, Bool, Bool, Bool, Bool)' '')
readonly representations_section order_section lookup_section
readonly restore_three_section restore_section insert_colored_section
readonly blacken_section insert_section fold_section insert_entry_section
readonly build_section lower_section upper_section valid_section color_section
readonly balance_section balance_holds_section root_section invariant_section
readonly main_section

readonly expected_representations=$'pub type Ordering =\n    Less\n    | Equal\n    | Greater\n\npub type Natural =\n    Zero\n    | Next(Natural)\n\npub type Option<A> =\n    None\n    | Some(A)\n\npub type List<A> =\n    End\n    | More(A, List<A>)\n\ntype Color =\n    Red\n    | Black\n\npub opaque type Dictionary<K, V> =\n    Empty\n    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)\n\ntype BalanceCheck =\n    Invalid\n    | Valid(Int)'
ash_doc_assert_exact \
    "$representations_section" "$expected_representations" \
    "public representations and private red-black forms must remain exact"

readonly expected_order=$'pub interface Order<A> {\n    compare : A -> A -> Ordering\n}\n\npub impl Order<Natural> {\n    compare Zero Zero = Equal\n    compare Zero Next(right) = Less\n    compare Next(left) Zero = Greater\n    compare Next(left) Next(right) = compare left right\n}'
ash_doc_assert_exact \
    "$order_section" "$expected_order" \
    "Order and its Natural implementation must remain exact"

for signature in \
    'pub empty : Unit -> Dictionary<K, V>' \
    'pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>' \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>' \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>' \
    'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>'; do
    ash_doc_assert_phrase_count \
        "$library_source" "$signature" 1 \
        "the public dictionary API must retain every exact signature"
done

readonly expected_lookup=$'pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>\nlookup query Empty = None\nlookup query Node(ignored_color, left, current_key, current_value, right) = match compare query current_key {\n    Less => lookup query left\n    Equal => Some(current_value)\n    Greater => lookup query right\n}'
ash_doc_assert_exact \
    "$lookup_section" "$expected_lookup" \
    "lookup must retain its exact selected branches and stored value"

readonly expected_restore_three=$'restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>\nrestore_three first first_key first_value second middle_key middle_value third last_key last_value fourth = Node(\n    Red,\n    Node(Black, first, first_key, first_value, second),\n    middle_key,\n    middle_value,\n    Node(Black, third, last_key, last_value, fourth)\n)'
ash_doc_assert_exact \
    "$restore_three_section" "$expected_restore_three" \
    "restore_three must retain all three ordered key-value associations"

readonly restore_ll=$'restore Black Node(\n    Red,\n    Node(Red, first, first_key, first_value, second),\n    middle_key,\n    middle_value,\n    third\n) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth'
readonly restore_lr=$'restore Black Node(\n    Red,\n    first,\n    first_key,\n    first_value,\n    Node(Red, second, middle_key, middle_value, third)\n) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth'
readonly restore_rl=$'restore Black first first_key first_value Node(\n    Red,\n    Node(Red, second, middle_key, middle_value, third),\n    last_key,\n    last_value,\n    fourth\n) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth'
readonly restore_rr=$'restore Black first first_key first_value Node(\n    Red,\n    second,\n    middle_key,\n    middle_value,\n    Node(Red, third, last_key, last_value, fourth)\n) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth'
ash_doc_assert_contains \
    "$restore_section" "$restore_ll" \
    "restore must retain the left-left repair orientation"
ash_doc_assert_contains \
    "$restore_section" "$restore_lr" \
    "restore must retain the left-right repair orientation"
ash_doc_assert_contains \
    "$restore_section" "$restore_rl" \
    "restore must retain the right-left repair orientation"
ash_doc_assert_contains \
    "$restore_section" "$restore_rr" \
    "restore must retain the right-right repair orientation"
ash_doc_assert_phrase_count \
    "$restore_section" \
    'restore color left key value right = Node(color, left, key, value, right)' 1 \
    "restore fallback must reconstruct exactly the supplied color and branches"

ash_doc_assert_phrase_count \
    "$insert_colored_section" \
    'insert_colored key value Empty = Node(Red, Empty, key, value, Empty)' 1 \
    "absent insertion must construct one red leaf"
ash_doc_assert_phrase_count \
    "$insert_colored_section" \
    'Less => restore color (insert_colored key value left) current_key current_value right' 1 \
    "colored insertion must recurse left and retain the right association"
ash_doc_assert_phrase_count \
    "$insert_colored_section" \
    'Equal => Node(color, left, current_key, value, right)' 1 \
    "equal insertion must retain the stored key, color, and branches"
ash_doc_assert_phrase_count \
    "$insert_colored_section" \
    'Greater => restore color left current_key current_value (insert_colored key value right)' 1 \
    "colored insertion must recurse right and retain the left association"

readonly expected_blacken=$'blacken_root : Dictionary<K, V> -> Dictionary<K, V>\nblacken_root dictionary = match dictionary {\n    Empty => Empty\n    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary\n    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)\n}'
ash_doc_assert_exact \
    "$blacken_section" "$expected_blacken" \
    "blacken_root must reuse Empty and Black roots and reconstruct only Red"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'insert key value dictionary = blacken_root (insert_colored key value dictionary)' 1 \
    "public insert must compose colored insertion with root blackening"

readonly expected_fold=$'fold_left : (B -> A -> B) -> B -> List<A> -> B\nfold_left combine accumulated End = accumulated\nfold_left combine accumulated More(first, rest) = {\n    let next_accumulated = combine accumulated first\n    fold_left combine next_accumulated rest\n}'
ash_doc_assert_exact \
    "$fold_section" "$expected_fold" \
    "fold_left must remain accumulator-first and strict"
readonly expected_insert_entry=$'insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>\ninsert_entry dictionary entry = match entry {\n    (key, value) => insert key value dictionary\n}'
ash_doc_assert_exact \
    "$insert_entry_section" "$expected_insert_entry" \
    "insert_entry must retain its accepted one-arm tuple body match"
readonly expected_build=$'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>\nbuild entries = fold_left insert_entry (empty ()) entries'
ash_doc_assert_exact \
    "$build_section" "$expected_build" \
    "build must left-fold insert_entry from one empty dictionary"

ash_doc_assert_phrase_count \
    "$lower_section" 'match compare lower key {' 1 \
    "the lower-bound check must compare lower before key"
ash_doc_assert_phrase_count \
    "$upper_section" 'match compare key upper {' 1 \
    "the upper-bound check must compare key before upper"
ash_doc_assert_phrase_count \
    "$valid_section" 'let respects_lower = above_lower lower key' 1 \
    "ordering validation must bind the lower-bound result"
ash_doc_assert_phrase_count \
    "$valid_section" 'let respects_upper = below_upper key upper' 1 \
    "ordering validation must bind the upper-bound result"
ash_doc_assert_phrase_count \
    "$valid_section" \
    'let left_valid = valid_between lower (Some(key)) left' 1 \
    "left validation must retain lower and install key as upper"
ash_doc_assert_phrase_count \
    "$valid_section" \
    'let right_valid = valid_between (Some(key)) upper right' 1 \
    "right validation must install key as lower and retain upper"
ash_doc_assert_phrase_count \
    "$valid_section" \
    'both respects_lower (both respects_upper (both left_valid right_valid))' 1 \
    "ordering validation must combine both bounds and recursive results"

ash_doc_assert_phrase_count \
    "$color_section" \
    'children_colors_hold Red left right = both (is_black left) (is_black right)' 1 \
    "a red node must reject either red immediate child"
ash_doc_assert_phrase_count \
    "$color_section" 'add_black Red height = height' 1 \
    "a red node must preserve child black-height"
ash_doc_assert_phrase_count \
    "$color_section" 'add_black Black height = height + 1' 1 \
    "a black node must increment child black-height"
readonly expected_balance_bindings=$'let left_result = balance_summary left\n    let right_result = balance_summary right\n    let children_hold = children_colors_hold color left right\n    match (left_result, right_result) {'
ash_doc_assert_phrase_count \
    "$balance_section" 'balance_summary Empty = Valid(1)' 1 \
    "terminal Empty must contribute one black form"
ash_doc_assert_contains \
    "$balance_section" "$expected_balance_bindings" \
    "balance validation must bind both child summaries before matching"
ash_doc_assert_phrase_count \
    "$balance_section" '(Invalid, ignored_right_result) => Invalid' 1 \
    "an invalid left summary must invalidate its parent"
ash_doc_assert_phrase_count \
    "$balance_section" '(Valid(ignored_left_height), Invalid) => Invalid' 1 \
    "an invalid right summary must invalidate its parent"
ash_doc_assert_phrase_count \
    "$balance_section" 'true => match left_height == right_height {' 1 \
    "balance validation must require equal child black-height"
ash_doc_assert_phrase_count \
    "$balance_section" 'true => Valid(add_black color left_height)' 1 \
    "balance validation must apply the color-specific height update"
readonly expected_balance_holds=$'balance_holds : Dictionary<K, V> -> Bool\nbalance_holds dictionary = match balance_summary dictionary {\n    Invalid => false\n    Valid(ignored_height) => true\n}'
ash_doc_assert_exact \
    "$balance_holds_section" "$expected_balance_holds" \
    "balance_holds must distinguish invalid and valid summaries"
readonly expected_root=$'root_is_black : Dictionary<K, V> -> Bool\nroot_is_black Empty = true\nroot_is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true\nroot_is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false'
ash_doc_assert_exact \
    "$root_section" "$expected_root" \
    "root validation must reject every red nonempty root"
readonly expected_invariant=$'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>\ninvariant_holds dictionary = {\n    let ordered = valid_between None None dictionary\n    let balanced = balance_holds dictionary\n    let black_root = root_is_black dictionary\n    both ordered (both balanced black_root)\n}'
ash_doc_assert_exact \
    "$invariant_section" "$expected_invariant" \
    "invariant_holds must bind and combine ordering, balance, and root results"

readonly valid_fixture='let valid = Node(Black, Empty, one, 10, Empty)'
readonly invalid_order_fixture=$'let invalid_order = Node(\n        Black,\n        Node(Black, Empty, one, 10, Node(Red, Empty, three, 30, Empty)),\n        two,\n        20,\n        Node(Black, Empty, four, 40, Empty)\n    )'
readonly red_root_fixture='let red_root = Node(Red, Empty, one, 10, Empty)'
readonly red_red_fixture=$'let red_red = Node(\n        Black,\n        Node(\n            Red,\n            Node(Red, Empty, one, 10, Empty),\n            two,\n            20,\n            Node(Red, Empty, three, 30, Empty)\n        ),\n        four,\n        40,\n        Empty\n    )'
readonly uneven_fixture=$'let uneven_black_height = Node(\n        Black,\n        Node(Black, Empty, one, 10, Empty),\n        two,\n        20,\n        Empty\n    )'
readonly fixture_results=$'(\n        invariant_holds valid,\n        invariant_holds invalid_order,\n        invariant_holds red_root,\n        invariant_holds red_red,\n        invariant_holds uneven_black_height\n    )'
ash_doc_assert_contains \
    "$main_section" "$valid_fixture" \
    "private validation matrix must retain its valid fixture"
ash_doc_assert_contains \
    "$main_section" "$invalid_order_fixture" \
    "private validation matrix must retain its deep ordering violation"
ash_doc_assert_contains \
    "$main_section" "$red_root_fixture" \
    "private validation matrix must retain its red-root violation"
ash_doc_assert_contains \
    "$main_section" "$red_red_fixture" \
    "private validation matrix must retain its red-red violation"
ash_doc_assert_contains \
    "$main_section" "$uneven_fixture" \
    "private validation matrix must retain its unequal black-height violation"
ash_doc_assert_contains \
    "$main_section" "$fixture_results" \
    "private validation results must retain their exact fixture order"

prefix_shapes=$(ash_doc_section \
    "$prefix_entry" 'type PrefixCheck =' 'has_value : Int -> Dictionaries.Option<Int> -> Bool')
prefix_run_section=$(ash_doc_section \
    "$prefix_entry" \
    'prefix_run : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> PrefixRun' \
    'lookup_checks : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Dictionaries.List<Bool>')
lookup_checks_section=$(ash_doc_section \
    "$prefix_entry" \
    'lookup_checks : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Dictionaries.List<Bool>' \
    'scenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Scenario')
scenario_section=$(ash_doc_section \
    "$prefix_entry" \
    'scenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Scenario' \
    'main : Unit -> (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)')
prefix_main_section=$(ash_doc_section \
    "$prefix_entry" \
    'main : Unit -> (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)' '')
readonly prefix_shapes prefix_run_section lookup_checks_section
readonly scenario_section prefix_main_section

readonly expected_prefix_shapes=$'type PrefixCheck =\n    PrefixCheck(Bool, Bool, Bool, Bool)\n\ntype Scenario =\n    Scenario(Bool, Dictionaries.List<PrefixCheck>, Dictionaries.List<Bool>)\n\ntype PrefixRun =\n    PrefixRun(\n        Dictionaries.List<PrefixCheck>,\n        Dictionaries.Dictionary<Dictionaries.Natural, Int>\n    )'
ash_doc_assert_exact \
    "$prefix_shapes" "$expected_prefix_shapes" \
    "prefix evidence must retain its exact observable shapes"
readonly expected_current_check=$'let current_check = PrefixCheck(\n            Dictionaries.invariant_holds next_dictionary,\n            has_value value (Dictionaries.lookup key next_dictionary),\n            has_value retained_value (Dictionaries.lookup retained_key next_dictionary),\n            is_none (Dictionaries.lookup absent_key next_dictionary)\n        )'
ash_doc_assert_contains \
    "$prefix_run_section" "$expected_current_check" \
    "every prefix must check its invariant, new and retained values, and absence"
readonly expected_lookup_checks=$'lookup_checks : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Dictionaries.List<Bool>\nlookup_checks Dictionaries.End absent_key dictionary = Dictionaries.More(\n    is_none (Dictionaries.lookup absent_key dictionary),\n    Dictionaries.End\n)\nlookup_checks Dictionaries.More(entry, rest) absent_key dictionary = match entry {\n    (key, value) => Dictionaries.More(\n        has_value value (Dictionaries.lookup key dictionary),\n        lookup_checks rest absent_key dictionary\n    )\n}'
ash_doc_assert_exact \
    "$lookup_checks_section" "$expected_lookup_checks" \
    "final checks must retain every exact association and end with absence"
ash_doc_assert_phrase_count \
    "$scenario_section" 'Dictionaries.invariant_holds empty' 1 \
    "each scenario must expose the empty-prefix invariant"
ash_doc_assert_phrase_count \
    "$scenario_section" 'lookup_checks entries absent_key final_dictionary' 1 \
    "each scenario must check all final associations and the fixed absence"

readonly ascending_sequence=$'let ascending = Dictionaries.More(\n        (one, 10),\n        Dictionaries.More(\n            (two, 20),\n            Dictionaries.More(\n                (three, 30),\n                Dictionaries.More(\n                    (four, 40),\n                    Dictionaries.More(\n                        (five, 50),\n                        Dictionaries.More(\n                            (six, 60),\n                            Dictionaries.More((seven, 70), Dictionaries.End)\n                        )\n                    )\n                )\n            )\n        )\n    )'
readonly descending_sequence=$'let descending = Dictionaries.More(\n        (seven, 70),\n        Dictionaries.More(\n            (six, 60),\n            Dictionaries.More(\n                (five, 50),\n                Dictionaries.More(\n                    (four, 40),\n                    Dictionaries.More(\n                        (three, 30),\n                        Dictionaries.More(\n                            (two, 20),\n                            Dictionaries.More((one, 10), Dictionaries.End)\n                        )\n                    )\n                )\n            )\n        )\n    )'
readonly left_left_sequence=$'let left_left = Dictionaries.More(\n        (three, 30),\n        Dictionaries.More((two, 20), Dictionaries.More((one, 10), Dictionaries.End))\n    )'
readonly left_right_sequence=$'let left_right = Dictionaries.More(\n        (three, 30),\n        Dictionaries.More((one, 10), Dictionaries.More((two, 20), Dictionaries.End))\n    )'
readonly right_left_sequence=$'let right_left = Dictionaries.More(\n        (one, 10),\n        Dictionaries.More((three, 30), Dictionaries.More((two, 20), Dictionaries.End))\n    )'
readonly right_right_sequence=$'let right_right = Dictionaries.More(\n        (one, 10),\n        Dictionaries.More((two, 20), Dictionaries.More((three, 30), Dictionaries.End))\n    )'
ash_doc_assert_contains \
    "$prefix_main_section" "$ascending_sequence" \
    "prefix matrix must retain the ascending 1-through-7 sequence"
ash_doc_assert_contains \
    "$prefix_main_section" "$descending_sequence" \
    "prefix matrix must retain the descending 7-through-1 sequence"
ash_doc_assert_contains \
    "$prefix_main_section" "$left_left_sequence" \
    "prefix matrix must retain the left-left repair sequence"
ash_doc_assert_contains \
    "$prefix_main_section" "$left_right_sequence" \
    "prefix matrix must retain the left-right repair sequence"
ash_doc_assert_contains \
    "$prefix_main_section" "$right_left_sequence" \
    "prefix matrix must retain the right-left repair sequence"
ash_doc_assert_contains \
    "$prefix_main_section" "$right_right_sequence" \
    "prefix matrix must retain the right-right repair sequence"
readonly scenario_calls=$'(\n        scenario ascending one 10 Dictionaries.Zero,\n        scenario descending seven 70 Dictionaries.Zero,\n        scenario left_left three 30 Dictionaries.Zero,\n        scenario left_right three 30 Dictionaries.Zero,\n        scenario right_left one 10 Dictionaries.Zero,\n        scenario right_right one 10 Dictionaries.Zero\n    )'
ash_doc_assert_contains \
    "$prefix_main_section" "$scenario_calls" \
    "prefix matrix must call all six scenarios with retained values and Zero absence"

readonly persistence_steps=$'let with_two = Dictionaries.insert two 20 empty\n    let older = Dictionaries.insert one 10 with_two\n    let replaced = Dictionaries.insert two 99 older\n    let extended = Dictionaries.insert three 30 replaced'
ash_doc_assert_contains \
    "$persistence_source" "$persistence_steps" \
    "persistence evidence must retain old, replaced, and extended construction"
readonly persistence_entries=$'let entries = Dictionaries.More(\n        (two, 20),\n        Dictionaries.More(\n            (one, 10),\n            Dictionaries.More(\n                (two, 99),\n                Dictionaries.More((three, 30), Dictionaries.End)\n            )\n        )\n    )'
ash_doc_assert_contains \
    "$persistence_source" "$persistence_entries" \
    "build evidence must retain two, one, replacement, then three input order"
ash_doc_assert_phrase_count \
    "$persistence_source" 'let built = Dictionaries.build entries' 1 \
    "build evidence must construct one independent dictionary"
readonly persistence_invariants=$'(\n            Dictionaries.invariant_holds older,\n            Dictionaries.invariant_holds replaced,\n            Dictionaries.invariant_holds extended,\n            Dictionaries.invariant_holds built\n        )'
ash_doc_assert_contains \
    "$persistence_source" "$persistence_invariants" \
    "persistence evidence must retain all four invariant observations"
readonly persistence_lookups=$'(\n            Dictionaries.lookup two older,\n            Dictionaries.lookup two replaced,\n            Dictionaries.lookup two built,\n            Dictionaries.lookup three older,\n            Dictionaries.lookup three extended,\n            Dictionaries.lookup three built\n        )'
ash_doc_assert_contains \
    "$persistence_source" "$persistence_lookups" \
    "persistence evidence must retain old, replaced, extended, and built lookups"

readonly repair_steps=$'let one = Next(Zero)\n    let two = Next(one)\n    let three = Next(two)\n    let after_three = insert three 30 (empty ())\n    let after_two = insert two 20 after_three\n    insert one 10 after_two'
ash_doc_assert_contains \
    "$repair_source" "$repair_steps" \
    "the calculated repair must insert keys three, two, one in that order"

ash_doc_assert_sha256 \
    "$library" \
    9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d \
    "dictionaries.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$prefix_entry" \
    e2f3fb2d4067ddc52e7c2cf4544223b9a23a79f78fb4e8b18250d30a75a29e55 \
    "the prefix matrix must retain its exact complete source"
ash_doc_assert_sha256 \
    "$persistence_entry" \
    444231b5a932c16b499b8ac9735a03ca5bf7967a43ade97a233040e86a8ddde7 \
    "the build and persistence entry must retain its exact complete source"

readonly dictionary_output='(true, false, false, false, false) : (Bool, Bool, Bool, Bool, Bool)'
readonly prefix_output='(Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))))))), More(true, More(true, More(true, More(true, More(true, More(true, More(true, More(true, End))))))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))))))), More(true, More(true, More(true, More(true, More(true, More(true, More(true, More(true, End))))))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End)))))) : (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)'
readonly persistence_output='((Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 20, Empty), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Empty), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Node(Red, Empty, Next(Next(Next(Zero))), 30, Empty)), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Node(Red, Empty, Next(Next(Next(Zero))), 30, Empty))), (true, true, true, true), (Some(20), Some(99), Some(99), None, Some(30), Some(30))) : ((Dictionary<Natural, Int>, Dictionary<Natural, Int>, Dictionary<Natural, Int>, Dictionary<Natural, Int>), (Bool, Bool, Bool, Bool), (Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>))'
readonly repair_output='Node(Black, Node(Black, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty)) : Dictionary<Natural, Int>'

[[ -f $prefix_fixture ]] || ash_doc_fail "missing complete prefix matrix capture"
ash_doc_assert_exact \
    "$(cat "$prefix_fixture")" "$prefix_output" \
    "the prefix matrix fixture must retain its complete exact observation"

ash_doc_run_accepted \
    "$unit_root" src/dictionaries.ash "$dictionary_output"
ash_doc_run_accepted \
    "$unit_root" src/01-prefix-matrix.ash "$prefix_output"
ash_doc_run_accepted \
    "$unit_root" src/02-build-and-persistence.ash "$persistence_output"
ash_doc_run_accepted \
    "$unit_root" src/03-repair.ash "$repair_output"

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_check_sources "$unit_root" "$readme" \
    src/02-build-and-persistence.ash src/03-repair.ash
python3 "$unit_root/checks/check_fragments.py" "$readme" "$library" "$prefix_entry"
python3 "$unit_root/checks/check_prefix_observations.py" "$readme" "$prefix_fixture"
python3 -m unittest discover -s "$unit_root/checks" -p 'test_*.py'

ash_doc_assert_text_line_once \
    "$dictionary_output" \
    "README must display the dictionary validation output exactly once"
ash_doc_assert_text_line_once \
    "$persistence_output" \
    "README must display the build and persistence output exactly once"
ash_doc_assert_text_line_once \
    "$repair_output" \
    "README must display the calculated three-key repair output exactly once"

ash_doc_finish 4
