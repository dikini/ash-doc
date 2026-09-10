effect Convert<A, B> {
    publish : A -> B
}

main : Unit -> Int
main () = hook Convert<Int, Int> {
    perform Convert<Int, Int>.publish 3
}
