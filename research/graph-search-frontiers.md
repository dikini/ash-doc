# Stack and queue frontiers for graph search

## Question

Which graph-search tradition can support an ash-doc case about replacing a
LIFO frontier with a FIFO frontier, preventing repeated expansion in a cyclic
graph, and recovering a shortest unweighted path?

The observable boundary is one finite directed graph searched with ordinary
eager Ash data. The case may compare returned paths, completed expansions, and
logical pending-frontier entries. It must not import another language's array,
mutation, runtime, or storage claims into Ash.

## Selected source

The selected source is Pat Morin, *Open Data Structures (in pseudocode)*,
edition 0.1G beta, section 12.3, [Graph
Traversal](https://opendatastructures.org/ods-python/12_3_Graph_Traversal.html).
The edition's [complete
PDF](https://opendatastructures.org/versions/edition-0.1g/ods-python.pdf) was
also consulted to fix the edition and surrounding context.

Section 12.3 presents breadth-first and depth-first graph traversal. Its
breadth-first search uses a queue, marks a vertex before adding it, and
processes vertices in increasing distance from the start. It connects that
layer order to shortest paths in an unweighted graph. The section also
describes an explicit-stack depth-first search and notes that exact traversal
depends on adjacency order.

Those ideas support the planned comparison:

- a frontier holds discovered work that has not yet been expanded;
- a queue removes the earliest added work and a stack removes the latest;
- a discovered set prevents a graph cycle from scheduling one vertex
  repeatedly; and
- a FIFO search that retains the first discovered path reaches vertices in
  nondecreasing edge distance.

The source's algorithms and performance theorem assume its own graph and
array representations. They are not Ash semantics and are not executable
evidence for the planned case.

## Material Ash departures

The planned case deliberately changes the source presentation and several
representations:

- The source uses adjacency structures indexed by integer vertex numbers. The
  Ash case uses one closed nominal `Vertex` type and an equation-defined
  adjacency function that returns finite lists.
- The source uses a mutable Boolean array for discovered vertices. The Ash
  case uses the persistent list dictionary from the earlier dictionary case,
  with `Unit` values.
- The source reconstructs shortest paths through predecessor indices. The Ash
  case keeps a current vertex and a reverse predecessor list in each frontier
  entry, then constructs the forward result only when it removes the target.
- The source's shown explicit-stack DFS marks a vertex when removing it. The
  Ash case marks both DFS and BFS vertices when adding them so one scheduling
  invariant can govern both frontier representations.
- The source presents an `O(n + m)` runtime result under constant-time array
  access. The Ash case does not inherit it. A list-dictionary membership test
  may inspect every previously discovered entry, and the recursive `Natural`
  measurement performs its own source work.

Mark-on-add is therefore an original design choice for the Ash comparison,
not a translation of the source's explicit DFS. The case must explain that
FIFO layer order, rather than discovered marking alone, establishes its
shortest-path result.

## Related project sources

The existing [recursive-algorithm
record](how-to-design-programs-recursive-algorithms.md) supplies the method for
stating a changing-state invariant, a termination argument, and named
source-operation costs. Its recorded CC BY-NC-ND boundary still requires
original prose, graph, programs, trace, and exercises.

The [persistent paired-list queue
record](persistent-paired-list-queue.md) governs the FIFO representation and
its source-level amortized account. One BFS run uses only each returned queue
successor from an empty queue, so the earlier linear-history boundary applies
to its queue operations. Retaining and resuming older search states would
leave that boundary and could repeat work.

The list-dictionary case is repository evidence for the selected visited-set
representation. It contributes no constant-time membership claim.

## Alternatives considered

### A textbook with a closed adaptation boundary

A conventional algorithms textbook could establish the queue, stack, and
shortest-path tradition. Without an open adaptation license, the case would
need the same conceptual-inspiration classification and strict separation
from the source's code, graph, proof presentation, and exercises.

The openly published selected source gives a clearer edition and rights
record while still leaving all Ash material original.

### The existing recursive-algorithm record alone

The existing record supports generative state and source-level cost reasoning,
but it does not establish the DFS/BFS frontier tradition, enqueue-time marking,
or the unweighted shortest-path argument. Using it alone would leave the new
algorithmic source boundary implicit.

## Adaptation classification and license

This use is **conceptual inspiration**, not direct adaptation. *Open Data
Structures* identifies Pat Morin as author and links its text and source under
the [Creative Commons Attribution 2.5 Canada
license](https://creativecommons.org/licenses/by/2.5/ca/). The official
[license file](https://github.com/patmorin/ods/blob/master/COPYING) retains the
project's attribution notice.

Ash-doc will credit the source and link the consulted section. Its graph,
constructor names, Ash functions, state representation, observations,
derivations, prose, and exercises will be original. It will not copy or
closely translate the source's figures, pseudocode, graph, trace, proof order,
or exercises. If later work directly adapts source expression, it must retain
the license notice, indicate the adaptation, and review the complete
attribution obligation again.

## Contribution to Case 12

The selected tradition can support these bounded claims:

- changing only ordinary add and remove functions lets one search engine use
  a LIFO list stack or FIFO paired-list queue;
- scheduling neighbors in a fixed list order is deterministic, while stack
  and queue removal consume those additions differently;
- inserting a vertex into the visited dictionary before adding its work item
  schedules each vertex at most once when membership and equality return;
- when no earlier target match returns, including when the target is
  unreachable, a finite graph whose adjacency calls return finite lists is
  exhausted after finitely many distinct scheduled vertices;
- FIFO removal keeps first-discovery paths in nondecreasing directed-edge
  distance, so the first removed target has a shortest unweighted path; and
- DFS can use the same discovered rule and return a longer path, showing that
  discovered marking alone is insufficient.

The fixed Ash observations and source relationships must establish the actual
case. The source record cannot prove them.

## Deliberate exclusions

The source relationship excludes:

- weighted graphs, negative edges, priority frontiers, Dijkstra's algorithm,
  and all-pairs search;
- mutable arrays, indexes, parent tables, colors, or in-place graph updates;
- the selected source's Java, C++, or pseudocode programs, figures, graph,
  traces, proof presentation, and exercises;
- a runtime `O(V + E)` claim for a list-dictionary implementation;
- recursive Ash data cycles, lazy or infinite adjacency, and nonreturning
  vertex equality;
- retained branching from older complete search states; and
- elapsed time, machine instructions, native stack depth, heap bytes,
  allocation counts, pointer identity, physical sharing, garbage collection,
  or compiler optimization.

This record is sufficient for the bounded Case 12 design because it fixes the
source, edition, license, transferable ideas, material departures, and claims
that must remain outside the Ash lesson.

## Historical pinned-tool observation

The first executable prototype at Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf` placed four `match`
expressions around an inner block in the search loop. The pinned tool rejected
that source with status `2`, empty standard output, first standard-error line
`internal.resource.structural-depth`, and reported limit `128`. A minimized
prototype with the same four nested matches and no inner block completed,
while adding the inner block reproduced the rejection. Moving the outer
frontier-removal result into the exhaustive `continue_search` helper produced
the accepted Case 12 source without changing the planned transition.

This is a historical prototype observation about the pinned tool's resource
boundary, not Ash language semantics, a diagnostic-layout contract, or a
runtime stack claim. The disposable reproductions are verified once more at
closure and then removed; this record and the retained plan commit preserve
the observation and its classification.
