pub import equality (Equal, equal)

pub type Box<A> = Box(A)

pub impl<A> Equal<Box<A>> where Equal<A> {
    equal (Box(left), Box(right)) = equal (left, right)
}
