# Modular Ash Publication Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Publish the reviewed beginning learning path as the immutable
ash-doc `modular-ash` repository-source edition.

**Architecture:** Record the matching Ash/ash-doc tag-name convention in
project policy, make the first edition identify its publication tag and exact
Ash target, and close the publication increment in the roadmap. Verify the
complete source snapshot before fast-forwarding `main`, then create and push an
annotated `modular-ash` tag atomically with `main`.

**Tech Stack:** Markdown, Bash, Git, `markdownlint-cli2`, and Ash
`modular-ash` at `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Worktree and authority

Work in
`/home/dikini/Projects/ash-doc/.worktrees/modular-ash-publication` on branch
`docs/modular-ash-publication` until integration. Use
@writing-ash-documentation for every project-prose review, edit, and commit
message.

The exact clean Ash checkout is:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

The pinned specification governs language claims. The pinned implementation,
tests, and tool guide govern executable observations. This publication changes
project state and identity only; it must not change lesson prose, canonical Ash
source, checks, or their claims.

Make unsigned commits with:

```bash
git -c commit.gpgsign=false commit --no-gpg-sign -m "<message>"
```

## Task 1: Record the matching-tag publication rule

**Files:**

- Modify: `AGENTS.md`
- Modify: `docs/project/workflow.md`
- Modify: `README.md`

### Step 1: Read the governing passages

Read the edition target and repository workflow passages in all three files.
Confirm that the existing source says publication uses an immutable
documentation tag but does not yet say that ash-doc reuses the target Ash
milestone tag name.

### Step 2: Add the durable rule

State that every published ash-doc edition uses the exact tag name of its
target Ash milestone. Explain that the tags live in different repositories and
therefore identify different commits: the `ash-lang` tag identifies language
and tool behavior, while the ash-doc tag identifies the corresponding
documentation source snapshot.

Keep immutable-tag and one-forward-line rules unchanged. Do not add a renderer,
release page, publication platform, or compatibility promise.

### Step 3: Identify the first published edition

Change the README from future publication language to current edition
language. Name:

- documentation tag: `modular-ash`;
- Ash milestone tag: `modular-ash`; and
- resolved Ash commit:
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

Keep the root as the one owner of this shared reader-facing target information.

### Step 4: Check the edited project prose

Run:

```bash
markdownlint-cli2 AGENTS.md README.md docs/project/workflow.md
git diff --check
git diff -- AGENTS.md README.md docs/project/workflow.md
```

Expected: Markdown reports zero errors, whitespace checks pass, and the diff
contains only publication identity and workflow changes.

### Step 5: Commit the durable publication rule

```bash
git add AGENTS.md README.md docs/project/workflow.md
git -c commit.gpgsign=false commit --no-gpg-sign \
    -m "docs: identify modular ash edition"
```

## Task 2: Establish the final publication state

**Files:**

- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-29-modular-ash-publication-design.md`
- Delete: `docs/plans/2026-08-29-modular-ash-publication.md`

### Step 1: Replace the roadmap increment

Record the first repository-source edition as published under documentation
tag `modular-ash`, still targeting Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`.

The verified increment should state that the final source snapshot retains the
reviewed eleven-lesson path, passes its complete pinned verifier, and provides
an immutable same-name mapping between the Ash milestone and documentation
edition without defining Ash behavior.

### Step 2: Select the next bounded outcome

Make the next roadmap increment a manual exact-commit compatibility canary
against one fetchable `ash-lang/main` commit. Keep the publication target
unchanged. Require a bounded design before adding any canary mechanism, and
exclude CI, schedules, migration, and new lesson content from that outcome.

### Step 3: Remove completed publication plans

Remove both temporary publication plan files. Git history retains the approved
design and execution sequence.

### Step 4: Read the final project state

Read `README.md`, `AGENTS.md`, `docs/project/workflow.md`,
`docs/project/roadmap.md`, and `docs/plans/README.md` as source. Confirm that:

- the matching tag-name rule is consistent;
- the edition target and documentation identity are unambiguous;
- publication is a fact, the canary is selected future work, and no migration
  is implied;
- completed plans no longer appear in the tree; and
- no lesson or executable file changed.

Do not commit yet. Task 3 verifies this candidate source snapshot first.

## Task 3: Verify the publication candidate

**Files:**

- Verify: `README.md`
- Verify: `AGENTS.md`
- Verify: `content/learn/**/*.md`
- Verify: `content/learn/**/*.ash`
- Verify: `content/learn/**/checks/*.sh`
- Verify: `docs/**/*.md`
- Verify: `.agents/skills/writing-ash-documentation/`

### Step 1: Verify the exact Ash target and tag baseline

Run:

```bash
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    rev-parse HEAD
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    status --short
git tag --list modular-ash
git ls-remote --tags origin refs/tags/modular-ash \
    'refs/tags/modular-ash^{}'
