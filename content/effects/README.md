# Working with effects and scoped resources

A function can request behavior that a surrounding handler supplies. This path
begins with that exchange, then develops how a program describes its effects
and keeps control and resource access within their scopes.

Finish [Learn Ash](../learn/README.md) first. The opening lesson uses its
functions, signatures, values, and pattern bindings; it needs no library or
algorithm Case as a prerequisite.

Use the `ash` command from the repository's [shared setup](../../README.md#prepare-ash).
Each lesson keeps complete programs in its `src` directory. Change into that
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
