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

The expression `Go` is already a complete value. Predict which constructor
and type name the tool will report, then run:

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

Predict how the report will distinguish a found integer from an integer
alone, then run. Ash preserves the form and field:

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

Both constructors carry one integer. Follow the supplied constructor back
to its type declaration, then compare that identity with the input required
by `keep_score`. Does the shared field shape establish the required type?
Run this version from `content/learn`:

<!-- diagnostic: src/03-distinct-types.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en defining-data/src/03-distinct-types.ash
This function argument must have type `Score`, but has type `Count`.
  --> /path/to/ash-doc/content/learn/defining-data/src/03-distinct-types.ash:8:22
8 | main () = keep_score (Count(42))
  |                      ^ This has type `Count`.
  --> /path/to/ash-doc/content/learn/defining-data/src/03-distinct-types.ash:4:14
4 | keep_score : Score -> Score
  |              ^ This function requires an argument of type `Score`.
  --> /path/to/ash-doc/content/learn/defining-data/src/03-distinct-types.ash:8:11
8 | main () = keep_score (Count(42))
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The message names both nominal types. The argument label points into
`Count(42)`, while the signature label identifies `Score` as the required
input. Replace `Count(42)` with `Score(42)` and the call produces
`Score(42) : Score`. The constructor tells Ash which data definition created
the value; changing only its contained integer could not repair this mismatch.

## Exercise: describe a reading

Start from a fresh copy of `src/02-result-with-value.ash` in your scratch
directory. Replace its data definition and entry result as you build the new
representation.

Define a type named `Reading` with these two forms:

- `Exact(Int)` carries a measured integer;
- `Unavailable` carries no fields.

Write `main : Unit -> Reading` and construct an `Exact` reading. Predict its
value and type before running. Then change only the result expression to
construct an unavailable reading; predict that observation before running too.

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
