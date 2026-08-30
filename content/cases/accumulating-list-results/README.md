# When should recursion retain knowledge from earlier elements?

The preceding case used an unfold to carry the state needed to produce the
next element. It did not retain a result derived from elements that had already
been produced. Reversing a finite list creates that need: after seeing an
element, the algorithm can either leave its placement to later traversals or
carry the reversed processed prefix forward.

Both choices below produce the same list. Their difference is the source work
that connects each element to that result. Append-based reverse completes the
recursively reversed rest and then traverses that result again. Accumulator
reverse remembers the work already done and passes it into the next recursive
call.

## Append follows its left list

Only the familiar finite `List<A>` representation is needed. The shared module
also contains the two reverse functions and counted versions used later in the
chapter.

<!-- source: src/lists.ash -->
```ash
pub type List<A> =
    Empty
    | More(A, List<A>)

pub append : List<A> -> List<A> -> List<A>
append Empty right = right
append More(first, rest) right = {
    let appended_rest = append rest right
    More(first, appended_rest)
}

pub reverse_through_append : List<A> -> List<A>
reverse_through_append Empty = Empty
reverse_through_append More(first, rest) = {
    let reversed_rest = reverse_through_append rest
    append reversed_rest (More(first, Empty))
}

append_revisits : List<A> -> List<A> -> (List<A>, Int)
append_revisits Empty right = (right, 0)
append_revisits More(first, rest) right = {
    let (appended_rest, later_revisits) = append_revisits rest right
    (More(first, appended_rest), later_revisits + 1)
}

reverse_revisits : List<A> -> (List<A>, Int)
reverse_revisits Empty = (Empty, 0)
reverse_revisits More(first, rest) = {
    let (reversed_rest, earlier_revisits) = reverse_revisits rest
    let singleton = More(first, Empty)
    let (reversed, current_revisits) = append_revisits reversed_rest singleton
    (reversed, earlier_revisits + current_revisits)
}

pub reverse_through_append_with_revisits : List<A> -> (List<A>, Int)
reverse_through_append_with_revisits list = reverse_revisits list

pub fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated Empty = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

pub prepend : List<A> -> A -> List<A>
prepend accumulated first = More(first, accumulated)

pub reverse_with_accumulator : List<A> -> List<A>
reverse_with_accumulator list = fold_left prepend Empty list

fold_left_visits : (B -> A -> B) -> B -> Int -> List<A> -> (B, Int)
fold_left_visits combine accumulated visits Empty = (accumulated, visits)
fold_left_visits combine accumulated visits More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left_visits combine next_accumulated (visits + 1) rest
}

pub reverse_with_accumulator_and_visits : List<A> -> (List<A>, Int)
reverse_with_accumulator_and_visits list = fold_left_visits prepend Empty 0 list
```

The equations for `append` are controlled by its left operand. At `Empty`, the
function returns `right` unchanged. At `More(first, rest)`, it follows `rest`
and constructs a new `More` containing `first` after the recursive result is
available. The source therefore inspects the left spine and constructs one new
`More` for each left-hand `More`; it does not traverse the right list. This
describes these equations and does not infer a physical pointer-sharing
strategy.

The [static pattern and equation
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage)
check the `Empty` and `More` cases, while the [global-definition
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
make a definition available in its own body. Those Ash rules support the
recursive definitions; the traversal account comes from the particular
equations shown here.

In `reverse_through_append`, the nonempty equation first binds
`reversed_rest`. A binding evaluates its initializer before the rest of its
block, according to the pinned [dynamic binding
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings).
The recursive reverse of `rest` is therefore a value before `append` begins to
traverse that already-built result. Append places the singleton containing
`first` on its right.

The first entry runs both reverse definitions on the same four-element input.

<!-- source: src/01-same-result.ash -->
```ash
import lists as Lists

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    (Lists.reverse_through_append numbers, Lists.reverse_with_accumulator numbers)
}
```

Before running the entry, predict its first field by expanding the outermost
append-based step. The reversed rest is `[4, 3, 2]`; append then follows that
left operand and places the singleton `[1]` on its right:

```text
reverse_through_append [1, 2, 3, 4]
=> append [4, 3, 2] [1]
=> [4, 3, 2, 1]
```

Predict the same `[4, 3, 2, 1]` target for the accumulator field. Its different
mechanism becomes the next part of the chapter.

Run it from `content/cases`:

```text
ash accumulating-list-results/src/01-same-result.ash
```

<!-- markdownlint-disable MD013 -->
```text
(More(4, More(3, More(2, More(1, Empty)))), More(4, More(3, More(2, More(1, Empty))))) : (List<Int>, List<Int>)
```
<!-- markdownlint-enable MD013 -->

Both fields are `More(4, More(3, More(2, More(1, Empty))))`. The complete line
follows the pinned tool's [successful-output
contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output):
one observed value, its checked type, and a newline.

