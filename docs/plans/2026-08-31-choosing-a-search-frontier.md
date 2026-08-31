<!-- markdownlint-disable MD013 -->

# Choosing a Search Frontier Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Publish and verify Case 12, which runs one higher-order graph-search engine with a LIFO list stack and a FIFO paired-list queue and explains why only the FIFO result is a shortest unweighted path.

**Architecture:** One dependency module owns the fixed graph, list dictionary, reverse-path work item, explicit generic state, stack, queue, and rank-1 search engine. Two entry modules observe found and exhausted searches. A lesson-local verifier fixes the exact sources, tool outputs, transition order, state relationships, prose boundaries, and mutation sensitivity.

**Tech Stack:** Modular Ash at `dca16039923475c48025c5f17beadeb6bcb6a4bf`, Bash, the existing `content/checks/lib.sh`, Markdown, Git, Markdownlint, and ShellCheck.

---

Status: approved on 2026-08-31 after independent specification and
instructional/workflow review

## Fixed context and guards

Work only in:

```text
/home/dikini/Projects/ash-doc/.worktrees/choosing-a-search-frontier
```

The feature branch is `choosing-a-search-frontier`. Its immutable reviewed
base is the local Case 11 merge:

```text
c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697
```

The approved Case 12 design commit is:

```text
0139aac3257e490772557234ff1c9a1f1d324233
```

Before each task, confirm `git status --short`, `git branch --show-current`,
and `git rev-parse HEAD`. Do not push. Commit without signing. Preserve the
immutable ash-doc `modular-ash` tag at
`e963a1597176f86003926eef827498db2a661b75` and the Ash target at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`.

Use @writing-ash-documentation for every prose, review, plan, and commit
message. Use @superpowers:test-driven-development for the verifier-first
implementation, @superpowers:systematic-debugging for unexpected failures,
@superpowers:requesting-code-review before closure,
@superpowers:verification-before-completion before success claims, and
@superpowers:finishing-a-development-branch for local integration.

The disposable prototype is retained only until implementation reproduces it:

```text
/tmp/ash-doc-case12-prototype.iclj4D
```

It passed both entries at the exact pin with these hashes:

```text
d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b  searches.ash
98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692  01-found-paths.ash
f1ff38eeceed2e155d6edfad4859af2851ab64521dcbfb8b44ac69d5021c21db  02-unreachable-cycle.ash
```

The first prototype nested four `match` expressions and was rejected by the
pinned tool with `internal.resource.structural-depth`, limit `128`. The parser
assigns weight `32` to each nested match; an inner block crossed the budget.
The fixed source moves the remove result into exhaustive `continue_search`
equations. This is a pinned tool-resource boundary, not Ash language truth or
a regression.

The intended branch has exactly four linear, non-merge commits:

1. `docs: design search frontier choice`
2. `docs: plan search frontier choice`
3. `docs: teach search frontier choice`
4. `docs: verify search frontier choice`

## Exact canonical Ash source

Task 3 writes `content/cases/choosing-a-search-frontier/src/searches.ash`
exactly as follows:

```ash
pub type Vertex =
    Start
    | Short
    | LongOne
    | LongTwo
    | WideOne
    | WideTwo
    | Goal
    | Isolated

pub type List<A> =
    End
    | More(A, List<A>)

pub type Natural =
    Zero
    | Next(Natural)

pub type SearchResult =
    Missing(Int, Natural)
    | Found(List<Vertex>, Int, Natural)

type Option<A> =
    Absent
    | Present(A)

type Entry<K, V> =
    Entry(K, V)

type Dictionary<K, V> =
    NoEntries
    | MoreEntry(Entry<K, V>, Dictionary<K, V>)

type Work =
    Work(Vertex, List<Vertex>)

type SearchState<F> =
    SearchState(F, Dictionary<Vertex, Unit>, Natural, Natural, Int)

type Queue<A> =
    Queue(List<A>, List<A>)

same_vertex : Vertex -> Vertex -> Bool
same_vertex Start Start = true
same_vertex Short Short = true
same_vertex LongOne LongOne = true
same_vertex LongTwo LongTwo = true
same_vertex WideOne WideOne = true
same_vertex WideTwo WideTwo = true
same_vertex Goal Goal = true
same_vertex Isolated Isolated = true
same_vertex ignored_left ignored_right = false

neighbors : Vertex -> List<Vertex>
neighbors Start = More(Short, More(LongOne, End))
neighbors Short = More(WideOne, More(WideTwo, More(Goal, End)))
neighbors LongOne = More(LongTwo, End)
neighbors LongTwo = More(Start, More(Goal, End))
neighbors WideOne = End
neighbors WideTwo = End
neighbors Goal = End
neighbors Isolated = End

empty_dictionary : Unit -> Dictionary<K, V>
empty_dictionary () = NoEntries

insert_dictionary : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
insert_dictionary key value dictionary = MoreEntry(Entry(key, value), dictionary)

lookup_dictionary : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup_dictionary same_key query NoEntries = Absent
lookup_dictionary same_key query MoreEntry(Entry(key, value), rest) = match same_key query key {
    true => Present(value)
    false => lookup_dictionary same_key query rest
}

stack_add : A -> List<A> -> List<A>
stack_add value stack = More(value, stack)

stack_remove : List<A> -> Option<(A, List<A>)>
stack_remove End = Absent
stack_remove More(first, rest) = Present((first, rest))

queue_empty : Unit -> Queue<A>
queue_empty () = Queue(End, End)

queue_add : A -> Queue<A> -> Queue<A>
queue_add value Queue(front, rear) = Queue(front, More(value, rear))

reverse_into : List<A> -> List<A> -> List<A>
reverse_into End reversed = reversed
reverse_into More(first, rest) reversed = {
    reverse_into rest (More(first, reversed))
}

queue_remove : Queue<A> -> Option<(A, Queue<A>)>
queue_remove Queue(End, End) = Absent
queue_remove Queue(More(first, rest), rear) = {
    Present((first, Queue(rest, rear)))
}
queue_remove Queue(End, rear) = {
    let front = reverse_into rear End
    queue_remove (Queue(front, End))
}

decrement : Natural -> Natural
decrement Zero = Zero
decrement Next(rest) = rest

