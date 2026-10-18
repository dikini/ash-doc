# Round-trip a tagged frame

An encoder and a decoder can agree with each other while both use the wrong
format. A second boundary can hide the mistake: a buffer may have room for
more bytes than the input actually contains. A decoder that treats unwritten,
zeroed storage as input could invent a missing field or report trailing data
that was never supplied.

Continue from [bounded messages](../reading-a-bounded-message/README.md),
[buffer acquisition](../../effects/acquiring-a-buffer/README.md), and
[scoped access](../../effects/keeping-access-in-scope/README.md). Here we will
check one small format independently in both directions, keep logical input
length separate from capacity, and return only ordinary decoded data after
buffer access ends.

## Derive the format from its messages

A `Ping` has no fields. A `Reading` has one integer field, and a `Pair` has two
ordered integer fields. Give each constructor a tag, then write its fields in
order. The whole input must contain exactly one frame:

| Message | Wire integers |
| --- | --- |
| `Ping` | `[0]` |
| `Reading(n)` | `[1,n]` |
| `Pair(x,y)` | `[2,x,y]` |

Square brackets in this chapter are non-executable list notation. The Ash
programs represent these sequences as `Byte(value, rest)` ending in `End`.
The name `ByteValues` denotes this ordinary list of integers. It is not the
primitive immutable byte type, and its element type does not establish a byte
range. Admitted payload fields must be in `0..255`; checked native writes
will enforce that condition.

Keep the ordinary data in `frames.ash`:

<!-- source: src/frames.ash -->
<!-- markdownlint-disable MD013 -->
```ash
pub type Message = Ping
    | Reading(Int)
    | Pair(Int, Int)
pub type ByteValues = End
    | Byte(Int, ByteValues)
pub type Next = EndOfFrame
    | Value(Int)
pub type DecodeResult = Decoded(Message)
    | BadTag
    | Truncated
    | TrailingData
```
<!-- markdownlint-enable MD013 -->

`Next` distinguishes a supplied integer from logical end of frame. End is not
a special byte value: zero is meaningful as both a tag and a payload. The
decoder returns `Decoded(message)` only after reading all expected fields and
confirming that no supplied byte remains. An unknown tag gives `BadTag`, a
missing tag or field gives `Truncated`, and extra input after a complete
message gives `TrailingData`.

These are application results. Buffer acquisition and operations have their
own outcome family, declared by the source buffer library. Derive the public
operation as non-executable contract notation:

```text
run_frame : (capacity, supplied_integers)
         -> Buffer.Outcome<Buffer.Outcome<DecodeResult>>
```

The outer outcome answers whether acquisition succeeded and its body returned
normally. The inner outcome is the body's checked-operation result. For
example, `Success(Success(Truncated))` means the buffer and operations succeeded
but the supplied frame was incomplete. `Success(Failure(InvalidIndex))`
means acquisition succeeded but an operation failed. Keep both layers even
though they use the same constructors.

## Write supplied values, then read only supplied input

`encode` follows the constructor cases directly. The tag distinguishes the
case; the fields follow it in their declared order. `write_all` traverses the
resulting integer list, matching each checked write before proceeding to the
next index. A failed write stops that path before decoding begins.

For decoding, count the supplied list itself. After successful writes, start a
cursor at position zero inside the live buffer owner. `read_next` returns
`EndOfFrame` when position equals that count. Otherwise it performs a checked
read and advances only after success. The cursor invariant is that position
counts the supplied values already returned, from zero through logical length.
Capacity governs access bounds; it does not tell the decoder how much input
was supplied.

Separate choosing a tag case from obtaining its bytes. `decode` requests the
first value; `decode_tag` chooses `Ping`, `Reading`, or `Pair`. The two payload
helpers request their fields in order. `finish` then requests one more value
to distinguish logical end from trailing input.

This direct decoder consumes cursor results and returns a `Message`. Another
design could first materialize a token representation, then interpret it. That
extra representation and pass could help if a later operation needed to inspect
or transform tokens independently. For this finite format it would add work
and make the supplied-length boundary harder to see. Revisit that choice when
a concrete consumer needs the intermediate form.

`codec.ash` connects those operations:

<!-- source: src/codec.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

