import @builtin.cell as Cell

effect Send<A> {
    value : A -> Unit
}

main : Unit -> Int
main () = handle (resource cell<R> counter = 41 {
    let copied = Cell.read counter
    let later : Unit -> Int = fn(ignored) {
        copied + 1
    }
    let ignored = perform Send<Unit -> Int>.value later
    0
}) with Send<Unit -> Int> {
    value later => {
        let reported = later ()
        let result = resume ()
        result + reported
    }
}
