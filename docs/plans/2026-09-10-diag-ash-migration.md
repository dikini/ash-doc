# Diag Ash migration

Status: selected by project direction on 2026-09-10; implementation pending.
Owner: the [roadmap's next outcome](../project/roadmap.md#next-migrate-the-existing-edition-to-diag-ash).

## Work target and historical references

All new edition work targets **`diag-ash`**, resolved to Ash commit
`9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. The tag currently identifies that
commit directly. Record and check the resolved commit; do not assume an
annotated tag object or use floating `ash-lang/main` as the edition pin.

Diag Ash is the cumulative Ash checkpoint. It includes diagnostics and the
migration repairs together with effects and resources, library abstractions,
modules, and the earlier language foundation. Its name identifies the complete
compiler target, not a diagnostics-only subset. Language claims derive from
its [specification](https://github.com/dikini/ash-lang/tree/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec);
commands and diagnostics derive from its
[tool guide](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/docs/tools/ash.md),
implementation, and tests.

Ash history serves as reference and comparison evidence:

- `modular-ash`, Ash `dca16039923475c48025c5f17beadeb6bcb6a4bf`, supplies the
  published predecessor and successful pre-Lib-Ash observations.
- `lib-ash`, Ash `d1e323d23390cdad03202ee3df76cd9100556e1d`, supplies the last
  verified documentation baseline and the retained compiler-failure evidence.
- `effect-ash`, Ash `a64f10bf618f23bcb0e647fe5715742e3946fe2c`, is an included
  upstream milestone. It is not a migration stop or a second work target.
- Ash-doc `recursive-1` retains the complete historical recursive Cases. It is
  a documentation checkpoint, not an Ash language milestone.

Keep these identities on historical records. Do not rewrite old observations
as Diag Ash results or require new teaching to run on old compilers. Historical
comparison checks may retain their exact pins; current edition checks must
move to Diag Ash. Backports and compatibility branches are outside this work.

## Current evidence and selected approach

At ash-doc `492a3abec1324c3c0c0e8f0376d380092e883561`, eleven Learn lessons,
nine Cases, and five library lessons were recorded as verified at Lib Ash.
Cases 9, 10, and 12 were unavailable. Existing source links and verifier guards
still encode that historical baseline; they have not been migrated by this
planning update.

The earlier
[Lib Ash plan](https://github.com/dikini/ash-doc/blob/492a3abec1324c3c0c0e8f0376d380092e883561/docs/plans/2026-08-31-lib-ash-documentation-milestone-design.md)
and its unfinished publication outcome are superseded. Its completed learning
material and source research remain migration inputs. The next publication
candidate is ash-doc `diag-ash`, after verification; no Lib Ash publication is
planned.

The upstream
[repair evidence](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/docs/design/migration-repair-evidence.md)
records fixes for private constructor-access metadata and repeated capture and
method scans, with producer authentication and unchanged resource limits.
The Diag Ash commit descends from both the effects milestone and the repair
merge, and includes the human/JSON diagnostic implementation. No additional
wait for effects integration is required.

A names-only retarget would leave old diagnostic parsers, source assumptions,
and verification claims behind. Keeping several active edition targets would
create ambiguous authority. Select one forward migration: prepare the shared
checks, change the content pin and target administration together, and verify
complete units in order. Pending units remain visible as migration gaps. An
upstream canary is useful evidence but cannot complete this edition migration.

## Ordered work

1. **Establish the exact compiler.** Use a clean Ash checkout at
   `9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. Check that `diag-ash^{commit}` and
   `HEAD` equal that value, then build with `cargo build --locked --bin ash`.
   Read the pinned specification and tool guide for each affected claim.
2. **Prepare diagnostic checks and content cutover together.** Update
   `content/checks/lib.sh` and specialized rejection verifiers discovered with
   `rg` under `content/`. Request `--message-format json` before the entry path;
   parse JSON objects and assert schema version, reason, responsibility,
   required facts, and causal source relationships. Preserve success output
   and exit-status checks. Do not match human wording, line layout, or a
   serialized JSON substring as the diagnostic contract.
3. **Declare the one content target.** Change the shared pin, README setup,
   AGENTS authority links, roadmap, family navigation, and active source/tool
   links to the exact Diag Ash commit in the same cutover. Enumerate pending
   units and restore active navigation only after each verifies. Remove the
   transitional historical-baseline setup when this happens. Search every old
   pin by role; retain history references in lab and research records instead
   of globally replacing them.
4. **Migrate the complete existing paths.** Verify Learn, Cases, and Libraries
   unit by unit. Preserve their reader questions, exercises, source traditions,
   derivations, invariants, and cost claims. Update code and explanations for
   actual target changes, and check displayed code against canonical sources.
   Pure lessons need no effects retrofit. A milestone's inclusion in Diag Ash
   does not imply this edition teaches every included feature.
5. **Restore Cases 9, 10, and 12.** Recover their complete prose, programs,
   fixtures, and checks from `recursive-1`. Retain private representations.
   Add explicit implementation selection to teaching clients where required
   by Diag Ash. Keep the lab's eight original sources unchanged and check them
   separately against Diag Ash. The upstream repaired-source baseline is:

   | Original entries | Expected outcome to confirm at Diag Ash |
   | --- | --- |
   | Two search-frontier entries | Success with their retained output hashes. |
   | Two red-black and two accepted iterator clients | `constraint.unsatisfied` because the originals omit implementation selection. |
   | Two opaque iterator entries | `resolve.opaque-constructor` with causal declaration labels. |

   Verify dependency controls too. An ordinary rejection proves restored
   compiler checking; a teaching Case promising success must additionally
   pass with its migrated source. Record any new failure without changing
   historical observations or masking it with relaxed assertions.
6. **Retain separate evidence.** Preserve
   `lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh`
   as the historical two-pin comparison. Add a separate exact-Diag-Ash replay
   with outcome assertions and links to the upstream repair record. Label
   original-source and migrated-source results separately. Historical failures
   remain facts about old Ash, not claims that Diag Ash still fails.
7. **Verify and close.** Run all three family aggregators at the exact Diag Ash
   checkout, including restored Cases and all negative checks. Review source
   agreement, semantic authority, links, Markdown, shell syntax, and changed
   scripts with ShellCheck. Record exact commits and command outcomes. Remove
   this temporary plan when complete and update the roadmap. A later annotated
   ash-doc `diag-ash` publication tag may identify only a clean, fully verified
   documentation snapshot; never move an existing tag.

## Verification and completion

The content migration must run these commands from ash-doc after adapting the
checks; they are not assertions that today's Lib Ash checks accept Diag Ash:

```text
bash content/learn/checks/verify.sh <clean exact diag-ash checkout>
bash content/cases/checks/verify.sh <clean exact diag-ash checkout>
bash content/libraries/checks/verify.sh <clean exact diag-ash checkout>
git diff --check
git status --short
```

Completion requires eleven Learn lessons, all twelve Cases, and five library
lessons verified at one Diag Ash commit, plus the separate original-trigger
replay. Review every remaining old milestone reference: it must identify
history or comparison evidence, never current work, current authority, or an
alternative edition pin. Record any unresolved discrepancy and keep the
relevant unit and publication incomplete.

This plan changes the destination and migration requirements. It does not
claim completed content migration, publish an edition, modify Ash, introduce
new learning topics, or select a renderer or publication service.