greater : Natural -> Natural -> Bool
greater Zero ignored_right = false
greater Next(ignored_left) Zero = true
greater Next(left) Next(right) = greater left right

retain_greater : Natural -> Natural -> Natural
retain_greater candidate retained = match greater candidate retained {
    true => candidate
    false => retained
}

forward_path : Work -> List<Vertex>
forward_path Work(current, predecessors) = {
    reverse_into predecessors (More(current, End))
}

schedule : (Work -> F -> F) -> List<Vertex> -> Work -> SearchState<F> -> SearchState<F>
schedule add End parent state = state
schedule add More(next, rest) parent state = match state {
    SearchState(frontier, visited, pending, maximum, expanded) => match lookup_dictionary same_vertex next visited {
        Present(ignored_value) => schedule add rest parent state
        Absent => {
            let next_visited = insert_dictionary next () visited
            match parent {
                Work(current, predecessors) => {
                    let next_work = Work(next, More(current, predecessors))
                    let next_frontier = add next_work frontier
                    let next_pending = Next(pending)
                    let next_maximum = retain_greater next_pending maximum
                    let next_state = SearchState(
                        next_frontier,
                        next_visited,
                        next_pending,
                        next_maximum,
                        expanded
                    )
                    schedule add rest parent next_state
                }
            }
        }
    }
}

continue_search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> Dictionary<Vertex, Unit> -> Natural -> Natural -> Int -> Option<(Work, F)> -> SearchResult
continue_search add remove target visited pending maximum expanded Absent = Missing(expanded, maximum)
continue_search add remove target visited pending maximum expanded Present((Work(current, predecessors), later_frontier)) = {
    let later_pending = decrement pending
    match same_vertex current target {
        true => Found(forward_path (Work(current, predecessors)), expanded, maximum)
        false => {
            let next_state = SearchState(
                later_frontier,
                visited,
                later_pending,
                maximum,
                expanded + 1
            )
            let scheduled = schedule add (neighbors current) (Work(current, predecessors)) next_state
            search add remove target scheduled
        }
    }
}

search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> SearchState<F> -> SearchResult
search add remove target SearchState(frontier, visited, pending, maximum, expanded) = {
    let removed = remove frontier
    continue_search add remove target visited pending maximum expanded removed
}

pub depth_first : Vertex -> Vertex -> SearchResult
depth_first start target = {
    let visited = insert_dictionary start () (empty_dictionary ())
    let initial_work = Work(start, End)
    let frontier = stack_add initial_work End
    let initial_size = Next(Zero)
    let initial_state = SearchState(frontier, visited, initial_size, initial_size, 0)
    search stack_add stack_remove target initial_state
}

pub breadth_first : Vertex -> Vertex -> SearchResult
breadth_first start target = {
    let visited = insert_dictionary start () (empty_dictionary ())
    let initial_work = Work(start, End)
    let frontier = queue_add initial_work (queue_empty ())
    let initial_size = Next(Zero)
    let initial_state = SearchState(frontier, visited, initial_size, initial_size, 0)
    search queue_add queue_remove target initial_state
}
```

Write `src/01-found-paths.ash` exactly as follows:

```ash
import searches as Searches

main : Unit -> (Searches.SearchResult, Searches.SearchResult)
main () = (
    Searches.depth_first Searches.Start Searches.Goal,
    Searches.breadth_first Searches.Start Searches.Goal
)
```

Write `src/02-unreachable-cycle.ash` exactly as follows:

```ash
import searches as Searches

