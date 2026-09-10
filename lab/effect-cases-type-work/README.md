# Effect Cases exhaust type-checking work

**State: upstream regression candidate; four Cases blocked.** This is current
baseline evidence, not a new language rule. Ash target: `diag-ash` at
`57eec5bbadae885e49c323e0a05e7a01b9ce8a36`. Build the clean checkout with
`cargo build --locked` as described in the [repository setup](../../README.md#prepare-ash).

The reader task is to combine recursive algorithms with handlers and scoped
state. Small programs for leaf numbering, comparison counting, bounded search,
and parent-path compression fail before producing their intended observations.
The examples are original concept illustrations, with no adapted external text
or code. Other new Cases using sessions and byte decoding pass at this baseline.

## Reproduce the reduced boundary

From this case directory, run:

```text
ash --message-format human --locale en src/minimal.ash
```

<!-- source: src/minimal.ash -->
```ash
import @builtin.cell as Cell

effect Ask {
    value : Unit -> Int
}

request : Int -> Int ! {Ask}
request value = match value == 0 {
    true => perform Ask.value ()
    false => {
        let left = request 0
        let right = request 0
        left + right
    }
}

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    handle (request 0) with Ask {
        value () => resume 0
    }
}
```

The command exits with status `2`, leaves stdout empty, and prints this complete
stderr. It supplies no source location or causal labels:

```text
The compiler ran out of resources for type checking and type construction.
reason: internal.resource.type-work
```

The intended result is `0 : Int`. `request 0` takes the base branch immediately;
the failing branch would also terminate because both recursive calls receive
zero. The failure therefore precedes runtime recursion. The cell is deliberately
unused in this reduction: merely keeping its acquisition distinguishes this
program from the passing control. This does not mean unused cells are the cause.

## Passing controls and affected drafts

- [Without the resource](src/without-resource.ash) changes only the acquisition
  into an ordinary block and produces `0 : Int`.
- [One recursive call](src/one-recursive-call.ash) retains the acquisition but
  replaces the second recursive call with zero; it also produces `0 : Int`.

Both controls require status zero and empty stderr. The combination of scoped
acquisition and multiple recursive call sites is enough for this reduction.
This isolates a useful investigation boundary, not the internal cause or a
proof that all four drafts have the same defect.

The full draft programs retain the approved teaching outcomes:

- [Number tree leaves](drafts/numbering-tree-leaves/README.md).
- [Measure tree search](drafts/measuring-tree-search/README.md).
- [Bound search work](drafts/bounding-search-work/README.md).
- [Compress parent paths](drafts/compressing-parent-paths/README.md).

Each currently exits with status `2`, empty stdout, and the same complete
message. Their expected output files under `checks/` are derived acceptance
criteria for an upstream repair, **not captured successful observations**.
They remain outside the active content navigation.

The [effects contract][effects] admits complete handlers that resume once.
The [cell scope rules][cells] admit scoped reads and writes and returning copied
integers or resource-independent data. [Native buffers][buffers] admit checked
reads and writes with separate acquisition outcomes. These programs intend to
keep every handle within its owner. The [tool guide][tool] distinguishes status
`2` internal exhaustion from ordinary source rejection. Bounded compiler work
is legitimate; whether this small combination charges or repeats work
incorrectly is the upstream investigation. No historical compiler comparison
or claim about the introducing commit is made.

## Verify and hand off

From ash-doc:

```text
bash lab/effect-cases-type-work/checks/verify.sh /path/to/diag-ash
```

The check pins the clean compiler, verifies both passing controls, all five
current failures, their complete human stderr, and displayed-source agreement.
The [upstream-agent prompt](upstream-agent.md) requests diagnosis and retained
regression coverage without prescribing a compiler implementation change.

After an upstream repair and an authorized baseline update, require the
unchanged draft programs to produce their derived outputs. Finish each lesson
and its ordinary verifier, restore their planned reading order, then remove
this case, its controls, expected files, handoff, and obsolete plan material.
Keep the current baseline until that migration is authorized. Git retains
superseded evidence.

[effects]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#effects
[cells]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[buffers]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#scoped-native-buffers
[tool]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/docs/tools/ash.md#failures
