# Accumulating list results implementation plan

<!-- markdownlint-disable-next-line MD013 -->
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Publish one verified Cases chapter that compares append-based and
accumulator reversal, exposes their different source work, and derives the
accumulator invariant without promising implementation-level stack behavior.

**Architecture:** Add one lesson-local `lists` module containing ordinary
append, reverse, and strict left-fold definitions beside two narrowly counted
mirrors. Four complete entries separately observe equal results, six append
revisits versus four accumulator visits, one invariant midpoint, and an
accepted wrong initial accumulator. A local verifier checks the exact pinned
outputs, displayed-source agreement, and every source relationship used by the
cost and invariant explanations.

**Tech stack:** Markdown, Ash, Bash, ShellCheck, Git, and the `ash` executable
built from exact Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Execution boundary

Work only in the `accumulating-list-results` branch and its existing worktree.
Use the clean pinned checkout at
`/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin` for
every executable observation. Do not change the edition target, the immutable
`modular-ash` tag, shared content infrastructure, or `ash-lang`.

The reader asks when recursion should retain knowledge from earlier elements.
The observable boundary crosses from a completed recursive result into
repeated append traversal, then to a next accumulator passed into a final
recursive call. Counts name source-level `More` visits; tail position names
source placement. Neither claim specifies elapsed time, heap bytes, host-stack
use, compiler optimization, mutation, or tail-call optimization.

## Task 1: Add the case verifier and establish red

**Files:**

- Create: `content/cases/accumulating-list-results/checks/verify.sh`

### Step 1: Create the executable verifier

Add a Bash verifier with `set -euo pipefail`. Derive `unit_root` and
`content_root` exactly as the preceding case does, source
`content/checks/lib.sh`, require one pinned Ash checkout argument, call
`ash_doc_prepare`, and declare these five canonical sources in order:

```bash
readonly sources=(
    src/lists.ash
    src/01-same-result.ash
    src/02-counted-work.ash
    src/03-accumulator-invariant.ash
    src/04-wrong-initial-accumulator.ash
)
```

After `ash_doc_check_sources`, add the same lesson-local `ash_doc_section`,
`ash_doc_assert_word_count`, and `ash_doc_assert_phrase_count` helpers used by
the two preceding cases. Extract sections by adjacent signatures for
`append`, `reverse_through_append`, the private `append_revisits` and
`reverse_revisits` helpers, `fold_left`, `prepend`,
`reverse_with_accumulator`, the private `fold_left_visits` helper, and the two
public counted wrappers.

Assert these causal source relationships:

- `append` returns `right` for `Empty`, recurses exactly once over the left
  operand's `rest`, binds the appended rest, and constructs one copied
  `More(first, appended_rest)` after that result;
- append-based reverse recursively obtains `reversed_rest`, then calls
  `append reversed_rest (More(first, Empty))` exactly once;
- `append_revisits` returns zero at `Empty`, recurses over the left operand's
  `rest`, and adds one for every copied left-hand `More`;
- `reverse_revisits` applies the counted append to each recursively reversed
  rest and adds `earlier_revisits + current_revisits`;
- `fold_left` computes `next_accumulated = combine accumulated first`, then
  uses `fold_left combine next_accumulated rest` as the block's final
  expression, with no source operation after that call;
- `prepend` constructs exactly `More(first, accumulated)`, ordinary
  accumulator reverse uses `fold_left prepend Empty list`, and its counted
  mirror adds exactly one input visit per `More` before the final recursive
  call;
- the counted entry supplies the same four-element list to both mirrors;
- the invariant entry derives `accumulated` by folding the processed prefix,
  then derives `complete` by continuing the same fold over the remaining
  suffix; and
- the counterexample passes `More(99, Empty)` as the initial accumulator
  rather than changing the element type.

Add these four accepted observations:

