import @builtin.native_buffer as Buffer

import @builtin.cell as Cell

main : Unit -> (Buffer.Outcome<Int>, Int)
main () = resource cell<C> entered = 0 {
    let result = resource native_buffer<R> bytes = 0 {
        let ignored = Cell.write (entered, 1)
        42
    }
    (result, Cell.read entered)
}
