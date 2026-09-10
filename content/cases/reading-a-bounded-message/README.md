# Read a bounded byte message

A decoder can request the next byte without knowing how the input stores it.
This message has one length byte followed by exactly that many payload bytes.
`decode` reads the prefix; `read_payload` requests the promised payload and
stops on the first failed access.

Continue from [the scripted session](../running-a-scripted-session/README.md)
and [acquiring a buffer](../../effects/acquiring-a-buffer/README.md). A handler
connects `Stream.next` to a scoped native buffer and advances a cell cursor only
after a successful read. The decoder's row names `Stream`; the handler owns the
buffer and cursor access. Only ordinary result data leaves those scopes.

From the Cases directory, enter `reading-a-bounded-message/src`. The buffer is
zero-initialized, so writing just the prefix leaves zero-valued payload bytes.
The four runs request a complete two-byte payload, a truncated payload, an empty
payload, and an invalid allocation length. Predict each wrapper before running
`ash main.ash`.

<!-- source: src/main.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import @builtin.native_buffer as Buffer

type Bytes = End
    | Byte(Int, Bytes)

effect Stream {
    next : Unit -> Buffer.Outcome<Int>
}

read_payload : (Int, Int) -> Buffer.Outcome<Bytes> ! {Stream}
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

decode : Unit -> Buffer.Outcome<Bytes> ! {Stream}
decode () = match perform Stream.next () {
    Buffer.Failure(error) => Buffer.Failure(error)
    Buffer.Success(length) => read_payload (length, 0)
}

run : (Int, Int) -> Buffer.Outcome<Buffer.Outcome<Bytes>>
run (capacity, length) = resource native_buffer<R> bytes = capacity {
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

main : Unit -> (Buffer.Outcome<Buffer.Outcome<Bytes>>,
    Buffer.Outcome<Buffer.Outcome<Bytes>>, Buffer.Outcome<Buffer.Outcome<Bytes>>,
    Buffer.Outcome<Buffer.Outcome<Bytes>>)
main () = (run (3, 2), run (2, 2), run (1, 0), run (0, 2))
```
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable MD013 -->
```text
$ ash main.ash
(Success(Success(Byte(0, Byte(0, End)))), Success(Failure(InvalidIndex)), Success(Success(End)), Failure(InvalidLength)) : (Outcome<Outcome<Bytes>>, Outcome<Outcome<Bytes>>, Outcome<Outcome<Bytes>>, Outcome<Outcome<Bytes>>)
```
<!-- markdownlint-enable MD013 -->

`Success(Success(Byte(0, Byte(0, End))))` records successful acquisition and
decoding. `Success(Failure(InvalidIndex))` records a buffer that was acquired
but ended before the promised payload did. `Success(Success(End))` is a valid
empty payload. `Failure(InvalidLength)` occurs before the resource body runs.
The two outcome layers preserve that distinction.

Every buffer write and read checks its outcome. The decoder propagates the
first failed read, so it does not retry the unchanged cursor. Its length comes
from a byte, bounding this example to at most 255 payload requests. This tiny
format consumes the declared payload; it does not require that the buffer end
immediately afterward.

The useful separation is visible in the contracts: parsing requests bytes,
while one handler supplies checked access and owns the position. The program
uses an in-memory buffer, with no external stream or general FFI.

As an exercise, try a prefix of one with capacity three and explain which byte
is left unread. A reasonable follow-up is a second handler that supplies a fixed
sequence directly, leaving `decode` unchanged. Add richer message fields only
when they illustrate another concept.
