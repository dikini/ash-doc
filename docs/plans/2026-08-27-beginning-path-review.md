# Beginning Path Review Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Review the eleven-lesson beginning path as one reader experience,
make the smallest evidence-backed revisions, and close the roadmap increment.

**Architecture:** Use the temporary plan as the course audit ledger while the
work remains active. Establish the executable baseline, audit the three course
parts in order, classify findings before editing, and verify the complete path
after revision. Keep lesson prose, canonical programs, and checks in their
existing local boundaries.

**Tech Stack:** Markdown, Bash, Git, `markdownlint-cli2`, and Ash
`modular-ash` at `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Worktree and authority

Work in `/home/dikini/Projects/ash-doc/.worktrees/beginning-path-review` on
branch `docs/beginning-path-review`. Do not merge or push the branch while
executing this plan.

Use @writing-ash-documentation for every lesson or project-prose review and
edit. Use the pinned specification for language claims and the pinned tool
guide, implementation, and tests for commands and executable observations.
Do not import language behavior from current `ash-lang/main`.

The clean pinned Ash checkout is:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Make unsigned commits with:

```bash
git -c commit.gpgsign=false commit --no-gpg-sign -m "<message>"
```

## Audit ledger

During Tasks 2 through 4, add concise findings below this paragraph. Each
finding must name the lesson and exact passage, the earlier idea on which it
depends, the observable reader or executable evidence, and one disposition:
retain, revise locally, verify against a governing source, consider structural
change, or route outside ash-doc. Do not propose wording until the evidence and
disposition are recorded.

### Baseline

- Intended outcome: a learner can design, run, and explain a pure multi-file
  Ash program over data they define; trace values through functions; use
  patterns to distinguish data; follow a data definition with recursion; and
  use type parameters when a definition does not depend on a particular
  element type.
- Lesson order:

  1. *What is an Ash program?*
  2. *How can one source file use another?*
  3. *How can a function use more than one input?*
  4. *How can a program choose a result?*
  5. *How can a calculation name an intermediate value?*
  6. *How can several values travel together?*
  7. *How can a program define its own data?*
  8. *How can a function handle each form of data?*
  9. *How can a function follow recursive data?*
  10. *How can a function itself be a value?*
  11. *How can one definition work with many types?*
- Excluded topics: interfaces, implementations, constraints, or ad-hoc
  polymorphism; opaque or hidden representation boundaries; targeted imports,
  named roots, or re-export details; advanced restrictions on recursive
  initialization; and documentation tooling and publication mechanisms.
- Review boundary: cross from lesson-local executable verification to the
  continuity of the eleven lessons as one reader experience. Audit
  prerequisites, transitions, vocabulary, exercises, assistant prompts, and
  the final outcome without adding another language topic.
- Executable baseline: `Verified 11 learning lesson(s) at
  dca16039923475c48025c5f17beadeb6bcb6a4bf.`

### Lessons 1–5: programs and calculations

#### Lesson 1: *What is an Ash program?*

- **Prerequisites and opening — retain.** The opening before the first
  `ash program.ash` command assumes only the index setup and contrasts a list
  of commands with definitions whose expressions calculate values. It then
  establishes `main ()` as the entry calculation and `value : Type` as the
  observation. The `01-literal.ash` result is `42 : Int`, exactly as the
  [lesson verifier](../../content/learn/what-is-an-ash-program/checks/verify.sh)
  asserts. This model agrees with the pinned specification's
  [entry contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  and the pinned tool's
  [successful-output contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output).
- **Predict, run, and explain — retain.** In
  [*Expressions calculate values*](../../content/learn/what-is-an-ash-program/README.md#expressions-calculate-values),
  `02-addition.ash` asks for the value before the run, while
  `03-precedence.ash` and `04-grouping.ash` pair predictions with explicit
  calculations and observed `7 : Int` and `9 : Int`. In
  [*Giving a calculation a name*](../../content/learn/what-is-an-ash-program/README.md#giving-a-calculation-a-name),
  `05-function-call.ash` and `06-composition.ash` reuse the smaller-expression
  model to calculate outward before reporting `42 : Int`.
  `01-literal.ash` establishes the first observation before asking for
  predictions. The verifier asserts every displayed result, and the
  sequence follows pinned
  [precedence](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#precedence-and-associativity),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  and
  [primitive-operation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#primitive-operations)
  behavior.
- **Vocabulary at the expression `double (increment 20)` — retain.** The
  passage first explains the observable relationship—the result of `increment`
  becomes the input to `double`—and then names that connection *function
  composition*. The
  [beginning-path record](../project/beginning-learning-path.md#programs-and-calculations)
  includes composition in lesson 1's verified scope. Lesson 5's description of
  the same source as a nested expression identifies its syntactic shape; it
  does not conflict with the project-level vocabulary. Removing the term would
  update that recorded scope, and the audit found no reader evidence that
  justifies such a change.
- **Negative boundary — retain.**
  [*Where does evaluation begin?*](../../content/learn/what-is-an-ash-program/README.md#where-does-evaluation-begin)
  presents a `Unit -> Int` definition under `answer` instead of `main`; the
  reader runs `07-missing-main.ash`, sees `entry.missing-main`, and explains why
  an otherwise valid definition is not the entry. The verifier also requires
  the causal text about no local `main` and status `1`, matching the pinned
  [program rule](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  and tool
  [failure contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures).
- **Exercise and assistant prompts — retain.**
  [*Exercise: square, then double*](../../content/learn/what-is-an-ash-program/README.md#exercise-square-then-double)
  requires only signatures, one-input definitions, calls, multiplication, and
  inside-out prediction already introduced in this lesson; its expected
  reasoning is `square 3` to `9`, then `double 9` to `18 : Int`. The grouping
  prompt asks the learner to defend a comparison, while the exercise prompt
  asks them to trace one expression at a time. Those are distinct uses of
  dialogue and both withhold a solution until after the learner reasons.
- **Handoff — retain.**
  [*The whole program*](../../content/learn/what-is-an-ash-program/README.md#the-whole-program)
  gathers definitions, expressions, calls, `main`, and the tool observation,
  then makes the one-file boundary explicit. That creates the next lesson's
  question—how one file can use a definition from another—without introducing
  module vocabulary early.

#### Lesson 2: *How can one source file use another?*

- **Prerequisites and opening — retain.** The opening names lesson 1's
  one-file definitions and `main` as its starting point, then establishes the
  new model before `ash main.ash`: two source files remain parts of one program
  and an import connects their modules. `arithmetic.ash` reuses the earlier
  `double` call before introducing `pub`; `01-main.ash` then introduces the
  import path, alias, and qualified call. This agrees with pinned
  [module paths](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#module-paths-and-identity)
  and
  [imports and namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces).
- **Positive and negative tool cycle — retain.** The unnamed opening passage
  directs `ash main.ash`, presents `42 : Int`, and then traces
  `Arithmetic.answer ()` through `double 21`. The
  [*What remains inside a module?*](../../content/learn/using-another-source-file/README.md#what-remains-inside-a-module)
  passage directs the run of `02-private-main.ash`, presents
  `resolve.unavailable-export`, and then explains the private-declaration
  cause. The shared
  [lesson method](../../content/learn/README.md#how-to-work-through-a-lesson)
  already asks the reader to predict every program before running it. As in the
  varied tool cycle retained for lesson 4, repeating that instruction locally
  would not solve a distinct reader problem: the positive trace and negative
  explanation provide the needed comparison, and the assistant prompt supports
  diagnosis after observation. The verifier establishes both exact outcomes.
  The private cause is governed by pinned
  [public and private declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations).
- **Exercise — retain.**
  [*Exercise: move `square`*](../../content/learn/using-another-source-file/README.md#exercise-move-square)
  depends on lesson 1's `square`, signatures, calls, prediction, and `main`,
  plus this lesson's two-file layout, `pub`, import alias, and qualified call.
  The learner must predict `36 : Int`, then remove `pub` and explain the
  changed observation as an access boundary between the two modules.
- **Assistant prompt — retain.** The prompt in
  [*What remains inside a module?*](../../content/learn/using-another-source-file/README.md#what-remains-inside-a-module)
  adds a distinct cross-file diagnostic task: locate the import, alias, public
  declaration, and qualified occurrence before considering a change. The
  lesson remains complete without it, and the prompt uses only names already
  introduced.
- **Handoff — retain.**
  [*One program, two files*](../../content/learn/using-another-source-file/README.md#one-program-two-files)
  gathers the module access model, then points out that every function used so
  far still receives one input. This directly creates the question answered by
  lesson 3 rather than adding another module feature.

#### Lesson 3: *How can a function use more than one input?*

- **Prerequisites and opening — retain.** The opening recalls lesson 1's
  one-input `double`, lesson 2's `Arithmetic.answer ()`, and the established
  function-call model. Before the first run it establishes that each call
  supplies one input and may leave a function waiting for another. That is the
  working model needed to read `Int -> Int -> Int`, whose arrows are
  [right-associative](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#precedence-and-associativity),
  and application remains unary under pinned
  [function typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application).
- **Predict, run, and explain — retain.**
  [*Supplying two inputs*](../../content/learn/using-more-than-one-input/README.md#supplying-two-inputs)
  calculates `add 20 22` before the `42 : Int` run;
  [*Pausing after the first input*](../../content/learn/using-more-than-one-input/README.md#pausing-after-the-first-input)
  asks what is missing before observing `<function> : Int -> Int`, then
  `03-reuse-a-partial-call.ash` traces the remembered input before its run.
  [*Each input keeps its type*](../../content/learn/using-more-than-one-input/README.md#each-input-keeps-its-type)
  uses `04-wrong-input.ash` to explain `type.argument` from the remaining
  `Int -> Int` domain. The verifier asserts all four observations, including
  `expected Int` and status `1`; the function rendering is part of the pinned
  tool's
  [successful-output contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output).
- **Exercise — retain.**
  [*Exercise: multiply three numbers*](../../content/learn/using-more-than-one-input/README.md#exercise-multiply-three-numbers)
  uses only multiplication, signatures, parameters, calls, and the newly
  introduced right-associated-arrow model. The learner must account for three
  inputs, predict both an integer result and the type left after two inputs,
  then complete and run the call.
- **No assistant prompt — retain.** The chapter supplies the two-step model,
  concrete arrow regrouping, a rendered function value, a reusable partial
  call, and a type rejection. An assistant would not add a distinct task to
  the existing predict-and-explain sequence, and the exercise remains
  self-contained.
- **Handoff — retain.**
  [*From inputs to decisions*](../../content/learn/using-more-than-one-input/README.md#from-inputs-to-decisions)
  gathers complete and partial calls, then contrasts every calculation's fixed
  route with the need to inspect a value. That creates lesson 4's decision
  question using the expression model already in place.

#### Lesson 4: *How can a program choose a result?*

- **Prerequisites and opening — retain.** The opening depends on the earlier
  expression-tracing model and lesson 3's multi-input calls. Before the first
  run, it establishes a two-part decision: an expression produces `true` or
  `false`, and a `match` supplies one result expression for each value. The
  later `choose : Bool -> Int -> Int -> Int` therefore adds no new call shape.
- **Question and choice observations — retain.**
  [*Asking a question*](../../content/learn/choosing-a-result/README.md#asking-a-question)
  predicts `20 + 22 == 42` before observing `true : Bool`, then asks for a
  changed prediction and run with `41`.
  [*Describing both choices*](../../content/learn/choosing-a-result/README.md#describing-both-choices)
  traces `02-choose.ash` for `true` and reasons about the `false` alternative;
  [*Calculating the condition*](../../content/learn/choosing-a-result/README.md#calculating-the-condition)
  traces the earlier arithmetic expression into `03-calculated-choice.ash`.
  Challenging the lack of a repeated run command does not justify revision:
  the equality run establishes the observation, the two traces explain the new
  match behavior, the exercise runs both routes, and the verifier asserts all
  three canonical results. This varied sequence avoids turning the tool cycle
  into a repeated prose template. The calculations agree with pinned
  [primitive operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#primitive-operations)
  and
  [match evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches).
- **Negative boundary — retain.**
  [*Accounting for every value*](../../content/learn/choosing-a-result/README.md#accounting-for-every-value)
  starts from the newly established two-value `Bool` model, removes the
  `false` arm in `04-missing-choice.ash`, and explains
  `coverage.non-exhaustive` as a pre-execution rejection. The verifier asserts
  that reason, its stable causal text, and status `1`, matching pinned
  [match coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage).
- **Exercise and assistant prompt — retain.**
  [*Exercise: keep or double*](../../content/learn/choosing-a-result/README.md#exercise-keep-or-double)
  requires only lesson 3's two-input signatures and calls plus this lesson's
  `Bool`, equality, match arms, and common `Int` result. The learner predicts
  both direct Boolean routes and then replaces the condition with a calculated
  equality. The assistant prompt has distinct value at the negative boundary:
  it asks the learner to identify and justify the missing value before seeking
  feedback, without teaching diagnostic presentation as a contract.
- **Handoff — retain.**
  [*A complete decision*](../../content/learn/choosing-a-result/README.md#a-complete-decision)
  gathers Boolean production, exhaustive matching, and the selected result,
  then identifies the cost of repeating a growing expression when one arm has
  several steps. This creates lesson 5's local-name question.

#### Lesson 5: *How can a calculation name an intermediate value?*

- **Prerequisites and opening — retain.** The opening returns to lesson 1's
  exact `double (increment 20)` expression and the smaller-expression model.
  Before any run, it establishes a block as one expression that can name the
  ordered route to its one result. This model follows pinned block
  [syntax](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and left-to-right
  [local scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#local-scope).
- **Positive observations — retain.**
  [*Naming one result*](../../content/learn/naming-intermediate-values/README.md#naming-one-result)
  explains the `01-one-name.ash` binding and final expression, traces each, and
  then runs the program for `42 : Int`.
  [*Letting one step use another*](../../content/learn/naming-intermediate-values/README.md#letting-one-step-use-another)
  makes the dependency in `02-several-names.ash` explicit, predicts `21` then
  `42`, and asks the run to check the chain. The verifier asserts both results,
  and pinned
  [block typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks)
  and
  [binding evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings)
  support the causal account.
- **Negative boundary — retain.**
  [*Names appear in order*](../../content/learn/naming-intermediate-values/README.md#names-appear-in-order)
  changes `03-forward-reference.ash` so `answer` depends on a later local,
  explains why `later` is not in scope, observes `resolve.unknown-name`, and
  asks the learner to reorder and rerun. The verifier asserts the stable reason,
  `not in scope`, and status `1`. The existing negative is the smallest account
  of ordinary sequential `let`; the pinned
  [local-scope rule](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#local-scope)
  also keeps the later recursion topic intentionally out of this lesson.
- **Exercise prerequisite — revise locally.**
  [*Exercise: expose the hidden steps*](../../content/learn/naming-intermediate-values/README.md#exercise-expose-the-hidden-steps)
  asks the learner to name the intermediate results and preserve `42 : Int`,
  using only lesson 1's `increment`, `double`, and inside-out trace plus this
  lesson's sequential bindings. However, “Keep the existing
  `increment` and `double` definitions” has no local antecedent: all three
  canonical programs in this lesson define only `main`. Challenging the issue
  against lesson 1 confirms that the needed definitions already exist there,
  so the smallest later fix is an explicit pointer back to that earlier
  program, not a new example or structural change.
- **No assistant prompt — retain.** The chapter already makes the intermediate
  values visible in prose calculations, tests the ordering boundary, and gives
  a bounded rewrite exercise. After the exercise prerequisite is clarified,
  dialogue would not add a distinct task and the lesson remains independently
  usable.
- **Handoff — retain.**
  [*A calculation with visible steps*](../../content/learn/naming-intermediate-values/README.md#a-calculation-with-visible-steps)
  gathers blocks, sequential local names, and the final result, then contrasts
  one name for one value with several values that belong to one step. That
  directly creates lesson 6's question of how several values travel together.

### Task 1: Reconfirm the baseline and course contract

**Files:**

- Read: `README.md`
- Read: `AGENTS.md`
- Read: `docs/project/roadmap.md`
- Read: `docs/project/workflow.md`
- Read: `docs/project/beginning-learning-path.md`
- Read: `content/learn/README.md`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Confirm repository and target state

Run:

```bash
git status --short --branch
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
  rev-parse HEAD
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
  status --short
