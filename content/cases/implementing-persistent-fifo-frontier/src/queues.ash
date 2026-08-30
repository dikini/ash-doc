pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

pub opaque type Queue<A> =
    Queue(List<A>, List<A>)

pub empty : Unit -> Queue<A>
empty () = Queue(End, End)

pub enqueue : A -> Queue<A> -> Queue<A>
enqueue value Queue(front, rear) = Queue(front, More(value, rear))

reverse_into : List<A> -> List<A> -> List<A>
reverse_into End reversed = reversed
reverse_into More(first, rest) reversed = {
    reverse_into rest (More(first, reversed))
}

pub dequeue : Queue<A> -> Option<(A, Queue<A>)>
dequeue Queue(End, End) = None
dequeue Queue(More(first, rest), rear) = {
    Some((first, Queue(rest, rear)))
}
dequeue Queue(End, rear) = {
    let front = reverse_into rear End
    dequeue (Queue(front, End))
}
