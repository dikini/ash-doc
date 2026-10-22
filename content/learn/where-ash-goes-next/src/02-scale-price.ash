effect Scale {
    by : Int -> Int
}

price : Int -> Int ! {Scale}
price base = perform Scale.by base

main : Unit -> Int
main () = handle (price 20) with Scale {
    by factor => resume (factor * 3)
}
