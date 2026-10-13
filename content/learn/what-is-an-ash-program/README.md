# What is an Ash program?

It is common to think of a program as a list of commands: do this, then do
that. An Ash source file has a different shape. It contains definitions. Those
definitions describe expressions, and expressions calculate values.

A runnable Ash program also needs a place to begin. Ash uses a definition named
`main`. When you give a source file to `ash`, it evaluates `main ()` and reports
the resulting value and its type. Our first program keeps that calculation
small enough to see as a whole.

Open a text editor, enter these two lines, and save them as `program.ash`:

<!-- source: src/01-literal.ash -->
```ash
main : Unit -> Int
main () = 42
```

The second line defines the calculation: its right side is the integer
`42`. The first line is its *signature*. Read `Unit -> Int` as “takes a
`Unit` value and produces an `Int` value.” `Unit` has one value, written
`()`; `Int` is the type of integer values.

Predict the value that `main ()` produces, then run the file from your terminal:

```text
ash program.ash
```

Ash reports:

```text
42 : Int
```

Let us slow down and read the two lines. The second line defines `main`. Its
right side, `42`, is an *expression*. Evaluating that expression produces the
value `42`. `ash` reports the value together with its type, `Int`, which is
the type of integer values.

Because `main` receives `()`, it needs no input information before calculating
its integer result. Together, the signature and definition describe the
calculation where this program begins. The [entry rules][entry] require that
starting definition in the file selected for execution.

## Expressions calculate values

Nothing in our first expression had to be worked out: `42` is already a value.
An expression may also combine values with an operation. Suppose we still want
`42`, but want to obtain it by addition. Change the program to this:

<!-- source: src/02-addition.ash -->
```ash
main : Unit -> Int
main () = 40 + 2
```

The right side of `main` is now the expression `40 + 2`. Before running the
file, work out its value. The same command now reports:

```text
ash program.ash
42 : Int
```

Both programs produce the same value. In the first, the expression is already
`42`. In the second, Ash evaluates an addition to produce `42`.

Expressions can contain smaller expressions. Consider what must happen when
two different arithmetic operations appear together:

<!-- source: src/03-precedence.ash -->
```ash
main : Unit -> Int
main () = 1 + 2 * 3
```

Multiplication groups more tightly than addition. Use that rule to predict
the value before running. Ash reports `7 : Int`; compare it with these steps:

```text
1 + 2 * 3
1 + 6
7
```

The smaller multiplication produces `6`; the addition then uses that value
to produce `7`.

Suppose we want the addition to happen first instead. Parentheses let us make
that grouping part of the expression:

<!-- source: src/04-grouping.ash -->
```ash
main : Unit -> Int
main () = (1 + 2) * 3
```

Only the grouping has changed. Predict its value, then run the file.
Ash reports `9 : Int`. The calculation now proceeds this way:

```text
(1 + 2) * 3
3 * 3
9
```

Parentheses make `1 + 2` the smaller expression that Ash evaluates first.

> **With a learning assistant:** Run both grouping programs. Show the assistant
> your predictions, the two programs, and the actual results from `ash`. Explain
> the difference yourself, then ask the assistant to question your explanation
> one step at a time.

So far, `main` has held the entire calculation. Even the nested examples fit on
one line. As a calculation grows, we need a way to name a useful part and use
it inside another expression.

## Giving a calculation a name

The next program names a calculation `increment`. It adds one to an integer:

<!-- source: src/05-function-call.ash -->
```ash
increment : Int -> Int
increment number = number + 1

main : Unit -> Int
main () = increment 41
```

The first two lines belong together. The signature `Int -> Int` says that
`increment` takes an integer and produces an integer. In the definition,
`number` is a *parameter*: it stands for whichever input `increment` receives.
The expression `number + 1` describes how the result is calculated.

The last line uses the expression `increment 41`. This is a *function call*,
and `41` is its *argument*. To understand the call, use `41` wherever the
definition uses its parameter. Predict the result before running:

```text
ash program.ash
42 : Int
```

The substitution explains that observation:

```text
increment 41
41 + 1
42
```

The argument replaces the parameter with `41`, so the addition and the
enclosing `main` both produce `42`.

Once a calculation has a name, it can take part in another calculation. Add a
function that doubles an integer, then use both functions in `main`:

<!-- source: src/06-composition.ash -->
```ash
increment : Int -> Int
increment number = number + 1

double : Int -> Int
double number = number * 2

main : Unit -> Int
main () = double (increment 20)
```

The parentheses keep `increment 20` together as the argument to `double`.
Start with that inner call and work outward to predict the result. Run the
program, then compare its `42 : Int` observation with the trace:

```text
double (increment 20)
double 21
21 * 2
42
```

Ash reports `42 : Int`, just as the calculation predicts. Here the result of
`increment` becomes the input to `double`. Connecting functions in this way is
called *function composition*.

## Where does evaluation begin?

Our latest source file contains three definitions, yet Ash begins with `main`.
Is `main` merely a name we happened to choose? We can find out by giving the
same kind of calculation a different name:

<!-- source: src/07-missing-main.ash -->
```ash
answer : Unit -> Int
answer () = 42
```

Which definition in this file could supply the required `main ()` call?
Run the saved example from `content/learn` to check that entry requirement:

<!-- diagnostic: src/07-missing-main.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en what-is-an-ash-program/src/07-missing-main.ash
The entry module must define its own `main`; importing one is not enough.
  --> /path/to/ash-doc/content/learn/what-is-an-ash-program/src/07-missing-main.ash:1:1
1 | answer : Unit -> Int
  | ^ This is the entry module.
2 | answer () = 42
  | ^ This is the entry module.
reason: entry.missing-main
```
<!-- markdownlint-enable MD013 -->

The first sentence names what is missing: the entry module must define its
own `main`. The source labels cover this file's `answer` definition and identify
it as the entry module. Nothing in those lines is named `main`. The sentence
also mentions imports; we will meet those in the next chapter. For this
one-file program, rename both occurrences of `answer` to `main` to give Ash
its starting definition.

The definition of `answer` describes a calculation, but Ash does not guess
which definition should start the program. It looks for `main` and begins by
evaluating `main ()`. This is why every working program in the lesson has
included that name.

## Exercise: square, then double

Start with a fresh copy of `src/06-composition.ash` in your scratch directory,
saved as `program.ash`. Replace `increment` with a function that squares an
integer:

1. Define `square : Int -> Int`. Multiply its input by itself.
2. Change `main` so it calls `double (square 3)`.
3. Work from the inner call outward and predict the result.
4. Run the program and compare the result with your calculation.

> **With a learning assistant:** Show the assistant your program, prediction,
> and actual result from `ash`. Ask it to point to one expression at a time and
> ask what value that expression produces. Request a complete solution only
> after you have explained your own.

## The whole program

We can now answer the question in the title. At its simplest, an Ash program is
one source file containing definitions, including one named `main` where
evaluation begins. A definition gives a calculation a name. The expression on
its right determines the value it produces, and function calls let one
calculation use a value produced by another.

When you run the file, Ash evaluates `main ()` and reports the resulting value
and type. Every program here fits in one source file, but Ash programs need not
stop there. The next question is how a definition in one file can be used from
another.

[entry]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#globals-and-modules
