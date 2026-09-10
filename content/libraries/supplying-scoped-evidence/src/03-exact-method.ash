interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> Int
main () = {
    newtype Token = Token(Int)
    let token = Token(40)
    let offset = 2
    with Read<Token, Int> {
        read (Token(value)) = value + offset
    }
    forward token
}
