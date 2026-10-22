both : Bool -> Bool -> Bool
both first second = match first {
    true => second
    false => false
}

main : Unit -> Bool
main () = both (20 + 22 == 42) (1 * 1 == 1)
