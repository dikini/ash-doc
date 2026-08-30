import dictionaries as Dictionaries

type PrefixCheck =
    PrefixCheck(Bool, Bool, Bool, Bool)

type Scenario =
    Scenario(Bool, Dictionaries.List<PrefixCheck>, Dictionaries.List<Bool>)

type PrefixRun =
    PrefixRun(
        Dictionaries.List<PrefixCheck>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>
    )

has_value : Int -> Dictionaries.Option<Int> -> Bool
has_value expected Dictionaries.None = false
has_value expected Dictionaries.Some(actual) = expected == actual

is_none : Dictionaries.Option<A> -> Bool
is_none Dictionaries.None = true
is_none Dictionaries.Some(ignored_value) = false

prefix_run : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> PrefixRun
prefix_run Dictionaries.End retained_key retained_value absent_key dictionary = PrefixRun(
    Dictionaries.End,
    dictionary
)
prefix_run Dictionaries.More(entry, rest) retained_key retained_value absent_key dictionary = match entry {
    (key, value) => {
        let next_dictionary = Dictionaries.insert key value dictionary
        let current_check = PrefixCheck(
            Dictionaries.invariant_holds next_dictionary,
            has_value value (Dictionaries.lookup key next_dictionary),
            has_value retained_value (Dictionaries.lookup retained_key next_dictionary),
            is_none (Dictionaries.lookup absent_key next_dictionary)
        )
        let later_run = prefix_run rest retained_key retained_value absent_key next_dictionary
        match later_run {
            PrefixRun(later_checks, final_dictionary) => PrefixRun(
                Dictionaries.More(current_check, later_checks),
                final_dictionary
            )
        }
    }
}

lookup_checks : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Dictionaries.List<Bool>
lookup_checks Dictionaries.End absent_key dictionary = Dictionaries.More(
    is_none (Dictionaries.lookup absent_key dictionary),
    Dictionaries.End
)
lookup_checks Dictionaries.More(entry, rest) absent_key dictionary = match entry {
    (key, value) => Dictionaries.More(
        has_value value (Dictionaries.lookup key dictionary),
        lookup_checks rest absent_key dictionary
    )
}

scenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Scenario
scenario entries retained_key retained_value absent_key = {
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let run = prefix_run entries retained_key retained_value absent_key empty
    match run {
        PrefixRun(checks, final_dictionary) => Scenario(
            Dictionaries.invariant_holds empty,
            checks,
            lookup_checks entries absent_key final_dictionary
        )
    }
}

main : Unit -> (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let four = Dictionaries.Next(three)
    let five = Dictionaries.Next(four)
    let six = Dictionaries.Next(five)
    let seven = Dictionaries.Next(six)
    let ascending = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More(
                (three, 30),
                Dictionaries.More(
                    (four, 40),
                    Dictionaries.More(
                        (five, 50),
                        Dictionaries.More(
                            (six, 60),
                            Dictionaries.More((seven, 70), Dictionaries.End)
                        )
                    )
                )
            )
        )
    )
    let descending = Dictionaries.More(
        (seven, 70),
        Dictionaries.More(
            (six, 60),
            Dictionaries.More(
                (five, 50),
                Dictionaries.More(
                    (four, 40),
                    Dictionaries.More(
                        (three, 30),
                        Dictionaries.More(
                            (two, 20),
                            Dictionaries.More((one, 10), Dictionaries.End)
                        )
                    )
                )
            )
        )
    )
    let left_left = Dictionaries.More(
        (three, 30),
        Dictionaries.More((two, 20), Dictionaries.More((one, 10), Dictionaries.End))
    )
    let left_right = Dictionaries.More(
        (three, 30),
        Dictionaries.More((one, 10), Dictionaries.More((two, 20), Dictionaries.End))
    )
    let right_left = Dictionaries.More(
        (one, 10),
        Dictionaries.More((three, 30), Dictionaries.More((two, 20), Dictionaries.End))
    )
    let right_right = Dictionaries.More(
        (one, 10),
        Dictionaries.More((two, 20), Dictionaries.More((three, 30), Dictionaries.End))
    )
    (
        scenario ascending one 10 Dictionaries.Zero,
        scenario descending seven 70 Dictionaries.Zero,
        scenario left_left three 30 Dictionaries.Zero,
        scenario left_right three 30 Dictionaries.Zero,
        scenario right_left one 10 Dictionaries.Zero,
        scenario right_right one 10 Dictionaries.Zero
    )
}
