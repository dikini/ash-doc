import @ffi.native_buffer as Buffer
import frames as Frames
import codec as Codec

main : Unit -> Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>
main () = Codec.run_frame (
    3, Frames.Byte(2, Frames.Byte(0, Frames.Byte(255, Frames.End)))
)
