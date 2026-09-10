effect Round {
    bonus : Unit -> Int
    enabled : Unit -> Bool
}

main : Unit -> Int
main () = handle {
    let bonus = perform Round.bonus ()
    let enabled = perform Round.enabled ()
    match enabled {
        true => 40 + bonus
        false => 0
    }
} with Round {
    bonus ignored => {
        let result = resume 2
        result + 100
    }
    enabled ignored => resume true
}
