type Scores = End
    | Item(Int, Scores)

count : (Scores, Int) -> Int
count (End, total) = total
count (Item(value, rest), total) = count (rest, total + 1)

main : Unit -> Int
main () = count (Item(20, Item(0, Item(99, End))), 0)
