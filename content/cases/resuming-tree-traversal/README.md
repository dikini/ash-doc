# How can traversal pause and resume without laziness?

[Balanced lookup](../guaranteeing-logarithmic-retrieval/README.md) enters one
logarithmic path. An in-order traversal has a different destination: it
eventually visits every association. A function that returns the complete
traversal as a list must enter all `n` nodes and construct all `n` list forms
before its caller receives the first association. That eager result costs
`O(n)` source work and `O(n)` new list state up front.

The traversal can remain eager without finishing all at once. One call returns
one association together with ordinary immutable data that describes where the
next call should continue. The boundary is between complete eager recursion and
explicit eager pending state carried between calls. There is no delayed
expression inside that state.

## Turn the unfinished calls into frames

Recall the order of one recursive visit:

```text
visit left subtree; produce current association; visit right subtree
```

The first client below builds the associations `two:20`, `one:10`, and
`three:30`. Their ordered tree has this source-level shape:

```text
          two:20
          /    \
     one:10    three:30
```

Traversal first descends to `one`. Its pending state is:

```text
MoreFrame(
    one,
    10,
    Empty,
    MoreFrame(two, 20, right subtree rooted at three:30, NoFrame)
)
```

The outer frame makes `one:10` the next association and records its `Empty`
right subtree. Beneath it, the frame for `two:20` retains the right subtree
containing `three:30`; `NoFrame` says that no ancestor remains.

The two frames repeat four positions: a key, its value, its unentered right
subtree, and the rest of the unfinished ancestors. Generalizing those positions
gives:

```text
NoFrame
MoreFrame(key, value, saved_right, remaining_ancestors)
```

The frame at the front is the next association to produce. Its left subtree is
absent because that work is complete. Its saved right subtree has not been
entered. The remaining frames describe later associations in the same
in-order sequence. This representation follows from the tree equations.

`push_left` prepares that invariant. At `Empty`, it returns the existing stack.
At a `Node`, it saves the current association and right subtree in a
`MoreFrame`, then continues down the left branch. The resulting first frame is
therefore the leftmost association that remains.

