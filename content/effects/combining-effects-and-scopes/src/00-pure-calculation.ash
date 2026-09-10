import scoring as Scoring

sum_scores : (Scoring.Scores, Int, Int) -> Scoring.Outcome
sum_scores (Scoring.End, total, bonus) = Scoring.Finished total
sum_scores (Scoring.Item(value, rest), total, bonus) = match value == 0 {
    true => Scoring.Stopped total
    false => sum_scores (rest, total + value + bonus, bonus)
}

main : Unit -> Scoring.Outcome
main () = sum_scores (Scoring.Item(20, Scoring.Item(22, Scoring.End)), 0, 2)
