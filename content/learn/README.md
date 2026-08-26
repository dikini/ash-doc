# Learn Ash

These chapters form one path through Ash. Work with the programs as you read.
Writing a program, predicting its result, and checking that prediction will
teach you more than reading the finished code alone.

## Before you begin

You need a text editor, a terminal, Git, and a Rust toolchain with Cargo. Follow
[Prepare Ash](../../README.md#prepare-ash) to clone the source selected for this
edition, build the command-line tool, and make `ash` available in your terminal.
Keep that terminal open while you work through a lesson.

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
   connect modules with public definitions and qualified names.
3. [How can a function use more than one input?](using-more-than-one-input/README.md)
   — read chained arrows, complete calls, and partial calls.
4. [How can a program choose a result?](choosing-a-result/README.md) — use
   Boolean values and exhaustive matches to select an expression.
