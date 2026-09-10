#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/dictionaries.ash"
readonly sequence_entry="$unit_root/src/01-sequence.ash"
readonly retained_entry="$unit_root/src/02-retained-state.ash"
readonly pattern_entry="$unit_root/src/03-opaque-pattern.ash"
readonly construction_entry="$unit_root/src/04-opaque-construction.ash"
readonly sources=(
    src/dictionaries.ash
    src/01-sequence.ash
    src/02-retained-state.ash
    src/03-opaque-pattern.ash
    src/04-opaque-construction.ash
)

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] ||
        ash_doc_fail "missing canonical source: $source"
done

declared_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/declared-sources.XXXXXX")
actual_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/actual-sources.XXXXXX")
readonly declared_sources_file actual_sources_file
printf '%s\n' "${sources[@]}" | LC_ALL=C sort > "$declared_sources_file"
find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' \
    -printf 'src/%f\n' | LC_ALL=C sort > "$actual_sources_file"
if ! cmp -s "$declared_sources_file" "$actual_sources_file"; then
    diff -u "$declared_sources_file" "$actual_sources_file" >&2 || true
    ash_doc_fail "canonical source set must contain exactly the five declared paths"
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
        ash_doc_fail "ash_doc_section could not find required adjacent signatures"
    fi
}

ash_doc_assert_phrase_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_phrase_count requires source, phrase, count, and claim"
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
        ash_doc_fail "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_line_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_line_count requires source, line, count, and claim"
    fi

    local source=$1
    local expected_line=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fx "$expected_line" <<< "$source" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_contains() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_contains requires source, substring, and claim"
    fi

    [[ $1 == *"$2"* ]] || ash_doc_fail "$3"
}

ash_doc_assert_sha256() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_sha256 requires file, hash, and claim"
    fi

    local actual
    actual=$(sha256sum "$1")
    actual=${actual%% *}
    [[ $actual == "$2" ]] ||
        ash_doc_fail "$3 (found $actual, expected $2)"
}

ash_doc_assert_text_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_text_line_once requires line and claim"
    fi

    local actual_count
    actual_count=$(
        awk -v expected="$1" '
            $0 == "```text" { inside = 1; next }
            inside && $0 == "```" { inside = 0; next }
            inside && $0 == expected { count += 1 }
            END { print count + 0 }
        ' "$readme"
    )
    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail "$2 (found $actual_count occurrences, expected 1)"
}

ash_doc_assert_text_first_line_count() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_text_first_line_count requires line, count, and claim"
    fi

    local actual_count
    actual_count=$(
        awk -v expected="$1" '
            $0 == "```text" { first = 1; next }
            first {
                if ($0 == expected) {
                    count += 1
                }
                first = 0
            }
            END { print count + 0 }
        ' "$readme"
    )
    [[ $actual_count -eq $2 ]] ||
        ash_doc_fail "$3 (found $actual_count occurrences, expected $2)"
}

library_source=$(<"$library")
sequence_source=$(<"$sequence_entry")
retained_source=$(<"$retained_entry")
pattern_source=$(<"$pattern_entry")
construction_source=$(<"$construction_entry")
readonly library_source sequence_source retained_source pattern_source construction_source

# Keep every mutation-facing semantic assertion before hashes and execution.
ash_doc_assert_phrase_count \
    "$library_source" 'pub opaque type Dictionary<K, V> =' 1 \
    "Dictionary must retain one public opaque identity"
ash_doc_assert_phrase_count \
    "$library_source" 'pub opaque type Iterator<K, V> =' 1 \
    "Iterator must retain one public opaque identity"
ash_doc_assert_phrase_count \
    "$library_source" 'type FrameStack<K, V> =' 1 \
    "FrameStack must retain one private nominal declaration"
ash_doc_assert_phrase_count \
    "$library_source" 'pub type FrameStack<K, V> =' 0 \
    "FrameStack must remain private"

for signature in \
    'pub empty : Unit -> Dictionary<K, V>' \
    'pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>' \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>' \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>' \
    'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>' \
    'pub iterator : Dictionary<K, V> -> Iterator<K, V>' \
    'pub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>'; do
    ash_doc_assert_line_count \
        "$library_source" "$signature" 1 \
        "the public API must retain every exact signature"
done

readonly expected_frames=$'type FrameStack<K, V> =\n    NoFrame\n    | MoreFrame(K, V, Dictionary<K, V>, FrameStack<K, V>)\n\npub opaque type Iterator<K, V> =\n    Iterator(FrameStack<K, V>)'
ash_doc_assert_contains \
    "$library_source" "$expected_frames" \
    "the private frames and opaque wrapper must retain their exact representation"

push_left_section=$(ash_doc_section \
    'push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>' \
    'pub iterator : Dictionary<K, V> -> Iterator<K, V>')
iterator_section=$(ash_doc_section \
    'pub iterator : Dictionary<K, V> -> Iterator<K, V>' '')
readonly push_left_section iterator_section
readonly expected_push_left=$'push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>\npush_left Empty stack = stack\npush_left Node(ignored_color, left, key, value, right) stack = {\n    let later_stack = MoreFrame(key, value, right, stack)\n    push_left left later_stack\n}'
[[ $push_left_section == "$expected_push_left" ]] ||
    ash_doc_fail "push_left must retain Empty reuse, exact frame fields, and left recursion"
