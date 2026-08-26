type Box<A> = Box(A)

main : Unit -> (Box<Int>, Box<Bool>)
main () = (Box(42), Box(false))
