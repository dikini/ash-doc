interface Functor<F : Type -> Type> {
    map : (A -> B, F<A>) -> F<B>
}