## Counting the revisited left operands

The next entry uses the counted variants. `append_revisits` adds one only when
it encounters a `More` in the left operand; its `Empty` equation returns zero.
`reverse_revisits` adds the counts from all the append calls.
`fold_left_visits` separately counts one visit to each input `More` handled by
the accumulator traversal. The pinned [dynamic constructor and match
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
govern constructor values and equational-clause selection. The counters remain
instrumentation defined by this module, not language operations.

<!-- source: src/02-counted-work.ash -->
```ash
import lists as Lists

main : Unit -> ((Lists.List<Int>, Int), (Lists.List<Int>, Int))
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    (
        Lists.reverse_through_append_with_revisits numbers,
        Lists.reverse_with_accumulator_and_visits numbers
    )
}
```

Run the counted comparison:

```text
ash accumulating-list-results/src/02-counted-work.ash
```

<!-- markdownlint-disable MD013 -->
```text
((More(4, More(3, More(2, More(1, Empty)))), 6), (More(4, More(3, More(2, More(1, Empty)))), 4)) : ((List<Int>, Int), (List<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The append calls receive reversed left operands of lengths zero through three.
The extra revisits are therefore:

```text
0 + 1 + 2 + 3 = 6
```

This first counter excludes the four visits to the original input `More`
values made by `reverse_revisits`. Under the named `More`-inspection metric,
the append version has ten inspections in this example: four original-input
visits plus six append revisits. The accumulator counter reports the four
original input `More` visits. The displayed `6` and `4` are counters for
different named parts of the source; they are not a comparison of total
operations.

For a finite input of length `n`, the append left operands have lengths from
zero through `n - 1`. Their extra revisit count is:

```text
0 + 1 + ... + (n - 1) = n * (n - 1) / 2
```

Append-based reverse also evaluates `n` singleton `More` applications, one for
each original element, and one copied `More` application per append revisit.
Its result and intermediate `More` applications therefore total:

```text
n + n * (n - 1) / 2
```

These append revisit and constructor-application counts grow quadratically
with `n`. Accumulator reverse visits each input `More` once and constructs one
`More` per visit, so those two named source metrics grow linearly. Neither
description is a measurement or promise of elapsed time.

## Carrying the reversed prefix

`fold_left` gives retained knowledge a separate type. In its signature,
`List<A>` supplies elements of type `A`, while `B` is the type of the
accumulated result. The `combine` function accepts the current `B`, then the
current `A`, and returns the next `B`:

```text
(B -> A -> B) -> B -> List<A> -> B
```

At `Empty`, `fold_left` returns the accumulated `B`. At `More(first, rest)`,
the strict `next_accumulated` binding completes `combine accumulated first`
before recursion continues with `rest`. The pinned [static function and
application
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application)
connect each supplied argument to the corresponding function domain.

For reverse, `B` is `List<A>`. `prepend` constructs
`More(first, accumulated)`, so each element moves in front of the result
retained from earlier elements. `reverse_with_accumulator` specializes the
fold by choosing `prepend` and an initial `Empty`.

## What the accumulator means

The shape of `fold_left` does not explain which accumulated value is correct.
For the call `fold_left prepend accumulated remaining`, use this invariant:

```text
original = processed followed by remaining
accumulated = reverse(processed)
```

At initialization, `processed` and `accumulated` are both `Empty`, while
`remaining` is the original list. Both relationships hold:

```text
processed = []
accumulated = []
remaining = original
```

For preservation, suppose `remaining` is `More(first, rest)`. The next
processed prefix is the old prefix followed by `first`. `prepend` makes the
next accumulator `More(first, accumulated)`, which is the reverse of that
longer prefix when `accumulated` is the reverse of the old prefix. The next
remaining list is `rest`, so the processed and remaining parts still form the
original list.

When `remaining` is `Empty`, the processed prefix is the whole original list.
The `Empty` equation returns `accumulated`, and the invariant says that value
is the reverse of the original.

The next entry exposes one midpoint. Its processed prefix is `[1, 2]`, its
derived accumulator is `[2, 1]`, and its remaining suffix is `[3, 4]`.

<!-- source: src/03-accumulator-invariant.ash -->
```ash
import lists as Lists

main : Unit -> (Lists.List<Int>, Lists.List<Int>, Lists.List<Int>)
main () = {
    let processed = Lists.More(1, Lists.More(2, Lists.Empty))
    let remaining = Lists.More(3, Lists.More(4, Lists.Empty))
    let accumulated = Lists.fold_left Lists.prepend Lists.Empty processed
    let complete = Lists.fold_left Lists.prepend accumulated remaining
    (processed, accumulated, complete)
}
```

Run the checkpoint:

```text
ash accumulating-list-results/src/03-accumulator-invariant.ash
```

<!-- markdownlint-disable MD013 -->
```text
(More(1, More(2, Empty)), More(2, More(1, Empty)), More(4, More(3, More(2, More(1, Empty))))) : (List<Int>, List<Int>, List<Int>)
```
<!-- markdownlint-enable MD013 -->

Continuing from the derived `[2, 1]` accumulator and processing `[3, 4]`
produces `[4, 3, 2, 1]`. This executable checkpoint supports one midpoint.
The initialization, preservation, and ending derivation from the source
equations is the general argument; it is not a formal proof supplied by the
language.

## A list type does not establish the invariant

The initial accumulator can have the right type and the wrong meaning. The
final entry starts it with `[99]` instead of the reverse of an empty processed
prefix.

<!-- source: src/04-wrong-initial-accumulator.ash -->
```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    Lists.fold_left Lists.prepend (Lists.More(99, Lists.Empty)) numbers
}
```

Run this accepted program:

```text
ash accumulating-list-results/src/04-wrong-initial-accumulator.ash
```

```text
More(4, More(3, More(2, More(1, More(99, Empty))))) : List<Int>
```

The result ends in `99`. `List<Int>` checks that the accumulator has the
representation required for this specialization of `fold_left`; it does not
check the content precondition that the accumulator equals the reverse of the
processed prefix. This is a well-typed negative semantic counterexample, not a
diagnostic or language defect.

## What tail position says here

In the nonempty `fold_left` equation, the initializer for `next_accumulated`
completes first under the pinned [dynamic binding
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings).
The recursive `fold_left combine next_accumulated rest` application is then the
result expression of the block under the pinned [static block
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks):
no later source operation waits for that recursive result. The pinned [dynamic
application
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application)
describe strict function and argument evaluation; *tail position* here names
only the recursive application's placement in this source.

That placement does not promise tail-call optimization, constant host-stack
use, or a particular stack representation. The program uses no mutation and
makes no in-place reversal claim. This case also leaves aside lazy or infinite
lists, fold laws or fusion, built-in or library status, runtime timing, machine
instructions, exact heap bytes, garbage collection, and a type-level proof of
the invariant. Structural output does not establish physical pointer sharing.

## Practice: retain a three-element prefix

Trace accumulator reverse on `[5, 6, 7]`. After each element, record
`processed`, `remaining`, and `accumulated`, and check both invariant
relationships before moving to the next element. Then predict the extra append
revisits for append-based reverse and the input `More` visits for accumulator
reverse. The source counts should be `0 + 1 + 2 = 3` extra append revisits and
three accumulator visits.

As a further exercise, define `sum_left` with `fold_left`. State its invariant
as “accumulated is the sum of the processed prefix,” then trace the same three
elements. Keep the exercise about the invariant and named source visits rather
than runtime timing.

The method of giving retained knowledge a precise invariant is inspired by
HtDP's [discussion of
accumulators](https://htdp.org/2026-2-25/Book/part_six.html).

An accumulator changes what recursion remembers without changing this list
representation. What does lookup cost when a dictionary is represented as a
recursive list?
