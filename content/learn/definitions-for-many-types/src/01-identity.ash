id : A -> A
id value = value

main : Unit -> (Int, Bool)
main () = (id 42, id true)
