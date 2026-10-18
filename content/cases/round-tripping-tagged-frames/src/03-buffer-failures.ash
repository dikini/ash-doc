import @builtin.cell as Cell
import @ffi.native_buffer as Buffer
import frames as Frames
import codec as Codec

type WriteControl = WriteControl(Buffer.Outcome<Unit>, Buffer.Outcome<Int>)

invalid_acquisition : Unit -> (Buffer.Outcome<Buffer.Outcome<Unit>>, Int)
invalid_acquisition () = resource cell<C> entered = 0 {
    let result = resource Buffer.Buffer<R> buffer = 0 {
        let ignored = Cell.write (entered, 1)
        Buffer.Success ()
    }
    (result, Cell.read entered)
}

unchanged_byte : Unit -> Buffer.Outcome<Buffer.Outcome<WriteControl>>
unchanged_byte () = resource Buffer.Buffer<R> buffer = 1 {
    match Buffer.write (buffer, 0, 42) {
        Buffer.Failure(error) => Buffer.Failure error
        Buffer.Success(()) => {
            let refused = Buffer.write (buffer, 0, 256)
            Buffer.Success (WriteControl(refused, Buffer.read (buffer, 0)))
        }
    }
}

main : Unit -> (
    Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>,
    Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>,
    (Buffer.Outcome<Buffer.Outcome<Unit>>, Int),
    Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>,
    Buffer.Outcome<Buffer.Outcome<WriteControl>>
)
main () = (
    Codec.run_frame (1, Frames.Byte(1, Frames.Byte(0, Frames.End))),
    Codec.run_frame (0, Frames.Byte(0, Frames.End)),
    invalid_acquisition (),
    Codec.run_frame (1, Frames.Byte(256, Frames.End)),
    unchanged_byte ()
)
