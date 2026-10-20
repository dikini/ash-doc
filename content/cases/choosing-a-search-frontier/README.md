# Choosing a search frontier

The [resumable traversal case](../resuming-tree-traversal/README.md) stored
unfinished tree work in a list stack. The [queue
case](../implementing-persistent-fifo-frontier/README.md) stored values in
first-in, first-out order. A graph search can use either representation for
the vertices it has discovered but not yet examined. The choice decides which
pending work becomes current next.

We will keep every other search decision fixed. One transition records the
same visited vertices, retained paths, and counts. Ordinary function arguments
supply either list-stack operations or paired-list queue operations. Comparing
the two results will isolate what last-in, first-out and first-in, first-out
removal change.

## Follow one ordered graph

The example graph has eight vertices. Each row gives the complete outgoing
neighbor list in its source order.

| Vertex | Ordered neighbors |
| --- | --- |
| `Start` | `Short`, `LongOne` |
| `Short` | `WideOne`, `WideTwo`, `Goal` |
| `LongOne` | `LongTwo` |
| `LongTwo` | `Start`, `Goal` |
| `WideOne` | none |
| `WideTwo` | none |
| `Goal` | none |
| `Isolated` | none |

The route through `Short` reaches `Goal` in two directed edges. The route
through `LongOne` and `LongTwo` takes three. `Isolated` has no incoming route
from `Start`.

The edge from `LongTwo` back to `Start` forms a cycle in the graph. An Ash
call to `neighbors LongTwo` still returns one finite list whose first element
is `Start` and whose second is `Goal`. No list node points back to an earlier
list node. The cycle belongs to the graph relation, not to a cyclic Ash value.
This distinction follows the pinned [structural observation
rule](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation):
`<cycle>` concerns a repeated location on an active value-rendering path, not
a pair of equations that name one another's vertices.

The graph-search model draws conceptual inspiration from Pat Morin's *Open
Data Structures (in pseudocode)*, edition 0.1G beta, section 12.3, under [CC BY
2.5 Canada](https://creativecommons.org/licenses/by/2.5/ca/). The [research
record](../../../research/graph-search-frontiers.md) preserves the attribution
and comparison. This case departs from that source by using an equation-defined
graph, a list dictionary, retained reverse paths, and mark-on-add DFS. It does
not import the source's `O(V + E)` runtime result.

## Retain enough work to resume

A pending vertex alone cannot produce a path when the target is removed. Pair
it with the path prefix that led to it:

```text
Work(current, reverse_predecessors)
```

The predecessor list starts with the parent of `current` and ends with the
search start. Initial work is `Work(Start, End)`. If that work schedules
`Short`, the new item is `Work(Short, More(Start, End))`. Scheduling `Goal`
from it produces `Work(Goal, More(Short, More(Start, End)))`.

Every such step retains a valid path because `next` came from
`neighbors current`. When the target is removed, `forward_path` reverses the
predecessors into a list that ends with `current`. The result is therefore in
start-to-target order.

The search carries five fields together:

```text
SearchState(frontier, visited, pending, maximum, expanded)
```

They obey one relationship:

- every frontier item retains a valid start-to-current path;
- `visited` contains exactly the vertices that have been scheduled, including
  the start;
- no vertex has more than one pending or previously removed work item;
- `pending` equals the logical number of frontier work items;
- `maximum` is the greatest `pending` value reached so far; and
- `expanded` counts removed non-target vertices whose neighbor list has been
  entered.

The generic type does not enforce this relationship. The initial state and
the transition equations preserve it.

## Derive one scheduling transition

Both searches mark the start in an empty dictionary before adding
`Work(start, End)`. Their `pending` and `maximum` fields start at `Next(Zero)`,
and `expanded` starts at `0`.

After removing an item, the engine decrements `pending` before it tests the
current vertex against the target. A match returns the forward path without
expanding the target. A mismatch increments `expanded` and schedules the
current vertex's neighbors from list head to tail.

For each neighbor, `schedule` performs these steps in order:

1. Look it up in the current threaded `visited` dictionary.
2. If it is present, leave the state unchanged and continue with the rest.
3. If it is absent, insert it before constructing or adding its work.
4. Extend the reverse path with the current vertex.
5. Add the new work item to the frontier.
6. Increment `pending`, retain the greater of that value and `maximum`, and
   continue from the complete successor state.

