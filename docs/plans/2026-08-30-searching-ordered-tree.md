# Searching an ordered tree implementation plan

<!-- markdownlint-disable-next-line MD013 -->
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Publish one verified Cases chapter that explains how a valid global
ordering invariant lets lookup enter one tree branch, while a transparent
malformed tree and ascending insertion expose the limits of that choice.

**Architecture:** Add one lesson-local transparent ordered-tree module with an
explicit comparator, lookup, persistent insertion, counted lookup, and unary
height. Three complete entries observe valid hit and miss paths, duplicate
replacement beside an accepted malformed miss, and a degenerate tree produced
by ascending insertion.

**Tech stack:** Markdown, Ash, Bash, ShellCheck, Git, and the `ash` executable
built from exact Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Execution boundary

Work only in the `searching-ordered-tree` branch and its existing worktree at
`/home/dikini/Projects/ash-doc/.worktrees/searching-ordered-tree`. The feature
branch began from local `main` commit
`ebe1847`; the approved design is commit `405b398`. Use the clean pinned
checkout at
`/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin` for
every executable observation. Do not change `ash-lang`, the edition target,
the immutable `modular-ash` tag, or shared content infrastructure.

The reader asks how a valid global binary-search-tree invariant lets lookup
ignore one complete branch. The observable boundary crosses from one local
`Ordering` result to every descendant's placement. The same one-branch lookup
runs on a transparent malformed tree, but it can return `None` for a key that
is structurally present in the branch that comparison rules out. The case
separates visited nodes and top-level comparator applications from recursive
work inside `compare_natural`; it does not infer logarithmic lookup from an
unbalanced representation.

Use `@superpowers:subagent-driven-development` to execute Tasks 1 through 4 in
order. Dispatch one fresh implementer per task; do not run implementation tasks
in parallel because they share one case and one closure draft. Tasks 1 through
3 form one uncommitted test-first cycle. Task 1 establishes a missing-first-
source RED. Task 2 adds all canonical sources, directly observes them at the
pin, and advances the verifier to a missing-README RED. Task 3 adds the complete
README, reaches GREEN, proves fourteen focused mutation REDs, and commits the
whole case once. Those implementers use
`@superpowers:test-driven-development`. Task 4 integrates already-green
documentation and uses explicit verification and review gates instead of a
new strict TDD cycle.

Use high reasoning for the bounded verifier and canonical-source implementers
in Tasks 1 and 2. Use xhigh reasoning for the chapter and integration
implementers in Tasks 3 and 4. After each task, dispatch a fresh xhigh
specification reviewer. Only after that review passes may a different fresh
quality reviewer begin; use high reasoning for Task 1 and 2 quality review and
xhigh for Task 3 and 4 quality review. If a reviewer finds an issue, the same
implementer fixes it and the same reviewer rechecks it. Do not proceed with an
open finding. Reviewers inspect the working-tree diff and untracked files,
rather than relying on a commit range while Tasks 1 through 3 remain
uncommitted.

Before drafting or reviewing the chapter, navigation, roadmap, review prose,
or commit messages, use the project-local `@writing-ash-documentation` skill.
Use `@superpowers:verification-before-completion` before each commit and before
integration. Task 5 uses a fresh xhigh whole-branch reviewer and
`@superpowers:requesting-code-review`; apply findings through
`@superpowers:receiving-code-review` and re-review every correction.

The approved design and this plan stay linked from the roadmap through the
reviewed repository-closure draft. Their presence does not authorize content
until this plan passes independent review and the planning checkpoint is
committed. Do not delete either record when the local case first turns green.

Execution begins only after a fresh xhigh planning review and this clean
planning checkpoint:

```bash
npx --yes markdownlint-cli2 \
    docs/plans/2026-08-30-searching-ordered-tree-design.md \
    docs/plans/2026-08-30-searching-ordered-tree.md \
    docs/project/roadmap.md
if command -v typos >/dev/null 2>&1; then
    typos docs/plans/2026-08-30-searching-ordered-tree-design.md \
        docs/plans/2026-08-30-searching-ordered-tree.md \
        docs/project/roadmap.md
fi
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
git diff --check
git status --short
git add docs/plans/2026-08-30-searching-ordered-tree.md \
    docs/project/roadmap.md
git commit --no-gpg-sign -m "docs: plan searching an ordered tree"
```

Expected before staging: only this implementation plan and its roadmap link
are uncommitted; the approved design is already tracked; and every check has no
findings. Expected after the commit: the feature worktree is clean.

The planning reviewer receives the approved design, this full plan, the
roadmap diff, base `ebe1847`, exact feasibility sources under
`/tmp/ash-ordered-tree-feasibility.ArXp9m/recommended`, and the fourteen
mutation contracts. It checks every proposed source and output, RED-to-GREEN
ordering, mutation failure ordering, authority, review payload, deletion
boundary, totals, and local merge procedure before approving content work.

## Task 1: Add the case verifier and establish the first RED

**Files:**

- Create: `content/cases/searching-ordered-tree/checks/verify.sh`

### Step 1: Create the executable verifier

Add a Bash verifier with `set -euo pipefail`. Derive `unit_root` and
`content_root` like the branching-data case, source `content/checks/lib.sh`,
require one pinned Ash checkout argument, call `ash_doc_prepare`, and declare
these four canonical sources in order:

```bash
readonly sources=(
    src/ordered_trees.ash
    src/01-lookup.ash
    src/02-replace-and-malformed.ash
    src/03-ascending.ash
)
```

Declare `readme`, `library`, and all three entry paths before sourcing the
helper. Immediately after `ash_doc_prepare`, add this first-source precheck:

