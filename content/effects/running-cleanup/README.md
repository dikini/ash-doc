# How can work run when a scope finishes?

A calculation may need to record that a scope has finished, even when a
handler stops its body early. `cleanup action { body }` gives the scope one
obligation: invoke the retained action when closing it. The action is an
ordinary function from `Unit` to `Unit`; the obligation belongs to the scope.

We will use a live cell as a log. Appending digit one means multiplying its
current value by ten and adding one. This makes action order visible without
introducing external output operations.

## Preserve the body result, then observe the action

`01-normal-completion.ash` writes nine in its body and appends one on closing:

<!-- source: src/01-normal-completion.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let append_one : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 1)
    }
    let result = cleanup append_one {
        let ignored = Cell.write (log, 9)
        42
    }
    (result, Cell.read log)
}
```

The body finishes with `42`. Before the cleanup expression returns that saved
value, it invokes `append_one`. The log changes from `9` to `91`; the body
result remains `42`. Run it from this lesson's `src` directory:

```text
$ ash 01-normal-completion.ash
(42, 91) : (Int, Int)
```

The cell owner surrounds the cleanup and the final read, so the action has
live access when it runs. Its function type records that access's operation
row. Cleanup does not require its action to be pure.

## Close inner scopes before outer scopes

`02-nested-cleanup.ash` gives each scope a different closing action:

<!-- source: src/02-nested-cleanup.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let append_one : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 1)
    }
    let append_two : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 2)
    }
    let result = cleanup append_one {
        cleanup append_two {
            42
        }
    }
    (result, Cell.read log)
}
```

The inner body produces `42`. Its action appends `2` before the outer body can
finish. The outer action then appends `1`, producing a log of `21`:

```text
$ ash 02-nested-cleanup.ash
(42, 21) : (Int, Int)
```

Neither action changes the saved result. Copying an action function would
copy an ordinary callable value, not the scope's obligation to invoke it.

## Close owned scopes when their body is abandoned

E6 used discard to skip a list calculation's remaining work.
`03-discard-cleanup.ash` places two cleanup scopes in the waiting computation:

<!-- source: src/03-discard-cleanup.ash -->
```ash
import @builtin.cell as Cell

effect Stop {
    now : Unit -> Unit
}

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let append_one : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 1)
    }
    let append_two : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 2)
    }
    let result = handle (cleanup append_one {
        cleanup append_two {
            let ignored = perform Stop.now ()
            let ignored = Cell.write (log, 999)
            42
        }
    }) with Stop {
        now ignored => {
            let ignored = discard
            7
        }
    }
    (result, Cell.read log)
}
```

The stop request selects the outer clause. Its discard owns the captured
cleanup scopes and invokes their actions while closing that abandoned work.
The inner action appends `2`, then the outer appends `1`. The later write of
`999` and the body result `42` are skipped. After closing, the clause returns
`7`:

```text
$ ash 03-discard-cleanup.ash
(7, 21) : (Int, Int)
```

The log cell remains live outside the handler. Cleanup can use it before its
own resource scope eventually releases it. Here discard itself has effects
because it invokes actions that write the cell. It is not universally pure.

## Do not restore a handler that abandonment removes

Cleanup actions can request source effects too. Their requests must be valid
in the context available at closing. `04-removed-handler.ash` surrounds an
action with a `Report` handler that the stop operation would abandon:

<!-- source: src/04-removed-handler.ash -->
```ash
effect Stop {
    now : Unit -> Unit
}

effect Report {
    closed : Int -> Unit
}

report_close : Unit -> Unit ! {Report}
report_close ignored = perform Report.closed 1

main : Unit -> Int
main () = handle {
    let ignored = perform Report.closed 0
    handle {
        handle (cleanup report_close {
            let ignored = perform Stop.now ()
            42
        }) with Report {
            closed value => resume ()
        }
    } with Stop {
        now ignored => {
            let ignored = discard
            7
        }
    }
} with Report {
    closed value => resume ()
}
```

There is also an outer `Report` handler, used by the initial report. It cannot
silently replace the nearer handler that governs `report_close` at its closing
position. Abandonment would remove that nearer handler:

<!-- diagnostic: src/04-removed-handler.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-removed-handler.ash
Discard would remove a handler that this cleanup action still needs.
  --> /path/to/ash-doc/content/effects/running-cleanup/src/04-removed-handler.ash:24:27
24 |             let ignored = discard
   |                           ^ Discard would remove a handler that this cleanup action still needs.
  --> /path/to/ash-doc/content/effects/running-cleanup/src/04-removed-handler.ash:16:16
