# Keeping access in scope

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

Inspect what `calculate` captures: does its body need the handle, or only the
integer already read? Predict its result when `later ()` runs after the
resource scope ends. Run from this lesson's `src` directory:

```text
$ ash 01-copied-result.ash
42 : Int
```

The closure keeps the copied `41` and adds one, producing `42`. The scope
releases the cell before `later ()` runs; the closure needs no access to it.
This is the same split the
[handler-selection lesson](../choosing-a-handler/README.md) drew for
closures: captured values travel with the function, while a request inside
its body answers to the handler in place when the function is called.

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
reads and increments it. The owner surrounds both calls and the final read.
Predict that read, and identify what would have to remain live to call
`bump` again:

```text
$ ash 02-live-access.ash
2 : Int
```

The two calls update the same cell from `0` to `2`. Both retain access
within its owner; only the copied final read leaves it. Reusable access is
allowed. What matters is keeping it within its owner, not
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

What would `leaked` retain after the closing brace? Compare it with the
copied integer retained by the first example:

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

Follow `later`'s captured value back to its owner. Could that function perform
its read after the owner closes?

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

`R` and `S` identify different acquisitions. Match each tuple field to its
owner, then trace the write and the read. Predict both returned integers and
identify which owner is still live when the final pair is constructed:

```text
$ ash 05-two-acquisitions.ash
(10, 2) : (Int, Int)
```

The write changes `outer` to `10`, while `inner` stays `2`. Its copied read
leaves the inner scope; the outer owner still surrounds the final read.
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

The integer field needs no cell access. What does the other field retain
when the whole tuple leaves the resource body?

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

The type `Unit -> Int` mentions no resource. Inspect the function body as well:
what does `let saved = counter` retain? The selected handler is outside the
acquisition. Does the constant return value remove that captured access?

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

The label points at the request crossing the boundary, with the acquisition
identified below it. The closure explicitly captures `counter`, even though
it returns a constant. The body's eventual zero result does not authorize
that earlier transfer. The
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

This closure retains the copied integer. Trace the handler's two bindings:
predict `reported` from the closure call, then `result` from resumption.
Which value does their addition produce?

```text
$ ash 08-copied-payload.ash
42 : Int
```

The closure call produces `42`. At that point, the cell scope is still
suspended in the continuation. `resume ()` restores that scope and the body
returns `0`; normal completion releases the cell before resumption returns
that result to the clause. Their addition gives `42`.

The [cell evaluation rules][execution] preserve the owned scope during
suspension and restore it without reacquiring the cell. A payload retaining
only copied data may cross to the outer handler. The earlier rejected payload
retained access whose owner was in the suspended work.

## Practice: identify the retained value

For each task, start with a fresh copy of its named program in a scratch
directory outside this lesson's `src` tree. Run your copy from that directory.

Change the cell's initial value in `01-copied-result.ash`. What does the
returned function remember? Answer that before predicting its result.

Add another call through `alias` in `02-live-access.ash`. Which owner must
remain live during all three calls?

Change the initial values and the write in `05-two-acquisitions.ash`. Predict
each tuple field separately.

In `08-copied-payload.ash`, change the calculation over `copied`. Why does
the closure need no cell access while the resource scope is suspended?

A dependency follows the access retained by a value, even through functions,
aggregates, or request payloads. Ordinary copies can travel farther. Next we
will use a still-live resource to observe work that must run when a scope
finishes, including when a handler abandons its body.

[cells]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-cell-execution
