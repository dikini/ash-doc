# What happens when a handler resumes a calculation?

A request pauses some work. Its handler clause can supply the operation's
answer through `resume`, but that answer is not necessarily the value returned
by `resume` itself. Resuming runs the waiting calculation; when that work
finishes, its result comes back to the clause.

We will follow two requests in one calculation, then examine why the right to
resume cannot be ignored, reused, or saved in another function.

## Follow the waiting work

`Round` supplies an integer bonus and a Boolean choice. In
`01-resumed-result.ash`, the bonus clause does more work after resuming:

<!-- source: src/01-resumed-result.ash -->
```ash
effect Round {
    bonus : Unit -> Int
    enabled : Unit -> Bool
}

main : Unit -> Int
main () = handle {
    let bonus = perform Round.bonus ()
    let enabled = perform Round.enabled ()
    match enabled {
        true => 40 + bonus
        false => 0
    }
} with Round {
    bonus ignored => {
        let result = resume 2
        result + 100
    }
    enabled ignored => resume true
}
```

The first request needs an integer. `resume 2` supplies that integer, allowing
the body to bind `bonus` and continue to its next request. The `enabled` clause
then supplies `true`. The match computes `42`.

That `42` becomes the result of the bonus clause's `resume 2`. The clause binds
it to `result`, adds `100`, and returns `142` as the handler's result. Run the
file from this lesson's `src` directory:

```text
$ ash 01-resumed-result.ash
142 : Int
```

There are three values to distinguish. The bonus operation receives the
answer `2`; the suspended body produces `42`; the clause produces `142` after
its remaining work. For the other operation, `resume true` takes a Boolean
answer but returns an integer result. The operation signature controls the
answer supplied to `resume`. The handler's result contract controls the
resumed computation and the clause result.

Resumption continues after the request. It does not start the body again or
repeat work before that request. Handlers in the suspended segment are
restored as the work continues, which is why the later `enabled` request still
uses the `Round` handler.

## Cover the whole operation API

A handler supplies exactly one clause for every operation in its target API.
`02-missing-operation.ash` omits `enabled`, even though this particular body
only requests `bonus`:

<!-- source: src/02-missing-operation.ash -->
```ash
effect Round {
    bonus : Unit -> Int
    enabled : Unit -> Bool
}

main : Unit -> Int
main () = handle (perform Round.bonus ()) with Round {
    bonus ignored => resume 2
}
```
<!-- diagnostic: src/02-missing-operation.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-missing-operation.ash
This handler must contain exactly one clause for every operation of the handled effect.
  --> /path/to/ash-doc/content/effects/resuming-a-calculation/src/02-missing-operation.ash:7:11
7 | main () = handle (perform Round.bonus ()) with Round {
  |           ^ This handler must contain exactly one clause for every operation of the handled effect.
8 |     bonus ignored => resume 2
  | ^ This handler must contain exactly one clause for every operation of the handled effect.
9 | }
  | ^ This handler must contain exactly one clause for every operation of the handled effect.
reason: effect.handler-coverage
```
<!-- markdownlint-enable MD013 -->

The diagnostic labels the incomplete handler. Add an `enabled` clause that
resumes with a Boolean, as in `01-resumed-result.ash`. Coverage belongs to the
API, not just to operations reached by one chosen input.

## Consume the continuation once

The waiting work is the *continuation*. A selected clause receives the right
to consume it exactly once on every normally completing path. Returning an
ordinary integer does not consume it. `03-missing-resume.ash` demonstrates
that difference with a smaller API:

<!-- source: src/03-missing-resume.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle (perform Bonus.amount ()) with Bonus {
    amount ignored => 2
}
```
<!-- diagnostic: src/03-missing-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 03-missing-resume.ash
This path can finish without resuming or safely discarding the continuation.
  --> /path/to/ash-doc/content/effects/resuming-a-calculation/src/03-missing-resume.ash:7:23
7 |     amount ignored => 2
  |                       ^ This path can finish without resuming or safely discarding the continuation.
