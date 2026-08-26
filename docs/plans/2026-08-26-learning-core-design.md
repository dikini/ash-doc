# Learning core design

## Problem

The first learning unit has verified examples, but its prose reads as a project
record. It renders state, target, prerequisites, evidence links, source links,
and specification administration before teaching. It also explains language
and tool boundaries that a novice does not need at that point.

This is a workflow defect. The workflow asks every unit page to carry both the
lesson and the records used to govern it. Future lessons written under that
rule would form a collection of self-contained reports rather than a coherent
self-learning path.

## Chosen shape

Use `content/learn/` as a sequential learning core. Its `README.md` is the
front door: it contains one-time setup, explains the edit-run-reflect cycle,
describes optional use of a learning assistant, and lists lessons in order.
Each lesson assumes that setup and builds on concepts introduced earlier.

This approach sits between two rejected shapes:

- Hiding the current metadata while retaining standalone units would remove
  clutter but preserve repeated setup and fragmented exposition.
- Combining the learning core into one file would strengthen continuity but
  make bounded source agreement, executable checks, and incremental work
  harder to maintain.

Lesson directories remain useful evidence boundaries. Their rendered
`README.md` files are chapters, not project records.

## Information ownership

The repository root owns the edition target, resolved Ash commit, authority
boundary, and source-of-truth navigation. A lesson inherits that target and
does not repeat it.

Project workflow and plans own state, governing sources, exclusions, evidence,
and verification status. Canonical programs and checks remain beside the
lesson. Invisible source markers may connect displayed Ash blocks to those
programs, but the lesson does not narrate that machinery.

Rendered learning pages do not display:

- draft or verification state;
- milestone names or commit hashes;
- reader-question, prerequisite, or outcome fields;
- governing specification inventories;
- canonical-source and evidence links;
- adaptation administration; or
- project limitations and exclusions.

Do not add page-local metadata without a concrete consumer. If a future
renderer needs metadata, place it in YAML front matter. Do not render an
administrative header as lesson prose.

## Teaching environment

The current teaching environment consists of a text editor and the `ash` CLI.
The learning core does not assume a REPL, notebook, editor extension, or IDE.
The front door explains tool setup once. Lessons use one cycle:

1. edit a complete `.ash` file;
2. predict what the program will produce;
3. run the file with `ash`;
4. compare the result with the prediction; and
5. explain the result in terms introduced so far.

An editor or IDE may later improve this cycle. Such a tool should change setup
or interaction guidance without forcing a rewrite of the conceptual sequence.

## Lesson method

Adapt the progression of *How to Design Programs*, not its wording or Racket
environment. Begin with an action and an observable program. After the reader
has seen the program work, introduce the words that name its parts. Move from
worked examples to short rules, predictions, contrasts, and exercises.

A lesson should:

- begin in the subject rather than with its learning objectives;
- connect its opening to the model established by earlier lessons;
- introduce one conceptual move at a time;
- show intermediate calculation steps when they explain a result;
- ask the reader to predict before revealing an observation;
- introduce vocabulary after the example creates a need for it;
- use a rejection only when it answers a reader question; and
- end with practice and the next question in the learning sequence.

The prose must remain complete without an assistant. It should sound like a
teacher working through a program with the reader, not like a summary of the
specification or a report about repository evidence.

## Learning assistants

A learner may use an LLM chat or coding agent as a tutor. This assistance is
optional. It cannot replace editing the program, predicting its behavior, or
running `ash`.

The front door gives the assistant a standing tutoring contract:

- use the current lesson, repository, and observed CLI result as evidence;
- do not rely on remembered Ash syntax or behavior;
- ask one focused question at a time;
- help the learner compare a prediction with an observation;
- use only concepts introduced so far unless the learner asks to look ahead;
- do not provide a finished exercise solution before helping the learner
  reason about it; and
- treat `ash` as the test of program behavior.

Lessons may include sparse, visible prompts where dialogue improves a
prediction, explanation, or debugging step. Prompts remain product-neutral and
short. They should ask the assistant to support reasoning, not generate the
next program on the learner's behalf.

## First lesson rewrite

Keep the seven canonical example programs and their checks. Rewrite the lesson
around one working file, `program.ash`:

1. produce `42` and inspect `42 : Int`;
2. replace the literal with arithmetic and predict the result;
3. compare precedence with explicit grouping through calculation steps;
4. introduce a named function after the reader has worked with expressions;
5. call one function with the result of another;
6. remove `main` to answer why the earlier programs shared that name; and
7. restore the composed program and add `square` as an exercise.

Explain `main` as the definition where this program begins. Do not introduce
entry-module, local-declaration, milestone, diagnostic-contract, or
specification terminology. Remove rendered canonical-source links and the
sources section. Retain invisible source markers for verification.

Add at most two assistant prompts: one after the precedence contrast and one
for the final exercise. The lesson remains usable when both prompts are
ignored.

## Workflow changes

Update the project workflow, `AGENTS.md`, and the project writing skill to
separate teaching from administration. Planning still records exact targets,
governing sources, exclusions, and evidence. Verification still checks every
semantic and tool claim against the repository target. These requirements
govern how lessons are produced; they do not become lesson content.

Add writing-skill scenarios that reject rendered administrative headers and
standalone-unit repetition, and that accept hidden source markers and optional
assistant prompts grounded in observed behavior.

## Verification

The change is complete when:

- the existing seven-program verifier passes without source changes;
- every displayed Ash block still agrees with its canonical source;
- the learning front door contains the one-time CLI and assistant setup;
- the first lesson contains no rendered target, state, evidence, source, or
  specification administration;
- the lesson can be followed without an assistant;
- assistant prompts defer program truth to the observed CLI behavior;
- project guidance preserves the target and evidence requirements outside the
  lesson; and
- Markdown, skill validation, links, shell syntax, and Git checks pass.

## Source and adaptation

The teaching shape is inspired by Matthias Felleisen, Robert Bruce Findler,
Matthew Flatt, and Shriram Krishnamurthi, *How to Design Programs*, second
edition. The material consulted was the 25 February 2026 online release,
especially [Prologue: How to Program](https://htdp.org/2026-2-25/Book/part_prologue.html)
and the opening of
[Part I: Fixed-Size Data](https://htdp.org/2026-2-25/Book/part_one.html).

The source is published under CC BY-NC-ND 2.0. Ash-doc adopts the pedagogical
ideas of beginning with interaction, introducing vocabulary after examples,
predicting results, showing calculations, and practicing with exercises. It
does not copy the source's wording, examples, exercises, code, or solutions.

## Exclusions

This change does not select a renderer, schema, REPL, notebook, editor
extension, IDE, chat product, or agent protocol. It does not alter Ash programs
or semantics. It does not design the second lesson.
