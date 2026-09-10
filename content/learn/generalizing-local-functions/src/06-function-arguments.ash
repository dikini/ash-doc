apply_twice : (A -> A, A) -> A
apply_twice (transform, value) = transform (transform value)

main : Unit -> (Int, Bool)
main () = {
    let identity = fn(value) {
        value
    }
    (apply_twice (identity, 42), apply_twice (identity, true))
}