```bash
[[ -f $library ]] ||
    ash_doc_fail "missing canonical source: src/ordered_trees.ash"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
```

The explicit precheck owns Task 1's RED. Once Task 2 adds the four sources,
`ash_doc_check_sources` advances to its own earlier missing-README check. Do
not precheck the README or the other sources before this sequence.

Copy the hardened `ash_doc_section`, `ash_doc_assert_word_count`,
`ash_doc_assert_phrase_count`, `ash_doc_assert_suffix`,
`ash_doc_assert_contains`, and `ash_doc_assert_text_line_once` helpers from
`content/cases/folding-branching-data/checks/verify.sh`. The section helper must
fail if either a required start or nonempty end signature is absent. The
multiline helper must use Bash literal containment; do not pass newline-
containing strings to the line-oriented phrase-count helper.

Use these adjacent library boundaries:

<!-- markdownlint-disable MD013 -->
```text
representations:
    pub type Tree<K, V> =
    -> pub compare_natural : Natural -> Natural -> Ordering
compare_natural:
    pub compare_natural : Natural -> Natural -> Ordering
    -> pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>
lookup:
    pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>
    -> pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>
insert:
    pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>
    -> pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)
lookup_counted:
    pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)
    -> maximum : Natural -> Natural -> Natural
maximum:
    maximum : Natural -> Natural -> Natural
    -> pub height : Tree<K, V> -> Natural
height:
    pub height : Tree<K, V> -> Natural
    -> end of file
```
<!-- markdownlint-enable MD013 -->

Assert the representation section exactly, including declaration order:

```text
pub type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

pub type Ordering =
    Less
    | Equal
    | Greater

pub type Option<A> =
    None
    | Some(A)

pub type Natural =
    Zero
    | Next(Natural)
```

For each function section, put the focused mutation phrases below before a
whole-section equality check against the exact Task 2 source. This ordering
makes a focused mutation reach its causal failure instead of a generic exact-
section failure. The final exact comparisons reject duplicate equations,
extra public operations, rearrangement, and unplanned behavior.

Check `compare_natural` in this order:

1. Require exactly one
   `compare_natural Zero Next(right) = Less`; failure:
   `compare_natural must order Zero before every Next value`.
2. Require exactly one
   `compare_natural Next(left) Next(right) = compare_natural left right`;
   failure:
   `compare_natural must structurally compare both Next payloads`.
3. Require exactly one each of the `Zero Zero = Equal` and
   `Next(left) Zero = Greater` equations, then compare the complete signature
   and four equations byte-for-byte with Task 2.

Check `lookup` in this order:

1. Require exactly one
   `Less => lookup compare query left`; failure:
   `lookup must enter only the left branch after Less`.
2. Require exactly one
   `Greater => lookup compare query right`; failure:
   `lookup must enter only the right branch after Greater`.
3. Require `lookup compare query Empty = None`, exactly one complete
   `match compare query key {`, and `Equal => Some(value)`, then compare the
   whole signature and two equations exactly. Word counts must confirm one
   comparator application and one recursive lookup in each selected unequal
   arm, with no eager binding of either branch result.

Check `insert` in this order:

1. Require exactly one complete Less arm
   `Less => Node(insert compare key value left, current_key, current_value, right)`;
   failure: `insert must recurse left and retain the right branch after Less`.
2. Require exactly one `current_key, value` phrase in the Equal result. This
   check is independent of the retained branch positions; failure:
   `insert replacement must retain the stored representative key`.
3. Require the complete
   `Equal => Node(left, current_key, value, right)` arm exactly; failure:
   `insert replacement must change only the value and retain both branches`.
4. Require the mirror Greater arm, the one-node Empty base, and one
   `match compare key current_key {`, then compare the whole section exactly.

Check `lookup_counted` in this order:

1. Require
   `lookup_counted compare query Empty = (None, 0)`; failure:
   `counted lookup must report zero comparisons at Empty`.
2. Require the complete Less block with its left recursion and
   `(found, later_comparisons + 1)`; failure:
   `counted lookup must add the current Less comparison`.
3. Require the complete Greater block with its right recursion and
   `(found, later_comparisons + 1)`; failure:
   `counted lookup must add the current Greater comparison`.
4. Require exactly one top-level `match compare query key {`, the Equal arm
   `(Some(value), 1)`, and the expected counts of `left`, `right`, `found`, and
   `later_comparisons`, then compare the whole section exactly.

Check `maximum` and `height` in this order:

1. Require
   <!-- markdownlint-disable-next-line MD013 -->
   `height Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))`;
   failure: `height must add one above the maximum of both branch heights`.
2. Compare `maximum` to its exact signature and three structural equations.
3. Compare `height` to its exact signature, `Empty` equation, and `Node`
   equation. Confirm `maximum` remains private and `height` public.

Read all three complete entries into variables. Put their focused assertions
before exact full-entry comparisons:

- For `01-lookup.ash`, require the explicit `one`, `two`, and `three` bindings,
  the exact valid balanced `Node` shape, and the final pair of counted calls on
  the same `Trees.compare_natural` and `valid` value. Word counts must allow
  exactly one tree binding and two counted lookups.
- For `02-replace-and-malformed.ash`, first require the exact multiline
  malformed binding with `two` in the left branch of `one`; failure:
  `the malformed entry must place two in the left branch of one`. Next require
  `Trees.lookup Trees.compare_natural two malformed`; failure:
  `the malformed observation must query its misplaced key two`. Then require
  `with_two`, `original`, and `replaced` in their exact source order and the
  three final lookup calls on retained `original`, derived `replaced`, and
  accepted `malformed`.