The type parameters `R` and `C` identify the buffer and position cell. The
helpers' provider requirements carry access already established by those
owners; they do not acquire another buffer. `run_frame` has one buffer scope,
with the cursor scope inside it. The handler resumes each `Cursor.next` with
an ordinary outcome from `read_next`. Neither an access handle nor an
access-retaining function leaves those scopes.

The [buffer rules][buffers] define the resource family, exact provider,
operation outcomes, and acquisition wrapper. The [execution rules][execution]
define initially zeroed storage and checked reads and writes. Our logical-end
rule is an additional application invariant. In particular, `run_frame` never
uses buffer capacity as a frame length or accepts a caller-supplied length.

For any admitted message, the encoder's tag selects the corresponding decoder
case. `Reading` consumes its one field; `Pair` consumes first and then second.
With successful acquisition, enough capacity, successful checked operations,
and no added input, the final cursor request reaches logical end. The returned
ordinary constructor therefore has the original fields in their original
positions. Those premises matter: `Message` permits arbitrary integers, while
a native byte write permits only `0..255`.

Counting and writing `b` supplied values take linear source work in `b`.
This decoder examines at most the three bytes of a valid frame and one extra
byte when checking for trailing data. Its message representation has fixed
size. Native allocation has its separate zero-initialization cost for the
chosen capacity; a short logical frame does not make a larger allocation
free. These source bounds are not elapsed-time measurements.

## Check both directions before relying on a round trip

Use distinct pair fields so a reversal cannot pass unnoticed. The five
hand-calculated goldens are `Ping`, `Reading(0)`, `Reading(255)`, `Pair(0,255)`,
and `Pair(255,0)`. In `01-round-trips.ash`, the first result group encodes those
messages. The second decodes independent literal golden lists. Only the third
feeds the encoder's results into the decoder.

<!-- source: src/01-round-trips.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Enter `round-tripping-tagged-frames/src` from the Cases directory. These
buffer programs use generated native executables, as in the buffer lesson.
With the shared `ASH_LIBRARIES` and native cache setup, build and run the first
entry:

```sh
ash build --output ./frames \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 01-round-trips.ash
./frames
```

Building reports the executable path. Running prints one value without a
`: Type` suffix; the source signature supplies the checked result type.
The entry groups encoded lists in a tuple and each sequence of decoder
results in `Checked(outcome, rest)` ending with `Done`. Its private
`check_frames` visits each explicit fixture once. The following table
summarizes all three groups from the one captured value. The decoder columns
preserve both outcome layers; the surrounding fixture grouping is omitted:

<!-- golden-observations: src/01-round-trips.ash -->
<!-- markdownlint-disable MD013 -->
| Message | Encoded integers | Decode literal golden | Decode encoded result |
| --- | --- | --- | --- |
| `Ping` | `[0]` | `Success(Success(Decoded(Ping)))` | `Success(Success(Decoded(Ping)))` |
| `Reading(0)` | `[1,0]` | `Success(Success(Decoded(Reading(0))))` | `Success(Success(Decoded(Reading(0))))` |
| `Reading(255)` | `[1,255]` | `Success(Success(Decoded(Reading(255))))` | `Success(Success(Decoded(Reading(255))))` |
| `Pair(0,255)` | `[2,0,255]` | `Success(Success(Decoded(Pair(0, 255))))` | `Success(Success(Decoded(Pair(0, 255))))` |
| `Pair(255,0)` | `[2,255,0]` | `Success(Success(Decoded(Pair(255, 0))))` | `Success(Success(Decoded(Pair(255, 0))))` |
<!-- markdownlint-enable MD013 -->

Each direction agrees with the format independently. Round-trip agreement then
checks their connection. These five observations do not prove the general
argument, but they exercise every constructor, both payload boundaries, and
the order of distinct pair fields.

## Find logical end before looking at spare storage

Use the same build/run pair with `02-malformed.ash`. Predict which inputs
supply a complete frame, which omit required input, and which supply too much:

<!-- source: src/02-malformed.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

The generated program returns seven nested outcomes in source order, grouped
by `Checked` and `Done`. This table selects each whole outcome from that one
result:

<!-- malformed-observations: src/02-malformed.ash -->
| Capacity | Supplied integers | Observed outcome |
| --- | --- | --- |
| `1` | `[9]` | `Success(Success(BadTag))` |
| `1` | `[1]` | `Success(Success(Truncated))` |
| `2` | `[2,7]` | `Success(Success(Truncated))` |
| `2` | `[0,9]` | `Success(Success(TrailingData))` |
| `1` | `[]` | `Success(Success(Truncated))` |
| `2` | `[1]` | `Success(Success(Truncated))` |
| `3` | `[0]` | `Success(Success(Decoded(Ping)))` |

