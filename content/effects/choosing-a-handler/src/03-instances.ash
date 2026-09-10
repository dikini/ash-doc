effect Ask<A> {
    value : Unit -> A
}

main : Unit -> (Int, Bool)
main () = {
    let points = handle (perform Ask<Int>.value ()) with Ask<Int> {
        value ignored => resume 40
    }
    let enabled = handle (perform Ask<Bool>.value ()) with Ask<Bool> {
        value ignored => resume true
    }
    (points, enabled)
}
