# Association-list dictionary implementation plan

<!-- markdownlint-disable-next-line MD013 -->
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Publish one verified Cases chapter that shows how front insertion,
explicit equality, and selective recursion determine association-list lookup
behavior and source work while preserving older dictionary values.

**Architecture:** Add one lesson-local transparent dictionary module with
ordinary and counted selective lookup. A private strict right fold and
combiner support one counted contrast that returns the same front-shadowing
value after visiting every entry. Four complete entries observe ordinary hit
and absence, selective counts, selective-versus-fold work, and retained older
and newer versions.

**Tech stack:** Markdown, Ash, Bash, ShellCheck, Git, and the `ash` executable
built from exact Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Execution boundary

Work only in the `association-list-dictionary` branch and its existing
worktree. Use the clean pinned checkout at
`/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin` for
every executable observation. Do not change the edition target, immutable
`modular-ash` tag, shared content infrastructure, or `ash-lang`.

The reader asks what lookup costs when a dictionary is a recursive list. The
observable boundary crosses the result of `same_key query key`: a true branch
returns immediately, while a false branch alone follows `rest`. A strict right
fold obtains the complete tail result before testing the current entry. Source
construction makes the previous dictionary the new front node's tail; it does
not expose object identity, heap bytes, collection, or compiler representation.

Use `@superpowers:test-driven-development` for Tasks 1 through 3. Before writing
the chapter, navigation, roadmap, review messages, or commits in Tasks 3 through
5, use the project-local `@writing-ash-documentation` skill. After each of
Tasks 1 through 4, dispatch a fresh specification reviewer and, only after
compliance passes, a fresh quality reviewer. Apply and re-review every verified
finding before proceeding.

## Task 1: Add the case verifier and establish red

**Files:**

- Create: `content/cases/dictionary-as-list/checks/verify.sh`

### Step 1: Create the executable verifier

Add a Bash verifier with `set -euo pipefail`. Derive `unit_root` and
`content_root` like the preceding case, source `content/checks/lib.sh`, require
one pinned Ash checkout argument, call `ash_doc_prepare`, and declare these
five canonical sources in order:

```bash
readonly sources=(
    src/dictionaries.ash
    src/01-ordinary-lookup.ash
    src/02-counted-lookup.ash
    src/03-selective-and-fold.ash
    src/04-retained-versions.ash
)
```

After `ash_doc_check_sources`, reuse the hardened lesson-local section,
word-count, phrase-count, and suffix helpers from the accumulator case. The
section helper must fail when its start or nonempty end marker is absent. Use
these exact adjacent boundaries:

<!-- markdownlint-disable MD013 -->
```text
representations:
    pub type Entry<K, V> =
    -> pub empty : Unit -> Dictionary<K, V>
empty:
    pub empty : Unit -> Dictionary<K, V>
    -> pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
insert:
    pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
    -> pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup:
    pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
    -> pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_counted:
    pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
    -> fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B
fold_entries:
    fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B
    -> prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)
prefer_current:
    prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)
    -> pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
fold wrapper:
    pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
    -> end of file
```
<!-- markdownlint-enable MD013 -->

Add a lesson-local transcript helper that counts an expected full line only
while inside a `text` fence and requires exactly one occurrence:

