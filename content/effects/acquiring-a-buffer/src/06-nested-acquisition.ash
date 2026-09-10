import @builtin.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource native_buffer<R> outer = 1 {
    resource native_buffer<S> inner = 0 {
        Buffer.length outer
    }
}
