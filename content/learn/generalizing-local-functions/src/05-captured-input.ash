pair_with : A -> ((A, Int), (A, Bool))
pair_with saved = {
    let pair = fn(value) {
        (saved, value)
    }
    (pair 42, pair true)
}

main : Unit -> ((Bool, Int), (Bool, Bool))
main () = pair_with false
