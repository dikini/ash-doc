# Migrate Cases to Lib Ash Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` to execute this plan task by task.

**Goal:** Restore the longest sequential prefix of the twelve recursive-algorithm
Cases that preserves its predecessor teaching promises at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`, and retain the first upstream
compiler blocker without weakening a Case to conceal it.

**Architecture:** Re-run every Case at the immutable predecessor before restoring
it. Add one verified Case and its navigation in each commit. Cases 1 through 6
retain their Ash sources; Cases 7 and 8 add the explicit implementation-selection
imports required by Lib Ash. Case 9 stops the active prefix when dependency-
summary admission reaches the body-free authentication failure already retained
under `lab/lib-ash-migration/`. The observation locates a boundary; it does not
attribute the compiler's internal cause.

**Tech Stack:** Markdown, Ash at two exact commits, Bash lesson verifiers,
Markdownlint, ShellCheck, Git worktrees.

---

## Status and authority

Status: approved for execution under the user-approved Lib Ash milestone and the
roadmap promotion of Cases to **next** on 2026-08-31.

The reader asks how each recursive representation and algorithm crosses the
Modular-to-Lib boundary without changing its problem, invariant, derivation, or
source-level cost account. The observable boundary is the complete Case program:
its value and type when accepted, stable rejection reason and causal location
when rejected, standard channels, exit status, displayed-source agreement, and
the representation relationship taught by its verifier.

Use these immutable identities:

```text
ash-doc recursive-1: fa870a280c76278361db658ff3952cf18f2b7833
ash-lang modular-ash: dca16039923475c48025c5f17beadeb6bcb6a4bf
ash-lang lib-ash: d1e323d23390cdad03202ee3df76cd9100556e1d
```

Language claims come only from the specification at the Lib Ash commit. Tool
commands, channels, statuses, and compiler-internal classification come from the
tool guide, implementation, and tests at that commit. Predecessor execution is a
comparison baseline, not authority for current behavior.

The relevant Lib Ash boundaries are:

- independent name and implementation import channels in
  `spec/name-resolution.md#imports-and-namespaces`;
- the effective implementation environment and checked evidence in
  `spec/static-semantics.md#implementations` and
  `#constraint-satisfaction-and-checked-evidence`;
- private and opaque declarations in
  `spec/name-resolution.md#public-private-and-opaque-declarations`; and
- status `2` compiler-internal failures in `docs/tools/ash.md#failures`.

## Executed compatibility evidence

A clean two-pin audit over all 41 numbered predecessor entries established:

| Classification | Entries | Result |
| --- | ---: | --- |
| Byte-identical observation | 28 | Same status, stdout, and stderr. |
| Required explicit selection | 5 | An `impl Order` import restores success. |
| Internal compiler failure | 8 | Summary authentication fails. |

No other output or diagnostic difference occurred.

Before migration, each of the five selector entries exits `1`, writes no
standard output, and begins standard error with `constraint.unsatisfied`. Each
of the eight internal failures exits `2`, writes no standard output, and begins
standard error with `resolve.internal-state` followed by dependency-summary
body-free authentication evidence.

The five positive selector migrations are Cases 7 entries 01 through 03 and
Cases 8 entries 01 and 02. Case 7 entry 04 already rejects with
`constraint.unsatisfied`; it also receives the selector so it continues to prove
the absence of `Order<Int>`, rather than the absence of a selected implementation
channel.

The eight internal failures are every numbered entry in Cases 9, 10, and 12.
The existing lab retains one representative entry from each Case. Task 9 expands
that record to all eight exact triggering entries before prefix integration.
Case 11 passes but cannot be published ahead of blocked Cases 9 and 10 without
breaking the selected reading order.

## Bounded design

### Restore passing Cases and skip directly to later ones

This would maximize active file count by publishing Case 11 while Cases 9 and 10
remain absent. It would break the sequential representation development: Case 11
is positioned after the iterator work and before Case 12's frontier comparison.
The family index would no longer describe one coherent path.

### Expose private representation names

Changing the affected private types to `pub opaque type` makes the current
compiler pass. It also exposes names that the predecessor Case deliberately
withheld, changes the access model, and conceals a failure of behavior specified
at Lib Ash. This is not a documentation migration.

