type Tagged = Tagged(Int)
newtype Points = Points(Int)

main : Unit -> (Tagged, Points)
main () = (Tagged(42), Points(42))
