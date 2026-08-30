# Building finite lists implementation plan

<!-- markdownlint-disable-next-line MD013 -->
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Publish one verified Cases chapter that shows how a structurally
decreasing finite state produces a recursive list with `unfold`, makes its
transition work and eager construction observable, and preserves the boundary
between one terminating producer and generic termination.

**Architecture:** Add one lesson-local `lists` module with `Natural`, `List`,
`Step`, ordinary and counted unfold functions, ordinary `map`, and one finite
transition. Four complete entries observe production, transition count,
following map construction, and a rejected seed. A local verifier reuses the
shared content helper and asserts both runtime evidence and the causal source
relationships used by the prose.

**Tech stack:** Markdown, Bash, ShellCheck, Git, and the `ash` executable built
from exact Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Execution boundary

Work only in the `finite-list-unfold` branch and its existing worktree. Use the
clean pinned checkout at
`/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin` for
every executable observation. Do not change the edition target, the immutable
`modular-ash` tag, shared content infrastructure, or `ash-lang`.

The reader asks how changing finite state can produce recursive data. The
observable boundary crosses from a transition result into a new `List<A>`:
each `Emit` supplies one value and next state, `Stop` ends production, and
pinned eager evaluation completes the recursive rest before the outer `More`
is constructed. The termination proof belongs to the concrete transition that
follows `Natural.rest`; it is not supplied by Ash's types or generic `unfold`.

## Task 1: Add the case verifier and establish red

**Files:**

- Create: `content/cases/building-finite-lists/checks/verify.sh`

### Step 1: Create the executable verifier

Add a Bash verifier with `set -euo pipefail`. Derive `unit_root` and
`content_root` exactly as the preceding case does, source
`content/checks/lib.sh`, require one pinned Ash checkout argument, call
`ash_doc_prepare`, and declare these five canonical sources in order:

```bash
readonly sources=(
    src/lists.ash
    src/01-unfold.ash
    src/02-counted-unfold.ash
    src/03-map-produced-list.ash
    src/04-wrong-seed.ash
)
```

After `ash_doc_check_sources`, add the same lesson-local
`ash_doc_section`, `ash_doc_assert_word_count`, and
`ash_doc_assert_phrase_count` helpers used by the folding case. Extract
sections for `unfold`, `unfold_counted`, `map`, and `repeat_step` by their
adjacent public signatures.

Assert these source relationships:

- ordinary `unfold` has one `match transition state`, one `Stop => Empty`, one
  recursive call on `next_state`, one binding of the produced rest, and one
  `More(value, produced_rest)`;
- counted unfold has the same single transition and recursive-call shape,
  returns `(Empty, 1)` for `Stop`, and adds exactly one with
  `later_steps + 1` after the recursive result;
- `map` recurses once on `rest`, binds the mapped rest, and constructs exactly
  one `More(transform first, mapped_rest)` in its nonempty equation;
- `repeat_step` has exactly the equations `repeat_step value Zero = Stop` and
  `repeat_step value Next(rest) = Emit(value, rest)`; and
- the third entry binds `produced` before applying `map`, then returns both
  `(produced, mapped)`.

Add three accepted observations:

```bash
readonly mapped_output='(More(42, More(42, More(42, Empty))), '\
'More(43, More(43, More(43, Empty)))) : (List<Int>, List<Int>)'

ash_doc_run_accepted \
    "$unit_root" \
    src/01-unfold.ash \
    'More(42, More(42, More(42, Empty))) : List<Int>'
ash_doc_run_accepted \
    "$unit_root" \
    src/02-counted-unfold.ash \
    '(More(42, More(42, More(42, Empty))), 4) : (List<Int>, Int)'
ash_doc_run_accepted \
    "$unit_root" \
    src/03-map-produced-list.ash \
    "$mapped_output"
```

