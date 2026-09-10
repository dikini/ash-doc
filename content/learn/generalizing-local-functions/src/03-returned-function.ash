make_identity : Unit -> A -> A
make_identity () = fn(value) {
    value
}

main : Unit -> (Int, Bool)
main () = {
    let identity = make_identity ()
    (identity 42, identity true)
}
