import @builtin.cell as Cell
import @ffi.native_buffer as Buffer
import frames as Frames

pub effect Cursor {
    next : Unit -> Buffer.Outcome<Frames.Next>
}

pub encode : Frames.Message -> Frames.ByteValues
encode Frames.Ping = Frames.Byte(0, Frames.End)
encode (Frames.Reading(value)) = Frames.Byte(1, Frames.Byte(value, Frames.End))
encode (Frames.Pair(first, second)) = Frames.Byte (
    2, Frames.Byte(first, Frames.Byte(second, Frames.End))
)

pub byte_count : Frames.ByteValues -> Int
byte_count Frames.End = 0
byte_count (Frames.Byte(value, rest)) = 1 + byte_count rest

write_all<R> : (
    (Buffer.Buffer<R>, Frames.ByteValues, Int) ->
    Buffer.Outcome<Unit> ! {Buffer.Ops<Buffer.Buffer<R>>}
) where Buffer.Provider<Buffer.Buffer<R>>
write_all (buffer, Frames.End, index) = Buffer.Success ()
write_all (buffer, Frames.Byte(value, rest), index) = {
    match Buffer.write (buffer, index, value) {
        Buffer.Failure(error) => Buffer.Failure error
        Buffer.Success(()) => write_all (buffer, rest, index + 1)
    }
}

finish : Frames.Message -> Buffer.Outcome<Frames.DecodeResult> ! {Cursor}
finish message = match perform Cursor.next () {
    Buffer.Failure(error) => Buffer.Failure error
    Buffer.Success(Frames.EndOfFrame) => Buffer.Success (Frames.Decoded message)
    Buffer.Success(Frames.Value(extra)) => Buffer.Success Frames.TrailingData
}

decode_reading : Unit -> Buffer.Outcome<Frames.DecodeResult> ! {Cursor}
decode_reading () = match perform Cursor.next () {
    Buffer.Failure(error) => Buffer.Failure error
    Buffer.Success(Frames.EndOfFrame) => Buffer.Success Frames.Truncated
    Buffer.Success(Frames.Value(value)) => finish (Frames.Reading value)
}

decode_pair : Unit -> Buffer.Outcome<Frames.DecodeResult> ! {Cursor}
decode_pair () = match perform Cursor.next () {
    Buffer.Failure(error) => Buffer.Failure error
    Buffer.Success(Frames.EndOfFrame) => Buffer.Success Frames.Truncated
    Buffer.Success(Frames.Value(first)) => match perform Cursor.next () {
        Buffer.Failure(error) => Buffer.Failure error
        Buffer.Success(Frames.EndOfFrame) => Buffer.Success Frames.Truncated
        Buffer.Success(Frames.Value(second)) => finish (Frames.Pair(first, second))
    }
}

decode_tag : Int -> Buffer.Outcome<Frames.DecodeResult> ! {Cursor}
decode_tag tag = match tag == 0 {
    true => finish Frames.Ping
    false => match tag == 1 {
        true => decode_reading ()
        false => match tag == 2 {
            true => decode_pair ()
            false => Buffer.Success Frames.BadTag
        }
    }
}

pub decode : Unit -> Buffer.Outcome<Frames.DecodeResult> ! {Cursor}
decode () = match perform Cursor.next () {
    Buffer.Failure(error) => Buffer.Failure error
    Buffer.Success(Frames.EndOfFrame) => Buffer.Success Frames.Truncated
    Buffer.Success(Frames.Value(tag)) => decode_tag tag
}

read_next<R, C> : (
    (Buffer.Buffer<R>, Cell.Handle<C>, Int) ->
    Buffer.Outcome<Frames.Next> ! {Buffer.Ops<Buffer.Buffer<R>>, Cell.Ops<C>}
) where Buffer.Provider<Buffer.Buffer<R>>, Cell.Provider<C>
read_next (buffer, position, logical_length) = {
    let index = Cell.read position
    match index == logical_length {
        true => Buffer.Success Frames.EndOfFrame
        false => match Buffer.read (buffer, index) {
            Buffer.Failure(error) => Buffer.Failure error
            Buffer.Success(value) => {
                let ignored = Cell.write (position, index + 1)
                Buffer.Success (Frames.Value value)
            }
        }
    }
}

pub run_frame : (
    Int, Frames.ByteValues
) -> Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>
run_frame (capacity, byte_values) = {
    let logical_length = byte_count byte_values
    resource Buffer.Buffer<R> buffer = capacity {
        match write_all (buffer, byte_values, 0) {
            Buffer.Failure(error) => Buffer.Failure error
            Buffer.Success(()) => resource cell<C> position = 0 {
                handle (decode ()) with Cursor {
                    next () => resume (
                        read_next (buffer, position, logical_length)
                    )
                }
            }
        }
    }
}
