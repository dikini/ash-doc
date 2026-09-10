import pipeline as Pipeline

main : Unit -> (Pipeline.Result, Pipeline.Steps)
main () = Pipeline.run (true, false)
