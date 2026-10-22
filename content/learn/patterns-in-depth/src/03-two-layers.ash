type Answer =
    Marked(Int, Int)
    | Blank

type Entry =
    Graded(Answer)
    | Skipped

earned_from : Entry -> Int
earned_from Graded(Marked(earned, _)) = earned
earned_from Graded(Blank) = 0
earned_from Skipped = 0

main : Unit -> Int
main () = earned_from (Graded(Marked(42, 50)))
