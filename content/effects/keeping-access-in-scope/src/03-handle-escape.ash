import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let leaked = resource cell<R> counter = 0 {
        counter
    }
    0
}