readonly expected_iterator=$'pub iterator : Dictionary<K, V> -> Iterator<K, V>\niterator dictionary = Iterator(push_left dictionary NoFrame)\n\npub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>\nnext Iterator(NoFrame) = None\nnext Iterator(MoreFrame(key, value, right, rest)) = Some(\n    ((key, value), Iterator(push_left right rest))\n)'
[[ $iterator_section == "$expected_iterator" ]] ||
    ash_doc_fail "iterator and next must retain initial, exhausted, yielded, right, and rest behavior"
ash_doc_assert_phrase_count \
    "$iterator_section" 'Order<' 0 \
    "iterator operations must not require ordering evidence"
ash_doc_assert_phrase_count \
    "$iterator_section" 'compare ' 0 \
    "iterator operations must not compare keys"

readonly expected_collect=$'collect : Dictionaries.Iterator<K, V> -> Dictionaries.List<(K, V)>\ncollect current = match Dictionaries.next current {\n    Dictionaries.None => Dictionaries.End\n    Dictionaries.Some((entry, later)) => Dictionaries.More(entry, collect later)\n}'
ash_doc_assert_contains \
    "$sequence_source" "$expected_collect" \
    "the sequence client must consume one entry and recurse on the returned state"
ash_doc_assert_phrase_count \
    "$sequence_source" \
    'let empty_finished = is_finished (Dictionaries.next (Dictionaries.iterator empty_dictionary))' 1 \
    "the sequence client must observe one empty iterator"
readonly expected_sequence_entries=$'let entries = Dictionaries.More(\n        (two, 20),\n        Dictionaries.More(\n            (one, 10),\n            Dictionaries.More((three, 30), Dictionaries.End)\n        )\n    )'
ash_doc_assert_contains \
    "$sequence_source" "$expected_sequence_entries" \
    "the sequence client must build the fixed two, one, three input"
ash_doc_assert_phrase_count \
    "$sequence_source" \
    '(empty_finished, collect (Dictionaries.iterator dictionary))' 1 \
    "the sequence result must retain empty and complete traversal observations"

readonly expected_replay=$'Dictionaries.Some((ignored_first, after_one)) => Replay(\n        after_one,\n        Dictionaries.next after_one,\n        Dictionaries.next after_one\n    )'
ash_doc_assert_contains \
    "$retained_source" "$expected_replay" \
    "the retained client must return raw state and replay it twice"
ash_doc_assert_phrase_count \
    "$retained_source" 'Dictionaries.next after_one' 2 \
    "the retained client must branch exactly twice from after_one"
readonly expected_retained_entries=$'let entries = Dictionaries.More(\n        (one, 10),\n        Dictionaries.More(\n            (two, 20),\n            Dictionaries.More((three, 30), Dictionaries.End)\n        )\n    )'
ash_doc_assert_contains \
    "$retained_source" "$expected_retained_entries" \
    "the retained client must build the fixed one, two, three input"

ash_doc_assert_phrase_count \
    "$pattern_source" 'Dictionaries.Iterator' 1 \
    "the pattern rejection must retain one opaque constructor occurrence"
ash_doc_assert_phrase_count \
    "$pattern_source" 'Dictionaries.Iterator(ignored_stack) => 1' 1 \
    "the pattern rejection must retain its exact failing arm"
ash_doc_assert_phrase_count \
    "$construction_source" 'Dictionaries.Iterator' 1 \
    "the value rejection must retain one opaque constructor occurrence"
ash_doc_assert_phrase_count \
    "$construction_source" 'let unavailable = Dictionaries.Iterator' 1 \
    "the value rejection must retain its exact failing initializer"

ash_doc_assert_sha256 \
    "$library" \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    "dictionaries.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$sequence_entry" \
    4b36d0271735f0c49c522d6c5c748013f32eb1fc46ec2a5603eb2e96c82a5b3c \
    "01-sequence.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$retained_entry" \
    18d15528fe8b93f4bf3455a9bdcb7d162e1d52a5ab10d1fca20b6de5f0122872 \
    "02-retained-state.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$pattern_entry" \
    334318b3480aaf6550e41dc8bd90ad26cec736cd2cd277e656d8a1af63e86ba8 \
    "03-opaque-pattern.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$construction_entry" \
    8c656fc6eb7591c46cf162f77b4fa838257bd441dbb80abcd98705e9b9057cea \
    "04-opaque-construction.ash must retain its exact complete source"

readonly sequence_output='(true, More((Next(Zero), 10), More((Next(Next(Zero)), 20), More((Next(Next(Next(Zero))), 30), End)))) : (Bool, List<(Natural, Int)>)'
readonly retained_output='Replay(Iterator(MoreFrame(Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty), NoFrame)), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame))), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))) : ReplayObservation'

ash_doc_run_accepted "$unit_root" src/01-sequence.ash "$sequence_output"
ash_doc_run_accepted "$unit_root" src/02-retained-state.ash "$retained_output"
ash_doc_run_rejected "$unit_root" src/03-opaque-pattern.ash 1
ash_doc_run_rejected "$unit_root" src/04-opaque-construction.ash 1

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_assert_text_line_once \
    "$sequence_output" \
    "README must display the complete sequence output exactly once"
ash_doc_assert_text_line_once \
    "$retained_output" \
    "README must display the retained-state output exactly once"
ash_doc_assert_text_first_line_count \
    'resolve.opaque-constructor' 2 \
    "README must begin two diagnostic transcripts with resolve.opaque-constructor"

ash_doc_finish 5
