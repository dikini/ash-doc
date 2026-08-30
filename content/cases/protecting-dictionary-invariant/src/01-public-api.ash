import dictionaries as Dictionaries

main : Unit -> (Bool, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let four = Dictionaries.Next(three)
    let with_three = Dictionaries.insert three 30 empty
    let with_one = Dictionaries.insert one 10 with_three
    let with_two = Dictionaries.insert two 20 with_one
    let dictionary = Dictionaries.insert four 40 with_two
    (
        Dictionaries.invariant_holds dictionary,
        Dictionaries.lookup one dictionary,
        Dictionaries.lookup two dictionary,
        Dictionaries.lookup three dictionary,
        Dictionaries.lookup four dictionary,
        Dictionaries.lookup Dictionaries.Zero dictionary
    )
}
