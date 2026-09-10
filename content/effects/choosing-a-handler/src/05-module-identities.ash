import left as Left
import right as Right

main : Unit -> Int
main () = handle {
    let first = handle (perform Left.Bonus.amount ()) with Left.Bonus {
        amount ignored => resume 2
    }
    first + (perform Right.Bonus.amount ())
} with Right.Bonus {
    amount ignored => resume 5
}