reason: effect.resume-not-consumed
```
<!-- markdownlint-enable MD013 -->

The label points at the clause that finishes while leaving its continuation
unused. Replace its `2` with `resume 2` to continue the waiting calculation.
The message also names safe discard, which the next lesson will introduce.

Once resumed, the same continuation cannot be used again. In
`04-repeated-resume.ash`, the first use has already consumed it:

<!-- source: src/04-repeated-resume.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle (perform Bonus.amount ()) with Bonus {
    amount ignored => {
        let result = resume 2
        resume result
    }
}
```
<!-- diagnostic: src/04-repeated-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-repeated-resume.ash
This path has already resumed or discarded the continuation; it cannot do so again.
  --> /path/to/ash-doc/content/effects/resuming-a-calculation/src/04-repeated-resume.ash:9:9
9 |         resume result
  |         ^ This path has already resumed or discarded the continuation; it cannot do so again.
reason: effect.resume-already-consumed
```
<!-- markdownlint-enable MD013 -->

The second `resume` is the error. Return `result` there instead; using an
ordinary returned integer does not require another resumption.

## A branch chooses one use

Exactly once is a rule about normally completing paths, not a count of the
word `resume` in the source. `06-branching-resume.ash` has one use in each
alternative:

<!-- source: src/06-branching-resume.ash -->
```ash
effect Round {
    bonus : Unit -> Int
    enabled : Unit -> Bool
}

main : Unit -> Int
main () = handle {
    let bonus = perform Round.bonus ()
    let enabled = perform Round.enabled ()
    match enabled {
        true => 40 + bonus
        false => 0
    }
} with Round {
    bonus ignored => {
        let result = match true {
            true => resume 2
            false => resume 5
        }
        result + 100
    }
    enabled ignored => resume true
}
```

Only one branch runs. The selected branch consumes the continuation and the
clause then adds `100` to its result:

```text
$ ash 06-branching-resume.ash
142 : Int
```

Changing the condition chooses a different answer; it does not permit both
branches to run against the same continuation. This check does not prove
that every program terminates. It governs paths that normally finish.

## Keep the right to resume in its clause

A continuation is not an ordinary function value. In
`05-captured-resume.ash`, a nested function tries to retain that right:

<!-- source: src/05-captured-resume.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle (perform Bonus.amount ()) with Bonus {
    amount ignored => {
        let later : Unit -> Int = fn(ignored) {
            resume 2
        }
        later ()
    }
}
```
<!-- diagnostic: src/05-captured-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 05-captured-resume.ash
This nested scope cannot capture the enclosing clause's right to resume or discard.
  --> /path/to/ash-doc/content/effects/resuming-a-calculation/src/05-captured-resume.ash:8:35
8 |         let later : Unit -> Int = fn(ignored) {
  |                                   ^ This nested scope cannot capture the enclosing clause's right to resume or discard.
9 |             resume 2
  | ^ This nested scope cannot capture the enclosing clause's right to resume or discard.
10 |         }
   | ^ This nested scope cannot capture the enclosing clause's right to resume or discard.
reason: effect.resume-capture
```
<!-- markdownlint-enable MD013 -->

The diagnostic points at the nested function that crosses the clause's
boundary. Even calling `later` immediately does not make this capture valid.
Keep the `resume 2` directly in the operation clause. Ordinary helper functions
can compute the integer answer, but cannot capture this right to resume.
The [effect rules][effects] define these consumption and scope restrictions.

## Practice: distinguish answer from result

1. Change the bonus answer in `01-resumed-result.ash`. Predict both the
   resumed body's result and the final result after adding `100`.
2. Change the `enabled` answer to `false`. Trace what returns to the bonus
   clause before running the program.
3. Change the branch condition in `06-branching-resume.ash`. Explain why each
   alternative still consumes the continuation exactly once.

A clause supplies an operation answer when it resumes, receives the result of
the waiting calculation, and may then finish its own work. Sometimes we want
to stop the waiting calculation instead. The next lesson develops that choice
without introducing resource ownership yet.

[effects]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#effects
