# Choose implementation evidence lesson implementation plan

> **For Codex:** Use `superpowers:test-driven-development` for the lesson
> verifier and `superpowers:verification-before-completion` before each success
> claim or commit.

**Goal:** Create the first complete **Design library abstractions in Ash**
lesson, where a selected client observes `true : Bool` and a name-only client
proves that importing a constrained operation does not select its implementation
evidence.

**Architecture:** Create one lesson-local source library and two complete entry
modules. The positive entry adds the independent `impl Equal` import item; the
negative entry imports the same constrained global by name but selects no
implementation fact. A lesson-local Bash verifier owns exact sources,
observations, causal diagnostic relationships, and displayed-source agreement.
The new family aggregator reuses `content/checks/lib.sh`. Root navigation and a
family-neutral `AGENTS.md` active-stream rule change only after the complete
lesson and family index pass.

**Tech Stack:** Markdown, Ash at exact commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`, Bash, the existing ash-doc
verification helper, Markdownlint, ShellCheck, Git worktrees.

---

## Status and authority

Status: approved under the approved
[library abstractions learning-path design](2026-09-01-library-abstractions-design.md).

The reader asks how a program chooses the implementation required by an
imported abstraction. The observable boundary is the difference between an
ordinary targeted name item and the independent `impl Interface` item: exact
accepted value/type/channels/status on one side, and the stable unsatisfied
obligation plus its causal source relationships on the other.

Language claims come only from the exact Lib Ash specification:

- [syntax grammar](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/syntax.md#grammar)
  for targeted name and implementation items;
- [imports and namespaces](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md#imports-and-namespaces)
  for their independent bindings and selected facts;
- [interfaces and constrained schemes](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#interfaces-and-constrained-schemes)
  for the interface, implementation, constrained global, and obligation;
- [constraint satisfaction and checked evidence](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
  for concrete selection and `constraint.unsatisfied`;
- [interface evidence lowering](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/elaboration.md#interface-evidence-lowering)
  and [generated interface evidence](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#generated-interface-evidence)
  only for the bounded statement that selected evidence lowers and erases
  rather than becoming a runtime registry; and
- the pinned tool guide's [successful output](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md#successful-output)
  and [failure behavior](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md#failures)
  for CLI channels and status.

The complete import and implementation-selection behavior is also exercised by
the pinned [library import tests](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/tests/library_imports.rs)
and [specification example tests](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/tests/spec_examples.rs).
Those tests corroborate implementation and diagnostic observations; they do
not define language behavior.

## Fixed executable observations

A disposable three-source canary at the exact target established these
observations before planning.

`equality.ash`:

```ash
pub interface Equal<A> {
    equal : (A, A) -> Bool
}

pub impl Equal<Int> {
    equal (left, right) = left == right
}

pub same : (A, A) -> Bool where Equal<A>
same pair = equal pair
```

Selected entry:

```ash
import equality (same, impl Equal)

main : Unit -> Bool
main () = same((21, 21))
```

It exits `0`, writes empty standard error, and writes exactly:

```text
true : Bool
```

Name-only entry:

```ash
import equality (same)

main : Unit -> Bool
main () = same((21, 21))
```

It exits `1`, writes empty standard output, and begins standard error with:

```text
constraint.unsatisfied
primary: source 0 54..58: no available implementation satisfies this interface obligation
related: source 1 124..128: this declaration introduced the interface obligation
related: source 0 17..21: this import made the declaration available
related: source 1 0..53: this interface declaration participates in the failing selection
```

The rendered offsets and prose are exact-pin observations, not general
contracts. The verifier derives the source ranges from the canonical files and
asserts only the stable reason, channels, status, and causal relationships used
by the lesson.

## Files

Create during implementation:

- `content/libraries/README.md`
- `content/libraries/checks/verify.sh`
- `content/libraries/choosing-implementation-evidence/README.md`
- `content/libraries/choosing-implementation-evidence/src/equality.ash`
- `content/libraries/choosing-implementation-evidence/src/01-selected.ash`
- `content/libraries/choosing-implementation-evidence/src/02-name-only.ash`
- `content/libraries/choosing-implementation-evidence/checks/verify.sh`

Modify only after the lesson and family pass:

- `AGENTS.md`
- `README.md`
- `content/README.md`
- `docs/project/roadmap.md`
- this plan

Delete this plan in the reviewed closure commit. Retain the approved family
design until all five lessons close.

## Task 1: Commit the approved implementation plan

1. Obtain independent authority/specification and instructional/workflow
   approval for this complete plan.
2. Change its status to approved and change the roadmap link from draft to
   active approved plan.
3. Verify no `content/libraries/` directory exists, the exact Lib Ash checkout
   is clean, Markdownlint and relative links pass, and `git diff --check` is
   clean.
4. Commit only the plan and roadmap:

```bash
git add docs/plans/2026-09-01-choosing-implementation-evidence.md \
  docs/project/roadmap.md
