add : Int -> Int -> Int
add left right = left + right

add_twenty : Int -> Int
add_twenty number = add 20 number

main : Unit -> Int
main () = add_twenty 22
