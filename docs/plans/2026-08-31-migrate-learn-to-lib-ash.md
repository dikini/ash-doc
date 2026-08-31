# Migrate Learn to Lib Ash Implementation Plan

<!-- markdownlint-disable MD013 -->

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move the complete eleven-lesson Learn path to exact Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d` while retaining every unexpected
compiler failure as upstream evidence and keeping unmigrated content out of the
active edition.

**Architecture:** Preserve the immutable `recursive-1` tree as the comparison
baseline, record the three known imported-summary failures before cutover, and
then make `main` an explicit unpublished migration. Restore Learn lessons in
reading order only after each passes its local verifier at `lib-ash`; after each
restoration, run the aggregate verifier and assess the four new feature groups
without changing the lesson's reader question.

**Tech Stack:** Ash at the signed annotated `lib-ash` tag, Git worktrees, Bash,
Cargo, Markdown, Markdownlint, ShellCheck, and Git.

---

## Execution boundary

Use `@writing-ash-documentation` for every project or lesson edit and every
commit message. Use `@systematic-debugging` for any observation that differs
from this plan. Before closure or integration, use
`@verification-before-completion` and report command output rather than an
inferred result.

This plan owns only Outcome 1 from the approved
[milestone design](2026-08-31-lib-ash-documentation-milestone-design.md):

- cut the repository target over to one exact `lib-ash` commit;
- retain the three already observed imported-summary compiler failures;
- migrate and restore all eleven Learn lessons in reading order;
- assess each migrated lesson for a justified `lib-ash` enhancement; and
- promote Cases migration after Learn closes.

Do not migrate a Case, create `content/libraries/`, change `ash-lang`, create
the ash-doc `lib-ash` tag, or push a branch or tag. An unexpected compiler
failure is evidence to record, not permission to alter Ash or conceal the
triggering source.

Use these exact local checkouts throughout execution:

```text
Learn worktree:
/home/dikini/Projects/ash-doc/.worktrees/migrate-learn-to-lib-ash

Predecessor ash-doc tree:
/home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin

Modular Ash tree:
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin

Lib Ash tree:
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

The exact identities are:

```text
ash-doc recursive-1 commit:
fa870a280c76278361db658ff3952cf18f2b7833

ash-lang modular-ash commit:
dca16039923475c48025c5f17beadeb6bcb6a4bf

ash-lang lib-ash tag object:
3173abcf54ec512dcf1b1bf10713faf312917f5e

ash-lang lib-ash peeled commit:
d1e323d23390cdad03202ee3df76cd9100556e1d
```

## Migration record

Update this table in the temporary plan as each task finishes. A baseline result
states whether the predecessor source behaves the same at both exact targets.
An enhancement result must name a concrete benefit or say why the new feature
would be unrelated or premature. Git history retains the table after this plan
leaves the final tree.

| Lesson | Baseline at `lib-ash` | Minimal migration | Enhancement assessment |
| --- | --- | --- | --- |
| 1. What is an Ash program? | All seven exact predecessor observations are unchanged at `lib-ash`. | Target and link administration only; canonical lesson source, prose, and verifier are unchanged. | None: implementation selection, kinds, method-local parameters, and relational interfaces do not answer the first program-and-value question. |
| 2. Using another source file | All three exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying this complete-import lesson, strengthening its public/private invariant, or making its promised module boundary more direct. |
| 3. Using more than one input | All four exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying chained inputs and partial calls, strengthening their typing boundary, or making the lesson's promised function-application model more direct. |
| 4. Choosing a result | All four exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying Boolean result selection, strengthening exhaustive coverage, or making the lesson's question-and-choice boundary more direct. |
| 5. Naming intermediate values | All three exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying ordered local bindings, strengthening their scope-and-order invariant, or making the lesson's block-expression boundary more direct. |
| 6. Values travel together | All four exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying structural tuples, strengthening their fixed-arity, order, and element-type invariant, or making the lesson's one-value product boundary more direct. |
| 7. Defining data | All three exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying nominal data definitions or constructor formation, strengthening the nominal-identity and possible-forms invariant, or making the lesson's promised data-definition boundary more direct. |
| 8. Handling data forms | All three exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying constructor-pattern handling, strengthening the data-definition and exhaustive-coverage invariant, or making the lesson's promised data-form boundary more direct. |
| 9. Following recursive data | All three exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying structural recursion, strengthening its smaller-rest and stopping-form invariant, or making the lesson's recursive-data boundary more direct. |
| 10. Functions as values | All four exact predecessor observations are unchanged at `lib-ash`. | Active-prefix navigation only; canonical lesson source, prose, verifier, and observations are unchanged, and the lesson contains no pinned specification or tool links to update. | None: implementation selection, explicit kinds, method-local parameters, and relational interfaces would introduce later abstractions without simplifying higher-order functions or lexical capture, strengthening the function-valued input boundary, or making the lesson's promised functional-abstraction boundary more direct. |
| 11. Definitions for many types | All three accepted predecessor observations retain their values, types, status, and channels at `lib-ash`; the specified rejection retains status `1` and empty standard output but changes its first reason from `resolve.type-argument-count` to `kind.expected-type`. | Preserve all five canonical sources; revise the lesson to explain the explicit kind boundary, and extend the shared rejection helper to retain the exact primary source location, the causal related declaration, and structured expected and found kinds while preserving every existing caller. | No new abstraction: the explicit kinds already improve the existing rejection account through `List : Type -> Type`, `List<Int> : Type`, and the ordinary-value-position invariant; a reusable higher-kinded example would change the beginner lesson's question and belongs in the later library path. |

### Execution note: exact comparison baseline

