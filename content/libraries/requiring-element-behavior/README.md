# How can an implementation depend on its element's behavior?

The first library lesson compared integers through `Equal<Int>`. A container
can also support equality, but its implementation must explain what makes its
elements equal. A box cannot obtain that behavior merely because its element
type is written as a parameter.

We will derive box equality by unwrapping two boxes and asking for equality of
their contents. The resulting implementation has a prerequisite. A client must
make both the container implementation and the needed element behavior
available.

## Retain the concrete element behavior

Keep the familiar interface, integer implementation, and constrained helper
in `equality.ash`:

<!-- source: src/equality.ash -->
```ash
pub interface Equal<A> {
    equal : (A, A) -> Bool
}

pub impl Equal<Int> {
    equal (left, right) = left == right
}

pub same : (A, A) -> Bool where Equal<A>
same pair = equal pair
```

`same` requires `Equal<A>` and forwards that evidence to the method call.
The integer implementation satisfies `Equal<Int>`. It says nothing yet about
boxes, even boxes containing integers.

## Derive the container implementation

`boxes.ash` owns the box type and supplies its equality rule:

<!-- source: src/boxes.ash -->
```ash
pub import equality (Equal, equal)

pub type Box<A> = Box(A)

pub impl<A> Equal<Box<A>> where Equal<A> {
    equal (Box(left), Box(right)) = equal (left, right)
}
```

Read the header from the outside inward. `impl<A>` names the head's type
parameter. `Equal<Box<A>>` is the interface application being implemented.
`where Equal<A>` is the evidence needed to implement it.

The method patterns expose `left` and `right`, both of type `A`. Their equality
call uses the declared prerequisite. The method cannot assume integer
operations because `A` is rigid while the implementation is checked. Its
argument type is fixed by substituting `Box<A>` into the interface contract.

The public import forwards the interface and method names. It does not import
or re-export the integer implementation. The public box implementation is a
separate fact whose prerequisite must be satisfied when a client selects it.
All parameter names in a prerequisite must already occur in the head;
prerequisites do not introduce new unknown element types.

## Supply both facts at the use

The entry explicitly selects the two public implementations:

<!-- source: src/01-box-equality.ash -->
```ash
import equality (same, impl Equal)
import boxes (Box, impl Equal)

main : Unit -> (Bool, Bool)
main () = (same (Box(42), Box(42)), same (Box(20), Box(22)))
```

Write the complete requirement for the first `same` call. Follow the box
implementation's prerequisite to the selected element method, then use that
method on each pair's unwrapped contents. Predict both booleans before running
from this lesson's `src` directory:

```text
$ ash 01-box-equality.ash
(true, false) : (Bool, Bool)
```

The first pair has equal contents and the second does not. The ordinary
constructor shapes are the same; the element method supplies the distinction.

For `same (Box(42), Box(42))`, the evidence request follows this path:

1. The argument fixes `A` in `same` to `Box<Int>`.
2. `Equal<Box<Int>>` matches the generic box implementation with its parameter
   set to `Int`.
3. Substituting that choice into its prerequisite gives `Equal<Int>`.
4. The selected integer implementation satisfies that prerequisite.

The resulting box method receives integer equality and uses it on the two
unwrapped values. The second call uses the same evidence path with different
integer contents.

## A selected container rule still needs its prerequisite

`02-missing-prerequisite.ash` removes only the integer implementation selector:

<!-- source: src/02-missing-prerequisite.ash -->
```ash
import equality (same)
import boxes (Box, impl Equal)

main : Unit -> (Bool, Bool)
main () = (same (Box(42), Box(42)), same (Box(20), Box(22)))
```

The box implementation is still selected. Trace its prerequisite from the
first call: where does evidence become unavailable? Predict which call and
declarations the message will connect, then run this entry:

<!-- diagnostic: src/02-missing-prerequisite.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-missing-prerequisite.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/02-missing-prerequisite.ash:5:12
5 | main () = (same (Box(42), Box(42)), same (Box(20), Box(22)))
  |            ^ No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/equality.ash:9:5
9 | pub same : (A, A) -> Bool where Equal<A>
  |     ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/02-missing-prerequisite.ash:1:18
1 | import equality (same)
  |                  ^ This import made the declaration available.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/equality.ash:1:1
1 | pub interface Equal<A> {
  | ^ This interface participates in the failing evidence selection.
2 |     equal : (A, A) -> Bool
  | ^ This interface participates in the failing evidence selection.
3 | }
  | ^ This interface participates in the failing evidence selection.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/02-missing-prerequisite.ash:2:1
