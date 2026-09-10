# How can one recursive traversal define many list algorithms?

The beginning path ended with `map`, a function whose equations follow the two
forms of `List<A>`. Other list calculations repeat that shape. A sum returns
zero for `Empty` and combines the first integer with the sum of `rest`. A length
returns zero for `Empty` and combines one with the length of `rest`. Only their
ending values and combinations differ.

A *fold* names this repeated traversal. It receives the result for `Empty` and
a function that combines one element with the already folded `rest`. The list
still determines where recursion goes; the two supplied values determine what
the traversal means for one algorithm.

Every list in this chapter is finite: a chain of `More` values ending in
`Empty`. The cost statements describe calculations that reach a result; the
supplied functions in the examples return for every element.

## Replacing the list forms

The shared module begins with the list from the final Learn Ash lesson. It adds
`Option<A>` so a later observation can distinguish an empty list from one with
a first element.

<!-- source: src/lists.ash -->
```ash
pub type List<A> =
    Empty
    | More(A, List<A>)

pub type Option<A> =
    None
    | Some(A)

pub fold : (A -> B -> B) -> B -> List<A> -> B
fold combine base Empty = base
fold combine base More(first, rest) = {
    let folded_rest = fold combine base rest
    combine first folded_rest
}

pub sum : List<Int> -> Int
sum list = fold (fn(first) {
    fn(total) {
        first + total
    }
}) 0 list

pub length : List<A> -> Int
length list = fold (fn(ignored) {
    fn(count) {
        count + 1
    }
}) 0 list

pub map : (A -> B) -> List<A> -> List<B>
map transform list = fold (fn(first) {
    fn(mapped_rest) {
        More(transform first, mapped_rest)
    }
}) Empty list

pub filter : (A -> Bool) -> List<A> -> List<A>
filter keep list = fold (fn(first) {
    fn(filtered_rest) {
        match keep first {
            true => More(first, filtered_rest)
            false => filtered_rest
        }
    }
}) Empty list

pub first_and_visits : List<A> -> (Option<A>, Int)
first_and_visits list = fold (fn(first) {
    fn(summary) {
        let (ignored, visits) = summary
        (Some(first), visits + 1)
    }
}) (None, 0) list
```

Read the type of `fold` from left to right. Its first input is a combiner. The
combiner receives an element of type `A`, then a result of type `B`, and returns
another `B`. The second input supplies the `B` for `Empty`. After those choices,
`fold` can turn a `List<A>` into a `B`.

The equations mirror the datatype:

- `Empty` becomes `base`;
- `More(first, rest)` first folds `rest`, then combines that result with
  `first`.

