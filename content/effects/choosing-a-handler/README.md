# Which handler answers a request?

The preceding lessons put each request under one handler. A calculation can
also have a local rule inside a broader rule. To predict its result, follow
where the request happens and identify the nearest handler for that exact
effect instance.

An effect instance consists of the declaring effect and its type arguments.
Two handlers with the same target can answer differently. Two effects with
the same spelling need not be the same target.

## A local answer inside an outer calculation

In `01-nested.ash`, the first request has a local handler. The second request
comes after that local scope has finished:

<!-- source: src/01-nested.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle {
    let local_bonus = handle (perform Bonus.amount ()) with Bonus {
        amount ignored => resume 2
    }
    local_bonus + (perform Bonus.amount ())
} with Bonus {
    amount ignored => resume 10
}
```

The inner handler supplies `2`. The later request uses the still-surrounding
handler and receives `10`. Follow both scopes, then run the file from this
lesson's `src` directory:

```text
$ ash 01-nested.ash
12 : Int
```

Both requests name `Bonus.amount`. Their positions in the calculation decide
which handler answers. The effect row does not list an order of handlers.

## A clause can ask the surrounding handler

A local rule may build on an outer answer instead of replacing it with a
constant. `02-forwarding.ash` moves the second request into the inner clause:

<!-- source: src/02-forwarding.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle {
    handle (perform Bonus.amount ()) with Bonus {
        amount ignored => {
            let base = perform Bonus.amount ()
            resume (base + 2)
        }
    }
} with Bonus {
    amount ignored => resume 10
}
```

The request in the inner body selects the inner clause. The request made
directly by that clause goes past its own handler to the outer handler. It
receives `10`, then the inner clause resumes its suspended calculation with
`12`. The clause does not repeatedly select itself.

```text
$ ash 02-forwarding.ash
12 : Int
```

Handling removes the targeted requirement from the body. A request introduced
by a clause remains an outward requirement until another handler answers it.
Here the outer handler handles that requirement. The [effect rules][effects]
describe both boundaries.

## Type arguments are part of the target

An operation API can be parameterized. In `03-instances.ash`, `Ask<A>` requests
a value of type `A`:

<!-- source: src/03-instances.ash -->
```ash
effect Ask<A> {
    value : Unit -> A
}

main : Unit -> (Int, Bool)
main () = {
    let points = handle (perform Ask<Int>.value ()) with Ask<Int> {
        value ignored => resume 40
    }
    let enabled = handle (perform Ask<Bool>.value ()) with Ask<Bool> {
        value ignored => resume true
    }
    (points, enabled)
}
```

`Ask<Int>` and `Ask<Bool>` are different instances of one declaration. Their
clauses resume with different value types. Each handler targets exactly the
instance requested in its body:

```text
$ ash 03-instances.ash
(40, true) : (Int, Bool)
```

Changing only the handler's target does not redirect the request. Consider
`04-wrong-instance.ash`:

<!-- source: src/04-wrong-instance.ash -->
```ash
effect Ask<A> {
    value : Unit -> A
}

main : Unit -> Int
main () = handle (perform Ask<Int>.value ()) with Ask<Bool> {
    value ignored => resume false
}
```
<!-- diagnostic: src/04-wrong-instance.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-wrong-instance.ash
The handled computation must explicitly request this exact effect instance, including its type arguments.
  --> /path/to/ash-doc/content/effects/choosing-a-handler/src/04-wrong-instance.ash:6:51
6 | main () = handle (perform Ask<Int>.value ()) with Ask<Bool> {
  |                                                   ^ The handled computation must explicitly request this exact effect instance, including its type arguments.
reason: effect.handler-missing-input
```
<!-- markdownlint-enable MD013 -->

The label identifies `Ask<Bool>`, but the body requests `Ask<Int>`. Restore the
target to `Ask<Int>` and supply an integer through `resume`, as in the first
binding of `03-instances.ash`. Matching operation names alone is insufficient.

## A declaration keeps its identity across imports

Two modules can use the same spelling for independent APIs. Save these sibling
files as `left.ash` and `right.ash`:

<!-- source: src/left.ash -->
```ash
pub effect Bonus {
    amount : Unit -> Int
}
```
<!-- source: src/right.ash -->
```ash
pub effect Bonus {
    amount : Unit -> Int
}
```

Both declarations are public, so their APIs are accessible through complete
imports. The consumer `05-module-identities.ash` qualifies each one:

<!-- source: src/05-module-identities.ash -->
```ash
import left as Left
import right as Right

main : Unit -> Int
main () = handle {
    let first = handle (perform Left.Bonus.amount ()) with Left.Bonus {
        amount ignored => resume 2
    }
    first + (perform Right.Bonus.amount ())
} with Right.Bonus {
    amount ignored => resume 5
}
```

The outer `Right.Bonus` handler does not answer the `Left.Bonus` request. The
inner handler supplies `2` for the left declaration and the outer supplies
`5` for the right:

```text
$ ash 05-module-identities.ash
7 : Int
```

Qualification identifies the declaring module. Renaming an import alias does
not create a new effect; declaring another effect does. The
[identity and row rules][rows] preserve this distinction even when spellings
and operation signatures agree.

## A closure keeps values, not its creating handler

E2 distinguished creating a function from calling it. In
`06-returned-function.ash`, creation itself includes one handled request:

<!-- source: src/06-returned-function.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

make_request : Unit -> Unit -> Int ! {Bonus}
make_request ignored = handle {
    let initial = perform Bonus.amount ()
    let request : Unit -> Int ! {Bonus} = fn(ignored) {
        initial + (perform Bonus.amount ())
    }
    request
} with Bonus {
    amount ignored => resume 2
}

main : Unit -> Int
main () = {
    let request = make_request ()
    handle (request ()) with Bonus {
        amount ignored => resume 9
    }
}
```

`make_request ()` obtains `2` and saves it as `initial`. The local annotation
on `request` supplies the function type needed to check the anonymous function.
Its body has not run yet. Returning that closure retains `initial`, but does
not retain the handler that supplied it.

Later, `request ()` runs under a handler supplying `9`. Its result combines
the saved `2` with that new answer:

```text
$ ash 06-returned-function.ash
11 : Int
```

There are two separate facts to trace: which ordinary values the closure
captures, and which handler surrounds a request when the closure is called.

## Practice: trace the request before changing the answer

1. Change only the inner answer in `01-nested.ash`. Predict which part of the
   sum changes, then run the program.
2. In `02-forwarding.ash`, change the outer answer. Explain the path from that
   answer to the value passed to the inner `resume`.
3. Rename the `Left` import alias in `05-module-identities.ash` and update its
   uses. Predict whether that changes either answer.
4. Change the handler around `request ()` in `06-returned-function.ash`.
   Identify the saved value before predicting the new result.

The nearest matching handler answers a request from its body; its own clauses
can request behavior from outside that handler. Exact declaration identity
and type arguments determine what matches. We can now follow a request to its
clause. Next we will follow what happens when that clause resumes the waiting
calculation.

[effects]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#effects
[rows]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#computation-types-and-effect-rows
