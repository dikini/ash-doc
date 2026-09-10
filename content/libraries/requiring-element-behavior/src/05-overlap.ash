import equality (Equal, equal, impl Equal)

type Box<A> = Box(A)

impl<A> Equal<Box<A>> where Equal<A> {
    equal (Box(left), Box(right)) = equal (left, right)
}

impl Equal<Box<Int>> {
    equal (Box(left), Box(right)) = left == right
}

main : Unit -> Unit
main () = ()
