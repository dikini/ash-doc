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

Now run the file from your terminal:

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

The first line is the *signature* of `main`. Read `Unit -> Int` as “takes a
`Unit` value and produces an `Int` value.” `Unit` has one value, written `()`.
Because `main` receives `()`, it needs no information before calculating its
integer result. Together, the signature and definition describe the
calculation where this program begins.

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

What value do you expect? Work through the expression before asking Ash. Since
multiplication groups more tightly than addition, the calculation proceeds as
follows:

```text
1 + 2 * 3
1 + 6
7
```

Run the program and Ash reports `7 : Int`. The smaller multiplication
expression produces `6`; the addition then uses that value to produce `7`.

Suppose we want the addition to happen first instead. Parentheses let us make
that grouping part of the expression:

<!-- source: src/04-grouping.ash -->
```ash
main : Unit -> Int
main () = (1 + 2) * 3
```

Only the grouping has changed. Before you run this version, predict its value.
Then work through the calculation:

```text
(1 + 2) * 3
3 * 3
9
```

Run the file. Ash reports `9 : Int`. Parentheses make `1 + 2` the smaller
expression that Ash evaluates first.

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
definition uses its parameter:

```text
increment 41
41 + 1
42
```

The call therefore produces `42`, and so does `main`. Running the program
confirms the calculation:

```text
ash program.ash
42 : Int
```

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
Start with that inner call and work outward:

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

Save this version and run it. Instead of producing `42`, Ash reports a message
whose first line is:

```text
entry.missing-main
```

The definition of `answer` describes a calculation, but Ash does not guess
which definition should start the program. It looks for `main` and begins by
evaluating `main ()`. This is why every working program in the lesson has
included that name.

## Exercise: square, then double

Return to the program that defines `increment` and `double`. We no longer need
`increment` for this exercise, so replace it with a function that squares an
integer:

1. Define `square : Int -> Int`. Multiply its input by itself.
2. Change `main` so it calls `double (square 3)`.
3. Work from the inner call outward and predict the result.
4. Run the program and compare the result with your calculation.

When the two functions are connected correctly, Ash reports:

```text
18 : Int
```

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
