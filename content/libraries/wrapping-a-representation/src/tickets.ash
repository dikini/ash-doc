pub opaque newtype Ticket = Ticket(Int)

pub issue : Int -> Ticket
issue value = Ticket(value)

pub number : Ticket -> Int
number (Ticket(value)) = value
