# How can a wrapper give an existing representation a distinct meaning?

Two quantities may both be stored as integers while meaning different things
to a program. A nominal type lets their contracts keep that distinction.
An ordinary data constructor can carry the integer. A `newtype` can give the
same representation a distinct type without adding a runtime wrapper.

The type distinction remains real: construction and unwrapping are explicit,
and interface behavior belongs to the nominal type rather than being inherited
from its representation.

## Compare two nominal declarations

`01-data-and-newtype.ash` constructs one value of each form:

<!-- source: src/01-data-and-newtype.ash -->
```ash
type Tagged = Tagged(Int)
newtype Points = Points(Int)

main : Unit -> (Tagged, Points)
main () = (Tagged(42), Points(42))
```

`Tagged` is ordinary data with one constructor and one integer field. `Points`
is a newtype whose sole, same-spelled constructor takes one representation
value. Both are distinct from `Int` and from each other. From this lesson's
`src` directory, run:

```text
$ ash 01-data-and-newtype.ash
(Tagged(42), 42) : (Tagged, Points)
```

The tool renders ordinary data with its constructor. It renders the newtype's
representation while retaining `Points` in the reported type. Seeing an integer
in that output does not mean the source type has become `Int`.

## Cross the representation boundary explicitly

A function accepting an integer cannot be given points automatically:

<!-- source: src/02-no-coercion.ash -->
```ash
newtype Points = Points(Int)

add_one : Int -> Int
add_one value = value + 1

main : Unit -> Int
main () = add_one (Points(41))
```

<!-- diagnostic: src/02-no-coercion.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-no-coercion.ash
This function argument must have type `Int`, but has type `Points`.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/02-no-coercion.ash:7:19
7 | main () = add_one (Points(41))
  |                   ^ This has type `Points`.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/02-no-coercion.ash:3:11
3 | add_one : Int -> Int
  |           ^ This function requires an argument of type `Int`.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/02-no-coercion.ash:7:11
7 | main () = add_one (Points(41))
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The labels connect the supplied `Points` value to the `Int` parameter contract.
The compiler does not insert an implicit conversion. If the operation should
accept and return points, write that contract and expose the representation
with a constructor pattern:

<!-- source: src/03-explicit-conversion.ash -->
```ash
newtype Points = Points(Int)

add_one : Points -> Points
add_one (Points(value)) = Points(value + 1)

main : Unit -> Points
main () = add_one (Points(41))
```

```text
$ ash 03-explicit-conversion.ash
42 : Points
```

The pattern `Points(value)` unwraps the integer. Integer addition computes the
new amount, and `Points(value + 1)` wraps it explicitly. The one constructor
pattern covers all values of `Points`, so no second case is needed.

## Give the nominal type its own behavior

Suppose raw integers are rewards directly, while each point is worth ten
reward units. Separate implementations make that interpretation explicit:

<!-- source: src/04-distinct-behavior.ash -->
```ash
newtype Points = Points(Int)

interface Reward<A> {
    reward : A -> Int
}

impl Reward<Int> {
    reward value = value
}

impl Reward<Points> {
    reward (Points(value)) = value * 10
}

main : Unit -> (Int, Int)
main () = (reward 4, reward (Points(4)))
```

```text
$ ash 04-distinct-behavior.ash
(4, 40) : (Int, Int)
```

The two arguments select different complete requirements: `Reward<Int>` and
`Reward<Points>`. Their representations do not merge their implementation
identities. Unlike the overlapping integer-box rules in the previous lesson,
these two nominal keys cannot match one another.

Without the points implementation, wrapping an integer does not supply its
missing evidence:

<!-- source: src/05-no-inherited-evidence.ash -->
```ash
newtype Points = Points(Int)

interface Reward<A> {
    reward : A -> Int
}

impl Reward<Int> {
    reward value = value
}

main : Unit -> Int
main () = reward (Points(4))
```

<!-- diagnostic: src/05-no-inherited-evidence.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 05-no-inherited-evidence.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/05-no-inherited-evidence.ash:12:11
12 | main () = reward (Points(4))
   |           ^ No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/05-no-inherited-evidence.ash:4:5
4 |     reward : A -> Int
  |     ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/05-no-inherited-evidence.ash:3:1