On 2026-08-31, execution verified the signed annotated `ash-lang` tag
`lib-ash` with tag object
`3173abcf54ec512dcf1b1bf10713faf312917f5e`, peeled commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`, and a good signature from key
`45568F3F6EF041E37DF0131443089CA4D73C4C22`. The clean detached Lib Ash
checkout builds with its declared Rust 1.97.1 toolchain.

The clean detached predecessor documentation checkout resolves `recursive-1`
to `fa870a280c76278361db658ff3952cf18f2b7833`. Against the clean Modular Ash
checkout at `dca16039923475c48025c5f17beadeb6bcb6a4bf`, its aggregate verifiers
reported `Verified 11 learning lesson(s)` and `Verified 12 case(s)`.

The first Lib Ash build command used `--manifest-path` while the caller's
working directory was ash-doc. Rustup therefore selected the caller's Rust
1.94.0 instead of the pinned checkout's `rust-toolchain.toml` and Cargo rejected
the package's declared Rust 1.97.1 minimum. Running Cargo from inside the exact
Ash checkout selected Rust 1.97.1 and passed. The plan now enters each Ash
checkout before building; this was a local invocation error, not an Ash
compiler failure.

### Execution note: retained imported-summary failures

The Task 3 RED command failed because its verifier did not yet exist. After the
six sources were copied byte-for-byte and the lab record and verifier were
added, Bash syntax, ShellCheck, Markdownlint, and `git diff --check` passed.
The executable comparison reported `Verified 3 imported-summary failures` from
exact Modular Ash to exact Lib Ash. Each predecessor entry returned status `0`
with its authenticated output, while each Lib Ash entry returned status `2`,
empty standard output, `resolve.internal-state`, and a causal import label for
`a dependency summary failed body-free authentication`.
Direct Lib Ash controls also established that both libraries without local
`main` reached `entry.missing-main` and that the red-black library's local
`main` succeeded. The internal failures therefore arise when the importing
entries admit the already checked dependency summaries.

### Execution note: first active Learn prefix

On 2026-08-31, the lesson 1 verifier rejected the exact Lib Ash checkout with
status `1` because the shared helper still expected
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. After the active target changed
to `d1e323d23390cdad03202ee3df76cd9100556e1d` and the unverified content left
the active tree, the lesson-local verifier reported seven canonical sources
and displayed blocks at the new pin. The aggregate reported one learning
lesson at the same pin; the active tree contained exactly one lesson verifier
and no `content/cases/` directory.

All six accepted value-and-type observations and the `entry.missing-main`
rejection retained their predecessor status and channel behavior. Lesson 1's
canonical source, prose, and local verifier did not change. The migration
changed only target and navigation administration. Explicit implementation
selection, kinds, method-local parameters, and relational interfaces add no
answer to this lesson's first program-and-value question, so it receives no
Lib Ash enhancement.

Expected enhancement decisions are not foregone conclusions. The initial
canary suggests that lessons 1 through 10 need no new library abstraction
because those concepts are outside their established questions. Lesson 11
must explain the newly explicit kind boundary for its existing unsaturated
type-constructor rejection, but a new higher-kinded abstraction belongs in the
later library path.

### Task 1: Activate the Learn migration plan

**Files:**

- Create: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`
- Modify: `docs/project/roadmap.md`

#### Step 1: Link the temporary plan from the one `next` outcome

In `docs/project/roadmap.md`, replace the paragraph beginning “The
implementation plan must define” with a link to this plan. State that the plan
fixes the cutover, per-lesson comparison, failure record, enhancement decision,
regression, review, and local-integration gates. Do not promote Cases.

#### Step 2: Check the plan as project prose

Run:

```bash
markdownlint-cli2 \
    docs/plans/2026-08-31-migrate-learn-to-lib-ash.md \
    docs/project/roadmap.md
git diff --check
git status --short
```

Expected: Markdownlint reports `0 error(s)`; the diff check is silent; status
lists only the plan and roadmap.

#### Step 3: Commit the execution handoff

```bash
git add docs/plans/2026-08-31-migrate-learn-to-lib-ash.md \
    docs/project/roadmap.md
git commit -m "docs: plan Learn migration to lib-ash"
```

Expected: one unsigned commit containing only those two files.

### Task 2: Establish immutable comparison checkouts

**Files:**

- Modify: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Verify the existing Modular Ash checkout

```bash
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    rev-parse HEAD
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    status --short
```

Expected: the first command prints
`dca16039923475c48025c5f17beadeb6bcb6a4bf`; the second is silent. Stop and
diagnose rather than moving this checkout if either condition differs.

#### Step 2: Create or verify the detached Lib Ash checkout

First inspect the target path. If it does not exist, run:

```bash
git -C /home/dikini/Projects/ash-lang worktree add --detach \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin \
    lib-ash
```

Then run:

```bash
git -C /home/dikini/Projects/ash-lang verify-tag --raw lib-ash
git -C /home/dikini/Projects/ash-lang rev-parse lib-ash^{tag}
git -C /home/dikini/Projects/ash-lang rev-parse lib-ash^{}
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin \
    rev-parse HEAD
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin \
    status --short
(
    cd /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
    cargo build --quiet --locked
)
```

Expected: the tag object is `3173abcf54ec512dcf1b1bf10713faf312917f5e`;
both peeled and checked-out commits are
`d1e323d23390cdad03202ee3df76cd9100556e1d`; status and build output are
silent.

#### Step 3: Create or verify the detached predecessor documentation tree

If the path does not exist, run:

```bash
mkdir -p /home/dikini/.config/superpowers/worktrees/ash-doc
git worktree add --detach \
    /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin \
    recursive-1
```

Then run:

```bash
git -C /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin \
    rev-parse HEAD
git -C /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin \
    status --short
bash \
    /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin/content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash \
    /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin/content/cases/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: exact predecessor commit
`fa870a280c76278361db658ff3952cf18f2b7833`, a clean tree, then `Verified 11
learning lesson(s)` and `Verified 12 case(s)` at the Modular Ash commit.

#### Step 4: Record the observed checkout identities

Append the actual identities and successful baseline commands to an execution
note immediately below the Migration record table. Do not copy compiler output
from memory.

#### Step 5: Commit the reproducible baseline

```bash
git add docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git commit -m "docs: record lib-ash migration baseline"
```

### Task 3: Retain the known imported-summary failures

**Files:**

- Modify: `lab/README.md`
- Create: `lab/lib-ash-migration/README.md`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/README.md`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/search-frontier/searches.ash`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/search-frontier/main.ash`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/red-black-dictionary/dictionaries.ash`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/red-black-dictionary/main.ash`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/tree-iterator/dictionaries.ash`
- Create: `lab/lib-ash-migration/body-free-summary-authentication/tree-iterator/main.ash`
- Modify: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Copy the six exact triggering sources

Copy without editing:

```text
content/cases/choosing-a-search-frontier/src/searches.ash
  -> .../search-frontier/searches.ash
