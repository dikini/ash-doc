import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let later = resource cell<R> counter = 41 {
        let copied = Cell.read counter
        let calculate : Unit -> Int = fn(ignored) {
            copied + 1
        }
        calculate
    }
    later ()
}
