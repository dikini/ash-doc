# Wrapping a representation

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
value. Both are distinct from `Int` and from each other. The tool prints a
newtype through its representation while retaining its nominal type in the
reported type. Use that [rendering rule][rendering] to predict the two printed
fields, then identify their types separately. Run from this lesson's `src`
directory:

```text
$ ash 01-data-and-newtype.ash
(Tagged(42), 42) : (Tagged, Points)
```

The tool renders ordinary data with its constructor. It renders the newtype's
representation while retaining `Points` in the reported type. Seeing an integer
in that output does not mean the source type has become `Int`.

## Cross the representation boundary explicitly

The representation does not make `Points` equal to `Int` in a function
contract. Consider this call:

<!-- source: src/02-no-coercion.ash -->
```ash
newtype Points = Points(Int)

add_one : Int -> Int
add_one value = value + 1

main : Unit -> Int
main () = add_one (Points(41))
```

Identify the argument expression's type and the domain that `add_one`
requires. Predict whether the application meets that contract, then run it:

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

Follow the pattern, integer addition, and explicit construction. What amount
does the function return, and which nominal type does its contract retain?
Predict both before running this version:

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

Write the complete `Reward` requirement for each argument, then follow the
matching method. Predict the two reward amounts before running the program:

```text
$ ash 04-distinct-behavior.ash
(4, 40) : (Int, Int)
```

The raw integer method returns `4`; the points method computes `4 * 10` and
returns `40`. The two arguments select different complete requirements:
`Reward<Int>` and `Reward<Points>`. Their representations do not merge their
implementation identities. Unlike the overlapping integer-box rules in the
previous lesson,
these two nominal keys cannot match one another.

Now remove only the points implementation:

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

Which complete requirement does this argument create? Compare it with the
remaining implementation head and predict whether evidence is available:

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
it. `pub opaque newtype` exports the type name but withholds the constructor.
The functions' own `pub` declarations export `issue` and `number`. A
transparent `pub newtype` would also export its constructor; a declaration
without `pub` would keep its name private.

This client uses the operations that the module exposes:

<!-- source: src/06-opaque-client.ash -->
```ash
import tickets as Tickets

main : Unit -> Int
main () = Tickets.number (Tickets.issue 42)
```

Follow the public operations from the input integer to the ticket and back.
Does the client need to name a constructor along that route? Predict its
result before running it:

```text
$ ash 06-opaque-client.ash
42 : Int
```

`issue` wraps `42` inside its defining module, and `number` unwraps that ticket
there. The client observes the returned integer using only those operations.
The complete import makes the public operations and type name available.
Constructor access is a separate boundary. This second client attempts to
cross it directly:

<!-- source: src/07-hidden-constructor.ash -->
```ash
import tickets as Tickets

main : Unit -> Tickets.Ticket
main () = Tickets.Ticket(42)
```

The signature and expression use the same spelling in different roles.
Which role needs constructor access, and which public declaration grants or
withholds it? Predict the source occurrence the message will identify:

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

Identify each constructed value's complete `Recorded` type, then follow its
`unwrap` call. Predict the pair's values and types before running it:

```text
$ ash 08-parameterized-wrapper.ash
(42, true) : (Int, Bool)
```

Each pattern exposes its representation and `unwrap` returns that value, so
the pair retains the integer and boolean. `Recorded<Int>` and `Recorded<Bool>`
are different applications of the same nominal constructor. Each `unwrap` use
substitutes one element type through both its parameter and result. This follows
the same parameter rules used by
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

Start each task with a fresh copy in a scratch directory: use
`04-distinct-behavior.ash` for tasks one and two,
`08-parameterized-wrapper.ash` for task three, and
`01-data-and-newtype.ash` for task four.

1. Change the point multiplier in `04-distinct-behavior.ash`. Explain which
   implementation and tuple field it affects. Predict the pair, then run it.
2. Add a second newtype over `Int` with a different domain meaning. Give it an
   explicit `Reward` implementation and extend `main` to compare all three
   rewards. Update its tuple annotation, predict the values, and run it.
3. Use `Recorded` with a tuple representation in `08-parameterized-wrapper.ash`.
   Update the entry result annotation to agree with the unwrapped value.
   Predict that value and type before running it.
4. Replace `newtype Points` with an ordinary one-constructor data declaration.
   Predict the value display and nominal type, then compare the observation.
   Explain the representation cost through the lowering and execution rules;
   explain separately whether either declaration makes the type equal to `Int`.

A newtype separates meaning in source contracts while reusing an existing
runtime representation. Explicit construction, patterns, and evidence keep
the intended interpretation visible. The next chapter brings that nominal
distinction into [one local scope and supplies exact behavior there](../supplying-scoped-evidence/README.md).

[overview]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md#current-ash
[evidence]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches
[lowering]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/elaboration.md#explicit-rank-1-operations
[allocation-test]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/src/eval/machine.rs#L8123
[rendering]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output