content/cases/choosing-a-search-frontier/src/01-found-paths.ash
  -> .../search-frontier/main.ash
content/cases/guaranteeing-logarithmic-retrieval/src/dictionaries.ash
  -> .../red-black-dictionary/dictionaries.ash
content/cases/guaranteeing-logarithmic-retrieval/src/01-prefix-matrix.ash
  -> .../red-black-dictionary/main.ash
content/cases/resuming-tree-traversal/src/dictionaries.ash
  -> .../tree-iterator/dictionaries.ash
content/cases/resuming-tree-traversal/src/01-sequence.ash
  -> .../tree-iterator/main.ash
```

Only rename the three entries to `main.ash`; their relative imports already
name the copied sibling library. Assert these SHA-256 values in the verifier:

Create the destinations and make the six mechanical copies:

```bash
mkdir -p \
    lab/lib-ash-migration/body-free-summary-authentication/checks \
    lab/lib-ash-migration/body-free-summary-authentication/search-frontier \
    lab/lib-ash-migration/body-free-summary-authentication/red-black-dictionary \
    lab/lib-ash-migration/body-free-summary-authentication/tree-iterator
cp content/cases/choosing-a-search-frontier/src/searches.ash \
    lab/lib-ash-migration/body-free-summary-authentication/search-frontier/searches.ash
cp content/cases/choosing-a-search-frontier/src/01-found-paths.ash \
    lab/lib-ash-migration/body-free-summary-authentication/search-frontier/main.ash
cp content/cases/guaranteeing-logarithmic-retrieval/src/dictionaries.ash \
    lab/lib-ash-migration/body-free-summary-authentication/red-black-dictionary/dictionaries.ash
cp content/cases/guaranteeing-logarithmic-retrieval/src/01-prefix-matrix.ash \
    lab/lib-ash-migration/body-free-summary-authentication/red-black-dictionary/main.ash
cp content/cases/resuming-tree-traversal/src/dictionaries.ash \
    lab/lib-ash-migration/body-free-summary-authentication/tree-iterator/dictionaries.ash
cp content/cases/resuming-tree-traversal/src/01-sequence.ash \
    lab/lib-ash-migration/body-free-summary-authentication/tree-iterator/main.ash
```

| Copy | Library SHA-256 | Entry SHA-256 |
| --- | --- | --- |
| search frontier | `d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b` | `98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692` |
| red-black dictionary | `9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d` | `eb56359bf329db9cf8e0c35ecad85efd9c39129b1da59f8024d577703d45282e` |
| tree iterator | `229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff` | `fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0` |

#### Step 2: Write a failing lab check for the two-target boundary

Create `checks/verify.sh` so it accepts exactly two arguments: the clean
Modular Ash checkout and the clean Lib Ash checkout. It must:

1. assert both exact commits and clean worktrees;
2. build each with `cargo build --quiet --locked` into a temporary target;
3. assert every copied source hash above;
4. run each dependency directly at Lib Ash and prove that it reaches either
   its successful `main` or the later `entry.missing-main` contract;
5. run each `main.ash` with the predecessor binary and assert status `0`, empty
   standard error, and the exact standard-output SHA-256 below;
6. run each entry with the Lib Ash binary and assert status `2`, empty standard
   output, first standard-error line `resolve.internal-state`, and the phrase
   `a dependency summary failed body-free authentication`; and
7. print one success line naming all three observations and both commits.

The predecessor output hashes include the command's trailing newline:

| Copy | Standard-output SHA-256 |
| --- | --- |
| search frontier | `254dc0d711ed8246b920f1be8b642af6d57a0aaa312a2d944de06fb570aea329` |
| red-black dictionary | `fbcad839ed0fcb98b146df63d4f478e191c38fe91083fb4b6c2e699b0777c2e1` |
| tree iterator | `190662c1447e5c5d9d5ae34d0e9dc95d0a157c6dfbf628656baa648a02166c45` |

Do not assert incidental color, layout, absolute paths, or source-number labels.
Before the files exist, run the planned command and expect failure for the
missing verifier:

```bash
bash \
    lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

Expected RED: Bash reports that `checks/verify.sh` does not exist.

Implement the check with this complete shape, substituting no floating refs or
different observations:

```bash
#!/usr/bin/env bash

set -euo pipefail

readonly modular_pin=dca16039923475c48025c5f17beadeb6bcb6a4bf
readonly lib_pin=d1e323d23390cdad03202ee3df76cd9100556e1d
case_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly case_root

fail() {
    printf 'verify: %s\n' "$1" >&2
    exit 1
}

if [[ $# -ne 2 ]]; then
    fail "usage: checks/verify.sh /path/to/modular-ash /path/to/lib-ash"
fi

readonly modular_dir=$1
readonly lib_dir=$2
verify_dir=$(mktemp -d "${TMPDIR:-/tmp}/ash-doc-lib-migration.XXXXXX")
readonly verify_dir
trap 'rm -rf -- "$verify_dir"' EXIT

check_checkout() {
    local checkout=$1
    local expected=$2
    local actual
    actual=$(git -C "$checkout" rev-parse HEAD 2>/dev/null) ||
        fail "$checkout is not an Ash checkout"
    [[ $actual == "$expected" ]] ||
        fail "$checkout is at $actual, expected $expected"
    [[ -z $(git -C "$checkout" status --short) ]] ||
        fail "$checkout must be clean"
}

check_checkout "$modular_dir" "$modular_pin"
check_checkout "$lib_dir" "$lib_pin"

(
    cd "$modular_dir"
    CARGO_TARGET_DIR="$verify_dir/modular-target" \
        cargo build --quiet --locked
)
(
    cd "$lib_dir"
    CARGO_TARGET_DIR="$verify_dir/lib-target" \
        cargo build --quiet --locked
)

readonly modular_ash="$verify_dir/modular-target/debug/ash"
readonly lib_ash="$verify_dir/lib-target/debug/ash"

assert_hash() {
    local file=$1
    local expected=$2
    local actual
    actual=$(sha256sum "$file" | cut -d' ' -f1)
    [[ $actual == "$expected" ]] ||
        fail "$file has hash $actual, expected $expected"
}

assert_dependency_reaches_entry_contract() {
    local label=$1
    local directory=$2
    local library_file=$3
    local dependency_stdout="$verify_dir/$label.dependency.stdout"
    local dependency_stderr="$verify_dir/$label.dependency.stderr"
    local status

    if "$lib_ash" "$case_root/$directory/$library_file" \
        > "$dependency_stdout" 2> "$dependency_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 1 ]] ||
        fail "$label dependency status is $status, expected 1"
    [[ ! -s $dependency_stdout ]] ||
        fail "$label dependency wrote unexpected standard output"
    [[ $(sed -n '1p' "$dependency_stderr") == entry.missing-main ]] ||
        fail "$label dependency did not reach the entry contract"
}

assert_dependency_runs() {
    local label=$1
    local directory=$2
    local library_file=$3
    local output_hash=$4
    local dependency_stdout="$verify_dir/$label.dependency.stdout"
    local dependency_stderr="$verify_dir/$label.dependency.stderr"
    local status
    local actual_output_hash

    if "$lib_ash" "$case_root/$directory/$library_file" \
        > "$dependency_stdout" 2> "$dependency_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 0 ]] ||
        fail "$label dependency status is $status, expected 0"
    [[ ! -s $dependency_stderr ]] ||
        fail "$label dependency wrote unexpected standard error"
    actual_output_hash=$(sha256sum "$dependency_stdout" | cut -d' ' -f1)
    [[ $actual_output_hash == "$output_hash" ]] ||
        fail "$label dependency output changed"
}

run_case() {
    local label=$1
    local directory=$2
    local library_file=$3
    local library_hash=$4
    local entry_hash=$5
    local output_hash=$6
    local import_line=$7
    local modular_stdout="$verify_dir/$label.modular.stdout"
    local modular_stderr="$verify_dir/$label.modular.stderr"
    local lib_stdout="$verify_dir/$label.lib.stdout"
    local lib_stderr="$verify_dir/$label.lib.stderr"
    local status
    local actual_output_hash
    local import_end=${#import_line}

    assert_hash "$case_root/$directory/$library_file" "$library_hash"
    assert_hash "$case_root/$directory/main.ash" "$entry_hash"
    [[ $(sed -n '1p' "$case_root/$directory/main.ash") == "$import_line" ]] ||
        fail "$label no longer retains its causal import"

    if "$modular_ash" "$case_root/$directory/main.ash" \
        > "$modular_stdout" 2> "$modular_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 0 ]] ||
        fail "$label predecessor status is $status, expected 0"
    [[ ! -s $modular_stderr ]] ||
        fail "$label predecessor wrote standard error"
    actual_output_hash=$(sha256sum "$modular_stdout" | cut -d' ' -f1)
    [[ $actual_output_hash == "$output_hash" ]] ||
        fail "$label predecessor output changed"

    if "$lib_ash" "$case_root/$directory/main.ash" \
        > "$lib_stdout" 2> "$lib_stderr"; then
        status=0
    else
        status=$?
    fi
    [[ $status -eq 2 ]] ||
        fail "$label lib-ash status is $status, expected 2"
    [[ ! -s $lib_stdout ]] ||
        fail "$label lib-ash wrote standard output"
    [[ $(sed -n '1p' "$lib_stderr") == resolve.internal-state ]] ||
        fail "$label lib-ash did not report resolve.internal-state"
    grep -Eq "^primary: source [0-9]+ 0\\.\\.$import_end: a dependency summary failed body-free authentication$" \
        "$lib_stderr" ||
        fail "$label lib-ash did not retain its causal import label"
}

assert_dependency_reaches_entry_contract \
    search-frontier \
    search-frontier \
    searches.ash
assert_dependency_runs \
    red-black-dictionary \
    red-black-dictionary \
    dictionaries.ash \
    6c159135693e2dff8d81dc97fb60fafcebfeb9b0c09cb4deebec4757e4a716fc
assert_dependency_reaches_entry_contract \
    tree-iterator \
    tree-iterator \
    dictionaries.ash

run_case \
    search-frontier \
    search-frontier \
    searches.ash \
    d40dfbd8feb871bf2bd81dd156446d874b4ac41deab6c99f93a7bdaaf95bfb7b \
    98bdc800729e2ca6fdb0ce8b885455b5e8b48d69b9bb5d31c8f7d6b74f95d692 \
    254dc0d711ed8246b920f1be8b642af6d57a0aaa312a2d944de06fb570aea329 \
    'import searches as Searches'
run_case \
    red-black-dictionary \
    red-black-dictionary \
    dictionaries.ash \
    9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d \
    eb56359bf329db9cf8e0c35ecad85efd9c39129b1da59f8024d577703d45282e \
    fbcad839ed0fcb98b146df63d4f478e191c38fe91083fb4b6c2e699b0777c2e1 \
    'import dictionaries as Dictionaries'
run_case \
    tree-iterator \
    tree-iterator \
    dictionaries.ash \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0 \
    190662c1447e5c5d9d5ae34d0e9dc95d0a157c6dfbf628656baa648a02166c45 \
    'import dictionaries as Dictionaries'

printf 'Verified 3 imported-summary failures (%s) from %s to %s.\n' \
    'search-frontier, red-black-dictionary, tree-iterator' \
    "$modular_pin" \
    "$lib_pin"
```

#### Step 3: Implement the verifier and make it pass

Use `mktemp -d` plus a trap for all outputs and build artifacts. Capture status
with an `if` statement so `set -e` does not erase the observation. Use
`sha256sum` for source and predecessor-output agreement, `sed -n '1p'` for the
stable first reason, and `grep -Eq` for causal import-range evidence.

Run the command from Step 2 again.

Expected GREEN: one line reports three retained compiler failures; neither
compiler writes uncontrolled output to the terminal.

#### Step 4: Write the evidence record

The case README must identify separately for all three programs:

- the exact original Case and immutable `recursive-1` source link;
- both exact Ash commits and complete reproduction command;
- the reader task that the original Case served;
- predecessor status, channel observations, and output hash;
- Lib Ash status, empty standard output, and complete captured standard error;
- the applicable `lib-ash` import, checking, and tool-failure contracts;
- the affected Case and why the failure matters beyond it; and
- classification as an Ash implementation regression candidate, not specified
  language behavior or a proposed fix.

