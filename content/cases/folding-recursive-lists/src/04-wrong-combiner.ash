import lists as Lists

wrong : Int -> Bool -> Bool
wrong first folded_rest = first == 42

main : Unit -> Bool
main () = Lists.fold wrong 0 (Lists.More(42, Lists.Empty))
