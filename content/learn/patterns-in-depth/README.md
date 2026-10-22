# Patterns in depth

The preceding lesson matched each constructor of a data type with its own
equation, and every pattern named every field its constructor carries. Real
functions are rarely that thorough. A report of the points earned from a
marked answer has no use for the points possible, and a function that keeps
the first integer of a pair never inspects the second. This lesson extends
the pattern vocabulary for such functions: ignore a field without naming it,
follow a value two layers deep, build a pattern from the small values
themselves, and state a type beside a pattern.

## Naming the field a calculation needs

A marked answer carries two integers, the points earned and the points
possible; a blank answer carries nothing:

<!-- source: src/01-earned-points.ash -->
```ash
type Answer =
    Marked(Int, Int)
    | Blank

earned_points : Answer -> Int
earned_points Marked(earned, _) = earned
earned_points Blank = 0

main : Unit -> Int
main () = earned_points (Marked(42, 50))
```

The `Marked` equation names its first field `earned` and writes `_` for the
second. Predict the result for the marked answer shown, then run the
program; Ash reports `42 : Int`.

Now change the call to `earned_points (Marked(42, 60))` and predict again.
The second field changed, and the result did not; Ash again reports
`42 : Int`. The `_` pattern is called the wildcard: it matches whatever
value occupies its field and binds no name for it, so one equation serves
every possible second field. The `Blank` equation names no field because its
constructor carries none.

## Ignoring a field is not ignoring a case

The wildcard answers a question about fields. It does not answer the other
question the function must answer: which constructors have equations. Remove
the `Blank` equation:

<!-- source: src/02-missing-case.ash -->
```ash
type Answer =
    Marked(Int, Int)
    | Blank

earned_points : Answer -> Int
earned_points Marked(earned, _) = earned

main : Unit -> Int
main () = earned_points (Marked(42, 50))
```

Every field of `Marked` is named, so the remaining equation looks complete.
Compare its patterns with the data definition; which constructor has no
result? Run this version from `content/learn`:

<!-- diagnostic: src/02-missing-case.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en patterns-in-depth/src/02-missing-case.ash
These cases do not cover every possible input; for example, `Blank` is not covered.
  --> /path/to/ash-doc/content/learn/patterns-in-depth/src/02-missing-case.ash:5:1
5 | earned_points : Answer -> Int
  | ^ These cases do not cover every possible input; for example, `Blank` is not covered.
6 | earned_points Marked(earned, _) = earned
  | ^ These cases do not cover every possible input; for example, `Blank` is not covered.
reason: coverage.non-exhaustive
```
<!-- markdownlint-enable MD013 -->

The message names `Blank` and labels the incomplete `earned_points`
definition, from its signature through the remaining equation. The wildcard
ignored one field of one constructor; it said nothing about the other
constructor, and coverage still asks for every constructor. Restoring
`earned_points Blank = 0` gives that form its own result.

> **With a learning assistant:** Show the assistant the single equation and
> the complete diagnostic. Ask which words of the message name the missing
> case and which label the definition. Then explain why ignoring a field of
> `Marked` could never cover `Blank` before asking for feedback.

## Following a value two layers deep

One type's field may hold another data type's value. An entry is either a
graded answer or a skip:

<!-- source: src/03-two-layers.ash -->
```ash
type Answer =
    Marked(Int, Int)
    | Blank

type Entry =
    Graded(Answer)
    | Skipped

earned_from : Entry -> Int
earned_from Graded(Marked(earned, _)) = earned
earned_from Graded(Blank) = 0
earned_from Skipped = 0

main : Unit -> Int
main () = earned_from (Graded(Marked(42, 50)))
```

The first pattern reaches through both layers: `Graded(Marked(earned, _))`
applies only when the entry holds a graded marked answer, and then `earned`
names that answer's first field. The possible points stay unnamed, and the
other two equations keep their own forms. Predict the result for the graded
answer shown, then change `main`'s input to `Graded(Blank)` and to
`Skipped`, predicting each result before running. The first call reports
`42 : Int`; the other two report `0 : Int`.

Writing both layers in one pattern keeps the equation's shape next to the
value's shape. Two matches, one per layer, would ask the same question with
more machinery.

## Patterns built from the values themselves

`Bool` has two values, and either may stand directly in an equation. The
`choose` function of the fourth lesson matched on its condition; the same
function writes as two equations:

<!-- source: src/04-boolean-equations.ash -->
```ash
pick : Bool -> Int -> Int -> Int
pick true when_true when_false = when_true
pick false when_true when_false = when_false

main : Unit -> Int
main () = pick (20 + 22 == 42) 42 0
```

The literal patterns `true` and `false` select an equation by the
condition's value. Coverage is checked across them as across any other
patterns: omit the second equation and the report names `false` as an
uncovered input. The unit value has a literal pattern too, and it has stood
in every program so far — `main ()` is an equation whose pattern is `()`.
Predict which equation the call shown selects, then run it; Ash reports
`42 : Int`.

## Stating the type beside the pattern

A pattern may state the type it must match. In a local binding, write the
type after the pattern:

<!-- source: src/05-checked-binding.ash -->
```ash
main : Unit -> Int
main () = {
    let (low, high) : (Int, Int) = (20, 22)
    high
}
```

Ash checks the pattern against the stated type — here `(low, high)` against
`(Int, Int)` — and the initializer against it as well, so a disagreement
is a type error reported before the program runs. Running the program
reports `22 : Int`.

## Exercise: count the integers

Start from a fresh copy of `src/01-earned-points.ash` in your scratch
directory, and give the program this definition instead:

```text
type Roll =
    Both(Int, Int)
    | One(Int)
    | None
```

Define `count : Roll -> Int` that counts the integers a roll carries:
`Both` holds two, `One` holds one, and `None` holds none. The count never
inspects the integers themselves, so let the wildcard keep every field
unnamed. Call `count` with each form of `Roll`, predicting all three
results before you run them.

Then define `add_up : Roll -> Int` that adds every integer a roll carries.
Name only the fields the addition needs. Compare the two definitions:
which equations changed shape, and which stayed the same?

## What a pattern can say

Across these programs, one idea repeats: a pattern describes the shape of
the value it matches. The wildcard fills a field without naming it. A nested
pattern follows the value's layers. Literal patterns let `Bool` and `Unit`
values select the equation for themselves. A stated type gives the pattern
something to be checked against. And coverage asks, of every pattern alike,
which values still have no equation.

Every value so far has a bounded shape — one answer, one entry, one roll.
A data definition may instead refer to the very type it defines, letting one
value contain another of the same shape. The next lesson follows that
self-reference.
