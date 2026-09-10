# Why can a result leave a resource scope while access cannot?

A resource scope owns release, but its result can outlive that scope. The
question is what the result retains. An integer read from a cell is a copy.
A handle, or a function that retains the handle, still depends on access to
the cell.

We will compare those results, then follow the same distinction through a
tuple and an effect request. A type annotation alone does not describe every
resource dependency stored in a value.

## Return a calculation over a copied integer

`01-copied-result.ash` reads a cell before returning a function:

<!-- source: src/01-copied-result.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let later = resource cell<R> counter = 41 {
        let copied = Cell.read counter
        let calculate : Unit -> Int = fn(ignored) {
            copied + 1
        }
        calculate
    }
    later ()
}
```

The returned function captures `copied`, an ordinary integer. Its later call
adds one without accessing the cell. The cell can be released when its scope
finishes, before `later ()` runs. From this lesson's `src` directory:

```text
$ ash 01-copied-result.ash
42 : Int
```

This is the same distinction between captured values and later effects used
in E4. Here it also explains why returning the closure is safe.

## Reuse captured access while the owner remains live

Capturing a handle is useful inside its live scope. `02-live-access.ash`
returns the final count rather than the function that updates it:

<!-- source: src/02-live-access.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    let bump : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (counter, (Cell.read counter) + 1)
    }
    let alias = bump
    let ignored = bump ()
    let ignored = alias ()
    Cell.read counter
}
```

Both names refer to a function retaining access to the same counter. Each call
reads and increments it. The owner surrounds both calls and the final read:

```text
$ ash 02-live-access.ash
2 : Int
```

Reusable access is allowed. What matters is keeping it within its owner, not
limiting a handle to one use or prohibiting closures from capturing it.

## A returned handle would outlive its owner

`03-handle-escape.ash` attempts to keep the handle after the resource body ends:

<!-- source: src/03-handle-escape.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let leaked = resource cell<R> counter = 0 {
        counter
    }
    0
}
```
<!-- diagnostic: src/03-handle-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 03-handle-escape.ash
This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/03-handle-escape.ash:6:9
6 |         counter
  |         ^ This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/03-handle-escape.ash:5:18
5 |     let leaked = resource cell<R> counter = 0 {
  |                  ^ This resource is acquired here and must remain within its scope.
6 |         counter
  | ^ This resource is acquired here and must remain within its scope.
7 |     }
  | ^ This resource is acquired here and must remain within its scope.
reason: type.resource-escape
```
<!-- markdownlint-enable MD013 -->

The first label identifies the escaping value and the related label identifies
its acquisition. The unused name `leaked` does not make that escape valid.
Return `Cell.read counter` instead when the outside code needs only the count.

Wrapping the handle in a function does not solve the problem.
`04-closure-escape.ash` returns a function that would read the closing cell:

<!-- source: src/04-closure-escape.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let leaked = resource cell<R> counter = 0 {
        let later : Unit -> Int ! {Cell.Ops<R>} = fn(ignored) {
            Cell.read counter
        }
        later
    }
    0
}
```
<!-- diagnostic: src/04-closure-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-closure-escape.ash
This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/04-closure-escape.ash:9:9
9 |         later
  |         ^ This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/04-closure-escape.ash:5:18
5 |     let leaked = resource cell<R> counter = 0 {
  |                  ^ This resource is acquired here and must remain within its scope.
6 |         let later : Unit -> Int ! {Cell.Ops<R>} = fn(ignored) {
  | ^ This resource is acquired here and must remain within its scope.
7 |             Cell.read counter
  | ^ This resource is acquired here and must remain within its scope.
8 |         }
  | ^ This resource is acquired here and must remain within its scope.
9 |         later
  | ^ This resource is acquired here and must remain within its scope.
10 |     }
   | ^ This resource is acquired here and must remain within its scope.
reason: type.resource-escape
```
<!-- markdownlint-enable MD013 -->

The error is at the returned `later` value. Compare the correction in
`01-copied-result.ash`: read inside the scope, then capture only the copied
integer. Alternatively, call the access-retaining function while the owner
still surrounds it, as in `02-live-access.ash`.

## Distinguish two acquisitions

A nested resource scope owns a separate cell. In `05-two-acquisitions.ash`, a
tuple carries handles to both cells while both owners are live:

<!-- source: src/05-two-acquisitions.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> outer = 1 {
    let copied = resource cell<S> inner = 2 {
        let handles = (outer, inner)
        let (first, second) = handles
        let ignored = Cell.write (first, 10)
        Cell.read second
    }
    (Cell.read outer, copied)
}
```

`R` and `S` identify different acquisitions. Writing through the first tuple
field changes `outer`; it does not change `inner`. The inner scope returns a
copied read, so closing it leaves the outer cell available:

```text
$ ash 05-two-acquisitions.ash
(10, 2) : (Int, Int)
```

Tuples can transport access within a live owner. They cannot hide an escape.
`07-aggregate-escape.ash` attempts to return one handle beside an integer:

<!-- source: src/07-aggregate-escape.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> Int
main () = {
    let leaked = resource cell<R> counter = 0 {
        (7, counter)
    }
    0
}
```
<!-- diagnostic: src/07-aggregate-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 07-aggregate-escape.ash
This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/07-aggregate-escape.ash:6:9
6 |         (7, counter)
  |         ^ This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/07-aggregate-escape.ash:5:18
