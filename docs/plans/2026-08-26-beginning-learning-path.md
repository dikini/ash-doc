# Beginning Learning Path Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Add a contributor-facing map of the beginning Ash learning path
without publishing absent lessons or turning the project roadmap into a
curriculum.

**Architecture:** A new project document owns the provisional sequence. The
project roadmap continues to own one next complete increment, and the learning
index continues to list only lessons that exist. Project indexes and workflow
text connect these three views and state their separate jobs.

**Tech Stack:** Markdown, `markdownlint-cli2`, Git, and the existing lesson and
skill validation scripts.

---

## Tasks

### Task 1: Add the provisional beginning path

**Files:**

- Create: `docs/project/beginning-learning-path.md`

#### Step 1: Confirm the planning view does not exist

Run:

```bash
test ! -e docs/project/beginning-learning-path.md
```

Expected: exit status 0.

#### Step 2: Write the planning view

Create the document described by
`docs/plans/2026-08-26-beginning-learning-path-design.md`. It must contain:

- the boundary between the project roadmap, provisional learning path, and
  published learning index;
- the three groups and eleven approved reader questions;
- **verified**, **next**, and **provisional** states;
- the pure multi-file beginner outcome;
- the explicit exclusion of interfaces, implementations, constraints, and
  ad-hoc polymorphism; and
- the condition under which lesson design may split, combine, or reorder later
  questions.

Do not add future entries to `content/learn/README.md` or create lesson
directories.

#### Step 3: Check the document

Run:

```bash
markdownlint-cli2 docs/project/beginning-learning-path.md
git diff --check
```

Expected: zero Markdown errors and exit status 0.

#### Step 4: Commit the planning view without signing

```bash
git add docs/project/beginning-learning-path.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: map beginning learning path"
```

### Task 2: Connect the planning surfaces

**Files:**

- Modify: `docs/README.md`
- Modify: `docs/project/roadmap.md`
- Modify: `docs/project/workflow.md`

#### Step 1: Index the new document

Add the beginning learning path to `docs/README.md` as a provisional planning
view for the early learning sequence.

#### Step 2: Relate the path to the active increment

Link `docs/project/beginning-learning-path.md` from the next-complete-increment
section of `docs/project/roadmap.md`. State that the learning path supplies
provisional sequence context while the roadmap owns only the module lesson now
being designed.

Replace the later decision about which question follows the module lesson with
a decision about whether executable lesson design confirms or revises the
provisional next question. Update the roadmap-maintenance rule so speculative
lesson sequencing belongs in the beginning learning path, not the roadmap or
reader-facing index.

#### Step 3: State the workflow boundary

In `docs/project/workflow.md`, tell contributors to consult the beginning
learning path for sequence context and the roadmap for the one active outcome.
State that a provisional entry creates no lesson directory or reader-facing
navigation.

#### Step 4: Check navigation and prose

Run:

```bash
test -f docs/project/beginning-learning-path.md
test -f docs/project/roadmap.md
test -f content/learn/README.md
markdownlint-cli2 docs/README.md docs/project/roadmap.md \
  docs/project/workflow.md docs/project/beginning-learning-path.md
git diff --check
```

Expected: every file exists, Markdown reports zero errors, and Git reports no
whitespace errors.

#### Step 5: Commit the connected workflow without signing

```bash
git add docs/README.md docs/project/roadmap.md docs/project/workflow.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: connect beginning learning path"
```

### Task 3: Audit and close the roadmap work

**Files:**

- Delete: `docs/plans/2026-08-26-beginning-learning-path-design.md`
- Delete: `docs/plans/2026-08-26-beginning-learning-path.md`

#### Step 1: Audit the approved requirements

Read every changed file. Confirm:

- lesson 1 is **verified**;
- lesson 2 is **next**;
- lessons 3 through 11 are **provisional**;
- the learning index contains only the existing first lesson;
- no future lesson directory exists;
- the roadmap contains one next complete increment;
- ad-hoc polymorphism is outside the beginning path; and
- the beginner outcome is a pure multi-file program over learner-defined data.

#### Step 2: Run the complete documentation checks

```bash
content/learn/what-is-an-ash-program/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
git diff --check main...HEAD
```

Expected: seven lesson sources and displayed blocks verified at the pinned Ash
commit, zero Markdown errors, a valid skill, and no whitespace errors.

#### Step 3: Remove the completed temporary records

Remove both plan files and remove their active links from
`docs/project/roadmap.md`. Git history retains the design and implementation
plan.

#### Step 4: Commit plan closure without signing

```bash
git add docs/plans docs/project/roadmap.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: close beginning learning path plan"
```

#### Step 5: Verify the final branch

Repeat the complete documentation checks from Step 2. Then run:

```bash
git status --short --branch
git log --format='%h %G? %s' main..HEAD
```

Expected: a clean `docs/beginning-learning-path` branch and `N` for every
intermediate commit signature status.
