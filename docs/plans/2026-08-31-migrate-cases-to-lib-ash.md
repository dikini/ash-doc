# Migrate Cases to Lib Ash Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use
> `superpowers:subagent-driven-development` to execute this plan task by task.

**Goal:** Restore every recursive-algorithm Case that preserves its predecessor
teaching promise at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`, retain all compiler-blocked entries
without weakening a Case to conceal them, and expose the resulting gaps.

**Architecture:** Re-run every Case at the immutable predecessor before restoring
it. Add one verified Case and its navigation in each commit. Cases 1 through 6
retain their Ash sources; Cases 7 and 8 add the explicit implementation-selection
imports required by Lib Ash. Cases 9, 10, and 12 retain complete failure reports
when dependency-summary admission reaches body-free authentication. Case 11
passes independently and returns to the numbered path with explicit unavailable
entries around it. The observation locates a boundary; it does not attribute the
compiler's internal cause.

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
| Raw byte-identical observation | 28 | Same channels before migration. |
| Required explicit selection | 5 | An `impl Order` import restores success. |
| Internal compiler failure | 8 | Summary authentication fails. |

No other difference occurred in that raw two-pin audit. Twenty-seven of the 28
raw byte-identical entries require no source migration. The remaining entry is
Case 7 entry 04: its raw rejection looks the same at both pins, but it must gain
an explicit selector so its causal boundary remains the absence of
`Order<Int>`, not an empty implementation-selection channel. Its migrated
diagnostic locations are re-established rather than claimed byte-identical.

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
The permanent lab now retains all eight exact triggering entries. Cases 9, 10,
and 12 remain explicit gaps; Case 11 passes independently and is now restored
without claiming that the Cases outcome is complete.

## Bounded design

### Restore passing Cases and expose gaps

The selected approach restores Case 11 after retaining all failures and marks
Cases 9, 10, and 12 as unavailable at the exact target. It lets readers use
every verified Case, but the family index must make the interrupted sequence and
missing prerequisites plain rather than presenting nine links as a complete
prefix.

### Expose private representation names

Changing the affected private types to `pub opaque type` makes the current
compiler pass. It also exposes names that the predecessor Case deliberately
withheld, changes the access model, and conceals a failure of behavior specified
at Lib Ash. This is not a documentation migration.

### Stop at the verified sequential prefix

This would keep Case 11 historical solely because earlier independent Cases
fail. It preserves a contiguous prefix, but withholds an implementable program
and prevents the migration from continuing after a documented compiler failure.

The selected approach restores Cases 1 through 8 and Case 11, retains all eight
failures, and keeps every gap visible in numeric order. Deferring passing work
would leave 33 accepted numbered observations and nine complete Cases
unavailable even though their compatibility is known. Restoring them costs no
new harness or content layout and separates compiler ownership from ash-doc
progress.

The gap treatment is removed when all twelve Cases pass in reading order at one
authorized exact target. It must be revisited if Ash supplies a separately
authorized resolution for the retained regression or if project authority
changes the edition target. Ash-doc does not design either change.

## Migration record

Update this table during execution; no row may say only `pending` after its gate
has run.

| Case | Baseline | Minimal migration | Enhancement assessment |
| --- | --- | --- | --- |
| 1. Folding recursive lists | 5 unchanged | Links/navigation | None |
| 2. Building finite lists | 5 byte-identical | Links/navigation | None |
| 3. Accumulating list results | 4 exact entries | Links/navigation | None |
| 4. Dictionary as a list | 5 sources / 4 exact | Links/navigation | None |
| 5. Folding branching data | 4 sources / 3 exact | Links/navigation | None |
| 6. Searching an ordered tree | 4 sources / 3 exact | Links/navigation | None |
| 7. Abstracting key order | 5 sources | Selectors/navigation | Selection |
| 8. Protecting invariant | 6 sources | 2 selectors/nav | Selection + opacity |
| 9. Red-black tree | 3 / 2 accepted | 2 status-2 auth | Deferred |
| 10. Iterator | 5 / 2 accepted + 2 rejected | 4 status-2 auth | Deferred |
| 11. FIFO frontier | 3 / 2 exact | Links/prose/navigation | None |
| 12. Graph search | 3 / 2 accepted | 2 status-2 auth | Deferred |

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

For Case 3, all five canonical sources and displayed blocks pass at both exact
pins. The four numbered entries remain accepted with byte-identical status,
standard output, and standard error. The migration changed only target links
and active family navigation; Ash source, observations, and verifiers remain
unchanged. Before the index linked the restored Case, the navigation gate
failed at three active verifiers and two indexed Cases; after the link, it
passed at three and three. Explicit
implementation selection, explicit kinds, method-local type parameters, and
relational interfaces do not strengthen the concrete repeated-append versus
accumulator comparison or its retained-state account, so the Case received no
enhancement.

For Case 4, all five canonical sources and displayed blocks pass at both exact
pins. The four numbered entries remain accepted with byte-identical status,
standard output, and standard error. The migration changed only target links
and active family navigation; Ash source, observations, and verifiers remain
unchanged. Before the index linked the restored Case, the navigation gate
failed at four active verifiers and three indexed Cases; after the link, it
passed at four and four. Explicit equality remains because an `Equal`
interface would pull implementation selection ahead of its established place
and weaken the sequence. Explicit kinds, method-local type parameters, and
relational interfaces do not strengthen the list-dictionary lookup, work, or
retained-version account, so the Case received no enhancement.

For Case 5, all four canonical sources and displayed blocks pass at both exact
pins. The three numbered entries remain accepted with byte-identical status,
standard output, and standard error. The migration changed only target links
and active family navigation; Ash source, observations, and verifiers remain
unchanged. Before the index linked the restored Case, the navigation gate
failed at five active verifiers and four indexed Cases; after the link, it
passed at five and five. Explicit implementation selection, explicit kinds,
method-local type parameters, and relational interfaces do not strengthen the
tree-specific fold and search contrast. A generic fold abstraction would
change the question's altitude, so the Case received no enhancement.

For Case 6, all four canonical sources and displayed blocks pass at both exact
pins. The three numbered entries retain byte-identical status, standard
output, and standard error. The migration changed only target links and active
family navigation; Ash source, observations, and verifiers remain unchanged.
Before the index linked the restored Case, the navigation gate failed at six
active verifiers and five indexed Cases; after the link, it passed at six and
six. Explicit comparator passing remains because it is the deliberate baseline
that Case 7 abstracts through `Order`. Explicit kinds, method-local type
parameters, and relational interfaces do not strengthen the ordered lookup
invariant, comparator-work account, or unbalanced-height boundary, so the Case
received no enhancement.

For Case 7, the predecessor's five canonical sources establish three accepted
entries and one `constraint.unsatisfied` rejection. At Lib Ash before source
migration, entries 01 through 03 rejected with `constraint.unsatisfied`
because the qualified import selected names but no implementation facts;
entry 04 retained its rejection. Each numbered entry now adds exactly one
`import ordered_trees (impl Order)` beside the qualified import. The first
three outputs are byte-identical to their predecessor observations. Entry 04
still exits `1` with empty standard output and `constraint.unsatisfied` first;
its primary label covers the shifted `Trees.lookup` bytes `173..185`, and
related labels retain the constrained declaration, exact qualified name
import, and `Order` interface relationships. The library source is unchanged.
Before the index linked the migrated Case, the navigation gate failed at seven
active verifiers and six indexed Cases; after the link, it passed at seven and
seven. Explicit selection improves the same capability-abstraction question
under Lib Ash's independent name and implementation channels. Explicit kinds,
method-local type parameters, and relational determination do not strengthen
that question, so the Case received no other feature retrofit.

For Case 8, the predecessor's six canonical sources establish four accepted
observations and two `resolve.opaque-constructor` rejections. At Lib Ash before
source migration, entries 01 and 02 rejected with `constraint.unsatisfied`
because their qualified imports selected names but no implementation facts;
entry 03 remained accepted, and entries 04 and 05 retained their opacity
rejections. Entries 01 and 02 now add exactly one
`import dictionaries (impl Order)`; no other source changes. Their accepted
outputs are byte-identical to the predecessor. The defining module and entry
03 retain their accepted observations. Both opacity cases still exit `1` with
empty standard output and `resolve.opaque-constructor` first; their primary
labels cover client `Empty` bytes `126..131`, and their related labels cover
the withheld declaration bytes `240..245`. Before the index linked the
migrated Case, the navigation gate failed at eight active verifiers and seven
indexed Cases; after the link, it passed at eight and eight. Explicit evidence
selection composes with the Case's existing opacity question without exposing
constructors or creating runtime or transitive availability. Explicit kinds,
method-local type parameters, and relational determination do not strengthen
that question, so the Case received no other feature retrofit.

For Cases 9, 10, and 12, the permanent lab now retains all eight numbered
entries with exact source hashes and two-pin observations. Six entries are
accepted at the predecessor; Case 10 entries 03 and 04 instead retain status
`1`, empty standard output, `resolve.opaque-constructor`, their exact client
locations, and the causal withheld declaration. At Lib Ash, every entry exits
`2`, writes empty standard output, begins with `resolve.internal-state`, and
labels its exact import with body-free dependency-summary authentication. The
three Case content directories remain absent. The Cases index now exposes
all twelve slots in strict order: slots 1 through 8 are active, slots 9, 10,
and 12 are unavailable with one exact failure-evidence link each, and slot 11
is pending migration. Case 11's two numbered entries retain byte-identical
accepted observations at both pins and form the next independent restoration.
Outcome 2 remains incomplete, later implementable work may continue, and no
ash-doc `lib-ash` tag may be created.

For Case 11, the predecessor verifier passes three canonical sources and two
accepted entries. Direct comparison establishes byte-identical status,
standard output, and standard error at both exact pins. The migration retains
all Ash source, observations, and verifier content; it changes target links,
reconstructs the minimum LIFO frame model in-page, and links unavailable Cases
10 and 12 through their historical chapters and exact failure evidence. After
the directory introduced a ninth active verifier, the revised twelve-slot
contract failed because slot 11 still lacked its active destination. Linking
the Case removed the pending label and passed both the exact slot contract and
the secondary nine-verifier/nine-link count. Explicit implementation selection,
explicit kinds, method-local type parameters, and relational interfaces do not
strengthen this concrete paired-list queue question, so the Case received no
feature retrofit. The active tree is now `9 Cases / 42 Case sources`; Cases 9,
10, and 12 remain unavailable with evidence, and Outcome 2 remains incomplete.

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
after the link: both equal the number of restored Cases. Unavailable numbered
entries are plain text rather than Markdown links, so they do not satisfy this
gate.

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

## Task 9: Retain every compiler-blocked entry

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
2. Leave Cases 9, 10, and 12 absent. In the Cases index, retain their numeric
   positions as plain-text unavailable entries, each with a link to the failure
   report after its label. Retain slot 11 as plain-text **Pending migration** in
   this transitional commit. Slots 1 through 8 remain active links. Do not count
   an unavailable or pending entry as active navigation. Update current
   navigation and the roadmap to say 8 Cases/39 canonical sources are active and
   that the three gaps are blocked by linked upstream evidence.
3. Fill migration rows 9, 10, and 12 with their exact blocker classification.
   Record Case 11's clean compatibility result and its next independent
   restoration; do not restore it in the failure-evidence commit.
4. State that Outcome 2 is incomplete, later implementable work may continue,
   and no `lib-ash` documentation tag may be created.

Before editing the index, extend the family verifier to enforce the navigation
contract and run it RED. It must extract exactly twelve numbered slots in
strict numeric order; require active Case destinations for slots 1 through 8;
require no active destinations for Cases 9, 10, 11, or 12; require
**Unavailable at this target** labels in slots 9, 10, and 12; require a
**Pending migration** label in slot 11; and require exactly one failure-report
link in each unavailable slot. After the index edit, run it GREEN. The existing
active-link count remains a secondary assertion, not the proof of slot state.

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

Commit: `docs: record blocked lib-ash Cases`.

## Task 10: Restore Case 11 across explicit gaps

**Files:** restore `content/cases/implementing-persistent-fifo-frontier/`;
modify the Cases index, roadmap, and this plan.

1. Run the predecessor verifier; expect three canonical sources and two
   accepted numbered entries.
2. Restore the exact Case and update pinned specification and tool links from
   Modular Ash to Lib Ash. Do not change Ash source, observation, or verifier:
   both entries have byte-identical status, stdout, and stderr at the two pins.
   Adapt the opening so it reconstructs the minimum needed LIFO model in-page:
   front-added unfinished frames remove the newest retained work first. Link the
   unavailable historical iterator and its failure evidence without presenting
   Case 10 as an active prerequisite. Replace the final handoff with an explicit
   note that the Case 12 LIFO/FIFO graph-search comparison is unavailable at this
   target, linked to its failure evidence. No relative link may target an absent
   content directory.
3. Before linking Case 11, run the navigation gate. Expected RED: nine active
   verifiers and eight numbered links. Add the Case 11 link in its numeric
   position after the plain unavailable entries for Cases 9 and 10 and before
   the plain unavailable entry for Case 12. Expected GREEN: nine and nine.
   Update the family verifier first so its exact twelve-slot contract expects
   Case 11's active destination and no **Pending migration** label. Run it RED
   before the index edit and GREEN afterward. It must continue to require the
   unavailable labels and evidence links for slots 9, 10, and 12.
4. Preserve the persistent two-list queue, transfer schedule, representation
   invariant, and retained-version cost account. Explicit implementation
   selection, explicit kinds, method-local type parameters, and relational
   interfaces do not strengthen this concrete queue question, so record no
   enhancement.
5. Run the local verifier, the complete nine-Case family verifier, Learn, the
   eight-entry failure lab, Markdown and shell checks, source agreement,
   relative links, `git diff --check`, and `git status --short`.
6. Obtain authority/specification review, instructional/workflow review, and a
   whole-branch review.

Commit: `docs: restore persistent FIFO frontier Case`.

## Task 11: Integrate all implementable Cases and close this plan

After Task 10's three reviews approve and its complete Learn/Cases/lab
verification passes, update the roadmap to carry Cases 9, 10, and 12 as
**blocked residual** work, promote the library-family design as the sole next
outcome, and remove this temporary plan in the same narrow closure change. That
change is a distinct commit:

```bash
git add docs/project/roadmap.md \
  docs/plans/2026-08-31-migrate-cases-to-lib-ash.md
