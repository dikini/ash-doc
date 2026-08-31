#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/searches.ash"
readonly found_entry="$unit_root/src/01-found-paths.ash"
readonly missing_entry="$unit_root/src/02-unreachable-cycle.ash"
readonly sources=(
    src/searches.ash
    src/01-found-paths.ash
    src/02-unreachable-cycle.ash
)
readonly library_hash=d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b
readonly found_hash=98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692
readonly missing_hash=f1ff38eeceed2e155d6edfad4859af2851ab64521dcbfb8b44ac69d5021c21db
readonly expected_pin=dca16039923475c48025c5f17beadeb6bcb6a4bf
readonly found_output='(Found(More(Start, More(LongOne, More(LongTwo, More(Goal, End)))), 3, Next(Next(Zero))), Found(More(Start, More(Short, More(Goal, End))), 5, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)'
readonly missing_output='(Missing(7, Next(Next(Zero))), Missing(7, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)'

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
# shellcheck disable=SC1091
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
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_section requires source, start, and end lines"
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
        ash_doc_fail "required adjacent signatures must remain present"
    fi
}

ash_doc_assert_phrase_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_phrase_count requires source, phrase, count, and claim"
    fi

    local actual_count
    actual_count=$(
        { grep -Fo "$2" <<< "$1" || true; } |
            wc -l
    )
    [[ $actual_count -eq $3 ]] || ash_doc_fail "$4"
}

ash_doc_assert_line_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_line_count requires source, line, count, and claim"
    fi

    local actual_count
    actual_count=$(
        { grep -Fx "$2" <<< "$1" || true; } |
            wc -l
    )
    [[ $actual_count -eq $3 ]] || ash_doc_fail "$4"
}

ash_doc_assert_contains() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_contains requires source, substring, and claim"
    fi

    [[ $1 == *"$2"* ]] || ash_doc_fail "$3"
}

ash_doc_assert_before() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_before requires source, earlier, later, and claim"
    fi

    local earlier_line later_line
    ash_doc_assert_phrase_count "$1" "$2" 1 "$4"
    ash_doc_assert_phrase_count "$1" "$3" 1 "$4"
    earlier_line=$(grep -nF "$2" <<< "$1")
    earlier_line=${earlier_line%%:*}
    later_line=$(grep -nF "$3" <<< "$1")
    later_line=${later_line%%:*}
    [[ $earlier_line -lt $later_line ]] || ash_doc_fail "$4"
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
    [[ $actual_count -eq 1 ]] || ash_doc_fail "$2"
}

