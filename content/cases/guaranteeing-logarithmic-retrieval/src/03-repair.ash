import dictionaries (Dictionary, Natural, Zero, Next, empty, insert, impl Order)

main : Unit -> Dictionary<Natural, Int>
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let after_three = insert three 30 (empty ())
    let after_two = insert two 20 after_three
    insert one 10 after_two
}