16 |         handle (cleanup report_close {
   |                ^ This cleanup action requires the handler.
17 |             let ignored = perform Stop.now ()
   | ^ This cleanup action requires the handler.
18 |             42
   | ^ This cleanup action requires the handler.
19 |         }) with Report {
   | ^ This cleanup action requires the handler.
  --> /path/to/ash-doc/content/effects/running-cleanup/src/04-removed-handler.ash:16:9
16 |         handle (cleanup report_close {
   |         ^ Discard would abandon this handler.
17 |             let ignored = perform Stop.now ()
   | ^ Discard would abandon this handler.
18 |             42
   | ^ Discard would abandon this handler.
19 |         }) with Report {
   | ^ Discard would abandon this handler.
20 |             closed value => resume ()
   | ^ Discard would abandon this handler.
21 |         }
   | ^ Discard would abandon this handler.
reason: effect.cleanup-context
```
<!-- markdownlint-enable MD013 -->

The labels connect discard, the action requiring interpretation, and the
handler that would be removed. Cleanup does not restore captured source
handlers merely to run an abandoned action.

In `05-surviving-handler.ash`, the handler needed by the action surrounds the
stop handler and remains available during discard:

<!-- source: src/05-surviving-handler.ash -->
```ash
import @builtin.cell as Cell

effect Stop {
    now : Unit -> Unit
}

effect Report {
    closed : Int -> Unit
}

report_close : Unit -> Unit ! {Report}
report_close ignored = perform Report.closed 1

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let result = handle {
        handle (cleanup report_close {
            let ignored = perform Stop.now ()
            42
        }) with Stop {
            now ignored => {
                let ignored = discard
                7
            }
        }
    } with Report {
        closed value => {
            let ignored = Cell.write (log, value)
            resume ()
        }
    }
    (result, Cell.read log)
}
```

The action reports `1`; the surviving handler writes that value to the log and
resumes the closing action. The stop clause can then return `7`:

```text
$ ash 05-surviving-handler.ash
(7, 1) : (Int, Int)
```

Another way to give an action its interpretation is to place the needed
handler inside the action itself. A handler placed only in the body's interior
does not automatically cover an action that runs after that body has finished.
The [cleanup rules][cleanup] define these closing-position checks.

## An action already running must finish

Starting an action does not erase its remaining obligation. In
`06-running-action.ash`, the action itself makes the stop request:

<!-- source: src/06-running-action.ash -->
```ash
effect Stop {
    now : Unit -> Unit
}

stop_while_closing : Unit -> Unit ! {Stop}
stop_while_closing ignored = perform Stop.now ()

main : Unit -> Int
main () = handle (cleanup stop_while_closing {
    42
}) with Stop {
    now ignored => {
        let ignored = discard
        7
    }
}
```
<!-- diagnostic: src/06-running-action.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-running-action.ash
This discard would skip a cleanup action that must complete.
  --> /path/to/ash-doc/content/effects/running-cleanup/src/06-running-action.ash:13:23
13 |         let ignored = discard
   |                       ^ This discard would skip a cleanup action that must complete.
  --> /path/to/ash-doc/content/effects/running-cleanup/src/06-running-action.ash:6:30
6 | stop_while_closing ignored = perform Stop.now ()
  |                              ^ This request or call can capture the continuation.
  --> /path/to/ash-doc/content/effects/running-cleanup/src/06-running-action.ash:9:18
9 | main () = handle (cleanup stop_while_closing {
  |                  ^ This cleanup action must complete.
10 |     42
   | ^ This cleanup action must complete.
11 | }) with Stop {
   | ^ This cleanup action must complete.
reason: effect.discard-unsafe
```
<!-- markdownlint-enable MD013 -->

Discard would skip the rest of the action and its unfinished close operation.
The labels identify that required completion and the request that captures
it. Use `resume ()` in the stop clause to let the action finish. Resumption
continues that invocation; it does not start the cleanup action again.

These rules govern normal completion and checked abandonment. They do not
promise source cleanup after internal termination or exhaustion, and they do
not prove that a diverging action eventually returns.

## Practice: predict closing order

1. Exchange the two actions in `02-nested-cleanup.ash`. Predict the log before
   running the program.
2. Change the body result in `01-normal-completion.ash`. Explain which tuple
   field changes and which action still runs.
3. In `03-discard-cleanup.ash`, replace the stop clause with `resume ()`.
   Trace the body write, inner action, and outer action in order before running.

A cleanup scope retains one action and owns its invocation. Normal return
preserves the body's value; abandonment closes the owned scopes before the
clause continues. Both paths must respect the resources and handlers available
at closing. Next we will use scoped handlers to transform publications through
several registered functions.

[cleanup]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#scoped-cleanup-actions
