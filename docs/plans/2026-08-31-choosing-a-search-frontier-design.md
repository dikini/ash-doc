# Choosing a search frontier design

Status: approved on 2026-08-31 after independent specification and
instructional/workflow review

## Reader question and observable boundary

**Question:** How does frontier representation change a search algorithm?

Case 10 turned unfinished tree traversal into an explicit LIFO stack. Case 11
gave the path a persistent FIFO queue. The final recursive-algorithm case puts
those representations behind the same search transition and asks what changes
when the next work item is the latest addition rather than the earliest.

The crossed boundary is one finite directed graph searched through two
frontiers. The observable result contains:

- the start-to-target path, when one is found;
- the number of non-target vertices whose adjacency was expanded; and
- the greatest logical number of pending frontier entries, represented by a
  recursive `Natural`.

Those observations do not measure elapsed time, runtime memory, native stack
frames, heap bytes, allocation, or physical sharing.

## Sequence and outcome

The reader already knows:

- finite nominal lists and recursive `Natural` values;
- higher-order globals whose function arguments select one operation;
- a persistent list dictionary with explicit equality;
- explicit eager pending state;
- a persistent paired-list FIFO queue and its linear-history boundary; and
- the difference between named source work and implementation performance.

The case adds one idea: one search state transition can use ordinary add and
remove functions to choose a LIFO or FIFO frontier. A reader completes the
case able to:

- derive deterministic DFS and BFS paths from adjacency order and frontier
  operations;
- state the visited, retained-path, and pending-count invariants;
- explain why a graph edge cycle does not repeatedly expand a vertex;
- derive why FIFO removal returns a shortest unweighted path while the same
  discovered rule with a stack need not;
- measure one fixed search's greatest pending frontier; and
- keep frontier entries, retained paths, visited-dictionary work, unary
  instrumentation, and queue work in separate accounts.

The case belongs at `content/cases/choosing-a-search-frontier/`. Its lesson,
three complete canonical sources, and local verifier land together only after
this design and its implementation plan are approved.

## Authority and exact target

The target remains the published Modular Ash checkpoint:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

The immutable ash-doc `modular-ash` tag remains at
`e963a1597176f86003926eef827498db2a661b75`. Case 12 is unpublished work on
`main`; it does not move the tag or retarget the edition.

Language claims are limited to the pinned:

- [specification
  overview](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md)
  for pure modules, rank-1 functions, nominal data, ordinary recursion, and
  the entry contract;
- [imports and
  namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces),
  [type and constructor
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope),
  and [public, private, and opaque
  declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations)
  for the dependency and its public boundary;
- static [tuples and
  constructors](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors),
  [functions and
  application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application),
  [patterns, matches, and
  coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage),
  [blocks](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks),
  and [globals and
  modules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules);
- dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches),
  and [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation).

Invocation, successful output, channels, and exit status come from the pinned
[`ash` tool
guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md).
The graph and algorithms are program designs. They cannot define Ash language
behavior.

## Approaches considered

### One higher-order engine

The selected approach defines one private rank-1 search engine. Ordinary
function arguments supply add and remove operations over an abstract frontier
type `F`. Public wrappers instantiate `F` as a list stack or paired-list queue.

The graph, visited timing, path extension, target test, counters, and recursive
transition occur once. The only selected difference is the supplied frontier
behavior. This continues the higher-order model introduced by the first Cases
chapter without requiring an interface or runtime strategy value.

The signature alone cannot prove the frontier or state invariants. The
concrete add and remove equations, initial states, and verifier establish them.

### Parallel DFS and BFS loops

A second approach would share support types and scheduling helpers but write
two recursive loops. Each loop would be locally direct. It would also duplicate
the target rule, visited threading, path conversion, and counter transitions.
The verifier would then need relationship checks to prevent the two invariants
from drifting.

This is rejected because the duplicated control would weaken the causal
comparison without teaching another idea.

### One tagged frontier value

