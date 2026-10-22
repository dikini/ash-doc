type Natural =
    Zero
    | Next(Natural)

main : Unit -> Natural
main () = Next(Next(Zero))
