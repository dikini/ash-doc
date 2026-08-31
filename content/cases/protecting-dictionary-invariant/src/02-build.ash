import dictionaries as Dictionaries
import dictionaries (impl Order)

main : Unit -> (Bool, Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((two, 99), Dictionaries.End)
        )
    )
    let dictionary = Dictionaries.build entries
    (
        Dictionaries.invariant_holds dictionary,
        Dictionaries.lookup two dictionary,
        Dictionaries.lookup one dictionary
    )
}
