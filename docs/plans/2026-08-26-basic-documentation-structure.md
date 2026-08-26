# Basic Documentation Structure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Establish indexed repository roots and an ash-doc-specific workflow
for planning complete documentation units with colocated executable evidence.

**Architecture:** Durable project policy lives under `docs/project/`; temporary
execution plans live under `docs/plans/`. Indexed `content/`, `lab/`, and
`research/` roots define distinct work boundaries without creating empty content
families or selecting a renderer, manifest, or harness.

**Tech Stack:** Markdown, Git, `markdownlint-cli2`, shell assertions

**Required project skill:** Use @writing-ash-documentation for every prose
change.

---

## Task 1: Add the project workflow and planning indexes

**Files:**

- Create: `docs/README.md`
- Create: `docs/project/workflow.md`
- Create: `docs/project/roadmap.md`
- Create: `docs/plans/README.md`

### Step 1: Run the structural check before creating the files

Run:

```bash
test -f docs/README.md && \
test -f docs/project/workflow.md && \
test -f docs/project/roadmap.md && \
test -f docs/plans/README.md
```

Expected: FAIL because the indexed project files do not exist.

### Step 2: Write the indexes and workflow

Create `docs/README.md` as the project-documentation index. Create
`docs/project/workflow.md` with the approved unit lifecycle, authority boundary,
path identities, experiment and research routes, evidence classification, and
replacement condition. Create `docs/project/roadmap.md` as the current planning
view for the Modular Ash edition. Create `docs/plans/README.md` with temporary
plan ownership and removal rules.

### Step 3: Verify the project documentation

Run:

```bash
markdownlint-cli2 \
  docs/README.md \
  docs/project/workflow.md \
  docs/project/roadmap.md \
  docs/plans/README.md
git diff --check
```

Expected: Markdown reports `0 error(s)` and `git diff --check` exits zero.

### Step 4: Commit the project workflow

```bash
git add docs/README.md docs/project docs/plans/README.md
git commit -m "docs: define ash-doc project workflow"
```

## Task 2: Add indexed work roots

**Files:**

- Create: `content/README.md`
- Create: `lab/README.md`
- Create: `research/README.md`

### Step 1: Run the root check before creating the files

Run:

```bash
test -f content/README.md && \
test -f lab/README.md && \
test -f research/README.md
```

Expected: FAIL because the work roots do not exist.

### Step 2: Write the root indexes

Define published unit boundaries in `content/README.md`, executable experiment
boundaries in `lab/README.md`, and source-evaluation boundaries in
`research/README.md`. Describe future path shapes without creating leaf
directories. Keep code, fixtures, and checks local to the unit or lab case that
owns them.

### Step 3: Verify the root indexes and absence of empty scaffolds

Run:

```bash
markdownlint-cli2 content/README.md lab/README.md research/README.md
leaf_count=$(find content lab research \
  -type d \
  ! -path content \
  ! -path lab \
  ! -path research | wc -l)
test "$leaf_count" -eq 0
git diff --check
```

Expected: Markdown reports `0 error(s)`, no leaf directory exists, and
`git diff --check` exits zero.

### Step 4: Commit the work root indexes

```bash
git add content/README.md lab/README.md research/README.md
git commit -m "docs: index documentation work roots"
```

## Task 3: Route contributors into the workflow

**Files:**

- Modify: `README.md`
- Modify: `AGENTS.md`

### Step 1: Confirm the old bootstrap boundary is still present

Run:

```bash
rg -n "selects no content (layout|directories)" README.md AGENTS.md
```

Expected: PASS and print the obsolete bootstrap statements.

### Step 2: Update repository guidance

Replace the obsolete no-layout statements with links to `docs/README.md` and
`docs/project/workflow.md`. Tell contributors to plan through the roadmap and a
temporary execution plan, then create a unit only when its prose and applicable
evidence can land together. Preserve the deferred renderer, manifest, harness,
CI, and publication boundaries.

### Step 3: Verify routing and links

Run:

```bash
markdownlint-cli2 README.md AGENTS.md
rg -n "docs/project/workflow.md" README.md AGENTS.md
! rg -n "selects no content (layout|directories)" README.md AGENTS.md
git diff --check
```

Expected: Markdown reports `0 error(s)`, both files route to the workflow, the
obsolete statements are absent, and `git diff --check` exits zero.

### Step 4: Commit the contributor routing

```bash
git add README.md AGENTS.md
git commit -m "docs: route work through project workflow"
```

## Task 4: Verify the complete structure and retire temporary plans

**Files:**

- Delete: `docs/plans/2026-08-26-basic-documentation-structure-design.md`
- Delete: `docs/plans/2026-08-26-basic-documentation-structure.md`

### Step 1: Run the full documentation checks

Run:

```bash
markdownlint-cli2 \
  README.md AGENTS.md \
  .agents/skills/writing-ash-documentation/SKILL.md \
  .agents/skills/writing-ash-documentation/tests/writing-scenarios.md \
  docs/README.md docs/project/workflow.md docs/project/roadmap.md \
  docs/plans/README.md content/README.md lab/README.md research/README.md
skill_creator=/home/dikini/.codex/skills/.system/skill-creator
python3 "$skill_creator/scripts/quick_validate.py" \
  .agents/skills/writing-ash-documentation
git diff --check
```

Expected: Markdown reports `0 error(s)`, the skill is valid, and
`git diff --check` exits zero.

### Step 2: Check local Markdown links

Run the repository link checker over every tracked Markdown file.

Expected: every relative Markdown target exists.

### Step 3: Remove the completed planning artifacts

Delete both task-owned plan files. Git history retains the approved design and
implementation sequence; `docs/plans/README.md` remains as the durable policy.

### Step 4: Verify the final tree

Run:

```bash
leaf_count=$(find content lab research \
  -type d \
  ! -path content \
  ! -path lab \
  ! -path research | wc -l)
test "$leaf_count" -eq 0
test "$(find docs/plans -maxdepth 1 -type f ! -name README.md | wc -l)" -eq 0
git diff --check
git status --short
```

Expected: no leaf scaffolds or completed plans remain, and Git reports only the
two planned deletions.

### Step 5: Commit the plan retirement

```bash
git add docs/plans
git commit -m "docs: retire completed structure plans"
```
