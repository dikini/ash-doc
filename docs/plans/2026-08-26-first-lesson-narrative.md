# First Lesson Narrative Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Rewrite the first Ash lesson as a connected introduction,
exploration, and conclusion, and teach future writing agents the same
paragraph-level method.

**Architecture:** Keep the seven canonical programs and their verifier as the
executable boundary. Change the reader-facing narrative and the preferred
project writing skill, record the unresolved lesson-filename question in the
roadmap, then remove these temporary plans after review and verification.

**Tech Stack:** Markdown, Bash, Git, `ash`, `markdownlint-cli2`, the project
writing skill, and its pressure scenarios.

---

## Task 1: Test and extend the project writing skill

**Files:**

- Modify: `.agents/skills/writing-ash-documentation/SKILL.md`
- Modify:
  `.agents/skills/writing-ash-documentation/tests/writing-scenarios.md`

### Step 1: Run the narrative-opening scenario with the current skill

Give a fresh, read-only writing agent this request from the repository root:

> Use the required project writing skill. Draft an alternative opening and
> prose outline for the existing first lesson, from its introduction through
> the arithmetic and grouping examples. Keep all existing Ash programs. The
> page should help a novice answer “What is an Ash program?” Do not edit files.

Record whether the response:

- establishes a model of programs before directing the reader;
- connects each example to a question created by the previous one;
- shapes paragraphs as setup, evidence, and interpretation;
- avoids repeating edit-predict-run instructions; and
- gives the exploration a conclusion.

Expected baseline: the current skill's instruction to begin with an action,
example, or question permits an abrupt opening or a procedural outline. Record
the observed failure, not the expected wording, in `writing-scenarios.md`.

### Step 2: Add the pressure scenario and passing condition

Add `## Narrative lesson` to `writing-scenarios.md`. Preserve the request above
and require an introduction, connected exploration, conclusion, paragraph
continuity, varied sentence purposes, and headings only at conceptual turns.
State that the canonical examples and authority boundary remain unchanged.

### Step 3: Revise the skill with the minimum missing guidance

In `SKILL.md`:

- replace “Begin with an action, example, or question” with an opening that
  first gives the reader a reason and a usable model;
- require a conceptual arc of introduction, exploration, and conclusion for a
  learning chapter without requiring visible headings for each part;
- describe paragraphs as connected explanatory moves from setup through
  evidence to interpretation or the next question;
- make examples create the need for later examples and vocabulary;
- keep edit, predict, run, inspect, and explain as learner actions without
  repeating them as the prose skeleton;
- require varied sentence purpose, restrained questions, and headings only at
  conceptual turns; and
- add a read-aloud review for command rhythm, stock transitions, and filler.

Keep the project-prose, assistant, authority, and executable-evidence rules.
Keep the skill under 650 words.

### Step 4: Run the same scenario with the revised skill

Give a fresh read-only writing agent the request from Step 1. Require it to
read the revised skill. Compare the response with every narrative-lesson
passing condition and record the result in the scenario baseline section.

Expected: the response establishes the model before the first command, links
the examples causally, and avoids a repeated procedural rhythm.

### Step 5: Validate and commit unsigned

Run:

```bash
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
test "$(wc -w < \
  .agents/skills/writing-ash-documentation/SKILL.md)" -le 650
markdownlint-cli2 \
  .agents/skills/writing-ash-documentation/SKILL.md \
  .agents/skills/writing-ash-documentation/tests/writing-scenarios.md
git diff --check
```

Expected: skill validation succeeds, the word-count assertion succeeds,
Markdown reports zero errors, and Git reports no whitespace errors.

Commit:

```bash
git add .agents/skills/writing-ash-documentation
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: teach narrative lesson writing"
```

## Task 2: Rewrite the first lesson as a developing explanation

**Files:**

- Modify: `content/learn/what-is-an-ash-program/README.md`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/01-literal.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/02-addition.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/03-precedence.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/04-grouping.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/05-function-call.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/06-composition.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/src/07-missing-main.ash`
- Verify without modifying:
  `content/learn/what-is-an-ash-program/checks/verify.sh`

### Step 1: Capture the current prose failure

Run:

```bash
sed -n '1,45p' content/learn/what-is-an-ash-program/README.md
rg -n '^(Create|Before you run|Then ask|Now return|Replace|Check)' \
  content/learn/what-is-an-ash-program/README.md
rg -n '^Make a prediction' \
  content/learn/what-is-an-ash-program/README.md
