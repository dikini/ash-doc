import queues as Queues

main : Unit -> (
    Queues.Option<(Int, Queues.Queue<Int>)>,
    Queues.Option<(Int, Queues.Queue<Int>)>
)
main () = {
    let ready = Queues.enqueue 3 (
        Queues.enqueue 2 (
            Queues.enqueue 1 (Queues.empty ())
        )
    )
    (Queues.dequeue ready, Queues.dequeue ready)
}
