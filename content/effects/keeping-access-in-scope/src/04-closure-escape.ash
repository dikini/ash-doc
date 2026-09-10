import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let leaked = resource cell<R> counter = 0 {
        let later : Unit -> Int ! {Cell.Ops<R>} = fn(ignored) {
            Cell.read counter
        }
        later
    }
    0
}
