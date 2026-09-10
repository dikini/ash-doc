newtype Points = Points(Int)

add_one : Points -> Points
add_one (Points(value)) = Points(value + 1)

main : Unit -> Points
main () = add_one (Points(41))