Do not claim that the three sources share an internal cause beyond their same
observable failure family. State that ash-doc does not solve or prescribe a
compiler change. Retain this lab until an authorized upstream resolution and a
later ash-doc plan explicitly replace its expectation.

Make `lab/lib-ash-migration/README.md` a short family index for compiler and
migration evidence at the two exact pins. Add the family link to `lab/README.md`.

#### Step 5: Verify and commit the permanent evidence

```bash
bash -n \
    lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh
shellcheck \
    lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh
bash \
    lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
markdownlint-cli2 lab/README.md 'lab/lib-ash-migration/**/*.md'
git diff --check
git status --short
```

Expected: syntax, ShellCheck, three observations, and Markdown all pass. Record
the exact result in the plan, then commit:

```bash
git add lab docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git commit -m "lab: retain lib-ash summary failures"
```

### Task 4: Cut the active edition over to Lib Ash

**Files:**

- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `content/README.md`
- Modify: `content/checks/lib.sh`
- Modify: `content/learn/README.md`
- Modify: `docs/project/beginning-learning-path.md`
- Modify: `docs/project/roadmap.md`
- Delete: `content/cases/`
- Delete: Learn lesson directories 2 through 11
- Modify: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Prove the first lesson is still pinned to Modular Ash

Run:

```bash
bash content/learn/what-is-an-ash-program/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

Expected RED: `verify: ash-lang HEAD is ... expected
dca16039923475c48025c5f17beadeb6bcb6a4bf`. This proves the shared pin blocks a
mixed active edition.

#### Step 2: Remove content that has not passed the new pin

Remove all of `content/cases/` and these Learn directories from the active
tree:

```text
using-another-source-file
using-more-than-one-input
choosing-a-result
naming-intermediate-values
values-travel-together
defining-data
handling-data-forms
following-recursive-data
functions-as-values
definitions-for-many-types
```

Run the removal as one explicit index change:

```bash
git rm -r content/cases \
    content/learn/using-another-source-file \
    content/learn/using-more-than-one-input \
    content/learn/choosing-a-result \
    content/learn/naming-intermediate-values \
    content/learn/values-travel-together \
    content/learn/defining-data \
    content/learn/handling-data-forms \
    content/learn/following-recursive-data \
    content/learn/functions-as-values \
    content/learn/definitions-for-many-types
```

They remain recoverable at immutable `recursive-1` and in branch history. Do
not leave placeholder pages under `content/`.

#### Step 3: Change the one shared target pin

In `content/checks/lib.sh`, set:

```bash
readonly ash_doc_expected_pin=d1e323d23390cdad03202ee3df76cd9100556e1d
```

Change no other helper behavior in this task.

#### Step 4: Make repository state and navigation coherent

Apply these exact policy changes:

- `AGENTS.md` names `lib-ash` and its peeled commit as the active migratory
  target and language/tool authority. It identifies `modular-ash` as the
  immutable predecessor, not the current edition.
- `README.md` names an unpublished `lib-ash` migration, gives the exact checkout
  command, links only to specification and tool material at the new commit,
  and says only the restored Learn prefix is active. It links the predecessor
  Cases at immutable `recursive-1` and says Cases migration is next, without
  presenting those old pages as current teaching.
- `content/README.md` indexes only the active Learn family. It sends the
  recursive-algorithm predecessor to immutable history and does not leave a
  broken local Cases link.
- `content/learn/README.md` lists only lesson 1.
- `docs/project/beginning-learning-path.md` names exact `lib-ash`, links lesson
  1 as verified, and displays lessons 2 through 11 as migration-pending plain
  text with no local links.
- `docs/project/roadmap.md` names the new exact target and unpublished migration
  state. Its retained Cases record uses immutable `recursive-1` URLs instead
  of deleted local paths, and its current verification command omits the absent
  Cases aggregator. Keep Learn as `next`.

Historical design documents retain their original target and status. Do not
rewrite `docs/plans/2026-08-29-recursive-algorithms-design.md` or the approved
milestone design to look current.

#### Step 5: Verify lesson 1 and the cutover

```bash
bash content/learn/what-is-an-ash-program/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
test "$(find content/learn -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l)" -eq 1
test ! -e content/cases
rg -n 'dca16039923475c48025c5f17beadeb6bcb6a4bf|modular-ash' \
    AGENTS.md README.md content docs/project
```

Expected: the local and aggregate verifiers pass at the new commit; exactly one
lesson is active; Cases is absent. The final search may find only explicitly
historical predecessor statements, retained historical Cases records, and the
milestone comparison. Review every match; no active target, command, or local
check may use the old pin.

#### Step 6: Record the first baseline and enhancement assessment

Update lesson 1 in the Migration record:

- baseline: all seven exact predecessor observations are unchanged at
  `lib-ash`;
- minimal migration: target/link administration only; canonical lesson source,
  prose, and verifier are unchanged; and
- enhancement: none, because implementation selection, kinds, method-local
  parameters, and relational interfaces do not answer the first program/value
  question.

#### Step 7: Verify project prose and commit the cutover

Run all changed shell syntax checks, Markdownlint over every current Markdown
file, a relative-link check, and `git diff --check`. The relative-link check
must parse Markdown link targets, ignore `http`, `https`, anchors, and code,
resolve each remaining local target from its source file, and report zero
missing targets.

Run this read-only link check:

```bash
python3 - <<'PY'
from pathlib import Path
import re
from urllib.parse import unquote

pattern = re.compile(r"!?\[[^]]*\]\(([^)]+)\)")
missing = []
checked = 0

for document in sorted(Path(".").rglob("*.md")):
    if any(part in {".git", ".worktrees"} for part in document.parts):
        continue
    fenced = False
    for number, line in enumerate(document.read_text().splitlines(), 1):
        if line.startswith(("```", "~~~")):
            fenced = not fenced
            continue
        if fenced:
            continue
        for match in pattern.finditer(line):
            raw = match.group(1).strip()
            target = (
                raw[1:raw.find(">")]
                if raw.startswith("<") and ">" in raw
                else raw.split()[0]
            )
            if target.startswith(("#", "http://", "https://", "mailto:")):
                continue
            path_text = unquote(target.split("#", 1)[0].split("?", 1)[0])
            if not path_text:
                continue
            checked += 1
            resolved = (document.parent / path_text).resolve()
            if not resolved.exists():
                missing.append(f"{document}:{number}: {target}")

