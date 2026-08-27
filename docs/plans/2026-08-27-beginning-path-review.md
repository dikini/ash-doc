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
