type Natural =
    Zero
    | Next(Natural)

to_int : Natural -> Int
to_int Zero = 0
to_int Next(rest) = 1 + to_int rest

main : Unit -> Int
main () = to_int (Next(Next(Next(Zero))))