```bash
readonly reversed='More(4, More(3, More(2, More(1, Empty))))'
readonly counted_output="(($reversed, 6), ($reversed, 4)) : "\
'((List<Int>, Int), (List<Int>, Int))'
readonly invariant_output='(More(1, More(2, Empty)), '\
'More(2, More(1, Empty)), '\
'More(4, More(3, More(2, More(1, Empty))))) : '\
'(List<Int>, List<Int>, List<Int>)'

ash_doc_run_accepted \
    "$unit_root" \
    src/01-same-result.ash \
    "($reversed, $reversed) : (List<Int>, List<Int>)"
ash_doc_run_accepted \
    "$unit_root" \
    src/02-counted-work.ash \
    "$counted_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/03-accumulator-invariant.ash \
    "$invariant_output"
ash_doc_run_accepted \
    "$unit_root" \
    src/04-wrong-initial-accumulator.ash \
    'More(4, More(3, More(2, More(1, More(99, Empty))))) : List<Int>'

Finish with `ash_doc_finish 5`. This case has no rejected program: its negative
observation is a well-typed result that violates the intended invariant.

### Step 2: Make the verifier executable and check its shell syntax

Run:

```bash
chmod +x content/cases/accumulating-list-results/checks/verify.sh
bash -n content/cases/accumulating-list-results/checks/verify.sh
shellcheck -x content/cases/accumulating-list-results/checks/verify.sh
```

Expected: all three commands exit `0` without output.

### Step 3: Run the new verifier and confirm red

Run:

```bash
bash content/cases/accumulating-list-results/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: status `1` with `verify: missing unit README.md`. This proves the
aggregated runtime and source contract exists before the implementation.

Do not commit the deliberately red state.

## Task 2: Implement and directly observe the canonical Ash programs

**Files:**

- Create: `content/cases/accumulating-list-results/src/lists.ash`
- Create: `content/cases/accumulating-list-results/src/01-same-result.ash`
- Create: `content/cases/accumulating-list-results/src/02-counted-work.ash`
- Create: `content/cases/accumulating-list-results/src/03-accumulator-invariant.ash`
- Create: `content/cases/accumulating-list-results/src/04-wrong-initial-accumulator.ash`

### Step 1: Add the shared module

Write this complete module:

```ash
pub type List<A> =
    Empty
    | More(A, List<A>)

pub append : List<A> -> List<A> -> List<A>
append Empty right = right
append More(first, rest) right = {
    let appended_rest = append rest right
    More(first, appended_rest)
}

pub reverse_through_append : List<A> -> List<A>
reverse_through_append Empty = Empty
reverse_through_append More(first, rest) = {
    let reversed_rest = reverse_through_append rest
    append reversed_rest (More(first, Empty))
}

append_revisits : List<A> -> List<A> -> (List<A>, Int)
append_revisits Empty right = (right, 0)
append_revisits More(first, rest) right = {
    let (appended_rest, later_revisits) = append_revisits rest right
    (More(first, appended_rest), later_revisits + 1)
}

reverse_revisits : List<A> -> (List<A>, Int)
reverse_revisits Empty = (Empty, 0)
reverse_revisits More(first, rest) = {
    let (reversed_rest, earlier_revisits) = reverse_revisits rest
    let singleton = More(first, Empty)
    let (reversed, current_revisits) = append_revisits reversed_rest singleton
    (reversed, earlier_revisits + current_revisits)
}

pub reverse_through_append_with_revisits : List<A> -> (List<A>, Int)
reverse_through_append_with_revisits list = reverse_revisits list

pub fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated Empty = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

pub prepend : List<A> -> A -> List<A>
prepend accumulated first = More(first, accumulated)

pub reverse_with_accumulator : List<A> -> List<A>
reverse_with_accumulator list = fold_left prepend Empty list

fold_left_visits : (B -> A -> B) -> B -> Int -> List<A> -> (B, Int)
fold_left_visits combine accumulated visits Empty = (accumulated, visits)
fold_left_visits combine accumulated visits More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left_visits combine next_accumulated (visits + 1) rest
}

pub reverse_with_accumulator_and_visits : List<A> -> (List<A>, Int)
reverse_with_accumulator_and_visits list = fold_left_visits prepend Empty 0 list
```

The `singleton` binding keeps the counted mirror's constructor and append
arguments visible on separate source lines. The verifier must assert both the
binding and the following counted append application.