2 | import boxes (Box, impl Equal)
  | ^ This import made the selected implementation available.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/boxes.ash:5:1
5 | pub impl<A> Equal<Box<A>> where Equal<A> {
  | ^ Evidence selection followed this implementation.
6 |     equal (Box(left), Box(right)) = equal (left, right)
  | ^ Evidence selection followed this implementation.
7 | }
  | ^ Evidence selection followed this implementation.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/boxes.ash:6:5
6 |     equal (Box(left), Box(right)) = equal (left, right)
  |     ^ This implementation method supplies the selected evidence.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/equality.ash:1:1
1 | pub interface Equal<A> {
  | ^ This interface participates in the failing evidence selection.
2 |     equal : (A, A) -> Bool
  | ^ This interface participates in the failing evidence selection.
3 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

The message starts at the constrained use, relates it to `same`'s declaration,
and follows the imported box implementation. That implementation is available,
but its substituted `Equal<Int>` prerequisite has no evidence in this entry's
effective environment. Importing `same` by name does not admit that fact.

Restore `impl Equal` in the import from `equality`. This repairs the missing
element behavior without changing the generic container rule. A library may
also deliberately forward public implementation facts through a facade, as
in the earlier forwarding lesson; the route must still be explicit.

## Follow nested prerequisites toward a base case

The same generic implementation handles a box inside another box:

<!-- source: src/03-nested-boxes.ash -->
```ash
import equality (same, impl Equal)
import boxes (Box, impl Equal)

main : Unit -> Bool
main () = same (Box(Box(42)), Box(Box(42)))
```

Write the complete requirements from the outer box to the element type.
Separately count the box layers each value must lose during execution. Predict
the boolean before running this nested comparison:

```text
$ ash 03-nested-boxes.ash
true : Bool
```

Selection follows `Equal<Box<Box<Int>>>`, then `Equal<Box<Int>>`, then
`Equal<Int>`. Each generic step removes one `Box` layer from the requirement.
Execution similarly unwraps each layer before comparing the integer values.
The implementation is reused with different complete arguments; its own
method body remains checked once against its declared generic contract.

For an interface without a determination edge, the complete argument vector
is its *selection key*. With an edge, only the determinant positions form the
key, as in the preceding determination lesson. Prerequisites do not provide a
second way to choose between competing implementations.

## Require structural progress from a generic prerequisite

For a generic prerequisite still containing parameters, compare its selection
key with the head's key. The vectors must have equal width. Each prerequisite
component must equal or be a strict syntactic part of the corresponding head
component, and at least one must be strictly smaller. This rule checks
structural progress in the requirement, not the method's calculation.

The following declaration repeats its head in its prerequisite:

<!-- source: src/04-no-decrease.ash -->
```ash
type Box<A> = Box(A)

interface Equal<A> {
    equal : (A, A) -> Bool
}

impl<A> Equal<Box<A>> where Equal<Box<A>> {
    equal pair = true
}

main : Unit -> Unit
main () = ()
```

Compare the two `Box<A>` key arguments. Which part of the progress requirement
can this header satisfy, and which part remains unmet? Run the source:

<!-- diagnostic: src/04-no-decrease.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-no-decrease.ash
This generic prerequisite does not have a strictly smaller selection key than the implementation head.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/04-no-decrease.ash:7:29
7 | impl<A> Equal<Box<A>> where Equal<Box<A>> {
  |                             ^ This generic prerequisite does not have a strictly smaller selection key than the implementation head.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/04-no-decrease.ash:7:9
7 | impl<A> Equal<Box<A>> where Equal<Box<A>> {
  |         ^ Each prerequisite key argument must equal or be a strict syntactic subterm of its corresponding head argument, with at least one strict decrease.
reason: impl.prerequisite-not-decreasing
```
<!-- markdownlint-enable MD013 -->

The labels compare `Box<A>` with the unchanged `Box<A>` prerequisite. The
prerequisite repeats the head instead of removing a constructor layer. In the
working implementation,
`A` is a strict part of `Box<A>`, so the prerequisite makes structural progress.
Use `where Equal<A>` and the unwrapping method from `boxes.ash`.

This admission rule applies to nonground prerequisites: those still containing
parameters. A fully concrete
prerequisite is exempt from this decrease comparison, but evidence selection
still detects cycles of complete requirements. The rule does not prove that
arbitrary method bodies terminate.

## A specialized implementation is not an override

Available implementation heads must be coherent: two distinct heads cannot
match the same complete application. A prerequisite does not give one head
lower priority. Consider adding a separate rule for integer boxes:

<!-- source: src/05-overlap.ash -->
```ash
import equality (Equal, equal, impl Equal)

type Box<A> = Box(A)

impl<A> Equal<Box<A>> where Equal<A> {
    equal (Box(left), Box(right)) = equal (left, right)
}

impl Equal<Box<Int>> {
    equal (Box(left), Box(right)) = left == right
}

main : Unit -> Unit
main () = ()
```

Find an application that both heads can match. Predict which declarations
the checker must compare before it can accept this module, then run it:

<!-- diagnostic: src/05-overlap.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 05-overlap.ash
This implementation can match the same interface application as an earlier available implementation.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/05-overlap.ash:9:12
9 | impl Equal<Box<Int>> {
  |            ^ This implementation can match the same interface application as an earlier available implementation.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/05-overlap.ash:5:9
5 | impl<A> Equal<Box<A>> where Equal<A> {
  |         ^ The earlier implementation is defined here.
reason: impl.overlap
```
<!-- markdownlint-enable MD013 -->

Both heads can match `Equal<Box<Int>>`. The diagnostic identifies the later
head and the earlier generic one. Having a prerequisite does not make the
generic rule lower priority. Source order, import order, and apparent
specificity do not select a winner.

Keep one coherent implementation for that key. Here the generic implementation
already obtains integer behavior through its prerequisite, so remove the
specialized declaration. If a wrapper needs a distinct meaning, give it a
distinct nominal type; the next chapter develops that choice.

## Put an implementation with an owner

An implementation belongs in a module that owns its interface or an outer
nominal type in its selection key. The box module qualifies through its own
type even though `Equal` comes from another module. Examine this client:

<!-- source: src/06-foreign-owner.ash -->
```ash
import equality (Equal)
import boxes (Box)

impl Equal<Box<Int>> {
    equal (Box(left), Box(right)) = left == right
}

main : Unit -> Unit
main () = ()
```

Locate the defining modules of `Equal` and the outer `Box` type. Does this
client define either one? Predict whether its method body can repair an
ownership failure, then run the source:

<!-- diagnostic: src/06-foreign-owner.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-foreign-owner.ash
This module owns neither the interface nor an outer nominal type in the implementation's selection key. Dependent arguments and nested nominal types do not establish ownership.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/06-foreign-owner.ash:4:6
4 | impl Equal<Box<Int>> {
  |      ^ This module owns neither the interface nor an outer nominal type in the implementation's selection key. Dependent arguments and nested nominal types do not establish ownership.
  --> /path/to/ash-doc/content/libraries/requiring-element-behavior/src/06-foreign-owner.ash:4:6
4 | impl Equal<Box<Int>> {
  |      ^ This selected interface belongs to another module.
reason: impl.orphan
```
<!-- markdownlint-enable MD013 -->

The declaration is rejected before its body matters. Place this responsibility
in the module owning `Equal` or the module owning the outer `Box`, retaining
only one implementation for overlapping keys. Importing a type does not
transfer ownership of its declaration.

For a determined interface, only the selection-key arguments can establish
this nominal ownership. A nominal appearing solely in a dependent result, or
nested beneath a foreign outer constructor, does not establish an owner.
The [implementation rules][implementations] govern admission and coherence;
[evidence selection][selection] governs the subsequent prerequisite search.

## Practice: follow the required behavior

Start each task with fresh copies in a scratch directory. For tasks one and
two, copy `03-nested-boxes.ash`, `equality.ash`, and `boxes.ash` together. For
tasks three and four, copy `01-box-equality.ash` with those two libraries.

1. Change one innermost integer in `03-nested-boxes.ash`. Trace the complete
   requirements and predict the boolean and which method makes the final
   decision, then run it.
2. Add another `Box` layer to both arguments in `03-nested-boxes.ash`. Predict
   the result and count the unwrapping steps before running it. Explain which
   complete requirements reuse the generic declaration.
3. Add `Equal<Bool>` to `equality.ash`, using exhaustive Boolean patterns.
   Compare two Boolean boxes through `same` in the copied entry and adjust its
   arguments as needed. Predict the result, then check it.
4. Explain why removing the prerequisite from the box implementation would
   leave its method unable to compare arbitrary elements.

A generic implementation describes how to build one behavior from explicitly
required smaller behaviors. Imports make its facts available, structural rules
keep selection coherent, and the method explains the actual calculation.
The next chapter gives an [existing representation a new nominal meaning](../wrapping-a-representation/README.md)
without allocating an ordinary constructor wrapper.

[implementations]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#implementations
[selection]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence
