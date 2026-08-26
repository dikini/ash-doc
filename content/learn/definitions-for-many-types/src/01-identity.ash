identity : A -> A
identity value = value

main : Unit -> (Int, Bool)
main () = (identity 42, identity true)
