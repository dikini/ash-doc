import lists as Lists

increment : Int -> Int
increment value = value + 1

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let three = Lists.Next(Lists.Next(Lists.Next(Lists.Zero)))
    let produced = Lists.unfold (Lists.repeat_step 42) three
    let mapped = Lists.map increment produced
    (produced, mapped)
}
