effect Review {
    propose : Unit -> Bool
}

main : Unit -> Bool
main () = handle (perform Review.propose ()) with Review {
    propose ignored => false
}