### Restore the verified sequential prefix

The selected approach restores Cases 1 through 8 in order, with only Cases 7 and
8 receiving legitimate source migration. It stops before Case 9, retains the
existing upstream evidence, keeps Cases 10 through 12 historical, and reports
the exact incomplete state on `main`. This preserves one forward line and makes
all active material trustworthy.

Deferring the prefix would leave 31 passing numbered entries and eight complete
Cases unavailable even though their compatibility is known. Restoring it costs
no new harness or content layout and provides the strongest honest progress
possible at the pinned commit.

The choice is removed when all twelve Cases pass in reading order at the exact
target. It must be revisited if Ash supplies a separately authorized resolution
for the retained regression or if project authority changes the edition target.
Ash-doc does not design either change.

## Migration record

Update this table during execution; no row may say only `pending` after its gate
has run.

| Case | Baseline | Minimal migration | Enhancement assessment |
| --- | --- | --- | --- |
| 1. Folding recursive lists | 5 unchanged | Links/navigation | None |
| 2. Building finite lists | 5 byte-identical | Links/navigation | None |
| 3. Accumulating list results | pending | pending | pending |
| 4. Dictionary as a list | pending | pending | pending |
| 5. Folding branching data | pending | pending | pending |
| 6. Searching an ordered tree | pending | pending | pending |
| 7. Abstracting key order | pending | pending | pending |
| 8. Protecting the dictionary invariant | pending | pending | pending |
| 9. Guaranteeing logarithmic retrieval | pending | pending | pending |
| 10. Resuming tree traversal | pending | pending | pending |
| 11. Persistent FIFO frontier | pending | pending | pending |
| 12. Choosing a search frontier | pending | pending | pending |

For Case 1, all five sources have byte-identical status, standard output, and
standard error at both exact pins. The migration changed only target links and
active family navigation; Ash source, observations, and verifiers remain
unchanged. Before the index linked the restored Case, the navigation gate
failed at one active verifier and zero indexed Cases; after the link, it passed
at one and one. Explicit implementation selection, method-local type
parameters, and relational interfaces do not serve the concrete fold question.
An explicitly kinded higher-kinded fold would change that question, so the
Case received no enhancement.

For Case 2, all five sources have byte-identical status, standard output, and
standard error at both exact pins. The migration changed only target links and
active family navigation; Ash source, observations, and verifiers remain
unchanged. Before the index linked the restored Case, the navigation gate
failed at two active verifiers and one indexed Case; after the link, it passed
at two and two. Explicit implementation selection, method-local type
parameters, and relational interfaces do not improve the concrete state
transition and decreasing-integer measure. Explicit kinds would add syntax
without strengthening finite production, so the Case received no enhancement.

## Shared rules for every restoration

For `<case>`, first run its immutable predecessor verifier:

```bash
readonly predecessor_doc="/home/dikini/.config/superpowers/worktrees/"\
"ash-doc/recursive-1-pin"
bash "$predecessor_doc/content/cases/<case>/checks/verify.sh" \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Restore only that directory from `recursive-1`. Update specification and tool
links from the Modular commit to the Lib commit. Do not change Ash source or an
observation unless the direct two-pin evidence requires it.

Before adding the Case to `content/cases/README.md`, run the family verifier and
compare active verifiers with numbered index links. The new directory must make
that count fail first. Add the link only after the local verifier passes at the
Lib pin.

Use this exact navigation gate before and after every index edit:

```bash
active_case_count=$(find content/cases -mindepth 3 -maxdepth 3 -type f \
  -path '*/checks/verify.sh' | wc -l)
indexed_case_count=$(grep -Ec '^[0-9]+\. \[' content/cases/README.md)
test "$active_case_count" -eq "$indexed_case_count"
```

Expected RED before the new link: active exceeds indexed by one. Expected GREEN
after the link: both equal the restored prefix length.

For every Case, record:

1. the exact dual-pin observation classification;
2. the minimum source, prose, verifier, link, or navigation migration; and
3. an assessment of explicit implementation selection, explicit kinds,
   method-local type parameters, and relational interfaces.

An enhancement belongs only when it improves the same algorithmic question. A
different reusable abstraction belongs in the future library family.

Run after each Case:

```bash
bash content/cases/<case>/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/cases/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
markdownlint-cli2 content/cases/<case>/README.md \
  content/cases/README.md docs/project/roadmap.md \
  docs/plans/2026-08-31-migrate-cases-to-lib-ash.md
