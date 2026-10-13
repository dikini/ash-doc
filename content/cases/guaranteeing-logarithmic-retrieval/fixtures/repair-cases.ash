type RepairObservation =
    RepairObservation(Dictionary<Natural, Int>, Bool, Bool, Bool, Bool)

observe_repair : Dictionary<Natural, Int> -> RepairObservation
observe_repair dictionary = RepairObservation(
    dictionary,
    valid_between None None dictionary,
    balance_holds dictionary,
    root_is_black dictionary,
    invariant_holds (blacken_root dictionary)
)

main : Unit -> (RepairObservation, RepairObservation, RepairObservation, RepairObservation, RepairObservation, RepairObservation, RepairObservation, RepairObservation, RepairObservation)
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let four = Next(three)
    let five = Next(four)
    let six = Next(five)
    let seven = Next(six)
    let a = Node(Black, Empty, one, 11, Empty)
    let b = Node(Black, Empty, three, 33, Empty)
    let c = Node(Black, Empty, five, 55, Empty)
    let d = Node(Black, Empty, seven, 77, Empty)
    let repaired = (restore_three
        (RArg(a, two, 22))
        (RArg(b, four, 44))
        (RArg(c, six, 66))
        d
    )
    let left_left = (restore Black
        (RArg(Node(Red, Node(Red, a, two, 22, b), four, 44, c), six, 66))
        d
    )
    let left_right = (restore Black
        (RArg(Node(Red, a, two, 22, Node(Red, b, four, 44, c)), six, 66))
        d
    )
    let right_left = (restore Black
        (RArg(a, two, 22))
        (Node(Red, Node(Red, b, four, 44, c), six, 66, d))
    )
    let right_right = (restore Black
        (RArg(a, two, 22))
        (Node(Red, b, four, 44, Node(Red, c, six, 66, d)))
    )
    let black_unchanged = restore Black (RArg(a, two, 22)) b
    let red_unchanged = restore Red (RArg(a, two, 22)) b
    let temporary_red_child = (restore Red
        (RArg(Node(Red, a, two, 22, b), four, 44))
        c
    )
    let red_discriminator = (restore Red
        (RArg(Node(Red, Node(Red, a, two, 22, b), four, 44, c), six, 66))
        d
    )
    (
        observe_repair repaired,
        observe_repair left_left,
        observe_repair left_right,
        observe_repair right_left,
        observe_repair right_right,
        observe_repair black_unchanged,
        observe_repair red_unchanged,
        observe_repair temporary_red_child,
        observe_repair red_discriminator
    )
}
