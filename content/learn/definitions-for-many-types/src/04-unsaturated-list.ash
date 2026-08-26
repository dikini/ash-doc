type List<A> =
    Empty
    | More(A, List<A>)

keep : List -> List
keep list = list

main : Unit -> List<Int>
main () = keep Empty
