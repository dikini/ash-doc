import score (Score, make, add, total)

main : Unit -> Int
main () = {
    let score : Score = add (make 10) 5
    total score
}
