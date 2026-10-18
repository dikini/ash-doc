import @ffi.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource Buffer.Buffer<R> bytes = 2 {
    Buffer.read (bytes, 2)
}
