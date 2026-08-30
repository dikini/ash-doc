import dictionaries as Dictionaries

inspect : Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Int
inspect Dictionaries.Empty = 0

main : Unit -> Int
main () = inspect(Dictionaries.empty())
