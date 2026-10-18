import @builtin.cell as Cell
import @ffi.native_buffer as Buffer

main : Unit -> Int
main () = resource cell<C> position = 0 {
    let escaped = resource Buffer.Buffer<R> buffer = 1 {
        let next : (
            Unit -> Buffer.Outcome<Int> ! {Cell.Ops<C>, Buffer.Ops<Buffer.Buffer<R>>}
        ) = fn(ignored) {
            Buffer.read (buffer, Cell.read position)
        }
        next
    }
    0
}