git diff --check
git status --short
```

Run `bash -n` and repository-aware `shellcheck -x -P SCRIPTDIR` over every
changed verifier. Confirm displayed Ash agrees exactly with its canonical source.

## Task 1: Activate the Cases family with Case 1

**Files:**

- Modify: `AGENTS.md`
- Restore: `content/cases/folding-recursive-lists/`
- Restore and trim: `content/cases/README.md`
- Restore: `content/cases/checks/verify.sh`
- Modify: `README.md`
- Modify: `content/README.md`
- Modify: `docs/project/roadmap.md`
- Modify: this plan

1. Run the predecessor verifier; expect five canonical sources and all displayed
   blocks to pass.
2. Restore the family index, aggregator, and Case 1. First trim the family index
   to shared setup with no numbered Case links. Run the exact navigation gate;
   expect RED with one active verifier and zero indexed Cases.
3. Run the local and family verifiers at Lib Ash. All predecessor observations
   must remain byte-identical.
4. Add only Case 1 to the family index and rerun the navigation gate; expect
   GREEN at one/one. Add Cases as an active family in root/content navigation
   and mark a one-Case verified prefix in the roadmap.
5. Record no enhancement: higher-kinded folding would replace the Case's
   concrete strict-right-fold question with a later abstraction.
6. Verify, review specification compliance, then instructional quality.
7. Commit:

```bash
git add README.md content docs/project/roadmap.md \
  docs/plans/2026-08-31-migrate-cases-to-lib-ash.md
