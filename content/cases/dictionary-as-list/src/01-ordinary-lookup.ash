import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> (Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup int_equal 1 dictionary,
        Dictionaries.lookup int_equal 3 dictionary
    )
}
