interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

newtype Token = Token(Int)

main : Unit -> Int
main () = {
    with Read<Token, Int> {
        read (Token(value)) = value
    }
    forward (Token(42))
}