A third approach would put stack and queue representations under constructors
of one `Frontier` type, then branch inside common add and remove functions. It
would avoid higher-order arguments, but it would make the representation choice
a runtime tag and keep irrelevant cases in every operation.

This is rejected because the case compares two selected representations, not
a runtime-configurable search service. Deferring the choice would leave the
final roadmap outcome without a bounded executable comparison.

## Public and private boundary

The dependency exposes only the types clients need to supply vertices and
observe results:

```text
pub type Vertex =
    Start | Short | LongOne | LongTwo
    | WideOne | WideTwo | Goal | Isolated

pub type List<A> = End | More(A, List<A>)
pub type Natural = Zero | Next(Natural)

pub type SearchResult =
    Missing(Int, Natural)
    | Found(List<Vertex>, Int, Natural)

pub depth_first : Vertex -> Vertex -> SearchResult
pub breadth_first : Vertex -> Vertex -> SearchResult
```

This is design notation; the implementation plan owns exact accepted Ash
formatting. In a result, `Int` is the count of completed non-target expansions
and `Natural` is the greatest logical pending-frontier count.

`Option`, `Entry`, `Dictionary`, `Work`, `SearchState<F>`, `Queue<A>`, and all
helpers remain private. Constructor spellings are unique throughout the
module, as required by the pinned constructor namespace. The public boundary
does not make the result an abstract proof: clients can construct transparent
result values, while only the search equations establish the observations.

## Fixed finite graph

The case uses one finite directed unweighted graph. Its adjacency equations
return neighbors in this exact order:

| Vertex | Neighbor list |
| --- | --- |
| `Start` | `Short`, `LongOne` |
| `Short` | `WideOne`, `WideTwo`, `Goal` |
| `LongOne` | `LongTwo` |
| `LongTwo` | `Start`, `Goal` |
| `WideOne` | empty |
| `WideTwo` | empty |
| `Goal` | empty |
| `Isolated` | empty |

`LongTwo -> Start` forms a graph-theoretic cycle. No Ash value points back to
itself. Each `neighbors` call constructs or returns one finite list, so the
pinned recursive-data rules and `<cycle>` observation are not the explanation
for this case.

The unique shortest directed path from `Start` to `Goal` is
`Start, Short, Goal`, with two edges. The other path used by the example is
`Start, LongOne, LongTwo, Goal`, with three edges. `Isolated` is not reachable
from `Start`.

## Work item and state relationships

A private work item has the conceptual representation:

```text
Work(current, reverse_predecessors)
```

`reverse_predecessors` begins with the parent of `current` and ends with the
start vertex. `Work(Start, End)` therefore denotes the one-vertex start path
without constructing a path `More`. Scheduling `next` from
`Work(current, predecessors)` constructs:

```text
Work(next, More(current, predecessors))
```

That is a valid path one directed edge longer. A found path is constructed in
forward order by reversing the predecessor list into `More(current, End)`.

The explicit generic state is conceptually:

```text
SearchState(frontier, visited, pending, maximum, expanded)
```

Its invariant is:

- every frontier work item denotes a valid path from the start;
- `visited` contains exactly the vertices already scheduled, including the
  start;
- no vertex has more than one pending or previously removed work item;
- `pending` equals the logical number of frontier entries;
- `maximum` is the greatest `pending` observed since initialization; and
- `expanded` counts removed non-target vertices whose adjacency has been
  entered.

The supplied operations and initial states preserve this relationship. The
generic type does not enforce it for arbitrary callers.

## Exact state transition

Both public searches first insert `start` into an empty list dictionary, then
add `Work(start, End)` to an empty concrete frontier. Their initial state has:

```text
pending = Next(Zero)
maximum = Next(Zero)
expanded = 0
```

The private search engine receives ordinary `add` and `remove` functions. Its
conceptual rank-1 signature is:

```text
search :
    (Work -> F -> F) ->
    (F -> Option<(Work, F)>) ->
    Vertex ->
    SearchState<F> ->
    SearchResult
```

