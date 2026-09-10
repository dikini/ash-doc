# How can a reusable function preserve its caller's effects?

A function such as `apply_twice` does not need to know what calculation its
argument performs. It calls the supplied function twice. But its signature
still has to account for any effects those calls require.

We will start with a pure callback, then pass the bonus calculation from the
previous lessons. This creates a reason to make the effect row a parameter,
just as Learn made an element type a parameter of a reusable definition.

## Start with a pure callback

A *callback* is an ordinary function passed to another function to be called
there. In `01-pure-callback.ash`, `increment` is the callback:

<!-- source: src/01-pure-callback.ash -->
```ash
apply_twice : (Int -> Int, Int) -> Int
apply_twice (function, value) = function (function value)

increment : Int -> Int
increment value = value + 1

main : Unit -> Int
main () = apply_twice (increment, 40)
```

The first call turns `40` into `41`. The second uses that result and produces
`42`. Neither call requests an effect. Run the file from this lesson's `src`
directory:

```text
$ ash 01-pure-callback.ash
42 : Int
```

The tuple parameter contains a pure function of type `Int -> Int` and its
starting integer. `apply_twice` also promises a pure result computation.
Those promises agree with `increment`.

## An effectful callback needs a different contract

Now try supplying `score`. `02-pure-contract.ash` installs a handler around
the call, but leaves the pure signature of `apply_twice` unchanged:

<!-- source: src/02-pure-contract.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

apply_twice : (Int -> Int, Int) -> Int
apply_twice (function, value) = function (function value)

main : Unit -> Int
main () = handle (apply_twice (score, 40)) with Bonus {
    amount ignored => resume 2
}
```

`score` has type `Int -> Int ! {Bonus}`. It cannot satisfy an argument position
that promises a pure function. The outer handler can answer a request made
during the calculation; it does not change the type required by the helper:

<!-- diagnostic: src/02-pure-contract.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-pure-contract.ash
This function argument must have type `(Int -> Int, Int)`, but has type `(Int -> Int ! {<effect:1:0:0>}, Int)`.
  --> /path/to/ash-doc/content/effects/preserving-callback-effects/src/02-pure-contract.ash:12:31
12 | main () = handle (apply_twice (score, 40)) with Bonus {
   |                               ^ This has type `(Int -> Int ! {<effect:1:0:0>}, Int)`.
  --> /path/to/ash-doc/content/effects/preserving-callback-effects/src/02-pure-contract.ash:8:15
8 | apply_twice : (Int -> Int, Int) -> Int
  |               ^ This function requires an argument of type `(Int -> Int, Int)`.
  --> /path/to/ash-doc/content/effects/preserving-callback-effects/src/02-pure-contract.ash:12:18
12 | main () = handle (apply_twice (score, 40)) with Bonus {
   |                  ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The first label identifies the supplied argument. The second points back to
the tuple parameter in `apply_twice`'s signature, and the third identifies the
whole call. Together they show where the effectful function meets a pure
function requirement.

In this message, `<effect:1:0:0>` is the tool's rendering of the effect identity
for `Bonus` in this program. It is not syntax to copy into a signature. The
important difference is the nonempty row on the supplied function.

We could specialize `apply_twice` to `Bonus`. Instead, its body gives us a more
useful contract: it needs whatever effects the supplied function needs.

## Give the row a parameter

`03-open-row.ash` makes both the value type and the effect row parameters:

<!-- source: src/03-open-row.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

apply_twice<A : Type, R : EffectRow> : (A -> A ! {| R}, A) -> A ! {| R}
apply_twice (function, value) = function (function value)

increment : Int -> Int
increment value = value + 1

main : Unit -> (Int, Int)
main () = {
    let pure_score = apply_twice (increment, 40)
    let bonus_score = handle (apply_twice (score, 40)) with Bonus {
        amount ignored => resume 2
    }
    (pure_score, bonus_score)
}
```

`A : Type` says that `A` stands for an ordinary value type. `R : EffectRow`
says that `R` stands for an effect row. A row parameter is not an integer, a
handler, or an ordinary type parameter. It describes which effects a
computation may require.

The notation `{| R}` is an *open row*: it has no explicitly listed effect
instances and has the tail `R`. Both occurrences of `{| R}` in the signature
refer to the same parameter. The callback may require `R`, so calling
`apply_twice` may require `R` too. The helper calls the callback without
installing a handler or adding a separate effect.

Each use of this signed global definition instantiates its parameters. In the
call with `increment`, `A` is `Int` and `R` is the empty row. In the call with
`score`, `A` is again `Int` and `R` is `{Bonus}`. The second call is handled;
the first needs no handler.

Predict both results before running:

```text
$ ash 03-open-row.ash
(42, 44) : (Int, Int)
```

The effectful calculation adds two to `40`, then adds two to `42`. Calling the
callback twice still requires the row `{Bonus}`, not two entries for `Bonus`.
A row records effect requirements, not request counts or execution order. The
inner call in `function (function value)` finishes before its result is passed
to the outer call; the expression determines that order.

Compare the body of `apply_twice` with the earlier version. Only its signature
needed to change. The row parameter lets that same body describe both uses.
All the polymorphic helpers here have global signatures; this explanation
does not depend on generalizing local function bindings.

## Add a known effect to the callback's row

A different helper might call its callback once and then request a bonus of
its own. Its result must include both requirements. In `04-known-effect.ash`,
`add_bonus` writes the known effect beside the tail:

<!-- source: src/04-known-effect.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

add_bonus<R : EffectRow> : (Int -> Int ! {| R}, Int) -> Int ! {Bonus | R}
add_bonus (function, value) = (function value) + (perform Bonus.amount ())