```

Expected: the Ash checkout reports
`dca16039923475c48025c5f17beadeb6bcb6a4bf` and no changes; both ash-doc tag
queries produce no output.

### Step 2: Run executable and shell verification

```bash
content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/learn/checks/*.sh content/learn/*/checks/verify.sh
```

Expected: all eleven lesson source-agreement summaries pass at the exact pin,
the family reports `Verified 11 learning lesson(s)`, and Bash reports no error.

### Step 3: Run documentation checks

```bash
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
    /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
    .agents/skills/writing-ash-documentation
```

Expected: Markdown reports zero errors and the writing skill is valid.

### Step 4: Check relative links and scope

Inspect every changed relative Markdown link at its source and confirm that the
target exists. Then run:

```bash
git diff --check main...HEAD
git diff --name-status main...HEAD
git diff --stat main...HEAD
git diff main...HEAD
git status --short --branch
```

Expected: only project publication Markdown and temporary plans differ from
`main`; no lesson, Ash source, check, fixture, or dependency changes; the
branch contains only the expected uncommitted roadmap closure and plan
removals.

## Task 4: Commit and review the final source snapshot

**Files:**

- Commit: `docs/project/roadmap.md`
- Commit deletion: `docs/plans/2026-08-29-modular-ash-publication-design.md`
- Commit deletion: `docs/plans/2026-08-29-modular-ash-publication.md`

### Step 1: Commit publication closure

```bash
git add docs/project/roadmap.md \
    docs/plans/2026-08-29-modular-ash-publication-design.md \
    docs/plans/2026-08-29-modular-ash-publication.md
git -c commit.gpgsign=false commit --no-gpg-sign \
    -m "docs: publish modular ash edition"
```

### Step 2: Request code review

Use @superpowers:requesting-code-review to review the complete branch diff
against `main`. Correct any publication-blocking finding and repeat affected
checks before continuing.

### Step 3: Run final branch verification

Run the complete Task 3 executable, shell, Markdown, skill, link, diff, and
status verification against the committed branch. Expected: all checks pass,
the branch is clean, and no publication tag exists yet.

## Task 5: Integrate and publish

**Files:**

- Integrate branch: `docs/modular-ash-publication`
- Create tag: `refs/tags/modular-ash`
- Update remote: `origin/main` and `origin` tag `modular-ash`

### Step 1: Confirm the remote integration baseline

From the primary worktree, fetch `origin/main` and confirm that local `main`,
`origin/main`, and the publication branch have the expected fast-forward
relationship. Stop if upstream moved or either worktree is dirty.

### Step 2: Fast-forward local main

```bash
git merge --ff-only docs/modular-ash-publication
```

Expected: `main` advances to the verified publication commit without a merge
commit.

### Step 3: Verify the exact tag target

Run the complete lesson verifier, Bash syntax check, Markdown check, writing
skill validation, `git diff --check`, and status check from `main`. Confirm
again that `modular-ash` is absent locally and remotely.

### Step 4: Create the annotated local tag

```bash
git -c tag.gpgSign=false tag --no-sign -a modular-ash \
    -m "Ash documentation for Modular Ash" \
    -m "Ash milestone: modular-ash" \
    -m "Resolved Ash commit: dca16039923475c48025c5f17beadeb6bcb6a4bf"
git cat-file -p refs/tags/modular-ash
git rev-parse modular-ash^{}
```

Expected: the annotated tag message names the edition and exact Ash target,
and the dereferenced tag equals the verified `main` commit.

### Step 5: Push main and tag atomically

```bash
git push --atomic origin main refs/tags/modular-ash
```

Expected: the remote accepts both the updated branch and new tag in one push.

### Step 6: Verify the remote publication

```bash
git ls-remote --exit-code --tags origin refs/tags/modular-ash \
    'refs/tags/modular-ash^{}'
git status --short --branch
git rev-parse HEAD
git rev-parse modular-ash^{}
```

Expected: the remote reports the annotated tag object and its dereferenced
publication commit; local `main` matches `origin/main`, the tree is clean, and
`HEAD` equals the dereferenced local tag.

### Step 7: Clean the completed task worktree

Use @superpowers:finishing-a-development-branch. Remove only the clean,
integrated `.worktrees/modular-ash-publication` worktree and delete only the
merged local `docs/modular-ash-publication` branch. Preserve unrelated
worktrees and branches.
