type Natural =
    Zero
    | Next(Natural)

to_int : Natural -> Int
to_int Zero = 0
to_int Next(rest) = 1 + to_int rest

to_int_down : Natural -> Int -> Int
to_int_down Zero count = count
to_int_down Next(rest) count = to_int_down rest (count + 1)

main : Unit -> (Int, Int)
main () = {
    let three = Next(Next(Next(Zero)))
    (to_int three, to_int_down three 0)
}