One transition follows this exact order:

1. Remove one work item. An empty frontier returns
   `Missing(expanded, maximum)`.
2. For a successful removal, decrement `pending` before testing the target.
3. If the removed current vertex equals the target, construct the forward path
   and return `Found(path, expanded, maximum)`. The target is not expanded.
4. Otherwise increment `expanded`, obtain the current vertex's finite neighbor
   list, and schedule it from head to tail.
5. Continue recursively with the complete returned successor state.

For each neighbor, scheduling looks it up in the threaded visited dictionary.
A present neighbor leaves the state unchanged. For an absent neighbor it:

1. inserts the neighbor into `visited`;
2. constructs its extended `Work` item;
3. adds that work item to the frontier;
4. constructs `Next(pending)`;
5. updates `maximum` after that addition; and
6. continues with the remaining neighbors and the updated state.

The maximum helper recursively compares two `Natural` values and returns one
existing operand. It does not make the unary measurement free.

Scheduling `Short` and then `LongOne` from `Start` puts `LongOne` at the front
of the list stack but leaves `Short` earlier in the queue's logical order.
More generally, head-to-tail scheduling preserves neighbor consumption order
for the queue and reverses it for the stack.

## Canonical executable evidence

The bounded case owns exactly three canonical source files:

```text
content/cases/choosing-a-search-frontier/src/searches.ash
content/cases/choosing-a-search-frontier/src/01-found-paths.ash
content/cases/choosing-a-search-frontier/src/02-unreachable-cycle.ash
```

`searches.ash` contains the complete graph, support representations, generic
engine, and public wrappers. It has no `main`. The two entries import it.

The first entry searches from `Start` to `Goal` with both wrappers. Its fixed
design prediction is:

<!-- markdownlint-disable MD013 -->
```text
(Found(More(Start, More(LongOne, More(LongTwo, More(Goal, End)))), 3, Next(Next(Zero))), Found(More(Start, More(Short, More(Goal, End))), 5, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
```
<!-- markdownlint-enable MD013 -->

DFS expands `Start`, `LongOne`, and `LongTwo` before removing `Goal`. Its
largest stack has two entries. BFS expands `Start`, `Short`, `LongOne`,
`WideOne`, and `WideTwo` before removing `Goal`. Its largest queue has four
entries.

The second entry searches from `Start` to unreachable `Isolated`. Its fixed
design prediction is:

<!-- markdownlint-disable MD013 -->
```text
(Missing(7, Next(Next(Zero))), Missing(7, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
```
<!-- markdownlint-enable MD013 -->

Both searches expand the seven reachable vertices exactly once. Their peaks
remain two and four. The implementation plan must prototype these predictions
at the exact pin before treating them as tool observations.

Output alone cannot prove the graph equations, discovered timing, unique
scheduling, state invariant, or frontier operations. The local verifier must
assert those causal source relationships.

## Shortest-path derivation

Path length means the number of directed edges, not the number of list nodes.
The shortest-path statement is algorithmic and has four premises:

1. Every scheduled work item retains a valid start-to-current path.
2. FIFO removal processes first-discovery work in nondecreasing edge distance
   from the start.
3. Scheduling an unseen neighbor creates a path exactly one edge longer than
   the removed path.
4. Marking before addition retains the first discovered path for each vertex;
   a later route cannot replace or duplicate it.

Therefore the first target removed by this BFS has minimum directed-edge
length among start-to-target paths. The fixed graph has a unique shortest path,
so no tie is present. On another graph, adjacency order can choose among
equal-length shortest paths without changing the minimum length.

The fixed DFS uses the same mark-before-add rule and returns the three-edge
path. Its longer result is the negative interaction: discovered marking alone
does not establish shortestness. FIFO layer order is necessary to this proof.

The case makes no shortest-path claim for weighted graphs, nonreturning
adjacency or equality, a priority frontier, or an arbitrary supplied add/remove
pair that violates the invariant.

## Termination and cycle boundary

The fixed `Vertex` type has eight constructors. Every adjacency equation
returns a finite list, and `same_vertex` returns for every pair. The visited
dictionary receives a vertex before its work item enters the frontier, so each
constructor can be scheduled at most once.

The recursive search therefore removes finitely many work items for every
start and target in this fixed graph. On the unreachable observation, the
`LongTwo -> Start` edge finds `Start` already present and does not schedule it
again. The `LongTwo -> Goal` convergence likewise finds the earlier scheduled
`Goal` during BFS.

This is a case-specific termination argument. A generic graph interface,
infinite vertex family, nonreturning equality, cyclic neighbor-list value, or
arbitrary frontier operations would require new premises.

## Separate source-work accounts

The case defines non-overlapping metrics.

**Frontier-entry work** is one logical work-item addition or successful
removal. `pending` and `maximum` count entries, not list nodes, path positions,
or runtime storage. The two `Natural` values are instrumentation in the
explicit state.

**Reverse-path work** counts path-list `More` forms. Initialization uses
`Work(start, End)` and constructs none. Each newly scheduled non-start vertex
constructs exactly one predecessor `More`. For a found path of `l` edges,
`reverse_into predecessors (More(current, End))` selects `l` predecessor nodes
and constructs exactly `l + 1` result nodes. These are source constructions,
not an allocation or sharing claim.

**Visited work** counts one `Entry` and one dictionary-list node for each
discovered vertex. One membership lookup applies `same_vertex` once for every
dictionary entry it inspects through the first match or absence. A candidate
neighbor can therefore require work proportional to the number already
discovered. These traversals remain separate from frontier-entry counts.

**Queue work** uses Case 11's list-node unit: one selected or constructed queue
list `More`. One BFS run begins with an empty queue and follows only returned
successors through enqueue and dequeue. Its queue operations therefore remain
inside the earlier `3e + d` upper bound for `e` enqueues and `d` successful
dequeues on that one history. Path and dictionary nodes are not queue nodes.

**Measurement work** includes constructing `Next(pending)` for every accepted
addition and recursively comparing pending with the retained maximum. This
instrumentation is not part of the uninstrumented frontier operations and is
not free.

The `SearchResult` reports only completed non-target expansions and greatest
pending entries. The remaining accounts are derived from source and fixed by
the verifier.

## General pending-frontier bounds

For the selected push-all-neighbors iterative DFS, let `b >= 1` bound the
number of previously unseen neighbors scheduled by one expansion. Let `d` be
the greatest directed-edge depth reached in its induced DFS discovery tree.
Along one descent, at most `b - 1` pending siblings remain at each depth in
addition to the next active item. The list stack therefore holds at most:

```text
1 + d(b - 1)
```

logical entries, which is `O(bd)`. If no vertex schedules a neighbor, the
initial one-entry state is the separate `b = 0` case.

For BFS, let `L_i` be the number of vertices first discovered at directed-edge
distance `i`. While the queue expands layer `i`, it contains only the
unprocessed suffix of that layer and the discovered prefix of layer `i + 1`.
Its pending count is therefore at most:

```text
L_i + L_(i + 1)
```

If `W` is the greatest layer size, pending is at most `2W`, hence `O(W)`.
Calling one layer size the queue size would omit the two-layer transition.

These are logical entry bounds under the stated discovery-tree and layer
premises. Each entry also retains a path; the visited dictionary and unary
measurement remain separate. No bound describes runtime bytes or native
stack frames.

## Source and adaptation boundary

The focused [graph-search frontier
record](../../research/graph-search-frontiers.md) selects Pat Morin's *Open
Data Structures (in pseudocode)*, edition 0.1G beta, section 12.3 under CC BY
2.5 Canada as conceptual inspiration. It records the material departures from
arrays, predecessor tables, the source's explicit-DFS marking time, and its
runtime theorem.

