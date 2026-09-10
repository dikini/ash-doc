type Count = Zero
    | Next(Count)

main : Unit -> (Bool, Bool)
main () = {
    let rec even : Count -> Bool = fn(count) {
        match count {
            Zero => true
            Next(rest) => odd rest
        }
    }
    and odd : Count -> Bool = fn(count) {
        match count {
            Zero => false
            Next(rest) => even rest
        }
    }
    let two = Next(Next(Zero))
    (even two, odd two)
}