```

Expected: the ash-doc worktree is clean on `docs/beginning-path-review`; the
Ash checkout reports `dca16039923475c48025c5f17beadeb6bcb6a4bf` and no
changes.

#### Step 2: Reconstruct the course contract

Read the files listed above. Write a short baseline entry in the audit ledger
that names the intended learner outcome, the eleven-lesson order, the excluded
topics, and the whole-path review boundary.

#### Step 3: Run the complete executable baseline

Run:

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: eleven lesson summaries followed by:

```text
Verified 11 learning lesson(s) at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

Record the exact result in the audit ledger. Stop and use
@superpowers:systematic-debugging if the baseline fails.

#### Step 4: Commit the baseline record

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: record beginning path baseline"
```

### Task 2: Audit programs and calculations in sequence

**Files:**

- Read: `content/learn/what-is-an-ash-program/README.md`
- Read: `content/learn/using-another-source-file/README.md`
- Read: `content/learn/using-more-than-one-input/README.md`
- Read: `content/learn/choosing-a-result/README.md`
- Read: `content/learn/naming-intermediate-values/README.md`
- Inspect: `content/learn/{what-is-an-ash-program,using-another-source-file,using-more-than-one-input,choosing-a-result,naming-intermediate-values}/src/*.ash`
- Inspect: `content/learn/{what-is-an-ash-program,using-another-source-file,using-more-than-one-input,choosing-a-result,naming-intermediate-values}/checks/verify.sh`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Read lessons 1 through 5 without editing

Read every lesson aloud and inspect each canonical program and verifier beside
the prose that uses it. Follow the reader from expressions and `main` through
modules, chained inputs, Boolean choice, and sequential local bindings.

#### Step 2: Trace course dependencies

For each lesson, record in the audit ledger:

- concepts and vocabulary assumed from earlier lessons;
- the new model established before the first command;
- each predict-run-explain opportunity;
- exercise prerequisites and expected reasoning;
- whether an assistant prompt adds distinct value; and
- whether the ending creates the next lesson's question.

Use exact headings or quoted identifiers to locate evidence. Keep any quotation
brief; the lesson path and passage description should do most of the work.

#### Step 3: Challenge the first findings

For each proposed revision, look for a smaller explanation already supplied by
earlier Ash semantics, a negative example that already establishes the
boundary, or an interaction with a later lesson that justifies retaining the
text. Update the finding's disposition rather than editing lesson prose.

#### Step 4: Commit the first course-part audit

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: audit beginning calculations"
```

### Task 3: Audit data and structure in sequence

**Files:**

- Read: `content/learn/values-travel-together/README.md`
- Read: `content/learn/defining-data/README.md`
- Read: `content/learn/handling-data-forms/README.md`
- Read: `content/learn/following-recursive-data/README.md`
- Inspect: `content/learn/{values-travel-together,defining-data,handling-data-forms,following-recursive-data}/src/*.ash`
- Inspect: `content/learn/{values-travel-together,defining-data,handling-data-forms,following-recursive-data}/checks/verify.sh`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Read lessons 6 through 9 without editing

Read every lesson aloud and inspect its source and check evidence. Follow the
reader from tuples through nominal data, constructor-shaped functions,
coverage, and structural recursion.

#### Step 2: Trace data-design dependencies

Apply the same dependency, vocabulary, prediction, exercise, prompt, and
handoff review used in Task 2. Pay particular attention to whether patterns are
introduced only after construction, whether coverage follows the complete data
definition, and whether recursive functions are derived from recursive data
rather than presented as an isolated mechanism.

#### Step 3: Challenge and classify findings

Test every candidate against earlier lessons and the smallest causal account.
Record a disposition for each finding. Do not edit lesson prose during the
audit pass.

#### Step 4: Commit the second course-part audit

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: audit beginning data design"
```

### Task 4: Audit functional abstraction and the final outcome

**Files:**

- Read: `content/learn/functions-as-values/README.md`
- Read: `content/learn/definitions-for-many-types/README.md`
- Inspect: `content/learn/functions-as-values/src/*.ash`
- Inspect: `content/learn/functions-as-values/checks/verify.sh`
- Inspect: `content/learn/definitions-for-many-types/src/*.ash`
- Inspect: `content/learn/definitions-for-many-types/checks/verify.sh`
- Read: `content/learn/README.md`
- Read: `docs/project/beginning-learning-path.md`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Read lessons 10 and 11 without editing

Read both lessons aloud and inspect their executable evidence. Trace the move
from functions as values to definitions whose behavior does not depend on one
particular element type.

#### Step 2: Test the final reader model

Trace every idea in the final multi-file `List<A>` and `map` program back to
the lesson that introduced it. Confirm that a reader can predict the
transformation, follow the recursive data and function together, explain the
function value, identify the type parameters, and follow the qualified module
use without relying on excluded topics.

#### Step 3: Review the course frame

Compare `content/learn/README.md` with the actual study method and reading
order. Confirm that assistant guidance remains optional and that the final
lesson gathers the intended outcome rather than administering project state.
Record all evidence and dispositions in the audit ledger.

#### Step 4: Decide whether structural change is warranted

Consider splitting or reordering only if the ledger shows a prerequisite cycle
or a transition that local prose cannot repair. If it does, stop and present
that evidence for project approval before changing navigation or directories.
Otherwise record that local revisions are sufficient.

#### Step 5: Commit the final course-part audit

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: audit beginning abstraction"
```

### Task 5: Verify governing claims and revise accepted findings

**Files:**

- Modify as evidence requires: `content/learn/README.md`
- Modify as evidence requires: `content/learn/*/README.md`
- Modify only if an observable claim changes: `content/learn/*/src/*.ash`
- Modify only if source or observation changes: `content/learn/*/checks/verify.sh`
- Read: `/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/spec/README.md`
- Read as selected by each claim: `/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/spec/{lexical-structure,syntax,name-resolution,static-semantics,elaboration,dynamic-semantics}.md`
- Read for tool claims: `/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/docs/tools/ash.md`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Select accepted revisions

Review every ledger item marked `revise locally` or `verify against a governing
source`. Reject edits based only on preference. Group accepted findings by one
causal reader problem, not merely by file.

#### Step 2: Verify claims before drafting

Read the pinned specification overview, then only the chapters governing each
accepted semantic finding. Read the pinned tool guide and relevant tests or
implementation only for command, output, failure, or diagnostic findings.
Add the governing section to the ledger item before changing prose or code.

#### Step 3: Make the smallest revision for one finding group

Use @writing-ash-documentation. Preserve the lesson's conceptual arc, source
markers, canonical program agreement, and transition into the next lesson.
Do not introduce a new language topic or project administration into rendered
lesson prose.

#### Step 4: Verify the affected lesson locally

For each changed lesson, run:

```bash
bash content/learn/<lesson>/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: a canonical-source summary for that lesson at the exact pinned
commit. If only the learning index changes, inspect its links instead.