git -c commit.gpgSign=false commit \
  -m "docs: plan explicit implementation selection lesson"
```

## Task 2: Build the local verifier RED

Create only
`content/libraries/choosing-implementation-evidence/checks/verify.sh` first.
It must use `set -euo pipefail`, resolve its unit and content roots, source
`content/checks/lib.sh`, require one Ash checkout argument, and call
`ash_doc_prepare`.

Declare exactly these sources in stable order:

```text
src/equality.ash
src/01-selected.ash
src/02-name-only.ash
```

Before reading them, compare the declared inventory with the actual `src/*.ash`
inventory and require every source to exist. Run the verifier against the exact
Lib Ash checkout. Expected RED: the first missing canonical source is named.

Do not create prose, an index, future lesson directories, or a shared
library-specific helper in this task.

## Task 3: Add canonical source and observation checks

Drive the source inventory first. Add an empty `equality.ash`, rerun and require
RED naming `01-selected.ash`; add an empty `01-selected.ash`, rerun and require
RED naming `02-name-only.ash`; add an empty `02-name-only.ash`, then require the
inventory-only check to pass.

Next use this strict RED/GREEN order:

1. Add the `equality.ash` structural assertions, run RED against the empty
   file, replace only that file with its exact canonical source from **Fixed
   executable observations**, and rerun GREEN.
2. Add the selected-entry structural and accepted-observation assertions, run
   RED against the empty file, replace only `01-selected.ash` with its exact
   canonical source, and rerun GREEN.
3. Add the name-only relationship and rejected-observation assertions, run RED
   against the empty file, replace only `02-name-only.ash` with its exact
   canonical source, and rerun GREEN.

Each RED must fail for the newly installed assertion, and each GREEN must
retain all earlier assertions. Do not weaken a check to make a source pass.

The verifier must assert:

1. `equality.ash` contains exactly one public `Equal<A>` interface, one public
   `Equal<Int>` implementation, one public `same` signature with
   `where Equal<A>`, and the exact `equal pair` body;
2. the selected and name-only entries are equal after removing exactly the
   `, impl Equal` selector text;
3. only the selected entry contains `impl Equal`, exactly once;
4. neither entry imports or calls `equal` directly;
5. both entries contain exactly one constrained `same` occurrence in `main`;
6. the selected entry exits `0`, writes empty stderr, and writes exactly
   `true : Bool` plus the terminating newline; and
7. the name-only entry exits `1`, writes empty stdout, begins stderr with
   `constraint.unsatisfied`, places its sole primary label exactly on the
   constrained `same` occurrence, and relates that failure to the exact
   imported `same` item, constrained declaration, and `Equal` interface.

Derive all byte ranges from source spelling with byte-oriented tools. Require
one match before computing a range. Do not assert colors, gutters, complete
diagnostic layout, or generalize the exact rendered prose.

Run the verifier. Expected GREEN for canonical source and executable
observations:

```text
Verified 3 canonical source observations at d1e323d23390cdad03202ee3df76cd9100556e1d.
```

Do not call `ash_doc_check_sources` yet: the lesson and its source markers do
not exist. Task 4 adds that check before it adds the prose, so the missing
agreement fails visibly rather than being silently accepted.

## Task 4: Write the lesson and prove source agreement

Create
`content/libraries/choosing-implementation-evidence/README.md` with the heading:

```text
# How can a program choose the implementation a library abstraction needs?
```

Use this teaching sequence:

1. Begin with the client problem: `same` needs equality behavior without a
   comparator argument in its value type.
2. Introduce `Equal<A>`, its method, the public `Equal<Int>` implementation,
   and `same`'s explicit requirement in one complete library source.
3. Separate the two evidence contexts the sources establish: `same` uses its
   declared abstract requirement, while a concrete client call needs a
   selected fact. Defer exact-current evidence inside implementation methods to
   a lesson whose source actually exercises that boundary.
4. Present the name-only entry first as the prediction boundary. Explain that
   importing `same` binds its name and constrained scheme but selects no
   implementation fact. Run and explain the rejection.
5. Add `impl Equal` and present the successful entry. Explain that the item
   resolves the public interface spelling to select facts but binds no source
   name. Ordinary typing fixes `A = Int` before selection.
6. Explain that selection is static: generated evidence becomes ordinary Core
   functions and applications; there is no runtime module object,
   implementation registry, registration, or dynamic dispatch.
7. End with practice that asks the reader to predict unequal `Int` values,
   remove `pub` from the implementation in a copy, and distinguish importing
   the `Equal` name from selecting `impl Equal`.

Keep the lesson in the subject. Do not render target administration, a source
inventory, governing-source list, migration state, or project evidence report.
Link each language conclusion near its exact pinned specification section.

Before writing prose, add `ash_doc_check_sources` for all three declared
sources and run the local verifier. Require RED naming the missing lesson
README. Then create the complete lesson with all three hidden source markers
and exact transcluded sources, rerun GREEN, and manually read the source and
rendered prose in full. Do not create the README before its check has failed.

```text
Verified 3 canonical sources and displayed blocks at d1e323d23390cdad03202ee3df76cd9100556e1d.
```

## Task 5: Create and activate the family atomically

Create `content/libraries/checks/verify.sh` by following the established Learn
and Cases aggregate pattern:

- require one exact Ash checkout argument;
- call `ash_doc_prepare` once;
- discover lesson verifiers at depth three in stable path order;
- require at least one verifier;
- run each with the same checkout; and
- report the verified lesson count and exact pin.

Create `content/libraries/README.md` initially with:

- the family title **Design library abstractions in Ash**;
- the Learn path as its prerequisite;
- the shared repository `ash` setup rather than repeated build instructions;
- an edit/predict/run/explain cycle adapted to source-library boundaries; and
- no numbered lesson link.

The family verifier must compare the active lesson-verifier count with the
numbered lesson-link count. After the local lesson verifier passes, run the
family verifier against the index with no numbered link and require RED at one
active lesson verifier and zero indexed lesson links. Add the one numbered
lesson link only after that RED, rerun, and require GREEN at one and one.

Run the family verifier. Expected GREEN:

```text
Verified 1 library lesson(s) at d1e323d23390cdad03202ee3df76cd9100556e1d.
```

Do not list the four planned lessons as reader navigation or create their
directories.

## Task 6: Activate the verified family in project navigation

Only after Tasks 2 through 5 pass:

1. Change `AGENTS.md` to say that only complete verified units under an indexed
   content family and linked active from that family index belong to the active
   stream. Retain the rule that unavailable numbered Cases are historical.
2. Add the library family and its one verified lesson to root and content
   navigation. Do not claim the five-lesson family is complete.
3. Update the roadmap repository state and verified increments to
   `11 Learn / 9 Cases / 1 library lesson`, with `43 / 42 / 3` canonical sources.
4. Record lesson 1 as verified and promote lesson 2, the capability-facade
   lesson, as the sole next lesson for bounded planning. Keep Cases 9, 10, and
   12 blocked residual and final publication incomplete.
5. Update this plan's execution record with the exact RED/GREEN observations
   and any classified discovery.

Run the exact active-family assertions:

```bash
test "$(find content/libraries -mindepth 3 -maxdepth 3 -type f \
  -path '*/checks/verify.sh' | wc -l)" -eq 1