Add four rejection checks for `src/04-wrong-seed.ash`: first reason
`type.argument`; text `this argument does not match the function domain`;
`expected Natural`; `found Bool`; and primary source span
`primary: source 0 100..104:`. Each must expect status `1`. Finish with
`ash_doc_finish 5`.

### Step 2: Make the verifier executable and check its shell syntax

Run:

```bash
chmod +x content/cases/building-finite-lists/checks/verify.sh
bash -n content/cases/building-finite-lists/checks/verify.sh
shellcheck -x content/cases/building-finite-lists/checks/verify.sh
```

Expected: all three commands exit `0` without output.

### Step 3: Run the new verifier and confirm red

Run:

```bash
bash content/cases/building-finite-lists/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: status `1` with `verify: missing unit README.md`. This proves the
aggregated runtime and source contract exists before the implementation.

Do not commit the deliberately red state.

## Task 2: Implement and directly observe the canonical Ash programs

**Files:**

- Create: `content/cases/building-finite-lists/src/lists.ash`
- Create: `content/cases/building-finite-lists/src/01-unfold.ash`
- Create: `content/cases/building-finite-lists/src/02-counted-unfold.ash`
- Create: `content/cases/building-finite-lists/src/03-map-produced-list.ash`
- Create: `content/cases/building-finite-lists/src/04-wrong-seed.ash`

### Step 1: Add the shared module

Write this complete module:

```ash
pub type Natural =
    Zero
    | Next(Natural)

pub type List<A> =
    Empty
    | More(A, List<A>)

pub type Step<S, A> =
    Stop
    | Emit(A, S)

pub unfold : (S -> Step<S, A>) -> S -> List<A>
unfold transition state = match transition state {
    Stop => Empty
    Emit(value, next_state) => {
        let produced_rest = unfold transition next_state
        More(value, produced_rest)
    }
}

pub unfold_counted : (S -> Step<S, A>) -> S -> (List<A>, Int)
unfold_counted transition state = match transition state {
    Stop => (Empty, 1)
    Emit(value, next_state) => {
        let (produced_rest, later_steps) = unfold_counted transition next_state
        (More(value, produced_rest), later_steps + 1)
    }
}

pub map : (A -> B) -> List<A> -> List<B>
map transform Empty = Empty
map transform More(first, rest) = {
    let mapped_rest = map transform rest
    More(transform first, mapped_rest)
}

pub repeat_step : Int -> Natural -> Step<Natural, Int>
repeat_step value Zero = Stop
repeat_step value Next(rest) = Emit(value, rest)
```

The explicit recursive bindings make the evaluation relationship visible.
Do not add a generic library, lazy producer, infinite data, or another
instrumented map API.

### Step 2: Add the four complete entries

Write `src/01-unfold.ash`:

```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    Lists.unfold (Lists.repeat_step 42) three
}
```

Write `src/02-counted-unfold.ash`:

```ash
import lists as Lists

main : Unit -> (Lists.List<Int>, Int)
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    Lists.unfold_counted (Lists.repeat_step 42) three
}
```

Write `src/03-map-produced-list.ash`:

```ash
import lists as Lists

