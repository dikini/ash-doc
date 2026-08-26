# How can a function handle each form of data?

The preceding lesson gave `Result` two possible forms. We can construct
`Found(42)` or `Missing`, and their shared type tells us that either value may
arrive wherever a `Result` is expected. A function that receives one must be
prepared for both.

The data definition guides the function. For each constructor in the
definition, we write a pattern with the same shape and an expression that says
what that form means for the calculation.

## Matching the data definition

Suppose we want the integer carried by a found result, and zero when there is
no integer:

<!-- source: src/01-match-result.ash -->
```ash
type Result =
    Found(Int)
    | Missing

value_or_zero : Result -> Int
value_or_zero result = match result {
    Found(value) => value
    Missing => 0
}

main : Unit -> Int
main () = value_or_zero (Found(42))
```

Place the data definition beside the match:

```text
Found(Int)    Found(value) => value
Missing       Missing      => 0
```

Each constructor has a corresponding arm. The pattern `Found(value)` does two
jobs: it recognizes the `Found` form and gives its integer field the local name
`value`. The `Missing` form has no field to name.

For `Found(42)`, the first pattern applies and `value` stands for `42`. The
function therefore produces `42`. For `Missing`, the second pattern applies
and the function produces `0`.

Run the program, then change the call to `value_or_zero Missing`. The two runs
should report `42 : Int` and `0 : Int`. Both paths agree with the result type in
the signature.

## Letting the equations follow the forms

When a function begins by matching one of its inputs, Ash can place the
patterns directly in separate equations:

<!-- source: src/02-equations.ash -->
```ash
type Result =
    Found(Int)
    | Missing

value_or_zero : Result -> Int
value_or_zero Found(value) = value
value_or_zero Missing = 0

main : Unit -> Int
main () = value_or_zero (Found(42))
```

The signature still belongs to the whole function. The two equations describe
what that function does for the two forms of `Result`:

```text
value_or_zero Found(42)
42
```

and

```text
value_or_zero Missing
0
```

This definition and the explicit match answer the same question. Use the shape
that keeps the explanation close to the data. An explicit match is useful when
it forms one part of a larger expression. Separate equations are useful when
the entire definition follows the input's forms.

## Following every branch of the definition

The data definition is also a checklist. If an equation handles `Found` but no
equation handles `Missing`, the function is incomplete:

<!-- source: src/03-missing-constructor.ash -->
```ash
type Result =
    Found(Int)
    | Missing

value_or_zero : Result -> Int
value_or_zero Found(value) = value

main : Unit -> Int
main () = value_or_zero Missing
```

Ash rejects this program with a message beginning:

```text
coverage.non-exhaustive
```

The problem exists whether or not `main` happens to construct `Missing`. The
signature says that `value_or_zero` accepts any `Result`, and the data
definition says that `Missing` is one. The equations must keep that promise.

When a constructor carries several fields, its pattern must have the same
number and order of parts. The pattern then supplies a local name for each part
the expression needs.

## Exercise: respond to a signal

Return to the earlier definition:

```ash
type Signal =
    Go
    | Stop
```

Define `signal_value : Signal -> Int` with one equation per constructor. Let
`Go` produce `1` and `Stop` produce `0`. Call the function with each value and
predict both results.

Next, rewrite the equations as one explicit match. Keep the signature and the
two observations unchanged. Explain how each line in the data definition leads
to one equation and one match arm.

## Functions that follow data

To handle a data type, write a pattern for every form the data definition
permits. A constructor pattern identifies the form and names any fields it
carries. Ash checks that the match or group of equations is exhaustive, so the
function has an expression for every accepted input.

The data so far has contained only existing values. A data definition may also
refer to the type being defined, allowing one value to lead to another of the
same shape. The next lesson follows that self-reference with a recursive
function.
