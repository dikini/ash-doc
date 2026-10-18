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

main : Unit -> (
    (Frames.ByteValues, Frames.ByteValues, Frames.ByteValues, Frames.ByteValues, Frames.ByteValues),
    Checks,
    Checks
)
main () = {
    let ping = Frames.Byte(0, Frames.End)
    let reading_zero = Frames.Byte(1, Frames.Byte(0, Frames.End))
    let reading_max = Frames.Byte(1, Frames.Byte(255, Frames.End))
    let pair_forward = Frames.Byte(2, Frames.Byte(0, Frames.Byte(255, Frames.End)))
    let pair_reverse = Frames.Byte(2, Frames.Byte(255, Frames.Byte(0, Frames.End)))
    let golden_frames = Frame (1, ping,
        Frame (2, reading_zero,
            Frame (2, reading_max,
                Frame (3, pair_forward, Frame (3, pair_reverse, NoFrames)))))
    let encoded_frames = Frame (1, Codec.encode Frames.Ping,
        Frame (2, Codec.encode (Frames.Reading 0),
            Frame (2, Codec.encode (Frames.Reading 255),
                Frame (3, Codec.encode (Frames.Pair(0, 255)),
                    Frame (3, Codec.encode (Frames.Pair(255, 0)), NoFrames)))))
    (
        (
            Codec.encode Frames.Ping,
            Codec.encode (Frames.Reading 0),
            Codec.encode (Frames.Reading 255),
            Codec.encode (Frames.Pair(0, 255)),
            Codec.encode (Frames.Pair(255, 0))
        ),
        check_frames golden_frames,
        check_frames encoded_frames
    )
}