The Ash graph, state, functions, exact observations, derivations, prose, and
exercises are original. The lesson will credit the source but will not copy or
closely translate its graph, pseudocode, figures, trace, proof presentation,
or exercises.

The existing [recursive-algorithm
record](../../research/how-to-design-programs-recursive-algorithms.md) governs
state invariants and named source work. The [paired-list queue
record](../../research/persistent-paired-list-queue.md) governs the FIFO
representation and its linear-history limit.

## Teaching shape

The chapter continues the established Cases sequence:

1. Start from the question of choosing the next explicit work item.
2. Draw the one finite graph and its ordered adjacency lists.
3. Derive `Work(current, reverse_predecessors)` and the explicit state
   invariant.
4. Mark the start before placing its initial work item.
5. Derive the shared lookup, mark, extend, add, and count transition.
6. Supply the list-stack add/remove pair and predict its reversed scheduling
   order, longer path, and peak two.
7. Supply the paired-list queue pair and predict its preserved scheduling
   order, shortest path, and peak four.
8. Run and explain the exact found-path observation.
9. Search for `Isolated`, follow the cycle edge into the visited dictionary,
   and run the complete-exhaustion observation.
10. Derive the FIFO shortest-path argument and use the DFS result as its
    negative interaction.
11. Separate frontier, path, dictionary, queue, and instrumentation work before
    stating the general DFS and BFS pending bounds.
12. End at the runtime and scope boundaries rather than proposing another
    recursive-algorithm case.

Practice asks the reader to predict the exact frontier after expanding
`Start`, change adjacency order and predict both paths, account for one skipped
cycle edge, derive the two-layer BFS bound, and explain why maximum frontier
entries omit paths and the visited dictionary.

## Deliberate exclusions

The case introduces no:

- graph library, generic graph interface, shared collection module, manifest,
  renderer, harness replacement, dependency, or CI service;
- mutable array, indexed adjacency table, parent table, or color state;
- weighted, negative-edge, priority, bidirectional, all-pairs, heuristic, or
  concurrent search;
- claim that the higher-order signature enforces valid frontier behavior;
- lazy or infinite adjacency, recursive Ash graph values, or general search
  totality;
- duplicate-path or all-shortest-path enumeration;
- `O(V + E)` runtime theorem for list-dictionary membership;
- amortized queue bound over retained branching from older search states; or
- elapsed time, machine instructions, host or native stack behavior, tail-call
  optimization, heap bytes, allocation counts, pointer identity, physical
  sharing, garbage collection, or compiler representation and optimization.

## Verification and completion

The implementation plan must use verifier-first evidence and name exact source
files, commands, observations, causal assertions, and mutation checks. The
complete case must pass:

- its local Bash verifier at the exact pin;
- both exact accepted outputs with status `0` and empty standard error;
- displayed-source agreement for all three complete canonical files;
- source assertions for the graph, same engine, concrete frontiers, initial
  marking, removal-time target test, left-to-right visited threading,
  insert-before-add order, path extension and reversal, counters, and maximum;
- Bash syntax, ShellCheck, Markdown structure, spelling when available, and
  relative-link checks;
- all Learn and Cases aggregators;
- focused pinned constructor, match, rank-1, import, and CLI tests;
- independent specification and instructional reviews;
- `git diff --check`; and
- exact clean-worktree, tag, target, commit-topology, and merge checks.

The verifier mutation matrix must prove sensitivity to at least: an adjacency
order change; stack/queue substitution; a missing initial mark; marking after
frontier addition; stale visited state between neighbors; duplicate scheduling;
target testing at discovery; target expansion; path extension or reversal
changes; pending decrement, increment, or maximum drift; queue-order or
rear-transfer changes; and removal of each required boundary statement.

Closure updates root and Cases navigation, replaces the active roadmap gate
with one durable verified summary, removes this design and the temporary
implementation plan, and merges a reviewed clean branch locally without
pushing. No successor case is promoted because this outcome closes the current
recursive-algorithms roadmap.
