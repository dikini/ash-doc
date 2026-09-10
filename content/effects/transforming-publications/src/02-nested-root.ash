effect Adjust {
    publish : Int -> Int
}

increment : Int -> Int
increment value = value + 1

double : Int -> Int
double value = value * 2

main : Unit -> (Int, Int, Int)
main () = hook Adjust {
    register Adjust increment {
        let before = perform Adjust.publish 3
        let inside = hook Adjust {
            perform Adjust.publish 3
        }
        (before, inside, perform Adjust.publish 3)
    }
}