```bash
ash_doc_assert_text_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail \
            "ash_doc_assert_text_line_once requires expected line and claim"
    fi

    local expected_line=$1
    local claim=$2
    local actual_count
    actual_count=$(
        awk -v expected="$expected_line" '
            $0 == "```text" { inside = 1; next }
            inside && $0 == "```" { inside = 0; next }
            inside && $0 == expected { count += 1 }
            END { print count + 0 }
        ' "$readme"
    )

    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected 1)"
}
```

Assert these causal relationships:

- `Entry<K, V>` has exactly `Entry(K, V)`, `Dictionary<K, V>` has exactly
  `Empty | More(Entry<K, V>, Dictionary<K, V>)`, and `Option<A>` has exactly
  `None | Some(A)`;
- `empty () = Empty` and
  `insert key value dictionary = More(Entry(key, value), dictionary)`; the
  insert section contains exactly two `insert` words, one `Entry`, one `More`,
  and zero `same_key`, `lookup`, and `fold_entries` words;
- ordinary lookup returns `None` at `Empty`, applies
  `same_key query key` exactly once in its nonempty equation, returns
  `Some(value)` in the true arm, and has its only recursive occurrence as
  `false => lookup same_key query rest`; require exactly four `lookup` and four
  `same_key` words in this section;
- counted lookup returns `(None, 0)`, returns `(Some(value), 1)` at the current
  match, contains exactly one `match same_key query key {`, recursively obtains
  `(found, later_comparisons)` only in the false branch, and returns
  `(found, later_comparisons + 1)`; require exactly four `lookup_counted` and
  four `same_key` words in this section, and assert the complete nonempty
  equation as the section suffix so the recursive binding remains inside the
  false arm;
- `fold_entries` binds `folded_rest` from exactly one recursive call before the
  final `combine entry folded_rest` expression; require exactly four
  `fold_entries` words and four `combine` words, and assert the complete
  nonempty equation as the section suffix;
- `prefer_current` applies equality once, returns the current `Some(value)` on
  true, retains `found` on false, and contains exactly two
  `comparisons + 1` expressions; require exactly two `prefer_current` and two
  `same_key` words;
- `lookup_through_fold_counted` invokes `fold_entries` exactly once with
  `(prefer_current same_key query)` and `(None, 0)`; require exactly two wrapper
  name occurrences and one each of `fold_entries` and `prefer_current`;
- every entry contains exactly one
  `int_equal left right = left == right`, and the complete entry contains four
  `int_equal` words: signature, definition, and two calls;
- every entry constructs `(1, 10)`, `(2, 20)`, and `(1, 11)` through the same
  ordered insertion dependency chain. The first three entries must use
  `empty_dictionary`, `first_dictionary`, `second_dictionary`, then
  `dictionary`; the retained entry must use `empty_dictionary`,
  `first_dictionary`, `older_dictionary`, then `newer_dictionary`;
- the selective/fold entry passes the same query and dictionary to both
  counted operations; and
- the retained-version entry passes `older_dictionary` directly to the final
  insertion and subsequently looks up both `older_dictionary` and
  `newer_dictionary`.

Add named exact outputs, require each exactly once inside a README `text` fence
with `ash_doc_assert_text_line_once`, and pass the same values to four accepted
runs:

```bash
readonly ordinary_output='(Some(11), None) : (Option<Int>, Option<Int>)'
readonly counted_output='((Some(11), 1), (None, 3)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'
readonly fold_output='((Some(11), 1), (Some(11), 3)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'
readonly retained_output='((Some(10), 2), (Some(11), 1)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'
```

Finish with `ash_doc_finish 5`. This case has no rejected program. Its semantic
negative is the accepted `None` after three comparisons.

### Step 2: Make the verifier executable and check its shell syntax

Run:

```bash
chmod +x content/cases/dictionary-as-list/checks/verify.sh
bash -n content/cases/dictionary-as-list/checks/verify.sh
shellcheck -x content/cases/dictionary-as-list/checks/verify.sh
```

Expected: every command exits `0` without findings.

### Step 3: Run the verifier and confirm red

Run:

```bash
bash content/cases/dictionary-as-list/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: status `1` with `verify: missing unit README.md`. Do not commit this
deliberately red state.

### Step 4: Review the red contract

Dispatch a specification reviewer with the exact verifier contract above, then
a separate quality reviewer. They must inspect the uncommitted script, its
executable mode, shell checks, expected red, section non-vacuity, exact counts,
and compatibility with the Task 2 sources. Apply and re-review every finding;
leave the reviewed verifier uncommitted for the complete case.

## Task 2: Implement and directly observe the canonical Ash programs

**Files:**

- Create: `content/cases/dictionary-as-list/src/dictionaries.ash`
- Create: `content/cases/dictionary-as-list/src/01-ordinary-lookup.ash`
- Create: `content/cases/dictionary-as-list/src/02-counted-lookup.ash`
- Create: `content/cases/dictionary-as-list/src/03-selective-and-fold.ash`
- Create: `content/cases/dictionary-as-list/src/04-retained-versions.ash`

### Step 1: Add the shared dictionary module

Write this exact module. Keep each global signature and the final fold-wrapper
equation on one physical line; the exact pin rejects a bare newline immediately
after an equational `=`.

<!-- markdownlint-disable MD013 -->
```ash
pub type Entry<K, V> =
    Entry(K, V)

pub type Dictionary<K, V> =
    Empty
    | More(Entry<K, V>, Dictionary<K, V>)

pub type Option<A> =
    None
    | Some(A)

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
insert key value dictionary = More(Entry(key, value), dictionary)

pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup same_key query Empty = None
lookup same_key query More(Entry(key, value), rest) = match same_key query key {
    true => Some(value)
    false => lookup same_key query rest
}

pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_counted same_key query Empty = (None, 0)
lookup_counted same_key query More(Entry(key, value), rest) = match same_key query key {
    true => (Some(value), 1)
    false => {
        let (found, later_comparisons) = lookup_counted same_key query rest
        (found, later_comparisons + 1)
    }
}

fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B
fold_entries combine base Empty = base
fold_entries combine base More(entry, rest) = {
    let folded_rest = fold_entries combine base rest
    combine entry folded_rest
}

prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)
prefer_current same_key query Entry(key, value) (found, comparisons) = match same_key query key {
    true => (Some(value), comparisons + 1)
    false => (found, comparisons + 1)
}

pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_through_fold_counted same_key query dictionary = fold_entries (prefer_current same_key query) (None, 0) dictionary
```
<!-- markdownlint-enable MD013 -->

Keep the fold helpers private and lesson-local. Do not add a shared collection
library, equality interface, tree, opacity, deletion, mutation, or generic
instrumentation framework.

### Step 2: Add the four complete entries

Write `src/01-ordinary-lookup.ash`:

<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> (Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup int_equal 1 dictionary,
        Dictionaries.lookup int_equal 3 dictionary
    )
}
```
<!-- markdownlint-enable MD013 -->

Write `src/02-counted-lookup.ash`:

<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> ((Dictionaries.Option<Int>, Int), (Dictionaries.Option<Int>, Int))
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup_counted int_equal 1 dictionary,
        Dictionaries.lookup_counted int_equal 3 dictionary
    )
}
```
<!-- markdownlint-enable MD013 -->

