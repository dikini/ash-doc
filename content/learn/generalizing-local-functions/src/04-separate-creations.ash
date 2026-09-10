make_identity : Unit -> A -> A
make_identity () = fn(value) {
    value
}

main : Unit -> (Int, Bool)
main () = {
    let integer_identity = make_identity ()
    let boolean_identity = make_identity ()
    (integer_identity 42, boolean_identity true)
}
