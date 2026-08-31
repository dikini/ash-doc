import dictionaries as Dictionaries

main : Unit -> (
    (
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>
    ),
    (Bool, Bool, Bool, Bool),
    (
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>
    )
)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let with_two = Dictionaries.insert two 20 empty
    let older = Dictionaries.insert one 10 with_two
    let replaced = Dictionaries.insert two 99 older
    let extended = Dictionaries.insert three 30 replaced
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More(
                (two, 99),
                Dictionaries.More((three, 30), Dictionaries.End)
            )
        )
    )
    let built = Dictionaries.build entries
    (
        (older, replaced, extended, built),
        (
            Dictionaries.invariant_holds older,
            Dictionaries.invariant_holds replaced,
            Dictionaries.invariant_holds extended,
            Dictionaries.invariant_holds built
        ),
        (
            Dictionaries.lookup two older,
            Dictionaries.lookup two replaced,
            Dictionaries.lookup two built,
            Dictionaries.lookup three older,
            Dictionaries.lookup three extended,
            Dictionaries.lookup three built
        )
    )
}
