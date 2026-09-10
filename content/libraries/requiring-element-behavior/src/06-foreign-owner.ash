import equality (Equal)
import boxes (Box)

impl Equal<Box<Int>> {
    equal (Box(left), Box(right)) = left == right
}

main : Unit -> Unit
main () = ()
