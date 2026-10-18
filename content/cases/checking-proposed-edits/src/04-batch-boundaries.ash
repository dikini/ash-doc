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
