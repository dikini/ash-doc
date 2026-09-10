import dictionaries as Dictionaries
import dictionaries (impl Order)

type ReplayObservation =
    Unexpected
    | Replay(
        Dictionaries.Iterator<Dictionaries.Natural, Int>,
        Dictionaries.Option<(
            (Dictionaries.Natural, Int),
            Dictionaries.Iterator<Dictionaries.Natural, Int>
        )>,
        Dictionaries.Option<(
            (Dictionaries.Natural, Int),
            Dictionaries.Iterator<Dictionaries.Natural, Int>
        )>
    )

replay : Dictionaries.Iterator<Dictionaries.Natural, Int> -> ReplayObservation
replay start = match Dictionaries.next start {
    Dictionaries.None => Unexpected
    Dictionaries.Some((ignored_first, after_one)) => Replay(
        after_one,
        Dictionaries.next after_one,
        Dictionaries.next after_one
    )
}

main : Unit -> ReplayObservation
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let entries = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
    replay (Dictionaries.iterator (Dictionaries.build entries))
}
