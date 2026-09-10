newtype Recorded<A> = Recorded(A)

unwrap : Recorded<A> -> A
unwrap (Recorded(value)) = value

main : Unit -> (Int, Bool)
main () = (unwrap (Recorded(42)), unwrap (Recorded(true)))
