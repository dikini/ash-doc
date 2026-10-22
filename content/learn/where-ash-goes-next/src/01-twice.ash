interface Twice<A> {
    double : A -> (A, A)
}

impl Twice<Int> {
    double value = (value, value)
}

replicate : A -> (A, A) where Twice<A>
replicate item = double item

main : Unit -> (Int, Int)
main () = replicate 21