main : Unit -> (Searches.SearchResult, Searches.SearchResult)
main () = (
    Searches.depth_first Searches.Start Searches.Isolated,
    Searches.breadth_first Searches.Start Searches.Isolated
)
```

The exact accepted output lines are:

```text
(Found(More(Start, More(LongOne, More(LongTwo, More(Goal, End)))), 3, Next(Next(Zero))), Found(More(Start, More(Short, More(Goal, End))), 5, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
(Missing(7, Next(Next(Zero))), Missing(7, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
```

### Task 1: Activate the implementation plan

**Files:**

- Create: `docs/plans/2026-08-31-choosing-a-search-frontier.md`
- Modify: `docs/project/roadmap.md`

#### Step 1: Confirm the approved design commit

Run:

```bash
set -euo pipefail
test "$(git rev-parse HEAD)" = 0139aac3257e490772557234ff1c9a1f1d324233
test "$(git branch --show-current)" = choosing-a-search-frontier
test -z "$(git status --short)"
```

Expected: all commands return status `0` with no output before the plan files
are changed.

#### Step 2: Add the roadmap authorization

After the design/source-record paragraph in the Case 12 outcome, add:

```markdown
The draft temporary
[implementation plan](../plans/2026-08-31-choosing-a-search-frontier.md)
fixes the canonical files, exact observations, verifier-first sequence,
mutation matrix, review order, and local merge boundary. Independent review
must approve its corrected bytes before it authorizes implementation.
```

#### Step 3: Verify the plan tranche

Run:

```bash
set -euo pipefail
markdownlint-cli2 docs/plans/2026-08-31-choosing-a-search-frontier-design.md docs/plans/2026-08-31-choosing-a-search-frontier.md research/graph-search-frontiers.md docs/project/roadmap.md
test -e docs/project/../plans/2026-08-31-choosing-a-search-frontier.md
git diff --check
git status --short
```

Expected: Markdownlint reports zero errors; whitespace passes; status contains
only this plan and the roadmap modification.

#### Step 4: Obtain independent plan review

Require one specification/implementation review and one
instructional/workflow review of the exact plan and roadmap diff. Resolve every
Critical and Important finding before approval. Record the reviewed commit
topology and exact prototype hashes. Keep the plan and roadmap in draft-review
state while any finding remains open. After both reviewers approve the
corrected bytes, change the plan status to approved and the roadmap paragraph
from draft to approved; require both reviewers to confirm that status-only
delta before staging it.

#### Step 5: Commit the approved plan

```bash
set -euo pipefail
git add docs/plans/2026-08-31-choosing-a-search-frontier.md docs/project/roadmap.md
test -e docs/project/../plans/2026-08-31-choosing-a-search-frontier.md
git diff --cached --name-only | LC_ALL=C sort |
    diff -u <(printf '%s\n' \
        docs/plans/2026-08-31-choosing-a-search-frontier.md \
        docs/project/roadmap.md | LC_ALL=C sort) -
git diff --cached --check
git diff --cached --stat
git diff --cached -- docs/plans/2026-08-31-choosing-a-search-frontier.md docs/project/roadmap.md
git -c commit.gpgsign=false commit -m "docs: plan search frontier choice"
```

Inspect the complete cached diff before committing. Expected: the new commit
has parent `0139aac...` and the branch is clean.

### Task 2: Create the failing local verifier

**Files:**

- Create: `content/cases/choosing-a-search-frontier/checks/verify.sh`
- Create later in the same uncommitted task:
  `content/cases/choosing-a-search-frontier/README.md`
- Create later in the same uncommitted task:
  `content/cases/choosing-a-search-frontier/src/searches.ash`
- Create later in the same uncommitted task:
  `content/cases/choosing-a-search-frontier/src/01-found-paths.ash`
- Create later in the same uncommitted task:
  `content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash`

#### Step 1: Create the case directories and verifier

The verifier must:

- prepare the exact pin with `ash_doc_prepare`;
- require exactly the three declared `.ash` files;
- assert their hashes listed above;
- assert the four public types and exactly two public globals;
- fix the complete `same_vertex` and `neighbors` equations;
- fix list-dictionary insertion and selective lookup;
- fix stack front insertion/removal and the three queue removal equations;
- require `Work(current, predecessors)` and the five-field generic state;
- require head-to-tail scheduling, lookup before insert, insert before work,
  add before count, and maximum update after every accepted addition;
- require the `continue_search` helper that stays below the pinned structural
  depth budget;
- require removal and pending decrement before target testing, exclude the
  target from expansion, and recurse only from the complete successor state;
- require start insertion before initial frontier addition in both wrappers;
- run both exact outputs with status `0` and empty standard error;
- require every displayed Ash block to agree with its canonical source; and
- require the exact prose statements in Task 4.

Implement helpers for exact section extraction, phrase/line count, source-order
assertion, SHA-256 assertion, prose-only phrase assertion, and exact text-line
assertion. Keep semantic assertions before whole-file hashes so mutations fail
with causal messages.

Use these exact constants:

```bash
readonly sources=(
    src/searches.ash
    src/01-found-paths.ash
    src/02-unreachable-cycle.ash
)
readonly library_hash=d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b
readonly found_hash=98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692
readonly missing_hash=f1ff38eeceed2e155d6edfad4859af2851ab64521dcbfb8b44ac69d5021c21db
readonly found_output='(Found(More(Start, More(LongOne, More(LongTwo, More(Goal, End)))), 3, Next(Next(Zero))), Found(More(Start, More(Short, More(Goal, End))), 5, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)'
readonly missing_output='(Missing(7, Next(Next(Zero))), Missing(7, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)'
```

For transition-order checks, extract the `schedule`, `continue_search`,
`search`, `depth_first`, and `breadth_first` sections using adjacent exact
signatures. Compare line numbers from `grep -nF` and require these orders:

```text
schedule: lookup_dictionary < next_visited < next_work < next_frontier
          < next_pending < next_maximum < next_state < recursive schedule
continue_search: decrement < same_vertex < Found/next_state
                 < schedule < recursive search
search: remove frontier < continue_search
each wrapper: insert_dictionary < initial_work < concrete add
              < initial_size < initial_state < search
```

#### Step 2: Run the verifier red

Run:

```bash
set -euo pipefail
bash -n content/cases/choosing-a-search-frontier/checks/verify.sh
bash content/cases/choosing-a-search-frontier/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: Bash syntax passes. The verifier fails with the first missing
canonical source or README message. This is the required RED observation.

Do not commit the incomplete case.

### Task 3: Add the exact canonical sources

**Files:**

- Create: `content/cases/choosing-a-search-frontier/src/searches.ash`
- Create: `content/cases/choosing-a-search-frontier/src/01-found-paths.ash`
- Create: `content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash`

#### Step 1: Copy the approved source exactly

Use the complete code in this plan. Do not refactor, rename, reformat, split,
or broaden it. Confirm the hashes match before running it.

```bash
sha256sum content/cases/choosing-a-search-frontier/src/*.ash
```

Expected: the three hashes match the fixed prototype hashes.

#### Step 2: Run the two entries directly

```bash
set -euo pipefail
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/target/debug/ash content/cases/choosing-a-search-frontier/src/01-found-paths.ash
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/target/debug/ash content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash
```

Expected: the two exact output lines above, with status `0` and no standard
error.

#### Step 3: Run the verifier again

Expected: it now advances through source semantics and execution, then fails
because `README.md` is missing. Do not weaken any assertion to advance it.

### Task 4: Write the complete lesson

**Files:**

- Create: `content/cases/choosing-a-search-frontier/README.md`

#### Step 1: Teach the causal model in this order

Write the chapter under the reader question, not an administrative header:

1. connect Case 10's stack and Case 11's queue to pending graph work;
2. draw the exact finite directed graph and ordered adjacency lists;
3. distinguish the graph relation cycle from cyclic Ash data;
4. derive `Work(current, reverse_predecessors)`;
5. state all five `SearchState` fields and their invariant;
6. derive lookup, mark, path extension, add, pending, and maximum order;
7. explain the generic add/remove boundary and its concrete stack/queue pairs;
8. predict and run the found-path entry;
9. derive the FIFO shortest-path argument and use DFS as the negative case;
10. predict and run the unreachable-cycle entry;
11. define and separate every source-work metric;
12. derive the DFS and BFS logical pending bounds; and
13. close with exact scope and runtime exclusions.

Transclude all three complete canonical sources with hidden source markers.
Do not expose a governing-source inventory, target header, evidence report, or
prototype administration in rendered lesson prose.

#### Step 2: Include these exact prose contracts once outside code/comments

```text
The cycle belongs to the graph relation, not to a cyclic Ash value.
Marking a vertex before adding its work prevents repeated scheduling; it does not by itself make a path shortest.
FIFO removal keeps first-discovery paths in nondecreasing directed-edge distance.
Maximum pending entries count frontier work items, not their retained paths or the visited dictionary.
For `b >= 1` and DFS discovery-tree edge depth `d`, the stack holds at most `1 + d(b - 1)` pending entries.
During BFS layer `i`, pending entries are at most `L_i + L_(i + 1)`, and therefore at most `2W` when `W` is the greatest layer size.
One BFS run follows a linear queue history that starts from `empty`; retained branching is outside that queue bound.
The named counts establish no elapsed time, machine instructions, native-stack behavior, heap bytes, allocation count, pointer identity, physical sharing, garbage collection, or compiler optimization.
```

The final sentence may wrap across Markdown source lines, but its verifier must
normalize or check its two exact clauses without accepting code fences.

#### Step 3: Credit the source tradition

Link the permanent graph-search research record and identify Pat Morin's
*Open Data Structures (in pseudocode)*, edition 0.1G beta, section 12.3, as
conceptual inspiration under CC BY 2.5 Canada. State the departures: equation
graph, list dictionary, retained reverse paths, mark-on-add DFS, and no
`O(V + E)` runtime import. Do not reproduce source expression.

#### Step 4: Make the verifier green

Run the local verifier at the pin. Expected:

```text
Verified 3 source file(s) at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

#### Step 5: Run local quality checks

```bash
set -euo pipefail
bash -n content/cases/choosing-a-search-frontier/checks/verify.sh
shellcheck content/cases/choosing-a-search-frontier/checks/verify.sh
markdownlint-cli2 content/cases/choosing-a-search-frontier/README.md
git diff --check
```

Expected: all pass with no warnings or errors.

### Task 5: Prove verifier sensitivity

**Files:**

- Mutate only a disposable exact copy under a fresh
  `/tmp/ash-doc-case12-mutations.XXXXXX` directory.
- Retain the final matrix log under a fresh
  `/tmp/ash-doc-case12-mutation-log.XXXXXX` file through final branch review.

#### Step 1: Establish the baseline

Mirror enough of `content/` for the copied verifier's relative dependency on
`content/checks/lib.sh`:

```bash
set -euo pipefail
case12_mutation_root=$(mktemp -d /tmp/ash-doc-case12-mutations.XXXXXX)
case12_mutation_log=$(mktemp /tmp/ash-doc-case12-mutation-log.XXXXXX)
readonly case12_mutation_root case12_mutation_log
mkdir -p "$case12_mutation_root/content/cases" "$case12_mutation_root/content/checks"
cp -R content/cases/choosing-a-search-frontier \
    "$case12_mutation_root/content/cases/choosing-a-search-frontier"
cp content/checks/lib.sh "$case12_mutation_root/content/checks/lib.sh"
diff -ru content/cases/choosing-a-search-frontier \
    "$case12_mutation_root/content/cases/choosing-a-search-frontier"
cmp -s content/checks/lib.sh "$case12_mutation_root/content/checks/lib.sh"
bash "$case12_mutation_root/content/cases/choosing-a-search-frontier/checks/verify.sh" \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Record exact lines `mutation_root=<path>`, `mutation_log=<path>`,
`baseline_head=<plan-commit-sha>`, and `ash_pin=<sha>`, followed by copied file
hashes, helper hash, and baseline verifier success in the log. The copied file
hashes bind the still-uncommitted teaching bytes; Task 8 records the committed
final feature identity. Every later copied-verifier invocation uses the
mirrored Case path above.

#### Step 2: Run one mutation at a time

Every mutation must:

1. name its file and exact adjacent-signature function, wrapper, entry, or
   prose scope, then assert its target text occurs exactly once in that scope;
2. change only the disposable copy;
3. run the copied verifier against the clean pin;
4. require nonzero status and the intended first failure;
5. restore the exact file and prove its hash; and
6. leave the copied baseline green before the next mutation.

Use at least this matrix. Each quoted replacement has one exact occurrence in
its named baseline scope. Require the quoted line as the first standard-error
line, including the `verify:` prefix; do not accept an arbitrary nonzero
failure.

| Group | Exact one-change transformation | Expected first failure |
| --- | --- | --- |
| Graph | In `searches.ash`, replace `More(Short, More(LongOne, End))` with `More(LongOne, More(Short, End))`. | `verify: Start neighbors must schedule Short before LongOne` |
| Graph | Replace `More(Start, More(Goal, End))` with `More(Goal, End)`. | `verify: LongTwo neighbors must retain the edge back to Start before Goal` |
| Equality | Replace `same_vertex Goal Goal = true` with `same_vertex Goal Goal = false`. | `verify: Goal must compare equal to itself` |
| Dictionary | Replace `MoreEntry(Entry(key, value), dictionary)` with `MoreEntry(Entry(key, value), NoEntries)`. | `verify: dictionary insertion must retain the prior dictionary` |
| Dictionary | Replace `lookup_dictionary same_key query rest` with `lookup_dictionary same_key query NoEntries`. | `verify: failed dictionary equality must continue through the rest` |
| Visited | Within the adjacent-signature `depth_first` definition, replace `insert_dictionary start () (empty_dictionary ())` with `empty_dictionary ()`. | `verify: depth_first must mark start before adding initial work` |
| Visited | Within the adjacent-signature `breadth_first` definition, make the same replacement. | `verify: breadth_first must mark start before adding initial work` |
| Visited | Move the `next_visited` binding below `next_frontier`. | `verify: scheduling must insert before constructing and adding work` |
| Visited | Replace the final `next_state` argument in `schedule add rest parent next_state` with `state`. | `verify: scheduling must recurse from the complete successor state` |
| Visited | Replace `lookup_dictionary same_vertex next visited` with `lookup_dictionary same_vertex next (empty_dictionary ())`. | `verify: scheduling must test the threaded visited dictionary before addition` |
| Frontier | Replace the DFS `search stack_add stack_remove` pair with `search queue_add queue_remove`. | `verify: depth_first must use the list stack operation pair` |
| Frontier | Replace the BFS `search queue_add queue_remove` pair with `search stack_add stack_remove`. | `verify: breadth_first must use the paired-list queue operation pair` |
| Stack | Replace `More(value, stack)` with `More(value, End)`. | `verify: stack_add must retain the old stack as its tail` |
| Queue | Replace `Queue(front, More(value, rear))` with `Queue(More(value, front), rear)`. | `verify: queue_add must prepend only to the rear list` |
| Queue | Replace `queue_remove Queue(End, End) = Absent` with `queue_remove Queue(End, End) = queue_remove (Queue(End, End))`. | `verify: queue_remove must report an empty pair as absent` |
| Queue | Replace `Queue(front, End)` in the transfer equation with `Queue(front, rear)`. | `verify: queue transfer must clear the rear before recursive removal` |
| Path | Replace `More(current, predecessors)` in `next_work` with `predecessors`. | `verify: scheduled work must extend the reverse path with its parent` |
| Path | Replace `reverse_into predecessors (More(current, End))` with `More(current, predecessors)`. | `verify: found paths must reverse their retained predecessors` |
| State | Replace `let later_pending = decrement pending` with `let later_pending = pending`. | `verify: successful removal must decrement pending before target testing` |
| State | Replace `let next_pending = Next(pending)` with `let next_pending = pending`. | `verify: accepted scheduling must increment pending exactly once` |
| State | Replace `retain_greater next_pending maximum` with `maximum`. | `verify: accepted scheduling must update maximum from next_pending` |
| State | Replace the found result's `expanded` with `expanded + 1`. | `verify: target removal must not count as a completed expansion` |
| Engine | Replace the canonical `search` signature and definition with the exact non-canonical mutation fragment below. | `verify: search must delegate the exhaustive remove result to continue_search` |
| Target | Add `Vertex` as a target parameter to the `schedule` signature. | `verify: schedule must not receive or test the target at discovery` |
| Entry | Replace the exact line `Searches.depth_first Searches.Start Searches.Goal,` with `Searches.depth_first Searches.Start Searches.Isolated,` in `01-found-paths.ash`. | `verify: the found-path entry must target Goal twice` |
| Entry | Replace the exact line `Searches.depth_first Searches.Start Searches.Isolated,` with `Searches.depth_first Searches.Start Searches.Goal,` in `02-unreachable-cycle.ash`. | `verify: the exhaustion entry must target Isolated twice` |
| README | Remove the graph-cycle contract. | `verify: missing prose contract: graph relation cycle is not cyclic Ash data` |
| README | Remove the mark-before-add negative contract. | `verify: missing prose contract: marking does not itself make a path shortest` |
| README | Remove the FIFO-distance contract. | `verify: missing prose contract: FIFO preserves nondecreasing directed-edge distance` |
| README | Remove the pending-metric contract. | `verify: missing prose contract: maximum pending excludes paths and dictionary` |
| README | Remove the DFS-bound contract. | `verify: missing prose contract: DFS pending bound` |
| README | Remove the BFS-bound contract. | `verify: missing prose contract: BFS pending bound` |
| README | Remove the linear-queue-history contract. | `verify: missing prose contract: queue bound excludes retained branching` |
| README | Remove the measurement-exclusion contract. | `verify: missing prose contract: named counts exclude runtime measurements` |
| Evidence | Alter the found-output text line. | `verify: the found output must appear exactly once in a text fence` |
| Evidence | Alter the missing-output text line. | `verify: the missing output must appear exactly once in a text fence` |
| Evidence | Alter one displayed line from `searches.ash`. | `verify: displayed Ash must agree exactly with src/searches.ash` |
| Evidence | Alter one displayed line from `01-found-paths.ash`. | `verify: displayed Ash must agree exactly with src/01-found-paths.ash` |
| Evidence | Alter one displayed line from `02-unreachable-cycle.ash`. | `verify: displayed Ash must agree exactly with src/02-unreachable-cycle.ash` |

Add a logged mutation and exact first failure for every additional semantic
assertion introduced while implementing the verifier. Do not use a passing
whole-file hash as the only evidence for a causal rule.

The engine mutation fragment is exact. It is a disposable complete definition,
not canonical lesson source:

```text
search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> SearchState<F> -> SearchResult
search add remove target state = match state {
    SearchState(frontier, visited, pending, maximum, expanded) => match remove frontier {
        Absent => Missing(expanded, maximum)
        Present((work, later_frontier)) => match work {
            Work(current, predecessors) => {
                let later_pending = decrement pending
                match same_vertex current target {
                    true => Found(forward_path (Work(current, predecessors)), expanded, maximum)
                    false => {
                        let next_state = SearchState(
                            later_frontier,
                            visited,
                            later_pending,
                            maximum,
                            expanded + 1
                        )
                        let scheduled = schedule add (neighbors current) (Work(current, predecessors)) next_state
                        search add remove target scheduled
                    }
                }
            }
        }
    }
}
```

When substituted into the otherwise canonical prototype, this exact fragment
produces status `2`, empty standard output, first standard-error line
`internal.resource.structural-depth`, and limit `128` at the pin. The mutation
audit still requires the verifier's causal delegation message to be first.

#### Step 3: Record final restoration

The log must show every mutation failed as intended, every source was restored,
the copied verifier ended green, and the mutation tree matched the feature
branch again.

### Task 6: Commit the complete teaching increment

**Files:**

- Create: `content/cases/choosing-a-search-frontier/README.md`
- Create: `content/cases/choosing-a-search-frontier/checks/verify.sh`
- Create: the three canonical sources

#### Step 1: Read every new file completely

Check the prose as source, not only rendered output. Confirm code fences match
the canonical files, attribution is accurate, and facts/proposals/tool
pressure retain their status.

#### Step 2: Run the local verifier and checks

Run the pinned local verifier, then repeat Task 4 Step 5 and require success:

```bash
set -euo pipefail
bash content/cases/choosing-a-search-frontier/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/choosing-a-search-frontier/checks/verify.sh
shellcheck content/cases/choosing-a-search-frontier/checks/verify.sh
markdownlint-cli2 content/cases/choosing-a-search-frontier/README.md
git diff --check
```

#### Step 3: Commit

```bash
set -euo pipefail
git add content/cases/choosing-a-search-frontier
git diff --cached --name-only | LC_ALL=C sort |
    diff -u <(printf '%s\n' \
        content/cases/choosing-a-search-frontier/README.md \
        content/cases/choosing-a-search-frontier/checks/verify.sh \
        content/cases/choosing-a-search-frontier/src/searches.ash \
        content/cases/choosing-a-search-frontier/src/01-found-paths.ash \
        content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash |
        LC_ALL=C sort) -
git diff --cached --check
git diff --cached --stat
git diff --cached -- content/cases/choosing-a-search-frontier
git -c commit.gpgsign=false commit -m "docs: teach search frontier choice"
```

Inspect the complete cached diff before committing. Expected: this is the
third linear feature commit; it adds exactly five files and leaves navigation
and roadmap closure for the fourth commit.

### Task 7: Close Case 12 and the recursive-algorithms roadmap

**Files:**

- Modify: `README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-31-choosing-a-search-frontier-design.md`
- Delete: `docs/plans/2026-08-31-choosing-a-search-frontier.md`

#### Step 1: Update root and Cases navigation

Change eleven verified Cases to twelve. Add Case 12 after the persistent FIFO
frontier and summarize only its reader outcome: one shared search transition,
longer LIFO path, shortest FIFO path, cycle guard, and separate pending-state
account. Do not repeat targets or administration in the Cases index.

Require exactly one `content/cases/choosing-a-search-frontier/README.md` link
target in the root README and exactly one
`choosing-a-search-frontier/README.md` link target in the Cases index. The root
must say `twelve verified cases`; the Cases index must number the new reader
question as `12`.

#### Step 2: Replace the active roadmap outcome

Move Case 12 under `## Verified increments` as
`### 12. Choosing a search frontier`. Retain a durable summary of:

- the exact target and three canonical sources;
- both exact results, expansion counts, and peaks;
- the state and mark-before-add relationships;
- the FIFO shortest-path derivation and DFS negative case;
- finite cycle exhaustion;
- the separate path, dictionary, queue, and measurement accounts;
- DFS `1 + d(b - 1)` and BFS `L_i + L_(i + 1) <= 2W` bounds;
- the pinned structural-depth tool pressure and helper-stage response;
- source attribution and exclusions; and
- complete verification evidence.

Remove the `## Next:` gate. State that the recursive-algorithms roadmap has no
outstanding case; a future increment requires a new bounded outcome rather
than implicit promotion.

Change repository state from eleven to twelve unpublished verified recursive
cases. Preserve the promotion policy as historical workflow guidance only if
its wording remains accurate with no active successor.

#### Step 3: Retain the temporary plans for closure review

Keep both Case 12 plan files present while the specification and
instructional reviewers inspect the closure candidate. The final closure
commit removes them only after those two reviews approve. Keep
`research/graph-search-frontiers.md` permanently.

### Task 8: Verify, review, and commit the exact final feature HEAD

#### Step 1: Verify the closure candidate with plans retained

```bash
set -euo pipefail
bash -n content/cases/choosing-a-search-frontier/checks/verify.sh
shellcheck content/cases/choosing-a-search-frontier/checks/verify.sh
markdownlint-cli2 '**/*.md' '#.worktrees/**'
git diff --check
bash content/learn/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: lint and whitespace checks pass, followed by:

```text
Verified 11 lesson(s) at dca16039923475c48025c5f17beadeb6bcb6a4bf.
Verified 12 case(s) at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

`typos` is optional only when installed.

#### Step 2: Run the exact focused pinned tests

```bash
set -euo pipefail
ash_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
readonly ash_pin
git -C "$ash_pin" rev-parse HEAD |
    grep -Fx dca16039923475c48025c5f17beadeb6bcb6a4bf
test -z "$(git -C "$ash_pin" status --short)"
(
    cd "$ash_pin"
    cargo test --locked --test data_and_adts \
        constructor_tuple_payloads_enter_elements_strictly_left_to_right -- --exact
    cargo test --locked --test data_and_adts \
        explicit_match_and_equations_have_equivalent_recursive_coverage -- --exact
    cargo test --locked --test data_and_adts \
        match_trace_enters_the_scrutinee_once_and_only_the_selected_body -- --exact
    cargo test --locked --test module_elaboration_nominals \
        imported_transparent_parameterized_constructor_checks_at_its_type_argument -- --exact
    cargo test --locked --test spec_examples \
        static_semantics_rank_one_polymorphism_is_executable -- --exact
    cargo test --locked --test spec_examples \
        tool_rank_one_example_has_exact_cli_observation -- --exact
    cargo test --locked --test parser \
        structural_depth_budget_bounds_nested_matches -- --exact
    cargo test --locked --test parser \
        structural_depth_budget_bounds_nested_blocks -- --exact
)
```

Expected: every named test passes at the exact clean pin. These focused tests
support, but do not replace, the Case verifier.

#### Step 3: Reproduce the historical structural-depth observation

Require the minimized prototype bytes retained from design work:

```bash
set -euo pipefail
ash_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
readonly ash_pin
printf '%s  %s\n' \
    44fd9b4cee4d46c06927f1875218b386d3163a73dca2cf7a0cc1a503b4cb974a \
    /tmp/ash-doc-case12-debug/four-matches.ash \
    d30092cede522dfcdcf2ec4c5cbb507fac684f827199406ac295e33c5809a317 \
    /tmp/ash-doc-case12-debug/four-matches-block.ash |
    sha256sum --check --strict
resource_stdout=$(mktemp /tmp/ash-doc-case12-resource-stdout.XXXXXX)
resource_stderr=$(mktemp /tmp/ash-doc-case12-resource-stderr.XXXXXX)
readonly resource_stdout resource_stderr
"$ash_pin/target/debug/ash" /tmp/ash-doc-case12-debug/four-matches.ash \
    > "$resource_stdout" 2> "$resource_stderr"
test "$(<"$resource_stdout")" = '1 : Int'
test ! -s "$resource_stderr"
set +e
"$ash_pin/target/debug/ash" /tmp/ash-doc-case12-debug/four-matches-block.ash \
    > "$resource_stdout" 2> "$resource_stderr"
resource_status=$?
set -e
test "$resource_status" -eq 2
test ! -s "$resource_stdout"
test "$(sed -n '1p' "$resource_stderr")" = internal.resource.structural-depth
test "$(sed -n '2p' "$resource_stderr")" = 'limit 128'
rm "$resource_stdout" "$resource_stderr"
```

This gate contracts only status, channels, reason, and limit for the exact
historical reproductions. It does not promote remaining diagnostic layout to
a lesson contract.

#### Step 4: Obtain closure-content reviews with plans retained

Require a specification/authority review, then an instructional/workflow
review, of the complete Case, navigation, permanent research record, roadmap
closure, and both still-present plans. Resolve every Critical and Important
finding and repeat Steps 1 through 3 after any correction. Do not ask either
reviewer to assume the other's result.

#### Step 5: Retire plans, stage exact closure scope, and inspect it

After both closure-content reviewers approve, delete the two temporary plans;
Git history retains them. Then run:

```bash
set -euo pipefail
git add README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-31-choosing-a-search-frontier-design.md \
    docs/plans/2026-08-31-choosing-a-search-frontier.md
git diff --cached --name-only | LC_ALL=C sort |
    diff -u <(printf '%s\n' \
        README.md \
        content/cases/README.md \
        docs/plans/2026-08-31-choosing-a-search-frontier-design.md \
        docs/plans/2026-08-31-choosing-a-search-frontier.md \
        docs/project/roadmap.md | LC_ALL=C sort) -
git diff --cached --check
git diff --cached --stat
git diff --cached -- README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-31-choosing-a-search-frontier-design.md \
    docs/plans/2026-08-31-choosing-a-search-frontier.md
```

Inspect the complete cached diff. Confirm both plans are deletions and the
three durable files are modifications.

#### Step 6: Run the final-tree fail-fast suite before committing

```bash
set -euo pipefail
ash_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
readonly ash_pin
bash -n content/cases/choosing-a-search-frontier/checks/verify.sh
shellcheck content/cases/choosing-a-search-frontier/checks/verify.sh
markdownlint-cli2 '**/*.md' '#.worktrees/**'
git diff --check
git diff --cached --check
bash content/learn/checks/verify.sh "$ash_pin"
bash content/cases/checks/verify.sh "$ash_pin"
test "$(find content/learn -mindepth 3 -maxdepth 3 -type f -path '*/checks/verify.sh' | wc -l)" -eq 11
test "$(find content/cases -mindepth 3 -maxdepth 3 -type f -path '*/checks/verify.sh' | wc -l)" -eq 12
test "$(find content/cases -type f -path '*/src/*.ash' | wc -l)" -eq 53
test "$(git ls-files '*.md' | wc -l)" -eq 43
test -z "$(rg -l '^## Next:' README.md content docs lab research || true)"
test "$(grep -Foc 'content/cases/choosing-a-search-frontier/README.md' README.md)" -eq 1
test "$(grep -Foc 'choosing-a-search-frontier/README.md' content/cases/README.md)" -eq 1
grep -Fq 'twelve verified cases' README.md
grep -Eq '^12\. \[How does frontier representation change a search' content/cases/README.md
test -z "$(rg -l 'plans/2026-08-31-choosing-a-search-frontier(-design)?\.md' README.md content docs lab research || true)"
test ! -e docs/plans/2026-08-31-choosing-a-search-frontier-design.md
test ! -e docs/plans/2026-08-31-choosing-a-search-frontier.md
test "$(git rev-parse modular-ash^{})" = e963a1597176f86003926eef827498db2a661b75
test "$(git -C "$ash_pin" rev-parse HEAD)" = dca16039923475c48025c5f17beadeb6bcb6a4bf
test -z "$(git -C "$ash_pin" status --short)"

relative_link_count=0
while IFS= read -r markdown_file; do
    while IFS= read -r link_token; do
        link_target=${link_token#](}
        link_target=${link_target%)}
        case "$link_target" in
            http://*|https://*|mailto:*|'#'*) continue ;;
        esac
        link_path=${link_target%%#*}
        if [[ ! -e $(dirname "$markdown_file")/$link_path ]]; then
            printf 'broken relative link: %s -> %s\n' "$markdown_file" "$link_target" >&2
            exit 1
        fi
        relative_link_count=$((relative_link_count + 1))
    done < <(grep -oE '\]\([^)]+\)' "$markdown_file" || true)
done < <(git ls-files '*.md')
test "$relative_link_count" -gt 0
printf 'Verified %s relative Markdown link(s).\n' "$relative_link_count"
```

The count is computed from the final index rather than fixed in the verifier.
Expected repository counts are `11 Learn / 12 Cases / 53 Case sources / 43
Markdown files`, with no active `## Next:` gate.

#### Step 7: Commit closure and prove the four-commit feature topology

```bash
set -euo pipefail
git -c commit.gpgsign=false commit -m "docs: verify search frontier choice"
case12_feature_head=$(git rev-parse HEAD)
readonly case12_feature_head
test "$(git branch --show-current)" = choosing-a-search-frontier
test "$(git rev-parse choosing-a-search-frontier)" = "$case12_feature_head"
test "$(git rev-parse HEAD~4)" = c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697
test "$(git rev-parse HEAD~3)" = 0139aac3257e490772557234ff1c9a1f1d324233
test "$(git rev-list --count c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697..HEAD)" -eq 4
test -z "$(git rev-list --merges c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697..HEAD)"
git log --reverse --format='%s' c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697..HEAD |
    diff -u <(printf '%s\n' \
        'docs: design search frontier choice' \
        'docs: plan search frontier choice' \
        'docs: teach search frontier choice' \
        'docs: verify search frontier choice') -
test "$(git log --format='%G?' c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697..HEAD | LC_ALL=C sort -u)" = N
test -z "$(git status --short)"
git diff --name-only c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697...HEAD |
    LC_ALL=C sort |
    diff -u <(printf '%s\n' \
        README.md \
        content/cases/README.md \
        content/cases/choosing-a-search-frontier/README.md \
        content/cases/choosing-a-search-frontier/checks/verify.sh \
        content/cases/choosing-a-search-frontier/src/searches.ash \
        content/cases/choosing-a-search-frontier/src/01-found-paths.ash \
        content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash \
        docs/project/roadmap.md \
        research/graph-search-frontiers.md | LC_ALL=C sort) -
git cat-file -e HEAD~2:docs/plans/2026-08-31-choosing-a-search-frontier-design.md
git cat-file -e HEAD~2:docs/plans/2026-08-31-choosing-a-search-frontier.md
```

Expected: exactly four unsigned, linear, non-merge feature commits; a clean
worktree; the nine-path final diff; plans absent from the final tree but
retained in history.

#### Step 8: Bind the mutation audit and whole-branch review to final HEAD

Repeat the complete Task 5 mutation matrix from the clean baseline. Record
an exact `feature_head=<sha>` line, the exact pin, copied helper hash, every
intended first failure, restoration, final copied-verifier success, and a
byte-for-byte Case comparison in the retained log. Require the worktree HEAD
and branch ref to remain equal to the last recorded feature head.

Then obtain a whole-branch/code review of that exact commit. Resolve every
Critical and Important finding. If a correction is required, amend or rebuild
the owning local feature commit while retaining exactly four linear commits,
rerun every affected check, repeat the entire final-HEAD mutation audit, and
repeat whole-branch review. The commit recorded by the last audit and approval
is the only feature HEAD eligible for merge.

After whole-branch approval, locate the one retained Case 12 mutation log and
bind that approval durably:

```bash
set -euo pipefail
mapfile -d '' case12_logs < <(find /tmp -maxdepth 1 -type f \
    -name 'ash-doc-case12-mutation-log.*' -print0)
test "${#case12_logs[@]}" -eq 1
case12_mutation_log=${case12_logs[0]}
case12_feature_head=$(git rev-parse HEAD)
logged_feature_head=$(sed -n 's/^feature_head=//p' "$case12_mutation_log" | tail -n 1)
readonly case12_mutation_log case12_feature_head logged_feature_head
test "$logged_feature_head" = "$case12_feature_head"
test "$(git rev-parse choosing-a-search-frontier)" = "$case12_feature_head"
test -z "$(sed -n 's/^reviewed_feature_head=//p' "$case12_mutation_log")"
printf 'reviewed_feature_head=%s\n' "$case12_feature_head" >> "$case12_mutation_log"
test "$(sed -n 's/^reviewed_feature_head=//p' "$case12_mutation_log")" = "$case12_feature_head"
```

The retained log path and its `reviewed_feature_head` line cross the fresh
shell boundary into merge verification; an ambient shell variable does not.

### Task 9: Merge locally and clean temporary state

#### Step 1: Verify topology and scope

Require:

```text
c0930cb... -> 0139aac... -> plan -> teaching -> verification
```

The feature diff against `c0930cb...` contains only:

```text
README.md
content/cases/README.md
content/cases/choosing-a-search-frontier/README.md
content/cases/choosing-a-search-frontier/checks/verify.sh
content/cases/choosing-a-search-frontier/src/searches.ash
content/cases/choosing-a-search-frontier/src/01-found-paths.ash
content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash
docs/project/roadmap.md
research/graph-search-frontiers.md
```

Both temporary plan files must be absent from the final tree but present in
history.

Also require the final mutation log and whole-branch approval to name the same
commit as both the feature worktree HEAD and the
`choosing-a-search-frontier` branch ref.

#### Step 2: Merge without pushing

From the repository root, require clean `main` at the exact Case 11 merge and
the reviewed feature ref before changing state:

```bash
set -euo pipefail
repository_root=/home/dikini/Projects/ash-doc
feature_worktree=/home/dikini/Projects/ash-doc/.worktrees/choosing-a-search-frontier
mapfile -d '' case12_logs < <(find /tmp -maxdepth 1 -type f \
    -name 'ash-doc-case12-mutation-log.*' -print0)
test "${#case12_logs[@]}" -eq 1
case12_mutation_log=${case12_logs[0]}
case12_feature_head=$(sed -n 's/^reviewed_feature_head=//p' \
    "$case12_mutation_log")
readonly repository_root feature_worktree case12_mutation_log case12_feature_head
[[ $case12_feature_head =~ ^[0-9a-f]{40}$ ]]
test "$(git -C "$repository_root" branch --show-current)" = main
test "$(git -C "$repository_root" rev-parse HEAD)" = c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697
test -z "$(git -C "$repository_root" status --short)"
test "$(git -C "$repository_root" rev-parse choosing-a-search-frontier)" = "$case12_feature_head"
test "$(git -C "$feature_worktree" rev-parse HEAD)" = "$case12_feature_head"
test "$(git -C "$feature_worktree" rev-parse HEAD~3)" = 0139aac3257e490772557234ff1c9a1f1d324233
git -C "$repository_root" -c commit.gpgsign=false merge \
    --no-ff --no-edit --no-gpg-sign choosing-a-search-frontier
test "$(git -C "$repository_root" rev-parse HEAD^1)" = c0930cb734ba9b5e50ba5d1ffe12ba8fa6441697
test "$(git -C "$repository_root" rev-parse HEAD^2)" = "$case12_feature_head"
test "$(git -C "$repository_root" log -1 --format='%G?')" = N
test -z "$(git -C "$repository_root" status --short)"
```

Use the default merge message noninteractively and without signing. The exact
reviewed feature HEAD must be the merge's second parent.

#### Step 3: Re-run merged-main verification

From `main`, repeat Task 8 Steps 1 through 3 and the complete final-tree
fail-fast suite, adapting only branch/topology assertions to the merge commit.
Repeat exact tag, pin, scope, counts, relative links, plan absence, zero active
`## Next:` gates, and clean-status checks. Require `HEAD^1` to remain the Case
11 merge and `HEAD^2` to remain the exact reviewed feature HEAD. Do not rely
on feature-branch output.

#### Step 4: Remove disposable state

After merged-main verification succeeds and the official audit has been
recorded, remove only these exact reviewed temporary targets:

- `/tmp/ash-doc-case12-prototype.iclj4D`;
- the exact Case 12 debug reproductions under
  `/tmp/ash-doc-case12-debug`;
- the final Case 12 mutation tree and log;
- `.worktrees/choosing-a-search-frontier`; and
- local branch `choosing-a-search-frontier` after verifying it is merged.

Use non-recursive file deletion where practical, then `rmdir` empty temporary
directories. These disposable files and the deleted local branch name are not
recoverable; feature history remains through the merge commit.

#### Step 5: Final audit

Confirm clean `main`, exact merge parents, immutable tag, exact Ash pin, 12
case verifiers, 53 case sources, no active Case 12 plan, no outstanding roadmap
case, no Case 12 temporary paths, and no push.

<!-- markdownlint-enable MD013 -->