<!-- markdownlint-disable MD013 -->
Marking a vertex before adding its work prevents repeated scheduling; it does not by itself make a path shortest.
<!-- markdownlint-enable MD013 -->

The dictionary is a front-inserted list of entries. Its failed equality branch
continues through the older entries, so a lookup observes the complete retained
dictionary. The pinned [match and coverage
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#patterns-matches-and-coverage)
check the constructor cases. The pinned [binding
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#bindings)
evaluate each initializer before its successor binding, which supports the
source-order state derivation above.

Only the frontier operations vary. `search` receives an add function and a
remove function over one type `F`. The pinned [rank-1 global
model](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#globals-and-modules)
instantiates that type at each wrapper. `depth_first` supplies `stack_add` and
`stack_remove` over `List<Work>`. `breadth_first` supplies `queue_add` and
`queue_remove` over `Queue<Work>`. The stack prepends and removes at the front.
The queue prepends to its rear list and removes the earliest logical item from
its front, transferring a reversed rear when necessary.

Here is the complete dependency module. Its public boundary contains the four
public data types and two search wrappers. The support types and helpers remain
private under the pinned [declaration visibility
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#public-private-and-opaque-declarations).

<!-- markdownlint-disable MD013 -->
<!-- source: src/searches.ash -->
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
<!-- markdownlint-enable MD013 -->

## Predict the two found paths

Scheduling the `Start` neighbors head to tail first adds `Short`, then
`LongOne`. The stack places each addition at its front, so it removes
`LongOne` next. The queue keeps `Short` ahead of `LongOne` in logical order.

Trace the stack first. It removes and expands `Start`, `LongOne`, and
`LongTwo`, then removes `Goal`. The returned path has three edges, `expanded`
is `3`, and the peak pending count is two.

For the queue, removal proceeds through `Start`, `Short`, `LongOne`,
`WideOne`, and `WideTwo` before `Goal`. The path has two edges, `expanded` is
`5`, and the peak pending count is four. Unary `Natural` values render those
peaks as `Next(Next(Zero))` and
`Next(Next(Next(Next(Zero))))`.

The entry calls both wrappers with the same start and target:

<!-- source: src/01-found-paths.ash -->
```ash
import searches as Searches

main : Unit -> (Searches.SearchResult, Searches.SearchResult)
main () = (
    Searches.depth_first Searches.Start Searches.Goal,
    Searches.breadth_first Searches.Start Searches.Goal
)
```

From the Cases directory, run:

```text
ash choosing-a-search-frontier/src/01-found-paths.ash
```

<!-- markdownlint-disable MD013 -->
```text
(Found(More(Start, More(LongOne, More(LongTwo, More(Goal, End)))), 3, Next(Next(Zero))), Found(More(Start, More(Short, More(Goal, End))), 5, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
```
<!-- markdownlint-enable MD013 -->

The result matches the trace. The pinned [`ash` success
contract](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output)
supplies one standard-output line and status `0`; the structural spelling
comes from the pinned [observation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation).

## Explain why only FIFO proves shortestness

Path length here means directed-edge count. Each work item retains a valid
path, and scheduling a neighbor extends its parent's path by exactly one edge.
<!-- markdownlint-disable MD013 -->
FIFO removal keeps first-discovery paths in nondecreasing directed-edge distance.
<!-- markdownlint-enable MD013 -->
The claim follows by layers: before a distance-`i` item is removed, all
earlier pending items have distance at most `i`; its newly scheduled neighbors
have distance `i + 1` and enter after those items. Marking before addition
retains the first path discovered for each vertex, so no later path replaces
it. The first target removed by this queue therefore has minimum edge length.

The stack preserves the same path-validity and visited relationships, but it
removes the most recent addition. On this graph it enters the three-edge route
while the two-edge route remains pending. That observed longer DFS path is the
negative case: visited timing prevents duplicate work, while FIFO layer order
establishes shortestness. The argument covers this finite unweighted directed
graph and other searches with the same premises. It does not cover weighted
edges or an arbitrary add/remove pair.

## Exhaust the reachable graph

Now predict what happens when the target is `Isolated`. Both searches must
empty their frontier. When `LongTwo` offers `Start`, dictionary lookup finds
the initial mark and skips that edge. Other converging edges likewise cannot
schedule a second work item for an already visited vertex.

<!-- source: src/02-unreachable-cycle.ash -->
```ash
import searches as Searches

main : Unit -> (Searches.SearchResult, Searches.SearchResult)
main () = (
    Searches.depth_first Searches.Start Searches.Isolated,
    Searches.breadth_first Searches.Start Searches.Isolated
)
```

Run the second entry:

```text
ash choosing-a-search-frontier/src/02-unreachable-cycle.ash
```

<!-- markdownlint-disable MD013 -->
```text
(Missing(7, Next(Next(Zero))), Missing(7, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
```
<!-- markdownlint-enable MD013 -->

Seven vertices are reachable from `Start`, and each is expanded once because
none is the target. The empty removal returns `Missing` with `expanded = 7`.
Changing the target does not change either search's peak for this graph: the
stack still reaches two pending entries, and the queue reaches four. Finiteness
follows from four premises: the graph has finitely many vertices; equality and
every `neighbors` call return; every neighbor list is finite; and
mark-before-add schedules each vertex at most once. It is not a claim that
every possible graph-search input terminates.

## Separate the source-work accounts

The result reports two measurements: completed non-target expansions and the
greatest logical number of pending entries.

<!-- markdownlint-disable MD013 -->
Maximum pending entries count frontier work items, not their retained paths or the visited dictionary.
<!-- markdownlint-enable MD013 -->

Other source work needs separate units:

- **Retained-path work:** initial work constructs no predecessor `More`.
  Scheduling each new non-start vertex constructs one. For a found path with
  `l` edges, `forward_path` selects `l` predecessor nodes and constructs
  `l + 1` result nodes.
- **Visited work:** discovering a vertex constructs one `Entry` and one
  dictionary-list node. A lookup applies `same_vertex` to each entry it
  inspects until a match or `NoEntries`.
- **Queue work:** one queue list-node unit is one selected or constructed
  `More`, as in the preceding queue case. For `e` additions and `d` successful
  removals, its `3e + d` bound applies only to one empty-to-successor history.
- **Measurement work:** every accepted addition constructs `Next(pending)` and
  recursively compares it with the retained maximum. The instrumentation has
  source work of its own.

<!-- markdownlint-disable MD013 -->
One BFS run follows a linear queue history that starts from `empty`; retained branching is outside that queue bound.
<!-- markdownlint-enable MD013 -->

The dictionary can inspect a growing discovered prefix, so this representation
does not inherit an array-based `O(V + E)` runtime theorem. These counts name
selected and constructed source forms. They are not interchangeable, and none
is a runtime measurement.

## Bound logical pending entries

Let `b` bound the number of previously unseen neighbors scheduled by one DFS
expansion, and let `d` be the greatest directed-edge depth reached in its DFS
discovery tree. Along one descent, removing the active item and adding at most
`b` children can leave at most `b - 1` pending siblings at that level. Starting
from the one initial item gives the accumulated bound.

<!-- markdownlint-disable MD013 -->
For `b >= 1` and DFS discovery-tree edge depth `d`, the stack holds at most `1 + d(b - 1)` pending entries.
<!-- markdownlint-enable MD013 -->

If `b = 0`, the separate initial state has one pending entry. The formula is a
bound on logical work items, not on recursive calls or path nodes.

For BFS, let `L_i` be the number of vertices first discovered at edge distance
`i`. While removing layer `i`, the queue contains only the unprocessed suffix
of that layer and the discovered prefix of layer `i + 1`. No later layer can
enter before a layer-`i` item schedules it.

<!-- markdownlint-disable MD013 -->
During BFS layer `i`, pending entries are at most `L_i + L_(i + 1)`, and therefore at most `2W` when `W` is the greatest layer size.
<!-- markdownlint-enable MD013 -->

This two-layer account is why a bound using only one layer size would omit a
transition already visible in the queue.

Try changing only the `Start` neighbor order on paper. Predict the next stack
and queue item, both found paths, and which shortest-path fact remains true.
Then trace the `LongTwo -> Start` edge and name the exact state field that
prevents another addition. Finally, explain why neither `maximum` result can
tell you the number of retained path nodes.

The frontier choice changes removal order, the returned path, the number of
non-target expansions before success, and the peak pending entries. It does
not change the graph, scheduling transition, or visited timing.

<!-- markdownlint-disable MD013 -->
The named counts establish no elapsed time, machine instructions, native-stack behavior, heap bytes, allocation count, pointer identity, physical sharing, garbage collection, or compiler optimization.
<!-- markdownlint-enable MD013 -->
