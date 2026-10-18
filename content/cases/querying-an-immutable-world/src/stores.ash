pub type EntityId = EntityId(Int)

pub type Position = Position(Int, Int)

pub type Velocity = Velocity(Int, Int)

pub type Option<C> = None
    | Some(C)

pub type Rows<C> = NoRows
    | Row(EntityId, C, Rows<C>)

pub opaque type Store<C> = Store(Rows<C>)

pub empty : Unit -> Store<C>
empty () = Store(NoRows)

pub entries : Store<C> -> Rows<C>
entries Store(rows) = rows

same_entity : (EntityId, EntityId) -> Bool
same_entity (EntityId(left), EntityId(right)) = left == right

lookup_rows : (EntityId, Rows<C>) -> Option<C>
lookup_rows (query, NoRows) = None
lookup_rows (query, Row(entity, component, rest)) = match same_entity(query, entity) {
    true => Some(component)
    false => lookup_rows(query, rest)
}

pub lookup : (EntityId, Store<C>) -> Option<C>
lookup (query, Store(rows)) = lookup_rows(query, rows)

put_rows : (EntityId, C, Rows<C>) -> Rows<C>
put_rows (entity, component, NoRows) = Row(entity, component, NoRows)
put_rows (entity, component, Row(current, saved, rest)) = match same_entity(entity, current) {
    true => Row(entity, component, rest)
    false => Row(current, saved, put_rows(entity, component, rest))
}

pub put : (EntityId, C, Store<C>) -> Store<C>
put (entity, component, Store(rows)) = Store(put_rows(entity, component, rows))
