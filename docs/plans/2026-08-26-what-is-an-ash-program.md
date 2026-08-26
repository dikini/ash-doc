# What Is an Ash Program? Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Publish and verify the first Ash learning unit, which grows one
single-file program from a literal result to nested function calls.

**Architecture:** The unit owns its tutorial, seven canonical Ash programs, and
one Bash verifier. The verifier builds Ash from a clean checkout at the pinned
commit, checks program observations, and compares displayed blocks with their
canonical sources.

**Tech Stack:** Markdown, Ash, Bash, Git, Cargo, `markdownlint-cli2`

**Required project skill:** Use @writing-ash-documentation for prose and
@test-driven-development for the executable verification boundary.

---

## Task 1: Write the failing unit verifier

**Files:**

- Create: `content/learn/what-is-an-ash-program/checks/verify.sh`

### Step 1: Create the unit and check directories

Run:

```bash
mkdir -p content/learn/what-is-an-ash-program/checks
```

### Step 2: Write the verifier before the examples

Write an executable Bash script that:

- requires one argument naming a clean `ash-lang` checkout;
- requires its `HEAD` to equal
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`;
- builds that checkout with `cargo build --quiet --locked` and a temporary
  `CARGO_TARGET_DIR`;
- checks the exact status, standard output, and standard error of every source;
- checks the missing-`main` reason and causal label; and
- extracts each marked `ash` fence from the unit README and compares it with
  the named canonical source.

The accepted observations are:

| Source | Standard output |
| --- | --- |
| `src/01-literal.ash` | `42 : Int` |
| `src/02-addition.ash` | `42 : Int` |
| `src/03-precedence.ash` | `7 : Int` |
| `src/04-grouping.ash` | `9 : Int` |
| `src/05-function-call.ash` | `42 : Int` |
| `src/06-composition.ash` | `42 : Int` |

`src/07-missing-main.ash` exits with status `1`, writes no standard output,
starts standard error with `entry.missing-main`, and identifies the entry module
as declaring no local `main`.

### Step 3: Make the verifier executable

Run:

```bash
chmod +x content/learn/what-is-an-ash-program/checks/verify.sh
bash -n content/learn/what-is-an-ash-program/checks/verify.sh
```

Expected: `bash -n` exits zero.

### Step 4: Verify the red state

Create a detached, clean worktree for the pinned `ash-lang` commit. Run:

```bash
content/learn/what-is-an-ash-program/checks/verify.sh \
  /path/to/pinned/ash-lang
```

Expected: FAIL because `src/01-literal.ash` does not exist.

### Step 5: Commit the failing verifier

```bash
git add content/learn/what-is-an-ash-program/checks/verify.sh
git commit -m "test: define first unit observations"
```

## Task 2: Add the canonical Ash programs

**Files:**

- Create: `content/learn/what-is-an-ash-program/src/01-literal.ash`
- Create: `content/learn/what-is-an-ash-program/src/02-addition.ash`
- Create: `content/learn/what-is-an-ash-program/src/03-precedence.ash`
- Create: `content/learn/what-is-an-ash-program/src/04-grouping.ash`
- Create: `content/learn/what-is-an-ash-program/src/05-function-call.ash`
- Create: `content/learn/what-is-an-ash-program/src/06-composition.ash`
- Create: `content/learn/what-is-an-ash-program/src/07-missing-main.ash`

### Step 1: Write the literal and expression programs

Use these complete sources:

```text
main : Unit -> Int
main () = 42
```

```text
main : Unit -> Int
main () = 40 + 2
```

```text
main : Unit -> Int
main () = 1 + 2 * 3
```

```text
main : Unit -> Int
main () = (1 + 2) * 3
```

### Step 2: Write the function-call program

Use:

```text
increment : Int -> Int
increment number = number + 1

main : Unit -> Int
main () = increment 41
```

### Step 3: Write the composition program

Use:

```text
increment : Int -> Int
increment number = number + 1

double : Int -> Int
double number = number * 2