if missing:
    raise SystemExit("Missing relative links:\n" + "\n".join(missing))
print(f"Checked {checked} relative links.")
PY
```

```bash
bash -n content/checks/lib.sh content/learn/checks/verify.sh \
    content/learn/what-is-an-ash-program/checks/verify.sh
markdownlint-cli2 '**/*.md'
git diff --check
git status --short
```

Expected: all checks pass; deleted content is explicit in status. Commit:

```bash
git add -A
git commit -m "docs: begin lib-ash Learn migration"
```

### Task 5: Restore lessons 2 through 10 in reading order

Repeat this task separately for each row below. Do not combine lessons into one
commit.

| Order | Directory | Sources | Commit subject |
| --- | --- | ---: | --- |
| 2 | `using-another-source-file` | 3 | `docs: restore multi-file Learn lesson` |
| 3 | `using-more-than-one-input` | 4 | `docs: restore multi-input Learn lesson` |
| 4 | `choosing-a-result` | 4 | `docs: restore result-choice Learn lesson` |
| 5 | `naming-intermediate-values` | 3 | `docs: restore local-binding Learn lesson` |
| 6 | `values-travel-together` | 4 | `docs: restore tuple Learn lesson` |
| 7 | `defining-data` | 3 | `docs: restore data-definition Learn lesson` |
| 8 | `handling-data-forms` | 3 | `docs: restore data-pattern Learn lesson` |
| 9 | `following-recursive-data` | 3 | `docs: restore recursive-data Learn lesson` |
| 10 | `functions-as-values` | 4 | `docs: restore function-values Learn lesson` |

For each lesson, use the following steps with `<lesson>` and `<N>` replaced by
that row's values.

#### Step 1: Re-run the immutable predecessor lesson

```bash
bash \
    /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin/content/learn/<lesson>/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: `<N>` canonical sources and displayed blocks pass at the predecessor
commit. This is the lesson-owned baseline, not an inference from the aggregate.

#### Step 2: Restore the exact lesson and make its new-target test fail first

Restore `content/learn/<lesson>/` byte-for-byte from `recursive-1`, but do not
yet add its index or path link:

```bash
git restore --source=recursive-1 -- content/learn/<lesson>
```

Run:

```bash
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

If the canary remains accurate, the aggregate passes and reports one more
lesson. If any value, type, reason, causal evidence, standard channel, or status
differs, stop the restoration and follow the compiler-failure classification
gate below before editing source or prose.

Now compare the number of restored lesson verifiers with the number of numbered
links in the Learn index:

```bash
restored_lesson_count=$(find content/learn -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l)
indexed_lesson_count=$(grep -Ec '^[0-9]+\. \[' content/learn/README.md)
test "$restored_lesson_count" -eq "$indexed_lesson_count"
```

Expected RED: the restored lesson exists but the index still describes the
previous active prefix. This is the navigation test that the next step fixes.

#### Step 3: Perform only the minimal migration

Update specification and tool links in the lesson from the old commit to
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Remove or change any final “next
lesson” link whose target is not active yet; keep the conceptual question as
plain text. Do not change canonical Ash or observations when the exact source
already passes.

Add the lesson to `content/learn/README.md` and change its entry in
`docs/project/beginning-learning-path.md` from migration-pending plain text to a
verified local link. Leave later lessons pending and unlinked.

#### Step 4: Assess all four feature groups

Read the migrated lesson as a learner and compare its current question with:

1. explicit implementation selection;
2. explicit kinds and higher-kinded declaration parameters;
3. method-local type parameters; and
4. relational interfaces and determination.

Record the result in the Migration record. For lessons 2 through 10, the
expected result is no enhancement unless the executed evidence disproves the
initial assessment: each feature would introduce a later abstraction without
simplifying the current code, strengthening its current invariant, or making
its promised boundary more direct. Do not add a feature merely to mention it.
If an enhancement is warranted, record the concrete benefit but do not edit the
lesson for it in this restoration task. Complete the minimal migration commit,
then execute Task 5A as a separate reviewed change.

#### Step 5: Run local, aggregate, prose, and navigation checks

```bash
bash content/learn/<lesson>/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
markdownlint-cli2 content/learn/<lesson>/README.md \
    content/learn/README.md docs/project/beginning-learning-path.md \
    docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git diff --check
git status --short
```

Expected: the local source count matches the table; the aggregate reports the
restored prefix length; all displayed source, output, diagnostic, navigation,
and Markdown checks pass.

Repeat the count assertion from Step 2 after updating the index. Expected
GREEN: restored and indexed lesson counts are equal.

#### Step 6: Commit exactly one restored lesson

```bash
git add content/learn/<lesson> content/learn/README.md \
    docs/project/beginning-learning-path.md \
    docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git commit -m "<commit subject>"
```

### Task 5A: Land any warranted Learn enhancement separately

This conditional task runs immediately after the minimal migration of a lesson
whose assessment names a concrete benefit. It does not run for a no-change
assessment.

**Files:**

- Modify: only the already migrated lesson's prose, canonical source, and local
  verifier needed by the accepted enhancement
- Modify: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Fix the enhancement boundary before editing

Record the unchanged reader question, the exact `lib-ash` feature, the concrete
benefit, the governing specification section, and the positive and negative
observation that will prove the improvement. If the enhancement changes the
reader question or introduces an unearned prerequisite, reject it from the
beginning path and retain it for the future library family instead.

#### Step 2: Write and run the smallest failing evidence check

Add the source-agreement or executable assertion that the proposed enhancement
requires before editing its teaching source or prose. Run the local verifier.
Expected RED: the new assertion fails for the specific missing source relation,
value, type, reason, channel, or status.

#### Step 3: Implement only the accepted enhancement

Change the minimum canonical source, displayed block, prose, and verifier needed
to answer the existing reader question better. Do not add adjacent `lib-ash`
features or general library infrastructure.

#### Step 4: Verify and review the separate change

Run the lesson-local verifier, full Learn aggregate, Markdownlint over every
changed Markdown file, the relative-link check, and `git diff --check`. Review
the diff first for specification compliance and then for instructional quality.
Fix every Critical or Important finding and rerun affected checks.

#### Step 5: Commit only the enhancement

```bash
git add content/learn/<lesson> \
    docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git commit -m "docs: strengthen <lesson concept> with lib-ash"
