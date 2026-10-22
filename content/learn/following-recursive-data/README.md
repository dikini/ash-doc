# Following recursive data

The data definitions so far have been shallow. A `Found` value contains an
integer, and a `Missing` value contains nothing. Once a pattern exposes those
fields, the function has reached the end of the value.

Some data grows by repeating one shape. A line of integers may contain a first
integer followed by the rest of the line. That rest is itself another line of
integers. An algebraic data type can express this repetition: its definition
refers to the very type it defines.

## A finite list of integers

Here is a type for such values:

<!-- source: src/01-int-list.ash -->
```ash
type IntList =
    Empty
    | More(Int, IntList)

main : Unit -> IntList
main () = More(20, More(22, Empty))
```

Read the definition one form at a time:

- `Empty` represents a list with no integers;
- `More(first, rest)` represents one integer followed by another `IntList`.

The second field of `More` is the self-reference. It permits another `More`
value, whose second field may permit another. In the finite lists here,
following those rest fields reaches `Empty`.

The value in `main` has two `More` layers. Indentation makes its structure
easier to see:

```text
More(20,
    More(22,
        Empty))
```

The first layer carries `20`. Its rest is a list whose first integer is `22`.
That second layer's rest is `Empty`, so the value is finite. Predict the
nested value and its type before running; Ash displays:

```text
More(20, More(22, Empty)) : IntList
```

## A function with the same shape

To add every integer in an `IntList`, begin as before: give each form in the
data definition an equation.

<!-- source: src/02-sum.ash -->
```ash
type IntList =
    Empty
    | More(Int, IntList)

sum : IntList -> Int
sum Empty = 0
sum More(first, rest) = first + sum rest

main : Unit -> Int
main () = sum (More(20, More(22, Empty)))
```

For `Empty`, there is no integer to add, so the result is `0` — the *base
case*, answered directly, without another call. For `More`, the pattern gives
names to the first integer and the rest of the list. We can add `first`
directly. To find what the entire `rest` contributes, the function applies
itself to that smaller list.

This is a *recursive call*. It follows the recursive field in the data.
For this finite input, count the `More` layers still to visit at each call.
Predict the result before running; Ash reports `42 : Int`. Compare the
pending additions with this trace:

```text
sum (More(20, More(22, Empty)))
20 + sum (More(22, Empty))
20 + (22 + sum Empty)
20 + (22 + 0)
42
```

Each call receives one fewer `More` layer, until `Empty` supplies `0`.
The pending additions combine that base result with `22` and then `20`.
This finite input and the move to its smaller rest explain why this traversal
ends. Exhaustive equations alone do not prove that every recursive call
terminates.

> **With a learning assistant:** Give the assistant a three-element `IntList`
> and your trace of `sum`. Ask it to check that each recursive call receives
> exactly the `rest` field from the preceding value. Keep the arithmetic and
> final explanation as your work.

## The ending form still matters

It may be tempting to write only the `More` equation because that is where the
addition happens:

<!-- source: src/03-missing-empty.ash -->
```ash
type IntList =
    Empty
    | More(Int, IntList)

sum : IntList -> Int
sum More(first, rest) = first + sum rest

main : Unit -> Int
main () = sum Empty
```

`Empty` is itself a valid `IntList`, as well as the ending form reached by
the finite lists here. Which equation gives it a result? Run this version
from `content/learn` to check that coverage requirement:

<!-- diagnostic: src/03-missing-empty.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en following-recursive-data/src/03-missing-empty.ash
These cases do not cover every possible input; for example, `Empty` is not covered.
  --> /path/to/ash-doc/content/learn/following-recursive-data/src/03-missing-empty.ash:5:1
5 | sum : IntList -> Int
  | ^ These cases do not cover every possible input; for example, `Empty` is not covered.
6 | sum More(first, rest) = first + sum rest
  | ^ These cases do not cover every possible input; for example, `Empty` is not covered.
reason: coverage.non-exhaustive
```
<!-- markdownlint-enable MD013 -->

The message names `Empty` and labels the incomplete `sum` definition.
Restoring `sum Empty = 0` supplies the ending result that the `More` equation
needs when it follows `rest`. Coverage checks the same promise as before:
`sum : IntList -> Int` must handle
every `IntList`. With recursive data, the non-recursive form also provides the
result from which the longer cases can be calculated.

## Exercise: count the integers

Start from a fresh copy of `src/02-sum.ash` in your scratch directory, keeping
the data definition. Define `length : IntList -> Int` by following the two
forms of the data:

- the length of `Empty` is `0`;
- the length of `More(first, rest)` is one more than the length of `rest`.

The first field is not needed for this calculation, but its place still appears
in the constructor pattern. Test the function with `Empty`, a one-element list,
and the two-element list from the lesson. Predict each result before running
the program.

Then compare the definitions of `length` and `sum`. Both follow `rest`; only
the expression that combines the first part with the recursive result changes.

## Recursion follows self-reference

In these finite lists, every `rest` holds fewer layers of the same type, so
the call that follows it makes progress, and `Empty` supplies the ending
result. The data definition guides the cases; the input and the recursive
argument explain why this traversal ends. One equation per constructor,
recursing into the data's own fields, is called *structural recursion*.

So far, every function has been called by name where it is used. Functions are
also values — they can be received, returned, and made for a particular
calculation. The next two lessons map what this language declines and then
build its missing arithmetic from data; the lesson after those develops
functions as values directly.
