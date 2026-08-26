make_adder : Int -> Int -> Int
make_adder amount = fn(number) {
    amount + number
}

main : Unit -> Int
main () = make_adder 20 22
