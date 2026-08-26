# Coherent Learning Core Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Turn `content/learn/` into a sequential, terminal-first learning core
whose lessons contain educational prose and optional grounded assistant prompts,
while project records retain target and verification administration.

**Architecture:** The repository root declares the Ash edition, the learn index
provides one-time setup and tutoring guidance, and lesson pages build one
cumulative reader model. Canonical sources, hidden source markers, and local
checks preserve executable evidence without appearing in lesson prose.

**Tech Stack:** Markdown, Bash, Git, `markdownlint-cli2`, the project writing
skill, and the pinned `ash` executable.

---

## Task 1: Separate teaching prose from project records

**Files:**

- Modify: `AGENTS.md:21-82`
- Modify: `docs/project/workflow.md:34-104`
- Modify: `.agents/skills/writing-ash-documentation/SKILL.md`
- Modify:
  `.agents/skills/writing-ash-documentation/tests/writing-scenarios.md`

### Step 1: Run structural checks that expose the current policy defect

Run:

```bash
rg -n 'Every published view must display' AGENTS.md
rg -n "its draft, verified|Ash milestone and resolved commit it targets" \
  docs/project/workflow.md
```

Expected: both commands find rules that require rendered per-lesson
administration.

### Step 2: Add scenarios for the corrected boundary

Add two cases to `writing-scenarios.md`:

1. A lesson request passes only when the response continues the learning
   sequence, begins with reader activity, and contains no rendered state,
   target, specification inventory, source link, or evidence report.
2. An assistant-supported exercise passes only when it retains a complete
   no-agent path and gives a short product-neutral prompt grounded in the
   lesson and observed `ash` output. The assistant asks one question at a time
   and initially withholds a finished solution.

### Step 3: Correct `AGENTS.md`

- Replace the rule that every published view displays the target. The edition
  root declares it once; learning pages inherit it.
- Keep exact target reconstruction mandatory during planning and verification.
- Define `content/learn/` as a sequential self-learning work.
- Exclude project state, source inventories, evidence administration, and
  specification navigation from rendered lessons.
- Require a concrete consumer before adding page metadata. Put any future
  page-local metadata in YAML front matter.
- Permit hidden source-agreement markers without visible source links.

Do not weaken the pinned-language or executable-example requirements.

### Step 4: Correct `docs/project/workflow.md`

- Plan one complete lesson and locate it in the cumulative learning model.
- Retain a lesson directory as an evidence boundary.
- Replace the rendered README field list with explicit information ownership.
- Assign target, sources, exclusions, state, and evidence to project records,
  canonical sources, and checks.
- Define lesson README files as reader-facing chapters.
- Forbid rendered administrative headers and source inventories.
- Define optional YAML front matter as non-rendered and consumer-driven.
- Add continuity with earlier and later lessons to close-out review.

### Step 5: Rewrite the project writing skill

Keep the direct voice and executable-source rules. Add:

- a distinction between project prose and learning prose;
- a cumulative reader model;
- openings that begin in the subject, not with objectives or metadata;
- the edit-predict-run-inspect-explain cycle;
- vocabulary after examples create a need for it;
- intermediate calculation steps where they help prediction;
- optional grounded assistant prompts and a complete no-agent path; and
- a review question that rejects paragraphs serving project administration.

Keep source adaptation and license records in project work, not rendered
lesson content.

### Step 6: Validate the policy and skill

Run:

```bash
if rg -n 'Every published view must display' AGENTS.md; then exit 1; fi
if rg -n "its draft, verified|Ash milestone and resolved commit it targets" \
  docs/project/workflow.md; then exit 1; fi
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
markdownlint-cli2 AGENTS.md docs/project/workflow.md \
  .agents/skills/writing-ash-documentation/SKILL.md \
  .agents/skills/writing-ash-documentation/tests/writing-scenarios.md
git diff --check
```

Expected: the searches find nothing; the skill is valid; Markdown reports zero
errors; Git reports no whitespace errors.

### Step 7: Commit unsigned

```bash
git add AGENTS.md docs/project/workflow.md \
  .agents/skills/writing-ash-documentation/SKILL.md \
  .agents/skills/writing-ash-documentation/tests/writing-scenarios.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: separate lessons from project records"
```

Confirm the commit has no `gpgsig` or `sshsig` header.

## Task 2: Establish the terminal-first learning front door

**Files:**

- Modify: `README.md:30-57`
- Modify: `content/learn/README.md`

### Step 1: Expose the current routing and setup gap

Run:

```bash
rg -n 'Start with.*What is an Ash program' README.md
if rg -n 'cargo build --locked|learning assistant' \
  content/learn/README.md; then exit 1; fi
```

Expected: the root skips the learn front door, and the front door lacks setup
and assistant guidance.

### Step 2: Route readers through the learning core

Change the root “Learn Ash” section to point first to
`content/learn/README.md`. Keep milestone, commit, authority, and specification
navigation at the repository root.

### Step 3: Write the learn front door

Give `content/learn/README.md` these sections:

- `# Learn Ash`: explain that the chapters form a sequence and that readers
  should work with the programs.
- `## Before you begin`: require a text editor, terminal, and the Ash source
  checkout selected by the root. Show `cargo build --locked` and a temporary
  `PATH` setting for `target/debug/ash`.
- `## How to work through a lesson`: define edit, predict, run, inspect, and
  explain.
- `## Learning with an assistant`: provide the standing tutor instruction.
- `## Contents`: list the first lesson as item 1.

Use this tutor instruction:

> Use this lesson, the repository, and the output from `ash` as evidence. Ask
> one question at a time. Help me compare my prediction with the result. Use
> only ideas introduced so far unless I ask to look ahead. Do not give me a
> finished exercise solution before helping me reason about it.

