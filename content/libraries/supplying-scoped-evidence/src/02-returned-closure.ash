make_adder : Int -> Int -> Int
make_adder amount = {
    newtype Offset = Offset(Int)
    let offset = Offset(amount)
    fn(value) {
        match offset {
            Offset(saved) => saved + value
        }
    }
}

main : Unit -> Int
main () = make_adder 40 2
