# How can acquiring a resource fail?

A cell scope begins with an integer value. A native buffer must first acquire
space for a requested number of bytes. That acquisition can fail before its
body starts. Successful acquisition followed by normal body completion wraps
the body's value in `Success`, even when that value is itself a `Failure`.

The buffer API also returns ordinary outcomes for checked reads and writes.
We will keep those outcomes separate: acquiring a buffer successfully does
not guarantee that every operation on it succeeds.

The buffer library calls the native allocator. Its programs need a generated
executable, built on Linux x86-64 GNU with the selected Rust toolchain and a
native linker. Keep `ASH_LIBRARIES` from the [shared setup][setup] in this
terminal; it points at the selected Ash checkout's `libraries` directory.
`ASH_NATIVE_CACHE` lets these builds reuse their compiled dependencies.
The `ffi` root connects imports to that directory. Building reports the
executable's absolute path; running it prints the value without a type suffix.
The `main` signature still states the result type checked during compilation.

## Read an initially zero byte

`01-zeroed-bytes.ash` acquires four bytes and reads index zero:

<!-- source: src/01-zeroed-bytes.ash -->
```ash
import @ffi.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource Buffer.Buffer<R> bytes = 4 {
    Buffer.read (bytes, 0)
}
```

`@ffi.native_buffer` imports the source buffer library through the `ffi` root.
`Buffer.Buffer<R>` names its declared resource family. Like a cell, an acquired
buffer has a handle, an exact provider relation, an operation interpreter, and
one scope owning release. Its bytes start at zero.

`Buffer.Outcome<A>` has ordinary constructors `Success(A)` and
`Failure(Error)`. Its errors include `InvalidLength`, `AllocationFailed`,
`InvalidIndex`, and `InvalidByte`. A read at a valid index returns
`Success` containing the byte. Identify the two expressions producing outcome
layers here: the read and the surrounding acquisition. Predict both before
running from this lesson's `src` directory:

```text
$ ash build --output ./buffer-example \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 01-zeroed-bytes.ash
/path/to/ash-doc/content/effects/acquiring-a-buffer/src/buffer-example
$ ./buffer-example
Success(Success(0))
```

The inner `Success(0)` is the read outcome. The outer `Success` says acquisition
succeeded and the body returned that value normally. The buffer is released
before that outer successful result is returned.

Code must match the outcomes it needs; these constructors do not throw
exceptions or automatically stop surrounding work.

## Check the write before using its result

`02-write-and-read.ash` writes one byte, then reads the same position:

<!-- source: src/02-write-and-read.ash -->
```ash
import @ffi.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource Buffer.Buffer<R> bytes = 4 {
    match Buffer.write (bytes, 1, 42) {
        Buffer.Success(()) => Buffer.read (bytes, 1)
        Buffer.Failure(error) => Buffer.Failure error
    }
}
```

For four bytes, valid indices are zero through three; valid byte values are
zero through 255. A successful write returns `Buffer.Success(())`, and its
match then reads index one. If the write failed, the other branch would return
that error instead. Predict which
branch this write selects, then the read's value and its acquisition wrapper:

```text
$ ash build --output ./buffer-example \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 02-write-and-read.ash
/path/to/ash-doc/content/effects/acquiring-a-buffer/src/buffer-example
$ ./buffer-example
Success(Success(42))
```

The body chooses an ordinary outcome, and acquisition wraps that body result.
These wrappers answer different questions and are not flattened.

## Acquisition failure skips the body

A length must be positive and within the provider's addressable bound.
`03-acquisition-failure.ash` requests zero bytes and uses a cell to record
whether the body runs:

<!-- source: src/03-acquisition-failure.ash -->
```ash
import @ffi.native_buffer as Buffer

import @builtin.cell as Cell

main : Unit -> (Buffer.Outcome<Int>, Int)
main () = resource cell<C> entered = 0 {
    let result = resource Buffer.Buffer<R> bytes = 0 {
        let ignored = Cell.write (entered, 1)
        42
    }
    (result, Cell.read entered)
}
```

Use the positive-length requirement to decide whether the body is entered.
Predict the acquisition outcome and the cell's final value separately:

```text
$ ash build --output ./buffer-example \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 03-acquisition-failure.ash
/path/to/ash-doc/content/effects/acquiring-a-buffer/src/buffer-example
$ ./buffer-example
(Failure(InvalidLength), 0)
```

Zero is invalid, so no buffer is acquired and the body never writes to
`entered`. The result is `Failure(InvalidLength)` and the cell remains
`0`. This failure comes from acquisition, before any body value exists.

A valid length can also fail because allocation is unavailable. The program
must be able to handle `AllocationFailed`; this example uses invalid length
because it gives a deterministic observation. A provider requirement grants
access inside a successful acquisition, not a promise that allocation always
succeeds.

## Check indices and byte values

For a length of two, the valid indices are zero and one.
`04-invalid-index.ash` attempts to read index two:

<!-- source: src/04-invalid-index.ash -->
```ash
import @ffi.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource Buffer.Buffer<R> bytes = 2 {
    Buffer.read (bytes, 2)
}
```

The length is valid, but is the read index within its bounds? Predict the
read's outcome and whether the enclosing acquisition still returns `Success`:

```text
$ ash build --output ./buffer-example \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 04-invalid-index.ash
/path/to/ash-doc/content/effects/acquiring-a-buffer/src/buffer-example
$ ./buffer-example
Success(Failure(InvalidIndex))
```

Acquisition succeeded and the body returned normally, but its value was the
read's `Failure(InvalidIndex)`. This is an ordinary returned value: the tool
prints it and exits with status `0`.
Changing the index to one gives a valid read of the initially zero byte.

