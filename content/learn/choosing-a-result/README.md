# How can a program choose a result?

Every calculation in the preceding lessons followed one route. Once a call
began, we could trace it from expression to expression without asking which
step should come next. A useful program must sometimes let a value decide.

Ash makes that decision in two parts. First, an expression produces either
`true` or `false`. Then a `match` provides one expression for each possibility.
Let us begin with the value that guides the choice.

## Asking a question

Integer equality asks whether two integer expressions produce the same value.
The result has type `Bool`:

<!-- source: src/01-equality.ash -->
```ash
main : Unit -> Bool
main () = 20 + 22 == 42
```

Work through the addition before the equality:

```text
20 + 22 == 42
42 == 42
true
```

Running the program confirms the last step:

```text
true : Bool
```

`Bool` has exactly two values, `true` and `false`. Change the right side of the
equality to `41` and predict the result before running the program again. The
answer to the question changes, but the type remains `Bool`.

A Boolean value can tell us which result to use. It does not choose by itself;
we must say what each of its two possible values means.

## Describing both choices

The following function receives a condition and two possible integer results:

<!-- source: src/02-choose.ash -->
```ash
choose : Bool -> Int -> Int -> Int
choose condition when_true when_false = match condition {
    true => when_true
    false => when_false
}

main : Unit -> Int
main () = choose true 42 0
```

Read the `match` from its first line. It examines `condition`. Each line inside
the braces is an *arm*. The part before `=>` names a possible form of the
value; the expression after `=>` gives the result for that form.

Here `condition` is `true`, so the first arm applies and the call produces
`when_true`:

```text
choose true 42 0
match true { ... }
42
```

If the call began `choose false 42 0`, the second arm would apply and the
result would be `0`. Both arms produce an `Int`, which agrees with the final
`Int` in the signature of `choose`.

## Calculating the condition

A condition need not be written directly as `true` or `false`. Any expression
that produces a `Bool` can guide the same match:

<!-- source: src/03-calculated-choice.ash -->
```ash
choose : Bool -> Int -> Int -> Int
choose condition when_true when_false = match condition {
    true => when_true
    false => when_false
}

main : Unit -> Int
main () = choose (20 + 22 == 42) 42 0
```

The parentheses keep the equality together as the first input to `choose`.
Trace that input before entering the match:

```text
choose (20 + 22 == 42) 42 0
choose true 42 0
42
```

The question and the choice are separate expressions. This separation lets
the same `choose` function work with any calculation that produces a `Bool`.

## Accounting for every value

Since `Bool` has two possible values, a match on `Bool` needs two arms. Consider
a function that accounts only for `true`:

<!-- source: src/04-missing-choice.ash -->
```ash
choose : Bool -> Int -> Int
choose condition number = match condition {
    true => number
}

main : Unit -> Int
main () = choose false 42
```

There is no expression to use when `condition` is `false`. Ash rejects the
program, beginning its message with:

```text
coverage.non-exhaustive
```

An *exhaustive* match covers every possible form of the value it examines.
Ash checks this before running the program, so execution cannot arrive at a
choice with no corresponding expression.

> **With a learning assistant:** Show the assistant the incomplete match and
> the first diagnostic line. Ask it which `Bool` value the match does not
> cover. Then explain why that value is possible and what arm would complete
> the match before asking for feedback.

## Exercise: keep or double

Define a function with this signature:

```text
keep_or_double : Bool -> Int -> Int
```

When its first input is `true`, return the number unchanged. When it is
`false`, return the number multiplied by two. Then:

1. call it with each Boolean value;
2. predict both results before running them; and
3. replace the direct Boolean with an integer equality.

Check that both match arms produce an `Int`, as the signature promises.

## A complete decision

A program chooses by first producing a value that represents the question and
then matching every possible form of that value. For `Bool`, those forms are
`true` and `false`. The selected arm supplies the result of the whole match.

Our matches still contain short expressions. When one route needs several
steps, repeating a growing expression becomes hard to read. The next lesson
shows how to name the intermediate values in a calculation.
