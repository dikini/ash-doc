# What is an Ash program?

- State: verified
- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Reader question: What is an Ash program, and how do I write and run one?
- Prerequisites: editing a text file and running a command in a terminal
- Outcome: write, run, predict, and change a one-file Ash program
- Adaptation: original Ash exposition and examples

A traditional first program prints a greeting. This Ash milestone has no text
or program input and output, so we will begin with a result that Ash can
produce: the number `42`.

By the end, several functions will work together to produce that result. Each
step is a complete program that you can run.

## Produce a value

An Ash program is written in files whose names end in `.ash`. Create a file with
this source:

<!-- source: src/01-literal.ash -->
```ash
main : Unit -> Int
main () = 42
```

The checked source for this step is
[`src/01-literal.ash`](src/01-literal.ash). From this unit's directory, run:

```text
ash src/01-literal.ash
```

The `ash` tool reports:

```text
42 : Int
```

The output has a value, `42`, and its type, `Int`. `Int` is the type of integer
values.

The first source line says that `main` has type `Unit -> Int`. Read the arrow as
“takes `Unit` and produces `Int`.” `Unit` has one value, written `()`. Giving
`main` that value means the program needs no useful input.

The second line defines what `main` does with `()`. The expression to the right
of `=` produces the program's result.

When you give `ash` a source path, that file is the entry file. Every Ash source
file is one module. This program has no imports, so its complete program is one
module. Ash checks that module, finds its local `main`, and evaluates `main ()`.

The program does not print `42`. The program produces the value. The `ash` tool
displays that value and its type.

## Build an expression

A literal such as `42` is an expression. An operator can combine smaller
expressions into another expression.

Replace the literal with an addition:

<!-- source: src/02-addition.ash -->
```ash
main : Unit -> Int
main () = 40 + 2
```

The checked source is [`src/02-addition.ash`](src/02-addition.ash). Before you
run it, predict the value that `main ()` will produce.

```text
ash src/02-addition.ash
42 : Int
```

The type is still `Int`. Changing the expression changed how Ash reached the
value, not the kind of value it produced.

Now predict this result:

<!-- source: src/03-precedence.ash -->
```ash
main : Unit -> Int
main () = 1 + 2 * 3
```

The checked source is [`src/03-precedence.ash`](src/03-precedence.ash).
Multiplication happens before addition, so Ash first produces `6` from `2 * 3`,
then adds `1`:

```text
ash src/03-precedence.ash
7 : Int
```

Parentheses can change that order:

<!-- source: src/04-grouping.ash -->
```ash
main : Unit -> Int
main () = (1 + 2) * 3
```

The checked source is [`src/04-grouping.ash`](src/04-grouping.ash). Ash now
performs the addition first:

```text
ash src/04-grouping.ash
9 : Int
```

## Name a calculation

A function gives a name to a calculation. Here is a function that adds one:

<!-- source: src/05-function-call.ash -->
```ash
increment : Int -> Int
increment number = number + 1

main : Unit -> Int
main () = increment 41
```

The checked source is
[`src/05-function-call.ash`](src/05-function-call.ash).

The first line is `increment`'s signature. A signature states the input type and
the result type. `increment` takes an `Int` and produces an `Int`.

The second line defines the function. `number` is the parameter: the name used
for the input inside the definition.

The expression `increment 41` calls the function. `41` is the argument supplied
for `number`. The call produces `42`, which becomes the result of `main`:

```text
ash src/05-function-call.ash
42 : Int
```

## Combine function calls

One function can use the result of another:

<!-- source: src/06-composition.ash -->
```ash
increment : Int -> Int
increment number = number + 1

double : Int -> Int
double number = number * 2

main : Unit -> Int
main () = double (increment 20)
```

The checked source is [`src/06-composition.ash`](src/06-composition.ash).

Start with the call inside the parentheses. `increment 20` produces `21`. That
value becomes the argument to `double`, which produces `42`:

```text
ash src/06-composition.ash
42 : Int
```

Passing one function's result to another function is composition. Here,
parentheses keep the inner call together as the one argument to `double`.

## A runnable program needs `main`

This file contains a function but no `main`:

<!-- source: src/07-missing-main.ash -->
```ash
answer : Unit -> Int
answer () = 42
```

The checked source is [`src/07-missing-main.ash`](src/07-missing-main.ash).
When you select it as the entry file, Ash rejects it. The first diagnostic line
names the reason:

```text
ash src/07-missing-main.ash
entry.missing-main
```

`answer` is a valid function definition, but Ash does not guess which function
should start the program. The selected entry module must define its own `main`.

## Exercise: add `square`

Start from [`src/06-composition.ash`](src/06-composition.ash).

1. Define `square : Int -> Int` using multiplication.
2. Change `main` so that it evaluates `double (square 3)`.
3. Predict the result, then run the program.

Your artifact is one complete `.ash` source file. This exercise practices
function signatures, definitions, multiplication, and nested calls. The
expected observation is:

```text
18 : Int
```

## What you established

An Ash program starts from the source file you give to `ash`. That entry file
must define a local `main` that takes `Unit`. Ash checks the program, evaluates
`main ()`, and the tool displays the resulting value and type.

The program in this unit has one source module. A larger Ash program can use
more than one. That leads to the next question: how can one Ash source module
use another?

## Sources

Language behavior comes from the specification at the pinned commit:

- [specification overview](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md)
- [lexical structure](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/lexical-structure.md)
- [syntax](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md)
- [static semantics](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md)
- [dynamic semantics](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md)

Command, output, and failure behavior comes from the pinned
[`ash` tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md).
