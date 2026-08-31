# How can a calculation name an intermediate value?

A short expression often tells its own story. We can read `double (increment
20)` from the inside out and keep the intermediate value in mind. As more steps
join the calculation, that silent value becomes easier to lose. A name can
record what a step produced and give the next step something clear to use.

Ash uses a *block* when an expression needs such local names. The block still
produces one value, just as the smaller expressions in earlier lessons did.
The difference is that it lets us describe the route to that value in several
ordered steps.

## Naming one result

Begin by naming the result of an addition:

<!-- source: src/01-one-name.ash -->
```ash
main : Unit -> Int
main () = {
    let answer = 40 + 2
    answer
}
```

The braces surround a block. Its first line is a `let` binding:

```text
let answer = 40 + 2
```

Ash evaluates the expression on the right and associates the resulting value
with the name on the left. Within the rest of this block, `answer` stands for
`42`.

The last line is different. It is the expression whose value becomes the value
of the whole block. We can trace the block without keeping the addition in our
heads:

```text
let answer = 40 + 2   -- answer stands for 42
answer                -- the block produces 42
```

Run the program. The block produces `42`, so `main` produces `42 : Int`.

## Letting one step use another

A block becomes more useful when a later binding uses a value named earlier:

<!-- source: src/02-several-names.ash -->
```ash
main : Unit -> Int
main () = {
    let incremented = 20 + 1
    let doubled = incremented * 2
    doubled
}
```

Read the bindings from top to bottom. The first binding associates
`incremented` with `21`. When Ash reaches `doubled`, that earlier name is
already available:

```text
incremented = 20 + 1 = 21
doubled     = 21 * 2 = 42
```

The final expression is `doubled`, so the block produces `42`. Running the
program checks the entire chain.

These names belong to the block. They help explain this calculation without
adding definitions that the rest of the source file can call. A useful local
name describes the value's part in the calculation: `incremented` says more
than `x`, even though both names could refer to the same integer.

## Names appear in order

The order of the bindings matters. A later binding can use an earlier name,
but an earlier binding cannot reach forward to a name that has not appeared:

<!-- source: src/03-forward-reference.ash -->
```ash
main : Unit -> Int
main () = {
    let answer = later + 2
    let later = 40
    answer
}
```

When Ash checks `later + 2`, no binding for `later` is in reach. The following
line cannot supply a name backward in the source. Ash rejects the program with
a message beginning:

```text
resolve.unknown-name
```

Move `let later = 40` above the binding for `answer`, then run the program
again. The revised order mirrors the dependency: first obtain `later`, then use
it to obtain `answer`.

## Exercise: expose the hidden steps

Rewrite this nested expression as a block:

```text
main : Unit -> Int
main () = double (increment 20)
```

Start from the
[first lesson's program](../what-is-an-ash-program/README.md#giving-a-calculation-a-name),
and keep its existing `increment` and `double` definitions. In the block:

1. name the result of `increment 20`;
2. name the result of doubling that value; and
3. use the second name as the block's final expression.

Predict the value after each binding, then run the program. The rewritten
calculation should still produce `42 : Int`.

## A calculation with visible steps

A block is an expression that can introduce local names before producing its
final value. Each `let` binding makes its name available to the lines that
follow, so source order should follow the flow of the calculation. The last
expression determines what leaves the block.

One name can stand for one value. Sometimes two or more values belong to the
same step and should travel together. The next lesson introduces a value that
keeps such parts side by side.
