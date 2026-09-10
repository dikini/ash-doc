interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> (Int, Int)
main () = {
    newtype Token = Token(Int)
    let token = Token(40)
    let first = {
        with Read<Token, Int> {
            read (Token(value)) = value + 1
        }
        forward token
    }
    let second = {
        with Read<Token, Int> {
            read (Token(value)) = value + 2
        }
        forward token
    }
    (first, second)
}