Write `src/03-selective-and-fold.ash`:

<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> ((Dictionaries.Option<Int>, Int), (Dictionaries.Option<Int>, Int))
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup_counted int_equal 1 dictionary,
        Dictionaries.lookup_through_fold_counted int_equal 1 dictionary
    )
}
```
<!-- markdownlint-enable MD013 -->

Write `src/04-retained-versions.ash`:

<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> ((Dictionaries.Option<Int>, Int), (Dictionaries.Option<Int>, Int))
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let older_dictionary = Dictionaries.insert 2 20 first_dictionary
    let newer_dictionary = Dictionaries.insert 1 11 older_dictionary
    (
        Dictionaries.lookup_counted int_equal 1 older_dictionary,
        Dictionaries.lookup_counted int_equal 1 newer_dictionary
    )
}
```
<!-- markdownlint-enable MD013 -->

### Step 3: Run every entry directly against the exact pin

Run from the new case directory:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
(
    cd "$ASH_DOC_PIN"
    cargo build --locked
)
"$ASH_DOC_PIN/target/debug/ash" src/01-ordinary-lookup.ash
"$ASH_DOC_PIN/target/debug/ash" src/02-counted-lookup.ash
"$ASH_DOC_PIN/target/debug/ash" src/03-selective-and-fold.ash
"$ASH_DOC_PIN/target/debug/ash" src/04-retained-versions.ash
```

Expected output is exactly the four strings from Task 1. Every command must
exit `0`, and the four `ash` runs must have empty standard error. `rev-parse`
must report `dca16039923475c48025c5f17beadeb6bcb6a4bf`; pinned status must be
empty; the locked build must succeed under the checkout's selected Rust
toolchain. Running Cargo from the pinned checkout is required because Rustup
selects a directory's toolchain before Cargo resolves an external
`--manifest-path`. If pinned behavior differs, stop and classify the difference
before changing the lesson contract.

### Step 4: Review the canonical programs

Dispatch separate specification and quality reviewers. They must read the five
uncommitted sources, run all entries at the exact pin, and inspect the reviewed
verifier for compatibility. Require the selected insert order, selective
branching, count meanings, strict fold order, retained-tail relationship,
generic typing, source style, exact outputs, and scope boundaries. Apply and
re-review every finding; do not commit before prose and checks can land
together.

## Task 3: Write the chapter and make its evidence green

**Files:**

- Create: `content/cases/dictionary-as-list/README.md`
- Test: `content/cases/dictionary-as-list/checks/verify.sh`

### Step 1: Write the chapter around selective recursion

Title the chapter `What does lookup cost when a dictionary is a recursive
list?` Continue directly from the accumulator case's front construction and
retained-state account. Include these conceptual moves:

1. Introduce `Entry`, `Dictionary`, `Option`, `empty`, and `insert`. Explain
   newest-to-oldest order and predict why the later duplicate shadows the
   older value without deleting it.
2. Show ordinary hit and missing lookup. Explain one equality application per
   visited entry, recursion only in the false arm, first front match, and
   accepted `None` after the complete miss.
3. Show counted lookup. Define front position `m`, derive one and three
   comparisons for the fixtures, and state worst-case linear comparison and
   `More`-visit counts.
4. Define `E_q(k_i)` as the complete supplied equality work for fixed query
   `q`. Give `O(m + sum E_q(k_i))`; use `O(m * (1 + Emax))` only under an
   explicit uniform bound. Explain that `int_equal` gives one primitive integer
   equality per visited entry. State beside the formula that the dictionary is
   finite and each required equality application returns. Do not present the
   counter as elapsed time or internal equality work.
5. Show the selective/fold observation. Explain strict folded-rest binding,
   why a current match replaces the older folded result, and why the fold still
   performs three comparisons. State that the comparison assumes all required
   equality applications return; the fold may enter older work that selective
   lookup skips.
6. Show retained versions. Account for one new dictionary front `More`, one
   `Entry`, and direct use of the previous dictionary as tail. State reachability
   from `older_dictionary` and `newer_dictionary`, while excluding pointer
   identity, heap bytes, collection, liveness, and compiler representation.
7. Practice predicting queries, adding a new `(2, 21)` duplicate while retaining
   the old version, and comparing direct/fold counts. Open the branching-data
   question for the next case.

Transclude all five canonical sources with unique `<!-- source: src/... -->`
markers. Make every displayed `ash` block byte-for-byte identical to its source.
Require prediction before each command and interpret each exact value/type line.
Mark commands, output, equations, and cost derivations as `text`.

Link claims close to every governing section named by the approved design:
syntax grammar and global presentations; name-resolution type/constructor and
global scope; static constructors, functions/application, patterns/matches,
primitive operations, and globals; dynamic bindings, application,
constructors/matches, primitive operations, and observation; and tool
successful output. Attribute structural design and named source-operation
inspiration directly and concisely to the relevant HtDP material without
exposing project licensing administration.

Keep these exclusions explicit: equality laws and interfaces, order, trees,
balancing, opacity, deletion, mutation, lazy/infinite/cyclic data, host stack,
TCO, timing, instructions, heap bytes, garbage collection, pointer identity,
and compiler optimization.

### Step 2: Read and verify the complete case

Read the README, verifier, and all sources fully. Then run:

```bash
bash content/cases/dictionary-as-list/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
npx --yes markdownlint-cli2 content/cases/dictionary-as-list/README.md
bash -n content/cases/dictionary-as-list/checks/verify.sh
shellcheck -x content/cases/dictionary-as-list/checks/verify.sh
if command -v typos >/dev/null 2>&1; then
    typos content/cases/dictionary-as-list