Keep all counted helpers private and lesson-local. Do not add a shared list
library, mutation, a direct `reverse_onto` traversal, runtime timing, or a
generic instrumentation framework.

### Step 2: Add the four complete entries

Write `src/01-same-result.ash`:

```ash
import lists as Lists

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    (Lists.reverse_through_append numbers, Lists.reverse_with_accumulator numbers)
}
```

Write `src/02-counted-work.ash`:

```ash
import lists as Lists

main : Unit -> ((Lists.List<Int>, Int), (Lists.List<Int>, Int))
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    (
        Lists.reverse_through_append_with_revisits numbers,
        Lists.reverse_with_accumulator_and_visits numbers
    )
}
```

Write `src/03-accumulator-invariant.ash`:

```ash
import lists as Lists

main : Unit -> (Lists.List<Int>, Lists.List<Int>, Lists.List<Int>)
main () = {
    let processed = Lists.More(1, Lists.More(2, Lists.Empty))
    let remaining = Lists.More(3, Lists.More(4, Lists.Empty))
    let accumulated = Lists.fold_left Lists.prepend Lists.Empty processed
    let complete = Lists.fold_left Lists.prepend accumulated remaining
    (processed, accumulated, complete)
}
```

Write `src/04-wrong-initial-accumulator.ash`:

```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    Lists.fold_left Lists.prepend (Lists.More(99, Lists.Empty)) numbers
}
```

Long expressions may remain over 80 columns in canonical Ash sources. In the
chapter, disable Markdown rule MD013 only for the exact displayed source lines;
do not reformat a canonical block into source text that the pin has not run.

### Step 3: Run every entry directly against the exact pin

