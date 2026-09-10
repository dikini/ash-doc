import @builtin.cell as Cell

effect Ask {
    value : Unit -> Int
}

request : Int -> Int ! {Ask}
request value = match value == 0 {
    true => perform Ask.value ()
    false => {
        let left = request 0
        let right = request 0
        left + right
    }
}

main : Unit -> Int
main () = {
    handle (request 0) with Ask {
        value () => resume 0
    }
}
