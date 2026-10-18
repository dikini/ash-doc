effect Compare {
    allow : Unit -> Unit
}

main : Unit -> Unit
main () = handle (perform Compare.allow ()) with Compare {
    allow () => {
        let ignored = resume ()
        resume ()
    }
}
