# Learn Ash

These chapters form one path through Ash. Work with the programs as you read.
Writing a program, predicting its result, and checking that prediction will
teach you more than reading the finished code alone.

## Before you begin

You need a text editor, a terminal, Git, and a Rust toolchain with Cargo. Follow
[Prepare Ash](../../README.md#prepare-ash) to clone the source selected for this
edition, build the command-line tool, and make `ash` available in your terminal.
Keep that terminal open while you work through a lesson.

To compare a rejection with its displayed message, run the named checked-in
example from the learning-path directory:

```text
cd /path/to/ash-doc/content/learn
```

The diagnostic commands below use those files even when the exploration asks
you to edit your own `program.ash` or `main.ash`. Follow the shared
[diagnostic reading notes](../../README.md#read-a-diagnostic) for the prompt,
English output, and source-path convention.

## How to work through a lesson

Use the same cycle for each program:

1. Edit the program in your text editor.
2. Predict the value it will produce.
3. Run the program with `ash`.
4. Inspect the value and type that `ash` displays.
5. Explain why the program produced that result.

When your prediction differs from the result, pause. Work through the
expressions one at a time, change the program, and run it again.

## Learning with an assistant

You can work through every chapter without an assistant. If you use an LLM
chat or coding agent, give it the current lesson, your program, and the output
from `ash`. This instruction establishes its role:

> Use this lesson, the repository, and the output from `ash` as evidence.
> Ask one question at a time. Help me compare my prediction with the result.
> Use only ideas introduced so far unless I ask to look ahead. Do not give me
> a finished exercise solution before helping me reason about it.

An assistant can help you examine a program or form a question. Run the program
with `ash` to test what it does.

## Contents

1. [What is an Ash program?](what-is-an-ash-program/README.md) — produce values
   with expressions and functions.
2. [How can one source file use another?](using-another-source-file/README.md) —
   connect modules through imports, public declarations, and qualified names.
3. [How can a function use more than one input?](using-more-than-one-input/README.md)
   — supply chained inputs, pause at a partial call, and read function arrows.
4. [How can a program choose a result?](choosing-a-result/README.md) — use
   integer equality, Boolean values, and exhaustive matching to select a result.
5. [How can a calculation name an intermediate value?](naming-intermediate-values/README.md)
   — make a block's steps visible with local bindings.
6. [How can several values travel together?](values-travel-together/README.md) —
   keep fixed collections of typed values together with tuples and tuple
   patterns.
7. [How can a program define its own data?](defining-data/README.md) — name a
   new type and the constructors for its possible values.
8. [How can a function handle each form of data?](handling-data-forms/README.md)
   — follow a data definition with patterns and exhaustive cases.
9. [How can a function follow recursive data?](following-recursive-data/README.md)
   — follow a self-reference with a recursive function and a stopping form.
10. [How can a function itself be a value?](functions-as-values/README.md) —
    receive, construct, and return function values.
11. [How can one definition work with many types?](definitions-for-many-types/README.md)
    — reuse functions and data definitions through type parameters.

## Continue learning

[Working with effects and scoped resources](../effects/README.md) begins with
one new question: how can a calculation request a value that a surrounding
handler supplies? It builds on the functions and signatures used in this path.
