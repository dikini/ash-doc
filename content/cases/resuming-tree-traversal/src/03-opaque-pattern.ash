import dictionaries as Dictionaries

main : Unit -> Int
main () = {
    let dictionary : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty ()
    match Dictionaries.iterator dictionary {
        Dictionaries.Iterator(ignored_stack) => 1
    }
}