A byte value must be between zero and 255. `05-invalid-byte.ash` records both
the write outcome and a later read in ordinary data:

<!-- source: src/05-invalid-byte.ash -->
```ash
import @ffi.native_buffer as Buffer

type Checked = Checked(Buffer.Outcome<Unit>, Buffer.Outcome<Int>)

main : Unit -> Buffer.Outcome<Checked>
main () = resource Buffer.Buffer<R> bytes = 2 {
    let written = Buffer.write (bytes, 0, 256)
    Checked(written, Buffer.read (bytes, 0))
}
```

Predict both fields of `Checked`. If the write is outside the byte range,
what will a later read find at the unchanged position?

```text
$ ash build --output ./buffer-example \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 05-invalid-byte.ash
/path/to/ash-doc/content/effects/acquiring-a-buffer/src/buffer-example
$ ./buffer-example
Success(Checked(Failure(InvalidByte), Success(0)))
```

`Checked` is our data constructor for the two observations. The invalid write
leaves the byte unchanged, so the later read still returns zero. Use a value
within the byte range to make the write succeed. Numeric bounds are checked
when operations run; the `Int` type does not prove them in advance.

## Keep nested acquisition outcomes distinct

`06-nested-acquisition.ash` acquires an outer buffer successfully, then tries
to acquire an invalid inner one:

<!-- source: src/06-nested-acquisition.ash -->
```ash
import @ffi.native_buffer as Buffer

main : Unit -> Buffer.Outcome<Buffer.Outcome<Int>>
main () = resource Buffer.Buffer<R> outer = 1 {
    resource Buffer.Buffer<S> inner = 0 {
        Buffer.length outer
    }
}
```

Trace entry into each body. Which acquisition can return a value without
running its body, and what will the outer body return and wrap?

```text
$ ash build --output ./buffer-example \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" 06-nested-acquisition.ash
/path/to/ash-doc/content/effects/acquiring-a-buffer/src/buffer-example
$ ./buffer-example
Success(Failure(InvalidLength))
```

The inner body does not run. The outer body returns the inner failure as an
ordinary value, then the outer scope releases its buffer and wraps that value
in `Success`. Its shape resembles a failed read in an acquired buffer, but
its cause is the inner acquisition. Follow the expression producing each
outcome rather than guessing from the constructor alone.

These examples separate the producer of each outcome layer:

| Example | Acquisition result | Body's returned value |
| --- | --- | --- |
| Zero length (`03`) | Invalid length | Body never entered |
| Invalid index (`04`) | `Success(...)` | Read's `Failure(InvalidIndex)` |
| Invalid byte (`05`) | `Success(...)` | `Checked` with both access outcomes |
| Nested acquisition (`06`) | `Success(...)` | Inner `Failure(InvalidLength)` |

All six generated programs so far return ordinary values with exit status `0`,
including those containing `Failure`. The [buffer evaluation rules][execution]
keep acquisition, access outcomes, and normal release distinct.

## A success wrapper cannot export access

The lifetime rules from cells still apply. `07-handle-escape.ash` tries to
return a buffer handle from its owner:

<!-- source: src/07-handle-escape.ash -->
```ash
import @ffi.native_buffer as Buffer

main : Unit -> Int
main () = {
    let leaked = resource Buffer.Buffer<R> bytes = 2 {
        bytes
    }
    0
}
```

What would the success wrapper retain if its body returned `bytes`? Apply
E8's dependency rule before reading this source rejection:

<!-- diagnostic: src/07-handle-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en --root ffi="$ASH_LIBRARIES" 07-handle-escape.ash
This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/acquiring-a-buffer/src/07-handle-escape.ash:5:54
5 |     let leaked = resource Buffer.Buffer<R> bytes = 2 {
  |                                                      ^ This value or computation depends on a resource that would be out of scope.
6 |         bytes
  | ^ This value or computation depends on a resource that would be out of scope.
7 |     }
  | ^ This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/acquiring-a-buffer/src/07-handle-escape.ash:5:18
5 |     let leaked = resource Buffer.Buffer<R> bytes = 2 {
  |                  ^ This resource is acquired here and must remain within its scope.
6 |         bytes
  | ^ This resource is acquired here and must remain within its scope.
7 |     }
  | ^ This resource is acquired here and must remain within its scope.
reason: type.resource-escape
```
<!-- markdownlint-enable MD013 -->

The returned handle would depend on the closed acquisition, even inside its
success wrapper. The primary label covers the body returning that handle;
the related label begins at the acquisition that owns it. Return
copied data, such as a read outcome, while keeping all handle access inside
the resource body.

The [buffer rules][buffers] define these outcomes, dependencies, and release
boundaries. The client acquires scoped access and returns ordinary data; the library
owns native allocation and release. No client pointer or manual release is
needed for this calculation.

## Practice: identify which operation failed

For each task, make a fresh copy of its named program in a scratch directory
outside this lesson's `src` tree. Predict the outcome, then build and run the
copy from its directory with the same `ffi` root.

1. Give `03-acquisition-failure.ash` a valid small length. Predict the outcome
   and the `entered` count before running.
2. Change the index in `04-invalid-index.ash` to the last valid position.
3. Use `255` in `05-invalid-byte.ash`. Predict both stored outcomes.
4. Give the inner acquisition in `06-nested-acquisition.ash` a valid length.
   Explain which buffer its body measures and predict the nested result.

Acquisition outcomes describe entry into a resource body. Read and write
outcomes describe operations within it. Both remain ordinary typed values,
while access belongs to a live owner. The final lesson will put requests,
state, early stopping, and cleanup together in one finite-list calculation.

[buffers]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-native-buffers
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-native-buffer-execution

[setup]: ../../../README.md#prepare-ash
