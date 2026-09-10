import @demo.pipeline as Pipeline

main : Unit -> ((Pipeline.Result, Pipeline.Steps),
    (Pipeline.Result, Pipeline.Steps), (Pipeline.Result, Pipeline.Steps))
main () = (Pipeline.run (true, true), Pipeline.run (false, true),
    Pipeline.run (true, false))
