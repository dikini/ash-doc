# How can a calculation keep scoped mutable state?

The preceding list calculation carried its total through ordinary arguments.
Sometimes a calculation needs several helpers to read and update one shared
count. A scoped cell provides that access while one surrounding scope owns
the cell's release.

Before this chapter, work through
[choosing implementation evidence](../../libraries/choosing-implementation-evidence/README.md).
It distinguishes a method's interface requirement from the evidence needed to
call it. Cell acquisition supplies a particular sealed form of that evidence.

## Read a value, then change the cell

`01-read-and-write.ash` starts with one cell containing zero:

<!-- source: src/01-read-and-write.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> counter = 0 {
    let before = Cell.read counter
    let alias = counter
    let ignored = Cell.write (alias, before + 1)
    (before, Cell.read counter)
}
```

`@builtin.cell` is a compiler-owned module. The import gives its public names
the alias `Cell`; the alias itself is an ordinary name chosen by this program.

`resource cell<R> counter = 0 { ... }` acquires the cell and runs its body.
Within the body, `counter` is a handle of type `Cell.Handle<R>`. The scope
introduces `R` to distinguish this acquisition. Reading returns a copied
integer; writing changes the cell and returns `Unit`.

`before` retains the copied zero. `alias` is another way to access the same
cell, so writing through it changes what a later read through `counter` sees.
Run the file from this lesson's `src` directory:

```text
$ ash 01-read-and-write.ash
(0, 1) : (Int, Int)
```

The aliases do not own separate releases. The resource scope owns one release
when its body finishes. The returned pair contains ordinary integers and
needs no cell access after that scope has closed.

## Keep the pure count for comparison

`02-pure-count.ash` counts a finite list without mutable state:

<!-- source: src/02-pure-count.ash -->
```ash
type Scores = End
    | Item(Int, Scores)

count : (Scores, Int) -> Int
count (End, total) = total
count (Item(value, rest), total) = count (rest, total + 1)

main : Unit -> Int
main () = count (Item(20, Item(0, Item(99, End))), 0)
```

Every `Item` contributes one, including an item whose score is zero. The
accumulator is the number of items already visited. At `End`, it is the final
count:

```text
$ ash 02-pure-count.ash
3 : Int
```

This is still a suitable way to count a list. The cell version will let us
compare the same result with a different way of carrying the count.

## Pass access to a helper

`03-cell-count.ash` gives a traversal helper the cell handle:

<!-- source: src/03-cell-count.ash -->
```ash
import @builtin.cell as Cell

type Scores = End
    | Item(Int, Scores)

visit : (Scores, Cell.Handle<R>) -> Unit ! {Cell.Ops<R>} where Cell.Provider<R>
visit (End, counter) = ()
visit (Item(value, rest), counter) = {
    let before = Cell.read counter
    let ignored = Cell.write (counter, before + 1)
    visit (rest, counter)
}

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    let values = Item(20, Item(0, Item(99, End)))
    let ignored = visit (values, counter)
    Cell.read counter
}
```

`visit` returns `Unit`; its useful work is updating the cell. Before each
recursive call, it reads the current count and writes one more. At `End`, it
finishes without changing the count. The outer body then reads the result:

```text
$ ash 03-cell-count.ash
3 : Int
```

Read the helper's contract in two parts. `! {Cell.Ops<R>}` records the effects
of its reads and writes. `where Cell.Provider<R>` requires evidence permitting
those methods for this handle identity. The parameter `R` connects the handle,
its operations, and its provider requirement.

Acquisition supplies both that exact provider evidence and an interpreter for
`Cell.Ops<R>` inside the body. This is why the call to `visit` can satisfy its
requirement there, and why the enclosing `main` still has an empty row. Other
effects introduced by a body would remain outward until separately handled.

The [cell rules][cells] make this provider sealed. Importing names, selecting
ordinary public implementations, or writing a source `impl` cannot manufacture
cell authority. An ordinary helper can require and forward the authority
supplied by an enclosing acquisition.

## State the helper's evidence requirement

A caller's resource scope does not erase the contract required by a helper's
own definition. `04-missing-provider.ash` records the read effect but omits
its provider requirement:

<!-- source: src/04-missing-provider.ash -->
```ash
import @builtin.cell as Cell

read_count : Cell.Handle<R> -> Int ! {Cell.Ops<R>}
read_count counter = Cell.read counter

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    read_count counter
}
```
<!-- diagnostic: src/04-missing-provider.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-missing-provider.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/effects/counting-with-a-cell/src/04-missing-provider.ash:4:22
4 | read_count counter = Cell.read counter
  |                      ^ No available evidence satisfies this interface requirement.
  --> @builtin.cell:7:1
7 | read : Handle<R> -> Int ! {Ops<R>}
  | ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/effects/counting-with-a-cell/src/04-missing-provider.ash:1:1
1 | import @builtin.cell as Cell
  | ^ This import made the declaration available.
  --> @builtin.cell:6:1
6 | pub interface Provider<R> {
  | ^ This interface participates in the failing evidence selection.
7 | read : Handle<R> -> Int ! {Ops<R>}
  | ^ This interface participates in the failing evidence selection.
8 | write : (Handle<R>, Int) -> Unit ! {Ops<R>}
  | ^ This interface participates in the failing evidence selection.
9 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

The first label identifies the method call without evidence. The builtin
source labels show the required `Provider<R>` interface and its method;
`@builtin.cell` identifies that compiler-owned source rather than a missing
file in your checkout. The import label explains how the method became
available by name.

Add `where Cell.Provider<R>` to `read_count`'s signature, following `visit` in
`03-cell-count.ash`. The helper then declares the requirement that the resource
body can supply at its call. An effect row and an interface requirement answer
different questions: what operation may be requested, and what evidence the
method needs.

## Practice: track the count and its access

1. Add another item to the list in both counting examples. Predict their
   results and explain their different representations of intermediate state.
2. In `01-read-and-write.ash`, write a different integer through `alias`.
   Explain why `before` and the later read can differ.
3. Change `visit` to count only nonzero scores. Keep the cell's updates inside
   the branch that counts an item, then compare with a pure version.

A cell handle provides reusable access during one owned scope. The scope
supplies the provider and operation interpreter and owns release; copies of a
read integer are ordinary values. Next we will examine which values can leave
that scope and which ones still retain access to the cell.

[cells]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#scoped-cells-and-resource-dependencies
