import @ffi.native_buffer as Buffer
import frames as Frames
import codec as Codec

swapped_pair : (Int, Int) -> Frames.ByteValues
swapped_pair (first, second) = Frames.Byte (
    2, Frames.Byte(second, Frames.Byte(first, Frames.End))
)

main : Unit -> (
    Frames.ByteValues, Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>
)
main () = {
    let wrong_bytes = swapped_pair (0, 255)
    (wrong_bytes, Codec.run_frame (3, wrong_bytes))
}
