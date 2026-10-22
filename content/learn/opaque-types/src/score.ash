pub opaque type Score = Score(Int)

pub make : Int -> Score
make points = Score(points)

pub add : Score -> Int -> Score
add (Score points) extra = Score(points + extra)

pub total : Score -> Int
total (Score points) = points
