# Defining local recursion

Ordinary local bindings extend a block one step at a time. A later function
can use an earlier value, but a definition cannot normally use its own new
name or one introduced later. Recursive functions need a different scope:
all names in their group must be available together.

Giving names that scope also creates an initialization question. A function
body can wait until a later call. A data initializer that immediately tries
to use an unfinished value cannot make the same promise.

## Start with the preceding scope

In `01-sequential-bindings.ash`, `add_base` captures an already bound integer:

<!-- source: src/01-sequential-bindings.ash -->
```ash
main : Unit -> Int
main () = {
    let base = 40
    let add_base = fn(value) {
        base + value
    }
    add_base 2
}
```

`base` is in scope while the anonymous function is checked. Identify that
saved value separately from the later argument, then predict their sum.
Run from this lesson's `src` directory:

```text
$ ash 01-sequential-bindings.ash
42 : Int
```

The new name `add_base` enters scope after its initializer. This sequential
rule is the same one used throughout Learn.

## Name a local recursive calculation

`02-local-sum.ash` keeps a list traversal close to the value it uses:

<!-- source: src/02-local-sum.ash -->
```ash
type Scores = End
    | Item(Int, Scores)

main : Unit -> Int
main () = {
    let bonus = 1
    let rec sum : Scores -> Int = fn(values) {
        match values {
            End => 0
            Item(value, rest) => value + bonus + sum rest
        }
    }
    sum (Item(20, Item(20, End)))
}
```

`let rec` makes `sum` available in its own initializer and the rest of the
block. Its annotation is required: the recursive calls must already have a
contract while the body is checked. The body may also capture the preceding
`bonus` binding.

The initializer creates a function; it does not run the match yet. The call
after the group starts the traversal. Each `Item` contributes its score plus
one, then the recursive call follows `rest`. `End` contributes zero.
Predict the total, distinguishing the captured `bonus` from the score
supplied by each recursive argument:

```text
$ ash 02-local-sum.ash
42 : Int
```

Here termination follows from the finite input and the move to its smaller
rest. The `rec` keyword itself does not prove that a function stops.

Recursive annotations describe one type per member. They do not introduce
local type parameters or apply the preceding lesson's generalization rule.
An enclosing type parameter can still appear where it is already in scope.

## Put mutually dependent functions in one group

A recursive group can contain several members. Write `and` on a new line
for each member after the first:

<!-- source: src/03-mutual-functions.ash -->
```ash
type Count = Zero
    | Next(Count)

main : Unit -> (Bool, Bool)
main () = {
    let rec even : Count -> Bool = fn(count) {
        match count {
            Zero => true
            Next(rest) => odd rest
        }
    }
    and odd : Count -> Bool = fn(count) {
        match count {
            Zero => false
            Next(rest) => even rest
        }
    }
    let two = Next(Next(Zero))
    (even two, odd two)
}
```

`Count` represents a nonnegative count by repeated `Next` constructors.
`Zero` is even and not odd. Removing one `Next` reverses the question: evenness
of the whole asks for oddness of the rest, and oddness asks for evenness.

Both names enter scope before either initializer is checked. Both initializers
are anonymous functions, so their calls to the other member wait until the
functions are used. The `let two` binding begins the ordinary block remainder.
Predict both results by alternating the calls until they reach `Zero`:

```text
$ ash 03-mutual-functions.ash
(true, false) : (Bool, Bool)
```

Trace the first result as `even two`, then `odd (Next Zero)`, then `even Zero`.
The second trace ends at `odd Zero` instead. Each call still follows one smaller
finite count.

Two sequential `let` bindings do not provide this mutual scope:

<!-- source: src/04-sequential-forward.ash -->
```ash
type Count = Zero
    | Next(Count)

main : Unit -> (Bool, Bool)
main () = {
    let even : Count -> Bool = fn(count) {
        match count {
            Zero => true
            Next(rest) => odd rest
        }
    }
    let odd : Count -> Bool = fn(count) {
        match count {
            Zero => false
            Next(rest) => even rest
        }
    }
    let two = Next(Next(Zero))
    (even two, odd two)
}
```

At the initializer for `even`, which names have already entered scope?
Does delaying its call change which names its body can use?

<!-- diagnostic: src/04-sequential-forward.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-sequential-forward.ash
No term named `odd` is in scope.
  --> /path/to/ash-doc/content/learn/defining-local-recursion/src/04-sequential-forward.ash:9:27
9 |             Next(rest) => odd rest
  |                           ^ This name could not be resolved here.
reason: resolve.unknown-name
```
<!-- markdownlint-enable MD013 -->

The label marks `odd` inside the earlier function. That later binding is not
in scope there, even though execution would call `even` after both bindings.
Name scope is established from the source, not from a prediction about when
the function will run. Restore the `let rec` and `and` group from the preceding
program when the definitions depend on one another.

## Build a cycle without traversing it forever

Recursive groups can also tie together nominal data. This is a different use
of recursion from following a finite list. `05-guarded-cycle.ash` gives each
node a score and a next node, with no ending constructor:

<!-- source: src/05-guarded-cycle.ash -->
```ash
type Trail = Step(Int, Trail)

