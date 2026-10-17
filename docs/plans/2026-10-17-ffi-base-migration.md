# FFI Base migration execution plan

> Execution guidance: use the project writing skill and
> `superpowers:executing-plans` for this plan's ordered checkpoints.

**Goal:** move the existing 54-lesson edition from Diag Ash to FFI Base while
retaining every lesson and its complete verification boundary.

**Architecture:** retain lesson-local Bash checks and Python diagnostic
comparisons. Add one test-only Rust observer for the eight native positives;
keep source rejections on the actual CLI. Cut over one exact target and restore
only verified navigation.

**Tools:** Bash, Python standard library, the pinned Rust/Cargo toolchain and
Ash public APIs, existing Quarto/Typst and browser/rendering checks.

**State:** approved for execution on 2026-10-17. The user approved the
[bounded design](2026-10-17-ffi-base-migration-design.md) and its harness scope.
The owning outcome is [the migration roadmap entry][outcome].

## Inputs and fixed bounds

Starting ash-doc commit: `10e06317c50d36ff9ce5599661973837749a025b`.
Starting Ash: `9ec5920e8c395f9a36125805ee93b7f58c0f4764` (`diag-ash`).
Destination Ash: `354c76b391fe4af665cf6a03479a9874a57cb3e3` (`ffi-base`).
No new lessons, compiler changes, publication, or A2–A8 implementation.

Keep the four indexed inventories: Learn 13/56 sources, Libraries 8/43,
Effects 12/71, Cases 21/74. Preserve all 60 human captures. The design records
the feasibility review; repeat final checks against the final source bytes.
Never use its temporary pin substitutions as the production migration method.

## 1. Establish the execution boundary

**Read:** `AGENTS.md`, `.agents/skills/writing-ash-documentation/SKILL.md`,
`README.md`, `docs/project/workflow.md`, `docs/project/verification.md`, and the
approved design. Inspect destination `spec/README.md`, lexical structure,
name resolution, static and dynamic semantics, `docs/tools/ash.md`,
`libraries/native_buffer.ash`, `tests/support/source_buffer.rs`, and relevant
native-buffer tests. Use exact Git objects or a clean detached checkout.

1. Create an ignored `.worktrees/` task worktree on a `codex/` branch under the
   workflow. Use the planning worktree if it remains suitable; do not alter
   another chat's worktree. Record current status and incoming changes.
2. Read the four `content/<family>/README.md` indexes and local verifier source
   inventories. Record a temporary checklist of all 54 lesson paths and their
   promised checks in this plan. Assert the 244-source and 60-capture totals.
   If a new lesson has landed, reconcile scope before cutover.
3. Prepare a clean Ash checkout at the destination and verify:

   ```sh
   git -C "$ASH_LANG" rev-parse HEAD
   git -C "$ASH_LANG" rev-parse 'ffi-base^{}'
   git -C "$ASH_LANG" status --short
   ```

   Both revisions must equal the destination above; status must be empty.
   `ASH_LANG` is an absolute checkout path supplied for execution.
4. Build with `cargo build --locked` in that checkout. Diagnose local wrapper
   or sandbox problems separately from Ash behavior; do not change the pin.

**Checkpoint:** inventory is fixed and design approval recorded. No lesson is
claimed verified at the destination yet.

## 2. Implement the bounded native observation path

**Modify:** `content/checks/lib.sh`, `content/checks/human.py`.
**Create:** `content/checks/native-observe.rs`,
`content/checks/test_native_observe.py`.
The Python test uses only the standard library and temporary directories; it
is a focused check, not a new content registry or verification framework.

1. Add focused failing harness checks for type/value mismatch, nonzero child
   status, unexpected stderr, compilation/build refusal, stale executable
   rejection, cleanup on failure, and unsupported native target. Include an
   ordinary CLI control and the existing human-command form. Run them and
   inspect why they fail before adding the corresponding behavior.
2. Implement the observer protocol from the design: compile once, obtain
   `type_display()`, prepare/build that same compiled object, then keep type,
   child stdout/stderr/status, and build logs separate. Its inputs are entry,
   exact library root, fresh output directory, and reusable Cargo cache.
   It must not return success before the child observation completes.
3. Generate temporary Cargo inputs for the exact checkout. Seed from the
   upstream lock, resolve/build offline, and compare the resulting dependency
   graph with that lock, allowing only the observer package addition. Verify
   wrong checkout, dirty checkout, and wrong prepared pin still reject.
4. Add `ash_doc_run_native_accepted unit entry expected_value expected_type`.
   It compares the separate checked type and child observation. Build once per
   verification preparation; remove each generated executable/project after
   comparison and all remaining scratch data on exit. Do not retain many large
   debug hosts or add a persistent artifact cache.
