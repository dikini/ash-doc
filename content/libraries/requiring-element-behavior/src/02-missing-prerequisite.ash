import equality (same)
import boxes (Box, impl Equal)

main : Unit -> (Bool, Bool)
main () = (same (Box(42), Box(42)), same (Box(20), Box(22)))
