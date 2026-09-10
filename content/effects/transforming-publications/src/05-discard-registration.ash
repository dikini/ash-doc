import @builtin.cell as Cell

effect Adjust {
    publish : Int -> Int
}

effect Stop {
    now : Unit -> Unit
}

main : Unit -> (Int, Int, Int)
main () = resource cell<R> calls = 0 {
    let change : Int -> Int ! {Cell.Ops<R>} = fn(value) {
        let ignored = Cell.write (calls, (Cell.read calls) + 1)
        value + 1
    }
    hook Adjust {
        let result = handle (register Adjust change {
            let ignored = perform Stop.now ()
            perform Adjust.publish 3
        }) with Stop {
            now ignored => {
                let ignored = discard
                7
            }
        }
        let later = perform Adjust.publish 5
        (result, later, Cell.read calls)
    }
}
