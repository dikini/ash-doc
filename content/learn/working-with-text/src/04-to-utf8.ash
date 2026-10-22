import @builtin.string as Text

main : Unit -> Bytes
main () = Text.to_utf8 "a\nb"
