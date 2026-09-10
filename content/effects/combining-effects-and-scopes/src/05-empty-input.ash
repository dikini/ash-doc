import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int)
main () = {
    let values = Scoring.End
    handle (Scoring.run values) with Scoring.Bonus {
        amount ignored => resume 2
    }
}
