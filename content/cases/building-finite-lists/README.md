# Building finite lists

The preceding case used `fold` to consume a finite list. Its input already had
every `More` and the ending `Empty`; the recursive equations replaced those
forms with a result. Production starts from a different question. Given one
state, what value should appear now, which state should follow, and when should
the list end?

An *unfold* separates that question from the recursion that constructs the
list. A transition examines the current state and returns one of two steps:

- `Stop` says that production is complete; and
- `Emit(value, next_state)` supplies one list value and the state for the next
  transition.

This chapter uses only finite production. Its concrete transition follows a
smaller part of a recursive natural number until it reaches `Zero`. The generic
`unfold` type does not by itself establish that every possible transition will
eventually return `Stop`.

## From a state step to a list form

The shared module defines two recursive representations and one step
representation. `Natural` describes the remaining number of emissions.
`List<A>` describes the result. `Step<S, A>` connects them without choosing
either representation: `S` is the state type, and `A` is the emitted element
type.

<!-- source: src/lists.ash -->
```ash
pub type Natural =
    Zero
    | Next(Natural)

pub type List<A> =
    Empty
    | More(A, List<A>)

pub type Step<S, A> =
    Stop
    | Emit(A, S)

pub unfold : (S -> Step<S, A>) -> S -> List<A>
unfold transition state = match transition state {
    Stop => Empty
    Emit(value, next_state) => {
        let produced_rest = unfold transition next_state
        More(value, produced_rest)
    }
}

pub unfold_counted : (S -> Step<S, A>) -> S -> (List<A>, Int)
unfold_counted transition state = match transition state {
    Stop => (Empty, 1)
    Emit(value, next_state) => {
        let (produced_rest, later_steps) = unfold_counted transition next_state
        (More(value, produced_rest), later_steps + 1)
    }
}

pub map : (A -> B) -> List<A> -> List<B>
map transform Empty = Empty
map transform More(first, rest) = {
    let mapped_rest = map transform rest
    More(transform first, mapped_rest)
}

pub repeat_step : Int -> Natural -> Step<Natural, Int>
repeat_step value Zero = Stop
repeat_step value Next(rest) = Emit(value, rest)
```

The equations for `unfold` translate steps into list forms. `Stop` becomes
`Empty`. `Emit(value, next_state)` produces the list for `next_state`, then
places `value` in front of that result. The transition decides what one step
means; `unfold` owns the repeated application and list construction.