`iterator` calls `push_left` with `NoFrame`, so initialization eagerly prepares
only the initial left spine. `next` has two cases. `NoFrame` means that no
association remains and produces `None`. `MoreFrame` produces its key-value
pair and calls `push_left` on the saved right subtree with the remaining
ancestors. The returned iterator is already fully prepared when `next`
returns. Ash evaluates function arguments before application under its strict
[application rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
and constructor arguments are ordinary strict data.

Here is the complete defining module. It retains the balanced dictionary from
the preceding case and adds the private frame stack and public opaque iterator.
This dependency has no `main`; the entry modules that follow import and invoke
it.

<!-- markdownlint-disable MD013 -->
<!-- source: src/dictionaries.ash -->
```ash
pub type Ordering =
    Less
    | Equal
    | Greater

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)

type BalanceCheck =
    Invalid
    | Valid(Int)

type FrameStack<K, V> =
    NoFrame
    | MoreFrame(K, V, Dictionary<K, V>, FrameStack<K, V>)

pub opaque type Iterator<K, V> =
    Iterator(FrameStack<K, V>)

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(ignored_color, left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth = Node(
    Red,
    Node(Black, first, first_key, first_value, second),
    middle_key,
    middle_value,
    Node(Black, third, last_key, last_value, fourth)
)

restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore Black Node(
    Red,
    Node(Red, first, first_key, first_value, second),
    middle_key,
    middle_value,
    third
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black Node(
    Red,
    first,
    first_key,
    first_value,
    Node(Red, second, middle_key, middle_value, third)
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    Node(Red, second, middle_key, middle_value, third),
    last_key,
    last_value,
    fourth
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    second,
    middle_key,
    middle_value,
    Node(Red, third, last_key, last_value, fourth)
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore color left key value right = Node(color, left, key, value, right)

insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert_colored key value Empty = Node(Red, Empty, key, value, Empty)
insert_colored key value Node(color, left, current_key, current_value, right) = match compare key current_key {
    Less => restore color (insert_colored key value left) current_key current_value right
    Equal => Node(color, left, current_key, value, right)
    Greater => restore color left current_key current_value (insert_colored key value right)
}

blacken_root : Dictionary<K, V> -> Dictionary<K, V>
blacken_root dictionary = match dictionary {
    Empty => Empty
    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary
    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value dictionary = blacken_root (insert_colored key value dictionary)

fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated End = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>
insert_entry dictionary entry = match entry {
    (key, value) => insert key value dictionary
}

pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>
build entries = fold_left insert_entry (empty ()) entries

above_lower : Option<K> -> K -> Bool where Order<K>
above_lower None key = true
above_lower Some(lower) key = match compare lower key {
    Less => true
    Equal => false
    Greater => false
}

below_upper : K -> Option<K> -> Bool where Order<K>
below_upper key None = true
below_upper key Some(upper) = match compare key upper {
    Less => true
    Equal => false
    Greater => false
}

both : Bool -> Bool -> Bool
both true right = right
both false right = false

valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>
valid_between lower upper Empty = true
valid_between lower upper Node(ignored_color, left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

is_black : Dictionary<K, V> -> Bool
is_black Empty = true
is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

children_colors_hold : Color -> Dictionary<K, V> -> Dictionary<K, V> -> Bool
children_colors_hold Black left right = true
children_colors_hold Red left right = both (is_black left) (is_black right)

add_black : Color -> Int -> Int
add_black Red height = height
add_black Black height = height + 1

balance_summary : Dictionary<K, V> -> BalanceCheck
balance_summary Empty = Valid(1)
balance_summary Node(color, left, ignored_key, ignored_value, right) = {
    let left_result = balance_summary left
    let right_result = balance_summary right
    let children_hold = children_colors_hold color left right
    match (left_result, right_result) {
        (Invalid, ignored_right_result) => Invalid
        (Valid(ignored_left_height), Invalid) => Invalid
        (Valid(left_height), Valid(right_height)) => match children_hold {
            false => Invalid
            true => match left_height == right_height {
                false => Invalid
                true => Valid(add_black color left_height)
            }
        }
    }
}

balance_holds : Dictionary<K, V> -> Bool
balance_holds dictionary = match balance_summary dictionary {
    Invalid => false
    Valid(ignored_height) => true
}

root_is_black : Dictionary<K, V> -> Bool
root_is_black Empty = true
root_is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
root_is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = {
    let ordered = valid_between None None dictionary
    let balanced = balance_holds dictionary
    let black_root = root_is_black dictionary
    both ordered (both balanced black_root)
}

push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>
push_left Empty stack = stack
push_left Node(ignored_color, left, key, value, right) stack = {
    let later_stack = MoreFrame(key, value, right, stack)
    push_left left later_stack
}

pub iterator : Dictionary<K, V> -> Iterator<K, V>
iterator dictionary = Iterator(push_left dictionary NoFrame)

pub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>
next Iterator(NoFrame) = None
next Iterator(MoreFrame(key, value, right, rest)) = Some(
    ((key, value), Iterator(push_left right rest))
)
```
<!-- markdownlint-enable MD013 -->

`FrameStack<K, V>` and its constructors are private. `Iterator<K, V>` is a
public opaque type, so a client can name it, obtain one through `iterator`,
retain it, and pass returned states to `next`. Its `Iterator` constructor
remains private to the defining module: clients cannot construct it or use it
in a pattern. Neither operation has an `Order<K>` requirement and neither calls
`compare`; iteration follows the structure already present.

## Produce one association at a time

The first client turns the frame sequence above into a check. The first `next`
should yield `one`; the second should yield `two` and prepare its saved right
subtree; the third should yield `three`; and the fourth should reach `NoFrame`
and return `None`. Starting from `Empty` should return `None` immediately.
`collect` turns those predictions into one complete list.

<!-- markdownlint-disable MD013 -->
<!-- source: src/01-sequence.ash -->
```ash
import dictionaries as Dictionaries

collect : Dictionaries.Iterator<K, V> -> Dictionaries.List<(K, V)>
collect current = match Dictionaries.next current {
    Dictionaries.None => Dictionaries.End
    Dictionaries.Some((entry, later)) => Dictionaries.More(entry, collect later)
}

is_finished : Dictionaries.Option<A> -> Bool
is_finished Dictionaries.None = true
is_finished Dictionaries.Some(ignored) = false

main : Unit -> (Bool, Dictionaries.List<(Dictionaries.Natural, Int)>)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let empty_dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
    let dictionary = Dictionaries.build entries
    let empty_finished = is_finished (Dictionaries.next (Dictionaries.iterator empty_dictionary))
    (empty_finished, collect (Dictionaries.iterator dictionary))
}
```
<!-- markdownlint-enable MD013 -->

The program should report `true` for the empty dictionary and then the three
key-value pairs in increasing-key order. Run it from `content/cases`:

```text
ash resuming-tree-traversal/src/01-sequence.ash
```

<!-- markdownlint-disable MD013 -->
```text
(true, More((Next(Zero), 10), More((Next(Next(Zero)), 20), More((Next(Next(Next(Zero))), 30), End)))) : (Bool, List<(Natural, Int)>)
```
<!-- markdownlint-enable MD013 -->

The leading `true` confirms the immediate empty result. `More` then contains
exactly `one`, `two`, and `three`, followed by `End`; reaching `End` means the
fourth `next` returned `None`. The ordering is a consequence of structural
in-order traversal together with the inherited dictionary ordering invariant.
The iterator itself made no comparison and performed no validation or sorting.
A malformed value constructed inside `Dictionaries` could therefore produce
an out-of-order sequence.

## Retain and replay a prepared state

An iterator is an ordinary immutable value. The next client retains the state
after producing `one`, then calls `next` on that same state twice. Because its
ascending insertion order produces a root `two` with a saved right subtree
containing `three`, the retained state should show a frame for `two` and that
saved subtree. Both calls should yield `two` and independently prepare an
equivalent frame for `three`.

<!-- markdownlint-disable MD013 -->
<!-- source: src/02-retained-state.ash -->
```ash
import dictionaries as Dictionaries

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

replay : Dictionaries.Iterator<Dictionaries.Natural, Int> -> ReplayObservation
replay start = match Dictionaries.next start {
    Dictionaries.None => Unexpected
    Dictionaries.Some((ignored_first, after_one)) => Replay(
        after_one,
        Dictionaries.next after_one,
        Dictionaries.next after_one
    )
}

main : Unit -> ReplayObservation
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let entries = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
    replay (Dictionaries.iterator (Dictionaries.build entries))
}
```
<!-- markdownlint-enable MD013 -->

The prediction includes private forms because Ash's structural
[observation rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
render nominal values even when their constructors are unavailable to the
entry module. Run the client:

```text
ash resuming-tree-traversal/src/02-retained-state.ash
```

<!-- markdownlint-disable MD013 -->
```text
Replay(Iterator(MoreFrame(Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty), NoFrame)), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame))), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))) : ReplayObservation
```
<!-- markdownlint-enable MD013 -->

`Iterator`, `MoreFrame`, `Node`, and their fields are visible in the output.
That observation supplies no constructor binding to client source. Ash's
[opaque declaration rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations)
export the iterator type name while withholding its constructor, independent
of how the tool renders a resulting value.

The raw retained state contains `two`, its right subtree containing `three`,
and `NoFrame`. Both later fields are the same structural observation: each
produces `two` and returns a state prepared for `three`. This fixed program
demonstrates repeatable results after retaining an immutable state. It also
repeats the `push_left` descent into the saved right subtree; persistence does
not memoize that deferred source work.

## Test the source boundary in patterns and values

First try to inspect the iterator with a constructor pattern. The importer may
name `Dictionaries.Iterator<...>`, but the `Dictionaries.Iterator` occurrence
in this match arm should be rejected during name resolution. It should write
no standard output, put `resolve.opaque-constructor` first on standard error,
and exit with status `1` under the tool's
[failure contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures).

<!-- markdownlint-disable MD013 -->
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
<!-- markdownlint-enable MD013 -->

Run the rejected entry:

```text
ash resuming-tree-traversal/src/03-opaque-pattern.ash
```

```text
resolve.opaque-constructor
primary: source 0 230..238: this constructor belongs to an opaque type
related: source 1 523..549: the inaccessible declaration is here
found Iterator
```

The stable reason and causal occurrence are the teaching evidence: source `0`
marks the `Iterator` member in the pattern. The displayed offsets and remaining
diagnostic prose describe this run rather than define a language contract.

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

```text
ash resuming-tree-traversal/src/04-opaque-construction.ash
```

```text
resolve.opaque-constructor
primary: source 0 103..111: this constructor belongs to an opaque type
related: source 1 523..549: the inaccessible declaration is here
found Iterator
```

This rejection identifies the distinct `Iterator` member in the local
initializer. Together the two runs separate pattern access from value access.
The constructor is unavailable in both positions even though successful
structural output can spell its name.

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
[recursive block-group rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups).
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