3 | interface Reward<A> {
  | ^ This interface participates in the failing evidence selection.
4 |     reward : A -> Int
  | ^ This interface participates in the failing evidence selection.
5 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

The method occurrence needs `Reward<Points>`. The message relates that use to
the interface contract; the available integer implementation satisfies a
different requirement. Restore the explicit points implementation from the
preceding example. If the intended calculation is instead the integer reward,
unwrap first and call the method on that integer deliberately.

Neither wrapping nor unwrapping copies interface evidence. The
[evidence rules][evidence] preserve nominal identity through selection.

## Choose who may construct and unwrap

The module `tickets.ash` keeps its constructor behind an opaque public type:

<!-- source: src/tickets.ash -->
```ash
pub opaque newtype Ticket = Ticket(Int)

pub issue : Int -> Ticket
issue value = Ticket(value)

pub number : Ticket -> Int
number (Ticket(value)) = value
```

The module owns `Ticket`, so `issue` may construct it and `number` may unwrap
it. `pub opaque newtype` exports the type name and the public functions, but
not the constructor. A transparent `pub newtype` would also export its
constructor; a declaration without `pub` would keep its name private.

This client uses the operations that the module exposes:

<!-- source: src/06-opaque-client.ash -->
```ash
import tickets as Tickets

main : Unit -> Int
main () = Tickets.number (Tickets.issue 42)
```

The client obtains a ticket from `issue` and reads its integer through `number`:

```text
$ ash 06-opaque-client.ash
42 : Int
```

The complete import makes the public operations and type name available.
Constructor access is a separate boundary. This second client attempts to
cross it directly:

<!-- source: src/07-hidden-constructor.ash -->
```ash
import tickets as Tickets

main : Unit -> Tickets.Ticket
main () = Tickets.Ticket(42)
```

<!-- diagnostic: src/07-hidden-constructor.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 07-hidden-constructor.ash
The constructor `Ticket` belongs to an opaque type and is not accessible here.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/07-hidden-constructor.ash:4:19
4 | main () = Tickets.Ticket(42)
  |                   ^ This name is not accessible here.
  --> /path/to/ash-doc/content/libraries/wrapping-a-representation/src/tickets.ash:1:29
1 | pub opaque newtype Ticket = Ticket(Int)
  |                             ^ The inaccessible declaration is here.
reason: resolve.opaque-constructor
```
<!-- markdownlint-enable MD013 -->

The message identifies the constructor use and the declaration that makes it
opaque. Replace `Tickets.Ticket(42)` with `Tickets.issue 42` to construct through
the public operation. The result may retain type `Tickets.Ticket`; the hidden
constructor is what the client cannot use.

The [module visibility rules][overview] allow the type in `main`'s signature
while withholding the expression constructor. A client must use `issue`, not
construct or pattern-match the opaque representation itself. Opacity controls
source access; it does not add a wrapper allocation or make printed values a
security boundary.

## Parameterize the representation

A newtype can leave its representation type open:

<!-- source: src/08-parameterized-wrapper.ash -->
```ash
newtype Recorded<A> = Recorded(A)

unwrap : Recorded<A> -> A
unwrap (Recorded(value)) = value

main : Unit -> (Int, Bool)
main () = (unwrap (Recorded(42)), unwrap (Recorded(true)))
```

```text
$ ash 08-parameterized-wrapper.ash
(42, true) : (Int, Bool)
```

`Recorded<Int>` and `Recorded<Bool>` are different applications of the same
nominal constructor. Each `unwrap` use substitutes one element type through
both its parameter and result. This follows the same parameter rules used by
ordinary data; it adds no implicit conversion between the two applications.

## Account for the wrapper's cost

The allocation claim comes from the language's lowering and execution rules,
not from the printed values above. Construction lowers to a checked wrap
conversion, and a newtype pattern lowers to an unwrap conversion. The compiler
validates the relation between the nominal type and its representation before
those conversions erase.

The [execution rule][execution] enters a validated conversion's child without
allocating a wrapper cell, comparing a tag, or copying the representation.
If the representation is an ordinary data value, its own construction still
allocates normally. Other work in the program, such as tuple construction or
function calls, retains its ordinary costs. Allocation-free wrapping does not
mean the whole program performs no allocation.

The pinned evaluator's
[`module_newtype_wrapper_allocates_no_constructor_cell` test][allocation-test]
checks this distinction directly: it wraps an ordinary `Box` value and asserts
that the heap contains exactly one cell, belonging to that representation.
The [lowering rules][lowering] establish why no ordinary constructor node is
emitted for the newtype wrapper. The source-level type distinction has already
been checked before this runtime erasure.

## Practice: preserve meaning across conversion

1. Change the point multiplier in `04-distinct-behavior.ash`. Explain which
   implementation and tuple field it affects.
2. Add a second newtype over `Int` with a different domain meaning. Give it an
   explicit `Reward` implementation and compare all three rewards.
3. Use `Recorded` with a tuple representation in the last example. Predict the
   unwrapped value and type before running it.
4. Explain why replacing a newtype declaration with an ordinary one-constructor
   data declaration changes the representation cost but does not make either
   type implicitly equal to its field type.

A newtype separates meaning in source contracts while reusing an existing
runtime representation. Explicit construction, patterns, and evidence keep
the intended interpretation visible. The next chapter brings that nominal
distinction into one local scope and supplies exact behavior for it there.

[overview]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/README.md#current-ash
[evidence]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence
[execution]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/dynamic-semantics.md#tuples-constructors-and-matches
[lowering]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/elaboration.md#explicit-rank-1-operations
[allocation-test]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/src/eval/machine.rs#L6306