fi
git diff --check
```

Expected local verifier output:

```text
Verified 5 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

### Step 3: Prove the focused checks can fail

After the complete case first passes, perform a deliberate mutation-and-restore
audit. Use `apply_patch` for each temporary change and its exact restoration;
never use `git checkout` to discard work. Change both the canonical source and
its displayed `ash` block when testing a causal source assertion so
source/block agreement remains green and the intended assertion is reached.

Run these six mutations one at a time:

1. In counted lookup only, replace
   `match same_key query key {` with `match true {`. Expect the verifier to fail
   its counted-equality assertion.
2. In both the canonical module and its displayed block, replace counted
   lookup's nonempty equation with a block that first binds
   `(found, later_comparisons)` through the unchanged recursive call, then
   returns the unchanged match and arms. This moves recursion before the match
   while preserving every existing word count, phrase count, and accepted
   output. Expect the complete-equation suffix assertion to fail.
3. In ordinary lookup, replace `false => lookup same_key query rest` with
   `false => None`. Expect the selective-recursion assertion to fail.
4. In `fold_entries`, replace
   `let folded_rest = fold_entries combine base rest` with
   `let folded_rest = base`. Expect the strict fold-order assertion to fail.
5. In the retained-version entry, make `newer_dictionary` insert onto
   `first_dictionary` rather than `older_dictionary`. Expect the retained-tail
   assertion to fail.