These are ordinary Ash types, matches, and recursive global definitions. The
[static pattern and match
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#patterns-matches-and-coverage)
check the two `Step` arms and make their payload bindings available only in the
matching arm. The [global-definition
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#globals-and-modules)
make every local global scheme available before any body is checked, so
`unfold` can refer to itself. It is neither special syntax nor a built-in list
producer.

The concrete `repeat_step` supplies the missing policy. At `Zero`, it returns
`Stop`. At `Next(rest)`, it emits the selected integer and uses `rest` as the
next state.

## Producing three values

The first entry constructs a state with three `Next` forms. Predict the step
and list form selected at each state before running it.

<!-- source: src/01-unfold.ash -->
```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    Lists.unfold (Lists.repeat_step 42) three
}
```

Starting at `three`, the transition emits `42` and follows one `rest` three
times. The fourth state is `Zero`, so its transition returns `Stop`:

```text
Next(Next(Next(Zero))) -> Emit(42, Next(Next(Zero)))
Next(Next(Zero))       -> Emit(42, Next(Zero))
Next(Zero)             -> Emit(42, Zero)
Zero                   -> Stop
```

Run the complete entry from `content/cases`:

```text
ash building-finite-lists/src/01-unfold.ash
```

Ash reports the complete produced list:

```text
More(42, More(42, More(42, Empty))) : List<Int>
```

The value has one `More` for each `Emit` and one ending `Empty` for `Stop`.
Ash's [observation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation)
render constructors structurally and pair the result with the checked type of
`main`; the displayed line is a tool observation, not a new notation defined
by this case.

## Why three elements require four transitions

The output alone shows three constructed elements, but it hides the final
question that discovers the end. `unfold_counted` keeps the ordinary step
protocol and mirrors the traversal only to expose how many times it applies
the transition. Its `Stop` arm reports one application. An `Emit` arm adds one
to the count returned by the next state.

<!-- source: src/02-counted-unfold.ash -->
```ash
import lists as Lists

main : Unit -> (Lists.List<Int>, Int)
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    Lists.unfold_counted (Lists.repeat_step 42) three
}
```

Run it:

```text
ash building-finite-lists/src/02-counted-unfold.ash
```

The second tuple field includes the final transition at `Zero`:

```text
(More(42, More(42, More(42, Empty))), 4) : (List<Int>, Int)
```

For a completed production from a state with `n` `Next` forms,
`repeat_step` causes `n` transitions that return `Emit` and one transition
that returns `Stop`. The source-level total is therefore `n + 1` transition
applications. The `n` emitting arms construct `n` result `More` values.

The pinned [dynamic match
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches)
evaluate the scrutinee once and enter only the first matching arm. Here the
scrutinee is `transition state`, so each recursive call contributes one
transition application and selects one arm. The count describes this source
operation; it does not claim a duration or a number of machine instructions.

## The producer supplies the termination argument

The type of `unfold` connects each returned next state to its input state type:

```text
(S -> Step<S, A>) -> S -> List<A>
```

That connection prevents a transition from changing to an unrelated state
type. It does not say that the next state is smaller. The termination argument
for these entries comes from the equations for `repeat_step`:

1. `Zero` returns `Stop` without another state.
2. `Next(rest)` returns the direct `rest` field as its next state.
3. A finite seed contains only finitely many enclosing `Next` forms before
   `Zero`.

Each recursive call therefore receives one fewer `Next` form, and the base
form stops production. This is a property of `repeat_step` and its finite
inputs, not of every function with the same type.

For example, a transition could emit a value while returning its unchanged
state:

```text
repeat_without_progress value state = Emit(value, state)
```

This sketch is intentionally non-executable and is not run. Generic `unfold`
would keep asking the same question, so strict evaluation would not produce a
completed result. Ash accepting a transition type is not a proof that the
transition reaches `Stop`.

## Eager production before a following map

Inside `unfold`, the `produced_rest` binding evaluates its initializer before
the block continues to `More(value, produced_rest)`. Production therefore
reaches `Stop` and returns outward through every recursive binding before the
outermost call can return its complete list. The pinned [dynamic binding
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#bindings)
make that initializer-before-remainder order explicit.

The next entry creates a second boundary. Its `produced` binding completes the
entire `unfold` application before the block enters the following `map` call.
It returns both results so the observation retains the produced list beside
the mapped list.

<!-- source: src/03-map-produced-list.ash -->
```ash
import lists as Lists

increment : Int -> Int
increment value = value + 1

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    let produced = Lists.unfold (Lists.repeat_step 42) three
    let mapped = Lists.map increment produced
    (produced, mapped)
}
```

Run the complete entry:

```text
ash building-finite-lists/src/03-map-produced-list.ash
```

The first field retains the three produced values. The second field contains a
new three-element representation:

<!-- markdownlint-disable MD013 -->
```text
(More(42, More(42, More(42, Empty))), More(43, More(43, More(43, Empty)))) : (List<Int>, List<Int>)
```
<!-- markdownlint-enable MD013 -->

The preceding case established the count: a completed `map` over a finite list
constructs one output `More` for every input `More`. The direct `map` here
preserves that source relationship in its nonempty equation,
`More(transform first, mapped_rest)`. After this `unfold` constructs three
`More` values, `map` constructs three additional `More` values. The [dynamic
application
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application)
evaluate a constructor's argument before allocating its payload constructor
cell. Together with the explicit recursive bindings, that rule supports the
construction order used in this account.

These are counts of constructor expressions completed by these definitions.
They do not determine exact heap bytes, elapsed time, host stack use, or a
compiler optimization. The example relies on strict evaluation throughout; it
introduces no lazy data, infinite data, or generic fold/build fusion interface.

## One state type throughout the unfold

The final entry supplies a Boolean where the selected transition requires a
`Natural` state:

<!-- source: src/04-wrong-seed.ash -->
```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = Lists.unfold (Lists.repeat_step 42) true
```

`Lists.repeat_step 42` has type
`Natural -> Step<Natural, Int>`. When it becomes the first argument to
`unfold`, the shared variables in
`(S -> Step<S, A>) -> S -> List<A>` fix `S` as `Natural` and `A` as `Int`.
The remaining seed argument must therefore be a `Natural`, not a `Bool`.
This follows from the [static function-application
rule](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#functions-and-application),
which synthesizes the function type and checks its argument against the
function domain.

Run the rejected entry:

<!-- diagnostic: src/04-wrong-seed.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en building-finite-lists/src/04-wrong-seed.ash
This function argument must have type `Natural`, but has type `Bool`.
  --> /path/to/ash-doc/content/cases/building-finite-lists/src/04-wrong-seed.ash:4:47
4 | main () = Lists.unfold (Lists.repeat_step 42) true
  |                                               ^ This has type `Bool`.
  --> /path/to/ash-doc/content/cases/building-finite-lists/src/lists.ash:13:5
13 | pub unfold : (S -> Step<S, A>) -> S -> List<A>
   |     ^ This function requires an argument of type `Natural`.
  --> /path/to/ash-doc/content/cases/building-finite-lists/src/04-wrong-seed.ash:4:11
4 | main () = Lists.unfold (Lists.repeat_step 42) true
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The first label identifies the Boolean seed; the next relates its required
`Natural` type to `unfold`'s signature. The containing-application label keeps
that mismatch attached to the call. Replace `true` with `Lists.Zero` to
produce an empty list, or with a finite chain of `Lists.Next` forms to produce
that many copies of `42`. The seed then has the same state type that
`repeat_step` receives and returns.

## Practice: produce the decreasing states

Define this transition in a separate copy of the shared module:

```text
natural_step : Natural -> Step<Natural, Natural>
natural_step Zero = Stop
natural_step Next(rest) = Emit(Next(rest), rest)
```

Use ordinary `unfold` with seeds `Zero`, `Next(Zero)`, and the three-step state
from the first entry. Before running each complete program, predict every
emitted `Natural` and the final `List<Natural>` shape.

Explain why each transition follows a structurally smaller state. For a seed
with `n` `Next` forms, predict both the output length and the number of
transition applications. Then compare those counts with the repeated-integer
producer: which part depends on the transition's emitted value, and which part
depends only on how its state reaches `Stop`?

`unfold` carries only the current state forward. Some recursive algorithms
need to retain a result derived from earlier elements instead. The next case
asks when that knowledge belongs inside the recursive call and what work it
avoids.
