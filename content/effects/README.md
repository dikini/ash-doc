# Working with effects and scoped resources

A function can request behavior that a surrounding handler supplies. This path
begins with that exchange, then develops how a program describes its effects
and keeps control and resource access within their scopes.

Finish [Learn Ash](../learn/README.md) first. The opening lesson uses its
functions, signatures, values, and pattern bindings; it needs no library or
algorithm Case as a prerequisite. The lessons are written for readers growing
from beginner toward intermediate.

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

1. [Requesting a value](requesting-a-value/README.md)
   — declare an effect, read a closed effect row, request a value, and supply
   it through a handler.
2. [Following effect contracts](following-effect-contracts/README.md)
   — follow effects through calls and distinguish requesting now from
   returning a function that requests later.
3. [Preserving callback effects](preserving-callback-effects/README.md)
   — give a callback's effect row a parameter and explain known effects beside
   an open tail.
4. [Which handler answers a request?](choosing-a-handler/README.md)
   — trace nested handlers, exact effect instances, and later closure calls.
5. [Resuming a calculation](resuming-a-calculation/README.md)
   — separate operation answers from results and consume continuations once.
6. [Stopping a calculation](stopping-a-calculation/README.md)
   — compare pure outcomes, resumption, and discard on a finite list.
7. [Counting with a cell](counting-with-a-cell/README.md)
   — use acquired cell access and compare it with a pure accumulator.
8. [Why can a result leave a resource scope while access cannot?](keeping-access-in-scope/README.md)
   — follow dependencies through handles, closures, tuples, and requests.
9. [Running cleanup](running-cleanup/README.md)
   — trace cleanup on normal completion and checked abandonment.
10. [Transforming publications](transforming-publications/README.md)
   — use hook roots and registrations with checked callback lifetimes.
11. [Acquiring a buffer](acquiring-a-buffer/README.md)
   — distinguish acquisition outcomes from checked buffer operations.
12. [Combining effects and scopes](combining-effects-and-scopes/README.md)
   — combine policy, state, early stopping, and cleanup in one calculation.

Before the scoped-cell chapter, read the existing
[implementation-evidence lesson](../libraries/choosing-implementation-evidence/README.md).
It supplies the interface vocabulary used by resource providers. The effects
chapters otherwise follow in order and introduce the concepts each later
chapter needs.