git -c commit.gpgSign=false commit -m "docs: restore recursive-list-fold Case"
```

## Task 2: Restore Case 2, building finite lists

**Files:** restore `content/cases/building-finite-lists/`; modify `README.md`,
`content/README.md`, the Cases index, roadmap, and this plan.

Expect five canonical sources with byte-identical observations at both pins.
Keep the concrete state transition and decreasing integer measure. Explicit kinds
would add syntax without improving finite production.

Commit: `docs: restore finite-list-unfold Case`.

## Task 3: Restore Case 3, accumulating results

**Files:** restore `content/cases/accumulating-list-results/`; modify the Cases
index, roadmap, and this plan.

Expect five canonical sources and four byte-identical accepted entries. Keep the
explicit accumulator comparison; none of the four Lib Ash feature groups
strengthens its retained-state account.

Commit: `docs: restore accumulator Case`.

## Task 4: Restore Case 4, dictionary as a list

**Files:** restore `content/cases/dictionary-as-list/`; modify the Cases index,
roadmap, and this plan.

Expect five canonical sources and four byte-identical accepted entries. Keep
explicit equality: an `Equal` interface here would pull implementation selection
ahead of its established place and weaken the sequence.

Commit: `docs: restore list-dictionary Case`.

## Task 5: Restore Case 5, folding branching data

**Files:** restore `content/cases/folding-branching-data/`; modify the Cases index,
roadmap, and this plan.

Expect four canonical sources and three byte-identical accepted entries. Keep the
tree-specific fold/search contrast; a generic fold abstraction changes the
question's altitude.

Commit: `docs: restore branching-fold Case`.

## Task 6: Restore Case 6, searching an ordered tree

**Files:** restore `content/cases/searching-ordered-tree/`; modify the Cases
index, roadmap, and this plan.

Expect four canonical sources and three byte-identical accepted entries. Preserve
explicit comparator passing because it is the baseline Case 7 deliberately
abstracts.

Commit: `docs: restore ordered-tree-search Case`.

## Task 7: Migrate Case 7 to explicit implementation selection

**Files:**

- Restore: `content/cases/abstracting-key-order/`
- Modify: numbered entries `01-lookup.ash` through `04-missing-order.ash`
- Modify: Case prose and verifier
- Modify: Cases index, roadmap, and this plan

1. Run the predecessor verifier; expect five canonical sources.
2. Restore the exact Case and run its unchanged verifier at Lib Ash. Expected
   RED: entries 01 through 03 report `constraint.unsatisfied`; entry 04 retains
   its rejection.
3. Before editing source, add verifier assertions that successful clients select
   `Order` explicitly and that entry 04 reaches an `Order<Int>` obligation rather
   than failing only for an absent import channel.
4. Run the local verifier. Expected RED: all four numbered entries contain zero
   explicit `Order` selectors.
5. Add this line after the existing module import in all four numbered entries:

```ash
import ordered_trees (impl Order)
```

1. Explain that name visibility and implementation availability are independent
   import channels. Do not imply runtime lookup, ambient evidence, or transitive
   selection.
2. Update diagnostic byte locations caused by the inserted line while retaining
   entry 04's reason, status `1`, empty stdout, relevant source location, and
   causal relationship.
3. Verify entries 01 through 03 are byte-identical in value/type output to the
   predecessor and entry 04 still proves no `Order<Int>` implementation.
4. Record explicit selection as a warranted Lib Ash improvement to the same
   capability-abstraction question; reject unrelated kinds, method-local
   parameters, and relational determination.

Commit: `docs: migrate ordering-abstraction Case to lib-ash`.

## Task 8: Migrate Case 8 while preserving opacity

**Files:**

- Restore: `content/cases/protecting-dictionary-invariant/`
- Modify: `src/01-public-api.ash`, `src/02-build.ash`
- Modify: Case prose and verifier
- Modify: Cases index, roadmap, and this plan

1. Run the six-source predecessor verifier.
2. Restore exact content and run at Lib Ash. Expected RED: entries 01 and 02
   report `constraint.unsatisfied`; entry 03 remains accepted; entries 04 and 05
   retain `resolve.opaque-constructor`.
3. Before editing source, add this exact verifier assertion for entries 01 and
   02, then run the local verifier. Expected RED: the selector count is zero.

```bash
for selected_entry in src/01-public-api.ash src/02-build.ash; do
    test "$(grep -Fxc 'import dictionaries (impl Order)' \
        "$unit_root/$selected_entry")" -eq 1 ||
        ash_doc_fail "$selected_entry must select Order exactly once"
done
```

1. Add to entries 01 and 02 only:

```ash
import dictionaries (impl Order)
```

1. Rerun the local verifier. Expected GREEN: the selector relationship and all
   accepted and rejected observations pass.
2. Teach that explicit evidence selection composes with opacity: it authorizes
   an implementation without exposing the representation or constructor.
3. Retain the accepted outputs and both opacity rejections, including status,
   channel, source location, and causal declaration relationship.
4. Record no additional kinds, method-local, or relational enhancement.

Commit: `docs: migrate opaque-dictionary Case to lib-ash`.

## Task 9: Apply the upstream blocker at Case 9

**Files:**

- Do not restore: `content/cases/guaranteeing-logarithmic-retrieval/`
- Modify: `lab/lib-ash-migration/README.md`
- Modify: `lab/lib-ash-migration/body-free-summary-authentication/README.md`
- Modify:
  `lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh`
- Create: exact missing numbered entries under the three existing lab source
  directories
- Modify: `README.md`
- Modify: `content/README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Modify: this plan

1. Re-run the predecessor Case 9 verifier; expect three canonical sources and
   both numbered entries accepted.
2. Run the immutable Case sources directly at Lib Ash. Confirm both entries exit
   `2`, write no stdout, and begin stderr with `resolve.internal-state` and body-
   free dependency-summary authentication.
3. Before copying any source, extend the lab verifier's declared inventory from
   three to all eight entries. Derive the five new expected SHA-256 values from
   immutable `recursive-1`, hard-code them with the exact predecessor and Lib
   observations, and require every declared retained path to exist. Run the
   verifier. Expected RED: it names the first missing retained entry.
