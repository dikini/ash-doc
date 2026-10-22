# Running a scripted session

A session remembers which commands are currently meaningful. Here `Start`
opens a session, `Send` is accepted only while it is open, and `Close` ends the
run. Keep those rules in the pure `transition` function. The session loop
requests commands and publishes replies through `Session`.

Continue from [supplying dependencies](../supplying-order-prices/README.md)
and [resuming a calculation](../../effects/resuming-a-calculation/README.md).
The handler uses a [scoped cell](../../effects/counting-with-a-cell/README.md)
for the script position. The session's domain state remains an explicit
argument; effects need not turn every piece of state into mutable storage.

From the Cases directory, enter `running-a-scripted-session/src`. The first
script starts before sending; the second sends twice without starting. Predict
the replies, then run `ash main.ash`.

<!-- source: src/main.ash -->
```ash
import @builtin.cell as Cell

type Command = Start
    | Send(Int)
    | Close

type State = Idle
    | Open

type Reply = Started
    | Accepted(Int)
    | Refused
    | Closed

type Replies = End
    | More(Reply, Replies)

effect Session {
    receive : Unit -> Command
    reply : Reply -> Unit
}

transition : (State, Command) -> (State, Reply)
transition (state, Start) = (Open, Started)
transition (Idle, Send(value)) = (Idle, Refused)
transition (Open, Send(value)) = (Open, Accepted(value))
transition (state, Close) = (Idle, Closed)

session : State -> Replies ! {Session}
session state = {
    let command = perform Session.receive ()
    let (next, response) = transition (state, command)
    let ignored = perform Session.reply response
    match command {
        Close => End
        other => session next
    }
}

script : (Bool, Int) -> Command
script (start_first, index) = match index == 0 {
    true => match start_first {
        true => Start
        false => Send(7)
    }
    false => match index == 1 {
        true => Send(42)
        false => Close
    }
}

run : Bool -> Replies
run start_first = resource cell<R> cursor = 0 {
    handle (session Idle) with Session {
        receive () => {
            let index = Cell.read cursor
            let ignored = Cell.write (cursor, index + 1)
            resume (script (start_first, index))
        }
        reply response => {
            let rest = resume ()
            More(response, rest)
        }
    }
}

main : Unit -> (Replies, Replies)
main () = (run true, run false)
```

<!-- markdownlint-disable MD013 -->
```text
$ ash main.ash
(More(Started, More(Accepted(42), More(Closed, End))), More(Refused, More(Refused, More(Closed, End)))) : (Replies, Replies)
```
<!-- markdownlint-enable MD013 -->

The two runs use the same transition rules and loop; only the supplied script
changes. Supplying a calculation's inputs from its enclosing handler this way
is *dependency injection*, as in the pricing Case. Each run starts its own
cursor at zero, and both scripts eventually supply `Close`.

In the `reply` clause, `resume ()` runs the remaining session and returns its
`Replies`. Prepending the current reply to that result retains chronological
order. The handler builds the transcript without adding a reply accumulator to
the session loop. Input and output here are finite data, with no terminal or
network connection.

The protocol is checked by `transition` at runtime. It does not establish
session types or prevent callers from constructing an out-of-order command.
Likewise, termination here depends on the supplied scripts reaching `Close`;
the effect declaration alone does not guarantee it.

For practice, change the second script to send, start, send, then close. Predict
its transcript before editing the script function. Keeping `transition` pure
also lets you examine individual command/state pairs separately.

Continue with [bounding search work](../bounding-search-work/README.md),
where a handler decides whether a calculation may take another step.