Use the already-built binary if present, or run `cargo build --locked` in the
pinned checkout first. Then run from the new case directory:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
"$ASH_DOC_PIN/target/debug/ash" src/01-same-result.ash
"$ASH_DOC_PIN/target/debug/ash" src/02-counted-work.ash
"$ASH_DOC_PIN/target/debug/ash" src/03-accumulator-invariant.ash
"$ASH_DOC_PIN/target/debug/ash" src/04-wrong-initial-accumulator.ash
```

Expected output is exactly the four strings from Task 1, and every command
must exit `0` with empty standard error.

If pinned behavior differs, stop and classify the difference before changing
the lesson contract. Fix an ash-doc mistake against the pin; do not infer new
language behavior from current `ash-lang/main`.

## Task 3: Write the chapter and make its evidence green

**Files:**

- Create: `content/cases/accumulating-list-results/README.md`
- Test: `content/cases/accumulating-list-results/checks/verify.sh`

### Step 1: Write the chapter around the observed boundary

Title the chapter `When should recursion retain knowledge from earlier
elements?` Continue directly from the preceding unfold case's changing-state
question. Include these sections in one causal teaching path:

1. Reintroduce the finite `List<A>` representation and show ordinary `append`.
   Explain that only its left operand is traversed and copied; `right` is
   returned unchanged at `Empty`.
2. Show append-based reverse and derive its four-element result. Make strict
   recursive-rest evaluation explicit: the rest is reversed before append
   traverses the already-built result.
3. Run the counted pair. Derive append left-operand lengths `0`, `1`, `2`, and
   `3`, hence six extra revisits. State separately that the reverse recursion
   also visits four original input nodes, for ten named inspections in this
   example.
4. Generalize to input length `n`: append revisits
   `0 + ... + (n - 1) = n * (n - 1) / 2` prior output nodes and constructs
   `n + n * (n - 1) / 2` result or intermediate `More` values. Explain why
   those counts grow quadratically without treating source operations as a
   runtime clock.
5. Introduce `fold_left`, `prepend`, and accumulator reverse. Explain that
   each original `More` is visited once and one new `More` is constructed per
   visit, so both named counts are linear.
6. Derive the invariant at `fold_left prepend accumulated remaining`:
   `accumulated` is the reverse of the processed prefix, and the original is
   that prefix followed by `remaining`. Use initialization, one preservation
   step, and the `Empty` ending argument, then run the executable midpoint.
7. Run the wrong-initial-accumulator entry. Explain that `List<Int>` checks the
   representation but does not establish which elements the accumulator must
   contain; `[99]` remains at the end of the accepted result.
8. Point to `fold_left combine next_accumulated rest` as the equation's final
   source expression and define that placement as tail position. State that
   pinned Ash promises neither tail-call optimization nor constant host-stack
   space and that no mutation or in-place reversal occurs.
9. End with practice tracing the invariant after each element of `[5, 6, 7]`
   and predicting both counted algorithms. Open the next question: what does
   lookup cost when a dictionary is a recursive list?

Transclude all five canonical sources with unique
`<!-- source: src/... -->` markers. Make each displayed `ash` block byte-for-
byte identical to its source. Mark commands, output, algebra, and invariant
states as `text`.

Link semantic conclusions close to these pinned specification sections:

- static functions and application for higher-order `fold_left` and shared
  type variables;
- static patterns and matches for the two list forms;
- global definitions for recursive scope;
- dynamic bindings for completion of reversed rest and next accumulator;
- dynamic application for calls and constructor applications; and
- dynamic constructors and tuples for the observed values and counts.

Use the existing [*How to Design Programs* research
record](../../../research/how-to-design-programs-recursive-algorithms.md) for
the accumulator-invariant and cost-comparison tradition. Attribute inspiration
without copying or adapting its prose, programs, exercises, diagrams, or
curriculum; retain its recorded CC BY-NC-ND boundary.

### Step 2: Read the chapter and every canonical source as source

Run:

```bash
sed -n '1,440p' content/cases/accumulating-list-results/README.md
for source in content/cases/accumulating-list-results/src/*.ash; do
    printf '%s\n' "$source"
    sed -n '1,240p' "$source"
done
```

Expected: every program is complete; the prose distinguishes pinned language
facts, source-derived work, and excluded implementation behavior; and no
rendered project administration appears in the lesson.

### Step 3: Run the local verifier and make it green

Run:

```bash
bash content/cases/accumulating-list-results/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected:

```text
Verified 5 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

### Step 4: Check prose and shell structure

Run:

```bash
npx --yes markdownlint-cli2 \
    content/cases/accumulating-list-results/README.md
bash -n content/cases/accumulating-list-results/checks/verify.sh
shellcheck -x content/cases/accumulating-list-results/checks/verify.sh
git diff --check
```

Expected: every command exits `0` with no findings.

### Step 5: Commit the complete verified case

Run:

```bash
git add content/cases/accumulating-list-results
git commit --no-gpg-sign -m "docs: teach accumulating list results"
```

Do not commit unless the local verifier is green.

## Task 4: Integrate the case and advance the roadmap

**Files:**

- Modify: `content/cases/README.md`
- Modify: `README.md`
- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-30-accumulating-list-results-design.md`
- Delete: `docs/plans/2026-08-30-accumulating-list-results.md`

### Step 1: Add the case to reader navigation

Add the new chapter as item 3 under `Cases in order`. Its summary should say
that accumulator state avoids repeated append traversal while preserving the
same reversed value. In the root README, extend the recursive-algorithms
paragraph with the third case's comparison of repeated rebuilding and retained
knowledge.

Do not repeat the edition target in the case index or lesson prose; they
inherit it from the root README.

### Step 2: Close the roadmap increment

Move `Accumulating list results` under `Verified increments` as item 3. Record:

- five canonical sources and displayed blocks;
- four exact accepted observations, including six append revisits, four input
  visits, one invariant midpoint, and the wrong initial accumulator;
- the source-derived quadratic and linear counts and the tail-position
  boundary;
- exact verification at
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`; and
- intentional exclusion of elapsed time, heap bytes, host-stack behavior,
  compiler optimization, mutation, and a type-level invariant proof.

Promote `A dictionary encoded as a list` from provisional item 4 to
`## Next: a dictionary encoded as a list`. Restore the standard gate: its
bounded design and temporary implementation plan are required before content
work. Leave cases 5 through 12 provisional and preserve their order. Keep the
recursive-algorithms design link as the governing path record.

Update the current-edition repository-state sentence to say the three verified
recursive-algorithm cases remain unpublished on `main`.

### Step 3: Remove the completed temporary records

Delete both accumulator plans only after the case, navigation, and roadmap
closure are complete:

```text
docs/plans/2026-08-30-accumulating-list-results-design.md
docs/plans/2026-08-30-accumulating-list-results.md
```

Git history retains their decisions. Confirm that no live link still names
either deleted plan.

### Step 4: Check Markdown, spelling, and local links

Run:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then typos; fi
while IFS= read -r file; do
    while IFS= read -r target; do
        link_path=${target%%#*}
        [[ -z $link_path || $link_path == http://* ]] && continue
        [[ $link_path == https://* ]] && continue
        [[ -e "$(dirname "$file")/$link_path" ]] || {
            printf 'broken relative link: %s -> %s\n' "$file" "$target" >&2
            exit 1
        }
    done < <(
        awk '
            /^```/ { fenced = !fenced; next }
            !fenced {
                remaining = $0
                while (match(remaining, /\]\([^)]*\)/)) {
                    print substr(remaining, RSTART + 2, RLENGTH - 3)
                    remaining = substr(remaining, RSTART + RLENGTH)
                }
            }
        ' "$file"
    )
done < <(rg --files -g '*.md')
git diff --check
```

Expected: no Markdown, spelling, relative-link, or whitespace finding.

### Step 5: Commit integration and roadmap closure

Run:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md docs/plans
git commit --no-gpg-sign -m "docs: verify accumulating list results case"
```

## Task 5: Review, verify, and integrate the branch

**Files:**

- Review: all changes from `main...accumulating-list-results`

### Step 1: Request a focused code and documentation review

Use `superpowers:requesting-code-review` with an xhigh reviewer agent. Ask it
to check the complete branch diff against the approved design, pinned semantic
and tool authority, executable evidence, TDD assertions, teaching sequence,
cost derivations, accumulator invariant, attribution and license boundary,
intentional exclusions, navigation, and roadmap closure. Apply only
technically verified findings, using `superpowers:receiving-code-review` when
feedback requires changes.

### Step 2: Run exact final verification

Use `superpowers:verification-before-completion`. Run from the feature
worktree:

```bash
bash -n content/cases/accumulating-list-results/checks/verify.sh
shellcheck -x content/cases/accumulating-list-results/checks/verify.sh
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then typos; fi
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
git diff --check main...HEAD
git status --short --branch
```

Expected: eleven Learn lessons pass; three Cases chapters and fifteen
canonical Case sources pass at the exact pin; all static checks pass; and the
feature worktree is clean.

Inspect `git diff --stat main...HEAD`, `git diff main...HEAD`, and every changed
file as source. Confirm `modular-ash` still resolves to
`e963a1597176f86003926eef827498db2a661b75`, while the pinned Ash checkout still
resolves to `dca16039923475c48025c5f17beadeb6bcb6a4bf` and is clean.

### Step 3: Merge locally and verify the merge result

Use `superpowers:finishing-a-development-branch`. Because the user's request
already authorizes autonomous local integration, merge the feature branch into
local `main` without pushing:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    accumulating-list-results
```

If `main` moved, inspect the new commits and re-run affected verification
before merging. After the merge, run both full content aggregators and
`git diff --check origin/main...main` from the main worktree. Confirm the main
worktree is clean and the immutable documentation tag did not move.

### Step 4: Remove the merged worktree and branch

Only after the merge result verifies, remove the isolated worktree and delete
the merged local branch:

```bash
git -C /home/dikini/Projects/ash-doc worktree remove \
    /home/dikini/Projects/ash-doc/.worktrees/accumulating-list-results
git -C /home/dikini/Projects/ash-doc branch -d accumulating-list-results
```

Do not report the full remaining-cases goal complete after this case. Report
the local main commit, exact Ash pin, verification totals, unpublished status,
and that no push occurred, then begin the newly promoted dictionary case.
