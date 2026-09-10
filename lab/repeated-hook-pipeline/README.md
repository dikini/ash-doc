# Repeated hook pipeline calls exhaust type work

Current-baseline regression candidate: `diag-ash` at
`38e3478589b77133caa8e4f16ccc0ef1ad2b6c26`. This is compiler pressure evidence,
not a source-language restriction or a proven diagnosis.

The [hook pipeline Case](../../content/cases/controlling-a-hook-pipeline/README.md)
shows local hook callbacks, ordinary policy control, and an execution trace.
Its three separate entries pass. Combining those same calls in one entry
exhausts type-checking work. The Case's promised comparisons are complete;
repeated use in one entry remains an upstream issue.

## Reproduce

Build a clean compiler at the exact baseline using the
[shared setup](../../README.md#prepare-ash). From ash-doc, run:

```text
ash --message-format human --locale en \
    --root demo=content/cases/controlling-a-hook-pipeline/src \
    lab/repeated-hook-pipeline/src/three-runs.ash
```

The named root imports the same canonical pipeline as the passing lesson:

<!-- source: src/three-runs.ash -->
```ash
import @demo.pipeline as Pipeline

main : Unit -> ((Pipeline.Result, Pipeline.Steps),
    (Pipeline.Result, Pipeline.Steps), (Pipeline.Result, Pipeline.Steps))
main () = (Pipeline.run (true, true), Pipeline.run (false, true),
    Pipeline.run (true, false))
```

Status is `2`, stdout is empty, and the complete stderr is:

```text
The compiler ran out of resources for type checking and type construction.
reason: internal.resource.type-work
```

The diagnostic gives no source location. Each component call succeeds in its
own lesson entry, with status zero and empty stderr. The expected combined
result is a tuple containing, in order, those unchanged permitted, rejected,
and unenriched results and traces. This entry is reduced to the three calls;
the imported pipeline has not been fully minimized.

The pinned [hook rules][hooks] permit effectful callbacks and surrounding
ordinary handlers. The [effect rules][effects] define resumption and owned
discard. Each `run` handles its effects and returns resource-independent data.
No specified source restriction limits these calls to separate entries.
Compiler work is bounded, so upstream must establish whether this is excessive
analysis or legitimate exhaustion before selecting a repair. The passing
controls show the interaction works individually; they do not prove the cause
of the combined failure. The example is original code, with no external source
adaptation.

Verify the current failure and all three controls:

```text
bash lab/repeated-hook-pipeline/checks/verify.sh /path/to/diag-ash
```

## Upstream-agent prompt

Investigate `lab/repeated-hook-pipeline` in ash-doc against compiler commit
`38e3478589b77133caa8e4f16ccc0ef1ad2b6c26`. Reproduce the combined entry's
`internal.resource.type-work` failure and the three passing lesson entries.
Minimize the imported pipeline further and trace the exhausted work ledger.
Do not assume this is the same cause as an earlier recursive-analysis defect.

Determine why combining these finite, individually accepted computations
exhausts type work. If defective, repair it in an isolated ash-lang worktree
with focused upstream regression coverage. Preserve resource safety, callback
context, continuation ownership, and bounded accounting; do not merely remove
checks or raise limits. Verify that the combined result contains the exact
three separately observed values and run relevant upstream tests. Report the
repair commit, evidence, and any independent source mistake or remaining issue.
Do not change ash-doc or move its baseline as part of the investigation.

Retain this case until an authorized baseline migration makes the combined
entry pass. Then remove the reproducer, recorded failure, and this handoff;
Git retains superseded evidence. Keep the lesson's separate entries because
they make each observation readable, not as a claimed language limitation.

[hooks]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#synchronous-typed-hooks
[effects]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#effects