increment : Int -> Int
increment value = value + 1

main : Unit -> Int
main () = handle (add_bonus (increment, 40)) with Bonus {
    amount ignored => resume 2
}
```

The callback has row `{| R}`. The helper's result has row `{Bonus | R}`: the
known `Bonus` instance together with the remaining effects represented by `R`.
This notation also records that `R` excludes that exact `Bonus` instance.
The tail is the remainder, not an unknown row that might duplicate the known
member.

Here the callback is pure, so `R` becomes empty. `increment 40` produces `41`,
and the helper's request supplies `2`:

```text
$ ash 04-known-effect.ash
43 : Int
```

The tail's exclusion also limits which callbacks this helper accepts. A
callback that itself requests `Bonus` cannot supply that tail. We will examine
that call after checking why the known member is needed in the result row.

## Do not guess what an unknown tail contains

`05-unknown-union.ash` drops the known member from the result row:

<!-- source: src/05-unknown-union.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

add_bonus<R : EffectRow> : (Int -> Int ! {| R}, Int) -> Int ! {| R}
add_bonus (function, value) = (function value) + (perform Bonus.amount ())

increment : Int -> Int
increment value = value + 1

main : Unit -> Int
main () = handle (add_bonus (increment, 40)) with Bonus {
    amount ignored => resume 2
}
```

The body still combines the callback's unknown row with a `Bonus` request.
Now the signature neither includes `Bonus` explicitly nor establishes that
`R` excludes it. Ash does not invent that exclusion to make the union work:

<!-- diagnostic: src/05-unknown-union.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 05-unknown-union.ash
This expression combines effect rows that have no most general union.
  --> /path/to/ash-doc/content/effects/preserving-callback-effects/src/05-unknown-union.ash:6:31
6 | add_bonus (function, value) = (function value) + (perform Bonus.amount ())
  |                               ^ This expression combines effect rows that have no most general union.
reason: effect.row-union-ambiguous
```
<!-- markdownlint-enable MD013 -->

The label identifies the expression combining the two requirements. This
message uses the same reason code seen for the incorrect closed contract in
the preceding lesson, but its explanation concerns an unknown row union.
Restore `{Bonus | R}` in the result signature, as in `04-known-effect.ash`.
That states the known requirement and the restriction on the remaining tail.

The [effect-row rules][rows] govern these unions and exclusions. Known members
form an unordered set: their written order does not select handlers or order
requests. The type checker also needs enough information about open tails;
it cannot assume facts about an unconstrained tail merely because one
particular call uses a pure callback.

## Respect the tail's exclusion at a call

Now try the bonus-requesting `score` as the callback to `add_bonus`.
`06-excluded-callback.ash` gives the helper the correct result row, but supplies
a callback that conflicts with its tail:

<!-- source: src/06-excluded-callback.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

add_bonus<R : EffectRow> : (Int -> Int ! {| R}, Int) -> Int ! {Bonus | R}
add_bonus (function, value) = (function value) + (perform Bonus.amount ())

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int
main () = handle (add_bonus (score, 40)) with Bonus {
    amount ignored => resume 2
}
```

`score` requires `{Bonus}`. Matching that callback against `Int -> Int ! {| R}`
would put `Bonus` into `R`. But the helper's result row `{Bonus | R}` already
requires that `R` exclude the same `Bonus` instance. The call is rejected:

<!-- diagnostic: src/06-excluded-callback.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-excluded-callback.ash
This computation requires an effect excluded from the row tail. An effect written before a row tail cannot also occur in that tail with the same type arguments.
  --> /path/to/ash-doc/content/effects/preserving-callback-effects/src/06-excluded-callback.ash:12:29
12 | main () = handle (add_bonus (score, 40)) with Bonus {
   |                             ^ This computation requires an effect excluded from the row tail. An effect written before a row tail cannot also occur in that tail with the same type arguments.
  --> /path/to/ash-doc/content/effects/preserving-callback-effects/src/06-excluded-callback.ash:5:28
5 | add_bonus<R : EffectRow> : (Int -> Int ! {| R}, Int) -> Int ! {Bonus | R}
  |                            ^ This type is required here.
reason: effect.row-exclusion
```
<!-- markdownlint-enable MD013 -->

The first label points at the supplied callback and its starting value. The
related label points at the helper's required callback type. The message
explains why matching them fails: the known effect cannot also occur in the
tail with the same type arguments.

Use the pure `increment` callback from `04-known-effect.ash` to satisfy this
contract. Its empty row fits `R`, leaving only the helper's own `Bonus`
request. If the helper is intended to share `Bonus` with its callback, its
callback contract must include that known effect explicitly as well.

This is a restriction on substituting a row into a contract. It does not mean
that a calculation can request a given effect only once: `apply_twice` already
requested the bonus twice using one effect-row member.

## Practice: preserve the callback's contract

1. In a copy of `03-open-row.ash`, make `apply_twice` call its callback three
   times and rename it `apply_three_times`. Predict both results before
   running. Explain whether the row needs to change.
2. Add a pure Boolean callback that exchanges `true` and `false`. Use the
   same `apply_twice` definition with that callback. Identify the value-type
   and row arguments for this use, then run it.
3. In `04-known-effect.ash`, change the handler's bonus and the initial points.
   Trace the callback first and the helper's request second. Predict the
   result without changing either function's contract.

A reusable helper can leave its value type and its effect requirements open.
The repeated row parameter connects what the callback needs to what the
helper needs. A known member beside that tail adds a requirement and makes
an exclusion explicit.

So far each successful effectful calculation has used one handler for
`Bonus`. Next we can ask which handler receives a request when handlers are
nested or when a program uses different effect instances.

[rows]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#computation-types-and-effect-rows
