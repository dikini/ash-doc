type Result =
    Found(Int)
    | Missing

main : Unit -> Result
main () = Found(42)
