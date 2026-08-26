# Learn Ash

These chapters form one path through Ash. Work with the programs as you read.
Writing a program, predicting its result, and checking that prediction will
teach you more than reading the finished code alone.

## Before you begin

You need a text editor, a terminal, and the Ash source checkout selected in the
[repository README](../../README.md). From the root of that Ash checkout, build
the command-line tool:

```text
cargo build --locked
```

The executable is now `target/debug/ash`. To use the shorter command `ash`,
replace `/path/to/ash-lang` with the full path to your checkout and run:

```text
export PATH="/path/to/ash-lang/target/debug:$PATH"
```

This setting lasts for the current terminal. Keep that terminal open while you
work through a lesson.

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
