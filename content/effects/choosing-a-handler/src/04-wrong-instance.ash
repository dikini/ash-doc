effect Ask<A> {
    value : Unit -> A
}

main : Unit -> Int
main () = handle (perform Ask<Int>.value ()) with Ask<Bool> {
    value ignored => resume false
}
