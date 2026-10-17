import @ffi.native_buffer as Buffer

main : Unit -> Int
main () = {
    let leaked = resource Buffer.Buffer<R> bytes = 2 {
        bytes
    }
    0
}
