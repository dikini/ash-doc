import lists as Lists

main : Unit -> (Lists.List<Int>, Int)
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    Lists.unfold_counted (Lists.repeat_step 42) three
}
