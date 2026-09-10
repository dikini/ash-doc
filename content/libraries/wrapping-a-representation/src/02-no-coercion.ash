newtype Points = Points(Int)

add_one : Int -> Int
add_one value = value + 1

main : Unit -> Int
main () = add_one (Points(41))
