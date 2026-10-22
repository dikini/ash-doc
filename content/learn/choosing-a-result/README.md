# Choosing a result

Every calculation in the preceding lessons followed one route. Once a call
began, we could trace it from expression to expression without asking which
step should come next. A useful program must sometimes let a value decide.

Ash makes that decision in two parts. First, an expression produces either
`true` or `false`. Then a `match` provides one expression for each possibility.

## Asking a question

Integer equality asks whether two integer expressions produce the same value.
The result has type `Bool`:

<!-- source: src/01-equality.ash -->
```ash
main : Unit -> Bool
main () = 20 + 22 == 42
```

Work through the addition before the equality, and predict the Boolean
result. Running the program answers the equality:

```text
true : Bool
```

The addition supplies the left input to equality:

```text
20 + 22 == 42
42 == 42
true
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

Use the supplied condition to choose an arm, then predict the value that
arm returns. Run your working program; it reports `42 : Int`. Trace why:

```text
choose true 42 0
match true { ... }
42
```

If the call began `choose false 42 0`, the second arm would apply and the
result would be `0`. Both arms produce an `Int`, which agrees with the final
`Int` in the signature of `choose`.

`choose` receives its inputs as evaluated values. The match selects one arm
body after receiving the condition; it does not delay evaluation of the
function's arguments. Evaluating arguments before the body runs is called
*strict evaluation*. The [application][application] and
[matching][evaluation] rules distinguish those steps.

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
Predict the condition first, then the selected result. Running the program
reports `42 : Int`, matching the trace:

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

Compare the possible `Bool` values with the patterns in the match. Which
input has no result expression? Run this version from `content/learn`:

<!-- diagnostic: src/04-missing-choice.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en choosing-a-result/src/04-missing-choice.ash
These cases do not cover every possible input; for example, `false` is not covered.
  --> /path/to/ash-doc/content/learn/choosing-a-result/src/04-missing-choice.ash:2:27
2 | choose condition number = match condition {
  |                           ^ These cases do not cover every possible input; for example, `false` is not covered.
3 |     true => number
  | ^ These cases do not cover every possible input; for example, `false` is not covered.
4 | }
  | ^ These cases do not cover every possible input; for example, `false` is not covered.
reason: coverage.non-exhaustive
```
<!-- markdownlint-enable MD013 -->

The message supplies `false` as an input the cases miss and labels the
incomplete `match`. Add an arm such as `false => 0` to give that input a
result. An *exhaustive* match covers every possible form of the value it
examines. Ash checks this before running the program, so execution cannot
arrive at a choice with no corresponding expression.

> **With a learning assistant:** Show the assistant the incomplete match and
> the complete diagnostic. Ask how the named missing value connects to the
> labelled match. Then explain why that value is possible and what arm would complete
> the match before asking for feedback.

## Exercise: keep or double

Start from a fresh copy of `src/02-choose.ash` in your scratch directory.

Build a gate for one integer. When the gate is `true`, the number passes
through unchanged; when it is `false`, the number doubles:

```text
keep_or_double : Bool -> Int -> Int
```

Call the function once with each Boolean value, predicting both results
before you run them. Then replace the direct Boolean in the call with an
integer equality, and check that both arms still produce an `Int`, as the
signature promises.

## A complete decision

A choice now has two parts: one expression answers the question, and the
match spends that answer, giving each possible value of `Bool` its own arm.
Ash checks the coverage before running, so no call can reach a value the
match leaves unanswered.

Each arm so far has held a short expression. When one route needs several
steps, repeating a growing expression becomes hard to read; the next lesson
gives the steps names.

[evaluation]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches
[application]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application
