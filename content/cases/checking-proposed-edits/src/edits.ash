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
