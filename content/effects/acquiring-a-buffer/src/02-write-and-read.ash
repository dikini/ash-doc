import @builtin.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource native_buffer<R> bytes = 4 {
    match Buffer.write (bytes, 1, 42) {
        Buffer.Success(()) => Buffer.read (bytes, 1)
        Buffer.Failure(error) => Buffer.Failure error
    }
}
