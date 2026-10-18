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
