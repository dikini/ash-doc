# What Is an Ash Program? Design

- Status: approved
- Content family: `learn`
- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`

## Reader question

What is an Ash program, and how do I write and run one?

The unit assumes no Ash knowledge. It explains a value, type, function, call,
and evaluation when the reader first needs each idea. It does not begin with
the specification's compressed description of the complete language.

## Observable outcome

The reader writes and runs one source file whose `main` function returns an
integer. The `ash` tool reports:

```text
42 : Int
```

By the end, the reader can predict and modify a program whose result flows
through two nested function calls.

## Compared boundaries

### One-file, observation-first unit

Begin with the smallest runnable program and grow its result from a literal to
arithmetic and nested calls. One file is one passive source module, so this is a
truthful instance of the Modular Ash program model without requiring imports.

This is the selected boundary.

### Module-first unit

A two-file program would expose the dependency graph immediately. It would also
require paths, imports, aliases, visibility, and qualified names before the
reader understands `main` or a function call.

### Syntax-first micro-units

Separate expression and function lessons would make each page short. They would
also delay the answer to the reader's main question and repeat the entry and
execution setup across several incomplete explanations.

## Learning progression

1. Run `main () = 42` and observe `42 : Int`.
2. Replace the literal with `40 + 2`.
3. Predict `1 + 2 * 3`, then contrast it with `(1 + 2) * 3`.
4. Define `increment : Int -> Int` and call it from `main`.
5. Define `double` and evaluate `double (increment 20)`.
6. Rename `main`, observe `entry.missing-main`, and explain why the file is not
   a runnable entry program.
7. Close with an exercise that defines `square` and nests it inside `double`.

The unit defines composition as passing one function's result to another. It
does not introduce a general higher-order composition function.

## Unit shape

Create:

```text
content/learn/what-is-an-ash-program/
  README.md
  src/
    01-literal.ash
    02-addition.ash
    03-precedence.ash
    04-grouping.ash
    05-function-call.ash
    06-composition.ash
    07-missing-main.ash
  checks/
    verify.sh
```

The numbered sources are complete programs, not fragments. The README presents
each source through a checked `ash` fence. Hidden source markers let the local
verifier compare every displayed block with its canonical file.

`checks/verify.sh` accepts the path to a clean `ash-lang` checkout. It rejects a
checkout whose `HEAD` is not the documented commit, builds with the retained
lockfile in a temporary target directory, and checks:

- status `0`, empty standard error, and exact `value : Type` output for six
  accepted programs;
- status `1`, empty standard output, and `entry.missing-main` with its causal
  source label for the rejected program; and
- exact agreement between every displayed Ash block and its source file.

This Bash check is local to the unit. Reconsider a shared harness only when a
second complete unit demonstrates the same stable need.

## Explanation boundary

Explain:

- a `.ash` source file and the entry file;
- the smallest one-module program;
- `main`, `Unit`, `()`, `Int`, and `->` in the first example;
- expressions, operator order, grouping, signatures, definitions, arguments,
  calls, and nested calls as they appear; and
- the difference between returning a value and printing text.

Defer imports, `pub`, multiple modules, Boolean values, nominal data, blocks,
patterns, polymorphism, interfaces, general diagnostics, and a syntax catalog.
The next unit can ask how one Ash source module uses another.

## Governing sources

Language claims derive from the pinned specification overview and its lexical,
syntax, static-semantics, and dynamic-semantics chapters. Command, output, and
failure claims derive from the pinned `ash` tool guide and executable behavior.

The unit is original Ash exposition. It adapts no external exercise or protected
source material.