```

Expected: the page opens with “Begin with a small question” and the search
finds repeated command-oriented paragraph openings.

### Step 2: Write the introduction and first observation

Open with two or three unheaded paragraphs. Explain that programs are often
described as instructions, while the first useful Ash model is a source file
whose definitions describe calculations. Running it asks Ash to evaluate the
calculation that begins at `main` and report a value.

Lead naturally into `src/01-literal.ash`. Invite the reader to save the program
as `program.ash` and run `ash program.ash`. After showing `42 : Int`, read the
program from whole to parts. Explain the right side of `=`, the signature,
`Unit`, `()`, `Int`, value, and type through the observed program.

Do not say that an Ash program itself is one expression. Do not introduce
entry-module or specification terms.

### Step 3: Connect literal, arithmetic, precedence, and grouping

Keep source blocks 02 through 04 unchanged. Let `40 + 2` show that a program
can calculate rather than merely contain its result. Let `1 + 2 * 3` raise the
question of smaller expressions and order. Let `(1 + 2) * 3` answer how the
reader changes that order.

Retain both calculation traces and one prediction for each contrast. Mention
running the file where observation matters, but do not restate the entire
learning cycle after every block.

### Step 4: Make functions continue the same story

Keep source blocks 05 and 06 unchanged. Introduce `increment` because naming a
calculation lets it be used from another expression. Explain signature,
parameter, argument, and call as the reader encounters them. Show how replacing
`number` with `41` accounts for the result.

Introduce `double` through the question of connecting named calculations.
Retain the trace from the inner call outward. Use “composition” only after the
trace has demonstrated one function's result becoming another's input.

### Step 5: Close the exploration and give practice

Keep source block 07 unchanged. Use the missing-`main` contrast after the
reader has seen several definitions, so the rejection explains why `main` has
been present throughout.

Retain the `square` exercise and up to two assistant prompts. Integrate each
prompt with the reasoning at hand and ground it in the learner's program,
prediction, and actual `ash` result.

End with two or three connected paragraphs that answer the title question:
the source file contains definitions, expressions calculate values, functions
name calculations, calls connect them, and `main` supplies the beginning for
the program run in this lesson. Open the next question about multiple files.

### Step 6: Verify and commit unsigned

Run:

```bash
content/learn/what-is-an-ash-program/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
markdownlint-cli2 content/learn/what-is-an-ash-program/README.md
git diff --check
git diff --quiet 0cfc6df -- \
  content/learn/what-is-an-ash-program/src \
  content/learn/what-is-an-ash-program/checks/verify.sh
```

Expected: seven sources and blocks verify at the pinned commit; Markdown and
Git pass; the final command confirms that canonical sources and the verifier
did not change during the prose revision.

Commit:

```bash
git add content/learn/what-is-an-ash-program/README.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: give first lesson a narrative"
```

## Task 3: Record the deferred lesson filename

**Files:**

- Modify: `docs/project/roadmap.md`

### Step 1: Add the publication-boundary question

Under `## Later decisions`, record whether lesson entry pages should remain
`README.md` for repository browsing or become `index.md` for a future website.
State that the decision waits for the first renderer or publication design.
Do not select a filename or renderer.

### Step 2: Check that no rename occurred

Run:

```bash
test -f content/learn/what-is-an-ash-program/README.md
test ! -e content/learn/what-is-an-ash-program/index.md
rg -n 'README\.md.*index\.md|index\.md.*README\.md' \
  docs/project/roadmap.md
markdownlint-cli2 docs/project/roadmap.md
git diff --check
```

Expected: the existing page remains, no `index.md` exists, the roadmap names
both options, and the prose checks pass.

### Step 3: Commit unsigned

```bash
git add docs/project/roadmap.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: defer lesson entry filename"
```

## Task 4: Review, verify, and retire temporary plans

**Files:**

- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-26-first-lesson-narrative-design.md`
- Delete: `docs/plans/2026-08-26-first-lesson-narrative.md`

### Step 1: Request read-only review

Review `0cfc6df..HEAD` for:

- semantic agreement with the pinned specification and tool behavior;
- an introduction, connected exploration, and conclusion;
- paragraph and sentence rhythm that does not expose a repeated procedure;
- vocabulary introduced where examples need it;
- unchanged canonical programs and source agreement;
- assistant prompts grounded in actual CLI evidence;
- correct deferral of the lesson-filename question; and
- absence of rendered project administration.

Fix each Critical or Important finding in a focused unsigned commit and request
follow-up review.

### Step 2: Update the roadmap and remove plans

Record the completed narrative revision in the verified increment. Preserve the
deferred `README.md` versus `index.md` question under later decisions. Remove
both temporary plan files; Git history retains them.

### Step 3: Run the final gate

Run:

```bash
content/learn/what-is-an-ash-program/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
bash -n content/learn/what-is-an-ash-program/checks/verify.sh
git diff --check
git status --short
git diff --quiet 0cfc6df -- \
  content/learn/what-is-an-ash-program/src \
  content/learn/what-is-an-ash-program/checks/verify.sh
```

Run the repository's existing local Markdown-link and branch-isolation checks.
Confirm the worktree is registered, `.worktrees/` is ignored, main remains at
`23b3aad6a3d5d86a10d9cab0427da7cd7cf100a0`, every commit after main is
unsigned, and the branch has not been merged or pushed.

Expected: all content, skill, Markdown, link, shell, Git, source-preservation,
and isolation checks pass with a clean worktree.

### Step 4: Commit the closeout unsigned

```bash
git add -A docs/plans docs/project/roadmap.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: complete first lesson narrative revision"
```

Do not merge, push, or remove the worktree.
