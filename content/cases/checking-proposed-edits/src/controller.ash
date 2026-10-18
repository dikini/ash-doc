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