git -c commit.gpgSign=false commit \
  -m "docs: close implementable lib-ash Cases migration"
```

Because the plan removes itself, stage its deletion rather than its old path.
At that closure commit's HEAD, rerun the complete 11-Learn, nine-Case, and
eight-entry lab verification; every shell, Markdown, relative-link,
source-agreement, exact-target, whitespace, and clean-status gate; then repeat
authority/specification, instructional/workflow, and whole-branch reviews.
Only after all three approve may the branch merge into `main` and receive the
same post-merge verification. Then remove the completed feature worktree and
branch. Do not create library content before its separate plan is approved; do
not create the ash-doc `lib-ash` tag or push.

The next continuation begins only after a separately authorized project change
makes Case 9's dependency-summary admission boundary executable under one exact
edition target. The declared Lib Ash commit is immutable, so a later compiler
fix alone cannot change this evidence or silently retarget the edition. Any
authorized retargeting must move every active page and check together. Then
use a fresh, separately authorized Cases-resumption plan to restore Cases 9, 10,
and 12 in order, reassess each Case, and close Outcome 2. The library plan and
the future resumption plan must not be active together.

## Completion conditions

The currently implementable execution is complete when:

- Cases 1 through 8 plus Case 11 and all 42 canonical sources pass at exact Lib
  Ash;
- the family index exposes nine verified Cases and three plain unavailable gaps
  in numeric order;
- Cases 7 and 8 teach and verify explicit implementation selection without
  weakening the negative or opacity boundaries;
- all eight failing entries from Cases 9, 10, and 12 have passing permanent
  compiler-failure evidence and remain inactive content;
- Case 11 retains its predecessor promise and exact observations;
- Learn, the nine active Cases, and the lab pass together from clean `main`;
- the roadmap names the exact incomplete state and upstream blocker; and
- this temporary plan leaves the integrated tree; and
- no publication tag, push, or upstream Ash change occurs.

The full Cases outcome remains incomplete until all twelve Cases pass in order.
