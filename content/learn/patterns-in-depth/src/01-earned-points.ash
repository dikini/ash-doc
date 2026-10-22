type Answer =
    Marked(Int, Int)
    | Blank

earned_points : Answer -> Int
earned_points Marked(earned, _) = earned
earned_points Blank = 0

main : Unit -> Int
main () = earned_points (Marked(42, 50))
