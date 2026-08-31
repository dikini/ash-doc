type Score = Score(Int)
type Count = Count(Int)

keep_score : Score -> Score
keep_score score = score

main : Unit -> Score
main () = keep_score (Count(42))
