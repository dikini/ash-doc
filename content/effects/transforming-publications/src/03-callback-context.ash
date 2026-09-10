effect Adjust {
    publish : Int -> Int
}

effect Bonus {
    amount : Unit -> Int
}

adjust : Int -> Int ! {Bonus}
adjust value = value + (perform Bonus.amount ())

main : Unit -> Int
main () = hook Adjust {
    handle (register Adjust adjust {
        handle {
            let ignored = perform Bonus.amount ()
            perform Adjust.publish 3
        } with Bonus {
            amount ignored => resume 100
        }
    }) with Bonus {
        amount ignored => resume 2
    }
}