5. Support the native library root in the existing rejection/human route.
   Verify the exact displayed command using literal `"$ASH_LIBRARIES"` while
   executing with the pinned absolute directory. Keep non-native commands
   unchanged and normalize only the ash-doc checkout prefix in diagnostics.
6. Run focused harness tests, `rustfmt --check` on the new Rust source, Bash
   syntax checks and ShellCheck on modified shell. Exercise a wrong expected
   type against a real positive pilot; a value-only success must not pass it.

   ```sh
   python3 -m unittest discover -s content/checks -p 'test_native_observe.py'
   rustfmt --check content/checks/native-observe.rs
   bash -n content/checks/lib.sh
   shellcheck -x -P SCRIPTDIR content/checks/lib.sh
   ```

   Expected: all focused cases pass; the injected wrong-type observation is
   rejected by the verifier, not accepted as a matching value.

**Checkpoint:** public APIs and locked dependencies suffice, and all failure
controls distinguish their intended causes. If this requires new upstream
behavior or another architecture, return to the design before proceeding.

## 3. Begin the edition cutover and migrate the affected units

**Modify shared inputs:** `README.md`, `AGENTS.md`, `content/checks/lib.sh`,
`content/cases/choosing-a-search-frontier/checks/verify.sh`,
`content/{learn,libraries,effects,cases}/README.md`, and
`docs/project/verification.md`.

1. Move the one active target to the destination, declare migration status,
   and temporarily mark unverified units as drafts outside active navigation.
   Preserve their inventory in the plan checklist; none may disappear.
   Restore links only after each whole unit passes the new-target checks.
2. Add the exact-checkout `ASH_LIBRARIES` setup to root reader setup. Keep
   target administration out of rendered lesson bodies. State the native
   platform/tool requirements at the point where readers need the build route.
3. For `content/effects/acquiring-a-buffer/`, change all seven `src/*.ash`,
   `README.md`, `checks/verify.sh`, and
   `checks/07-handle-escape.diagnostic.json` together. Use the imported library
   and declared resource form. Convert the six positives to separate native
   value/type assertions; keep the escape check on the CLI. Recapture complete
   English stderr and JSON labels; revise the causal explanation from them.
4. For `content/cases/compressing-parent-paths/`, change `src/main.ash`,
   `README.md`, and `checks/verify.sh` together. Preserve its read/write counts,
   compression comparison, nested outcomes, and canonical-source agreement.
5. For `content/cases/reading-a-bounded-message/`, change `src/main.ash`,
   `README.md`, and `checks/verify.sh` together. Rename nominal `Bytes` to
   `Payload`, including expected types. Preserve the recursive representation,
   cursor advance condition, four scenarios, and unanswered exercise.
6. For `content/effects/preserving-callback-effects/`, review and update
   `README.md` and `checks/02-pure-contract.diagnostic.json` for the observed
   `Bonus` spelling. Run its complete verifier, including the other captures.
7. Qualify entry-contract explanations in
   `content/effects/requesting-a-value/README.md` and
   `content/effects/combining-effects-and-scopes/README.md`. Link the exact
   destination rules; preserve the ordinary unhandled-effect rejections.
8. Run each affected lesson's `checks/verify.sh "$ASH_LANG"`. Expected result:
   its complete source, observation, JSON, human, and causal checks pass.
   Restore each verified unit's index link and mark its checklist entry done.

**Checkpoint:** all eight native positives retain independently checked result
types and expected values; the escape boundary and callback contract remain
rejected for the explained reasons. No discovery exercise has gained an answer.

## 4. Review and verify all retained units and project records

**Review:** every remaining indexed lesson and its governing destination
sections. Update its specification links and any claims affected by the new
primitive types, native entry interpretation, or resource declarations.
Do not infer semantic compatibility solely from successful execution.

**Modify as required:** `docs/project/{roadmap,workflow,verification,rendering}.md`,
`docs/plans/README.md`, current records under `research/` and `lab/`,
`rendering/` target-bearing source inputs, and active A2–A8/coordination plans.
Find candidates with `rg -n 'diag-ash|9ec5920|native_buffer|<effect:'` in the
tracked roots; inspect each hit rather than performing a blanket replacement.

1. Retarget unexecuted future briefs and their governing links, review their
   assumptions, and label their acceptance checks unverified. Preserve their
   actual informative source provenance. Remove superseded baseline-only
   instructions; do not implement future Cases or touch their worktrees.