This definition is commonly called a *right fold* because the result for the
rest becomes the combiner's second input. `fold` is not special Ash syntax or a
built-in operation. It is an ordinary higher-order function checked by the
[function-application
rules](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#functions-and-application)
and placed in recursive scope by the [global-definition
rules](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#globals-and-modules)
used throughout the beginning path.

Each algorithm chooses one replacement for each list form:

| Function | Result `B` | `Empty` becomes | `More` combines |
| --- | --- | --- | --- |
| `sum` | `Int` | `0` | `first + total` |
| `length` | `Int` | `0` | `count + 1` |
| `map` | `List<B>` | `Empty` | `More(transform first, mapped_rest)` |
| `filter` | `List<A>` | `Empty` | retained `More` or `filtered_rest` |

The nested anonymous functions in each definition match
`A -> B -> B`: the outer function receives `first`, and the function it returns
receives the folded rest. `length` does not need the element, but its combiner
still receives that position because every `More` carries one.

## One traversal definition, two integer results

The first entry gives the same three-element list to `sum` and `length`. Both
functions reuse the `fold` definition, but each call starts its own traversal:

<!-- source: src/01-fold.ash -->
```ash
import lists as Lists

main : Unit -> (Int, Int)
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.Empty)))
    (Lists.sum numbers, Lists.length numbers)
}
```

Before running it, replace the list forms by the choices in the table. For the
sum, the calculation has this shape:

```text
combine 1 (combine 2 (combine 3 0))
1 + (2 + (3 + 0))
6
```

For the length, the elements do not enter the arithmetic:

```text
combine 1 (combine 2 (combine 3 0))
1 + (1 + (1 + 0))
3
```

Run the entry from `content/cases`:

```text
ash folding-recursive-lists/src/01-fold.ash
```

The result keeps both predictions together:

```text
(6, 3) : (Int, Int)
```

One fold over this list selects the recursive equation three times, so it calls
its supplied combiner three times. The complete entry runs two folds—one for
`sum` and one for `length`—and therefore makes six combiner calls. For a
calculation that reaches a result, one fold over a finite list with `n` `More`
forms completes exactly `n` combiner calls; these two folds together complete
`2 * n`. `Empty` selects the base equation and causes no combiner call. Here one
combiner call means one complete evaluation of `combine first folded_rest`, not
each unary application step within it.

## Rebuilding or retaining elements

A fold can also produce another list. `map` constructs one `More` result for
every input element. `filter` constructs `More` only when `keep first` is true;
otherwise it returns the already filtered rest without another `More`.

The next entry uses the same input for both operations:

<!-- source: src/02-map-filter.ash -->
```ash
import lists as Lists

increment : Int -> Int
increment number = number + 1

is_42 : Int -> Bool
is_42 number = number == 42

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let numbers = Lists.More(41, Lists.More(42, Lists.More(43, Lists.Empty)))
    (Lists.map increment numbers, Lists.filter is_42 numbers)
}
```

Predict the two shapes before running the entry. `map` should preserve all
three `More` positions and change their values to `42`, `43`, and `44`.
`filter` should retain only the input value equal to `42`:

```text
ash folding-recursive-lists/src/02-map-filter.ash
```

Ash reports:

```text
(More(42, More(43, More(44, Empty))), More(42, Empty)) : (List<Int>, List<Int>)
```

For a completed calculation over a finite input with `n` elements, `map`
constructs `n` output `More` values. If the predicate retains `r` elements,
`filter` constructs `r` output `More` values. These counts follow the
constructor expressions in the two combiners. A completed `filter` still
applies its predicate to all `n` input elements because the fold calls its
combiner `n` times.
The pinned [constructor evaluation
rule](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/dynamic-semantics.md#application)
allocates a constructor cell when a payload constructor is applied. The counts
describe the output `More` cells attributable to these functions, not an exact
number of heap bytes.

## Why the first result still visits the rest

Finding the first element may appear to need only the outer `More`. The
`first_and_visits` combiner makes a different property observable: it returns
the current `first` while adding one to the visit count carried back from the
rest.

<!-- source: src/03-eager-fold.ash -->
```ash
import lists as Lists

main : Unit -> (Lists.Option<Int>, Int)
main () = Lists.first_and_visits(
    Lists.More(42, Lists.More(43, Lists.More(44, Lists.Empty)))
)
```

Predict both tuple fields. The outermost combiner eventually replaces the
option with `Some(42)`, so the first field is the first list element. The count
still reaches three:

```text
ash folding-recursive-lists/src/03-eager-fold.ash
```

```text
(Some(42), 3) : (Option<Int>, Int)
```

The result follows from Ash's strict binding and application order. The
`folded_rest` binding evaluates its initializer before the block continues, so
the recursive fold becomes a value before `combine first folded_rest` is
evaluated. The [dynamic binding
rules](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/dynamic-semantics.md#bindings)
and [application
rules](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/dynamic-semantics.md#application)
make both steps explicit.

Each recursive call therefore depends on the result of the call for `rest`.
For a finite list with `n` `More` forms, this right fold creates a linear chain
of `n` recursive dependencies. Returning only the first value does not make the
traversal short-circuit. A selective algorithm needs a recursive definition
that decides whether to follow `rest` before it makes that recursive call;
changing only this fold's combiner is too late.

This is a source-level dependency count. The Ash specification does not promise
that a host implementation uses or optimizes its native call stack in a
particular way. Linear recursive dependency depth is therefore justified here;
an exact stack size, constant-stack claim, or byte count is not.

## The base and combiner share one result type

The type variable `B` connects three places in `fold`: the base, the combiner's
second input, and the final result. A combiner returning `Bool` therefore
requires a Boolean base. This complete entry deliberately supplies integer `0`
instead:

<!-- source: src/04-wrong-combiner.ash -->
```ash
import lists as Lists

wrong : Int -> Bool -> Bool
wrong first folded_rest = first == 42

main : Unit -> Bool
main () = Lists.fold wrong 0 (Lists.More(42, Lists.Empty))
```

The type of `wrong` fixes `A` as `Int` and `B` as `Bool`. Predict which argument
cannot meet the resulting fold type, then run:

<!-- diagnostic: src/04-wrong-combiner.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en folding-recursive-lists/src/04-wrong-combiner.ash
This function argument must have type `Bool`, but has type `Int`.
  --> /path/to/ash-doc/content/cases/folding-recursive-lists/src/04-wrong-combiner.ash:7:28
7 | main () = Lists.fold wrong 0 (Lists.More(42, Lists.Empty))
  |                            ^ This has type `Int`.
  --> /path/to/ash-doc/content/cases/folding-recursive-lists/src/lists.ash:9:5
9 | pub fold : (A -> B -> B) -> B -> List<A> -> B
  |     ^ This function requires an argument of type `Bool`.
  --> /path/to/ash-doc/content/cases/folding-recursive-lists/src/04-wrong-combiner.ash:7:11
7 | main () = Lists.fold wrong 0 (Lists.More(42, Lists.Empty))
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The message identifies `0` as an `Int` and points back to `fold`'s required
`Bool` input. `wrong` fixed the shared result type before that base was
supplied. Replace `0` with `false` to make the base and combiner agree; this
one-element fold then returns `true`. The rejection follows the rule that
checks an
[application argument against the function's
domain](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#functions-and-application).

## Practice: choose the two replacements

Define `product : List<Int> -> Int` through `fold`. Before editing, decide what
`Empty` must become and how one integer combines with the product of the rest.
Test empty, one-element, and three-element lists. For each input, predict the
value and the number of combiner calls.

Then define `keep_all : List<A> -> List<A>` through `fold`. Its result should
have the same elements and order as its input. Explain why it constructs one
output `More` per input element even though none of the element values change.

This fold consumes a finite recursive list by replacing each form with a
result. The next case turns the direction around: how can a changing finite
state *produce* a recursive list, and what termination argument makes that
production safe to run eagerly?
