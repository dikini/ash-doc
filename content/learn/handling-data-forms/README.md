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

Predict which arm handles `Found(42)`, what `value` binds, and what the
function returns. Run it, then change the call to `value_or_zero Missing`
and predict that result before running again.

The observations are `42 : Int` and `0 : Int`. The `Found` pattern binds
its field to `value`; the `Missing` arm supplies its own integer because
there is no field. Both paths agree with the signature's result type.

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
what that function does for the two forms of `Result`. Before running, locate
the equation selected by each input and compare with the explicit match.
The first call reports `42 : Int`; the two calculations are:

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
that keeps the explanation close to the data. Separate equations are useful
when the entire definition follows the input's forms.

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

Compare every form allowed by `Result` with the equations. Which form has no
result, and would changing only `main`'s input fulfill the function's contract?
Run this version from `content/learn`:

<!-- diagnostic: src/03-missing-constructor.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en handling-data-forms/src/03-missing-constructor.ash
These cases do not cover every possible input; for example, `Missing` is not covered.
  --> /path/to/ash-doc/content/learn/handling-data-forms/src/03-missing-constructor.ash:5:1
5 | value_or_zero : Result -> Int
  | ^ These cases do not cover every possible input; for example, `Missing` is not covered.
6 | value_or_zero Found(value) = value
  | ^ These cases do not cover every possible input; for example, `Missing` is not covered.
reason: coverage.non-exhaustive
```
<!-- markdownlint-enable MD013 -->

The message names `Missing` and labels the incomplete `value_or_zero`
definition. Restoring `value_or_zero Missing = 0` gives that form its own
result. The problem exists whether or not `main` happens to construct
`Missing`. The signature accepts any `Result`, and the data definition says
that `Missing` is one. The equations must keep that promise.

When a constructor carries several fields, its pattern must have the same
number and order of parts. The pattern then supplies a local name for each part
the expression needs.

## Exercise: respond to a signal

Start from a fresh copy of `src/02-equations.ash` in your scratch directory.
Replace the data definition and function, then use the same scratch program
for the equivalent match.

Return to the earlier definition:

```text
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
