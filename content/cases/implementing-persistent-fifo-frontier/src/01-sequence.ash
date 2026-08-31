import queues as Queues

drain : Queues.Queue<A> -> Queues.List<A>
drain queue = match Queues.dequeue queue {
    Queues.None => Queues.End
    Queues.Some((first, later)) => Queues.More(first, drain later)
}

main : Unit -> (
    Queues.Option<(Int, Queues.Queue<Int>)>,
    Queues.Queue<Int>,
    Int,
    Queues.Queue<Int>,
    Queues.List<Int>
)
main () = {
    let empty_queue = Queues.empty ()
    let ready = Queues.enqueue 3 (
        Queues.enqueue 2 (
            Queues.enqueue 1 empty_queue
        )
    )
    let empty_result = Queues.dequeue empty_queue
    match Queues.dequeue ready {
        Queues.None => (empty_result, ready, 0, ready, Queues.End)
        Queues.Some((first, later)) => (
            empty_result,
            ready,
            first,
            later,
            drain later
        )
    }
}
