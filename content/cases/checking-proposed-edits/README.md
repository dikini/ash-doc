# Check proposed edits

A worker can propose a plausible result without having permission to make
its changes. A controller needs more than a finished list: it needs the
proposed edits, the original list it trusts, and the positions the worker may
change. It can then reconstruct the expected result before allowing the
worker to complete.

The [scripted session](../running-a-scripted-session/README.md) separated a
calculation from the commands supplied by its handler. Here one immutable
proposal contains an entire edit batch and its candidate artifact. Continue
from [resumption](../../effects/resuming-a-calculation/README.md) and
[early stopping](../../effects/stopping-a-calculation/README.md): resuming a
worker safely and approving its data are separate responsibilities.

## Keep the original outside the proposal

Use a finite list of integers as the artifact. Positions start at zero. The
controller owns original `[10,20,30]` and allowed positions `[1,2]`. A worker
proposes `1 := 25`, then `2 := 35`, together with candidate `[10,25,35]`.
Square brackets and `:=` here are non-executable notation; the Ash data below
uses constructors.

The proposal contains an edits list and one candidate. It contains neither
an authoritative original nor an authoritative permission list. That keeps
the question precise: does this proposed artifact result from these edits to
*our* original, and is each requested position permitted? Reviewing an entire
immutable batch also avoids a changing current artifact between review rounds.
A session with several rounds would need an additional agreement about that
current state.

Derive the operation contracts from the desired result. `make_proposal`
receives an original and edits and constructs their candidate. `Review.propose`
takes the proposal and requests a `Decision`. `Allow` lets the worker return
`Completed(candidate)`; `Reject(reason)` lets it return `Rejected(reason)`.
A controller that stops the waiting worker instead constructs `Cancelled`.
Those constructors are ordinary data; their names confer no permission.

The controller must establish three conditions before allowing the batch:

1. Every requested position exists in its original artifact.
2. Every requested position appears in its allowed-position list.
3. The complete candidate equals the result of applying the edits in order.

Existence comes first so position `7` is missing, while existing position `0`
is forbidden. A write of `0 := 10` is still forbidden even though it would
leave that field unchanged. Permission is about the proposed operation, not
only the difference between final artifacts.

## Construct a candidate by rebuilding its prefix

For one edit, walk the remaining suffix with an index starting at zero. Keep
already visited values in a reversed prefix. When the index equals the target
position, replace the current value and rebuild the prefix onto that suffix.
The invariant is non-executable notation:

```text
artifact before this edit = reverse(prefix) ++ suffix
```

For `1 := 25`, the reversed prefix becomes `[10]` and the suffix is
`[20,30]`. Replacing its head gives `[25,30]`; rebuilding yields
`[10,25,30]`. The next edit starts again at index zero with that updated
artifact, so `2 := 35` yields `[10,25,35]`.

`rebuild` preserves prefix order by moving its head onto the suffix and
recursing on the smaller reversed prefix. `replace_from` advances through a
smaller suffix until equality selects the replacement. If no position matches,
it rebuilds the unchanged artifact; that behavior alone does not authorize a
missing position. `worker_candidate` applies the remaining edits to each
updated artifact. An empty batch returns its input unchanged, and repeated
writes therefore use the last value.

Keep the data and worker definitions in `edits.ash`:

<!-- source: src/edits.ash -->
```ash
pub type Artifact = End
    | Item(Int, Artifact)
pub type Edit = Edit(Int, Int)
pub type Edits = NoEdits
    | More(Edit, Edits)
pub type Proposal = Proposal(Edits, Artifact)
pub type RejectReason = ForbiddenPosition(Int)
    | MissingPosition(Int)
    | CandidateMismatch
    | ScriptedRejection
pub type Decision = Allow
    | Reject(RejectReason)
pub type Result = Completed(Artifact)
    | Rejected(RejectReason)
    | Cancelled

pub effect Review {
    propose : Proposal -> Decision
}

pub effect AfterReview {
    reached : Unit -> Unit
}

rebuild : (Artifact, Artifact) -> Artifact
rebuild (End, suffix) = suffix
rebuild (Item(value, prefix), suffix) = rebuild (prefix, Item(value, suffix))

replace_from : (Int, Int, Int, Artifact, Artifact) -> Artifact
replace_from (position, value, index, prefix, End) = rebuild (prefix, End)
replace_from (position, value, index, prefix, Item(current, suffix)) = {
    match index == position {
        true => rebuild (prefix, Item(value, suffix))
        false => replace_from (
            position, value, index + 1, Item(current, prefix), suffix
        )
    }
}

pub worker_candidate : (Artifact, Edits) -> Artifact
worker_candidate (original, NoEdits) = original
worker_candidate (original, More(Edit(position, value), rest)) = {
    let updated = replace_from (position, value, 0, End, original)
    worker_candidate (updated, rest)
}

pub valid_batch : Unit -> Edits
valid_batch () = More(Edit(1, 25), More(Edit(2, 35), NoEdits))

pub make_proposal : (Artifact, Edits) -> Proposal
make_proposal (original, edits) = Proposal (
    edits, worker_candidate (original, edits)
)

pub worker : Proposal -> Result ! {Review, AfterReview}
worker proposal = {
    let decision = perform Review.propose proposal
    let ignored = perform AfterReview.reached ()
    match decision {
        Allow => {
            let Proposal(ignored_edits, candidate) = proposal
            Completed candidate
        }
        Reject(reason) => Rejected reason
    }
}
```

The worker's post-request suffix begins with `AfterReview.reached`. This small
observation request records whether execution continued after review; it is
not an authorization operation. The following match interprets the supplied
decision. Notice that an ordinary rejection still runs that suffix before
returning its reason.

The [effect contract][effects] checks the proposal and answer types.
`Review.propose` does not itself know the original or the allowed positions.
Likewise, `worker_candidate` can calculate a forbidden edit. These functions
construct and communicate data; the controller must judge that data.

## Reconstruct the answer independently

A checker that calls the worker's replacement function could repeat its
mistake. Use a different calculation in the controller. `model_at` traverses
the whole artifact by index, selects the new value at the matching index, and
reconstructs every list node. It has no reversed prefix and does not call
`replace_from`. Applying these full passes sequentially gives `model`.

On each pass, a nonmatching index preserves the current value; the matching
index supplies the replacement. Both cases recurse on the remaining tail.
Consequently, an existing position changes exactly once per edit and the list
length stays fixed. Sequential passes explain both last-write-wins behavior
and why the empty batch preserves the original.

Derive `validate : Proposal -> Decision` from that model. First inspect every
edit for existence and permission using controller-owned values. Only when
those checks pass, compare the candidate against `model(original, edits)`.
`same_artifact` checks corresponding integers, both empty tails, and unequal
shapes, so a matching prefix is insufficient.

In `controller.ash`, `original` and `allowed_positions` have no worker inputs.
The proposal pattern binds only `edits` and `candidate`. Their declared types
alone do not establish trust; these definitions and call sites establish which
values the controller actually uses:

<!-- source: src/controller.ash -->
```ash
import edits as Edits

pub type Script = Check
    | Refuse
    | Cancel

type Inspection = Accepted
    | Problem(Edits.RejectReason)

pub original : Unit -> Edits.Artifact
original () = Edits.Item(10, Edits.Item(20, Edits.Item(30, Edits.End)))

pub allowed_positions : Unit -> Edits.Artifact
allowed_positions () = Edits.Item(1, Edits.Item(2, Edits.End))

model_at : (Edits.Artifact, Int, Int, Int) -> Edits.Artifact
model_at (Edits.End, index, position, value) = Edits.End
model_at (Edits.Item(current, rest), index, position, value) = {
    let selected = match index == position {
        true => value
        false => current
    }
    Edits.Item(selected, model_at (rest, index + 1, position, value))
}

pub model : (Edits.Artifact, Edits.Edits) -> Edits.Artifact
model (artifact, Edits.NoEdits) = artifact
model (artifact, Edits.More(Edits.Edit(position, value), rest)) = {
    model (model_at (artifact, 0, position, value), rest)
}

position_exists : (Edits.Artifact, Int, Int) -> Bool
position_exists (Edits.End, index, position) = false
position_exists (Edits.Item(ignored_value, rest), index, position) = {
    match index == position {
        true => true
        false => position_exists (rest, index + 1, position)
    }
}

permitted : (Edits.Artifact, Int) -> Bool
permitted (Edits.End, position) = false
permitted (Edits.Item(allowed, rest), position) = match allowed == position {
    true => true
    false => permitted (rest, position)
}

same_artifact : (Edits.Artifact, Edits.Artifact) -> Bool
same_artifact (Edits.End, Edits.End) = true
same_artifact (Edits.Item(left, left_rest), Edits.Item(right, right_rest)) = {
    match left == right {
        true => same_artifact (left_rest, right_rest)
        false => false
    }
}
same_artifact (left, right) = false

inspect_edits : Edits.Edits -> Inspection
inspect_edits Edits.NoEdits = Accepted
inspect_edits (Edits.More(Edits.Edit(position, ignored_value), rest)) = {
    match position_exists (original (), 0, position) {
        false => Problem (Edits.MissingPosition position)
        true => match permitted (allowed_positions (), position) {
            false => Problem (Edits.ForbiddenPosition position)
            true => inspect_edits rest
        }
    }
}

pub validate : Edits.Proposal -> Edits.Decision
validate (Edits.Proposal(edits, candidate)) = match inspect_edits edits {
    Problem(reason) => Edits.Reject reason
    Accepted => match same_artifact (candidate, model (original (), edits)) {
        true => Edits.Allow
        false => Edits.Reject Edits.CandidateMismatch
    }
}

pub run_proposal : (Script, Edits.Proposal) -> (Edits.Result, Bool)
run_proposal (script, proposal) = handle {
    let result = handle (Edits.worker proposal) with Edits.Review {
        propose offered => match script {
            Check => resume (validate offered)
            Refuse => resume (Edits.Reject Edits.ScriptedRejection)
            Cancel => {
                let ignored = discard
                Edits.Cancelled
            }
        }
    }
    (result, false)
} with Edits.AfterReview {
    reached ignored => {
        let (result, ignored_later) = resume ()
        (result, true)
    }
}

pub run : Script -> (Edits.Result, Bool)
run script = run_proposal (
    script, Edits.make_proposal (original (), Edits.valid_batch ())
)
```

`position_exists` increases an index while consuming a finite list.
`permitted` compares the requested position with each allowed integer. Neither
needs an integer ordering operator: equality and finite structural recursion
supply the bounds checks. A target that never equals an enumerated index is
missing.

The `Check` clause validates the actual `offered` proposal before supplying its
decision through `resume`. The `Refuse` script supplies an ordinary rejected
decision. The `Cancel` script instead consumes its owned continuation with
`discard` and then constructs `Cancelled`. The right to resume or discard
stays in this local operation clause; a helper computes the ordinary decision.
The [completion rules][completion] explain why resumption restores the waiting
worker and discard abandons its suffix.

The outer `AfterReview` handler resumes the marker request and returns `true`
as the pair's second field. Without a marker request, that field stays `false`.
This observes execution after the review request without mutable state. It
adds no permission check and does not change which proposal gets validated.

For an artifact of length `n`, `m` edits, and `a` allowed positions, each
worker edit scans and rebuilds at most `n` nodes. Each model pass visits `n`
nodes; validation also searches for each position and permission and compares
the complete candidate. Source-level list work is therefore bounded by
`O(m(n + a) + n)`. Reconstructing lists allocates nodes; this bound claims no
constant stack space or compiler optimization. The original remains available
as an immutable value throughout review.

## Observe three ways to finish review

Enter `checking-proposed-edits/src` from the Cases directory. The three
entries share the original, batch, worker, and controller. Only their script
choice changes. Predict both the ordinary result and whether the worker's
post-request marker is reached.

<!-- source: src/01-allow.ash -->
```ash
import edits as Edits
import controller as Controller

main : Unit -> (Edits.Result, Bool)
main () = Controller.run Controller.Check
```

