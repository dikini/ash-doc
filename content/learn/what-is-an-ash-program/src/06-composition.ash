increment : Int -> Int
increment number = number + 1

double : Int -> Int
double number = number * 2

main : Unit -> Int
main () = double (increment 20)
