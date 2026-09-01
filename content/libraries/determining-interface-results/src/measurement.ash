pub interface Measure<Key, Result> where Key -> Result {
    measure : Key -> Int
}

pub impl Measure<Bool, Unit> {
    measure value = 42
}
