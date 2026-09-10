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
