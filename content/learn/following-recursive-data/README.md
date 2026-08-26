# How can a function follow recursive data?

The data definitions so far have been shallow. A `Found` value contains an
integer, and a `Missing` value contains nothing. Once a pattern exposes those
fields, the function has reached the end of the value.

Some data grows by repeating one shape. A line of integers may contain a first
integer followed by the rest of the line. That rest is itself another line of
integers. The data definition can express this repetition by referring to the
type it is defining.

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
value, whose second field may permit another, until an `Empty` value ends the
list.

The value in `main` has two `More` layers. Indentation makes its structure
easier to see:

```text
More(20,
    More(22,
        Empty))
```

The first layer carries `20`. Its rest is a list whose first integer is `22`.
That second layer's rest is `Empty`, so the value is finite. Run the program
and Ash displays the same nested shape:

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

For `Empty`, there is no integer to add, so the result is `0`. For `More`, the
pattern gives names to the first integer and the rest of the list. We can add
`first` directly. To find what the entire `rest` contributes, the function
applies itself to that smaller list.

This is a *recursive call*. It follows the recursive field in the data. Each
call receives one fewer `More` layer than the call before it:

```text
sum (More(20, More(22, Empty)))
20 + sum (More(22, Empty))
20 + (22 + sum Empty)
20 + (22 + 0)
42
```

The `Empty` equation supplies the result that ends the chain of calls. Running
the program confirms the trace with `42 : Int`.

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

But every finite list eventually contains `Empty`, and `Empty` is itself a
valid `IntList`. Without its equation, the recursive call has nowhere to stop.
Ash rejects the incomplete definition with:

```text
coverage.non-exhaustive
```

Coverage checks the same promise as before: `sum : IntList -> Int` must handle
every `IntList`. With recursive data, the non-recursive form also provides the
result from which the longer cases can be calculated.

## Exercise: count the integers

Define `length : IntList -> Int`. Follow the two forms of the data:

- the length of `Empty` is `0`;
- the length of `More(first, rest)` is one more than the length of `rest`.

The first field is not needed for this calculation, but its place still appears
in the constructor pattern. Test the function with `Empty`, a one-element list,
and the two-element list from the lesson. Predict each result before running
the program.

Then compare the definitions of `length` and `sum`. Both follow `rest`; only
the expression that combines the first part with the recursive result changes.

## Recursion follows self-reference

A recursive data definition has a form containing a smaller value of the type
being defined. A function follows that form with a recursive call on the
corresponding field. A non-recursive form supplies the result that ends the
calculation.

So far, every function has been called by name where it is used. Functions are
also values: they can be received, returned, and made for a particular
calculation. The next lesson develops that idea directly.