main : Unit -> (Int, Int)
main () = {
    let rec first : Trail = Step(20, second)
    and second : Trail = Step(22, first)
    match first {
        Step(left, rest) => match rest {
            Step(right, ignored) => (left, right)
        }
    }
}
```

The group reserves the two data locations, builds `Step(20, second)` and
`Step(22, first)`, and connects their recursive references. Each initializer
starts with a fully applied constructor of its declared nominal type. The
references are stored as fields rather than used to calculate their contents
during initialization.

The result follows exactly two `Step` patterns. Predict which stored node
supplies each returned integer, and whether that bounded observation needs
an ending constructor:

```text
$ ash 05-guarded-cycle.ash
(20, 22) : (Int, Int)
```

Following the next link after those two nodes would return to the first node.
The cycle is finite stored structure, but an unrestricted walk has no ending
case. The finite-list traversals in Learn and the Cases rely on reaching a
base constructor; that assumption does not hold here.

Constructor guarding is not general laziness. Initializers still evaluate
ordinary nonrecursive subexpressions. The special allowance is for retaining
recursive references through constructor or tuple construction, or delaying
them inside an anonymous function body. It does not make arbitrary unfinished
values available to computation.

## The initializer must provide its data shape

A bare self-reference does not construct a node:

<!-- source: src/06-unsafe-root.ash -->
```ash
type Trail = Step(Int, Trail)

main : Unit -> Int
main () = {
    let rec trail : Trail = trail
    0
}
```

Compare this initializer's outer form with the constructor-root requirement.
What node would it construct before trying to retain its own reference?

<!-- diagnostic: src/06-unsafe-root.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-unsafe-root.ash
This recursive data initializer must start with a fully applied constructor of its declared nominal type.
  --> /path/to/ash-doc/content/learn/defining-local-recursion/src/06-unsafe-root.ash:5:29
5 |     let rec trail : Trail = trail
  |                             ^ This recursive data initializer must start with a fully applied constructor of its declared nominal type.
  --> /path/to/ash-doc/content/learn/defining-local-recursion/src/06-unsafe-root.ash:5:5
5 |     let rec trail : Trail = trail
  |     ^ This declaration introduces the recursive group.
  --> /path/to/ash-doc/content/learn/defining-local-recursion/src/06-unsafe-root.ash:5:21
5 |     let rec trail : Trail = trail
  |                     ^ The recursive member's type is declared here.
reason: recursion.unsafe-root
```
<!-- markdownlint-enable MD013 -->

The message identifies the initializer, its recursive group, and its declared
nominal type. There is no constructor-rooted value to initialize. Write
`Step(42, trail)` to build a node that retains its own reference, or use an
ordinary nonrecursive binding when no cycle is needed. The unused result of
the group does not make unsafe initialization acceptable.

A constructor root is necessary, but references beneath it must be guarded too:

<!-- source: src/07-forced-reference.ash -->
```ash
type Trail = Step(Int, Trail)

keep : Trail -> Trail
keep value = value

main : Unit -> Int
main () = {
    let rec trail : Trail = Step(42, keep trail)
    0
}
```

The outer constructor is present. Follow the recursive occurrence beneath
it: is the reference stored directly, or passed through a calculation that
initialization checking does not allow?

<!-- diagnostic: src/07-forced-reference.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 07-forced-reference.ash
This recursive value cannot be passed through this expression during initialization.
  --> /path/to/ash-doc/content/learn/defining-local-recursion/src/07-forced-reference.ash:8:38
8 |     let rec trail : Trail = Step(42, keep trail)
  |                                      ^ This recursive value cannot be passed through this expression during initialization.
reason: recursion.unguarded-use
```
<!-- markdownlint-enable MD013 -->

`keep` is an ordinary call. Passing the unfinished `trail` through it crosses
a form that initialization checking does not permit. Returning the argument
unchanged does not make the call a constructor. Replace `keep trail` with the
direct field `trail` to retain the reference without calling a function on it.

The [recursive-group rules][groups] define both checks; the
[execution rules][execution] explain reservation and initialization of the
recursive data locations. Neither rule authorizes arbitrary recursive integers,
implicit delays, or a promise that later traversals terminate.

## Practice: separate construction from use

For each task, make a fresh copy of its named program in a scratch directory
outside this lesson's `src` tree. Run the copy from that directory.

1. Change `bonus` and the input list in `02-local-sum.ash`. Trace which values
   come from capture and which come from each recursive argument.
2. Add one `Next` to `two` in `03-mutual-functions.ash`. Predict both results
   by tracing the alternating calls before running.
3. Start from `03-mutual-functions.ash` and exchange its two member
   declarations. Keep `let rec` on the first and `and` on the second.
   Explain whether scope changes.
4. Extend `05-guarded-cycle.ash` to observe exactly three scores. Predict which
   node supplies the third, and keep a fixed observation bound.

A recursive group provides simultaneous names with explicit contracts and
safe initialization. Functions delay their bodies until called; constructor
fields can retain guarded links. What happens after initialization still
depends on the program's calls and data. With this boundary understood, the
[effects](../../effects/README.md) and [library](../../libraries/README.md)
paths can build on local functions without assuming they are all polymorphic
or that every recursive structure is a finite list.

[groups]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#recursive-block-groups
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#recursive-bindings
