# What is an Ash program?

Begin with a small question: can an Ash program produce the number `42`?

Create a file named `program.ash` in this directory and enter these two lines:

<!-- source: src/01-literal.ash -->
```ash
main : Unit -> Int
main () = 42
```

Before you run it, predict what you will see. Then ask Ash to run the file:

```text
ash program.ash
```

Ash responds:

```text
42 : Int
```

You have written an Ash program. The program produces the value `42`, and
`ash` displays that value with its type, `Int`. `Int` is the type of integer
values.

Now return to the program. The expression to the right of `=` produces the
result. Here that expression is the integer value `42`.

The first line is a signature. It says what kind of value goes into `main` and
what kind comes out. Read `Unit -> Int` as “takes `Unit` and produces an
`Int`.” `Unit` has one value, written `()`. A `main` that takes `()` needs no
information before it can produce its result.

The name `main` tells Ash where this program begins. We will test that claim
later. First, let us make the result from an expression.

## Calculating a value

Replace the contents of `program.ash` with this program:

<!-- source: src/02-addition.ash -->
```ash
main : Unit -> Int
main () = 40 + 2
```

The expression `40 + 2` combines two integer values. Predict the result, then
run the program again:

```text
ash program.ash
42 : Int
```

The result is still `42 : Int`. This time the expression calculates the value
instead of naming it directly.

Expressions may contain other expressions. What does this program produce?

<!-- source: src/03-precedence.ash -->
```ash
main : Unit -> Int
main () = 1 + 2 * 3
```

Make a prediction before you run it. Ash displays:

```text
7 : Int
```

Multiplication happens before addition. Work from the smaller expression to
the whole expression:

```text
1 + 2 * 3
1 + 6
7
```

Parentheses let you choose a different grouping:

<!-- source: src/04-grouping.ash -->
```ash
main : Unit -> Int
main () = (1 + 2) * 3
```

Now the expression in parentheses is calculated first:

```text
(1 + 2) * 3
3 * 3
9
```

Replace `program.ash`, predict the result, and run it. Ash displays `9 : Int`.

> **With a learning assistant:** Share both calculations and explain why they
> differ. Ask the assistant to question your explanation one step at a time
> without giving its own explanation first.

## Giving a calculation a name

So far, `main` contains the whole calculation. When a calculation has a useful
role, you can give it a name and use it where it is needed.

The next program names the calculation that adds one:

<!-- source: src/05-function-call.ash -->
```ash
increment : Int -> Int
increment number = number + 1

main : Unit -> Int
main () = increment 41
```

Replace `program.ash` with this program. Before you run it, work out what
`increment 41` should produce.

```text
ash program.ash
42 : Int
```

The first line is the signature of `increment`. It says that `increment` takes
an `Int` and produces an `Int`.

The second line defines the calculation. The name `number` is the parameter. It
stands for the input while the function calculates `number + 1`.

The expression `increment 41` is a function call. The value `41` is the
argument: the value supplied for `number`. The call produces `42`, so `main`
also produces `42`.

## Putting function calls together

Add another named calculation, this time one that doubles an integer:

<!-- source: src/06-composition.ash -->
```ash
increment : Int -> Int
increment number = number + 1

double : Int -> Int
double number = number * 2

main : Unit -> Int
main () = double (increment 20)
```

The result of `increment 20` becomes the input to `double`. Trace the calls
from the inner expression outward:

```text
double (increment 20)
double 21
42
```

Check the calculation by running the program:

```text
ash program.ash
42 : Int
```

Using one function's result as another function's input is function
composition. The parentheses keep `increment 20` together as the input to
`double`.

## Why does the program need `main`?

Every program so far has included `main`. To see why, replace `program.ash`
with a function that has a different name:

<!-- source: src/07-missing-main.ash -->
```ash
answer : Unit -> Int
answer () = 42
```

The definition of `answer` describes a valid calculation, but running the file
does not produce `42`. The message begins with:

```text
ash program.ash
entry.missing-main
```

Ash needs a definition named `main` to know where this program begins. It does
not choose another function merely because that function could produce a
result.

## Exercise: square, then double

Return `program.ash` to the version from “Putting function calls together.”
Then change it:

1. Define `square : Int -> Int`. Calculate the square by multiplying the input
   by itself.
2. Change `main` so it calls `double (square 3)`.
3. Predict the result before you run the program.
4. Run it, then explain the result by working from the inner call outward.

When the two calls are connected correctly, `ash` displays:

```text
18 : Int
```

> **With a learning assistant:** Show the assistant your program and prediction.
> Ask it to point to one expression at a time and ask what value that expression
> produces. Ask for a complete solution only after you have explained your own.

## The program you built

An Ash program contains definitions. To run the programs in this lesson, you
gave `ash` a source file with a definition named `main`. Ash began with
`main ()`, calculated its expression, and produced a value.

Expressions describe calculations. Functions give calculations names. Function
calls let one calculation use a value or the result of another calculation.

Each program in this lesson fit in one source file. The next question is how an
Ash program can use more than one file.
