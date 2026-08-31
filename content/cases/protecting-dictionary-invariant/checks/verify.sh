#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/dictionaries.ash"
readonly public_api_entry="$unit_root/src/01-public-api.ash"
readonly build_entry="$unit_root/src/02-build.ash"
readonly observe_entry="$unit_root/src/03-observe.ash"
readonly construct_entry="$unit_root/src/04-construct.ash"
readonly match_entry="$unit_root/src/05-match.ash"
readonly sources=(
    src/dictionaries.ash
    src/01-public-api.ash
    src/02-build.ash
    src/03-observe.ash
    src/04-construct.ash
    src/05-match.ash
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

for selected_entry in src/01-public-api.ash src/02-build.ash; do
    test "$(grep -Fxc 'import dictionaries (impl Order)' \
        "$unit_root/$selected_entry")" -eq 1 ||
        ash_doc_fail "$selected_entry must select Order exactly once"
done

declared_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/declared-sources.XXXXXX")
actual_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/actual-sources.XXXXXX")
readonly declared_sources_file actual_sources_file
printf '%s\n' "${sources[@]}" | LC_ALL=C sort > "$declared_sources_file"
find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' \
    -printf 'src/%f\n' | LC_ALL=C sort > "$actual_sources_file"
if ! cmp -s "$declared_sources_file" "$actual_sources_file"; then
    diff -u "$declared_sources_file" "$actual_sources_file" >&2 || true
    ash_doc_fail \
        "canonical source set must contain exactly the six declared paths"
fi

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

ash_doc_assert_suffix() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_suffix requires source, suffix, and claim"
    fi

    local source=$1
    local expected=$2
    local claim=$3

    [[ $source == *"$expected" ]] || ash_doc_fail "$claim"
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

ash_doc_assert_text_first_line_count() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail \
            "ash_doc_assert_text_first_line_count requires line, count, and claim"
    fi

    local expected_line=$1
    local expected_count=$2
    local claim=$3
    local actual_count
    actual_count=$(
        awk -v expected="$expected_line" '
            $0 == "```text" {
                first = 1
                next
            }
            first {
                if ($0 == expected) {
                    count += 1
                }
                first = 0
            }
            END { print count + 0 }
        ' "$readme"
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_run_opaque_rejection() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail \
            "ash_doc_run_opaque_rejection requires a unit and entry"
    fi

    local rejected_unit_root=$1
    local rejected_entry=$2
    local rejected_source="$rejected_unit_root/$rejected_entry"
    local rejected_stdout
    local rejected_stderr
    local rejected_status
    rejected_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    rejected_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")

    if "$ASH_DOC_ASH_BIN" "$rejected_source" \
        > "$rejected_stdout" 2> "$rejected_stderr"; then
        rejected_status=0
    else
        rejected_status=$?
    fi

    [[ $rejected_status -eq 1 ]] ||
        ash_doc_fail \
            "$rejected_entry exited with status $rejected_status, expected 1"
    [[ ! -s $rejected_stdout ]] ||
        ash_doc_fail "$rejected_entry wrote unexpected standard output"
    [[ $(sed -n '1p' "$rejected_stderr") == 'resolve.opaque-constructor' ]] ||
        ash_doc_fail \
            "$rejected_entry did not report resolve.opaque-constructor first"

    local qualified_spelling=Dictionaries.Empty
    local qualified_matches=()
    mapfile -t qualified_matches < <(
        LC_ALL=C grep -aboF "$qualified_spelling" "$rejected_source" || true
    )
    [[ ${#qualified_matches[@]} -eq 1 ]] ||
        ash_doc_fail \
            "$rejected_entry must contain one byte-identifiable Dictionaries.Empty occurrence"

    local qualified_start=${qualified_matches[0]%%:*}
    local qualifier_length
    qualifier_length=$(LC_ALL=C printf '%s' 'Dictionaries.' | wc -c)
    local member_length
    member_length=$(LC_ALL=C printf '%s' 'Empty' | wc -c)
    local member_start=$((qualified_start + qualifier_length))
    local member_end=$((member_start + member_length))

    local dictionary_marker='pub opaque type Dictionary<K, V> ='
    local node_marker='| Node(Dictionary<K, V>, K, V, Dictionary<K, V>)'
    local dictionary_markers=()
    local node_markers=()
    mapfile -t dictionary_markers < <(
        LC_ALL=C grep -aboF "$dictionary_marker" "$library" || true
    )
    mapfile -t node_markers < <(
        LC_ALL=C grep -aboF "$node_marker" "$library" || true
    )
    [[ ${#dictionary_markers[@]} -eq 1 && ${#node_markers[@]} -eq 1 ]] ||
        ash_doc_fail \
            "the opaque Dictionary declaration must have one byte-identifiable constructor family"

    local dictionary_start=${dictionary_markers[0]%%:*}
    local node_start=${node_markers[0]%%:*}
    local empty_matches=()
    local empty_match
    while IFS= read -r empty_match; do
        local empty_start=${empty_match%%:*}
        if [[ $empty_start -gt $dictionary_start && $empty_start -lt $node_start ]]; then
            empty_matches+=("$empty_start")
        fi
    done < <(LC_ALL=C grep -aboF 'Empty' "$library" || true)
    [[ ${#empty_matches[@]} -eq 1 ]] ||
        ash_doc_fail \
            "the opaque Dictionary declaration must contain one byte-identifiable Empty token"

    local declaration_start=${empty_matches[0]}
    local declaration_end=$((declaration_start + member_length))
    local primary_prefix="primary: source 0 $member_start..$member_end:"
    local related_prefix="related: source 1 $declaration_start..$declaration_end:"
    local primary_lines=()
    local related_lines=()
    mapfile -t primary_lines < <(
        LC_ALL=C grep -F 'primary: source 0 ' "$rejected_stderr" || true
    )
    mapfile -t related_lines < <(
        LC_ALL=C grep -F 'related: source 1 ' "$rejected_stderr" || true
    )
    [[ ${#primary_lines[@]} -eq 1 ]] ||
        ash_doc_fail \
            "$rejected_entry must report one primary source-0 diagnostic label"
    [[ ${primary_lines[0]} == "$primary_prefix"* ]] ||
        ash_doc_fail \
            "$rejected_entry primary label did not cover exactly the Empty member token"
    [[ ${#related_lines[@]} -eq 1 ]] ||
        ash_doc_fail \
            "$rejected_entry must report one related source-1 diagnostic label"
    [[ ${related_lines[0]} == "$related_prefix"* ]] ||
        ash_doc_fail \
            "$rejected_entry related label did not cover exactly the withheld Empty declaration token"
}

library_source=$(<"$library")
public_api_source=$(<"$public_api_entry")
build_source=$(<"$build_entry")
observe_source=$(<"$observe_entry")
construct_source=$(<"$construct_entry")
match_source=$(<"$match_entry")
readonly library_source public_api_source build_source observe_source
readonly construct_source match_source

# Keep mutation-facing claims ahead of section extraction, hashes, and runs.
ash_doc_assert_phrase_count \
    "$library_source" 'pub opaque type Dictionary<K, V> =' 1 \
    "Dictionary must be one public opaque nominal"
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
    "$library_source" \
    'compare Next(left) Next(right) = compare left right' 1 \
    "Natural order must recursively compare both Next payloads"

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

lookup_section=$(ash_doc_section \
    'pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>' \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>')
insert_section=$(ash_doc_section \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>' \
    'fold_left : (B -> A -> B) -> B -> List<A> -> B')
fold_section=$(ash_doc_section \
    'fold_left : (B -> A -> B) -> B -> List<A> -> B' \
    'insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>')
insert_entry_section=$(ash_doc_section \
    'insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>' \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>')
build_section=$(ash_doc_section \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>' \
    'above_lower : Option<K> -> K -> Bool where Order<K>')
lower_section=$(ash_doc_section \
    'above_lower : Option<K> -> K -> Bool where Order<K>' \
    'below_upper : K -> Option<K> -> Bool where Order<K>')
upper_section=$(ash_doc_section \
    'below_upper : K -> Option<K> -> Bool where Order<K>' \
    'both : Bool -> Bool -> Bool')
valid_section=$(ash_doc_section \
    'valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>' \
    'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>')
main_section=$(ash_doc_section 'main : Unit -> Bool' '')
readonly lookup_section insert_section fold_section insert_entry_section
readonly build_section lower_section upper_section valid_section main_section

ash_doc_assert_phrase_count \
    "$lookup_section" 'Less => lookup query left' 1 \
    "lookup must enter only the left branch after Less"
ash_doc_assert_phrase_count \
    "$lookup_section" 'Greater => lookup query right' 1 \
    "lookup must enter only the right branch after Greater"
ash_doc_assert_phrase_count \
    "$lookup_section" 'match compare query current_key {' 1 \
    "lookup must compare the query with the current key exactly once"
ash_doc_assert_phrase_count \
    "$insert_section" 'Equal => Node(left, current_key, value, right)' 1 \
    "insert replacement must retain the stored key and both branches"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'Less => Node(insert key value left, current_key, current_value, right)' 1 \
    "insert must recurse left and retain the right branch"
ash_doc_assert_phrase_count \
    "$insert_section" \
    'Greater => Node(left, current_key, current_value, insert key value right)' 1 \
    "insert must recurse right and retain the left branch"

ash_doc_assert_phrase_count \
    "$fold_section" 'let next_accumulated = combine accumulated first' 1 \
    "fold_left must pass the accumulator before the current entry"
readonly expected_fold_suffix=$'let next_accumulated = combine accumulated first\n    fold_left combine next_accumulated rest\n}'
ash_doc_assert_suffix \
    "$fold_section" "$expected_fold_suffix" \
    "fold_left must compute the next accumulator before its final recursive expression"
readonly expected_insert_entry=$'insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>\ninsert_entry dictionary entry = match entry {\n    (key, value) => insert key value dictionary\n}'
[[ $insert_entry_section == "$expected_insert_entry" ]] ||
    ash_doc_fail \
        "insert_entry must destructure its tuple in the accepted body match and insert it"
ash_doc_assert_phrase_count \
    "$build_section" '(empty ())' 1 \
    "build must start from exactly one empty dictionary"
ash_doc_assert_phrase_count \
    "$build_section" 'fold_left insert_entry' 1 \
    "build must use insert_entry as its left-fold combiner"
ash_doc_assert_phrase_count \
    "$build_section" 'build entries = fold_left insert_entry (empty ()) entries' 1 \
    "build must retain its exact strict left-fold equation"

ash_doc_assert_phrase_count \
    "$lower_section" 'match compare lower key {' 1 \
    "the lower-bound check must compare lower before key"
ash_doc_assert_phrase_count \
    "$upper_section" 'match compare key upper {' 1 \
    "the upper-bound check must compare key before upper"
ash_doc_assert_phrase_count \
    "$valid_section" 'let left_valid = valid_between lower (Some(key)) left' 1 \
    "left validation must retain the lower bound and install key as upper"
ash_doc_assert_phrase_count \
    "$valid_section" 'let right_valid = valid_between (Some(key)) upper right' 1 \
    "right validation must install key as lower and retain the upper bound"
readonly expected_validation_body=$'let respects_lower = above_lower lower key\n    let respects_upper = below_upper key upper\n    let left_valid = valid_between lower (Some(key)) left\n    let right_valid = valid_between (Some(key)) upper right\n    both respects_lower (both respects_upper (both left_valid right_valid))'
ash_doc_assert_contains \
    "$valid_section" "$expected_validation_body" \
    "whole-tree validation must bind four results before three Boolean combinations"
ash_doc_assert_phrase_count \
    "$library_source" \
    'invariant_holds dictionary = valid_between None None dictionary' 1 \
    "invariant_holds must begin with both bounds absent"

readonly expected_malformed_topology=$'let malformed = Node(\n        Node(Empty, one, 10, Node(Empty, three, 30, Empty)),\n        two,\n        20,\n        Empty\n    )'
ash_doc_assert_contains \
    "$main_section" "$expected_malformed_topology" \
    "private main must retain the deeper ancestor-bound violation"
ash_doc_assert_phrase_count \
    "$main_section" 'invariant_holds malformed' 1 \
    "private main must return the malformed dictionary invariant check"

readonly expected_public_insertions=$'let with_three = Dictionaries.insert three 30 empty\n    let with_one = Dictionaries.insert one 10 with_three\n    let with_two = Dictionaries.insert two 20 with_one\n    let dictionary = Dictionaries.insert four 40 with_two'
readonly expected_public_observation=$'(\n        Dictionaries.invariant_holds dictionary,\n        Dictionaries.lookup one dictionary,\n        Dictionaries.lookup two dictionary,\n        Dictionaries.lookup three dictionary,\n        Dictionaries.lookup four dictionary,\n        Dictionaries.lookup Dictionaries.Zero dictionary\n    )'
ash_doc_assert_contains \
    "$public_api_source" "$expected_public_insertions" \
    "the public API entry must insert three, one, two, then four"
ash_doc_assert_contains \
    "$public_api_source" "$expected_public_observation" \
    "the public API entry must check the invariant, four hits, and one absence"
ash_doc_assert_phrase_count \
    "$public_api_source" 'Dictionaries.lookup ' 5 \
    "the public API entry must retain exactly five lookup calls"

readonly expected_build_entries=$'let entries = Dictionaries.More(\n        (two, 20),\n        Dictionaries.More(\n            (one, 10),\n            Dictionaries.More((two, 99), Dictionaries.End)\n        )\n    )'
readonly expected_build_observation=$'(\n        Dictionaries.invariant_holds dictionary,\n        Dictionaries.lookup two dictionary,\n        Dictionaries.lookup one dictionary\n    )'
ash_doc_assert_contains \
    "$build_source" "$expected_build_entries" \
    "the build entry must retain two, one, then the later equal value 99"
ash_doc_assert_phrase_count \
    "$build_source" 'let dictionary = Dictionaries.build entries' 1 \
    "the build entry must call the public build operation exactly once"
ash_doc_assert_contains \
    "$build_source" "$expected_build_observation" \
    "the build entry must check its invariant and both retained values"

ash_doc_assert_phrase_count \
    "$observe_source" \
    'main : Unit -> Dictionaries.Dictionary<Dictionaries.Natural, Int>' 1 \
    "the observe entry must retain its exact opaque result annotation"
ash_doc_assert_phrase_count \
    "$observe_source" 'main () = Dictionaries.empty()' 1 \
    "the observe entry must return the public empty dictionary exactly"
ash_doc_assert_phrase_count \
    "$construct_source" 'Dictionaries.Empty' 1 \
    "the value rejection must retain one qualified opaque constructor occurrence"
ash_doc_assert_phrase_count \
    "$construct_source" 'main () = Dictionaries.Empty' 1 \
    "the value rejection must retain its exact failing constructor line"
ash_doc_assert_phrase_count \
    "$match_source" 'Dictionaries.Empty' 1 \
    "the pattern rejection must retain one qualified opaque constructor occurrence"
ash_doc_assert_phrase_count \
    "$match_source" 'inspect Dictionaries.Empty = 0' 1 \
    "the pattern rejection must retain its exact failing constructor pattern"

ash_doc_assert_sha256 \
    "$library" \
    ed7a29ee1007751e54840e7ccfc3017589b2126ff20f1e2a3b7f0729027c7e28 \
    "dictionaries.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$public_api_entry" \
    83a6e64a56af15b7bc1bf4682033313f5b0b74f7be7f8147e82d0fb6dbe726b4 \
    "the public API entry must retain its exact complete source"
ash_doc_assert_sha256 \
    "$build_entry" \
    21f73deaaf8a7e45a77493e4fd2d9976f2242d8685a696a2851795d9183459ac \
    "the build entry must retain its exact complete source"
ash_doc_assert_sha256 \
    "$observe_entry" \
    24372051e76bdd4ce1df1a4219287bdfa2457b8dc7ef9876624e4c3d66d1d2ed \
    "the observe entry must retain its exact complete source"
ash_doc_assert_sha256 \
    "$construct_entry" \
    6a1a58bb82cbbddfb2dd02e23585e6a150c3fade181bd4ebd2eef8deceb0e97d \
    "the value rejection must retain its exact complete source"
ash_doc_assert_sha256 \
    "$match_entry" \
    37af6eb991b11e8ea9663d81b10c1b5a87c4b081b14904cfdf72c47954e01f15 \
    "the pattern rejection must retain its exact complete source"

readonly malformed_output='false : Bool'
readonly public_api_output='(true, Some(10), Some(20), Some(30), Some(40), None) : '\
'(Bool, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>)'
readonly build_output='(true, Some(99), Some(10)) : (Bool, Option<Int>, Option<Int>)'
readonly observe_output='Empty : Dictionary<Natural, Int>'

ash_doc_run_accepted \
    "$unit_root" \
    src/dictionaries.ash \
    "$malformed_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/01-public-api.ash \
    "$public_api_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/02-build.ash \
    "$build_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/03-observe.ash \
    "$observe_output"
ash_doc_run_opaque_rejection \
    "$unit_root" \
    src/04-construct.ash
ash_doc_run_opaque_rejection \
    "$unit_root" \
    src/05-match.ash

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"

ash_doc_assert_text_line_once \
    "$malformed_output" \
    "README must display the deeper malformed invariant result exactly once"
ash_doc_assert_text_line_once \
    "$public_api_output" \
    "README must display the public API output exactly once"
ash_doc_assert_text_line_once \
    "$build_output" \
    "README must display the strict build output exactly once"
ash_doc_assert_text_line_once \
    "$observe_output" \
    "README must display the opaque structural observation exactly once"
ash_doc_assert_text_first_line_count \
    'resolve.opaque-constructor' 2 \
    "README must begin two diagnostic transcripts with resolve.opaque-constructor"

ash_doc_finish 6
