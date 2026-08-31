#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/queues.ash"
readonly sequence_entry="$unit_root/src/01-sequence.ash"
readonly retained_entry="$unit_root/src/02-retained-state.ash"
readonly sources=(
    src/queues.ash
    src/01-sequence.ash
    src/02-retained-state.ash
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
    ash_doc_fail "canonical source set must contain exactly the three declared paths"
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

ash_doc_assert_readme_phrase() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_readme_phrase requires phrase and claim"
    fi

    local actual_count
    actual_count=$(
        awk '
            /^[[:space:]]*<!--/ { in_comment = 1 }
            !in_comment && /^[[:space:]]*(```|~~~)/ {
                in_fence = !in_fence
                next
            }
            !in_comment && !in_fence { print }
            in_comment && /-->[[:space:]]*$/ { in_comment = 0 }
        ' "$readme" |
            { grep -Fo "$1" || true; } |
            wc -l
    )
    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail "$2 (found $actual_count occurrences, expected 1)"
}

library_source=$(<"$library")
sequence_source=$(<"$sequence_entry")
retained_source=$(<"$retained_entry")
readonly library_source sequence_source retained_source

public_operation_count=$(
    { grep -Ec '^pub [a-z][a-z0-9_]* :' "$library" || true; }
)
readonly public_operation_count
[[ $public_operation_count -eq 3 ]] ||
    ash_doc_fail "queue API must expose exactly three public operations"

# Keep every mutation-facing semantic assertion before hashes and execution.
types_section=$(ash_doc_section 'pub type Option<A> =' 'pub empty : Unit -> Queue<A>')
empty_enqueue_section=$(ash_doc_section 'pub empty : Unit -> Queue<A>' 'reverse_into : List<A> -> List<A> -> List<A>')
reverse_section=$(ash_doc_section 'reverse_into : List<A> -> List<A> -> List<A>' 'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>')
dequeue_section=$(ash_doc_section 'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>' '')
readonly types_section empty_enqueue_section reverse_section dequeue_section

readonly expected_types=$'pub type Option<A> =\n    None\n    | Some(A)\n\npub type List<A> =\n    End\n    | More(A, List<A>)\n\npub opaque type Queue<A> =\n    Queue(List<A>, List<A>)'
[[ $types_section == "$expected_types" ]] ||
    ash_doc_fail "support types and opaque queue must retain their exact representation"

readonly expected_empty_enqueue=$'pub empty : Unit -> Queue<A>\nempty () = Queue(End, End)\n\npub enqueue : A -> Queue<A> -> Queue<A>\nenqueue value Queue(front, rear) = Queue(front, More(value, rear))'
[[ $empty_enqueue_section == "$expected_empty_enqueue" ]] ||
    ash_doc_fail "empty and enqueue must retain empty state and one rear prepend"

readonly expected_reverse=$'reverse_into : List<A> -> List<A> -> List<A>\nreverse_into End reversed = reversed\nreverse_into More(first, rest) reversed = {\n    reverse_into rest (More(first, reversed))\n}'
[[ $reverse_section == "$expected_reverse" ]] ||
    ash_doc_fail "reverse_into must retain its terminal reuse and accumulator step"

readonly expected_dequeue=$'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>\ndequeue Queue(End, End) = None\ndequeue Queue(More(first, rest), rear) = {\n    Some((first, Queue(rest, rear)))\n}\ndequeue Queue(End, rear) = {\n    let front = reverse_into rear End\n    dequeue (Queue(front, End))\n}'
[[ $dequeue_section == "$expected_dequeue" ]] ||
    ash_doc_fail "dequeue must retain empty, front, and rear-transfer equations in order"

readonly signatures=(
    'pub empty : Unit -> Queue<A>'
    'pub enqueue : A -> Queue<A> -> Queue<A>'
    'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>'
)
for signature in "${signatures[@]}"; do
    ash_doc_assert_line_count "$library_source" "$signature" 1 "the queue API must retain every exact signature"
done
ash_doc_assert_phrase_count "$library_source" 'pub reverse_into' 0 "reverse_into must remain private"

readonly expected_drain=$'drain : Queues.Queue<A> -> Queues.List<A>\ndrain queue = match Queues.dequeue queue {\n    Queues.None => Queues.End\n    Queues.Some((first, later)) => Queues.More(first, drain later)\n}'
ash_doc_assert_contains "$sequence_source" "$expected_drain" "the sequence client must drain only returned successor states"
readonly expected_sequence_ready=$'let ready = Queues.enqueue 3 (\n        Queues.enqueue 2 (\n            Queues.enqueue 1 empty_queue\n        )\n    )'
ash_doc_assert_contains "$sequence_source" "$expected_sequence_ready" "the sequence client must enqueue one, two, and three in that order"
ash_doc_assert_line_count "$sequence_source" '    let empty_result = Queues.dequeue empty_queue' 1 "the sequence client must retain one empty dequeue observation"
ash_doc_assert_line_count "$sequence_source" '    match Queues.dequeue ready {' 1 "the sequence client must trigger transfer from the retained ready state"
readonly expected_sequence_result=$'        Queues.Some((first, later)) => (\n            empty_result,\n            ready,\n            first,\n            later,\n            drain later\n        )'
ash_doc_assert_contains "$sequence_source" "$expected_sequence_result" "the sequence result must expose empty, pre-transfer, FIFO, successor, and drain evidence"

readonly expected_retained_ready=$'let ready = Queues.enqueue 3 (\n        Queues.enqueue 2 (\n            Queues.enqueue 1 (Queues.empty ())\n        )\n    )'
ash_doc_assert_contains "$retained_source" "$expected_retained_ready" "the retained client must build the same one, two, three queue"
ash_doc_assert_phrase_count "$retained_source" 'Queues.dequeue ready' 2 "the retained client must branch exactly twice from ready"
ash_doc_assert_line_count "$retained_source" '    (Queues.dequeue ready, Queues.dequeue ready)' 1 "the retained result must contain both calls from the same state"

ash_doc_assert_sha256 "$library" 9db0dde1fd8776556ea4f4bad51aacb09fd00a7ed769cf8e457ea20795cfe7bd "queues.ash must retain its exact complete source"
ash_doc_assert_sha256 "$sequence_entry" 38edc257a6e1859b96b40f523ac57199eff14aaa6bccf13176289e4b18dcfc61 "01-sequence.ash must retain its exact complete source"
ash_doc_assert_sha256 "$retained_entry" 6a0981eb6dd63c2cc540983a69bc5e058db0018f670645610d518e8e6ab99d51 "02-retained-state.ash must retain its exact complete source"

readonly sequence_output='(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)'
readonly retained_output='(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)'

ash_doc_run_accepted "$unit_root" src/01-sequence.ash "$sequence_output"
ash_doc_run_accepted "$unit_root" src/02-retained-state.ash "$retained_output"

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
# The literal Markdown backticks below are intentional evidence text.
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase '`Queue(front, rear)` denotes `front ++ reverse(rear)`.' "README must state the representation relationship"
ash_doc_assert_readme_phrase 'The front may be empty while the rear is nonempty.' "README must state the selected variant has no nonempty-front invariant"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase 'The transfer is eager and complete before `dequeue` returns.' "README must state the eager-transfer boundary"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase 'One list-node unit is one selected or constructed `More`.' "README must define the named work metric"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase '`reverse_into` runs `m + 1` times, and the transfer costs `2m + 1` list-node units.' "README must state the exact one-transfer work"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase 'One linear successor history that starts from `empty` costs at most `3e + d` list-node units.' "README must state the start-from-empty linear-history bound"
ash_doc_assert_readme_phrase 'Retained branching repeats the transfer outside that linear-history bound.' "README must state the persistent-branching exclusion"
ash_doc_assert_readme_phrase 'The metric excludes elapsed time, machine instructions, and host-stack behavior.' "README must exclude runtime measurements"
ash_doc_assert_readme_phrase 'It also excludes heap bytes, allocation count, pointer identity, physical sharing,' "README must exclude storage and identity measurements"
ash_doc_assert_readme_phrase 'garbage collection, and compiler optimization.' "README must complete the runtime exclusions"
ash_doc_assert_text_line_once "$sequence_output" "README must display the complete sequence output exactly once"
ash_doc_assert_text_line_once "$retained_output" "README must display the retained-state output exactly once"

ash_doc_finish 3
