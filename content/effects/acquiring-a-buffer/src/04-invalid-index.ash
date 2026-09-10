import @builtin.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource native_buffer<R> bytes = 2 {
    Buffer.read (bytes, 2)
}
