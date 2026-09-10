score : (Int, Int) -> Int
score (points, bonus) = points + bonus

main : Unit -> Int
main () = score (40, 2)
