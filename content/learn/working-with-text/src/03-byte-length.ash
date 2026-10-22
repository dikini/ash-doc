import @builtin.string as Text

main : Unit -> Int
main () = Text.byte_length "a\nb"
