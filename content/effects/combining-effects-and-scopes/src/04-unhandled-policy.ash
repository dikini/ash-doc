import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int) ! {Scoring.Bonus}
main () = {
    let values = Scoring.Item(20, Scoring.Item(22, Scoring.End))
    Scoring.run values
}
