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

The first request needs an integer; `resume 2` supplies it and continues at
the binding of `bonus`. Follow that work through the `enabled` request and
the match. Before running, predict what value returns to `result`, then what
the bonus clause returns after adding `100`. Run the file from this lesson's
`src` directory:

```text
$ ash 01-resumed-result.ash
142 : Int
```

The `enabled` clause supplies `true`, so the match computes `40 + 2`.
That result returns to the bonus clause, which still has its addition to do:

| Role | Value | Where it goes |
| --- | --- | --- |
| Answer supplied to the bonus operation | `2` | The body's `bonus` binding |
| Result of the resumed calculation | `42` | The clause's `result` binding |
| Final result of the bonus clause | `142` | The enclosing calculation |

For the other operation, `resume true` takes a Boolean answer but returns an
integer result. The operation signature controls the answer supplied to
`resume`. The handler's result contract controls the resumed computation and
the clause result.

Resumption continues after the request. It does not start the body again or
repeat work before that request. Handlers in the suspended segment are
restored as the work continues, which is why the later `enabled` request still
uses the `Round` handler. The [handler evaluation rules][evaluation] describe
this return to the clause after the resumed work finishes.

## Cover the whole operation API

A handler supplies exactly one clause for every operation in its target API.
`02-missing-operation.ash` uses a body that only requests `bonus`. Compare the
declared operations with the clauses: which requirement remains uncovered?

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

Check that comparison against the diagnostic:

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

At the end of this clause, has the waiting calculation received an answer?
Identify what remains unconsumed before reading the message:

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

Once resumed, the same continuation cannot be used again. Trace its state
through the two uses in `04-repeated-resume.ash`:

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

Which use encounters a continuation that has already been consumed?

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

Only one branch runs. Choose that branch from the condition, then predict
what returns from its resumption and what the clause adds afterward:

```text
$ ash 06-branching-resume.ash
142 : Int
```

The `true` branch supplies `2`, so the waiting body returns `42` and the
clause returns `142`, as before. Changing the condition chooses a different
answer; it does not permit both branches to run against the same continuation.
This check does not prove
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

The right to resume belongs to the operation clause. Which nested scope would
have to retain that right for `later` to work?

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

For each task, make a fresh copy of the named program in a scratch directory
outside this lesson's `src` tree. Predict the result, then run that copy from
its directory.

1. Start from `01-resumed-result.ash` and change the bonus answer. Predict the
   resumed body's result and the final result after adding `100`.
2. Start again from `01-resumed-result.ash` and change the `enabled` answer to
   `false`. Trace what returns to the bonus clause before running the program.
3. Start from `06-branching-resume.ash` and change the branch condition.
   Explain why each alternative still consumes the continuation exactly once.

A clause supplies an operation answer when it resumes, receives the result of
the waiting calculation, and may then finish its own work. Sometimes we want
to stop the waiting calculation instead. The next lesson develops that choice
without introducing resource ownership yet.

[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[evaluation]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
