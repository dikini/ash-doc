import @ffi.native_buffer as Buffer
import frames as Frames
import codec as Codec

type FrameInputs = NoFrames
    | Frame(Int, Frames.ByteValues, FrameInputs)
type Checks = Done
    | Checked(Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>, Checks)

check_frames : FrameInputs -> Checks
check_frames NoFrames = Done
check_frames (Frame(capacity, byte_values, rest)) = Checked (
    Codec.run_frame (capacity, byte_values), check_frames rest
)

main : Unit -> Checks
main () = {
    let inputs = Frame (1, Frames.Byte(9, Frames.End),
        Frame (1, Frames.Byte(1, Frames.End),
            Frame (2, Frames.Byte(2, Frames.Byte(7, Frames.End)),
                Frame (2, Frames.Byte(0, Frames.Byte(9, Frames.End)),
                    Frame (1, Frames.End,
                        Frame (2, Frames.Byte(1, Frames.End),
                            Frame (3, Frames.Byte(0, Frames.End), NoFrames)))))))
    check_frames inputs
}