Say that the instruction works with a chat or coding agent. Running `ash`
remains the test of the program.

### Step 4: Validate navigation and prose

Run:

```bash
rg -n 'cargo build --locked' content/learn/README.md
rg -n 'Ask one question at a time' content/learn/README.md
rg -n 'content/learn/README.md' README.md
markdownlint-cli2 README.md content/learn/README.md
git diff --check
```

Expected: each search finds its line; Markdown and Git report no errors.

### Step 5: Commit unsigned

```bash
git add README.md content/learn/README.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: establish learning front door"
```

Confirm the commit has no signature header.

## Task 3: Rewrite the first lesson as educational prose

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

### Step 1: Expose rendered administration in the current lesson

Run:

```bash
rg -n \
  'State:|Ash milestone|Resolved commit|checked source|entry module|## Sources' \
  content/learn/what-is-an-ash-program/README.md
```

Expected: the search finds project and specification administration.

### Step 2: Rewrite the opening and first observation

Remove the metadata block and tool-build setup. Begin with the reader creating
`program.ash`, running the literal program, and observing `42 : Int`. Then name
only the parts the observation needs:

- the right side of `=` is an expression and produces a value;
- `42` is an integer value and `Int` names its type;
- `main` is where this program begins; and
- `main ()` needs no information before it produces an `Int`.

Do not introduce modules, entry files, local declarations, output streams, or
specification terminology. Keep the hidden marker for `src/01-literal.ash`.

### Step 3: Teach expressions through predictions and calculations

Keep the addition, precedence, and grouping programs and their hidden markers.
Remove visible `src` links. Tell the reader when to replace `program.ash`, ask
for a prediction before each result, and show these reductions:

```text
1 + 2 * 3
1 + 6
7
```

```text
(1 + 2) * 3
3 * 3
9
```

Add this optional prompt after the contrast:

> **With a learning assistant:** Share both calculations and explain why they
> differ. Ask the assistant to question your explanation one step at a time
> without giving its own explanation first.

### Step 4: Introduce definitions, calls, and composition when needed

Keep the `increment` and `double` programs unchanged. Introduce `increment` as
a way to name a calculation. Name signature, input, parameter, argument, and
call only as the reader uses each part. Show the composed calculation:

```text
double (increment 20)
double 21
42
```

Define composition as using one function's result as another function's input.

### Step 5: Explain `main` through the rejected contrast

Present the missing-main program as the answer to “Why have all the programs
used the name `main`?” Ask the reader to run it. Explain that Ash needs `main`
to know where this program begins. Show the stable first diagnostic line only;
do not discuss entry modules or diagnostic contracts.

### Step 6: End with practice and the next question

Restore the composed program and retain the `square` exercise. Ask the reader
to predict, implement, run, and explain `18 : Int`. Add the second prompt:

> **With a learning assistant:** Show the assistant your program and prediction.
> Ask it to point to one expression at a time and ask what value that expression
> produces. Ask for a complete solution only after you have explained your own.

End by answering “what is an Ash program?” with established terms, then open
the question of using more than one source file. Remove the sources section.

### Step 7: Run focused verification

Run:

```bash
content/learn/what-is-an-ash-program/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
if rg -n \
  'State:|Ash milestone|Resolved commit|checked source|entry module|## Sources' \
  content/learn/what-is-an-ash-program/README.md; then exit 1; fi
test "$(rg -c '^> \*\*With a learning assistant:\*\*' \
  content/learn/what-is-an-ash-program/README.md)" -le 2
markdownlint-cli2 content/learn/what-is-an-ash-program/README.md
git diff --check
```

Expected: seven sources and displayed blocks verify; the administration search
finds nothing; at most two assistant prompts exist; Markdown and Git pass.

### Step 8: Commit unsigned

```bash
git add content/learn/what-is-an-ash-program/README.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: rewrite first Ash lesson"
```

Confirm the commit has no signature header.

## Task 4: Review, retire plans, and preserve the branch

**Files:**

- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-26-learning-core-design.md`
- Delete: `docs/plans/2026-08-26-learning-core.md`

### Step 1: Request read-only branch review

Review `2ad1583..HEAD` for:

- root, learn, lesson, and project-record ownership;
- continuity and educational prose against the approved design;
- complete use without an assistant and grounded optional prompts;
- absence of rendered lesson administration;
- unchanged canonical programs and exact source agreement;
- pinned semantic and tool correctness; and
- unsigned, unmerged branch constraints.

Fix every Critical or Important issue in a focused unsigned commit. Request a
follow-up review after fixes.

### Step 2: Update the roadmap

Record that the first lesson has been revised under the coherent-core workflow.
Keep the next reader question unchanged. Remove active-plan links.

### Step 3: Delete the temporary plans

Delete both plan files with `apply_patch`. Git history retains the approved
design and execution sequence.

### Step 4: Run the full completion gate

Run:

- the seven-program and displayed-source verifier;
- Markdown lint for every tracked Markdown file;
- writing-skill validation;
- local Markdown-link validation;
- `bash -n` for the verifier;
- `git diff --check`; and
- branch-boundary checks.

Confirm that every `main..HEAD` commit is unsigned, `main` and `origin/main`
remain at `23b3aad6a3d5d86a10d9cab0427da7cd7cf100a0`, `.worktrees/` remains
ignored, the feature head is not merged, and the feature worktree remains
registered.

### Step 5: Commit cleanup unsigned

```bash
git add docs/project/roadmap.md \
  docs/plans/2026-08-26-learning-core-design.md \
  docs/plans/2026-08-26-learning-core.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: complete learning core revision"
```

Run the completion gate again after the commit.

### Step 6: Keep the branch and worktree

Keep `content/what-is-an-ash-program` and its current worktree as-is. Do not
merge, push, or remove the worktree.