<!-- observation: src/01-allow.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 01-allow.ash
(Completed(Item(10, Item(25, Item(35, End)))), true) : (Result, Bool)
```
<!-- markdownlint-enable MD013 -->

All validation conditions pass, so the clause resumes with `Allow`. The worker
reaches its marker and returns the candidate `[10,25,35]`. The `true` records
that resumed suffix, not a separate claim that the artifact is correct.

<!-- source: src/02-reject.ash -->
```ash
import edits as Edits
import controller as Controller

main : Unit -> (Edits.Result, Bool)
main () = Controller.run Controller.Refuse
```

<!-- observation: src/02-reject.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 02-reject.ash
(Rejected(ScriptedRejection), true) : (Result, Bool)
```
<!-- markdownlint-enable MD013 -->

`Refuse` resumes with `Reject(ScriptedRejection)`. The worker still continues
after the request, reaches the marker, and returns `Rejected` with that reason.
Rejecting the proposal is an ordinary answer to the operation.

<!-- source: src/03-cancel.ash -->
```ash
import edits as Edits
import controller as Controller

main : Unit -> (Edits.Result, Bool)
main () = Controller.run Controller.Cancel
```

<!-- observation: src/03-cancel.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 03-cancel.ash
(Cancelled, false) : (Result, Bool)
```
<!-- markdownlint-enable MD013 -->

`Cancel` supplies no operation answer. Discard consumes the continuation that
would have reached the marker and interpreted the decision. The clause then
returns `Cancelled`, leaving the marker false. This local capture owns no
resource or cleanup obligation; the accepted discard does not establish that
an arbitrary suspended worker can always be abandoned safely.

## Distinguish policy boundaries from candidate agreement

A few differing inputs test the controller's three conditions separately.
Before running `04-batch-boundaries.ash`, predict these decisions:

- Existing but forbidden position `0`, even when writing its original value.
- Missing position `7`, which also does not appear in the permission list.
- Valid edits paired with the unchanged original as a wrong candidate.
- Two authorized writes to position `1`, first `25`, then `27`.
- An empty batch paired with the original, then with a different candidate.

The entry also returns the worker and model artifacts for valid, repeated,
and empty edits. Compare each calculation with a hand-derived whole artifact;
agreement with each other alone would not rule out a shared mistaken answer.

<!-- source: src/04-batch-boundaries.ash -->
```ash
import edits as Edits
import controller as Controller