6. In README output only, append `!` to the counted transcript line. Expect the
   fenced-transcript assertion to fail.

After each red result, restore the exact source text with `apply_patch`, run the
local verifier again, and require its exact green summary before starting the
next mutation. End with no mutation diff. Record the six focused failure
messages for review.

### Step 4: Review the complete case before commit

Dispatch independent specification and quality reviewers over the complete
uncommitted case. Give them the approved design, exact chapter contract, source
and verifier, direct outputs, and all mutation evidence. Require authority,
teaching, equality-cost, strictness, reachability, attribution, exclusion, and
non-vacuous-verifier review. Apply and re-review every finding, then rerun the
green local and static checks.

### Step 5: Commit the complete verified case

Run:

```bash
git add content/cases/dictionary-as-list
git commit --no-gpg-sign -m "docs: teach association-list lookup"
```

Do not commit until prose, programs, and checks are green together.

## Task 4: Draft, review, and close repository integration

**Files:**

- Modify: `content/cases/README.md`
- Modify: `README.md`
- Modify: `docs/project/roadmap.md`
- Delete after review: `docs/plans/2026-08-30-association-list-dictionary-design.md`
- Delete after review: `docs/plans/2026-08-30-association-list-dictionary.md`

### Step 1: Draft navigation and roadmap closure while records remain active

Add the dictionary chapter as item 4 under `Cases in order`. Summarize its
selective lookup, explicit equality, and retained versions. Extend the root
recursive-algorithm summary from three to four verified cases without repeating
the edition target or setup.

Draft the roadmap transition: move `A dictionary encoded as a list` under
`Verified increments` as item 4; record five canonical sources, four accepted
observations, hit/miss counts, selective-versus-fold work, fixed-query equality
cost, front construction, retained-version reachability, exact-pin evidence,
and runtime/storage exclusions. Promote case 5 to
`## Next: folding branching data`, preserve its audited content, add the
standard design gate, and leave cases 6 through 12 provisional and numbered.
Update the repository state to four verified unpublished cases.

Do not delete either active record yet. In the draft verified increment, retain
a temporary sentence linking the association-list design and implementation
plan and saying closure review is still active. This keeps both records
discoverable until review and final verification approve their removal.

### Step 2: Verify the complete integration draft

