# How can traversal pause and resume without laziness?

Suppose a caller needs the first association in a dictionary, then wants to
stop and decide whether to ask for another. [Balanced lookup][balanced] finds
one key along a logarithmic path. Traversal has a different goal: visit every
association in key order, allowing the caller to stop between visits.

Use the three associations `two:20`, `one:10`, and `three:30`. Inserting them
into the preceding dictionary gives this tree. The following sketches describe
its shape and traversal; they are not executable Ash.

```text
          two:20
          /    \
     one:10    three:30
```

The first request should return `one:10`; a later request should return
`two:20`, then `three:30`. A fourth request should say that traversal is
finished. An empty dictionary should be finished on the first request.

Returning a complete in-order list would visit all `n` nodes and construct
all `n` list forms before the caller receives the first association. That
costs `O(n)` source work and new list state up front. Instead, each request
can return one association and a value describing where to continue. The
caller keeps that value while paused and supplies it to the next request.
What information must it contain?

## Represent the unfinished traversal

Recall the order at a node:

```text
visit left subtree; produce current association; visit right subtree
```

To find the first entry, descend from `two` to `one`. Before descending, save
`two:20` and its right subtree: both must be visited after the left subtree.
At `one`, save `one:10` and its empty right subtree. Reaching its empty left
subtree finishes the descent. The saved entries now form a stack, with `one`
at the front and `two` behind it.

A frame records four things: the pending key, its value, the right subtree
still to visit, and the remaining stack. Work in its left subtree belongs
before that association; the descent records it in frames ahead of this one.
Generalize those fields over the dictionary's existing `K` and `V` types.
These are checked, non-executable excerpts from the defining module and the
clients used below; the commands run their complete source files.

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#frames -->
```text
type FrameStack<K, V> =
    NoFrame
    | MoreFrame(K, V, Dictionary<K, V>, FrameStack<K, V>)
```
<!-- markdownlint-enable MD013 -->

`NoFrame` means that no entry remains. `MoreFrame` puts one pending association
in front of the rest. Its third field is a whole dictionary, not a list of
its entries. Saving that subtree preserves the work for a later request
without traversing it now.

For the example, the prepared stack has this schematic shape. `one`, `two`,
and the named subtree stand for their actual values:

```text
MoreFrame(
    one, 10, Empty,
    MoreFrame(two, 20, subtree rooted at three:30, NoFrame)
)
```

The outer frame is the next entry to produce. After producing it, traversal
must handle its saved right subtree before the remaining frames. This is the
stack invariant: the front association, then its right subtree, then the
remaining stack describe exactly the unfinished in-order sequence. The type
records the fields; the operations must preserve their intended order.

Wrap the stack in a public iterator type:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#iterator_data -->
```text
pub opaque type Iterator<K, V> =
    Iterator(FrameStack<K, V>)
```
<!-- markdownlint-enable MD013 -->

Inside the module, `Iterator` exposes the frame stack to its operations.
Outside it, the opaque type gives callers a name for the state while
withholding its constructor. This is the same [opaque-declaration boundary][opacity]
used for the dictionary. A caller obtains states through the public operations
rather than assembling frames itself.

The saved state is ordinary immutable data. Each returned iterator is already
prepared for its next request. There is no delayed expression to force: the
remaining work happens when the caller explicitly invokes an operation.

## Determine the operation types

Start with the caller's two operations. Preparing a dictionary gives an
iterator with the same key and value types:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#iterator_type -->
```text
pub iterator : Dictionary<K, V> -> Iterator<K, V>
```
<!-- markdownlint-enable MD013 -->

Advancing it either reports completion or returns one association together
with the state for the next request:

<!-- markdownlint-disable MD013 -->
::: {#wide-dictionaries-next_type .column-page-right}

<!-- excerpt: src/dictionaries.ash#next_type -->
```text
pub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>
```

:::
<!-- markdownlint-enable MD013 -->

Read the successful payload from the outside in. `Some` holds a pair whose
first component is `(K, V)` and whose second is `Iterator<K, V>`. `None` has
no payload. Keeping the later iterator is what makes another request possible;
keeping the current one allows a caller to repeat the same request.

These operations need no `Order<K>` requirement. Insertion has already
established the tree's ordering; traversal follows its structure. It neither
compares keys nor repairs a malformed ordering.

One private operation must prepare the next frame. It takes a subtree and an
existing stack of later ancestors, then returns the prepared stack:

<!-- markdownlint-disable MD013 -->
::: {#wide-dictionaries-push_left_type .column-page-right}

<!-- excerpt: src/dictionaries.ash#push_left_type -->
```text
push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>
```

:::
<!-- markdownlint-enable MD013 -->

The second input matters when resuming: after visiting a saved right subtree,
traversal still owes the associations recorded in the remaining stack. Starting
each descent with `NoFrame` would discard those ancestors.

## Calculate preparation and one step

First express the public composition. An initial traversal has no ancestors,
so prepare the whole dictionary over `NoFrame` and wrap the result:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#iterator -->
```text
iterator dictionary = Iterator(push_left dictionary NoFrame)
```
<!-- markdownlint-enable MD013 -->

The wrapper does not postpone `push_left`. Ash evaluates arguments before
application under its strict [application rules][application], including
arguments supplied to constructors. This call completes the initial left
spine before returning an iterator, while leaving other subtrees unentered.

Now calculate `next` from its input's two possible stack forms. An empty
stack has no association to return:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#next_empty -->
```text
next Iterator(NoFrame) = None
```
<!-- markdownlint-enable MD013 -->

For a frame, the key and value are ready. Remove that frame, prepare its saved
right subtree over `rest`, and package the association with the later iterator:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#next_frame -->
```text
next Iterator(MoreFrame(key, value, right, rest)) = Some(
    ((key, value), Iterator(push_left right rest))
)
```
<!-- markdownlint-enable MD013 -->

This equation explains the resume point: the saved right subtree comes next,
then the previously saved ancestors. An empty right subtree simply exposes
`rest`. A nonempty one contributes its own leftmost entries in front of `rest`.

It remains to fill in `push_left`. At `Empty`, there is no earlier association
to place in front of the supplied stack:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/dictionaries.ash#push_empty -->
```text
push_left Empty stack = stack
```
<!-- markdownlint-enable MD013 -->

At a node, its left subtree must come first. Save the current association and
right subtree in one frame, then descend into `left` over that frame:

<!-- markdownlint-disable MD013 -->
::: {#wide-dictionaries-push_node .column-page-right}

<!-- excerpt: src/dictionaries.ash#push_node -->
```text
push_left Node(ignored_color, left, key, value, right) stack = {
    let later_stack = MoreFrame(key, value, right, stack)
    push_left left later_stack
}
```

:::
<!-- markdownlint-enable MD013 -->

The local `later_stack` names precisely what remains after the left subtree.
The node's color does not affect in-order visitation, so the pattern calls it
`ignored_color`. The recursive call handles a smaller subtree in a finite
acyclic tree; eventually its empty left edge returns the prepared stack.

Why does this preserve the order? The empty case contributes no entries.
For a node, assume the recursive descent prepares its left subtree in order.
Placing that preparation before the new frame gives the left entries, then
the current association, then its right subtree, then the supplied stack.
Those are exactly the required pieces in their required order. Combined with
the two `next` equations, each request removes the first unfinished association
and leaves the rest ready for another request.

For the three-key example, the prepared frames change as follows. This is a
schematic trace, not a captured tool result. The front frame appears first:

| Request | Returned association | Prepared frames afterward |
| --- | --- | --- |
| Start | No association yet | `one` over `two`, with `three` saved by `two` |
| First `next` | `one:10` | `two`, with its right subtree at `three` |
| Second `next` | `two:20` | `three`, with an empty right subtree |
| Third `next` | `three:30` | `NoFrame` |
| Fourth `next` | `None` | No later iterator in the result |

The second request is the one that enters the saved subtree at `three`. Pausing
before that request leaves that descent undone.

## Collect a sequence to check the calculation

A client can test the repeated requests by collecting them into the familiar
`List<(K, V)>`. This deliberately finishes traversal; it lets one observation
show its order. The public names come from these imports:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/01-sequence.ash#imports -->
```text
import dictionaries as Dictionaries
import dictionaries (impl Order)
```
<!-- markdownlint-enable MD013 -->

The first import supplies `Dictionaries` as a qualifier. The separate
`impl Order` import supplies the ordering implementation used to build the
dictionary. The iterator operations themselves do not require it.

The collection operation consumes an iterator and produces a list:

<!-- markdownlint-disable MD013 -->
::: {#wide-01-sequence-collect_type .column-page-right}

<!-- excerpt: src/01-sequence.ash#collect_type -->
```text
collect : Dictionaries.Iterator<K, V> -> Dictionaries.List<(K, V)>
```

:::
<!-- markdownlint-enable MD013 -->

Ask for one entry. `None` gives the empty list; `Some((entry, later))` gives a
list whose head is `entry` and whose tail collects from `later`:

<!-- markdownlint-disable MD013 -->
::: {#wide-01-sequence-collect .column-page-right}

<!-- excerpt: src/01-sequence.ash#collect -->
```text
collect current = match Dictionaries.next current {
    Dictionaries.None => Dictionaries.End
    Dictionaries.Some((entry, later)) => Dictionaries.More(entry, collect later)
}
```

:::
<!-- markdownlint-enable MD013 -->

Passing `later` is essential. Recursing on `current` would request the same
entry again. The structural argument above says that each successful request
removes one unfinished association, so this recursion reaches `None` on a
finite dictionary.

A second operation converts an optional result to a completion flag:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/01-sequence.ash#is_finished_type -->
```text
is_finished : Dictionaries.Option<A> -> Bool
```
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/01-sequence.ash#is_finished -->
```text
is_finished Dictionaries.None = true
is_finished Dictionaries.Some(ignored) = false
```
<!-- markdownlint-enable MD013 -->

Together these observations determine the entry's result type:

<!-- markdownlint-disable MD013 -->
::: {#wide-01-sequence-main_type .column-page-right}

<!-- excerpt: src/01-sequence.ash#main_type -->
```text
main : Unit -> (Bool, Dictionaries.List<(Dictionaries.Natural, Int)>)
```

:::
<!-- markdownlint-enable MD013 -->

The first component checks an empty dictionary; the second records the ordered
sequence. Inside `main`, construct the three existing natural-number keys:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/01-sequence.ash#keys -->
```text
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
```
<!-- markdownlint-enable MD013 -->

Prepare the empty dictionary with an explicit key and value type:

<!-- markdownlint-disable MD013 -->
::: {#wide-01-sequence-empty .column-page-right}

<!-- excerpt: src/01-sequence.ash#empty -->
```text
    let empty_dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
```

:::
<!-- markdownlint-enable MD013 -->

Supply the nonempty entries in the example's insertion order:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/01-sequence.ash#entries -->
```text
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
```
<!-- markdownlint-enable MD013 -->

Finally build the dictionary, inspect the empty iterator, and collect the
nonempty one:

<!-- markdownlint-disable MD013 -->
::: {#wide-01-sequence-finish .column-page-right}

<!-- excerpt: src/01-sequence.ash#finish -->
```text
    let dictionary = Dictionaries.build entries
    let empty_finished = is_finished (Dictionaries.next (Dictionaries.iterator empty_dictionary))
    (empty_finished, collect (Dictionaries.iterator dictionary))
```

:::
<!-- markdownlint-enable MD013 -->

Predict the flag, the three associations, and the end of the list. Run the
complete client from `content/cases`:

```text
ash resuming-tree-traversal/src/01-sequence.ash
```

Read these selected components of that one captured result separately. They
are not separate runs or a replacement full transcript. The leading flag is:

<!-- markdownlint-disable MD013 -->
<!-- observation: sequence#empty -->
```text
true
```
<!-- markdownlint-enable MD013 -->

The empty iterator immediately returns `None`. The three successive `More`
heads, in their captured order, are:

<!-- markdownlint-disable MD013 -->
<!-- observation: sequence#one -->
```text
(Next(Zero), 10)
```
<!-- markdownlint-enable MD013 -->

`Next(Zero)` is `one`, paired with `10`.

<!-- markdownlint-disable MD013 -->
<!-- observation: sequence#two -->
```text
(Next(Next(Zero)), 20)
```
<!-- markdownlint-enable MD013 -->

`Next(Next(Zero))` is `two`, paired with `20`.

<!-- markdownlint-disable MD013 -->
<!-- observation: sequence#three -->
```text
(Next(Next(Next(Zero))), 30)
```
<!-- markdownlint-enable MD013 -->

The third natural number is paired with `30`. The list's final tail is:

<!-- markdownlint-disable MD013 -->
<!-- observation: sequence#end -->
```text
End
```
<!-- markdownlint-enable MD013 -->

Reaching `End` means that `collect` received `None` on its fourth request.
The type of the complete result is:

<!-- markdownlint-disable MD013 -->
<!-- observation: sequence#type -->
```text
(Bool, List<(Natural, Int)>)
```
<!-- markdownlint-enable MD013 -->

These observations agree with the trace. Their order follows from in-order
traversal and the inherited dictionary ordering invariant. The iterator made
no comparison and performed no validation or sorting. A malformed value
constructed inside `Dictionaries` could produce an out-of-order sequence.

## Retain a state and resume it twice

A later iterator is an ordinary immutable value. To check that using it does
not consume it, retain the state after producing `one` and call `next` on
that same state twice. Each call should produce `two:20` with a state ready
for `three:30`.

The observation needs three fields: the retained iterator, the first call's
result, and the second call's result. Each call has the same optional
association-and-iterator type derived above. `Unexpected` records an empty
initial result, which the nonempty example should not produce:

<!-- markdownlint-disable MD013 -->
::: {#wide-02-retained-state-replay_data .column-page-right}

<!-- excerpt: src/02-retained-state.ash#replay_data -->
```text
type ReplayObservation =
    Unexpected
    | Replay(
        Dictionaries.Iterator<Dictionaries.Natural, Int>,
        Dictionaries.Option<(
            (Dictionaries.Natural, Int),
            Dictionaries.Iterator<Dictionaries.Natural, Int>
        )>,
        Dictionaries.Option<(
            (Dictionaries.Natural, Int),
            Dictionaries.Iterator<Dictionaries.Natural, Int>
        )>
    )
```

:::
<!-- markdownlint-enable MD013 -->

The client uses the same two imports. Its checking operation has this type:

<!-- markdownlint-disable MD013 -->
::: {#wide-02-retained-state-replay_type .column-page-right}

<!-- excerpt: src/02-retained-state.ash#replay_type -->
```text
replay : Dictionaries.Iterator<Dictionaries.Natural, Int> -> ReplayObservation
```

:::
<!-- markdownlint-enable MD013 -->

One request obtains the state after the first association. In the successful
case, save `after_one` in the observation and use it as both subsequent inputs:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/02-retained-state.ash#replay -->
```text
replay start = match Dictionaries.next start {
    Dictionaries.None => Unexpected
    Dictionaries.Some((ignored_first, after_one)) => Replay(
        after_one,
        Dictionaries.next after_one,
        Dictionaries.next after_one
    )
}
```
<!-- markdownlint-enable MD013 -->

`ignored_first` names the association that positions the experiment; the
experiment observes what happens from the returned state. Both subsequent
calls receive `after_one`, so neither uses the state returned by the other.

This client returns the observation directly:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/02-retained-state.ash#main_type -->
```text
main : Unit -> ReplayObservation
```
<!-- markdownlint-enable MD013 -->

Inside `main`, define `one`, `two`, and `three` as before. This time insert in
ascending order, which the balanced dictionary also turns into a root `two`
with children `one` and `three`:

<!-- markdownlint-disable MD013 -->
<!-- excerpt: src/02-retained-state.ash#entries -->
```text
    let entries = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
```
<!-- markdownlint-enable MD013 -->

Compose building, preparation, and the replay check:

<!-- markdownlint-disable MD013 -->
::: {#wide-02-retained-state-finish .column-page-right}

<!-- excerpt: src/02-retained-state.ash#finish -->
```text
    replay (Dictionaries.iterator (Dictionaries.build entries))
```

:::
<!-- markdownlint-enable MD013 -->

The tree shape predicts a saved frame for `two` retaining the subtree at
`three`. Both subsequent calls should prepare equivalent frames for `three`.
Run the complete client:

```text
ash resuming-tree-traversal/src/02-retained-state.ash
```

The following are the three fields of the single captured `Replay` result,
followed by its type. Its first field is the saved iterator:

<!-- markdownlint-disable MD013 -->
::: {#wide-retained-state-saved .column-page-right}

<!-- observation: retained-state#saved -->
```text
Iterator(MoreFrame(Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty), NoFrame))
```

:::
<!-- markdownlint-enable MD013 -->

The front frame contains `two:20`, a right subtree containing `three:30`, and
`NoFrame`. That subtree remains a `Node`; it has not yet been converted to
frames. The second field comes from the first `next after_one`:

<!-- markdownlint-disable MD013 -->
::: {#wide-retained-state-first .column-page-right}

<!-- observation: retained-state#first -->
```text
Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))
```

:::
<!-- markdownlint-enable MD013 -->

It returns `two:20` and prepares a frame for `three:30`. The third field comes
from the second `next after_one`:

<!-- markdownlint-disable MD013 -->
::: {#wide-retained-state-second .column-page-right}

<!-- observation: retained-state#second -->
```text
Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))
```

:::
<!-- markdownlint-enable MD013 -->

It shows the same association and prepared state. Both calls descend into
the same saved right subtree and construct a frame for `three`; retaining
state does not memoize that remaining source work. The complete result's type
is:

<!-- markdownlint-disable MD013 -->
<!-- observation: retained-state#type -->
```text
ReplayObservation
```
<!-- markdownlint-enable MD013 -->

`Iterator`, `MoreFrame`, `Node`, and their fields are visible in these
observations. Ash's structural [observation rules][observation] render nominal
values even when their constructors are unavailable to the entry module.
Constructor payload tuples appear as fields in this output, which is why the
captured `Some` displays the association and iterator as two fields. Seeing
those forms supplies no constructor binding to client source. Test that
separate boundary next.

[balanced]: ../guaranteeing-logarithmic-retrieval/README.md
[application]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application
[observation]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation
[opacity]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#public-private-and-opaque-declarations

## Test the source boundary in patterns and values

First try to inspect the iterator with a constructor pattern. The importer may
name `Dictionaries.Iterator<...>`, but the `Dictionaries.Iterator` occurrence
in this match arm should be rejected during name resolution. The type name
is public, but the constructor that would expose the frame stack is withheld.

<!-- markdownlint-disable MD013 -->
::: {#wide-source-03-opaque-pattern .column-page-right}

<!-- source: src/03-opaque-pattern.ash -->
```ash
import dictionaries as Dictionaries

main : Unit -> Int
main () = {
    let dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
    match Dictionaries.iterator dictionary {
        Dictionaries.Iterator(ignored_stack) => 1
    }
}
```

:::
<!-- markdownlint-enable MD013 -->

Run the rejected entry:

{{< pagebreak >}}

::: {#wide-diagnostic-03-opaque-pattern .column-page-right}

<!-- diagnostic: src/03-opaque-pattern.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en resuming-tree-traversal/src/03-opaque-pattern.ash
The constructor `Iterator` belongs to an opaque type and is not accessible here.
  --> /path/to/ash-doc/content/cases/resuming-tree-traversal/src/03-opaque-pattern.ash:7:22
7 |         Dictionaries.Iterator(ignored_stack) => 1
  |                      ^ This name is not accessible here.
  --> /path/to/ash-doc/content/cases/resuming-tree-traversal/src/dictionaries.ash:35:5
35 |     Iterator(FrameStack<K, V>)
   |     ^ The inaccessible declaration is here.
reason: resolve.opaque-constructor
```

:::
<!-- markdownlint-enable MD013 -->

The message explains that `Iterator` belongs to an opaque type. The first
label marks the member in the client pattern, and the related label identifies
its withheld declaration in `dictionaries.ash`. The constructor exists, but it
is unavailable in this module. Use `Dictionaries.next` to observe the next
association through the public API, as in the accepted sequence.

Now use the same unavailable constructor as a value. A constructor is an
ordinary term before it is applied, so binding `Dictionaries.Iterator` should
cross the same opacity boundary at a different source occurrence. Predict the
same channel and status behavior, with the primary label on the initializer
instead of a pattern.

<!-- markdownlint-disable MD013 -->
<!-- source: src/04-opaque-construction.ash -->
```ash
import dictionaries as Dictionaries

main : Unit -> Int
main () = {
    let unavailable = Dictionaries.Iterator
    0
}
```
<!-- markdownlint-enable MD013 -->

Run the second rejected entry:

{{< pagebreak >}}

::: {#wide-diagnostic-04-opaque-construction .column-page-right}

<!-- diagnostic: src/04-opaque-construction.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en resuming-tree-traversal/src/04-opaque-construction.ash
The constructor `Iterator` belongs to an opaque type and is not accessible here.
  --> /path/to/ash-doc/content/cases/resuming-tree-traversal/src/04-opaque-construction.ash:5:36
5 |     let unavailable = Dictionaries.Iterator
  |                                    ^ This name is not accessible here.
  --> /path/to/ash-doc/content/cases/resuming-tree-traversal/src/dictionaries.ash:35:5
35 |     Iterator(FrameStack<K, V>)
   |     ^ The inaccessible declaration is here.
reason: resolve.opaque-constructor
```

:::
<!-- markdownlint-enable MD013 -->

This rejection labels `Iterator` in the local initializer and returns to the
same hidden declaration. Use `Dictionaries.iterator` to obtain the initial
state from a dictionary, then retain states returned by `next`. Together the
two runs show that the constructor is unavailable in both patterns and values,
even though successful structural output can spell its name.

## Count the explicit pending work

Let `d` be the number of `Node` forms on one left-spine descent. `push_left`
applies once at each of those `d` nodes and once more at the terminal `Empty`,
for exactly:

```text
d + 1 push_left applications
d MoreFrame constructions
```

Let `h` be the largest number of `Node` forms on a path from the root to
`Empty`. Initialization descends one left spine, so `d <= h`. It constructs at
most `h` explicit `MoreFrame` forms and one `Iterator` wrapper. The `O(h)`
state bound counts only those explicit frame forms. Each frame also retains an
existing key, value, saved right-subtree value, and rest-of-stack value. Much
or all of the original `n`-node dictionary may remain transitively reachable,
so the claim is not an `O(h)` bound on all reachable data or runtime bytes.

For a successful `next`, popping the first frame is one frame operation. If
the saved right subtree has a `d_i`-node left spine, preparing the returned
state pushes `d_i` new frames. The current node followed by that descent lies
on one dictionary path, hence:

```text
1 pop + d_i pushes
1 + d_i <= h
```

The call also constructs one new `Iterator` wrapper and one `Some` result. Its
worst-case explicit frame work is therefore `O(h)`. An exhausted call selects
`NoFrame` and constructs `None` without pushing or popping a frame.
The remaining ancestors and the newly prepared left spine form one pending
tree path, so every returned state still contains at most `h` explicit frames.

Now count one complete linear traversal of a finite `n`-node dictionary. Every
node enters a frame exactly once: nodes on the initial left spine enter during
initialization, and every other node enters when a saved right subtree is
prepared. Each of those frames later leaves exactly once when its association
is produced. The totals, including initialization, are therefore:

```text
n pushes + n pops = 2n frame operations
```

This exact count includes `n = 0`: the empty traversal moves no frame, and its
final `None` call adds no frame move. For `n > 0`, distribute the `2n`
operations over the `n` produced pairs:

```text
2n frame operations / n produced pairs = 2 frame operations per pair
```

The quotient gives two frame operations per pair across the complete linear
chain. This is amortized constant frame work. One individual `next` can still
pop one frame and push `d_i` frames, so its worst-case work remains `O(h)`.
The complete sequence uses frame work within `O(n + h)`.

The amortized account does not extend across arbitrary branching histories.
Calling `next` again on an older state can repeat its saved right-subtree
left-spine descent and construct the corresponding frame path again, as the
replay did.

The preceding case established `h <= 2 log2(n + 1)` for a valid red-black
dictionary under its ordering and balance premises. Inheriting those premises
makes initialization and one worst-case `next` use logarithmic explicit frame
work. The complete traversal remains linear because it still produces all `n`
associations.

These return and traversal claims apply to finite acyclic dictionary spines
reached through completed public operations and to iterator states produced
from them. A defining module can construct malformed or constructor-guarded
cyclic spines despite opacity under Ash's static
[recursive block-group rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#recursive-block-groups).
An initial left-edge cycle can prevent `iterator` from returning. A cycle in a
saved right subtree may permit earlier results and then prevent the `next` call
that enters it from returning. The spine premise does not require acyclic keys
or values: a cyclic key or value payload can be returned without traversal;
later structural observation may render an active-path revisit as `<cycle>`.

At source level, a frame supplies existing key, value, subtree, and stack
values unchanged to a new constructor application. The account counts named
source applications and constructor applications only. It establishes no
elapsed-time, machine-instruction, native-stack, tail-call-optimization,
runtime-byte, heap-layout, pointer-identity, physical-sharing,
garbage-collection, compiler-layout, or compiler-optimization property. It
also introduces no mutation, laziness, hidden mutable cursor, or infinite-data
claim.

## Practice and continue

1. Draw the initial `MoreFrame` stack for the three-entry dictionary built in
   `01-sequence.ash`. Then draw the states returned after each successful
   `next`.
2. Draw a valid tree whose root's right subtree has a nonempty left branch.
   Predict the frames pushed after the root is produced, including their
   order.
3. Starting from the fact that every node enters and leaves one frame, derive
   the `n` pushes, `n` pops, and `2n` total without counting the final `None`
   as a frame operation.
4. Explain why constant amortized frame work applies to one linear chain of
   states but not to a history that repeatedly resumes the same older state.

This iterator keeps pending work in last-in, first-out order: the leftmost
unfinished association must come before its ancestors. What changes when a
traversal must retain pending work in first-in, first-out order instead?
