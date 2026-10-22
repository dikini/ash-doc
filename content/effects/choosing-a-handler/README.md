# Which handler answers a request?

The preceding lessons put each request under one handler. A calculation can
also have a local rule inside a broader rule. To predict its result, follow
where the request happens and identify the nearest handler for that exact
effect instance.

An [effect instance][rows] consists of the declaring effect and its type arguments.
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

For each `perform`, identify the matching handler that still surrounds it.
Follow where the local scope finishes before predicting the sum, then run
the file from this lesson's `src` directory:

```text
$ ash 01-nested.ash
12 : Int
```

The inner handler supplies `2`. The later request uses the still-surrounding
handler and receives `10`, so the addition produces `12`.

Both requests name `Bonus.amount`. The [handler evaluation rules][evaluation]
select the nearest matching handler at the point of each request. The effect
row does not list an order of handlers.

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

A clause runs outside the handler that selected it. Here, its request reaches
the handlers surrounding the inner handler. With that boundary in mind,
follow how `base` gets its value and predict the answer passed to the inner
`resume`:

```text
$ ash 02-forwarding.ash
12 : Int
```

The request in the inner body selects the inner clause. The request made
directly by that clause goes past its own handler to the outer handler. It
receives `10`, then the inner clause resumes its suspended calculation with
`12`. The clause does not repeatedly select itself.

Both programs produce `12`. The preceding one adds the answers to two body
requests. This one uses the outer answer to construct the inner clause's
answer. The same final value can follow different request paths.

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
operations return different value types. Match each requested instance to
its handler, then predict the value and type of each tuple field:

```text
$ ash 03-instances.ash
(40, true) : (Int, Bool)
```

Each handler targets exactly the instance requested in its body. The integer
request receives `40`, and the Boolean request receives `true`. Their operation
result types determine what each clause may supply through `resume`.

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

Compare the type arguments on the request and the handler target before
looking at the clause. Does the handler target the instance established by
its body? Run the file to inspect that boundary:

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

The label identifies `Ask<Bool>`, but the body requests `Ask<Int>`. The handler
must target that exact instance. Restore the target to `Ask<Int>` and supply
an integer through `resume`, as in the first binding of `03-instances.ash`.
Changing the target also changes the operation's answer type, so the Boolean
answer must change too. Matching operation names alone is insufficient.

## A declaration keeps its identity across imports

Two modules can use the same spelling for independent APIs. The sibling files
`left.ash` and `right.ash` each declare a public effect:

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

For each request, follow its import alias to the declaring module. Locate the
handler that targets that declaration, then predict the sum from the two
answers:

```text
$ ash 05-module-identities.ash
7 : Int
```

The outer `Right.Bonus` handler does not answer the `Left.Bonus` request. The
inner handler supplies `2` for the left declaration and the outer supplies
`5` for the right. The calculation adds those answers to produce `7`.

Qualification identifies the declaring module. Renaming an import alias does
not create a new effect; declaring another effect does. The
[effect identity rules][effects] preserve this distinction even when spellings
and operation signatures agree.

## A closure keeps values, not its creating handler

[Following effect contracts](../following-effect-contracts/README.md)
distinguished creating a function from calling it. In
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

Separate the creating call, `make_request ()`, from the later call,
`request ()`. Trace the first request while the function is being made, then
identify which handler surrounds the request inside its body when it is
called later. Predict the result from the saved value and the new answer:

```text
$ ash 06-returned-function.ash
11 : Int
```

`make_request ()` obtains `2` and saves it as `initial`. The local annotation
on `request` gives the checker an expected function type. Its body has not run
yet. Returning that closure retains `initial`, but does not retain the handler
that supplied it.

Later, `request ()` runs under a handler supplying `9`. Its result combines
the saved `2` with that new answer, producing `11`.

There are two separate facts to trace: which ordinary values the closure
captures, and which handler surrounds a request when the closure is called.

## Practice: trace the request before changing the answer

Start each task from a fresh copy of its named program in this lesson's `src`
directory. Keep `left.ash` and `right.ash` beside the module-example copy so
its relative imports still find the same declarations.

In `01-nested.ash`, change only the inner answer. Which part of the sum
changes? Run the program to check.

In `02-forwarding.ash`, change the outer answer. Explain the path from that
answer to the value passed to the inner `resume`.

Rename the `Left` import alias in `05-module-identities.ash` and update its
uses. Does renaming change either answer? Predict before running.

In `06-returned-function.ash`, change the handler around `request ()`. Its
result combines one saved value with the new answer; predict the new result.

The nearest matching handler answers a request from its body; its own clauses
can request behavior from outside that handler. Exact declaration identity
and type arguments determine what matches. We can now follow a request to its
clause. Next we will follow what happens when that clause resumes the waiting
calculation.

[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[rows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#computation-types-and-effect-rows
[evaluation]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