Use this existing manual relative-link check; do not add a dependency, script,
or harness:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
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
```

Then run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/dictionary-as-list/checks/verify.sh
shellcheck -x content/cases/dictionary-as-list/checks/verify.sh
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
git diff --check
git status --short
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: Markdown and shell checks have no findings; 11 Learn lessons pass; 4
Cases and 20 canonical Case sources pass at the exact pin; only the three
integration drafts appear in status; the documentation tag peels to
`e963a1597176f86003926eef827498db2a661b75`; the Ash pin reports
`dca16039923475c48025c5f17beadeb6bcb6a4bf` with empty status.

### Step 3: Review the case and proposed integration before closure

Dispatch an xhigh specification reviewer over the committed case plus the
uncommitted navigation and roadmap draft while both temporary records remain
linked. After it passes, dispatch an independent xhigh quality reviewer. Give
both the design, plan, exact-pin output, mutation audit, case diff, draft
integration diff, and provisional roadmap. Apply and re-review every finding.

Run the complete Step 2 verification again after review fixes. Do not mark the
closure complete or remove either record unless this review and fresh
verification pass.

### Step 4: Remove temporary records and commit reviewed closure

Remove the draft's temporary active-review sentence, then delete exactly:

```text
docs/plans/2026-08-30-association-list-dictionary-design.md
docs/plans/2026-08-30-association-list-dictionary.md
```

Confirm no live reference names either file, run Markdown lint, spelling,
relative links, `git diff --check`, and both exact-pin content aggregators again.
Read every changed file as source, then commit:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md docs/plans
git commit --no-gpg-sign -m "docs: verify association-list dictionary case"
git diff --check HEAD^..HEAD
git status --short --branch
```

Expected: the closure commit succeeds, its diff check is empty, and the feature
worktree is clean. Git history retains both removed records.

## Task 5: Review, verify, and integrate the closed branch

**Files:**

- Review: all changes from `main...association-list-dictionary`

### Step 1: Review the complete closed branch

Use `superpowers:requesting-code-review` for one fresh xhigh whole-branch
review. The reviewer must recover the retired design and plan from Git history,
compare every final file to them, run exact-pin evidence, and check roadmap
closure. Apply technically verified feedback with
`superpowers:receiving-code-review` and re-review every fix.

### Step 2: Run exact final verification

Use `superpowers:verification-before-completion`. Run from the feature worktree:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/dictionary-as-list/checks/verify.sh
shellcheck -x content/cases/dictionary-as-list/checks/verify.sh
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
git diff --check main...HEAD
git status --short --branch
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Also rerun the exact manual relative-link loop from Task 4. Read
`git diff main...HEAD` and every changed file as source. Expected:

- 11 Learn lessons pass;
- 4 Cases and 20 canonical Case sources pass at the exact pin;
- all static and link checks have no findings;
- the feature and pin worktrees are clean;
- `modular-ash` peels to
  `e963a1597176f86003926eef827498db2a661b75`; and
- the Ash pin is `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

### Step 3: Merge locally, verify, and clean up

The user's autonomous integration request selects the local-merge option from
`superpowers:finishing-a-development-branch`. Confirm local `main` is clean and
inspect any movement since the feature base. Merge without pushing:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    association-list-dictionary
```

From local `main`, run the complete merged-state verification. The Markdown
glob excludes the still-present feature worktree so each repository file is
checked once:

```bash
ASH_DOC_ROOT=/home/dikini/Projects/ash-doc
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n "$ASH_DOC_ROOT/content/cases/dictionary-as-list/checks/verify.sh"
shellcheck -x "$ASH_DOC_ROOT/content/cases/dictionary-as-list/checks/verify.sh"
(
    cd "$ASH_DOC_ROOT"
    npx --yes markdownlint-cli2 '**/*.md' '#.worktrees/**'
    if command -v typos >/dev/null 2>&1; then
        typos
    fi
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
    done < <(rg --files -g '*.md')
    git diff --check origin/main...main
    git status --short --branch
    git rev-parse 'modular-ash^{commit}'
)
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: Bash syntax, ShellCheck, Markdown, optional spelling, and relative
links have no findings; 11 Learn lessons pass; 4 Cases and 20 canonical Case
sources pass at the exact pin; `git diff --check` has no findings; local `main`
is clean; the documentation tag and Ash pin have the exact commits stated in
Step 2; and the pin is clean. Only after this merged result passes, remove the
worktree and delete the merged branch:

```bash
git -C /home/dikini/Projects/ash-doc worktree remove \
    /home/dikini/Projects/ash-doc/.worktrees/association-list-dictionary
git -C /home/dikini/Projects/ash-doc branch -d association-list-dictionary
```

Do not push. Keep the full remaining-cases goal active and begin the newly
promoted branching tree-fold case after the local merge checkpoint.