ash_doc_readme_prose() {
    awk '
        /^[[:space:]]*<!--/ { in_comment = 1 }
        !in_comment && /^[[:space:]]*(```|~~~)/ {
            in_fence = !in_fence
            next
        }
        !in_comment && !in_fence { print }
        in_comment && /-->[[:space:]]*$/ { in_comment = 0 }
    ' "$readme" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g'
}

ash_doc_assert_readme_phrase() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_readme_phrase requires phrase and claim"
    fi

    local prose actual_count
    prose=$(ash_doc_readme_prose)
    actual_count=$(
        { grep -Fo "$1" <<< "$prose" || true; } |
            wc -l
    )
    [[ $actual_count -eq 1 ]] || ash_doc_fail "$2"
}

ash_doc_assert_displayed_source() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_displayed_source requires source and claim"
    fi

    local source=$1
    local extracted marker
    extracted=$(mktemp "$ASH_DOC_VERIFY_DIR/extracted.XXXXXX")
    marker="<!-- source: $source -->"
    awk -v expected_marker="$marker" '
        $0 == expected_marker { marker_count += 1; seen = 1; next }
        seen == 1 && $0 == "```ash" { inside = 1; next }
        inside && $0 == "```" { closed = 1; exit }
        inside { print }
        END {
            if (marker_count != 1 || !inside || !closed) {
                exit 2
            }
        }
    ' "$readme" > "$extracted" || ash_doc_fail "$2"
    cmp -s "$unit_root/$source" "$extracted" || ash_doc_fail "$2"
}

library_source=$(<"$library")
found_source=$(<"$found_entry")
missing_source=$(<"$missing_entry")
readonly library_source found_source missing_source

# Keep every mutation-facing semantic assertion before hashes and execution.
public_type_count=$(
    { grep -Ec '^pub type [A-Z][A-Za-z0-9]*(<[^>]+>)? =$' "$library" || true; }
)
public_global_count=$(
    { grep -Ec '^pub [a-z][a-z0-9_]* :' "$library" || true; }
)
readonly public_type_count public_global_count
[[ $public_type_count -eq 4 && $public_global_count -eq 2 ]] ||
    ash_doc_fail "the public surface must contain four types and only depth_first and breadth_first"

public_types_section=$(ash_doc_section "$library" 'pub type Vertex =' 'type Option<A> =')
private_types_section=$(ash_doc_section "$library" 'type Option<A> =' 'same_vertex : Vertex -> Vertex -> Bool')
readonly public_types_section private_types_section
readonly expected_public_types=$'pub type Vertex =\n    Start\n    | Short\n    | LongOne\n    | LongTwo\n    | WideOne\n    | WideTwo\n    | Goal\n    | Isolated\n\npub type List<A> =\n    End\n    | More(A, List<A>)\n\npub type Natural =\n    Zero\n    | Next(Natural)\n\npub type SearchResult =\n    Missing(Int, Natural)\n    | Found(List<Vertex>, Int, Natural)'
[[ $public_types_section == "$expected_public_types" ]] ||
    ash_doc_fail "the four public data types must retain their exact constructors and result fields"
readonly expected_private_types=$'type Option<A> =\n    Absent\n    | Present(A)\n\ntype Entry<K, V> =\n    Entry(K, V)\n\ntype Dictionary<K, V> =\n    NoEntries\n    | MoreEntry(Entry<K, V>, Dictionary<K, V>)\n\ntype Work =\n    Work(Vertex, List<Vertex>)\n\ntype SearchState<F> =\n    SearchState(F, Dictionary<Vertex, Unit>, Natural, Natural, Int)\n\ntype Queue<A> =\n    Queue(List<A>, List<A>)'
[[ $private_types_section == "$expected_private_types" ]] ||
    ash_doc_fail "private support types must retain Work and the five-field generic SearchState"

same_section=$(ash_doc_section "$library" 'same_vertex : Vertex -> Vertex -> Bool' 'neighbors : Vertex -> List<Vertex>')
neighbors_section=$(ash_doc_section "$library" 'neighbors : Vertex -> List<Vertex>' 'empty_dictionary : Unit -> Dictionary<K, V>')
readonly same_section neighbors_section
ash_doc_assert_line_count "$same_section" 'same_vertex Goal Goal = true' 1 \
    "Goal must compare equal to itself"
readonly expected_same=$'same_vertex : Vertex -> Vertex -> Bool\nsame_vertex Start Start = true\nsame_vertex Short Short = true\nsame_vertex LongOne LongOne = true\nsame_vertex LongTwo LongTwo = true\nsame_vertex WideOne WideOne = true\nsame_vertex WideTwo WideTwo = true\nsame_vertex Goal Goal = true\nsame_vertex Isolated Isolated = true\nsame_vertex ignored_left ignored_right = false'
[[ $same_section == "$expected_same" ]] ||
    ash_doc_fail "same_vertex must retain every self-equality equation and the false fallback"
ash_doc_assert_line_count "$neighbors_section" \
    'neighbors Start = More(Short, More(LongOne, End))' 1 \
    "Start neighbors must schedule Short before LongOne"
ash_doc_assert_line_count "$neighbors_section" \
    'neighbors LongTwo = More(Start, More(Goal, End))' 1 \
    "LongTwo neighbors must retain the edge back to Start before Goal"
readonly expected_neighbors=$'neighbors : Vertex -> List<Vertex>\nneighbors Start = More(Short, More(LongOne, End))\nneighbors Short = More(WideOne, More(WideTwo, More(Goal, End)))\nneighbors LongOne = More(LongTwo, End)\nneighbors LongTwo = More(Start, More(Goal, End))\nneighbors WideOne = End\nneighbors WideTwo = End\nneighbors Goal = End\nneighbors Isolated = End'
[[ $neighbors_section == "$expected_neighbors" ]] ||
    ash_doc_fail "neighbors must retain the complete ordered finite graph"

dictionary_section=$(ash_doc_section "$library" 'empty_dictionary : Unit -> Dictionary<K, V>' 'stack_add : A -> List<A> -> List<A>')
stack_section=$(ash_doc_section "$library" 'stack_add : A -> List<A> -> List<A>' 'queue_empty : Unit -> Queue<A>')
queue_section=$(ash_doc_section "$library" 'queue_empty : Unit -> Queue<A>' 'decrement : Natural -> Natural')
readonly dictionary_section stack_section queue_section
ash_doc_assert_line_count "$dictionary_section" \
    'insert_dictionary key value dictionary = MoreEntry(Entry(key, value), dictionary)' 1 \
    "dictionary insertion must retain the prior dictionary"
ash_doc_assert_line_count "$dictionary_section" \
    '    false => lookup_dictionary same_key query rest' 1 \
    "failed dictionary equality must continue through the rest"
ash_doc_assert_contains "$dictionary_section" \
    $'lookup_dictionary same_key query NoEntries = Absent\nlookup_dictionary same_key query MoreEntry(Entry(key, value), rest) = match same_key query key {\n    true => Present(value)' \
    "dictionary lookup must distinguish absence and return the first matching value"
ash_doc_assert_line_count "$stack_section" \
    'stack_add value stack = More(value, stack)' 1 \
    "stack_add must retain the old stack as its tail"
readonly expected_stack=$'stack_add : A -> List<A> -> List<A>\nstack_add value stack = More(value, stack)\n\nstack_remove : List<A> -> Option<(A, List<A>)>\nstack_remove End = Absent\nstack_remove More(first, rest) = Present((first, rest))'
[[ $stack_section == "$expected_stack" ]] ||
    ash_doc_fail "stack_remove must select and return the front item and old tail"
ash_doc_assert_line_count "$queue_section" \
    'queue_add value Queue(front, rear) = Queue(front, More(value, rear))' 1 \
    "queue_add must prepend only to the rear list"
ash_doc_assert_line_count "$queue_section" \
    'queue_remove Queue(End, End) = Absent' 1 \
    "queue_remove must report an empty pair as absent"
ash_doc_assert_contains "$queue_section" \
    $'queue_remove Queue(More(first, rest), rear) = {\n    Present((first, Queue(rest, rear)))\n}' \
    "queue_remove must return the front item with the successor pair"
ash_doc_assert_contains "$queue_section" \
    $'queue_remove Queue(End, rear) = {\n    let front = reverse_into rear End\n    queue_remove (Queue(front, End))\n}' \
    "queue transfer must clear the rear before recursive removal"

ash_doc_assert_line_count "$library_source" \
    'schedule : (Work -> F -> F) -> List<Vertex> -> Work -> SearchState<F> -> SearchState<F>' 1 \
    "schedule must not receive or test the target at discovery"
forward_section=$(ash_doc_section "$library" 'forward_path : Work -> List<Vertex>' 'schedule : (Work -> F -> F) -> List<Vertex> -> Work -> SearchState<F> -> SearchState<F>')
readonly forward_section
ash_doc_assert_line_count "$forward_section" \
    '    reverse_into predecessors (More(current, End))' 1 \
    "found paths must reverse their retained predecessors"

schedule_section=$(ash_doc_section "$library" \
    'schedule : (Work -> F -> F) -> List<Vertex> -> Work -> SearchState<F> -> SearchState<F>' \
    'continue_search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> Dictionary<Vertex, Unit> -> Natural -> Natural -> Int -> Option<(Work, F)> -> SearchResult')
readonly schedule_section
ash_doc_assert_line_count "$schedule_section" 'schedule add End parent state = state' 1 \
    "scheduling must stop at the end of the neighbor list"
ash_doc_assert_line_count "$schedule_section" \
    '    SearchState(frontier, visited, pending, maximum, expanded) => match lookup_dictionary same_vertex next visited {' 1 \
    "scheduling must test the threaded visited dictionary before addition"
ash_doc_assert_line_count "$schedule_section" \
    '        Present(ignored_value) => schedule add rest parent state' 1 \
    "a visited neighbor must skip addition and preserve the current state"
ash_doc_assert_line_count "$schedule_section" \
    '                    let next_work = Work(next, More(current, predecessors))' 1 \
    "scheduled work must extend the reverse path with its parent"
ash_doc_assert_before "$schedule_section" \
    '            let next_visited = insert_dictionary next () visited' \
    '                    let next_work = Work(next, More(current, predecessors))' \
    "scheduling must insert before constructing and adding work"
ash_doc_assert_before "$schedule_section" \
    '                    let next_work = Work(next, More(current, predecessors))' \
    '                    let next_frontier = add next_work frontier' \
    "scheduling must construct work before adding it"
ash_doc_assert_line_count "$schedule_section" \
    '                    let next_pending = Next(pending)' 1 \
    "accepted scheduling must increment pending exactly once"
ash_doc_assert_before "$schedule_section" \
    '                    let next_frontier = add next_work frontier' \
    '                    let next_pending = Next(pending)' \
    "accepted scheduling must add work before incrementing pending"
ash_doc_assert_before "$schedule_section" \
    '                    let next_pending = Next(pending)' \
    '                    let next_maximum = retain_greater next_pending maximum' \
    "accepted scheduling must update maximum from next_pending"
readonly expected_successor=$'                    let next_state = SearchState(\n                        next_frontier,\n                        next_visited,\n                        next_pending,\n                        next_maximum,\n                        expanded\n                    )\n                    schedule add rest parent next_state'
ash_doc_assert_contains "$schedule_section" "$expected_successor" \
    "scheduling must recurse from the complete successor state"

continue_section=$(ash_doc_section "$library" \
    'continue_search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> Dictionary<Vertex, Unit> -> Natural -> Natural -> Int -> Option<(Work, F)> -> SearchResult' \
    'search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> SearchState<F> -> SearchResult')
readonly continue_section
ash_doc_assert_line_count "$continue_section" \
    'continue_search add remove target visited pending maximum expanded Absent = Missing(expanded, maximum)' 1 \
    "an empty removal must report expansions and maximum as Missing"
ash_doc_assert_line_count "$continue_section" \
    '    let later_pending = decrement pending' 1 \
    "successful removal must decrement pending before target testing"
ash_doc_assert_before "$continue_section" \
    '    let later_pending = decrement pending' \
    '    match same_vertex current target {' \
    "successful removal must decrement pending before target testing"
ash_doc_assert_line_count "$continue_section" \
    '        true => Found(forward_path (Work(current, predecessors)), expanded, maximum)' 1 \
    "target removal must not count as a completed expansion"
readonly expected_expansion=$'            let next_state = SearchState(\n                later_frontier,\n                visited,\n                later_pending,\n                maximum,\n                expanded + 1\n            )'
ash_doc_assert_contains "$continue_section" "$expected_expansion" \
    "a non-target removal must increment expanded in its successor state"
ash_doc_assert_before "$continue_section" \
    '        true => Found(forward_path (Work(current, predecessors)), expanded, maximum)' \
    '            let next_state = SearchState(' \
    "the target test must return Found before any expansion"
ash_doc_assert_line_count "$continue_section" \
    '            let scheduled = schedule add (neighbors current) (Work(current, predecessors)) next_state' 1 \
    "a non-target removal must schedule the current ordered neighbors"
ash_doc_assert_line_count "$continue_section" \
    '            search add remove target scheduled' 1 \
    "search must continue from the fully scheduled successor state"

search_section=$(ash_doc_section "$library" \
    'search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> SearchState<F> -> SearchResult' \
    'pub depth_first : Vertex -> Vertex -> SearchResult')
readonly search_section
readonly expected_search=$'search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> SearchState<F> -> SearchResult\nsearch add remove target SearchState(frontier, visited, pending, maximum, expanded) = {\n    let removed = remove frontier\n    continue_search add remove target visited pending maximum expanded removed\n}'
[[ $search_section == "$expected_search" ]] ||
    ash_doc_fail "search must delegate the exhaustive remove result to continue_search"

depth_section=$(ash_doc_section "$library" \
    'pub depth_first : Vertex -> Vertex -> SearchResult' \
    'pub breadth_first : Vertex -> Vertex -> SearchResult')
breadth_section=$(ash_doc_section "$library" \
    'pub breadth_first : Vertex -> Vertex -> SearchResult' '')
readonly depth_section breadth_section
ash_doc_assert_line_count "$depth_section" \
    '    let visited = insert_dictionary start () (empty_dictionary ())' 1 \
    "depth_first must mark start before adding initial work"
ash_doc_assert_line_count "$breadth_section" \
    '    let visited = insert_dictionary start () (empty_dictionary ())' 1 \
    "breadth_first must mark start before adding initial work"
ash_doc_assert_before "$depth_section" '    let visited = insert_dictionary start () (empty_dictionary ())' \
    '    let initial_work = Work(start, End)' \
    "depth_first must mark start before adding initial work"
ash_doc_assert_before "$depth_section" '    let initial_work = Work(start, End)' \
    '    let frontier = stack_add initial_work End' \
    "depth_first must add its initial work to the list stack"
ash_doc_assert_before "$depth_section" '    let frontier = stack_add initial_work End' \
    '    let initial_size = Next(Zero)' \
    "depth_first must count one initial pending work item"
ash_doc_assert_before "$depth_section" '    let initial_size = Next(Zero)' \
    '    let initial_state = SearchState(frontier, visited, initial_size, initial_size, 0)' \
    "depth_first must initialize pending and maximum to one and expanded to zero"
ash_doc_assert_line_count "$depth_section" \
    '    search stack_add stack_remove target initial_state' 1 \
    "depth_first must use the list stack operation pair"
ash_doc_assert_before "$breadth_section" '    let visited = insert_dictionary start () (empty_dictionary ())' \
    '    let initial_work = Work(start, End)' \
    "breadth_first must mark start before adding initial work"
ash_doc_assert_before "$breadth_section" '    let initial_work = Work(start, End)' \
    '    let frontier = queue_add initial_work (queue_empty ())' \
    "breadth_first must add its initial work to the paired-list queue"
ash_doc_assert_before "$breadth_section" '    let frontier = queue_add initial_work (queue_empty ())' \
    '    let initial_size = Next(Zero)' \
    "breadth_first must count one initial pending work item"
ash_doc_assert_before "$breadth_section" '    let initial_size = Next(Zero)' \
    '    let initial_state = SearchState(frontier, visited, initial_size, initial_size, 0)' \
    "breadth_first must initialize pending and maximum to one and expanded to zero"
ash_doc_assert_line_count "$breadth_section" \
    '    search queue_add queue_remove target initial_state' 1 \
    "breadth_first must use the paired-list queue operation pair"

ash_doc_assert_line_count "$found_source" \
    '    Searches.depth_first Searches.Start Searches.Goal,' 1 \
    "the found-path entry must target Goal twice"
ash_doc_assert_line_count "$found_source" \
    '    Searches.breadth_first Searches.Start Searches.Goal' 1 \
    "the found-path entry must target Goal twice"
ash_doc_assert_line_count "$missing_source" \
    '    Searches.depth_first Searches.Start Searches.Isolated,' 1 \
    "the exhaustion entry must target Isolated twice"
ash_doc_assert_line_count "$missing_source" \
    '    Searches.breadth_first Searches.Start Searches.Isolated' 1 \
    "the exhaustion entry must target Isolated twice"

ash_doc_assert_sha256 "$library" "$library_hash" \
    "searches.ash must retain its exact complete source"
ash_doc_assert_sha256 "$found_entry" "$found_hash" \
    "01-found-paths.ash must retain its exact complete source"
ash_doc_assert_sha256 "$missing_entry" "$missing_hash" \
    "02-unreachable-cycle.ash must retain its exact complete source"

ash_doc_run_accepted "$unit_root" src/01-found-paths.ash "$found_output"
ash_doc_run_accepted "$unit_root" src/02-unreachable-cycle.ash "$missing_output"

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_assert_displayed_source src/searches.ash \
    "displayed Ash must agree exactly with src/searches.ash"
ash_doc_assert_displayed_source src/01-found-paths.ash \
    "displayed Ash must agree exactly with src/01-found-paths.ash"
ash_doc_assert_displayed_source src/02-unreachable-cycle.ash \
    "displayed Ash must agree exactly with src/02-unreachable-cycle.ash"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"

ash_doc_assert_readme_phrase \
    'The cycle belongs to the graph relation, not to a cyclic Ash value.' \
    "missing prose contract: graph relation cycle is not cyclic Ash data"
ash_doc_assert_readme_phrase \
    'Marking a vertex before adding its work prevents repeated scheduling; it does not by itself make a path shortest.' \
    "missing prose contract: marking does not itself make a path shortest"
ash_doc_assert_readme_phrase \
    'FIFO removal keeps first-discovery paths in nondecreasing directed-edge distance.' \
    "missing prose contract: FIFO preserves nondecreasing directed-edge distance"
ash_doc_assert_readme_phrase \
    'Maximum pending entries count frontier work items, not their retained paths or the visited dictionary.' \
    "missing prose contract: maximum pending excludes paths and dictionary"
# The literal Markdown backticks in these contracts are intentional.
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase \
    'For `b >= 1` and DFS discovery-tree edge depth `d`, the stack holds at most `1 + d(b - 1)` pending entries.' \
    "missing prose contract: DFS pending bound"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase \
    'During BFS layer `i`, pending entries are at most `L_i + L_(i + 1)`, and therefore at most `2W` when `W` is the greatest layer size.' \
    "missing prose contract: BFS pending bound"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase \
    'One BFS run follows a linear queue history that starts from `empty`; retained branching is outside that queue bound.' \
    "missing prose contract: queue bound excludes retained branching"
ash_doc_assert_readme_phrase \
    'The named counts establish no elapsed time, machine instructions, native-stack behavior, heap bytes, allocation count, pointer identity, physical sharing, garbage collection, or compiler optimization.' \
    "missing prose contract: named counts exclude runtime measurements"
ash_doc_assert_text_line_once "$found_output" \
    "the found output must appear exactly once in a text fence"
ash_doc_assert_text_line_once "$missing_output" \
    "the missing output must appear exactly once in a text fence"

printf 'Verified 3 source file(s) at %s.\n' "$expected_pin"