#### Step 5: Read and commit the finding group

Read every changed file as source, then run:

```bash
git diff --check
git diff -- content/learn
```

Stage only that finding group and commit with a message naming the reader
problem, for example:

```bash
git add content/learn/<exact-files>
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: clarify <reader boundary>"
```

Repeat Steps 3 through 5 for each independent finding group. Stop and use
@superpowers:systematic-debugging for any unexpected executable failure.

### Task 6: Verify the complete revised path

**Files:**

- Read: every file changed from `main`
- Verify: `content/learn/README.md`
- Verify: `content/learn/*/README.md`
- Verify: `content/learn/checks/*.sh`
- Verify: `content/learn/*/checks/verify.sh`
- Verify: `.agents/skills/writing-ash-documentation/`

#### Step 1: Run executable and shell verification

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/learn/checks/*.sh content/learn/*/checks/verify.sh
```

Expected: all eleven lessons pass at the exact pinned commit and Bash reports
no syntax errors.

#### Step 2: Run documentation checks

```bash
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
```

Expected: Markdown lint reports zero errors and the skill validator reports a
valid skill.

#### Step 3: Review links, status, and changed source

Inspect every changed relative link at its source and confirm its target
exists. Then run:

```bash
git diff --check main...HEAD
git status --short --branch
git diff --stat main...HEAD
git diff main...HEAD
```

Expected: no whitespace errors, only files authorized by accepted findings and
the active plans are changed, and every diff hunk has been read.

#### Step 4: Record final verification

Add the exact commands and results to the audit ledger. Commit the completed
audit evidence with any final prose corrections:

```bash
git add docs/plans/2026-08-27-beginning-path-review.md content/learn
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: verify beginning reader journey"
```

### Task 7: Select the next outcome and close the review

**Files:**

- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-27-beginning-path-review-design.md`
- Delete: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Propose the next complete outcome

Use the completed audit evidence and the roadmap's later decisions to compare
at least two bounded next outcomes. Do not select a new language topic,
renderer, coverage mechanism, or publication design without its own concrete
need. Present the recommendation for project approval before changing the
roadmap.

#### Step 2: Record closure after approval

Replace the roadmap's current edition state and verified-increment account
with the completed whole-path review. Replace `Next complete increment` with
the approved next outcome. Remove links to the review plans.

#### Step 3: Remove temporary plans

Delete both review plan files. Git history retains their design, audit, and
execution evidence.

#### Step 4: Run final verification

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/learn/checks/*.sh content/learn/*/checks/verify.sh
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
git diff --check main...HEAD
git status --short --branch
git log --format='%h %G? %s' main..HEAD
```

Expected: eleven lessons pass at the pinned commit; shell, Markdown, skill, and
whitespace checks pass; only intended review changes remain; both plan files
are absent; and each branch commit reports signature status `N`.

#### Step 5: Commit closure

```bash
git add docs/project/roadmap.md \
  docs/plans/2026-08-27-beginning-path-review-design.md \
  docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: close beginning path review"
```

Do not merge, push, or remove the worktree during plan execution. Use
@superpowers:finishing-a-development-branch after all verification passes to
present integration choices.
