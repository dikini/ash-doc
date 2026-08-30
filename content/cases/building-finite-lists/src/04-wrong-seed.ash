import lists as Lists

main : Unit -> Lists.List<Int>
main () = Lists.unfold (Lists.repeat_step 42) true
