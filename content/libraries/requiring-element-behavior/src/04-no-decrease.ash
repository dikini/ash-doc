type Box<A> = Box(A)

interface Equal<A> {
    equal : (A, A) -> Bool
}

impl<A> Equal<Box<A>> where Equal<Box<A>> {
    equal pair = true
}

main : Unit -> Unit
main () = ()
