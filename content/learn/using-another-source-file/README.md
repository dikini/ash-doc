# How can one source file use another?

The programs in the first chapter kept every definition in one source file.
That kept each calculation in view as a whole. As a program grows, some
definitions begin to belong together: arithmetic functions form one group,
data-handling functions another, and `main` connects them for the result we
want.

Ash lets us place such a group in its own source file. One file can then name
the other and use the definitions it makes available. The files do not become
separate programs. They are parts of one program, connected by an import.

Create a directory for this program. Inside it, create two files:

```text
calculation/
|-- arithmetic.ash
`-- main.ash
```

Begin with `arithmetic.ash`. It contains the calculation that will produce our
answer:

<!-- source: src/arithmetic.ash -->
```ash
double : Int -> Int
double number = number * 2

pub answer : Unit -> Int
answer () = double 21
```

Both definitions work as they did in the first chapter. `double` takes an
integer and doubles it. `answer` calls `double`. The new word
is `pub`, short for *public*. It says that another source file may use
`answer`.

Now put this program in `main.ash`:

<!-- source: src/01-main.ash -->
```ash
import arithmetic as Arithmetic

main : Unit -> Int
main () = Arithmetic.answer ()
```

The first line connects the files. `arithmetic` names `arithmetic.ash` in the
same directory; an import path leaves off the `.ash` extension. The name after
`as` is the alias used in this file. We chose `Arithmetic`, so the call writes
`Arithmetic.answer`.

Follow the qualified call into `arithmetic.ash`, then use its definition of
`double` to predict the result. Run the entry file from `calculation`:

```text
ash main.ash
```

Ash follows the import, checks both files, and reports:

```text
42 : Int
```

We can follow the same path by hand. `main` calls `Arithmetic.answer ()`.
`answer` calls `double 21`, and that expression produces `42`:

```text
Arithmetic.answer ()
double 21
21 * 2
42
```

Each Ash source file forms a *module*. The import gives the entry module a name
for the imported module, and the qualified name `Arithmetic.answer` identifies
one public definition in it. The alias belongs to `main.ash`; it is the name
this file chose for that import.

## What remains inside a module?

Only `answer` carries `pub`. The helper `double` has no such marker. It is
available throughout `arithmetic.ash`, which is why `answer` can call it, but
it is not available through the import.

We can test that boundary by changing `main.ash` to call the helper directly:

<!-- source: src/02-private-main.ash -->
```ash
import arithmetic as Arithmetic

main : Unit -> Int
main () = Arithmetic.double 21
```

Compare the requested name with the declarations carrying `pub`. Does this
import make that call available? Run the saved version from `content/learn`:

<!-- diagnostic: src/02-private-main.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en using-another-source-file/src/02-private-main.ash
The declaration `double` is private to its defining module.
  --> /path/to/ash-doc/content/learn/using-another-source-file/src/02-private-main.ash:4:22
4 | main () = Arithmetic.double 21
  |                      ^ This name is not accessible here.
  --> /path/to/ash-doc/content/learn/using-another-source-file/src/arithmetic.ash:1:1
1 | double : Int -> Int
  | ^ The inaccessible declaration is here.
reason: resolve.unavailable-export
```
<!-- markdownlint-enable MD013 -->

The message names `double` as private. Its first label marks the inaccessible
member in the call; the second takes us to `double`'s declaration in
`arithmetic.ash`, where there is no `pub`. The import succeeded, but it did not
make that helper public. Restore `Arithmetic.answer ()` to use the module's
public calculation. Make public the definitions another module needs and
leave supporting calculations inside their own module. The
[visibility rules][visibility] preserve that distinction across an import.

> **With a learning assistant:** If an imported name is rejected, show the
> assistant both source files and the complete diagnostic. Ask it to connect
> the message and labels to the import, alias, declaration, and call before it suggests
> a change.

## Exercise: move `square`

Make a new two-file program in a fresh scratch directory, with
`arithmetic.ash` and `main.ash` beside each other:

1. In `arithmetic.ash`, define a public function `square : Int -> Int` that
   multiplies its input by itself.
2. In `main.ash`, import the file as `Arithmetic`.
3. Make `main` call `Arithmetic.square 6`.
4. Predict the value and type, then run `ash main.ash`.
5. Remove `pub` from `square`, run the program once more, and explain the
   change in terms of the two modules.

## One program, two files

An Ash program begins with the source file passed to `ash`. An import connects
that entry module to another module. The importing file gives the module an
alias, and a qualified name uses that alias to reach one of the module's public
definitions. Definitions without `pub` remain available inside their own
module.

Our functions still take one input each. The next chapter asks what the arrows
and calls mean when a function needs more than one input.

[visibility]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/name-resolution.md#public-private-and-opaque-declarations