increment : Int -> Int
increment value = value + 1

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    let produced = Lists.unfold (Lists.repeat_step 42) three
    let mapped = Lists.map increment produced
    (produced, mapped)
}
```

Write `src/04-wrong-seed.ash`:

```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = Lists.unfold (Lists.repeat_step 42) true
```

### Step 3: Run every entry directly against the exact pin

Use the already-built binary if present, or run `cargo build --locked` in the
pinned checkout first. Then run from the new case directory:

```bash
ASH_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
"$ASH_PIN/target/debug/ash" src/01-unfold.ash
"$ASH_PIN/target/debug/ash" src/02-counted-unfold.ash
"$ASH_PIN/target/debug/ash" src/03-map-produced-list.ash
"$ASH_PIN/target/debug/ash" src/04-wrong-seed.ash
```

Expected successful output is exactly the three strings from Task 1. The
fourth command must write no standard output, begin standard error with
`type.argument`, include `expected Natural`, `found Bool`, and
`primary: source 0 100..104:`, and exit `1`.

If pinned behavior differs, stop and classify the difference before changing
the lesson contract. Fix an ash-doc mistake against the pin; do not infer new
language behavior from current `ash-lang/main`.

## Task 3: Write the chapter and make its evidence green

**Files:**

- Create: `content/cases/building-finite-lists/README.md`
- Test: `content/cases/building-finite-lists/checks/verify.sh`

### Step 1: Write the chapter around the observed boundary

Title the chapter `How can changing finite state produce a recursive list?`
Continue directly from the folding case's consume/produce contrast. Include
these sections in one causal teaching path:

1. Introduce `Natural`, `List`, and `Step`; explain state, `Stop`, and
   `Emit(value, next_state)` from the concrete producer.
2. Show ordinary `unfold` and derive the three-element result from three
   `Next` forms followed by `Zero`.
3. Show `unfold_counted`; explain why three emissions require four transition
   applications because the final application discovers `Stop`.
4. Explain the structural termination proof for `repeat_step`: every recursive
   state is the direct `rest` field and `Zero` stops. State separately that
   arbitrary transitions are not proven terminating. Describe an unchanged or
   growing-state danger in prose or a `text` block only; never run it and never
   label it executable Ash.
5. Use the third entry to show that strict binding completes `produced` before
   `map` starts, retains both lists in the result, and constructs a following
   three-node mapped representation. Reuse the preceding case's established
   `map` constructor account instead of introducing `map_counted`.
6. Show the complete Boolean-seed rejection and explain that
   `repeat_step 42` fixes `S` as `Natural` before `unfold` checks the seed.
7. End with practice defining
   `natural_step : Natural -> Step<Natural, Natural>` that emits the current
   `Next(rest)` value and continues with `rest`; ask for `Zero`, one-step, and
   three-step predictions plus the termination and `n + 1` transition
   arguments.
8. Open the next reader question: when should recursion retain knowledge from
   earlier elements?

Transclude all five canonical sources with unique
`<!-- source: src/... -->` markers. Make each displayed `ash` block byte-for-
byte identical to its source. Mark commands, output, derivations, and unsafe
non-running sketches as `text`.

Link semantic conclusions close to these pinned specification sections:

- static functions and application for the shared `S` and rejected seed;
- static patterns and matches for the three state/list forms;
- global definitions for recursive scope;
- dynamic bindings for completion of recursive rest and `produced`;
- dynamic application for transition, constructor, and `map` evaluation; and
- dynamic tuples, constructors, and matches for observation values and branch
  selection.

Keep claims at source level: for terminating inputs with `n` `Next` forms,
state `n + 1` transition applications, `n` produced `More` values, and `n`
additional mapped `More` values. Exclude elapsed time, exact heap bytes, host
stack behavior, compiler optimizations, lazy or infinite data, and generic
fold/build fusion. Preserve original prose; the existing research records
already cover the adapted structural-design and unfold traditions.

### Step 2: Read the chapter and every canonical source as source

Run:

```bash
sed -n '1,360p' content/cases/building-finite-lists/README.md
for source in content/cases/building-finite-lists/src/*.ash; do
    printf '%s\n' "$source"
    sed -n '1,220p' "$source"
done
```

Expected: every program is complete, the prose distinguishes language facts
from source-level derivations, and no rendered project administration appears
in the lesson.

### Step 3: Run the local verifier and make it green

Run:

```bash
bash content/cases/building-finite-lists/checks/verify.sh \
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
    content/cases/building-finite-lists/README.md
bash -n content/cases/building-finite-lists/checks/verify.sh
shellcheck -x content/cases/building-finite-lists/checks/verify.sh
git diff --check
```

Expected: every command exits `0` with no findings.

### Step 5: Commit the complete verified case

Run:

```bash
git add content/cases/building-finite-lists
git commit --no-gpg-sign -m "docs: teach finite list production"
```

Do not commit unless the local verifier is green.

## Task 4: Integrate the case and advance the roadmap

**Files:**

- Modify: `content/cases/README.md`
- Modify: `README.md`
- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-30-finite-list-unfold-design.md`
- Delete: `docs/plans/2026-08-30-building-finite-lists.md`

### Step 1: Add the case to reader navigation

Add the new chapter as item 2 under `Cases in order`. Its summary should say
that finite state, a transition, and a structural measure produce a complete
eager list. In the root README, replace the first-case-only paragraph with a
compact description of both verified cases: fold consumes a finite list;
unfold produces one from finite state and exposes its termination boundary.

Do not repeat the edition target in the lesson index or lesson prose; they
inherit it from the root README.

### Step 2: Close the roadmap increment

Move `Building finite lists with unfold` under `Verified increments` as item
2. Record:

- five canonical sources and displayed blocks;
- three exact successful observations and one complete `type.argument`
  rejection;
- the counted `n + 1` transition boundary, eager recursive-rest binding,
  following `map` representation, and structural termination argument;
- exact verification at
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`; and
- intentional exclusion of generic termination, lazy/infinite data, and
  fold/build fusion.

Promote `Accumulating list results` from provisional item 3 to
`## Next: accumulating list results`. Restore the standard design gate: its
bounded design and temporary implementation plan are required before content
work. Leave the remaining order unchanged and renumber its provisional items
from 4 through 11. Keep the recursive-algorithms design link as the governing
path record.

Update the current-edition repository-state sentence to say the verified
recursive-algorithm cases remain unpublished on `main`.

### Step 3: Remove the completed temporary records

Delete both unfold plans only after the case, navigation, and roadmap closure
are complete:

```text
docs/plans/2026-08-30-finite-list-unfold-design.md
docs/plans/2026-08-30-building-finite-lists.md
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
git commit --no-gpg-sign -m "docs: verify finite list unfold case"
```

## Task 5: Review, verify, and integrate the branch

**Files:**

- Review: all changes from `main...finite-list-unfold`

### Step 1: Request a focused code and documentation review

Use `superpowers:requesting-code-review` with a reviewer agent. Ask it to check
the complete branch diff against the approved design, pinned semantic and tool
authority, executable evidence, TDD assertions, teaching sequence, source
claims, exclusions, navigation, and roadmap closure. Apply only technically
verified findings, using `superpowers:receiving-code-review` when feedback
requires changes.

### Step 2: Run exact final verification

Use `superpowers:verification-before-completion`. Run from the feature
worktree:

```bash
bash -n content/cases/building-finite-lists/checks/verify.sh
shellcheck -x content/cases/building-finite-lists/checks/verify.sh
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then typos; fi
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
git diff --check main...HEAD
git status --short --branch
```

Expected: eleven Learn lessons pass; two Cases chapters and ten canonical Case
sources pass at the exact pin; all static checks pass; and the feature worktree
is clean.

Inspect `git diff --stat main...HEAD`, `git diff main...HEAD`, and every changed
file as source. Confirm `modular-ash` still resolves to `e963a15`, while the
pinned Ash checkout still resolves to
`dca16039923475c48025c5f17beadeb6bcb6a4bf` and is clean.

### Step 3: Merge locally and verify the merge result

Use `superpowers:finishing-a-development-branch`. Because the user's request
already authorizes autonomous local integration, merge the feature branch into
local `main` without pushing:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    finite-list-unfold
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
    /home/dikini/Projects/ash-doc/.worktrees/finite-list-unfold
git -C /home/dikini/Projects/ash-doc branch -d finite-list-unfold
```

Report the local main commit, exact Ash pin, verification totals, unpublished
status, and that no push occurred.
