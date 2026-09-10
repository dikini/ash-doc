import @builtin.native_buffer as Buffer

type Checked = Checked(Buffer.Outcome<Unit>, Buffer.Outcome<Int>)

main : Unit -> Buffer.Outcome<Checked>
main () = resource native_buffer<R> bytes = 2 {
    let written = Buffer.write (bytes, 0, 256)
    Checked(written, Buffer.read (bytes, 0))
}
