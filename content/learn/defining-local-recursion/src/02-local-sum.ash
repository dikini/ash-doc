type Scores = End
    | Item(Int, Scores)

main : Unit -> Int
main () = {
    let bonus = 1
    let rec sum : Scores -> Int = fn(values) {
        match values {
            End => 0
            Item(value, rest) => value + bonus + sum rest
        }
    }
    sum (Item(20, Item(20, End)))
}
