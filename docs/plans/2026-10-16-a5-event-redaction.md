# A5: Redact before publication

The reader asks when an event must lose its sensitive field before publication.
The observable boundary is between an internal hook transformation, an ordinary
snapshot collector, and a public event interface. This is a lesson implementation
brief for roadmap A5, not a language or publication decision.

## Target and prerequisites

**State:** planned; application code and observations remain unverified.

Use `diag-ash`, exact Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`, throughout.
Read the repository README, workflow, writing skill, and roadmap A5.
Continue `content/cases/controlling-a-hook-pipeline/` and
`content/effects/transforming-publications/`, including their local checks.
The [specification overview][overview], [typed hooks][hooks],
[hook execution][execution], and [module access][modules] govern claims.
Hook callbacks preserve the payload type; outer transformations run first,
and an exact nested root starts a separate chain. Nominal public shape is a
static interface boundary; removing confidential information is an application
invariant. DN-0052 at `9f8738b7e0d7f280f9744bf808343d2c97ce6661`
is informative motivation only and supplies no observations.

## Fixed design

Use the lesson slug `redacting-before-publication` and branch
`codex/a5-event-redaction`. The following signatures are non-executable design
notation: `InternalEvent(id, code, secret)`, `PublicEvent(id, code)`,
`public_view : InternalEvent -> PublicEvent`, and
`redact : InternalEvent -> InternalEvent`.
Use id `1`, code `7`, and unmistakable secret `424242`. Redaction replaces
only secret with `0`; public projection removes the field entirely.
Provide separate internal and public hook APIs and an ordinary public collector
whose input type is `PublicEvent`. Non-executable API notation:
`InternalFeed.publish : InternalEvent -> InternalEvent`,
`PublicFeed.publish : PublicEvent -> PublicEvent`, and
`CollectInternal.capture : InternalEvent -> Unit`.
Project explicitly before public publication.

Demonstrate the internal pipeline with snapshot callbacks around `redact`.
A callback requests collection from an ordinary surrounding handler and returns
the unchanged payload; that handler collects copied ordinary snapshots.
Predict the before/after order from `B(A(payload))`, then inspect the result.
Install an early collector deliberately: it receives secret `424242` even
though its program is well typed. Put a nested exact root inside an outer
redactor to show isolation; explicit public projection must still remove the
secret field. Derive a public interface from the data boundary before writing
its bodies. Explain why a public `code` can still be assigned the secret by
incorrect application code; the type checker has no automatic secrecy policy.

Compare same-type redaction alone with explicit nominal public projection.
Select projection because the public collector cannot accept an internal shape;
deferral would leave the public interface ambiguous. Keep the internal pipeline
only to explain order. Replace this local model only if a later concrete Case
needs another publication representation; add no generic event framework.

## Owned files

All paths below are relative to `content/cases/redacting-before-publication/`.
The author creates `README.md`, `checks/verify.sh`, and these exact sources:

- `src/events.ash`: event types, projection, redaction, collector API.
- `src/01-public-view.ash`: correct projection and public collection.
- `src/02-snapshot-order.ash`: ordinary pre/post-redaction snapshots.
- `src/03-early-collector.ash`: well-typed confidentiality counterexample.
- `src/04-nested-root.ash`: isolated internal chain and safe public view.
- `src/05-copy-secret.ash`: well-typed wrong public-field assignment.
- `src/06-type-changing-registration.ash`: rejected internal registration.
- `src/07-internal-to-public.ash`: rejected collector argument.
- `checks/06-type-changing-registration.diagnostic.json` and
  `checks/07-internal-to-public.diagnostic.json`: inspected semantic fixtures.

Keep complete human captures in marked README transcript fences; do not create
separate transcript fixtures. Add another lesson-local file only for a concrete
observation within this boundary; shared tooling needs separate ownership.

## Implementation sequence

1. Reconstruct the hook and module boundary at the pin; derive collector and
   projection contracts from the public goal and predict each example.
2. Implement the nominal representation, correct public entry, and snapshot
   collector. Check that the handler surrounds callback registration.
3. Add early collection, nested root, and copied-secret counterexamples;
   compare their ordinary results with explicit independent expected data.
4. Minimize both source rejections and capture their complete pinned output.
   Repair the registration by using the public-type hook, and the collector
   argument by explicitly projecting the internal event.
5. Write the connected chapter: problem, data, predictions, observations,
   source-label explanation, guarantee boundary, practice, next question.
6. Add local checks, source inventory/agreement, and source relationships;
   obtain integrator updates and final independent review before PR completion.

## Acceptance and verification

- The public result is exactly `PublicEvent(1, 7)` with no secret field.
  Snapshots are exactly internal `(1, 7, 424242)` then `(1, 7, 0)`;
  the final internal payload has secret `0`.
- Early collection returns an actual snapshot containing `424242`; its check
  succeeds as a counterexample, rather than expecting a compiler rejection.
- The nested-root internal snapshot retains `424242` while its public view
  remains `(1, 7)`. Check the source nesting that explains isolation.
- Copying secret into public code yields `(1, 424242)` and remains well typed;
  explain why this violates the chosen policy despite matching the public shape.
- Registration of `public_view` on the internal hook rejects as an ordinary
  callback type mismatch, not an invented hook-qualification reason. Passing
  `InternalEvent` to the public collector rejects at that argument boundary.
  Both repairs accept and produce the intended public result.

Run from the ash-doc checkout after implementation:

```sh
bash content/cases/redacting-before-publication/checks/verify.sh /path/to/diag-ash
bash -n content/cases/redacting-before-publication/checks/verify.sh
shellcheck -x -P SCRIPTDIR content/cases/redacting-before-publication/checks/verify.sh
markdownlint content/cases/redacting-before-publication/README.md
```

Exclude observer grants, introspection, asynchronous delivery, automatic secrecy,
new runtime mechanisms, external I/O, and a shared event library.

## Execution and handoff

Follow the [shared execution contract](2026-10-16-application-cases-integration.md#shared-execution-contract).
Use `dikini/ash-doc`, one issue and one PR for this Case, and an isolated
`.worktrees/` checkout. Dispatch the PM with `gpt-6.1-sol` / `medium`,
the developer with `gpt-6.1-sol` / `xhigh`, and the reviewer with
`gpt-6.1-sol` / `max`. The Case author owns the lesson and this temporary plan.
The integrator owns shared index, runner, and coverage/count updates, included
in this same PR before final review. Do not edit those shared paths concurrently.

The issue must carry the reader question, exact pin, this plan, owned inventory,
acceptance criteria, and exclusions. The PR records observations, affected
checks, independent review findings and repairs, and remaining discoveries.
Do not merge until the complete Case and integrator changes pass review.
Remove this plan when its outcome is complete; Git retains its history.

Read every changed source, check spelling, relative links, attribution and
pinned anchors, and run `git diff --check` and `git status --short`.
Use original prose and code; adapt the teaching method recorded in the project's
HtDP/DCIC/Liquid Shplait research rather than copying their examples or wording.
Each displayed executable block must exactly match its canonical source.
Use the existing `content/checks/lib.sh` and its JSON and human comparisons;
assert value, type, stdout, stderr, status, and causal source relationships.
Capture every provided diagnostic in full using explicit human format and
English locale; normalize only the documented checkout prefix. Keep discovery
exercise answers undisclosed. Do not promote diagnostic wording to semantics.

No Case rendering is required here. Final integration owns HTML, EPUB, and both
PDF formats. Do not run whole-book builds or unrelated lesson checks.
Correct documentation errors against the pin. Minimize a specified-behavior
failure with passing controls as a regression candidate; return unspecified
semantics to Ash design. Retain other pressure as evidence. A regression leaves
the promised outcome incomplete: do not weaken it, modify ash-lang, or move the
pin. Report a required lab/shared change for separately bounded ownership.

[overview]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/README.md
[hooks]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#synchronous-typed-hooks
[modules]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/name-resolution.md
[execution]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#synchronous-hook-execution
