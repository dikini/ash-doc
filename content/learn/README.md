# Learn Ash

These chapters form one path through Ash. Work with the programs as you read.
Writing a program, predicting its result, and checking that prediction will
teach you more than reading the finished code alone. The path is written for
beginners; no prior programming experience is assumed.

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

The first thirteen lessons use that shared directory for diagnostic commands.
The two continuation chapters state their own lesson-local `src` directory.
The diagnostic commands use checked-in files even when the exploration asks
you to edit your own `program.ash` or `main.ash`. Follow the shared
[diagnostic reading notes](../../README.md#read-a-diagnostic) for the prompt,
English output, and source-path convention.

## How to work through a lesson

Keep your working programs in a scratch directory outside the checked-in
lesson `src` trees. The chapters build on those working programs; each exercise
names a fresh starting point. For a program with imports, keep its entry and
required sibling files together in that directory.

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

<!-- markdownlint-disable MD029 -->
1. [An Ash program](what-is-an-ash-program/README.md) — produce values
   with expressions and functions.
2. [Using another source file](using-another-source-file/README.md) —
   connect modules through imports, public declarations, and qualified names.
3. [Using more than one input](using-more-than-one-input/README.md)
   — supply chained inputs, pause at a partial call, and read function arrows.
4. [Choosing a result](choosing-a-result/README.md) — use
   integer equality, Boolean values, and exhaustive matching to select a result.
5. [Naming intermediate values](naming-intermediate-values/README.md)
   — make a block's steps visible with local bindings.
6. [Making values travel together](values-travel-together/README.md) —
   keep fixed collections of typed values together with tuples and tuple
   patterns.
7. [Working with text](working-with-text/README.md) — display, measure, and
   convert text with `String` values.
8. [Defining data](defining-data/README.md) — name a
   new type and the constructors for its possible values.
9. [Handling data forms](handling-data-forms/README.md)
   — follow a data definition with patterns and exhaustive cases.
10. [Patterns in depth](patterns-in-depth/README.md) — name exactly what a
    value contains with wildcards, nested patterns, and literal patterns.
11. [Following recursive data](following-recursive-data/README.md)
    — follow a self-reference with a recursive function and a stopping form.
12. [Functions as values](functions-as-values/README.md) —
    receive, construct, and return function values.
13. [Definitions for many types](definitions-for-many-types/README.md)
    — reuse functions and data definitions through type parameters.

### Continuation chapters

14. [Generalizing local functions](generalizing-local-functions/README.md)
    — distinguish local generalization from a fixed function value.

15. [Defining local recursion](defining-local-recursion/README.md)
    — use annotated recursive groups and distinguish guarded construction
    from forcing unfinished data.
<!-- markdownlint-enable MD029 -->

## Continue learning

[Working with effects and scoped resources](../effects/README.md) begins with
one new question: how can a calculation request a value that a surrounding
handler supplies? It builds on the functions and signatures used in this path.