test "$(grep -Ec '^[0-9]+\. \[' content/libraries/README.md)" -eq 1
test "$(find content/libraries -type f -name '*.ash' | wc -l)" -eq 3
test ! -e content/libraries/forwarding-capabilities
test ! -e content/libraries/accepting-type-constructors
test ! -e content/libraries/polymorphic-interface-methods
test ! -e content/libraries/relational-determination
```

Commit the complete lesson and active navigation:

```bash
git add AGENTS.md README.md content docs/project/roadmap.md \
  docs/plans/2026-09-01-choosing-implementation-evidence.md
git -c commit.gpgSign=false commit \
  -m "docs: teach explicit implementation selection"
```

## Task 7: Verify and review the implementation commit

From the implementation commit's clean HEAD, run:

```bash
bash content/libraries/choosing-implementation-evidence/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/libraries/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash content/cases/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
bash lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

Run `bash -n` and `shellcheck -x -P SCRIPTDIR` over every changed shell script.
Run Markdownlint over every Markdown file, check every relative link, confirm
all displayed source agreement, audit active teaching for the old pin, verify
both Ash checkouts are exact and clean, then run `git diff --check` and require
clean status.

Run the pinned focused tests:

```bash
cargo test --locked --test library_imports \
  name_only_import_does_not_select_implementation -- --exact
cargo test --locked --test library_imports \
  implementation_only_import_selects_evidence_without_binding_names -- --exact
cargo test --locked --test spec_examples \
  overview_implementation_only_selector_beside_qualified_import_is_executable \
  -- --exact
cargo test --locked --test spec_examples \
  overview_name_only_import_has_structured_unsatisfied_constraint -- --exact
```