Tag `9` names no case. Tag `1` needs one field, and tag `2` needs two, so the
next two inputs are truncated. `Ping` needs no payload, making the supplied
`9` in `[0,9]` trailing data.

The final three cases distinguish input from storage. Empty input reaches
logical end immediately, even though capacity is one. A lone Reading tag is
still truncated at capacity two: the unwritten zero at index one is not its
payload. Conversely, `[0]` is a valid Ping at capacity three: spare zeroed
storage is not trailing input. Both outcomes follow from list-derived logical
length, without reading those unused bytes.

## Keep acquisition, access, and format failures separate

A capacity can also be too small to store all supplied integers. That failure
occurs during writing, before the decoder establishes its logical-end result.
`03-buffer-failures.ash` compares that operation failure with invalid
acquisition and invalid byte values:

<!-- source: src/03-buffer-failures.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Build this entry with the same native command and run `./frames`. Predict
which wrapper each failure belongs to. The five fields of its one captured
result are:

<!-- buffer-observations: src/03-buffer-failures.ash -->
<!-- markdownlint-disable MD013 -->
| Observation | Captured value |
| --- | --- |
| Capacity one, two supplied values | `Success(Failure(InvalidIndex))` |
| Public `run_frame` at capacity zero | `Failure(InvalidLength)` |
| Independent zero-capacity body-entry check | `(Failure(InvalidLength), 0)` |
| Write `256` at valid index zero | `Success(Failure(InvalidByte))` |
| Write `42`, reject `256`, then read | `Success(Success(WriteControl(Failure(InvalidByte), Success(42))))` |
<!-- markdownlint-enable MD013 -->

The first result is not logical truncation. Its second write has no valid
index, so `write_all` returns that operation failure. The decoder never runs.
At zero capacity, acquisition instead refuses entry. The independent cell
sentinel remains zero because its write is inside the skipped buffer body.
The public operation and the sentinel control both retain the outer failure.

For a valid index, writing `256` fails byte conversion. The independent control
first checks a successful write of `42`, then records the rejected write and
reads the same index. The byte remains `42`; no native read produces `256`.
The [buffer execution rules][execution] specify that refusal leaves storage
unchanged. In the control, the inner success contains a record of both access
outcomes; its embedded failure is ordinary data rather than an exception.

All of these generated programs return ordinary values with exit status zero.
The two-success format errors, inner operation failures, and outer acquisition
failures answer different questions. The library can also report allocation
failure; no observation here attempts to force it.

## A well-typed encoder can still reverse the fields

`04-swapped-pair.ash` deliberately puts the second pair field before the first.
The integer list still fits the data types and all writes fit the byte range:

<!-- source: src/04-swapped-pair.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Build and run this entry after predicting its byte order and decoded fields:

<!-- observation: src/04-swapped-pair.ash -->
<!-- markdownlint-disable MD013 -->
```text
(Byte(2, Byte(255, Byte(0, End))), Success(Success(Decoded(Pair(255, 0)))))
```
<!-- markdownlint-enable MD013 -->

The first field is `[2,255,0]`, which disagrees with the golden for
`Pair(0,255)`. The correct decoder reads those supplied bytes as
`Pair(255,0)`. This accepted program violates field-order agreement, despite
using valid byte values and scoped access. Testing only a round trip with a
similarly reversed decoder could hide that mistake.

## Keep the cursor's access inside its owner

Successful access does not give a function permission to outlive a buffer.
`05-escaping-cursor.ash` tries to return a cursor closure that retains both
the buffer and its position cell:

<!-- source: src/05-escaping-cursor.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

The position cell surrounds the buffer, but the buffer would close before the
returned function could be used. Predict that lifetime boundary, then run this
source check from the same `src` directory:

