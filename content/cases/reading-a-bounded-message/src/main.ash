import @builtin.cell as Cell
import @ffi.native_buffer as Buffer

type Payload = End
    | Byte(Int, Payload)

effect Stream {
    next : Unit -> Buffer.Outcome<Int>
}

read_payload : (Int, Int) -> Buffer.Outcome<Payload> ! {Stream}
read_payload (length, read) = match read == length {
    true => Buffer.Success(End)
    false => match perform Stream.next () {
        Buffer.Failure(error) => Buffer.Failure(error)
        Buffer.Success(byte) => match read_payload (length, read + 1) {
            Buffer.Failure(error) => Buffer.Failure(error)
            Buffer.Success(rest) => Buffer.Success(Byte(byte, rest))
        }
    }
}

decode : Unit -> Buffer.Outcome<Payload> ! {Stream}
decode () = match perform Stream.next () {
    Buffer.Failure(error) => Buffer.Failure(error)
    Buffer.Success(length) => read_payload (length, 0)
}

run : (Int, Int) -> Buffer.Outcome<Buffer.Outcome<Payload>>
run (capacity, length) = resource Buffer.Buffer<R> bytes = capacity {
    match Buffer.write (bytes, 0, length) {
        Buffer.Failure(error) => Buffer.Failure(error)
        Buffer.Success(()) => resource cell<C> cursor = 0 {
            handle (decode ()) with Stream {
                next () => {
                    let index = Cell.read cursor
                    let result = Buffer.read (bytes, index)
                    let ignored = match result {
                        Buffer.Failure(error) => ()
                        Buffer.Success(byte) => Cell.write (cursor, index + 1)
                    }
                    resume result
                }
            }
        }
    }
}

main : Unit -> (Buffer.Outcome<Buffer.Outcome<Payload>>,
    Buffer.Outcome<Buffer.Outcome<Payload>>, Buffer.Outcome<Buffer.Outcome<Payload>>,
    Buffer.Outcome<Buffer.Outcome<Payload>>)
main () = (run (3, 2), run (2, 2), run (1, 0), run (0, 2))
