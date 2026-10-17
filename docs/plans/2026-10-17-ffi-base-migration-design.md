# Preserve the 54-lesson edition at FFI Base

How can a reader continue running every current lesson when the native buffer
moves from a builtin provider to an imported source library? This proposed
book-level design preserves the lessons' questions, programs, observations,
negative boundaries, and reading order while changing one exact Ash target.

**State:** prepared for project approval. Preparing this design and its
[execution plan](2026-10-17-ffi-base-migration.md) does not authorize migration
implementation, move the current pin, or claim new verification.

## Outcome and authority

The starting ash-doc snapshot is
`10e06317c50d36ff9ce5599661973837749a025b`. It targets `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. The destination is `ffi-base`,
resolved to `354c76b391fe4af665cf6a03479a9874a57cb3e3`. Remote Main resolved
to that same destination during the compatibility review on 2026-10-17;
execution must use the commit, not follow Main.

The [destination specification overview][spec], governing chapters, and
[destination tool guide][tool] own the new claims. The changed boundaries
are specified in [lexical structure][lexical], [buffer name resolution][buffers],
[resource typing][resources], and [buffer execution][execution]. The current
edition remains at Diag Ash until implementation begins. Neither this design
nor its review observations define Ash semantics or repair the compiler.

Completion preserves 13 Learn lessons / 56 sources, 8 Libraries lessons /
43 sources, 12 Effects lessons / 71 sources, and 21 Cases / 74 sources:
54 lessons and 244 canonical sources. Preserve all 60 complete human captures
and their semantic JSON checks, source agreement, causal assertions, successful
values and types, streams, and exit statuses. A justified fixture or transcript
change preserves the boundary it tests; it does not preserve obsolete bytes.

New FFI lessons, general foreign-authoring instruction, SQLite or Arena
applications, compiler repairs, new language targets, CI, publication, and
renderer redesign are excluded. The existing buffer lesson explains only the
import and build steps needed for its acquisition question.

## Review evidence and its limits

The compatibility review built the destination compiler and ran all 54 local
verifiers in a temporary copy with only their pin guards changed. Learn passed
13/13; Libraries 8/8; Effects 10/12; Cases 19/21. The four failures were:

- `effects/acquiring-a-buffer`: removed builtin buffer syntax and module;
- `cases/compressing-parent-paths`: the same removed buffer API;
- `cases/reading-a-bounded-message`: that API and a reserved `Bytes` type name;
- `effects/preserving-callback-effects`: `Bonus` replaced an internal effect
  spelling in one diagnostic's found-type fields and displayed message.

All eight positive buffer entries built and ran after temporary import and
resource-form edits and renaming the message Case's `Bytes` to `Payload`.
Their values matched the existing expectations; hosts exited zero with empty
stderr. The ninth entry retained `type.resource-escape`. The callback lesson's
complete verifier passed after the observed spelling update.

These are feasibility observations, not finished migration evidence. The
review did not establish a separate native type assertion, migrated lesson
prose, all new source labels, or rendered output. Temporary captures are not a
required input to execution; the plan reproduces the relevant checks.

## Choice of verification path

The maintainer problem is that ordinary `ash entry.ash` refuses required native
bindings, while a generated host prints only a value. The current accepted
check expects `value : Type`. Replacing that expectation with a value-only
comparison would lose an explicit type observation.

<!-- markdownlint-disable MD013 -->
| Approach | Cost and consequence |
| --- | --- |
| CLI build/run plus declared source signatures | Smallest shell change, but signatures alone replace rather than retain the independently observed result-type check. |
| Small test-only observer using public Ash APIs | Adds one Rust source and generated temporary Cargo inputs; retains checked type, native execution, and the existing Bash/Python division. Selected. |
| Move every accepted example to a Rust verification framework | Broad rewrite of 51 otherwise passing lesson checks; unnecessary for eight native positives. |

<!-- markdownlint-enable MD013 -->

Deferring the choice leaves three units unverified or requires keeping a second
compiler target. Neither completes this migration. Select the observer only for
the eight native positives; keep ordinary CLI checks for the other examples.

### Native observations

Add `content/checks/native-observe.rs` and a narrow Bash helper in
`content/checks/lib.sh`. The observer uses the exact clean checkout supplied to
the verifier as a path dependency. It calls `driver::compile_path`, reads
`CompiledProgram::type_display()`, and passes that same compiled program to
`build::prepare_program` and `build::build_prepared`. Those public APIs are
present at the destination commit; no upstream API change is needed.

Write the type to a separate file. Capture the generated executable's stdout,
stderr, and status separately. Assert the expected type, complete value line,
empty stderr, and status zero. Build logs and observer output cannot become the
program's stdout. A compilation or build failure is a failed check, even if a
previous executable exists. Use a fresh output directory per entry.

Generate the Cargo manifest and lock under the verification temporary directory,
with the pinned checkout's lock as the dependency starting point. Build offline;
verify the resolved dependency packages against that upstream lock, allowing
only the local observer package addition. Add no third-party dependency. If this
cannot retain the locked graph, resolve it within this design before accepting
a harness; do not silently refresh dependencies. Build the observer once per
prepared verification run and reuse one host dependency cache. Release each
observed executable and generated project after its checks; an EXIT trap cleans
up failures. The feasibility run exhausted temporary storage when it retained
several debug executables, so bounded artifact lifetime is required.

The intended Bash operation is
`ash_doc_run_native_accepted unit entry expected_value expected_type`.
The shell remains responsible for comparisons and cleanup. Ordinary successful
checks keep their current interface and output contract. The observer is
verification infrastructure, not a reader command or installed tool.

### Imports, commands, and rejection captures

Use `import @ffi.native_buffer as Buffer` and
`resource Buffer.Buffer<R>` in the nine affected sources. Point `ffi` at the
exact checkout's `libraries/`; do not copy or fork the library. Rename the
bounded-message Case's nominal byte-list type to `Payload` consistently in
source, prose, and expected type. Do not substitute primitive `Bytes`: that
would change the representation being taught.

The root setup declares `ASH_LIBRARIES` as the absolute `libraries/` directory
of the selected Ash checkout. The buffer lesson introduces the supported
Linux x86-64 GNU build route and its Rust/native linker requirements. Readers
use `ash build --output ... --root ffi="$ASH_LIBRARIES" entry.ash`, then run
the executable. Show actual value-only output. The two Cases reuse that setup.
Keep the acquisition, checked access, nested outcomes, initializer effects,
parent-path costs, and message-decoding boundaries intact.

The escape rejection must use the real CLI with that root, explicit human
format and English locale. Extend the rejection and human helpers only as
needed to pass the native root. Extend `human.py` to check the complete displayed
command containing the literal shell reference `"$ASH_LIBRARIES"`; execution
expands it to the verified checkout library directory. Keep the existing
command comparison for non-native captures. No diagnostic-path normalization
beyond the documented ash-doc checkout prefix is introduced. Inspect fresh
JSON labels and full stderr before changing either fixture or explanation.

For callback effects, replace the obsolete internal spelling with the observed
`Bonus` spelling and explain the named effect rather than an internal identity.
Qualify the general entry-contract claims in `requesting-a-value` and
`combining-effects-and-scopes`: ordinary unanswered effects still reject;
[admitted native entry instances][entry] receive a checked interpretation.
Do not add a native-effects tutorial to either lesson.

## One cutover and one forward line

Implement in one migration worktree. Record the 54-unit inventory from the
four family indexes before changing navigation. On changing the pin, declare
migration status and mark every not-yet-verified unit as draft; restore its
active link only after its complete destination check and claim review pass.
All 54 must be restored before the final integration. Do not remove lessons to
meet the gate, keep an old compiler mode, or publish an intermediate edition.

Inspect incoming content before execution. If another lesson has landed since
the stated snapshot, stop before changing the baseline and reconcile the
inventory and scope with the project; do not silently migrate more than 54.
No task here authorizes messaging other chats or changing their worktrees.

The existing A1 is included among the 54. A2–A8 and their foundation programme
are not migration implementations. At cutover, retarget retained future briefs
and the coordination plan to the destination after checking their source links
and assumptions. Mark unexecuted acceptance conditions as unverified and remove
obsolete Diag-only gate claims. Preserve informative design-note provenance at
its actual historical commit. Do not implement those Cases or claim their
proposed results. Superseded instructions that cannot be accurately retargeted
leave the active tree; Git retains them.

Review active targets and links across README, AGENTS, project documents,
content, research, lab, and rendering inputs. Change current authority links
where justified; preserve actual historical attribution. Remove obsolete
baseline-specific evidence rather than blindly replacing every hash. No
published documentation tag exists, and this work creates no publication tag.

## Verification, acceptance, and lifetime

Run all four family aggregates at the destination, retaining all 54 local
checks and 60 captures. Run the wrapper allocation test required by the
verification guide. Add focused harness checks that distinguish wrong type,
wrong value, unexpected stderr, nonzero child status, build failure, stale
output, and unsupported native target. Preserve ordinary CLI and human
comparison controls. Lint changed Rust, Bash, and Markdown, and check links and
pinned anchors. No complete upstream compiler suite is required.

Render the final 54-lesson book in HTML, EPUB, book PDF, and A4 PDF. The retained
rendering evidence covers 53 lessons and cannot establish the destination's
coverage. Check all source hashes, chapter order and links; run existing browser,
artifact, and EPUB checks and inspect changed chapters and A1 in both PDFs.
Record accurate new results without inventing page counts. Run the unchanged
specimen regression separately using the existing tools and styles.

Completion requires a clean single-target edition, all original lesson outcomes
and checks preserved, no draft links left, and updated verification and rendering
records. An unexpected specified-behavior failure becomes a minimal upstream
regression handoff under repository policy; it blocks the affected outcome,
not permission to weaken it or move the target.

Expected implementation effort is 2–4 working days, conditional on the public
observer route retaining the locked graph and existing rendering tools working.
This is an estimate, not a schedule. Remove this design and its execution plan
when their outcome closes, retaining lasting verification facts in the project
guides. Remove or simplify the observer if a later pinned CLI exposes checked
type metadata for native builds; that requires a separate bounded decision.

[spec]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md
[tool]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md
[entry]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#globals-and-modules
[lexical]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/lexical-structure.md#tokens
[buffers]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#ordinary-native-buffer-library
[resources]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-native-buffers
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-native-buffer-execution