```

Expected: the commit follows, rather than contains, the minimal migration and
changes no other lesson or project state.

### Task 6: Migrate the polymorphism lesson and kind rejection

**Files:**

- Restore: `content/learn/definitions-for-many-types/`
- Modify: `content/checks/lib.sh`
- Modify: `content/learn/definitions-for-many-types/README.md`
- Modify: `content/learn/definitions-for-many-types/checks/verify.sh`
- Modify: `content/learn/README.md`
- Modify: `docs/project/beginning-learning-path.md`
- Modify: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Re-run the predecessor evidence

```bash
bash \
    /home/dikini/.config/superpowers/worktrees/ash-doc/recursive-1-pin/content/learn/definitions-for-many-types/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: five sources pass, including status `1` and first reason
`resolve.type-argument-count` for `src/04-unsaturated-list.ash`.

#### Step 2: Restore exact source and observe the expected diagnostic change

Restore the lesson from `recursive-1`:

```bash
git restore --source=recursive-1 -- \
    content/learn/definitions-for-many-types
```

Then run its unchanged verifier at Lib Ash.

First observe the compiler directly without relying on the old verifier:

```bash
(
    set -euo pipefail
    kind_observation_dir=$(mktemp -d \
        "${TMPDIR:-/tmp}/ash-doc-kind-observation.XXXXXX")
    readonly kind_observation_dir
    trap 'rm -rf -- "$kind_observation_dir"' EXIT
    readonly kind_stdout="$kind_observation_dir/stdout"
    readonly kind_stderr="$kind_observation_dir/stderr"
    if /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin/target/debug/ash \
        content/learn/definitions-for-many-types/src/04-unsaturated-list.ash \
        > "$kind_stdout" 2> "$kind_stderr"; then
        kind_status=0
    else
        kind_status=$?
    fi
    readonly kind_status
    test "$kind_status" -eq 1
    test ! -s "$kind_stdout"
    test "$(sed -n '1p' "$kind_stderr")" = kind.expected-type
    grep -Fq \
        'primary: source 0 56..60: this function domain must have kind Type' \
        "$kind_stderr"
    grep -Fq \
        'related: source 0 0..47: the found kind is fixed by this declaration' \
        "$kind_stderr"
    grep -Fq 'expected Type' "$kind_stderr"
    grep -Fq 'found Type -> Type' "$kind_stderr"
)
```

Expected: every assertion passes and the temporary observation directory is
removed by the trap.

Now run the unchanged lesson verifier:

```bash
bash content/learn/definitions-for-many-types/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

Expected RED: `src/04-unsaturated-list.ash` still exits `1` with empty standard
output, but its first reason is `kind.expected-type`, not
`resolve.type-argument-count`. Standard error includes:

```text
primary: source 0 56..60: this function domain must have kind Type
related: source 0 0..47: the found kind is fixed by this declaration
expected Type
found Type -> Type
```

If status becomes `2`, standard output is nonempty, or the reason is not the
specified kind rejection, create a new compiler-failure lab record before
continuing.

#### Step 3: Write the helper test before changing the helper

Change only the lesson verifier call to:

```bash
ash_doc_run_rejected \
    "$unit_root" \
    src/04-unsaturated-list.ash \
    kind.expected-type \
    'primary: source 0 56..60: this function domain must have kind Type' \
    1 \
    'related: source 0 0..47: the found kind is fixed by this declaration' \
    'expected Type' \
    'found Type -> Type'
```

Run the lesson verifier.

Expected RED: the shared helper reports that `ash_doc_run_rejected` requires
exactly five arguments. This establishes the need to retain more than one
causal evidence phrase.

#### Step 4: Generalize only the rejection-evidence arity

In `content/checks/lib.sh`, change the guard to accept at least five arguments.
Keep the first five meanings unchanged. After assigning the expected status,
shift five arguments and check every remaining phrase with `grep -Fq`; fail
with a message that names the missing phrase. Existing five-argument callers
must remain valid.

Do not change status, standard-output, or first-reason behavior.

#### Step 5: Teach the existing kind boundary

Keep `src/04-unsaturated-list.ash` byte-identical to the predecessor. In the
lesson's existing “When a complete type is required” discussion, explain:

- `List` is a type constructor with kind `Type -> Type`;
- function parameter and result positions require a type of kind `Type`;
- `List<Int>` applies the constructor and has kind `Type`; and
- the rejection is `kind.expected-type`, with expected `Type` and found
  `Type -> Type`.

Link the conclusion to the exact `lib-ash` specification section
`spec/static-semantics.md#kinds-monotypes-and-schemes`. Do not add a reusable
higher-kinded function, an interface, kind inference, or kind polymorphism;
those change the beginner lesson's question and belong in the future library
path.

#### Step 6: Restore final navigation and record the assessment

Add lesson 11 to the Learn index, restore every now-valid next/previous link in
the sequence, and mark all eleven entries verified in the beginning path.
Record the baseline as “accepted observations unchanged; specified rejection
reason changed to the explicit kind boundary.” Record the required prose and
verifier migration separately from the decision not to add a new abstraction.

#### Step 7: Run regression checks

```bash
bash -n content/checks/lib.sh \
    content/learn/definitions-for-many-types/checks/verify.sh
shellcheck --source-path=SCRIPTDIR content/checks/lib.sh \
    content/learn/definitions-for-many-types/checks/verify.sh
bash content/learn/definitions-for-many-types/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
markdownlint-cli2 content/learn/definitions-for-many-types/README.md \
    content/learn/README.md docs/project/beginning-learning-path.md \
    docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git diff --check
```

Expected: the lesson reports five sources, the aggregate reports eleven
lessons, all older five-argument rejection checks still pass, and prose checks
are clean.

#### Step 8: Commit the final Learn lesson

