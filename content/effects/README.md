# Working with effects and scoped resources

A function can request behavior that a surrounding handler supplies. This path
begins with that exchange, then develops how a program describes its effects
and keeps control and resource access within their scopes.

Finish [Learn Ash](../learn/README.md) first. The opening lesson uses its
functions, signatures, values, and pattern bindings; it needs no library or
algorithm Case as a prerequisite.

Use the `ash` command from the repository's [shared setup](../../README.md#prepare-ash).
The buffer chapter builds native executables; earlier chapters use ordinary
`ash` execution. Each lesson keeps complete programs in its `src` directory.
Change into that
directory before running the commands shown in the lesson. For the first one:

```text
cd /path/to/ash-doc/content/effects/requesting-a-value/src
```

Read the calculation, predict its result, and run it. When the result differs
from your prediction, follow the request and the answer before changing the
program. The [diagnostic reading notes](../../README.md#read-a-diagnostic)
explain the command prompt, English messages, and displayed source paths.

## Lessons in order

1. [How can a calculation request a value from its caller's context?](requesting-a-value/README.md)
   — declare an effect, read a closed effect row, request a value, and supply
   it through a handler.
2. [What does an effectful function promise?](following-effect-contracts/README.md)
   — follow effects through calls and distinguish requesting now from
   returning a function that requests later.
3. [How can a reusable function preserve its caller's effects?](preserving-callback-effects/README.md)
   — give a callback's effect row a parameter and explain known effects beside
   an open tail.
4. [Which handler answers a request?](choosing-a-handler/README.md)
   — trace nested handlers, exact effect instances, and later closure calls.
5. [What happens when a handler resumes a calculation?](resuming-a-calculation/README.md)
   — separate operation answers from results and consume continuations once.
6. [How can a handler stop a calculation early?](stopping-a-calculation/README.md)
   — compare pure outcomes, resumption, and discard on a finite list.
7. [How can a calculation keep scoped mutable state?](counting-with-a-cell/README.md)
   — use acquired cell access and compare it with a pure accumulator.
8. [Why can a result leave a resource scope while access cannot?](keeping-access-in-scope/README.md)
   — follow dependencies through handles, closures, tuples, and requests.
9. [How can work run when a scope finishes?](running-cleanup/README.md)
   — trace cleanup on normal completion and checked abandonment.
10. [How can several scopes transform one publication?](transforming-publications/README.md)
   — use hook roots and registrations with checked callback lifetimes.
11. [How can acquiring a resource fail?](acquiring-a-buffer/README.md)
   — distinguish acquisition outcomes from checked buffer operations.
12. [How do these boundaries fit together?](combining-effects-and-scopes/README.md)
   — combine policy, state, early stopping, and cleanup in one calculation.

Before the scoped-cell chapter, read the existing
[implementation-evidence lesson](../libraries/choosing-implementation-evidence/README.md).
It supplies the interface vocabulary used by resource providers. The effects
chapters otherwise follow in order and introduce the concepts each later
chapter needs.
