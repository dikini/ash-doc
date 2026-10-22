pub opaque type Score = Score(Int, Int)

pub make : Int -> Score
make points = Score(points, 0)

pub add : Score -> Int -> Score
add (Score(points, additions)) extra = Score(points + extra, additions + 1)

pub total : Score -> Int
total (Score(points, _)) = points
