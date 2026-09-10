import @builtin.native_buffer as Buffer

main : Unit -> Int
main () = {
    let leaked = resource native_buffer<R> bytes = 2 {
        bytes
    }
    0
}