Run Cargo only from the exact Lib Ash checkout. Obtain independent
authority/specification and instructional/workflow reviews. Correct findings,
rerun affected checks, and repeat the applicable reviews.

## Task 8: Close the lesson plan and integrate

After both implementation reviews approve, delete this temporary plan and
remove its roadmap link in one closure commit. Keep the approved family design
and the roadmap's lesson 2 next outcome. Commit:

```bash
git add -u docs/plans/2026-09-01-choosing-implementation-evidence.md \
  docs/project/roadmap.md
git -c commit.gpgSign=false commit \
  -m "docs: close explicit implementation selection lesson"
```

At the closure commit's HEAD, rerun all Task 7 repository checks and obtain a
whole-branch review. Fast-forward the clean branch into local `main` only after
approval. Re-run lesson, family, Learn, Cases, lab, Markdown, link, shell, pin,
count, diff, and clean-status checks from merged `main`. Remove the feature
worktree and branch.

Do not create an ash-doc `lib-ash` tag, push, change Ash, or start lesson 2
content before its own bounded plan is approved.

## Execution record

Implementation followed the approved RED/GREEN sequence at exact Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`:

- the inventory named missing `equality.ash`, `01-selected.ash`, and
  `02-name-only.ash` in order before the three-file inventory passed;
- the equality structure, selected import, and name-only import checks each
  failed against an empty source before its canonical source was added;
- canonical observations then passed with `true : Bool` for the selected entry
  and the complete causal `constraint.unsatisfied` boundary for the name-only
  entry;
- source agreement failed with `missing unit README.md` before all three exact
  marked blocks and their lesson prose were added, then passed; and
- family navigation failed at one active verifier and zero indexed links before
  the single lesson link was added, then passed at one and one.

The inventory's first implementation compared a pedagogically ordered declared
list with a lexically sorted filesystem list. Its expected RED exposed that
ash-doc verifier mistake. The corrected check sorts a separate expected set
while retaining library-first order for displayed-source checks. This is an
ash-doc correction, not an Ash language, tool, or diagnostic discovery.

## Completion conditions

This lesson increment is complete when:

- exactly three canonical sources and their displayed blocks pass at the exact
  target;
- the selected entry observes `true : Bool` and the name-only entry retains its
  complete causal `constraint.unsatisfied` boundary;
- the lesson clearly separates names, selected implementation facts, checked
  evidence, and runtime evaluation;
- exactly one library lesson is active in family and project navigation;
- `AGENTS.md` admits that verified indexed family without admitting future
  lesson plans;
- all active Learn, Cases, library, and lab evidence passes together;
- the temporary lesson plan leaves the integrated tree; and
- no publication tag, push, future lesson content, or Ash change occurs.
