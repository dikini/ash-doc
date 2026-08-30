# Resuming Tree Traversal Implementation Plan

<!-- markdownlint-disable MD013 -->
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
<!-- markdownlint-enable MD013 -->

**Goal:** Teach and verify an opaque eager in-order iterator whose explicit
pending frames let a client pause and resume traversal without laziness.

**Architecture:** Extend the complete case-9 `Dictionaries` module with one
private `FrameStack<K, V>`, one public opaque `Iterator<K, V>`, a private
left-spine helper, and public `iterator` and `next` operations. Two accepted
clients establish complete sequence and retained-state behavior; two rejected
clients establish the separate opaque pattern and value boundaries. A
lesson-local Bash verifier owns exact source, output, diagnostic, causal, and
transclusion evidence.

**Tech Stack:** Markdown, Bash, ShellCheck, pinned Modular Ash at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, Git worktrees, and existing
`content/checks/lib.sh` helpers. Add no dependency, manifest, renderer, shared
harness, or CI service.

---

## Fixed context

Work only in:

```text
/home/dikini/Projects/ash-doc/.worktrees/resuming-tree-traversal
```

Feature branch:

```text
resuming-tree-traversal
```

Base `main` commit:

```text
71f847c
```

Approved design commit:

```text
e909961
```

Clean pinned Ash checkout:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Exact Ash commit:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

Immutable ash-doc tag commit:

```text
e963a1597176f86003926eef827498db2a661b75
```

The exact-pin prototype is retained only while this case remains active:

```text
/tmp/ash-doc-case10-prototype.k5Dfk9
```

Its verifier first failed because the five sources were absent. After the
sources were added, a four-level nested client exposed the pinned tool's
`internal.resource.structural-depth` boundary. The accepted client now uses a
small recursive `collect` global. The retained-state source similarly uses one
match and two calls from the same state. These are ash-doc planning choices,
not Ash semantic changes or retained regression candidates.

The accepted prototype currently exits `0`, writes empty standard error, and
prints the exact values in Appendix C. Both rejected entries exit `1`, write
empty standard output, and begin standard error with
`resolve.opaque-constructor`. Their fixed source hashes are:

```text
229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff  dictionaries.ash
fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0  01-sequence.ash
5e6be6afdd2de8f12df1b48556a197b71e364a968c113146f5362b20c7d4f3b2  02-retained-state.ash
334318b3480aaf6550e41dc8bd90ad26cec736cd2cd277e656d8a1af63e86ba8  03-opaque-pattern.ash
8c656fc6eb7591c46cf162f77b4fa838257bd441dbb80abcd98705e9b9057cea  04-opaque-construction.ash
```

Retain these focused pinned access tests:

<!-- markdownlint-disable MD013 -->
```bash
(
    cd /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
    cargo test --locked --test module_visibility opaque_constructors_remain_available_inside_their_defining_module -- --exact
    cargo test --locked --test spec_examples overview_opaque_smart_constructor_example_is_executable -- --exact
    cargo test --locked --test interface_modules rejects_external_opaque_constructor_and_pattern_in_impl_body -- --exact
    cargo test --locked --test module_elaboration_nominals imported_opaque_nominal_is_not_an_empty_constructor_family -- --exact
)
```
<!-- markdownlint-enable MD013 -->

The complete case adds five canonical Case sources. Before navigation exists,
the aggregate verifier must report:

```text
11 Learn lessons
10 Cases
47 canonical Case sources
```

## Task 1: Create the failing lesson-local verifier

**Files:**

- Create: `content/cases/resuming-tree-traversal/checks/verify.sh`

### Step 1: Create only the required directories

Run:

```bash
mkdir -p \
    content/cases/resuming-tree-traversal/checks \
    content/cases/resuming-tree-traversal/src
```

Do not create `README.md` or any source yet.

### Step 2: Add the complete verifier

Use `apply_patch` to add Appendix A exactly. Make it executable:

```bash
chmod +x content/cases/resuming-tree-traversal/checks/verify.sh
```

The verifier must place semantic assertions before hashes and Ash execution.
It must own:

- the exact five-file source set;
- one public opaque iterator and one private frame stack;
- the exact inherited public dictionary API;
- both `push_left` equations and their saved association, right subtree, rest,
  and left recursion;
- `iterator` starting from `NoFrame`;
- the exhausted and successful `next` equations;
- the absence of `Order<K>` requirements or comparison in the iterator
  section;
- the recursive sequence consumer, empty observation, three entries, and
  complete result;
- the raw retained state and exactly two calls from `after_one`;
- both distinct opaque constructor contexts;
- exact hashes, success output, rejection channels/status/reason, primary and
  related token ranges, transclusion, and displayed output counts.

### Step 3: Run RED

Run:

```bash
bash content/cases/resuming-tree-traversal/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected status: `1`.

Expected first line:

```text
verify: missing canonical source: src/dictionaries.ash
```

If it fails for Bash syntax, tool setup, or another reason, correct the test
until it fails only because the first source is absent.

## Task 2: Add the five exact canonical sources

**Files:**

- Create: `content/cases/resuming-tree-traversal/src/dictionaries.ash`
- Create: `content/cases/resuming-tree-traversal/src/01-sequence.ash`
- Create: `content/cases/resuming-tree-traversal/src/02-retained-state.ash`
- Create: `content/cases/resuming-tree-traversal/src/03-opaque-pattern.ash`
- Create: `content/cases/resuming-tree-traversal/src/04-opaque-construction.ash`

### Step 1: Add the library and entries

Use `apply_patch` to add the five Appendix B sources byte-for-byte. Do not copy
the prototype with a filesystem command. The library is a dependency module,
so it intentionally has no `main`. It retains the case-9 public dictionary API
and implementation, removes only the old entry-specific private fixtures, and
adds the approved iterator representation and functions.

### Step 2: Confirm the fixed hashes

Run:

```bash
sha256sum content/cases/resuming-tree-traversal/src/*.ash
```

Require the five hashes in the fixed context above.

### Step 3: Run each exact observation directly

Run both accepted entries with the pinned binary and require status `0`, empty
standard error, and the exact Appendix C output. Run both rejected entries and
require status `1`, empty standard output, first standard-error line
`resolve.opaque-constructor`, and these exact causal spans:

```text
03-opaque-pattern.ash
primary: source 0 230..238
related: source 1 523..549

04-opaque-construction.ash
primary: source 0 103..111
related: source 1 523..549
```

The verifier computes these spans from the source bytes rather than hard-coding
them. It must prove that each primary covers only the `Iterator` member token
and that the related label covers the complete withheld
`Iterator(FrameStack<K, V>)` constructor declaration.

### Step 4: Run the verifier before prose

Run the local verifier again.

Expected status: `1`.

Expected first line:

```text
verify: missing unit README.md
```

The semantic and executable checks must pass before this final transclusion
failure.

## Task 3: Write the complete chapter and reach GREEN

**Files:**

- Create: `content/cases/resuming-tree-traversal/README.md`

### Step 1: Write the chapter through the approved arc

Use `apply_patch`. The chapter must begin from case 9's final model, not from
project status or objectives. Teach these moves in order:

1. a complete eager traversal must visit every association before returning a
   complete list;
2. materializing that list first pays `O(n)` work and state before the first
   client result;
3. an in-order traversal's unfinished work is current association, right
   subtree, and unfinished ancestors;
4. `push_left` turns that pending work into explicit private frames;
5. `iterator` eagerly prepares only the initial left spine;
6. `next` yields one pair and prepares the saved right subtree's left spine;
7. a client recursively consumes three results and reaches `None`;
8. raw output shows private constructor spellings without granting access;
9. replaying one retained state produces the same association and later state
   twice while repeating that deferred source work;
10. separate value and pattern rejections establish both opacity boundaries;
11. frame counts distinguish worst-case one-step work from complete linear
    traversal amortization; and
12. a final contrast asks what changes when the pending frontier must be FIFO.

Before every command, give the reader a model and a prediction. Explain each
exact observation after it appears. Keep project state, governing-source lists,
hashes, regression administration, and verification machinery out of lesson
prose.

### Step 2: Transclude every source exactly

Include exactly five marked `ash` blocks:

```text
<!-- source: src/dictionaries.ash -->
<!-- source: src/01-sequence.ash -->
<!-- source: src/02-retained-state.ash -->
<!-- source: src/03-opaque-pattern.ash -->
<!-- source: src/04-opaque-construction.ash -->
```

The dependency module is complete even without `main`; the accepted entries
invoke it. Include both Appendix C success outputs exactly once. Include two
diagnostic transcript blocks whose first line is
`resolve.opaque-constructor`; teach only the stable reason and distinct causal
source occurrence.

### Step 3: State the complete cost account

The lesson must derive, not merely state:

- a left spine of `d` nodes causes `d + 1` `push_left` applications and `d`
  `MoreFrame` constructions;
- initialization has `d <= h`, at most `h` explicit frames, and one iterator
  wrapper;
- `O(h)` counts only explicit frame forms, while saved subtrees may retain much
  or all of the existing dictionary transitively;
- a successful step performs one pop and `d_i` pushes with
  `1 + d_i <= h`, plus one `Iterator` and one `Some` construction;
- a finite complete linear traversal of `n` structural `Node` encounters makes
  exactly `n` pushes and `n` pops, including initialization, and the final
  `None` step makes no frame move;
- `2n` is `O(n + h)` and amortizes to constant frame work per produced pair on
  that one linear state chain;
- branching from an older persistent state can repeat a saved right-subtree
  left-spine descent and is outside that linear-history amortization; and
- case 9's inherited `h <= 2 log2(n + 1)` makes initialization and one
  worst-case step logarithmic for a valid public dictionary, while a complete
  traversal remains linear.

Attach finite, acyclic, ordered, return, cycle, structural observation, source
reuse, and runtime exclusions to the claims. The iterator makes no comparison,
does not validate or sort an internal malformed dictionary, and can return a
cyclic key or value payload without traversing it.

### Step 4: Add practice and the transition

Practice must ask readers to draw frames, predict a right-subtree left-spine
descent, derive the `2n` frame account, and explain the branching-history
caveat. End with the LIFO/FIFO question that motivates the persistent queue.
Do not introduce queue source or queue invariants here.

### Step 5: Run GREEN

Run:

```bash
bash content/cases/resuming-tree-traversal/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected final line:

```text
Verified 5 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

## Task 4: Prove verifier mutation sensitivity

**Files:**

- Test only: `content/cases/resuming-tree-traversal/checks/verify.sh`
- Mutate disposable copies only: the five canonical sources and `README.md`

### Step 1: Prepare an executable disposable content tree

Run from the feature-worktree root in one shell:

```bash
readonly mutation_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
readonly canonical_unit=$PWD/content/cases/resuming-tree-traversal
mutation_root=$(mktemp -d \
    "${TMPDIR:-/tmp}/ash-doc-case10-mutations.XXXXXX")
mutation_log=$(mktemp \
    "${TMPDIR:-/tmp}/ash-doc-case10-mutation-log.XXXXXX")
readonly mutation_root mutation_log
mkdir -p "$mutation_root/content/checks" "$mutation_root/content/cases"
cp content/checks/lib.sh "$mutation_root/content/checks/lib.sh"
cp -R "$canonical_unit" \
    "$mutation_root/content/cases/resuming-tree-traversal"
readonly mutation_unit=$mutation_root/content/cases/resuming-tree-traversal
readonly mutation_verify=$mutation_unit/checks/verify.sh

# Reuse one exact-pin build in every disposable verifier process.
# shellcheck source=../../../content/checks/lib.sh
source content/checks/lib.sh
ash_doc_prepare "$mutation_pin"
```

The copied helper is required: Appendix A derives `content_root` from the
verifier's path and sources `content/checks/lib.sh`. Do not alter the copied
verifier or any worktree source. Use these runners in the same shell:

```bash
expect_semantic_failure() {
    local mutant=$1
    local expected=$2
    local output status first

    set +e
    output=$(bash "$mutation_verify" "$mutation_pin" 2>&1)
    status=$?
    set -e

    first=${output%%$'\n'*}
    {
        printf '%s: status %s\n' "$mutant" "$status"
        printf '%s\n' "$output"
    } >> "$mutation_log"

    [[ $status -eq 1 ]]
    [[ $first == "verify: $expected" ]]
}

expect_block_difference() {
    local mutant=$1
    local source=$2
    local output status last

    set +e
    output=$(bash "$mutation_verify" "$mutation_pin" 2>&1)
    status=$?
    set -e

    last=$(printf '%s\n' "$output" | tail -n 1)
    {
        printf '%s: status %s\n' "$mutant" "$status"
        printf '%s\n' "$output"
    } >> "$mutation_log"

    [[ $status -eq 1 ]]
    [[ $output == *'@@ '* ]]
    [[ $last == "verify: displayed Ash differs from $source" ]]
}

restore_input() {
    cp "$canonical_unit/$1" "$mutation_unit/$1"
}
```

An exact semantic first line proves the named assertion exited before the
subsequent fixed-hash and Ash-execution sections.

### Step 2: Kill the exact mutation matrix

Apply one row at a time to the disposable copy with `apply_patch`, run the
stated runner, and restore its file with `restore_input` before the next row.
Each arrow means the one shown occurrence only. Type correctness is unnecessary
because the verifier must reject the mutant before Ash execution.

<!-- markdownlint-disable MD013 -->

| Mutant | Exact replacement | Expected semantic failure |
| --- | --- | --- |
| 1a | `pub opaque type Iterator` → `pub type Iterator` | `Iterator must retain one public opaque identity (found 0 occurrences, expected 1)` |
| 1b | `type FrameStack` → `pub type FrameStack` | `FrameStack must remain private (found 1 occurrences, expected 0)` |
| 2 | `push_left Empty stack = stack` → `push_left Empty stack = NoFrame` | `push_left must retain Empty reuse, exact frame fields, and left recursion` |
| 3a | `MoreFrame(key, value, right, stack)` → `MoreFrame(ignored_color, value, right, stack)` | same `push_left` failure |
| 3b | `MoreFrame(key, value, right, stack)` → `MoreFrame(key, key, right, stack)` | same `push_left` failure |
| 3c | `MoreFrame(key, value, right, stack)` → `MoreFrame(key, value, left, stack)` | same `push_left` failure |
| 3d | `MoreFrame(key, value, right, stack)` → `MoreFrame(key, value, right, NoFrame)` | same `push_left` failure |
| 4a | `push_left left later_stack` → `push_left right later_stack` | same `push_left` failure |
| 4b | `push_left left later_stack` → `push_left left stack` | same `push_left` failure |
| 5 | `push_left dictionary NoFrame` → `push_left dictionary (push_left dictionary NoFrame)` | `iterator and next must retain initial, exhausted, yielded, right, and rest behavior` |
| 6 | Delete `next Iterator(NoFrame) = None` | same iterator/`next` failure |
| 7a | `((key, value), Iterator(push_left right rest))` → `((value, value), Iterator(push_left right rest))` | same iterator/`next` failure |
| 7b | `((key, value), Iterator(push_left right rest))` → `((key, key), Iterator(push_left right rest))` | same iterator/`next` failure |
| 8a | `push_left right rest` → `push_left Empty rest` | same iterator/`next` failure |
| 8b | `push_left right rest` → `push_left right NoFrame` | same iterator/`next` failure |
| 9a | Add `where Order<K>` to the public `iterator` signature | `the public API must retain every exact signature (found 0 occurrences, expected 1)` |
| 9b | `Iterator(push_left right rest)` → `Iterator(compare right rest)` | same iterator/`next` failure |
| 10a | `Dictionaries.None => Dictionaries.End` → `Dictionaries.None => collect current` | `the sequence client must consume one entry and recurse on the returned state` |
| 10b | `Dictionaries.More(entry, collect later)` → `Dictionaries.More(later, collect later)` | same sequence-consumer failure |
| 10c | `collect later` → `collect current` | same sequence-consumer failure |
| 10d | `collect later` → `Dictionaries.End` | same sequence-consumer failure |
| 11a | Change the empty observation to use `dictionary` instead of `empty_dictionary` | `the sequence client must observe one empty iterator (found 0 occurrences, expected 1)` |
| 11b | `(two, 20)` → `(two, 21)` | `the sequence client must build the fixed two, one, three input` |
| 11c | Exchange the complete `(two, 20)` and `(one, 10)` positions | same fixed-input failure |
| 12a | Change the last `Dictionaries.next after_one` to `Dictionaries.None` | `the retained client must return raw state and replay it twice` |
| 12b | Change the raw first `after_one` argument of `Replay` to `start` | same retained-client failure |
| 13a | `Dictionaries.Iterator(ignored_stack) => 1` → `Dictionaries.None => 1` | `the pattern rejection must retain one opaque constructor occurrence (found 0 occurrences, expected 1)` |
| 13b | `let unavailable = Dictionaries.Iterator` → `let unavailable = Dictionaries.None` | `the value rejection must retain one opaque constructor occurrence (found 0 occurrences, expected 1)` |

<!-- markdownlint-enable MD013 -->

After each mutation group, restore its input and require disposable GREEN.
For each of the five marked source blocks, alter one code token only inside
that README block, then run the corresponding check:

```bash
expect_block_difference block-dictionaries src/dictionaries.ash
expect_block_difference block-sequence src/01-sequence.ash
expect_block_difference block-retained src/02-retained-state.ash
expect_block_difference block-pattern src/03-opaque-pattern.ash
expect_block_difference block-construction src/04-opaque-construction.ash
```

Restore `README.md` after each call. Mutate the two exact successful-output
lines independently and invoke the runner with these exact suffixes; the
runner supplies leading `verify:` text and its following space:

<!-- markdownlint-disable MD013 -->

```bash
expect_semantic_failure output-sequence \
    'README must display the complete sequence output exactly once (found 0 occurrences, expected 1)'
expect_semantic_failure output-retained \
    'README must display the retained-state output exactly once (found 0 occurrences, expected 1)'
```

<!-- markdownlint-enable MD013 -->

Finally alter the first and second diagnostic blocks' initial
`resolve.opaque-constructor` line independently, using each block's surrounding
source context to select one occurrence. Restore between mutations. Run these
calls after their corresponding mutation:

<!-- markdownlint-disable MD013 -->

```bash
expect_semantic_failure diagnostic-pattern \
    'README must begin two diagnostic transcripts with resolve.opaque-constructor (found 1 occurrences, expected 2)'
expect_semantic_failure diagnostic-construction \
    'README must begin two diagnostic transcripts with resolve.opaque-constructor (found 1 occurrences, expected 2)'
```

<!-- markdownlint-enable MD013 -->

These tests validate the verifier; they are not runtime mutation claims.

### Step 3: Restore GREEN and remove only disposable inputs

Run unprepared GREEN from the worktree and reconfirm all five hashes. Preserve
the exact `$mutation_log` path for chapter, closure, and whole-branch reviewers;
do not commit it. Delete the disposable copy by exact file name, then remove
only empty directories:

```bash
rm -- \
    "$mutation_unit/README.md" \
    "$mutation_unit/checks/verify.sh" \
    "$mutation_unit/src/dictionaries.ash" \
    "$mutation_unit/src/01-sequence.ash" \
    "$mutation_unit/src/02-retained-state.ash" \
    "$mutation_unit/src/03-opaque-pattern.ash" \
    "$mutation_unit/src/04-opaque-construction.ash" \
    "$mutation_root/content/checks/lib.sh"
rmdir -- \
    "$mutation_unit/checks" \
    "$mutation_unit/src" \
    "$mutation_unit" \
    "$mutation_root/content/cases" \
    "$mutation_root/content/checks" \
    "$mutation_root/content" \
    "$mutation_root"
```

## Task 5: Verify and review the complete chapter

### Step 1: Run pre-review verification

Run:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash -n content/cases/resuming-tree-traversal/checks/verify.sh
shellcheck -x content/cases/resuming-tree-traversal/checks/verify.sh
bash content/cases/resuming-tree-traversal/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Run Appendix D's relative-link loop, the four focused pinned tests, all five
hashes, `git diff --check`, exact pin/tag checks, clean pin status, and feature
status. Read the chapter, verifier, and all five sources fully as source.
Require 11 Learn lessons, 10 Cases, and 47 canonical Case sources.

### Step 2: Obtain sequential chapter reviews

Give one independent high-rigor specification reviewer the approved design,
plan, pinned authorities, complete sources and outputs, exact diagnostics,
mutation transcript, chapter, verifier, and status. Require findings for
authority, opacity, state invariant, ordered traversal, eager evaluation,
frame and amortized counts, persistence boundary, cycles, observation, and
verifier adequacy.

Only after specification approval, give a different instructional reviewer the
same evidence. Require continuity from case 9, prediction before execution,
explicit-state derivation, sequence explanation, opacity-versus-observation,
replay interaction, cost readability, practice, and queue transition.

Apply technically verified findings with `apply_patch`, rerun affected checks,
and obtain re-review until both approve.

### Step 3: Commit the complete case

Stage only:

```text
content/cases/resuming-tree-traversal/
```

Run:

```bash
git diff --cached --check
git status --short
git commit --no-gpg-sign -m "docs: teach resumable tree traversal"
```

## Task 6: Integrate, review, and close the case

### Step 1: Draft permanent navigation and roadmap state

Update only:

```text
README.md
content/cases/README.md
docs/project/roadmap.md
```

Root and Cases navigation must report ten verified cases and link the new
chapter in sequence. Replace the active case-10 section with a durable summary
that retains:

- all five sources and four exact accepted/rejected observations;
- the private frame stack, opaque iterator identity, public API, and separate
  pattern/value boundaries;
- initial left descent, saved association/right/rest fields, and successful and
  exhausted `next` behavior;
- comparison-free in-order traversal under the inherited dictionary invariant;
- raw structural observation without source access;
- complete sequence, empty state, retained replay, and linear-history
  amortization boundary;
- exact `d + 1`, `d`, `1 + d_i`, `n`, `2n`, `O(h)`, `O(n + h)`, and inherited
  logarithmic-height accounts;
- finite, cycle, reachability, source-construction, runtime, and source-status
  exclusions; and
- the original local source classification and absence of a new adaptation.

Promote case 11 only to `## Next: implementing a persistent FIFO frontier`.
Require its own bounded design and implementation plan before content. Preserve
the provisional case-12 block byte-for-byte; its fixed current hash is:

```text
0ba0cd849dcb728485ef5e5b219fca125a314a37168c18fa4b814c9c0a7c6a22
```

Reproduce it before and after integration with:

```bash
awk '
    /^### 12\. / { keep = 1 }
    /^## Promotion and verification policy/ { keep = 0 }
    keep { print }
' docs/project/roadmap.md | sha256sum
```

Retain temporary links to both case-10 plans while closure review is active.

### Step 2: Verify and review the integration draft

Rerun the complete verification set. Obtain sequential fresh specification and
quality closure reviews. Require durable-summary completeness, case-11 gate,
case-12 nonauthorization and byte preservation, clear navigation, attribution,
workflow compliance, and a reviewable deletion boundary.

### Step 3: Cross the temporary-record deletion boundary

Only after both closure reviewers approve:

1. remove the temporary roadmap links;
2. delete exactly this implementation plan and the approved case-10 design
   with `apply_patch`; and
3. confirm no live file references either completed record.

Read every changed permanent file and rerun all checks. Commit closure:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-30-resuming-tree-traversal-design.md \
    docs/plans/2026-08-30-resuming-tree-traversal.md
git diff --cached --check
git commit --no-gpg-sign -m "docs: verify resumable tree traversal"
```

## Task 7: Review, merge locally, and clean up

### Step 1: Obtain a whole-branch review

Give a fresh reviewer base `71f847c`, feature HEAD, the full diff, deleted
plans recovered from history, exact evidence, mutation transcript, final
navigation/roadmap, hashes, counts, tag, and pin. Apply verified findings and
obtain re-review.

### Step 2: Run final feature verification

Run the full Markdown, spelling-if-available, relative-link, Bash, ShellCheck,
local/Learn/Cases, focused-test, hash, 11/10/47, no-live-record, case-12,
tag/pin, clean-pin, diff, and status checks. Read every changed file and the
complete branch diff.

### Step 3: Merge without pushing and verify `main`

Confirm local `main` is clean and still contains base `71f847c`. Merge with an
unsigned no-fast-forward local commit:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    -m "Merge branch 'resuming-tree-traversal'" \
    resuming-tree-traversal
```

Do not push. From merged `main`, rerun the complete verification set while
excluding `.worktrees/**` from repository-wide Markdown and link discovery.
Require 11 Learn lessons, 10 Cases, 47 Case sources, clean `main`, clean pin,
and the fixed tag/pin commits.

Rebind `mutation_log` to the exact path retained from Task 4, then remove only
that reviewed transcript:

```bash
[[ -f $mutation_log ]]
rm -- "$mutation_log"
[[ ! -e $mutation_log ]]
```

Validate the prototype before removing the feature worktree:

```bash
readonly prototype_root=/tmp/ash-doc-case10-prototype.k5Dfk9
prototype_real=$(realpath -e -- "$prototype_root")
readonly prototype_real
[[ $prototype_real == "$prototype_root" ]]

readonly expected_prototype_files=$'01-sequence.ash\n02-retained-state.ash\n03-opaque-pattern.ash\n04-opaque-construction.ash\ndictionaries.ash\nverify.sh'
actual_prototype_files=$(
    find "$prototype_real" -mindepth 1 -maxdepth 1 -printf '%f\n' |
        LC_ALL=C sort
)
[[ $actual_prototype_files == "$expected_prototype_files" ]]

(
    cd "$prototype_real"
    sha256sum -c <<'HASHES'
fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0  01-sequence.ash
5e6be6afdd2de8f12df1b48556a197b71e364a968c113146f5362b20c7d4f3b2  02-retained-state.ash
334318b3480aaf6550e41dc8bd90ad26cec736cd2cd277e656d8a1af63e86ba8  03-opaque-pattern.ash
8c656fc6eb7591c46cf162f77b4fa838257bd441dbb80abcd98705e9b9057cea  04-opaque-construction.ash
229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff  dictionaries.ash
HASHES
)
bash -n "$prototype_real/verify.sh"
```

Use `apply_patch` to delete exactly the five named `.ash` files and
`verify.sh`. Then require and remove only the empty directory:

```bash
[[ -z $(find "$prototype_real" -mindepth 1 -maxdepth 1 -print -quit) ]]
rmdir -- "$prototype_real"
[[ ! -e $prototype_root ]]
```

Finally leave the feature worktree before removing it:

```bash
readonly repository_root=/home/dikini/Projects/ash-doc
readonly feature_worktree=$repository_root/.worktrees/resuming-tree-traversal
readonly feature_branch=resuming-tree-traversal

[[ -z $(git -C "$feature_worktree" status --short) ]]
feature_head=$(git -C "$feature_worktree" rev-parse HEAD)
git -C "$repository_root" merge-base --is-ancestor "$feature_head" main

cd "$repository_root"
git worktree remove "$feature_worktree"
[[ ! -e $feature_worktree ]]
git branch -d "$feature_branch"
if git show-ref --verify --quiet "refs/heads/$feature_branch"; then
    printf 'feature branch still exists: %s\n' "$feature_branch" >&2
    exit 1
fi
```

Do not use a recursive deletion command. Do not push. Begin case 11 only after
these assertions pass.

## Appendix A: exact lesson-local verifier

<!-- markdownlint-disable MD013 -->

```bash
#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/dictionaries.ash"
readonly sequence_entry="$unit_root/src/01-sequence.ash"
readonly retained_entry="$unit_root/src/02-retained-state.ash"
readonly pattern_entry="$unit_root/src/03-opaque-pattern.ash"
readonly construction_entry="$unit_root/src/04-opaque-construction.ash"
readonly sources=(
    src/dictionaries.ash
    src/01-sequence.ash
    src/02-retained-state.ash
    src/03-opaque-pattern.ash
    src/04-opaque-construction.ash
)

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] ||
        ash_doc_fail "missing canonical source: $source"
done

declared_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/declared-sources.XXXXXX")
actual_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/actual-sources.XXXXXX")
readonly declared_sources_file actual_sources_file
printf '%s\n' "${sources[@]}" | LC_ALL=C sort > "$declared_sources_file"
find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' \
    -printf 'src/%f\n' | LC_ALL=C sort > "$actual_sources_file"
if ! cmp -s "$declared_sources_file" "$actual_sources_file"; then
    diff -u "$declared_sources_file" "$actual_sources_file" >&2 || true
    ash_doc_fail "canonical source set must contain exactly the five declared paths"
fi

ash_doc_section() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_section requires start and end lines"
    fi

    if ! awk -v section_start="$1" -v section_end="$2" '
        $0 == section_start {
            start_seen = 1
            inside = 1
        }
        inside && section_end != "" && $0 == section_end {
            end_seen = 1
            exit
        }
        inside {
            print
        }
        END {
            if (!start_seen || (section_end != "" && !end_seen)) {
                exit 2
            }
        }
    ' "$library"; then
        ash_doc_fail "ash_doc_section could not find required adjacent signatures"
    fi
}

ash_doc_assert_phrase_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_phrase_count requires source, phrase, count, and claim"
    fi

    local source=$1
    local phrase=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fo "$phrase" <<< "$source" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_line_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_line_count requires source, line, count, and claim"
    fi

    local source=$1
    local expected_line=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fx "$expected_line" <<< "$source" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_contains() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_contains requires source, substring, and claim"
    fi

    [[ $1 == *"$2"* ]] || ash_doc_fail "$3"
}

ash_doc_assert_sha256() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_sha256 requires file, hash, and claim"
    fi

    local actual
    actual=$(sha256sum "$1")
    actual=${actual%% *}
    [[ $actual == "$2" ]] ||
        ash_doc_fail "$3 (found $actual, expected $2)"
}

ash_doc_assert_text_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_text_line_once requires line and claim"
    fi

    local actual_count
    actual_count=$(
        awk -v expected="$1" '
            $0 == "```text" { inside = 1; next }
            inside && $0 == "```" { inside = 0; next }
            inside && $0 == expected { count += 1 }
            END { print count + 0 }
        ' "$readme"
    )
    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail "$2 (found $actual_count occurrences, expected 1)"
}

ash_doc_assert_text_first_line_count() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_text_first_line_count requires line, count, and claim"
    fi

    local actual_count
    actual_count=$(
        awk -v expected="$1" '
            $0 == "```text" { first = 1; next }
            first {
                if ($0 == expected) {
                    count += 1
                }
                first = 0
            }
            END { print count + 0 }
        ' "$readme"
    )
    [[ $actual_count -eq $2 ]] ||
        ash_doc_fail "$3 (found $actual_count occurrences, expected $2)"
}

ash_doc_run_iterator_rejection() {
    if [[ $# -ne 1 ]]; then
        ash_doc_fail "ash_doc_run_iterator_rejection requires one entry"
    fi

    local rejected_entry=$1
    local rejected_source="$unit_root/$rejected_entry"
    local rejected_stdout rejected_stderr rejected_status
    rejected_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    rejected_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")

    if "$ASH_DOC_ASH_BIN" "$rejected_source" \
        > "$rejected_stdout" 2> "$rejected_stderr"; then
        rejected_status=0
    else
        rejected_status=$?
    fi

    [[ $rejected_status -eq 1 ]] ||
        ash_doc_fail "$rejected_entry exited with status $rejected_status, expected 1"
    [[ ! -s $rejected_stdout ]] ||
        ash_doc_fail "$rejected_entry wrote unexpected standard output"
    [[ $(sed -n '1p' "$rejected_stderr") == 'resolve.opaque-constructor' ]] ||
        ash_doc_fail "$rejected_entry did not report resolve.opaque-constructor first"

    local qualified='Dictionaries.Iterator'
    local qualified_matches=()
    mapfile -t qualified_matches < <(
        LC_ALL=C grep -aboF "$qualified" "$rejected_source" || true
    )
    [[ ${#qualified_matches[@]} -eq 1 ]] ||
        ash_doc_fail "$rejected_entry must contain one byte-identifiable Dictionaries.Iterator"

    local qualified_start=${qualified_matches[0]%%:*}
    local qualifier_length member_length member_start member_end
    qualifier_length=$(LC_ALL=C printf '%s' 'Dictionaries.' | wc -c)
    member_length=$(LC_ALL=C printf '%s' 'Iterator' | wc -c)
    member_start=$((qualified_start + qualifier_length))
    member_end=$((member_start + member_length))

    local declaration='Iterator(FrameStack<K, V>)'
    local declaration_matches=()
    mapfile -t declaration_matches < <(
        LC_ALL=C grep -aboF "$declaration" "$library" || true
    )
    [[ ${#declaration_matches[@]} -eq 1 ]] ||
        ash_doc_fail "the opaque Iterator must have one byte-identifiable constructor declaration"
    local declaration_start=${declaration_matches[0]%%:*}
    local declaration_length declaration_end
    declaration_length=$(LC_ALL=C printf '%s' "$declaration" | wc -c)
    declaration_end=$((declaration_start + declaration_length))

    local primary_prefix="primary: source 0 $member_start..$member_end:"
    local related_prefix="related: source 1 $declaration_start..$declaration_end:"
    local primary_lines=() related_lines=()
    mapfile -t primary_lines < <(
        LC_ALL=C grep -F 'primary: source 0 ' "$rejected_stderr" || true
    )
    mapfile -t related_lines < <(
        LC_ALL=C grep -F 'related: source 1 ' "$rejected_stderr" || true
    )
    [[ ${#primary_lines[@]} -eq 1 && ${primary_lines[0]} == "$primary_prefix"* ]] ||
        ash_doc_fail "$rejected_entry primary label must cover exactly the Iterator member token"
    [[ ${#related_lines[@]} -eq 1 && ${related_lines[0]} == "$related_prefix"* ]] ||
        ash_doc_fail "$rejected_entry related label must cover the withheld Iterator constructor declaration"
    grep -Fxq 'found Iterator' "$rejected_stderr" ||
        ash_doc_fail "$rejected_entry must retain Iterator as its found constructor spelling"
}

library_source=$(<"$library")
sequence_source=$(<"$sequence_entry")
retained_source=$(<"$retained_entry")
pattern_source=$(<"$pattern_entry")
construction_source=$(<"$construction_entry")
readonly library_source sequence_source retained_source pattern_source construction_source

# Keep every mutation-facing semantic assertion before hashes and execution.
ash_doc_assert_phrase_count \
    "$library_source" 'pub opaque type Dictionary<K, V> =' 1 \
    "Dictionary must retain one public opaque identity"
ash_doc_assert_phrase_count \
    "$library_source" 'pub opaque type Iterator<K, V> =' 1 \
    "Iterator must retain one public opaque identity"
ash_doc_assert_phrase_count \
    "$library_source" 'type FrameStack<K, V> =' 1 \
    "FrameStack must retain one private nominal declaration"
ash_doc_assert_phrase_count \
    "$library_source" 'pub type FrameStack<K, V> =' 0 \
    "FrameStack must remain private"

for signature in \
    'pub empty : Unit -> Dictionary<K, V>' \
    'pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>' \
    'pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>' \
    'pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>' \
    'pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>' \
    'pub iterator : Dictionary<K, V> -> Iterator<K, V>' \
    'pub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>'; do
    ash_doc_assert_line_count \
        "$library_source" "$signature" 1 \
        "the public API must retain every exact signature"
done

readonly expected_frames=$'type FrameStack<K, V> =\n    NoFrame\n    | MoreFrame(K, V, Dictionary<K, V>, FrameStack<K, V>)\n\npub opaque type Iterator<K, V> =\n    Iterator(FrameStack<K, V>)'
ash_doc_assert_contains \
    "$library_source" "$expected_frames" \
    "the private frames and opaque wrapper must retain their exact representation"

push_left_section=$(ash_doc_section \
    'push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>' \
    'pub iterator : Dictionary<K, V> -> Iterator<K, V>')
iterator_section=$(ash_doc_section \
    'pub iterator : Dictionary<K, V> -> Iterator<K, V>' '')
readonly push_left_section iterator_section
readonly expected_push_left=$'push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>\npush_left Empty stack = stack\npush_left Node(ignored_color, left, key, value, right) stack = {\n    let later_stack = MoreFrame(key, value, right, stack)\n    push_left left later_stack\n}'
[[ $push_left_section == "$expected_push_left" ]] ||
    ash_doc_fail "push_left must retain Empty reuse, exact frame fields, and left recursion"
readonly expected_iterator=$'pub iterator : Dictionary<K, V> -> Iterator<K, V>\niterator dictionary = Iterator(push_left dictionary NoFrame)\n\npub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>\nnext Iterator(NoFrame) = None\nnext Iterator(MoreFrame(key, value, right, rest)) = Some(\n    ((key, value), Iterator(push_left right rest))\n)'
[[ $iterator_section == "$expected_iterator" ]] ||
    ash_doc_fail "iterator and next must retain initial, exhausted, yielded, right, and rest behavior"
ash_doc_assert_phrase_count \
    "$iterator_section" 'Order<' 0 \
    "iterator operations must not require ordering evidence"
ash_doc_assert_phrase_count \
    "$iterator_section" 'compare ' 0 \
    "iterator operations must not compare keys"

readonly expected_collect=$'collect : Dictionaries.Iterator<K, V> -> Dictionaries.List<(K, V)>\ncollect current = match Dictionaries.next current {\n    Dictionaries.None => Dictionaries.End\n    Dictionaries.Some((entry, later)) => Dictionaries.More(entry, collect later)\n}'
ash_doc_assert_contains \
    "$sequence_source" "$expected_collect" \
    "the sequence client must consume one entry and recurse on the returned state"
ash_doc_assert_phrase_count \
    "$sequence_source" \
    'let empty_finished = is_finished (Dictionaries.next (Dictionaries.iterator empty_dictionary))' 1 \
    "the sequence client must observe one empty iterator"
readonly expected_sequence_entries=$'let entries = Dictionaries.More(\n        (two, 20),\n        Dictionaries.More(\n            (one, 10),\n            Dictionaries.More((three, 30), Dictionaries.End)\n        )\n    )'
ash_doc_assert_contains \
    "$sequence_source" "$expected_sequence_entries" \
    "the sequence client must build the fixed two, one, three input"
ash_doc_assert_phrase_count \
    "$sequence_source" \
    '(empty_finished, collect (Dictionaries.iterator dictionary))' 1 \
    "the sequence result must retain empty and complete traversal observations"

readonly expected_replay=$'Dictionaries.Some((ignored_first, after_one)) => Replay(\n        after_one,\n        Dictionaries.next after_one,\n        Dictionaries.next after_one\n    )'
ash_doc_assert_contains \
    "$retained_source" "$expected_replay" \
    "the retained client must return raw state and replay it twice"
ash_doc_assert_phrase_count \
    "$retained_source" 'Dictionaries.next after_one' 2 \
    "the retained client must branch exactly twice from after_one"
readonly expected_retained_entries=$'let entries = Dictionaries.More(\n        (one, 10),\n        Dictionaries.More(\n            (two, 20),\n            Dictionaries.More((three, 30), Dictionaries.End)\n        )\n    )'
ash_doc_assert_contains \
    "$retained_source" "$expected_retained_entries" \
    "the retained client must build the fixed one, two, three input"

ash_doc_assert_phrase_count \
    "$pattern_source" 'Dictionaries.Iterator' 1 \
    "the pattern rejection must retain one opaque constructor occurrence"
ash_doc_assert_phrase_count \
    "$pattern_source" 'Dictionaries.Iterator(ignored_stack) => 1' 1 \
    "the pattern rejection must retain its exact failing arm"
ash_doc_assert_phrase_count \
    "$construction_source" 'Dictionaries.Iterator' 1 \
    "the value rejection must retain one opaque constructor occurrence"
ash_doc_assert_phrase_count \
    "$construction_source" 'let unavailable = Dictionaries.Iterator' 1 \
    "the value rejection must retain its exact failing initializer"

ash_doc_assert_sha256 \
    "$library" \
    229205c9dfde2592a5a0305ba214a172253f9577d0e99a22808e13193c2c0eff \
    "dictionaries.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$sequence_entry" \
    fac3de5c89b93a159b22e764a36be2ea18358ba3a2666298c42bcaf501d500c0 \
    "01-sequence.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$retained_entry" \
    5e6be6afdd2de8f12df1b48556a197b71e364a968c113146f5362b20c7d4f3b2 \
    "02-retained-state.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$pattern_entry" \
    334318b3480aaf6550e41dc8bd90ad26cec736cd2cd277e656d8a1af63e86ba8 \
    "03-opaque-pattern.ash must retain its exact complete source"
ash_doc_assert_sha256 \
    "$construction_entry" \
    8c656fc6eb7591c46cf162f77b4fa838257bd441dbb80abcd98705e9b9057cea \
    "04-opaque-construction.ash must retain its exact complete source"

readonly sequence_output='(true, More((Next(Zero), 10), More((Next(Next(Zero)), 20), More((Next(Next(Next(Zero))), 30), End)))) : (Bool, List<(Natural, Int)>)'
readonly retained_output='Replay(Iterator(MoreFrame(Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty), NoFrame)), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame))), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))) : ReplayObservation'

ash_doc_run_accepted "$unit_root" src/01-sequence.ash "$sequence_output"
ash_doc_run_accepted "$unit_root" src/02-retained-state.ash "$retained_output"
ash_doc_run_iterator_rejection src/03-opaque-pattern.ash
ash_doc_run_iterator_rejection src/04-opaque-construction.ash

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_assert_text_line_once \
    "$sequence_output" \
    "README must display the complete sequence output exactly once"
ash_doc_assert_text_line_once \
    "$retained_output" \
    "README must display the retained-state output exactly once"
ash_doc_assert_text_first_line_count \
    'resolve.opaque-constructor' 2 \
    "README must begin two diagnostic transcripts with resolve.opaque-constructor"

ash_doc_finish 5
```

<!-- markdownlint-enable MD013 -->

## Appendix B: exact canonical sources

The following five files are the accepted exact-pin prototypes.

### B.1 `dictionaries.ash`

<!-- markdownlint-disable MD013 -->

```ash
pub type Ordering =
    Less
    | Equal
    | Greater

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)

type BalanceCheck =
    Invalid
    | Valid(Int)

type FrameStack<K, V> =
    NoFrame
    | MoreFrame(K, V, Dictionary<K, V>, FrameStack<K, V>)

pub opaque type Iterator<K, V> =
    Iterator(FrameStack<K, V>)

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(ignored_color, left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth = Node(
    Red,
    Node(Black, first, first_key, first_value, second),
    middle_key,
    middle_value,
    Node(Black, third, last_key, last_value, fourth)
)

restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore Black Node(
    Red,
    Node(Red, first, first_key, first_value, second),
    middle_key,
    middle_value,
    third
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black Node(
    Red,
    first,
    first_key,
    first_value,
    Node(Red, second, middle_key, middle_value, third)
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    Node(Red, second, middle_key, middle_value, third),
    last_key,
    last_value,
    fourth
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    second,
    middle_key,
    middle_value,
    Node(Red, third, last_key, last_value, fourth)
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore color left key value right = Node(color, left, key, value, right)

insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert_colored key value Empty = Node(Red, Empty, key, value, Empty)
insert_colored key value Node(color, left, current_key, current_value, right) = match compare key current_key {
    Less => restore color (insert_colored key value left) current_key current_value right
    Equal => Node(color, left, current_key, value, right)
    Greater => restore color left current_key current_value (insert_colored key value right)
}

blacken_root : Dictionary<K, V> -> Dictionary<K, V>
blacken_root dictionary = match dictionary {
    Empty => Empty
    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary
    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value dictionary = blacken_root (insert_colored key value dictionary)

fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated End = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>
insert_entry dictionary entry = match entry {
    (key, value) => insert key value dictionary
}

pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>
build entries = fold_left insert_entry (empty ()) entries

above_lower : Option<K> -> K -> Bool where Order<K>
above_lower None key = true
above_lower Some(lower) key = match compare lower key {
    Less => true
    Equal => false
    Greater => false
}

below_upper : K -> Option<K> -> Bool where Order<K>
below_upper key None = true
below_upper key Some(upper) = match compare key upper {
    Less => true
    Equal => false
    Greater => false
}

both : Bool -> Bool -> Bool
both true right = right
both false right = false

valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>
valid_between lower upper Empty = true
valid_between lower upper Node(ignored_color, left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

is_black : Dictionary<K, V> -> Bool
is_black Empty = true
is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

children_colors_hold : Color -> Dictionary<K, V> -> Dictionary<K, V> -> Bool
children_colors_hold Black left right = true
children_colors_hold Red left right = both (is_black left) (is_black right)

add_black : Color -> Int -> Int
add_black Red height = height
add_black Black height = height + 1

balance_summary : Dictionary<K, V> -> BalanceCheck
balance_summary Empty = Valid(1)
balance_summary Node(color, left, ignored_key, ignored_value, right) = {
    let left_result = balance_summary left
    let right_result = balance_summary right
    let children_hold = children_colors_hold color left right
    match (left_result, right_result) {
        (Invalid, ignored_right_result) => Invalid
        (Valid(ignored_left_height), Invalid) => Invalid
        (Valid(left_height), Valid(right_height)) => match children_hold {
            false => Invalid
            true => match left_height == right_height {
                false => Invalid
                true => Valid(add_black color left_height)
            }
        }
    }
}

balance_holds : Dictionary<K, V> -> Bool
balance_holds dictionary = match balance_summary dictionary {
    Invalid => false
    Valid(ignored_height) => true
}

root_is_black : Dictionary<K, V> -> Bool
root_is_black Empty = true
root_is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
root_is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = {
    let ordered = valid_between None None dictionary
    let balanced = balance_holds dictionary
    let black_root = root_is_black dictionary
    both ordered (both balanced black_root)
}

push_left : Dictionary<K, V> -> FrameStack<K, V> -> FrameStack<K, V>
push_left Empty stack = stack
push_left Node(ignored_color, left, key, value, right) stack = {
    let later_stack = MoreFrame(key, value, right, stack)
    push_left left later_stack
}

pub iterator : Dictionary<K, V> -> Iterator<K, V>
iterator dictionary = Iterator(push_left dictionary NoFrame)

pub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>
next Iterator(NoFrame) = None
next Iterator(MoreFrame(key, value, right, rest)) = Some(
    ((key, value), Iterator(push_left right rest))
)
```

### B.2 `01-sequence.ash`

```ash
import dictionaries as Dictionaries

collect : Dictionaries.Iterator<K, V> -> Dictionaries.List<(K, V)>
collect current = match Dictionaries.next current {
    Dictionaries.None => Dictionaries.End
    Dictionaries.Some((entry, later)) => Dictionaries.More(entry, collect later)
}

is_finished : Dictionaries.Option<A> -> Bool
is_finished Dictionaries.None = true
is_finished Dictionaries.Some(ignored) = false

main : Unit -> (Bool, Dictionaries.List<(Dictionaries.Natural, Int)>)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let empty_dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
    let dictionary = Dictionaries.build entries
    let empty_finished = is_finished (Dictionaries.next (Dictionaries.iterator empty_dictionary))
    (empty_finished, collect (Dictionaries.iterator dictionary))
}
```

### B.3 `02-retained-state.ash`

```ash
import dictionaries as Dictionaries

type ReplayObservation =
    Unexpected
    | Replay(
        Dictionaries.Iterator<Dictionaries.Natural, Int>,
        Dictionaries.Option<(
            (Dictionaries.Natural, Int),
            Dictionaries.Iterator<Dictionaries.Natural, Int>
        )>,
        Dictionaries.Option<(
            (Dictionaries.Natural, Int),
            Dictionaries.Iterator<Dictionaries.Natural, Int>
        )>
    )

replay : Dictionaries.Iterator<Dictionaries.Natural, Int> -> ReplayObservation
replay start = match Dictionaries.next start {
    Dictionaries.None => Unexpected
    Dictionaries.Some((ignored_first, after_one)) => Replay(
        after_one,
        Dictionaries.next after_one,
        Dictionaries.next after_one
    )
}

main : Unit -> ReplayObservation
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let entries = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
    replay (Dictionaries.iterator (Dictionaries.build entries))
}
```

### B.4 `03-opaque-pattern.ash`

```ash
import dictionaries as Dictionaries

main : Unit -> Int
main () = {
    let dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
    match Dictionaries.iterator dictionary {
        Dictionaries.Iterator(ignored_stack) => 1
    }
}
```

### B.5 `04-opaque-construction.ash`

```ash
import dictionaries as Dictionaries

main : Unit -> Int
main () = {
    let unavailable = Dictionaries.Iterator
    0
}
```

## Appendix C: exact successful outputs

### C.1 Complete sequence

```text
(true, More((Next(Zero), 10), More((Next(Next(Zero)), 20), More((Next(Next(Next(Zero))), 30), End)))) : (Bool, List<(Natural, Int)>)
```

### C.2 Retained state

```text
Replay(Iterator(MoreFrame(Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty), NoFrame)), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame))), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))) : ReplayObservation
```

## Appendix D: exact relative-link check

```bash
while IFS= read -r file; do
    while IFS= read -r target; do
        link_path=${target%%#*}
        [[ -z $link_path || $link_path == http://* ]] && continue
        [[ $link_path == https://* || $link_path == \#* ]] && continue
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
```

<!-- markdownlint-enable MD013 -->