main : Unit -> (
    (Edits.Decision, Edits.Decision, Edits.Decision),
    (Edits.Decision, Edits.Decision, Edits.Decision),
    (Edits.Artifact, Edits.Artifact, Edits.Artifact),
    (Edits.Artifact, Edits.Artifact, Edits.Artifact)
)
main () = {
    let original = Controller.original ()
    let valid = Edits.valid_batch ()
    let repeated = Edits.More (
        Edits.Edit(1, 25), Edits.More(Edits.Edit(1, 27), Edits.NoEdits)
    )
    let Edits.Proposal(ignored_valid, valid_candidate) = (
        Edits.make_proposal (original, valid)
    )
    let Edits.Proposal(ignored_repeated, repeated_candidate) = (
        Edits.make_proposal (original, repeated)
    )
    let Edits.Proposal(ignored_empty, empty_candidate) = (
        Edits.make_proposal (original, Edits.NoEdits)
    )
    let forbidden = Edits.Proposal (
        Edits.More(Edits.Edit(0, 10), Edits.NoEdits), original
    )
    let missing = Edits.Proposal (
        Edits.More(Edits.Edit(7, 99), Edits.NoEdits), original
    )
    (
        (
            Controller.validate forbidden,
            Controller.validate missing,
            Controller.validate (Edits.Proposal(valid, original))
        ),
        (
            Controller.validate (Edits.Proposal(repeated, repeated_candidate)),
            Controller.validate (Edits.Proposal(Edits.NoEdits, original)),
            Controller.validate (Edits.Proposal(Edits.NoEdits, valid_candidate))
        ),
        (valid_candidate, repeated_candidate, empty_candidate),
        (
            Controller.model (original, valid),
            Controller.model (original, repeated),
            Controller.model (original, Edits.NoEdits)
        )
    )
}
```

Run `ash 04-batch-boundaries.ash`. It returns one four-part tuple. The following
tables select every field of that one captured result; the surrounding tuple
structure and type annotation are omitted. The first two groups contain these
decisions, in source order:

<!-- boundary-decisions: src/04-batch-boundaries.ash -->
| Group | Proposed batch or candidate | Observed decision |
| --- | --- | --- |
| First | `0 := 10`, unchanged candidate | `Reject(ForbiddenPosition(0))` |
| First | `7 := 99`, unchanged candidate | `Reject(MissingPosition(7))` |
| First | Valid edits, unchanged candidate | `Reject(CandidateMismatch)` |
| Second | `1 := 25`, then `1 := 27` | `Allow` |
| Second | Empty edits, original candidate | `Allow` |
| Second | Empty edits, changed candidate | `Reject(CandidateMismatch)` |

The third and fourth groups hold complete worker and model artifacts:

<!-- boundary-artifacts: src/04-batch-boundaries.ash -->
<!-- markdownlint-disable MD013 -->
| Edits | Worker artifact | Model artifact |
| --- | --- | --- |
| Valid | `Item(10, Item(25, Item(35, End)))` | `Item(10, Item(25, Item(35, End)))` |
| Repeated position | `Item(10, Item(27, Item(30, End)))` | `Item(10, Item(27, Item(30, End)))` |
| Empty | `Item(10, Item(20, Item(30, End)))` | `Item(10, Item(20, Item(30, End)))` |
<!-- markdownlint-enable MD013 -->

The unchanged forbidden write shows why checking only the candidate's changed
positions would miss the policy violation. The missing-position reason shows
which check runs first. Candidate equality then distinguishes both the wrong
valid-batch candidate and the wrong empty-batch candidate. The repeated
position confirms sequential interpretation rather than rejecting duplicates
or letting the first write win.

Now remove the validation decision itself. `05-approve-all.ash` gives every
proposal `Allow`, including a write of `0 := 99`:

<!-- source: src/05-approve-all.ash -->
```ash
import edits as Edits
import controller as Controller

main : Unit -> (Edits.Result, Bool)
main () = {
    let forbidden_edits = Edits.More(Edits.Edit(0, 99), Edits.NoEdits)
    let proposal = Edits.make_proposal (Controller.original (), forbidden_edits)
    handle {
        let result = handle (Edits.worker proposal) with Edits.Review {
            propose ignored => resume Edits.Allow
        }
        (result, false)
    } with Edits.AfterReview {
        reached ignored => {
            let (result, ignored_later) = resume ()
            (result, true)
        }
    }
}
```

Predict whether the compiler accepts this controller and which artifact the
worker returns:

<!-- observation: src/05-approve-all.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 05-approve-all.ash
(Completed(Item(99, Item(20, Item(30, End)))), true) : (Result, Bool)
```
<!-- markdownlint-enable MD013 -->

The continuation is consumed once, and all operation, answer, and result types
fit. Yet the completed artifact changes forbidden position `0`. This accepted
program violates the chosen policy. A `Decision` type cannot by itself make
every `Allow` justified. The controller's checks and its trusted inputs supply
that justification; safe continuation use does not supply it.

## Consume a continuation exactly once

The previous mistake produced an ordinary wrong application result. A different
mistake tries to use the same continuation twice. Isolate that boundary from
the edit data in `06-double-resume.ash`; its local review asks only for a Boolean:

<!-- source: src/06-double-resume.ash -->
```ash
effect Review {
    propose : Unit -> Bool
}

main : Unit -> Bool
main () = handle (perform Review.propose ()) with Review {
    propose ignored => {
        let result = resume true
        resume result
    }
}
```

The first `resume` receives the waiting computation's result. Predict what
right remains before the next line, then run from the same `src` directory:

<!-- diagnostic: src/06-double-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-double-resume.ash
This path has already resumed or discarded the continuation; it cannot do so again.
  --> /path/to/ash-doc/content/cases/checking-proposed-edits/src/06-double-resume.ash:9:9
