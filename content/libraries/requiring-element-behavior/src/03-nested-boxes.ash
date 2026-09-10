import equality (same, impl Equal)
import boxes (Box, impl Equal)

main : Unit -> Bool
main () = same (Box(Box(42)), Box(Box(42)))
