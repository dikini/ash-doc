interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

make_reader : Int -> Unit -> Int
make_reader amount = {
    newtype Token = Token(Int)
    let token = Token(amount)
    let offset = 2
    with Read<Token, Int> {
        read (Token(value)) = value + offset
    }
    fn(ignored) {
        forward token
    }
}

main : Unit -> Int
main () = make_reader 40 ()