2. Run all four family aggregates, using an exact-pin prepared build/cache
   where the existing helper permits reuse:

   ```sh
   bash content/learn/checks/verify.sh "$ASH_LANG"
   bash content/libraries/checks/verify.sh "$ASH_LANG"
   bash content/effects/checks/verify.sh "$ASH_LANG"
   bash content/cases/checks/verify.sh "$ASH_LANG"
   ```

   Expect 13, 8, 12, and 21 verified lessons, all 244 canonical sources, and
   all 60 complete human captures. Reconcile every change to fixture counts.
3. Run the separate wrapper allocation claim from the Ash checkout:

   ```sh
   cargo test --locked --lib module_newtype_wrapper_allocates_no_constructor_cell
   ```

4. Restore all 54 index links only after their checklist entries pass. Review
   attribution and relative links and verify destination specification anchors.
   Replace the old verification status with actual exact-target results.

**Checkpoint:** one target, all 54 lessons active and verified, no stale current
baseline evidence. A compiler regression requires the repository's minimal
executable handoff; do not waive checks, narrow the outcome, or advance the pin.

## 5. Verify presentation and close the migration

**Modify:** only affected lesson presentation, existing rendering integration
inputs if required for the 54th lesson, and truthful retained rendering records.
Do not redesign styles or expand the renderer.

1. Build and verify the final whole book and default specimen using the
   existing pinned toolchain and explicit local renderer paths:

   ```sh
   python3 rendering/build.py --whole-book \
       --railroad "$RAILROAD" --sequent "$SEQUENT"
   python3 rendering/checks/verify.py .build/book
   node rendering/checks/browser.mjs .build/book
   java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
       .build/book/output/ash-doc-review.epub
   python3 rendering/build.py --railroad "$RAILROAD" --sequent "$SEQUENT"
   python3 rendering/checks/verify.py
   node rendering/checks/browser.mjs
   java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
       .build/specimen/output/ash-doc-specimen.epub
   ```

   `RAILROAD` and `SEQUENT` name the exact local tools selected by the rendering
   guide. Run its bootstrap only if those pinned tools need preparation.
2. Confirm all 54 lessons and four family introductions in the intended order.
   Inspect changed chapters and A1 in HTML, enlarged EPUB, and both PDFs for
   complete commands, code and diagnostics, note placement, and page breaks.
   Run affected renderer unit regressions if integration inputs changed.
3. Read every changed file as source. Run Markdown lint for changed Markdown,
   relative-link and destination-anchor checks, ShellCheck and Bash syntax for
   changed shell, and the focused native harness checks. Run `git diff --check`
   and inspect `git status --short`.
4. Record results and limits in verification/rendering guides and the roadmap.
   Remove this plan, its design, their index links, and obsolete evidence when
   the complete outcome is integrated. Keep only current instructions and facts.
   Review the final diff for a single `ffi-base` edition; create no publication
   tag and leave no compatibility branch as maintained documentation policy.

Expected effort is 2–4 working days. This preparation task does not run the
migration, tag an edition, or claim any of these future gates have passed.

[outcome]: ../project/roadmap.md#ffi-base-migration-outcome

## Execution inventory

- [x] `content/learn/choosing-a-result`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/defining-data`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/defining-local-recursion`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/definitions-for-many-types`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/following-recursive-data`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/functions-as-values`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/generalizing-local-functions`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/handling-data-forms`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/naming-intermediate-values`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/using-another-source-file`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/using-more-than-one-input`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/values-travel-together`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/learn/what-is-an-ash-program`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/accepting-type-constructors`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/choosing-implementation-evidence`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/determining-interface-results`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/forwarding-capability-evidence`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/giving-method-local-type-parameters`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/requiring-element-behavior`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/supplying-scoped-evidence`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/libraries/wrapping-a-representation`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/acquiring-a-buffer`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/choosing-a-handler`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/combining-effects-and-scopes`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/counting-with-a-cell`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/following-effect-contracts`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/keeping-access-in-scope`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/preserving-callback-effects`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/requesting-a-value`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/resuming-a-calculation`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/running-cleanup`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/stopping-a-calculation`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/effects/transforming-publications`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/abstracting-key-order`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/accumulating-list-results`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/bounding-search-work`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/building-finite-lists`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/choosing-a-search-frontier`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/compressing-parent-paths`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/controlling-a-hook-pipeline`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/dictionary-as-list`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/folding-branching-data`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/folding-recursive-lists`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/guaranteeing-logarithmic-retrieval`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/implementing-persistent-fifo-frontier`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/measuring-tree-search`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/numbering-tree-leaves`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/preserving-outcomes-through-cleanup`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/protecting-dictionary-invariant`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/reading-a-bounded-message`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/resuming-tree-traversal`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/running-a-scripted-session`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/searching-ordered-tree`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
- [x] `content/cases/supplying-order-prices`:
  source agreement, observations, diagnostics,
  and source-specific assertions where applicable.
