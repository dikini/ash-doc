import @builtin.cell as Cell

effect Ask {
    value : Unit -> Int
}

request : Int -> Int ! {Ask}
request value = match value == 0 {
    true => perform Ask.value ()
    false => {
        let left = request 0
        let right = 0
        left + right
    }
}

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    handle (request 0) with Ask {
        value () => resume 0
    }
}