4. Copy these missing files byte-for-byte from immutable `recursive-1`:

   - Case 9 `src/02-build-and-persistence.ash`;
   - Case 10 `src/02-retained-state.ash`, `03-opaque-pattern.ash`, and
     `04-opaque-construction.ash`; and
   - Case 12 `src/02-unreachable-cycle.ash`.

5. Rerun the verifier. Expected GREEN: it asserts source hashes, predecessor
   observations, and Lib observations for every entry. Every Lib run must exit
   `2`, write no stdout, begin stderr with `resolve.internal-state`, and retain
   its exact
   primary import range plus the body-free authentication evidence. The two
   predecessor opacity entries must retain their original status `1`, empty
   stdout, reason, source location, and causal evidence.
6. Update the lab prose and index to say eight entries are retained. Keep the
   direct-dependency controls and state only that the evidence locates failure at
   dependency-summary admission; do not claim it proves the compiler's internal
   cause.
7. Run the expanded permanent two-pin lab verifier. Commit this complete
   evidence separately:

```bash
git add lab
git -c commit.gpgSign=false commit \
  -m "lab: retain all blocked lib-ash Case entries"
```

1. Confirm the affected private types remain part of each Case's hidden
   representation. Do not make them `pub opaque`, edit ash-lang, or propose a
   compiler fix.
2. Leave Cases 9 through 12 absent. Update current navigation and the roadmap to
   say the active Cases prefix is 8 Cases/39 canonical sources and is blocked at
   Case 9 by the linked upstream evidence.
3. Fill migration rows 9, 10, and 12 with their exact blocker classification.
   Record Case 11's clean compatibility result but its intentional reading-order
   hold; do not restore it.
4. State that Outcome 2 is incomplete, the library-family outcome remains
   provisional under the approved sequence, and no `lib-ash` documentation tag
   may be created.

Run:

```bash
bash content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/cases/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
test "$(find content/cases -mindepth 3 -maxdepth 3 -type f \
  -path '*/checks/verify.sh' | wc -l)" -eq 8
test "$(find content/cases -type f -name '*.ash' | wc -l)" -eq 39
test ! -e content/cases/guaranteeing-logarithmic-retrieval
test ! -e content/cases/resuming-tree-traversal
test ! -e content/cases/implementing-persistent-fifo-frontier
test ! -e content/cases/choosing-a-search-frontier
```

Run all shell syntax, repository-aware ShellCheck, Markdownlint, relative-link,
source-agreement, and `git diff --check` gates. Perform authority, instructional,
and whole-branch reviews over the complete Cases branch.

Commit: `docs: retain lib-ash Cases migration blocker`.

## Task 10: Integrate the verified prefix without closing Outcome 2

Fast-forward the clean Cases branch into local `main` only after Task 9's three
reviews approve and the complete Learn/Cases/lab verification passes. Re-run the
same closure commands from merged `main`, then remove the completed feature
worktree and branch.

Keep this temporary plan in the current tree because the Cases outcome remains
active. Do not promote the library family, delete the plan, create the ash-doc
`lib-ash` tag, or push.

The next continuation begins only after a separately authorized project change
makes Case 9's dependency-summary admission boundary executable under one exact
edition target. The declared Lib Ash commit is immutable, so a later compiler
fix alone cannot change this evidence or silently retarget the edition. Any
authorized retargeting must move every active page and check together. Then
restore Cases 9 through 12 in order, reassess each Case, close Outcome 2, delete
this plan, and independently review the decision to promote the library family.

## Completion conditions

The partial-prefix execution is complete when:

- Cases 1 through 8 and all 39 canonical sources pass at exact Lib Ash;
- the family index exposes only that verified prefix;
- Cases 7 and 8 teach and verify explicit implementation selection without
  weakening the negative or opacity boundaries;
- all eight failing entries from Cases 9, 10, and 12 have passing permanent
  compiler-failure evidence and remain inactive content;
- Case 11 remains historical solely to preserve reading order;
- Learn, the active Cases prefix, and the lab pass together from clean `main`;
- the roadmap names the exact incomplete state and upstream blocker; and
- no library family, publication tag, push, or upstream Ash change occurs.

The full Cases outcome remains incomplete until all twelve Cases pass in order.
