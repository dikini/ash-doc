type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

sum_scores : (Scores, Int) -> Outcome
sum_scores (End, total) = Finished total
sum_scores (Item(value, rest), total) = match value == 0 {
    true => Stopped total
    false => sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = sum_scores (Item(20, Item(0, Item(99, End))), 0)