5 |     let leaked = resource cell<R> counter = 0 {
  |                  ^ This resource is acquired here and must remain within its scope.
6 |         (7, counter)
  | ^ This resource is acquired here and must remain within its scope.
7 |     }
  | ^ This resource is acquired here and must remain within its scope.
reason: type.resource-escape
```
<!-- markdownlint-enable MD013 -->

The tuple retains its second field's dependency. Replace that field with a
read of the count when the result needs only data. The same reasoning applies
to a data constructor that stores a handle.

## A request can carry a dependency across a scope

Returning from the resource body is not the only way to send a value outside
its owner. `06-payload-escape.ash` sends a closure to an outer effect handler:

<!-- source: src/06-payload-escape.ash -->
```ash
import @builtin.cell as Cell

effect Send<A> {
    value : A -> Unit
}

main : Unit -> Int
main () = handle (resource cell<R> counter = 41 {
    let later : Unit -> Int = fn(ignored) {
        let saved = counter
        42
    }
    let ignored = perform Send<Unit -> Int>.value later
    0
}) with Send<Unit -> Int> {
    value later => {
        let reported = later ()
        let result = resume ()
        result + reported
    }
}
```

The closure has the apparently resource-free type `Unit -> Int`, but its body
captures `counter` and binds that handle to `saved`. Returning a constant does
not remove the stored dependency. The request would deliver that closure to
a handler outside the acquisition:

<!-- diagnostic: src/06-payload-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-payload-escape.ash
This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/06-payload-escape.ash:13:19
13 |     let ignored = perform Send<Unit -> Int>.value later
   |                   ^ This value or computation depends on a resource that would be out of scope.
  --> /path/to/ash-doc/content/effects/keeping-access-in-scope/src/06-payload-escape.ash:8:18
8 | main () = handle (resource cell<R> counter = 41 {
  |                  ^ This resource is acquired here and must remain within its scope.
9 |     let later : Unit -> Int = fn(ignored) {
  | ^ This resource is acquired here and must remain within its scope.
10 |         let saved = counter
   | ^ This resource is acquired here and must remain within its scope.
11 |         42
   | ^ This resource is acquired here and must remain within its scope.
12 |     }
   | ^ This resource is acquired here and must remain within its scope.
13 |     let ignored = perform Send<Unit -> Int>.value later
   | ^ This resource is acquired here and must remain within its scope.
14 |     0
   | ^ This resource is acquired here and must remain within its scope.
15 | }) with Send<Unit -> Int> {
   | ^ This resource is acquired here and must remain within its scope.
reason: type.resource-escape
```
<!-- markdownlint-enable MD013 -->

The label points at the request crossing the boundary. The body eventually
returns zero, but that does not authorize the earlier transfer. The
[resource-dependency rules][cells] track stored handles and captures as well
as exposed types and rows.

`08-copied-payload.ash` reads first and sends a closure retaining only the copy:

<!-- source: src/08-copied-payload.ash -->
```ash
import @builtin.cell as Cell

effect Send<A> {
    value : A -> Unit
}

main : Unit -> Int
main () = handle (resource cell<R> counter = 41 {
    let copied = Cell.read counter
    let later : Unit -> Int = fn(ignored) {
        copied + 1
    }
    let ignored = perform Send<Unit -> Int>.value later
    0
}) with Send<Unit -> Int> {
    value later => {
        let reported = later ()
        let result = resume ()
        result + reported
    }
}
```

The outer handler can call that closure without cell access. It obtains `42`,
resumes the suspended body, and adds the body's zero result:

```text
$ ash 08-copied-payload.ash
42 : Int
```

The resource scope is preserved while its suspended body waits and resumes;
it is not acquired again. A resource-free payload may cross that boundary.
The unsafe case was transferring retained access to a recipient outside its
owner.

## Practice: identify the retained value

1. Change the cell's initial value in `01-copied-result.ash`. Explain what the
   returned function remembers before predicting its result.
2. Add another call through `alias` in `02-live-access.ash`. Identify which
   owner remains live during all three calls.
3. Change the initial values and the write in `05-two-acquisitions.ash`.
   Predict both tuple fields separately.
4. In `08-copied-payload.ash`, change the calculation over `copied`. Explain
   why this still needs no access to the released cell.

A dependency follows the access retained by a value, even through functions,
aggregates, or request payloads. Ordinary copies can travel farther. Next we
will use a still-live resource to observe work that must run when a scope
finishes, including when a handler abandons its body.

[cells]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#scoped-cells-and-resource-dependencies
