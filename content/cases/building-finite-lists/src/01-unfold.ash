import lists as Lists

main : Unit -> Lists.List<Int>
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    Lists.unfold (Lists.repeat_step 42) three
}
