# Ordering from data

The last lesson left one question standing. With no subtraction and no
ordering operators, where do a program's descent and comparison come
from? This lesson answers it: define the numbers as data, and the
operations become structural recursion — the same shape the lesson on
recursive data established, base case included.

Everything the build uses is already in place: data definitions, pattern
matching (wildcards and nested patterns included), and structural
recursion.

## The numbers, built as data

A data definition can build numbers rather than describe them:

<!-- source: src/01-natural.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

main : Unit -> Natural
main () = Next(Next(Zero))
```

Read the definition one form at a time. `Zero` is a number — the first
one. `Next(rest)` is the number after another `Natural`, and its field
holds the number it follows. These are the natural numbers of
mathematics: zero, then the number after zero, then the number after
that, one counting step per layer.

The value in `main` builds two steps past `Zero`. Predict the displayed
value and its type before running; Ash reports
`Next(Next(Zero)) : Natural`.

## Comparison, one equation per form

To compare two `Natural` values, first name the answers comparison can
give:

<!-- source: src/02-compare.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

type Ordering =
    Less
    | Equal
    | Greater

compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Zero = Equal
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

main : Unit -> Ordering
main () = {
    let two = Next(Next(Zero))
    let three = Next(two)
    compare_natural two three
}
```

`Ordering` carries one constructor per outcome, and the function pairs
every form of one input with every form of the other. Two `Zero` values
are equal; `Zero` comes before every `Next` value, answering `Less`;
every `Next` value comes after `Zero`, answering `Greater`. Two `Next`
values each hide one counting step — removing both outside layers
compares the numbers that remain.

This is *structural recursion*, exactly as the lesson on recursive data
defined it: one equation per form, every recursive call receiving a
field of the matched value. Here two inputs are matched together, so
the call descends into both rests at once.

Ash has no integer literal patterns, so the program builds its values
with constructors; the bindings give the compared numbers readable
names. Follow the call:

```text
compare_natural two three
compare_natural (Next(Zero)) (Next(Next(Zero)))
compare_natural Zero (Next(Zero))
Less
```

Each call removes one layer from both sides until a `Zero` pairing
answers directly — the base case. Predict the results of the reversed
call, `compare_natural three two`, and of `compare_natural two two`
before trying them in your scratch copy. Run the program; Ash reports
`Less : Ordering`.

## The way back and the way down

Comparison stays inside `Natural`; to see the count a value carries,
convert it to an `Int`:

<!-- source: src/03-to-int.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

to_int : Natural -> Int
to_int Zero = 0
to_int Next(rest) = 1 + to_int rest

main : Unit -> Int
main () = to_int (Next(Next(Next(Zero))))
```

The base case names the count of `Zero` directly: `0`; the `Next`
equation asks for the count of the rest first, then adds one for the
outside layer. The additions wait on the recursive call:

```text
to_int (Next(Next(Next(Zero))))
1 + to_int (Next(Next(Zero)))
1 + (1 + to_int (Next(Zero)))
1 + (1 + (1 + to_int Zero))
1 + (1 + (1 + 0))
3
```

Each call hands its result back to the waiting addition, and the full
answer is assembled as the calls return — the result is built on the
way back from the base case. Predict the program's report; Ash answers
`3 : Int`.

The same conversion can carry its count into the calls instead:

<!-- source: src/04-to-int-down.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

to_int : Natural -> Int
to_int Zero = 0
to_int Next(rest) = 1 + to_int rest

to_int_down : Natural -> Int -> Int
to_int_down Zero count = count
to_int_down Next(rest) count = to_int_down rest (count + 1)

main : Unit -> (Int, Int)
main () = {
    let three = Next(Next(Next(Zero)))
    (to_int three, to_int_down three 0)
}
```

The second parameter holds the count so far: it starts at `0` in the
call, each `Next` equation increases it by one and passes it down, and
the base case hands back whatever arrives. A parameter that carries a
partial result toward the base case like this is called an
*accumulator*. The trace shows where the work happens now:

```text
to_int_down (Next(Next(Next(Zero)))) 0
to_int_down (Next(Next(Zero))) (0 + 1)
to_int_down (Next(Zero)) ((0 + 1) + 1)
to_int_down Zero (((0 + 1) + 1) + 1)
(((0 + 1) + 1) + 1)
3
```

No addition waits on a return: each step finishes before the next call
begins, and the base case returns the running total. The first function
computes on the way back from the base case; this one computes on the
way down. The program runs both shapes on the same value and pairs the
answers; predict the pair before running it. Ash reports
`(3, 3) : (Int, Int)` — both routes reach the same value.

## The pairing no equation answers

Coverage has checked every definition so far: a signature accepting
every `Natural` promises equations for every form. Remove the `Zero`
and `Zero` equation and the promise breaks exactly where `main` still
asks it a question:

<!-- source: src/05-missing-equal.ash -->
```ash
type Natural =
    Zero
    | Next(Natural)

type Ordering =
    Less
    | Equal
    | Greater

compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

main : Unit -> Ordering
main () = compare_natural Zero Zero
```

Run this version from `content/learn`:

<!-- diagnostic: src/05-missing-equal.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en ordering-from-data/src/05-missing-equal.ash
These cases do not cover every possible input; for example, `Zero Zero` is not covered.
  --> /path/to/ash-doc/content/learn/ordering-from-data/src/05-missing-equal.ash:10:1
10 | compare_natural : Natural -> Natural -> Ordering
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
11 | compare_natural Zero Next(right) = Less
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
12 | compare_natural Next(left) Zero = Greater
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
13 | compare_natural Next(left) Next(right) = compare_natural left right
   | ^ These cases do not cover every possible input; for example, `Zero Zero` is not covered.
reason: coverage.non-exhaustive
```
<!-- markdownlint-enable MD013 -->

The message names the uncovered pairing — `Zero` against `Zero` — and
labels the whole remaining definition, which was meant to answer it.
Restoring `compare_natural Zero Zero = Equal` keeps the promise.

## Exercise: double the number

Start from a fresh copy of `src/03-to-int.ash` in your scratch
directory, keeping the data definition. Define `double : Natural ->
Natural` the structural way: one equation per form of the data, the
recursive call receiving the rest. Call `double` on `Next(Next(Zero))`
and on `Next(Next(Next(Zero)))`, predicting each result before running.

## From data, the operations

Descent and comparison arrived without a single operator. A data
definition built the numbers, structural recursion built comparison on
top of it, and two process shapes carried a count to an `Int` and back.
The language declined subtraction and ordering operators; the build
replaced them with one number type and two operations — comparison and
conversion — guarded by the coverage check.

The Cases path makes the same move at larger scale: [Searching an
ordered tree](../../cases/searching-ordered-tree/README.md) stores
these unary numbers as keys and derives its branch choices from the
same four equations.

One step remains for values themselves. Every function so far has stood
behind a name, called where it was needed. Functions are also values:
they can be given as inputs, produced as results, and made for one
particular calculation. The next lesson takes that step.