9 |         resume result
  |         ^ This path has already resumed or discarded the continuation; it cannot do so again.
reason: effect.resume-already-consumed
```
<!-- markdownlint-enable MD013 -->

The label points at the second `resume result`. The preceding `resume true`
already consumed this clause's capability, so the later use encounters a
consumed continuation. The message describes that reuse; its secondary reason
is `effect.resume-already-consumed`.

Return the ordinary result after the first resumption instead. The complete
repair is `08-resume-once.ash`:

<!-- source: src/08-resume-once.ash -->
```ash
effect Review {
    propose : Unit -> Bool
}

main : Unit -> Bool
main () = handle (perform Review.propose ()) with Review {
    propose ignored => {
        let result = resume true
        result
    }
}
```

<!-- observation: src/08-resume-once.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 08-resume-once.ash
true : Bool
```
<!-- markdownlint-enable MD013 -->

The right to resume is consumed once; using the returned Boolean needs no
second resumption. The [effect rules][effects] govern consumption on each
normally completing path. They do not promise termination or authorize the
Boolean supplied by the handler.

`07-missing-resume.ash` makes the opposite mistake: it returns a Boolean
without answering or abandoning the waiting computation:

<!-- source: src/07-missing-resume.ash -->
```ash
effect Review {
    propose : Unit -> Bool
}

main : Unit -> Bool
main () = handle (perform Review.propose ()) with Review {
    propose ignored => false
}
```

<!-- diagnostic: src/07-missing-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 07-missing-resume.ash
This path can finish without resuming or safely discarding the continuation.
  --> /path/to/ash-doc/content/cases/checking-proposed-edits/src/07-missing-resume.ash:7:24
7 |     propose ignored => false
  |                        ^ This path can finish without resuming or safely discarding the continuation.
reason: effect.resume-not-consumed
```
<!-- markdownlint-enable MD013 -->

The label points at the clause's `false`, where the path finishes while its
capability remains available. Returning an ordinary value did not consume it.
The message names both permitted ways to finish that obligation; its secondary
reason is `effect.resume-not-consumed`.

If the intention is to continue, use the one-resume pattern. If the intention
is to stop this locally owned work, consume it with discard and then supply
the handler's result, as in `09-owned-discard.ash`:

<!-- source: src/09-owned-discard.ash -->
```ash
effect Review {
    propose : Unit -> Bool
}

main : Unit -> Bool
main () = handle (perform Review.propose ()) with Review {
    propose ignored => {
        let ignored = discard
        false
    }
}
```

<!-- observation: src/09-owned-discard.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 09-owned-discard.ash
false : Bool
```
<!-- markdownlint-enable MD013 -->

Discard produces unit, which the binding sets aside. The subsequent `false`
is the handler's Boolean result; it was never supplied as an answer to the
operation. These complete diagnostic captures describe this edition's tool
presentation. Their consumption reasons identify language boundaries, while
the wording and printed layout are not a language contract.

## Practice: preserve both kinds of correctness

Make scratch copies outside this lesson's `src` directory, keeping `edits.ash`
and `controller.ash` beside the entries that import them. Predict each changed
result before running it.

1. Reverse the repeated edits in `04-batch-boundaries.ash`. Derive the worker
   and model artifacts and explain what the checker should require.
2. Give the forbidden unchanged write the `Check` script through
   `run_proposal`. Predict the result and marker, comparing ordinary rejection
   with cancellation.
3. Change the trusted allowed-position list to include `0`. Identify which
   boundary observations may change and which checks still apply.
4. Keep valid edits but make a candidate with one extra list item. Explain
   which part of `same_artifact` must prevent approval.
5. Repair the missing-consumption example using resumption instead of discard.
   Explain which Boolean is an operation answer and which is a handler result.

An accepted controller uses its continuation safely. A correct controller
also checks each edit against its own authority and reconstructs the whole
artifact from its own original. Keeping those obligations separate makes an
unjustified approval visible as an application mistake. Next comes a related
question for a longer calculation: which properties can a partially completed
result promise when its continuation is cancelled?

[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[completion]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