```bash
git add content/checks/lib.sh content/learn \
    docs/project/beginning-learning-path.md \
    docs/plans/2026-08-31-migrate-learn-to-lib-ash.md
git commit -m "docs: migrate polymorphism lesson to lib-ash"
```

### Task 7: Apply the compiler-failure gate to any new failure

This task is conditional and repeats immediately whenever an unexpected
compiler failure appears. It is not a compiler-fix task.

**Files:**

- Create: `lab/lib-ash-migration/<failure>/README.md`
- Create: `lab/lib-ash-migration/<failure>/checks/verify.sh`
- Create: exact triggering sources and fixtures under that failure directory
- Modify: `lab/lib-ash-migration/README.md`
- Modify: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Stop before changing the triggering teaching source

Retain the exact source, command, both Ash identities, exit status, standard
output, and standard error. Re-run once from a clean pin to exclude a dirty
checkout or stale binary.

#### Step 2: Challenge the classification

Compare the result with the exact `lib-ash` specification and tool guide:

- a specified source rejection remains lesson evidence;
- a mismatch with specified behavior is an Ash regression candidate;
- an unspecified semantic question returns to Ash design; and
- diagnostic or resource behavior remains tool evidence.

Do not infer language truth from predecessor acceptance alone.

#### Step 3: Add the smallest permanent executable record

Use the same two-pin structure and observation discipline as Task 3. Minimize
only when minimization improves attribution, and retain the original source as
well. Name the blocked lesson and wider reader task. State no compiler fix.

#### Step 4: Decide whether migration can continue

If the failure blocks specified behavior required by the lesson, leave the
lesson inactive and report the milestone blocked by upstream Ash. If a
separately justified teaching migration no longer needs the triggering source,
continue only after the permanent lab passes; never delete the evidence.

### Task 8: Close the Learn outcome and promote Cases planning

**Files:**

- Modify: `README.md`
- Modify: `content/README.md`
- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-31-migrate-learn-to-lib-ash.md`

#### Step 1: Audit the migration record before deleting it

Confirm all eleven rows contain actual dual-pin baseline results, minimal
migration results, and enhancement assessments. Confirm every unexpected
compiler failure encountered has a linked passing lab. Commit a correction
before closure if any result says only “pending” or lacks evidence.

#### Step 2: Make the final Outcome 1 project state accurate

Update root and content indexes to say the complete eleven-lesson Learn path is
active and verified at exact `lib-ash`. Cases remains absent from active
content and available at immutable `recursive-1` pending migration.

In the roadmap:

- mark Learn migration verified with the exact source count of 43;
- summarize required changes and all no-change enhancement decisions;
- link permanent compiler-failure evidence;
- promote only Cases migration to `next`;
- leave the library path provisional; and
- name the next required bounded Cases design/plan work.

Remove this implementation plan. Retain the milestone design until the entire
`lib-ash` milestone closes.

#### Step 3: Run complete source and repository verification

```bash
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash \
    lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
find content lab -type f -path '*/checks/*.sh' -print0 | \
    xargs -0 -n1 bash -n
shellcheck content/checks/lib.sh content/learn/checks/verify.sh \
    content/learn/*/checks/verify.sh \
    lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh
test "$(find content/learn -type f -name '*.ash' | wc -l)" -eq 43
test "$(find content/learn -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l)" -eq 11
test ! -e content/cases
markdownlint-cli2 '**/*.md'
git diff --check
git status --short
```

Expected: eleven lessons and 43 canonical Learn sources pass at Lib Ash; three
failure records pass across both pins; shell syntax, ShellCheck, Markdown, and
whitespace checks pass. Before commit, status contains only closure prose and
the deleted temporary plan.

Run a read-only relative-link checker over every Markdown file and inspect all
remaining `modular-ash` and old-commit matches. Historical comparison and
immutable predecessor references are allowed; active target, active setup, and
current verification references are not. Reuse the exact Python link command
from Task 4 Step 7 so closure and cutover apply the same rule.

#### Step 4: Perform three reviews

Review the full branch diff against `727790af6fdb8020cf69b3db9d68cd0213df244e`
in this order:

1. authority/specification review: exact pin, language claims, tool claims,
   compiler-failure classification;
2. instructional/workflow review: sequential learner model, active navigation,
   minimal migrations, enhancement decisions, historical recovery; and
3. whole-branch review: scope, source agreement, checks, links, exclusions,
   absence of Cases and library implementation.

Any correction invalidates the affected verification. Apply it, rerun the
applicable local and aggregate commands, then repeat the relevant review.

#### Step 5: Commit Outcome 1 closure

```bash
git add -A
git commit -m "docs: verify lib-ash Learn migration"
git status --short
```

Expected: one unsigned closure commit and a clean feature worktree.

### Task 9: Integrate the verified outcome into local main

**Files:** none beyond the verified branch history.

#### Step 1: Confirm both worktrees are clean and main has not diverged

```bash
git status --short
git -C /home/dikini/Projects/ash-doc status --short
git merge-base --is-ancestor \
    727790af6fdb8020cf69b3db9d68cd0213df244e \
    migrate-learn-to-lib-ash
```

Expected: both statuses are silent and the ancestry command exits `0`. If main
has new commits, stop and review them before integration.

#### Step 2: Fast-forward local main

From `/home/dikini/Projects/ash-doc`:

```bash
git merge --ff-only migrate-learn-to-lib-ash
```

Expected: a fast-forward retaining the task-by-task history. Do not squash,
tag, or push.

#### Step 3: Re-run closure from merged main

Repeat Task 8 Step 3 from `/home/dikini/Projects/ash-doc`, then run:

```bash
git status --short
git log -1 --oneline
```

Expected: all checks pass, main is clean, and the final commit is
`docs: verify lib-ash Learn migration`.

#### Step 4: Remove only the completed feature worktree and branch

After merged-main verification succeeds:

```bash
git worktree remove \
    /home/dikini/Projects/ash-doc/.worktrees/migrate-learn-to-lib-ash
git branch -d migrate-learn-to-lib-ash
```

Retain both exact Ash checkouts and the detached `recursive-1` documentation
checkout for the following Cases migration. Report the final main commit,
verification results, permanent failure labs, next roadmap outcome, and that no
push or `lib-ash` documentation tag occurred.
