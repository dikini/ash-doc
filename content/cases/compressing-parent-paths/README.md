# Compress parent paths

Union–find represents a set by a root reached through parent links. This
example follows [native buffers](../../effects/acquiring-a-buffer/README.md)
and isolates its lookup step: four buffer entries describe the parent
chain `3 → 2 → 1 → 0`, with zero as its own parent. The buffer starts at zero;
the two checked writes establish the remaining links. Valid parent links and
an acyclic path to a self-parent are assumptions of this fixed input.

`find_root` requests parent access through `Parents`. With compression enabled,
it writes the discovered root into every non-root entry on the return path;
this rewrite toward the root is called *path compression*, and later lookups
from those entries start nearer the root. The handler interprets those
requests as checked scoped-buffer operations.
`Root` records the root, reads, and writes for one lookup. Two lookups without
compression should each read four entries and write none. With compression,
the first should read four and write three; the second should read two and
write one. Initialization is outside these counts, and the second run acquires
its own buffer.

These source-operation counts illustrate the tradeoff for this chain. They
make no timing or amortized-complexity claim. Every access failure propagates
as ordinary `Outcome` data. The outer `Outcome` reports acquisition; the inner
one reports initialization or lookup. Successful acquisition does not hide an
access failure.

<!-- source: src/main.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @ffi.native_buffer as Buffer

type Lookup = Root(Int, Int, Int)

effect Parents {
    read : Int -> Buffer.Outcome<Int>
    write : (Int, Int) -> Buffer.Outcome<Unit>
}

record_root : (Int, Bool, Lookup) -> Buffer.Outcome<Lookup> ! {Parents}
record_root (node, false, Root(root, reads, writes)) = Buffer.Success(Root(root, reads + 1, writes))
record_root (node, true, Root(root, reads, writes)) = {
    match perform Parents.write (node, root) {
        Buffer.Failure(error) => Buffer.Failure(error)
        Buffer.Success(()) => Buffer.Success(Root(root, reads + 1, writes + 1))
    }
}

find_root : (Int, Bool) -> Buffer.Outcome<Lookup> ! {Parents}
find_root (node, compress) = match perform Parents.read node {
    Buffer.Failure(error) => Buffer.Failure(error)
    Buffer.Success(parent) => match parent == node {
        true => Buffer.Success(Root(node, 1, 0))
        false => match find_root (parent, compress) {
            Buffer.Failure(error) => Buffer.Failure(error)
            Buffer.Success(result) => record_root (node, compress, result)
        }
    }
}

repeat_lookup : Bool -> Buffer.Outcome<(Lookup, Lookup)> ! {Parents}
repeat_lookup compress = match find_root (3, compress) {
    Buffer.Failure(error) => Buffer.Failure(error)
    Buffer.Success(first) => match find_root (3, compress) {
        Buffer.Failure(error) => Buffer.Failure(error)
        Buffer.Success(second) => Buffer.Success((first, second))
    }
}

run : Bool -> Buffer.Outcome<Buffer.Outcome<(Lookup, Lookup)>>
run compress = resource Buffer.Buffer<R> parents = 4 {
    match Buffer.write (parents, 2, 1) {
        Buffer.Failure(error) => Buffer.Failure(error)
        Buffer.Success(()) => match Buffer.write (parents, 3, 2) {
            Buffer.Failure(error) => Buffer.Failure(error)
            Buffer.Success(()) => handle (repeat_lookup compress) with Parents {
                read index => resume (Buffer.read (parents, index))
                write pair => {
                    let (index, parent) = pair
                    resume (Buffer.write (parents, index, parent))
                }
            }
        }
    }
}

main : Unit -> (Buffer.Outcome<Buffer.Outcome<(Lookup, Lookup)>>,
    Buffer.Outcome<Buffer.Outcome<(Lookup, Lookup)>>)
main () = (run false, run true)
```
<!-- markdownlint-enable MD013 -->

Build and run from the Cases directory, using the buffer lesson's native
[setup](../../effects/acquiring-a-buffer/README.md):

{{< pagebreak >}}

```text
ash build --output ./parent-paths \
    --cargo-target-dir "$ASH_NATIVE_CACHE" \
    --root ffi="$ASH_LIBRARIES" \
    compressing-parent-paths/src/main.ash
./parent-paths
```

The result is:

<!-- markdownlint-disable MD013 -->
```text
(Success(Success(Root(0, 4, 0), Root(0, 4, 0))), Success(Success(Root(0, 4, 3), Root(0, 2, 1))))
```
<!-- markdownlint-enable MD013 -->

The first lookup follows `3 → 2 → 1 → 0`. Compression then writes `0` into
entries `1`, `2`, and `3`, so the next lookup follows only `3 → 0`. It still
writes entry `3` on return, even though that parent is already `0`. Without
compression, both lookups follow the original four-entry chain.

Predict the counts if entry `3` initially points directly to `0`, then change
that one initialization write and run again. The next Case uses checked buffer
access to supply a decoder's byte requests.
