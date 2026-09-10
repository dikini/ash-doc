type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Stop}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = {
    let values = Item(20, Item(22, End))
    handle (Finished (sum_scores (values, 0))) with Stop {
        at_zero partial => {
            let ignored = discard
            Stopped partial
        }
    }
}