- For `03-ascending.ash`, require
  `let after_one = Trees.insert Trees.compare_natural one 10 Trees.Empty`
  before any other insertion; failure:
  `the ascending entry must insert one before two`. Then require the exact
  `after_two` and `after_three` bindings and the same `after_three` value in
  the displayed tree, `height`, and counted lookup positions.

Compare each complete entry byte-for-byte with the Task 2 source after those
focused checks. Use `ash_doc_assert_contains` for multiline bindings and final
call tuples. The exact full-source comparisons and source-display agreement
prevent added calls or alternate construction paths.

Name these exact outputs, require each complete line exactly once inside a
README `text` fence, and pass the same values to three accepted runs:

<!-- markdownlint-disable MD013 -->
```bash
readonly lookup_output='((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))'
readonly replacement_output='(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)'
readonly ascending_output='(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : '\
'(Tree<Natural, Int>, Natural, (Option<Int>, Int))'
```
<!-- markdownlint-enable MD013 -->

Finish with `ash_doc_finish 4`. This case has no rejected source. Its negative
boundary is the accepted malformed tree and exact `None` result.

### Step 2: Make the verifier executable and check its shell syntax

Run:

```bash
chmod +x content/cases/searching-ordered-tree/checks/verify.sh
bash -n content/cases/searching-ordered-tree/checks/verify.sh
shellcheck -x content/cases/searching-ordered-tree/checks/verify.sh
```

Expected: all commands exit `0` without findings.

### Step 3: Run the verifier and confirm the first RED

Run:

```bash
bash content/cases/searching-ordered-tree/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: status `1` with exactly:

```text
verify: missing canonical source: src/ordered_trees.ash
```

Confirm this is the expected absent-production failure after pin preparation,
not a shell, helper, checkout, or build failure. Do not create a placeholder
README or source and do not commit the deliberate RED.

### Step 4: Review the RED contract

Give a fresh xhigh specification reviewer the uncommitted verifier, executable
mode, approved design, all four exact Task 2 source proposals, three outputs,
fourteen mutations, shared helper, and the exact RED transcript. It checks the
first-source precheck, subsequent missing-README transition, non-vacuous
section boundaries, source/display comparisons, focused failure ordering,
accepted-run ordering, exact pin, and local scope. After it passes, give a
different fresh high quality reviewer the same payload plus Bash syntax and
ShellCheck output. The quality reviewer checks quoting, failure clarity,
maintainability, and compatibility with Tasks 2 and 3. Fix and re-review every
finding; leave the verifier uncommitted.

## Task 2: Add and directly observe the canonical Ash programs

**Files:**

- Create: `content/cases/searching-ordered-tree/src/ordered_trees.ash`
- Create: `content/cases/searching-ordered-tree/src/01-lookup.ash`
- Create:
  `content/cases/searching-ordered-tree/src/02-replace-and-malformed.ash`
- Create: `content/cases/searching-ordered-tree/src/03-ascending.ash`

### Step 1: Add the exact shared ordered-tree module

Use this complete source:

<!-- markdownlint-disable MD013 -->
```ash
pub type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

pub type Ordering =
    Less
    | Equal
    | Greater

pub type Option<A> =
    None
    | Some(A)

pub type Natural =
    Zero
    | Next(Natural)

pub compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Zero = Equal
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>
lookup compare query Empty = None
lookup compare query Node(left, key, value, right) = match compare query key {
    Less => lookup compare query left
    Equal => Some(value)
    Greater => lookup compare query right
}

pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>
insert compare key value Empty = Node(Empty, key, value, Empty)
insert compare key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert compare key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert compare key value right)
}

pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)
lookup_counted compare query Empty = (None, 0)
lookup_counted compare query Node(left, key, value, right) = match compare query key {
    Less => {
        let (found, later_comparisons) = lookup_counted compare query left
        (found, later_comparisons + 1)
    }
    Equal => (Some(value), 1)
    Greater => {
        let (found, later_comparisons) = lookup_counted compare query right
        (found, later_comparisons + 1)
    }
}

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub height : Tree<K, V> -> Natural
height Empty = Zero
height Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))
```
<!-- markdownlint-enable MD013 -->

Keep `maximum` private. Do not add an interface, evidence selection, an opaque
dictionary, balancing, generic instrumentation, a shared tree library, or a
benchmark.

### Step 2: Add the exact lookup entry

Create `src/01-lookup.ash` with:

```ash
import ordered_trees as Trees

main : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let valid = Trees.Node(
        Trees.Node(Trees.Empty, one, 10, Trees.Empty),
        two,
        20,
        Trees.Node(Trees.Empty, three, 30, Trees.Empty)
    )
    (
        Trees.lookup_counted Trees.compare_natural three valid,
        Trees.lookup_counted Trees.compare_natural Trees.Zero valid
    )
}
```

### Step 3: Add the exact replacement and malformed-tree entry

Create `src/02-replace-and-malformed.ash` with explicit bindings that expose
the insertion order before reconstructing the accepted malformed `Node`:

<!-- markdownlint-disable MD013 -->
```ash
import ordered_trees as Trees

main : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let with_two = Trees.insert Trees.compare_natural two 20 Trees.Empty
    let original = Trees.insert Trees.compare_natural one 10 with_two
    let replaced = Trees.insert Trees.compare_natural one 99 original
    let malformed = Trees.Node(
        Trees.Node(Trees.Empty, two, 20, Trees.Empty),
        one,
        10,
        Trees.Empty
    )
    (
        Trees.lookup Trees.compare_natural one original,
        Trees.lookup Trees.compare_natural one replaced,
        Trees.lookup Trees.compare_natural two malformed
    )
}
```
<!-- markdownlint-enable MD013 -->

The `with_two` and `original` bindings preserve the approved semantic order:
insert `two -> 20` into `Empty`, then insert `one -> 10` into that retained
tree. Do not replace them with a manually constructed valid tree.

### Step 4: Add the exact ascending-insertion entry

Create `src/03-ascending.ash` with:

<!-- markdownlint-disable MD013 -->
```ash
import ordered_trees as Trees

