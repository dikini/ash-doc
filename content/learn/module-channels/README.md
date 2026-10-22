# Module channels

Early in this path, the module lesson connected two source files with one
channel: a complete import placed every public name of `arithmetic.ash` under
the alias `Arithmetic`. That client wanted one name and accepted the whole
namespace to get it. A module boundary usually offers more than one public
name, though, and a client rarely wants all of them, qualified or not. This
lesson narrows what crosses the boundary in two directions: importing
selected names into a file, and re-exporting selected names through another
module.

## Importing one name

The earlier program still serves. Create a fresh directory for this program
with the same two files:

```text
channels/
|-- arithmetic.ash
`-- main.ash
```

`arithmetic.ash` holds the module from that lesson, unchanged:

<!-- source: src/arithmetic.ash -->
```ash
double : Int -> Int
double number = number * 2

pub answer : Unit -> Int
answer () = double 21
```

`answer` is public; the helper `double` stays inside the module. This time
the entry names the one spelling it wants, in a parenthesized list:

<!-- source: src/01-main.ash -->
```ash
import arithmetic (answer)

main : Unit -> Int
main () = answer ()
```

This is a *targeted import*. Where the complete import bound the whole public
namespace under one alias, the targeted import places only the selected public
spellings in this file's file-wide namespaces. The call therefore writes
`answer ()` with no qualifier. Nothing else in `arithmetic.ash` becomes
nameable here, not even under an alias.

Each item in the list may take its own alias. Writing
`import arithmetic (answer as total)` brings the same definition in under
the name `total`, so the call becomes `total ()`. The alias changes only
this file's spelling; the definition followed is still `answer` in
`arithmetic.ash`.

Follow `answer` into its module as before and predict the value and type of
`main ()`. Run the entry from `channels`:

```text
ash main.ash
```

Ash follows the import, checks both files, and reports:

```text
42 : Int
```

## The boundary answers at the import

The earlier module lesson tested this boundary at a call:
`Arithmetic.double` was refused because `double` is private. Naming the
helper in the import list tests the same boundary at the channel itself:

<!-- source: src/02-private-import.ash -->
```ash
import arithmetic (double)

main : Unit -> Int
main () = double 21
```

Predict first: does naming `double` in the list make it cross? Run the saved
version from `content/learn`:

<!-- diagnostic: src/02-private-import.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en module-channels/src/02-private-import.ash
The declaration `double` is private to its defining module.
  --> /path/to/ash-doc/content/learn/module-channels/src/02-private-import.ash:1:20
1 | import arithmetic (double)
  |                    ^ This name is not accessible here.
  --> /path/to/ash-doc/content/learn/module-channels/src/arithmetic.ash:1:1
1 | double : Int -> Int
  | ^ The inaccessible declaration is here.
reason: resolve.unavailable-export
```
<!-- markdownlint-enable MD013 -->

The words match the rejection the earlier lesson produced for a private
call, and the reason is the same, `resolve.unavailable-export`. What changed
is where the label lands: on the import item itself. Naming a private
spelling refuses the import, so this file has no `double` at all. The second
label still leads to `arithmetic.ash`, to the declaration with no `pub`. A
targeted import selects from public spellings only; the
[import rules][import-rules] define what the list may name.

> **With a learning assistant:** Show the assistant both source files and the
> complete diagnostic. Ask it to point to the exact spelling the import
> selected, to the label that refused it, and to explain why the second label
> lands in `arithmetic.ash` before suggesting any change.

## Re-exporting selected names

A module can also widen what its own clients receive. Add a third file,
`reporting.ash`, beside the other two:

<!-- source: src/reporting.ash -->
```ash
pub import arithmetic (answer)

pub report : Unit -> Int
report () = answer () + 1
```

Two things happen on the first line. `pub import` is a targeted import with
`pub` in front, so inside this file `answer` is usable unqualified, exactly
as a private targeted import would allow. The `pub` also places the selected
spelling in this module's own public summary: a client that imports
`reporting` receives `answer` with it. A public import must be targeted — it
has no complete `as` form — and it re-exports exactly the names it selects,
nothing more.

Such a module is an ordinary module to its clients, one that passes selected
names through — a facade. The client below imports the facade and reaches
`answer` through it:

<!-- source: src/03-facade-main.ash -->
```ash
import reporting (report, answer)

main : Unit -> Int
main () = report () + answer ()
```

Predict the sum from the two definitions: `report ()` follows the
re-exported `answer` and adds one. Run the entry from `channels`:

```text
ash main.ash
```

Both spellings crossed, and the entry reports:

```text
85 : Int
```

A complete alias import of the facade — `import reporting as Reporting` —
would reach `Reporting.report` and the re-exported `Reporting.answer`,
because both are public spellings of `reporting`. It would still not reach
`Reporting.double`: that helper never left `arithmetic.ash`. And the alias
would belong to the importing file alone, exactly as the alias did in the
earlier module lesson.

## Exercise: one facade, two modules

Build a scratch program with two small modules side by side: `scores.ash`
offering a public `top` and a private helper, and `limits.ash` offering a
public `maximum` and a private helper. Add a facade module that re-exports
`top` from `scores` and `maximum` from `limits`, renaming one of them with
its own `as` clause as it passes through, and keeps both helpers hidden.

1. Write the three modules and an entry that imports the facade targeted,
   then predict the entry's value and type and run it.
2. Predict which names a complete alias import of the facade would give a
   client: write each `Facade.` spelling you expect to reach, and each one
   you expect to be refused.
3. Verify the prediction with a client that imports the facade as `Facade`
   and calls every spelling you listed.

## What crosses, and under whose name

Three channels are now known. A complete import places every public name of
a module under an alias. A targeted import places selected public spellings
in the file-wide namespaces, each renamable with `as`. A public import
re-exports its selected spellings to its own clients. The boundary question
is always the same: which public spellings cross, and under whose name?

One more channel exists at this checkpoint: an import item can carry
implementation evidence for an interface instead of a name. The libraries
path develops it; the name-only channels are what ordinary clients need.

The next lesson turns the boundary around once more: how can a module keep a
type nameable while hiding how its values are built?

[import-rules]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#imports-and-namespaces
