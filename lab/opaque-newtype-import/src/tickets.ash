pub opaque newtype Ticket = Ticket(Int)

pub issue : Int -> Ticket
issue value = Ticket(value)
