# How can a program define its own data?

An integer says how many; a Boolean says yes or no; a tuple keeps a fixed set
of parts together. These types are useful, but their names do not always say
what the values mean in a particular program. The integer `42` might be a
score, a count, or a value found by a search. A program becomes easier to
understand when its data can carry those distinctions.

An Ash data definition introduces a new type and lists the forms that values of
that type may take. The form names belong to the program's subject. They let
the data say more than its underlying integers and Booleans could say alone.

## Naming the possible forms

Suppose a signal can tell a calculation either to continue or to stop:

<!-- source: src/01-signal.ash -->
```ash
type Signal =
    Go
    | Stop

main : Unit -> Signal
main () = Go
```

Read the definition as a description: a `Signal` is either `Go` or `Stop`.
`Signal` is the new type. `Go` and `Stop` are its *constructors*, the two ways
to construct a value of that type.

The vertical bar means “or.” It separates one possible form from the next. The
indentation keeps the alternatives together as one definition.

The expression `Go` is already a complete value. Running the program reports:

```text
Go : Signal
```

Change `main` to produce `Stop`. Ash then reports `Stop : Signal`. The two
values differ, but both belong to the type named by the definition.

## A form that carries a value

A constructor may also keep fields inside the value it constructs. A search,
for example, may either find an integer or find nothing:

<!-- source: src/02-result-with-value.ash -->
```ash
type Result =
    Found(Int)
    | Missing

main : Unit -> Result
main () = Found(42)
```

The data definition gives us two cases to consider:

- `Found(number)` represents a result that contains an integer;
- `Missing` represents a result with no integer to carry.

`Found` is a constructor that needs one `Int`. The expression `Found(42)`
supplies that field and produces a `Result`. `Missing` needs no fields and is a
`Result` by itself.

Run the program. Ash preserves both the form and the field in its report:

```text
Found(42) : Result
```

The type describes what every `Result` may look like. A particular value uses
one constructor from that definition.

## A new name makes a new type

Two data definitions remain distinct even when their constructors have the
same field types:

<!-- source: src/03-distinct-types.ash -->
```ash
type Score = Score(Int)
type Count = Count(Int)

keep_score : Score -> Score
keep_score score = score

main : Unit -> Score
main () = keep_score (Count(42))
```

Both constructors carry one integer. Nevertheless, `Score(42)` has type
`Score`, while `Count(42)` has type `Count`. The names preserve the distinction
the program cares about.

`keep_score` requires a `Score`. Giving it `Count(42)` does not become sound
merely because the value inside is an integer. Ash rejects the program with a
message beginning:

```text
type.argument
```

Replace `Count(42)` with `Score(42)` and the call produces `Score(42) : Score`.
The constructor tells Ash which data definition created the value.

## Exercise: describe a reading

Define a type named `Reading` with these two forms:

- `Exact(Int)` carries a measured integer;
- `Unavailable` carries no fields.

Write `main : Unit -> Reading` and construct an `Exact` reading. Run the
program, then change only the result expression so that it constructs an
unavailable reading. Predict how Ash will display each value and its type.

Finish by explaining, in one sentence for each constructor, what information
that form represents. A data definition should describe the values of the
program, not merely demonstrate syntax.

## Data shaped for the program

A data definition creates a type and names every way to construct its values.
Some constructors are complete values; others carry fields. Even when two
types carry fields with the same shape, their type names keep the values
distinct.

We can now construct every form of `Result`, but a useful function must also be
able to handle them. The next lesson connects these data definitions to the
matches and patterns we already know.
