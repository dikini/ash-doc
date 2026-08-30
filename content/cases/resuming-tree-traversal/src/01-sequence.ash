import dictionaries as Dictionaries

collect : Dictionaries.Iterator<K, V> -> Dictionaries.List<(K, V)>
collect current = match Dictionaries.next current {
    Dictionaries.None => Dictionaries.End
    Dictionaries.Some((entry, later)) => Dictionaries.More(entry, collect later)
}

is_finished : Dictionaries.Option<A> -> Bool
is_finished Dictionaries.None = true
is_finished Dictionaries.Some(ignored) = false

main : Unit -> (Bool, Dictionaries.List<(Dictionaries.Natural, Int)>)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let empty_dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((three, 30), Dictionaries.End)
        )
    )
    let dictionary = Dictionaries.build entries
    let empty_finished = is_finished (Dictionaries.next (Dictionaries.iterator empty_dictionary))
    (empty_finished, collect (Dictionaries.iterator dictionary))
}
