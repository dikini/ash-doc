import @ffi.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource Buffer.Buffer<R> outer = 1 {
    resource Buffer.Buffer<S> inner = 0 {
        Buffer.length outer
    }
}
