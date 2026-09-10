import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int)
main () = {
    let values = Scoring.Item(20, Scoring.Item(22, Scoring.End))
    handle (Scoring.run values) with Scoring.Bonus {
        amount ignored => resume 2
    }
}