main : Unit -> (Trees.Tree<Trees.Natural, Int>, Trees.Natural, (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let after_one = Trees.insert Trees.compare_natural one 10 Trees.Empty
    let after_two = Trees.insert Trees.compare_natural two 20 after_one
    let after_three = Trees.insert Trees.compare_natural three 30 after_two
    (
        after_three,
        Trees.height after_three,
        Trees.lookup_counted Trees.compare_natural three after_three
    )
}
```
<!-- markdownlint-enable MD013 -->

### Step 5: Build inside the exact checkout and run every entry directly

Run from the feature worktree:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
(
    cd "$ASH_DOC_PIN"
    cargo build --locked
)
(
    cd content/cases/searching-ordered-tree
    "$ASH_DOC_PIN/target/debug/ash" src/01-lookup.ash
    "$ASH_DOC_PIN/target/debug/ash" src/02-replace-and-malformed.ash
    "$ASH_DOC_PIN/target/debug/ash" src/03-ascending.ash
)
```

Building inside the checkout lets its `rust-toolchain.toml` select the pinned
toolchain and makes the resulting binary's provenance explicit. `--locked`
requires that checkout's lockfile resolution.

The exact standard-output lines, in entry order, are:

<!-- markdownlint-disable MD013 -->
```text
((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

Each invocation exits `0`, writes exactly its one line to standard output, and
leaves standard error empty. `rev-parse` reports
`dca16039923475c48025c5f17beadeb6bcb6a4bf`; pin status is empty. Stop and
classify any difference before changing the approved contract.

### Step 6: Prove the verifier advances to its second RED

Run:

```bash
bash content/cases/searching-ordered-tree/checks/verify.sh "$ASH_DOC_PIN"
```

Expected: status `1` with exactly:

```text
verify: missing unit README.md
```

This proves the first-source precheck now passes and the source set has
advanced to the deliberately absent chapter. Do not add placeholder prose and
do not commit sources separately.

### Step 7: Review the canonical programs and second RED

Give a fresh xhigh specification reviewer all four uncommitted sources, the
approved design, exact verifier contract, three direct stdout/stderr/status
records, pin identity, and missing-README RED. It compares every type,
equation, pattern, branch, binding order, output, invariant premise, and
exclusion with the design and pinned specification. After it passes, give a
different fresh high quality reviewer the same payload plus source style and
shell results. It checks descriptive names, adjacent signatures, four-space
indentation, complete entries, exact output readability, and absence of
unapproved machinery. Apply and re-review every finding. Keep verifier and
sources uncommitted until Task 3 makes the complete case green.

## Task 3: Write the chapter, turn GREEN, and audit mutations

**Files:**

- Create: `content/cases/searching-ordered-tree/README.md`
- Test: `content/cases/searching-ordered-tree/checks/verify.sh`
- Test: all files under `content/cases/searching-ordered-tree/src/`

### Step 1: Write one connected chapter

Use `@writing-ash-documentation`. Title the chapter
`How can an invariant let lookup ignore most of a tree?` Begin from the prior
chapter's direct search: a predicate could stop early, but it supplied no fact
that ruled out either branch after a mismatch. Establish the new working model
before the first command. At `Node(left, key, value, right)`, one comparison
chooses left, current value, or right; this choice is correct only when the
global descendant invariant and comparator premises hold.

Build this conceptual progression:

1. Introduce transparent `Tree<K, V>`, `Ordering`, `Option<A>`, and unary
   `Natural`, then transclude `src/ordered_trees.ash`. Derive the four
   `compare_natural` equations from the two Natural forms. Explain that a
   function with the same type need not implement a coherent total order.
2. State the comparator premises: required comparisons return; `Equal` names
   the chosen equivalence; reversing strict order reverses `Less` and
   `Greater`; strict order is transitive; and equivalent keys have the same
   ordering relationship to other keys. State the tree invariant globally:
   all keys anywhere in `left` compare as `Less`, all keys anywhere in `right`
   compare as `Greater`, and both subtrees satisfy the invariant.
3. Derive `lookup` from the invariant. `Empty` gives `None`. At a node, Ash
   completes `compare query key`, selects one match arm, and evaluates only
   that arm. Under the invariant, `Less` rules out the whole right subtree and
   `Greater` rules out the whole left subtree.
4. Transclude `src/01-lookup.ash`. Ask the reader to predict the path for
   `three` and `Zero`, then run
   `ash searching-ordered-tree/src/01-lookup.ash`. Interpret both value/type
   pairs and both counts of `2`. Make clear that `lookup_counted` counts visited
   `Node` forms and top-level comparator applications, not recursive calls
   inside `compare_natural`.
5. Derive comparison work. With unary size notation, state
   `C(q, k) = min(|q|, |k|) + 1` for completed `compare_natural` calls,
   including the terminal equation. Calculate the hit's `3 + 4 = 7` internal
   comparison applications and the miss's `1 + 1 = 2`, while both report two
   top-level comparisons.
6. Derive insertion. At `Empty`, construct one node. On `Less` or `Greater`,
   rebuild the selected path while retaining the other branch. On `Equal`,
   retain `current_key` and both branches and replace only the value. Explain
   why retaining the stored representative matters when a generic comparator
   regards distinguishable key values as equivalent.
7. Transclude `src/02-replace-and-malformed.ash`. Predict the older `Some(10)`,
   replacement `Some(99)`, and accepted malformed `None`; then run its command.
   The exact command is
   `ash searching-ordered-tree/src/02-replace-and-malformed.ash`.
   Explain the explicit `with_two`, `original`, and `replaced` values. Trace
   the malformed lookup: `two` is structurally in the left branch of root
   `one`, but `Greater` selects the empty right branch. The nominal transparent
   type accepts the shape and does not prove the invariant.
8. Give the preservation argument under the stated comparator premises and a
   finite valid input. Each unequal case inserts into the only admissible
   branch and retains the other; equality changes no key or branch. Label this
   as reasoning about these programs, not an Ash language guarantee.
9. Transclude `src/03-ascending.ash`. Predict the three-node right chain, unary
   height `3`, and counted last-key lookup `3`; then run it.
   The exact command is `ash searching-ordered-tree/src/03-ascending.ash`.
   Contrast this with the earlier balanced three-node tree's height `2`.
   Generalize only to the supported boundary: ascending insertion can produce
   `h = n`, so this representation gives no logarithmic guarantee.
10. State the cost model. For a completed lookup visiting `k_1` through
    `k_m`, comparison sub-work is `sum C(query, k_i)` and surrounding named
    source work is `O(m)`. A one-branch lookup has `m <= h`. Only when every
    visited comparison has `C(query, k_i) <= Cmax` with `Cmax >= 1` may the
    account be summarized as `O(h * Cmax)`. Keep arbitrary-precision integer
    bit cost outside this count.
11. State return and structural boundaries. A lookup on a finite tree returns
    when every comparison on its entered path returns. An unentered branch
    needs no comparison-return premise. A required nonreturning comparison or
    a reachable constructor-guarded cycle may prevent return. `height`
    traverses both branches and its private unary `maximum` performs separate
    work; do not use it to claim elapsed time, runtime storage, or native stack
    behavior.
12. Give practice that asks the reader to classify a supplied tree against the
    global invariant, predict the selected lookup path, and repair one
    misplaced key. A second exercise changes a query and compares reported
    node visits with derived Natural comparison work. End with the repetition
    exposed by every operation receiving `compare`: how can an `Order<A>`
    interface let checking select that evidence?

Transclude all four canonical sources with unique
`<!-- source: src/... -->` markers. Every `ash` block is byte-for-byte
identical to its canonical source. Use `text` fences for commands, outputs,
calculations, tree sketches, and other non-executable notation. Put each
prediction before its command and interpret the complete observed value and
type after it.

Keep language authority claim-local. Use the approved design's exact pinned
links beside the first claims they support:

- syntax grammar and global function presentations for parameterized data,
  patterns, curried explicit-comparator functions, blocks, and equations;
- imports and namespaces, type and constructor scope, and global scope for the
  shared module, transparent constructors, and recursive globals;
- static tuples and constructors, functions and application, patterns and
  coverage, blocks, recursive block groups, primitive operations, and globals
  and modules for accepted programs and the cyclic-value boundary;
- dynamic bindings, recursive bindings, application, constructor matches,
  primitive operations, and observation for strict comparison, selected-arm
  execution, retained values, arithmetic counts, cycles, and rendered
  structures; and
- the pinned successful-output contract for each exact output line, empty
  standard error, and status `0`.

Do not render an edition target, governing-source inventory, canonical-source
inventory, or verification report. Link the existing [HtDP research
record](../../research/how-to-design-programs-recursive-algorithms.md) and
credit only inspiration for deriving functions from self-referential data and
counting named source operations. The chapter's link needs one additional
`..` path component. State that the prose, programs, tree shapes,
calculations, and exercises are original; do not translate its examples,
sequence, or teaching-language behavior. No new source record is needed.

Keep these exclusions explicit: interfaces and evidence selection, opacity,
balancing, deletion, mutation, iteration, generic tree infrastructure, a new
harness, manifest, renderer, or research record; elapsed time, machine
instructions, runtime or host stack behavior, tail-call optimization, heap
layout or bytes, garbage collection, pointer identity, physical sharing,
compiler representation or optimization, and arbitrary-precision integer bit
cost. Do not claim comparator laws, tree validity, finiteness, logarithmic
height, or logarithmic lookup from the nominal type.

### Step 2: Read and verify the complete case

Read the README, verifier, and all four sources fully. Run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/searching-ordered-tree/checks/verify.sh "$ASH_DOC_PIN"
npx --yes markdownlint-cli2 \
    content/cases/searching-ordered-tree/README.md
bash -n content/cases/searching-ordered-tree/checks/verify.sh
shellcheck -x content/cases/searching-ordered-tree/checks/verify.sh
if command -v typos >/dev/null 2>&1; then
    typos content/cases/searching-ordered-tree
fi
git diff --check
git status --short
```

Expected local verifier output:

```text
Verified 4 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

Status contains only the uncommitted complete case; both planning records
remain present and tracked. Do not call the case complete before the mutation
audit and two independent reviews.

### Step 3: Prove all fourteen focused assertions can fail

Perform the mutations below one at a time only after the complete case first
passes. Use `apply_patch` for each change and restoration. Change canonical
source and its marked README block together so source agreement remains green
and the intended focused assertion runs. Require verifier status `1` and the
exact message below. Restore exact text with `apply_patch`, rerun, and require
the exact green summary before beginning the next mutation. Preserve all
fourteen failure transcripts for Task 3 and whole-branch review.

1. In both copies, replace
   `compare_natural Zero Next(right) = Less` with
   `compare_natural Zero Next(right) = Greater`.
   Expect
   `verify: compare_natural must order Zero before every Next value`.
2. Restore, then replace
   `compare_natural Next(left) Next(right) = compare_natural left right` with
   `compare_natural Next(left) Next(right) = Equal`.
   Expect
   `verify: compare_natural must structurally compare both Next payloads`.
3. Restore, then replace lookup's
   `Less => lookup compare query left` with
   `Less => lookup compare query right`.
   Expect
   `verify: lookup must enter only the left branch after Less`.
4. Restore, then replace lookup's
   `Greater => lookup compare query right` with
   `Greater => lookup compare query left`.
   Expect
   `verify: lookup must enter only the right branch after Greater`.
5. Restore, then replace
   `lookup_counted compare query Empty = (None, 0)` with
   `lookup_counted compare query Empty = (None, 1)`.
   Expect
   `verify: counted lookup must report zero comparisons at Empty`.
6. Restore, then replace only the Less block's
   `(found, later_comparisons + 1)` with `(found, later_comparisons)`.
   Expect
   `verify: counted lookup must add the current Less comparison`.
7. Restore, then make the same replacement only in the Greater block.
   Expect
   `verify: counted lookup must add the current Greater comparison`.
8. Restore, then change insert's Less arm to recurse into `right` while keeping
   the constructor fields type-correct:

   <!-- markdownlint-disable-next-line MD013 -->
   ```text
   Less => Node(left, current_key, current_value, insert compare key value right)
   ```

   Expect
   `verify: insert must recurse left and retain the right branch after Less`.
9. Restore, then change only insert's Equal result from `current_key` to the
   incoming `key`.
   Expect
   `verify: insert replacement must retain the stored representative key`.
10. Restore, then change the Equal result to
    `Node(right, current_key, value, right)`.
    Expect
    `verify: insert replacement must change only the value and retain both branches`.
11. Restore, then move `two` from the malformed tree's left branch to its
    right branch in `02-replace-and-malformed.ash` and its displayed block:

    ```ash
    let malformed = Trees.Node(
        Trees.Empty,
        one,
        10,
        Trees.Node(Trees.Empty, two, 20, Trees.Empty)
    )
    ```

    Expect
    `verify: the malformed entry must place two in the left branch of one`.
12. Restore, then change only the malformed lookup query from `two` to `one`.
    Expect
    `verify: the malformed observation must query its misplaced key two`.
13. Restore, then reverse the first two ascending insertions while retaining
    well-typed sequential names:

    <!-- markdownlint-disable MD013 -->
    ```text
    let after_one = Trees.insert Trees.compare_natural two 20 Trees.Empty
    let after_two = Trees.insert Trees.compare_natural one 10 after_one
    ```

    Expect
    `verify: the ascending entry must insert one before two`.
14. Restore, then replace the height equation's
    `Next(maximum (height left) (height right))` with
    `Next(height left)`.
    Expect
    `verify: height must add one above the maximum of both branch heights`.

The focused assertions precede whole-section, full-entry, transcript, and
runtime checks, so each mutation fails for the stated causal relationship.
End with no mutation residue and one final exact green local verifier run.

### Step 4: Review the complete GREEN case

Give a fresh xhigh specification reviewer the complete uncommitted case, the
approved design, exact Task 3 chapter contract, four sources, direct pin
outputs, verifier, fourteen named RED transcripts, and final GREEN transcript.
The reviewer checks every semantic conclusion against claim-local authority;
the global descendant invariant and comparator premises; selected-arm
evaluation; representative-key replacement; retained older value; malformed
accepted miss; `C(q, k)` derivation; `m`, `h`, and `Cmax`; ascending `h = n`;
height helper separation; return and cycle boundaries; attribution;
continuity; and exclusions.

After specification review passes, give a different fresh xhigh quality
reviewer the same payload. Require source/display agreement, a connected
teaching arc, prediction before commands, interpretation after outputs,
readable prose, exact source style, non-vacuous checks, intended mutation
failure ordering, local scope, and maintainability. The same implementer fixes
findings and each reviewer rechecks its own findings. Rerun every Step 2 check
after review changes.

### Step 5: Commit the complete case as one unit

Use `@superpowers:verification-before-completion`. Read every case file as
source. Rerun the local verifier, Markdownlint, Bash syntax, ShellCheck,
optional spelling, `git diff --check`, and `git status --short`. Commit only
when prose, sources, and checks pass together:

```bash
git add content/cases/searching-ordered-tree
git commit --no-gpg-sign -m "docs: teach searching an ordered tree"
```

Do not include roadmap integration or remove planning records in this commit.

## Task 4: Draft, review, and close repository integration

**Files:**

- Modify: `README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Delete after review:
  `docs/plans/2026-08-30-searching-ordered-tree-design.md`
- Delete after review: `docs/plans/2026-08-30-searching-ordered-tree.md`

### Step 1: Preserve the later provisional text before editing

Record the exact base text from `### 8. Protecting the dictionary invariant`
through the line before `## Promotion and verification policy`:

```bash
git show ebe1847:docs/project/roadmap.md |
    sed -n '/^### 8\. Protecting the dictionary invariant$/,/^## Promotion and verification policy$/p' |
    sed '$d' > /tmp/searching-ordered-tree-cases-8-12.before
```

This read-only snapshot is a temporary review aid, not a repository artifact.
Cases 8 through 12 must remain byte-for-byte identical while case 7 moves from
provisional to Next.

### Step 2: Draft navigation and roadmap closure with both records active

Add `How can an invariant let lookup ignore most of a tree?` as item 6 under
`Cases in order`. Summarize the valid global ordering invariant, explicit
comparison, one-branch lookup, accepted malformed miss, and unbalanced
ascending insertion. Extend the root recursive-algorithm summary from five to
six verified cases without repeating setup or the edition target.

Draft the roadmap transition while both temporary records still exist and are
linked. Move `Searching an ordered tree` under `Verified increments` as item
6. Record:

- four canonical sources and three exact accepted outputs at the exact pin;
- a manually valid balanced tree with successful and missing paths, each with
  two visited nodes and two top-level comparisons;
- recursive Natural comparison work of `7` for the hit and `2` for the miss;
- the global descendant invariant and coherent-total-order, equivalence, and
  comparison-return premises;
- insertion preservation under those premises, duplicate value replacement
  with stored representative key and branches retained, and observable older
  and replacement values;
- the accepted malformed tree whose misplaced `two` is hidden from lookup;
- the exact comparison sum, `O(m)` surrounding work, `m <= h`, and the
  conditional `O(h * Cmax)` summary;
- ascending insertion's three-node right chain, height `3`, three visited
  nodes, and the general possibility `h = n`, without a logarithmic claim;
- `height` and private unary `maximum` as separate work;
- finiteness, returning-comparison, cyclic-value, source-level cost, runtime,
  storage, identity, optimization, and arbitrary-precision exclusions; and
- exact verification at Ash
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

Update repository state to six verified unpublished recursive-algorithm cases.
Promote case 7 to `## Next: abstracting key order`. Preserve its audited
question and content, then add the standard gate: approve a bounded design and
link an active temporary implementation plan before creating any case content
or source. Keep cases 8 through 12 provisional, with their text, numbering,
and order byte-for-byte unchanged.

In the draft verified increment, retain one temporary sentence that links the
searching-ordered-tree design and implementation plan and says repository
closure review remains active. Do not delete either record. Their roadmap
links own the work through specification and quality review.

### Step 3: Verify the complete integration draft

First prove cases 8 through 12 remain exact:

```bash
sed -n '/^### 8\. Protecting the dictionary invariant$/,/^## Promotion and verification policy$/p' \
    docs/project/roadmap.md |
    sed '$d' > /tmp/searching-ordered-tree-cases-8-12.after
cmp -s /tmp/searching-ordered-tree-cases-8-12.before \
    /tmp/searching-ordered-tree-cases-8-12.after
```

Run Markdown and spelling checks:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
```

Run this exact manual relative-link check without adding a dependency, script,
or harness:

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

Then run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/searching-ordered-tree/checks/verify.sh
shellcheck -x content/cases/searching-ordered-tree/checks/verify.sh
bash content/cases/searching-ordered-tree/checks/verify.sh "$ASH_DOC_PIN"
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
find content/learn -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l
find content/cases -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l
find content/cases -mindepth 3 -maxdepth 3 -type f \
    -path '*/src/*.ash' | wc -l
git diff --check
git status --short
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: the lesson verifier reports four sources; 11 Learn lessons pass; 6
Cases and 28 canonical Case sources pass at the exact pin; all static and
relative-link checks have no findings; only `README.md`,
`content/cases/README.md`, and `docs/project/roadmap.md` appear in status; the
documentation tag peels to
`e963a1597176f86003926eef827498db2a661b75`; and the clean pin reports
`dca16039923475c48025c5f17beadeb6bcb6a4bf`.

### Step 4: Run independent repository-closure reviews

Give a fresh xhigh specification reviewer the approved design and plan from
the worktree, Task 3's fourteen RED transcripts and final GREEN transcript,
the committed case diff, the uncommitted integration diff, exact-pin output,
the cases-8-through-12 byte comparison, and the complete roadmap. Require it
to check exact counts and commits; language/tool authority; invariant and
comparator premises; costs and preconditions; insertion, replacement,
malformation, height, and exclusions; root and Cases navigation; six-case
unpublished state; case 7 promotion; later provisional non-authorization; and
both active plan links.

Only after that review passes, give a different fresh xhigh quality reviewer
the same payload and the full changed files. Require clear project prose,
working navigation, complete durable evidence, exact preservation of cases 8
through 12, correct relative links, and a reviewable deletion boundary. The
same integration implementer fixes findings; each reviewer rechecks its own
findings. Rerun all Step 3 checks after review changes. Do not remove either
record until both reviews and fresh verification pass.

### Step 5: Delete exactly the temporary records and verify closure

Remove the draft's temporary active-review sentence. Use `apply_patch`, not a
shell deletion command, to delete exactly:

```text
docs/plans/2026-08-30-searching-ordered-tree-design.md
docs/plans/2026-08-30-searching-ordered-tree.md
```

Check that no live tracked or untracked file names either record:

```bash
if rg -n \
    '2026-08-30-searching-ordered-tree(-design)?\.md' \
    --glob '!.git/**'; then
    printf 'live file still references a completed case-6 record\n' >&2
    exit 1
fi
```

Read `README.md`, `content/cases/README.md`, and
`docs/project/roadmap.md` fully as source. Rerun the cases-8-through-12 byte
comparison, Markdownlint, optional spelling, exact relative-link loop, Bash
syntax, ShellCheck, lesson verifier, both content aggregators, 11/6/28 counts,
tag and pin checks, `git diff --check`, and `git status --short`.

Commit the reviewed closure:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-30-searching-ordered-tree-design.md \
    docs/plans/2026-08-30-searching-ordered-tree.md
git commit --no-gpg-sign -m "docs: verify searching an ordered tree case"
git diff --check HEAD^..HEAD
git status --short --branch
```

Expected: the closure commit succeeds, its diff check is empty, the feature
worktree is clean, and Git history retains both removed records.

## Task 5: Review, verify, merge locally, and clean up

**Files:**

- Review: all changes from `main...searching-ordered-tree`

### Step 1: Review the complete closed branch

Use `@superpowers:requesting-code-review` for one fresh xhigh whole-branch
reviewer. The review payload contains:

- base `ebe1847`, current feature HEAD, and `git diff --stat` plus
  `git diff main...HEAD`;
- the deleted design and plan recovered with `git show` from their last
  pre-deletion commit;
- all final changed files read as source;
- three direct accepted observations and the local/aggregate verifier output;
- all fourteen mutation messages and the final restoration GREEN;
- cases-8-through-12 byte-preservation evidence;
- tag `e963a1597176f86003926eef827498db2a661b75` and pin
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`; and
- the final roadmap state and deletion-reference check.

The reviewer compares the final branch with the recovered records line by
line, reruns exact-pin evidence, checks navigation and closure, and reports
findings by severity with file and line. Apply technically verified feedback
through `@superpowers:receiving-code-review`; re-review every change before
final verification.

If review changes an authorized file, rerun its local verifier and static
checks, obtain approval for the uncommitted correction, and commit:

```bash
git add README.md content/cases/README.md \
    content/cases/searching-ordered-tree docs/project/roadmap.md
git commit --no-gpg-sign -m \
    "docs: address searching an ordered tree review"
git diff --check HEAD^..HEAD
git status --short --branch
```

Do not create an empty review-fix commit. A finding outside these paths needs a
new bounded scope decision before editing.

### Step 2: Run exact final feature-branch verification

Use `@superpowers:verification-before-completion`. Run from the feature
worktree:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/searching-ordered-tree/checks/verify.sh
shellcheck -x content/cases/searching-ordered-tree/checks/verify.sh
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash content/cases/searching-ordered-tree/checks/verify.sh "$ASH_DOC_PIN"
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
find content/learn -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l
find content/cases -mindepth 3 -maxdepth 3 -type f \
    -path '*/checks/verify.sh' | wc -l
find content/cases -mindepth 3 -maxdepth 3 -type f \
    -path '*/src/*.ash' | wc -l
git diff --check main...HEAD
git status --short --branch
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Regenerate `/tmp/searching-ordered-tree-cases-8-12.before` from commit
`ebe1847`, rerun the exact relative-link loop and cases-8-through-12 byte
comparison from Task 4, then read `git diff main...HEAD` and every changed file
as source.

Expected: 11 Learn lessons, 6 Cases, and 28 canonical Case sources pass at the
exact pin; all static and relative-link checks have no findings; branch and
pin are clean; the tag and pin report the exact commits above; and the roadmap
contains no live reference to either deleted case-6 record.

### Step 3: Merge without pushing and verify local `main`

The autonomous integration request selects the local-merge option from
`@superpowers:finishing-a-development-branch`. Confirm local `main` is clean
and inspect any movement since base `ebe1847`. Resolve unexpected divergence
before merging. Do not push. Merge:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    -m "Merge branch 'searching-ordered-tree'" searching-ordered-tree
```

From local `main`, run the complete merged-state verification. Exclude the
still-present worktree from repository-wide discovery so each tracked file is
checked once:

```bash
ASH_DOC_ROOT=/home/dikini/Projects/ash-doc
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n "$ASH_DOC_ROOT/content/cases/searching-ordered-tree/checks/verify.sh"
shellcheck -x \
    "$ASH_DOC_ROOT/content/cases/searching-ordered-tree/checks/verify.sh"
(
    cd "$ASH_DOC_ROOT"
    npx --yes markdownlint-cli2 '**/*.md' '#.worktrees/**'
    if command -v typos >/dev/null 2>&1; then
        typos --exclude '.worktrees/**'
    fi
    bash content/cases/searching-ordered-tree/checks/verify.sh "$ASH_DOC_PIN"
    bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
    bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
    while IFS= read -r file; do
        while IFS= read -r target; do
            link_path=${target%%#*}
            [[ -z $link_path || $link_path == http://* ]] && continue
            [[ $link_path == https://* || $link_path == \#* ]] && continue
            [[ -e "$(dirname "$file")/$link_path" ]] || {
                printf 'broken relative link: %s -> %s\n' \
                    "$file" "$target" >&2
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
    done < <(rg --files -g '*.md' -g '!.worktrees/**')
    find content/learn -mindepth 3 -maxdepth 3 -type f \
        -path '*/checks/verify.sh' | wc -l
    find content/cases -mindepth 3 -maxdepth 3 -type f \
        -path '*/checks/verify.sh' | wc -l
    find content/cases -mindepth 3 -maxdepth 3 -type f \
        -path '*/src/*.ash' | wc -l
    git diff --check origin/main...main
    git status --short --branch
    git rev-parse 'modular-ash^{commit}'
)
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: Bash syntax, ShellCheck, Markdown, optional spelling, relative links,
and diff checks have no findings; 11 Learn lessons, 6 Cases, and 28 canonical
Case sources pass at the exact pin; local `main` and pin are clean; and the tag
and pin report the exact commits above.

Only after the merged state passes, remove the worktree and delete the merged
branch:

```bash
git -C /home/dikini/Projects/ash-doc worktree remove \
    /home/dikini/Projects/ash-doc/.worktrees/searching-ordered-tree
git -C /home/dikini/Projects/ash-doc branch -d searching-ordered-tree
```

Do not push. Keep the autonomous remaining-cases goal active and begin the
newly promoted `Abstracting key order` bounded design after this local merge
checkpoint.
