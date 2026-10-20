# How can a calculation name an intermediate value?

A short expression often tells its own story. We can read `double (increment
20)` from the inside out and keep the intermediate value in mind. As more steps
join the calculation, that silent value becomes easier to lose. A name can
record what a step produced and give the next step something clear to use.

Ash uses a *block* when an expression needs such local names. The
[multiple-inputs lesson](../using-more-than-one-input/README.md#pausing-after-the-first-input)
already used one to group a program's lines. The block still produces one
value, just as the smaller expressions in earlier lessons did.
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
with the name on the left. That name is available in the rest of the block.

The last line is different. It is the expression whose value becomes the value
of the whole block. Predict the value bound to `answer` and the value returned
by the final expression, then run the program. Ash reports `42 : Int`.
Trace how that result follows:

```text
let answer = 40 + 2   -- answer stands for 42
answer                -- the block produces 42
```

The addition binds `42` to `answer`; the final expression uses that value.
A binding names the intermediate result, while the final expression determines
what the block returns.

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

Read the bindings from top to bottom. Predict each named value and the final
result before running. Ash reports `42 : Int`; the later initializer uses the
value produced by the earlier one:

```text
incremented = 20 + 1 = 21
doubled     = 21 * 2 = 42
```

The first binding produces `21`, the next produces `42`, and the final
expression returns `doubled`. The [binding rules][bindings] explain how each
initializer runs before its new names become available to the remainder.

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

At the initializer `later + 2`, which names have already been introduced?
Run this version from `content/learn` to check your account:

<!-- diagnostic: src/03-forward-reference.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en naming-intermediate-values/src/03-forward-reference.ash
No term named `later` is in scope.
  --> /path/to/ash-doc/content/learn/naming-intermediate-values/src/03-forward-reference.ash:3:18
3 |     let answer = later + 2
  |                  ^ This name could not be resolved here.
reason: resolve.unknown-name
```
<!-- markdownlint-enable MD013 -->

The message names `later` and labels its use in `answer`'s initializer. It is
that use, before the binding, that cannot be resolved.

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
[first lesson's composition program](../what-is-an-ash-program/README.md#giving-a-calculation-a-name):
make a fresh scratch copy of its `src/06-composition.ash`. Keep the existing
`increment` and `double` definitions. In the block:

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

[bindings]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#bindings
