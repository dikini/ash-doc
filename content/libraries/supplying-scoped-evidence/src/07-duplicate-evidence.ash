interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> Int
main () = {
    newtype Token = Token(Int)
    with Read<Token, Int> {
        read (Token(value)) = value + 1
    }
    with Read<Token, Int> {
        read (Token(value)) = value + 2
    }
    forward (Token(40))
}