main : Unit -> Int
main () = double (increment 20)
```

### Step 4: Write the rejected entry source

Use:

```text
answer : Unit -> Int
answer () = 42
```

### Step 5: Run the programs directly

Build the pinned checkout and run all seven sources with its `ash` executable.

Expected: the six accepted outputs match the table in Task 1. The rejected
source exits with status `1` and reports `entry.missing-main`.

### Step 6: Confirm the verifier advances to the next missing boundary

Run the verifier again.

Expected: FAIL because the unit `README.md` and its marked blocks do not exist.

### Step 7: Commit the canonical programs

```bash
git add content/learn/what-is-an-ash-program/src
git commit -m "examples: add first Ash programs"
```

## Task 3: Write the tutorial and make the verifier green

**Files:**

- Create: `content/learn/README.md`
- Create: `content/learn/what-is-an-ash-program/README.md`
- Modify: `content/README.md`

### Step 1: Write the unit metadata and opening

Record the verified state, `modular-ash` milestone and resolved commit, reader
question, prerequisites, outcomes, governing pinned sources, observations,
limitations, and lack of external adaptation.

Open with the problem: this Ash milestone has no text or program I/O for a
traditional greeting, so the first program produces `42`. Explain that the
program returns a value; the `ash` tool displays the value and its type.

### Step 2: Present the smallest program

Before its fence, add this source marker:

```text
<!-- source: src/01-literal.ash -->
```

Show the complete source and the exact `ash src/01-literal.ash` observation.
Explain `.ash`, entry file, the one-module program, `main`, `Unit`, `()`, `Int`,
and `->` in plain language.

### Step 3: Grow the expressions

Present `02-addition.ash`, `03-precedence.ash`, and `04-grouping.ash` with their
matching hidden source markers. Ask the reader to predict each result before
showing it. Explain only addition, multiplication order, and parentheses.

### Step 4: Introduce functions and nested calls

Present `05-function-call.ash` and `06-composition.ash` with matching source
markers. Define signature, definition, parameter, argument, call, and
composition where each first appears. Explain that the inner call produces the
value passed to the outer call.

### Step 5: Establish the entry boundary

Present `07-missing-main.ash` with its marker. Show the stable reason
`entry.missing-main` and explain that valid function definitions do not make a
runnable entry program without a local `main`.

### Step 6: Add one exercise and close the unit

Ask the reader to define `square : Int -> Int`, make `main` evaluate
`double (square 3)`, predict `18 : Int`, and run it. State that the artifact is
one complete source file and that the exercise practices signatures,
definitions, multiplication, and nested calls.

Close with the established model and the next question: how can one Ash source
module use another?

### Step 7: Add family and root navigation

Create `content/learn/README.md` and link the unit from it. Link the learning
family and first unit from `content/README.md`.

### Step 8: Run the green verifier

Run:

```bash
content/learn/what-is-an-ash-program/checks/verify.sh \
  /path/to/pinned/ash-lang
```

Expected: PASS with all six accepted observations, one rejected observation,
and seven source-agreement checks.

### Step 9: Verify Markdown and commit

```bash
markdownlint-cli2 \
  content/README.md \
  content/learn/README.md \
  content/learn/what-is-an-ash-program/README.md
git diff --check
git add content
git commit -m "docs: teach the first Ash program"
```

## Task 4: Update project navigation and retire the plans

**Files:**

- Modify: `README.md`
- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-26-what-is-an-ash-program-design.md`
- Delete: `docs/plans/2026-08-26-what-is-an-ash-program.md`

### Step 1: Route readers to the first unit

Link the first unit from the root README. Keep the pinned specification links
as the precise source of truth, but make the learning unit the novice starting
point.

### Step 2: Advance the roadmap

Record the first unit as verified. Name evaluation of the next unit about using
another source module as the next complete planning increment. Record that the
first unit uses a local Bash verifier and that sharing it remains deferred until
a second unit demonstrates the same need.

### Step 3: Run the complete verification gate

Run the unit verifier, Markdown lint over every tracked Markdown file, writing
skill validation, local-link checking, `bash -n`, and `git diff --check`.

Expected: every check passes and the only planned leaf paths belong to the
complete first unit.

### Step 4: Remove the completed plans

Delete the design and implementation plan. Remove their active roadmap link.
Git history retains both records.

### Step 5: Verify the final tree and commit

Run the complete gate again. Confirm `docs/plans/` contains only `README.md` and
inspect `git status --short`.

```bash
git add README.md docs content
git commit -m "docs: complete first learning unit"
```