<!-- diagnostic: src/05-escaping-cursor.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en --root ffi="$ASH_LIBRARIES" 05-escaping-cursor.ash
This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/cases/round-tripping-tagged-frames/src/05-escaping-cursor.ash:6:56
6 |     let escaped = resource Buffer.Buffer<R> buffer = 1 {
  |                                                        ^ This value or computation depends on a resource that would be out of scope.
7 |         let next : (
  | ^ This value or computation depends on a resource that would be out of scope.
8 |             Unit -> Buffer.Outcome<Int> ! {Cell.Ops<C>, Buffer.Ops<Buffer.Buffer<R>>}
  | ^ This value or computation depends on a resource that would be out of scope.
9 |         ) = fn(ignored) {
  | ^ This value or computation depends on a resource that would be out of scope.
10 |             Buffer.read (buffer, Cell.read position)
   | ^ This value or computation depends on a resource that would be out of scope.
11 |         }
   | ^ This value or computation depends on a resource that would be out of scope.
12 |         next
   | ^ This value or computation depends on a resource that would be out of scope.
13 |     }
   | ^ This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/cases/round-tripping-tagged-frames/src/05-escaping-cursor.ash:6:19
6 |     let escaped = resource Buffer.Buffer<R> buffer = 1 {
  |                   ^ This resource is acquired here and must remain within its scope.
7 |         let next : (
  | ^ This resource is acquired here and must remain within its scope.
8 |             Unit -> Buffer.Outcome<Int> ! {Cell.Ops<C>, Buffer.Ops<Buffer.Buffer<R>>}
  | ^ This resource is acquired here and must remain within its scope.
9 |         ) = fn(ignored) {
  | ^ This resource is acquired here and must remain within its scope.
10 |             Buffer.read (buffer, Cell.read position)
   | ^ This resource is acquired here and must remain within its scope.
11 |         }
   | ^ This resource is acquired here and must remain within its scope.
12 |         next
   | ^ This resource is acquired here and must remain within its scope.
13 |     }
   | ^ This resource is acquired here and must remain within its scope.
reason: type.resource-escape
```
<!-- markdownlint-enable MD013 -->

The primary label covers the buffer body that returns `next`. The related
label begins at the buffer acquisition owning that access. Inside the function,
`Buffer.read` still needs `buffer`; capturing the enclosing position cell does
not preserve the buffer's lifetime. Even leaving `escaped` unused cannot make
that returned dependency valid. The secondary reason is
`type.resource-escape`.

The [dependency rules][resources] follow retained access through closures and
outcome wrappers. A result type without an explicit handle field is not enough
to erase that dependency. Keep the reads and cursor updates inside their live
owners and return the copied integers in ordinary message data instead.
`06-decode-in-scope.ash` uses `run_frame`, whose decoding happens before those
scopes close:

<!-- source: src/06-decode-in-scope.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @ffi.native_buffer as Buffer
import frames as Frames
import codec as Codec

main : Unit -> Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>
main () = Codec.run_frame (
    3, Frames.Byte(2, Frames.Byte(0, Frames.Byte(255, Frames.End)))
)
```
<!-- markdownlint-enable MD013 -->

Build and run the repaired entry:

<!-- observation: src/06-decode-in-scope.ash -->
<!-- markdownlint-disable MD013 -->
```text
Success(Success(Decoded(Pair(0, 255))))
```
<!-- markdownlint-enable MD013 -->

The returned `Pair(0,255)` retains only ordinary integer fields. The outer and
inner success wrappers remain visible after access ends. The complete human
message records this edition's tool presentation; its wording and printed
layout are not a language contract.

## Practice: separate agreement from access

Make scratch copies outside this lesson's `src` directory. Keep `frames.ash`
and `codec.ash` beside the entries that import them. Predict each result, then
build and run with the same native root and cache settings.

1. Change the Pair tag in the encoder only. Explain which independent golden
   check and which round-trip observation can distinguish the change.
2. Add another supplied integer after a valid Reading. Predict the decoder's
   result without changing capacity to represent logical length.
3. Give `[2,7]` capacity three instead of two. Trace the cursor's logical-end
   test before predicting whether the spare zero becomes a field.
4. Change the invalid write control from `256` to `255`. Predict both the write
   result and the later read while preserving all outcome layers.
5. In a scratch cursor closure, perform the read before returning the function
   and capture only the copied integer. Explain which owner is still needed.

Golden bytes establish the chosen format, logical length establishes which
input belongs to the frame, and scoped access establishes where buffer
operations may run. A round trip connects those boundaries only when its
payload and successful-operation premises hold. A larger format would next
need an explicit policy for framing several messages or reporting where a
failed parse stopped; those are additional questions to design separately.

[buffers]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-native-buffers
[resources]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-native-buffer-execution
