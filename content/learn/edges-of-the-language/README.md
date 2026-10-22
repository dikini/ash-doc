# The edges of the language

The programs so far have grown from a single calculation into data
definitions, recursive functions, and matches. Each new form extended what you
could say. Every language also draws a boundary around what it admits, and
knowing Ash's boundary prevents surprises: it explains why the book's idioms
look the way they do.

This lesson tours the boundary from the inside. At each stop we attempt
something Ash declines, read the compiler's complete answer, and name the
idiom that covers the need. The refusals are deliberate, and every one points
at a working alternative.

## A note the program cannot carry

Other languages let a source file carry notes for its next reader —
comments that explain a choice without changing what the program does. Try
adding one to the smallest program:

<!-- source: src/01-comment.ash -->
```ash
// explain this
main : Unit -> Int
main () = 1
```

The note is written for a reader; predict how the compiler answers it. Run
this program from `content/learn`:

<!-- diagnostic: src/01-comment.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en edges-of-the-language/src/01-comment.ash
Ash does not support comments.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/01-comment.ash:1:1
1 | // explain this
  | ^ Ash does not support comments.
reason: lex.comment
```
<!-- markdownlint-enable MD013 -->

The message names what it found — the whole `// explain this` line — and
states the rule in words. Its reason line, `lex.comment`, identifies the
message family for later comparison; the sentence above it carries the
teaching.

The refusal suggests the idiom. An Ash program explains itself through its
signature, its names, and small definitions whose scope is easy to see.
Longer explanations live beside the file, in a lesson or a document such as
this one. Every chapter you have read follows that arrangement: the prose is
the comment's home.

## Counting below zero

Ash counts `0`, `1`, `2`, and upward; every integer literal is nonnegative.
Suppose a calculation needs one less than zero:

<!-- source: src/02-negative-one.ash -->
```ash
main : Unit -> Int
main () = -1
```

Predict the compiler's answer before running it:

<!-- diagnostic: src/02-negative-one.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en edges-of-the-language/src/02-negative-one.ash
An expression is required here.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/02-negative-one.ash:2:11
2 | main () = -1
  |           ^ An expression is required here.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/02-negative-one.ash:2:13
2 | main () = -1
  |             ^ Parsing resumes at this boundary.
reason: parse.expected-form
```
<!-- markdownlint-enable MD013 -->

The parser expected an expression after `=`, and `-` cannot begin one: a
leading minus is not part of an integer literal. The second label marks where
parsing resumes; the compiler reports and stops, so a declined program never
runs in a damaged state.

Stand the question on its head. Without subtraction, a program seems unable
to count downward at all — so where would descent come from? Hold that
question; the next stop sharpens it, and the lesson after this one follows
it.

## The operators Ash declines

The arithmetic in this edition is exactly three operators: `+` and `*` on
integers, and `==`, which asks whether two integers are equal. A reader
arriving from another language expects a fourth operation on that list to
work:

<!-- source: src/03-subtract.ash -->
```ash
main : Unit -> Int
main () = 40 - 2
```

Here `40` is already a complete expression, so predict what the parser
expects where `-` appears. Run it:

<!-- diagnostic: src/03-subtract.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en edges-of-the-language/src/03-subtract.ash
A logical line end is required here.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/03-subtract.ash:2:14
2 | main () = 40 - 2
  |              ^ A logical line end is required here.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/03-subtract.ash:2:17
2 | main () = 40 - 2
  |                 ^ Parsing resumes at this boundary.
reason: parse.expected-form
```
<!-- markdownlint-enable MD013 -->

The message records a completed expression: after `40`, only the end of the
logical line is expected, and `-` cannot extend the line. There is no
subtraction to type-check because subtraction is not in the grammar — the
grammar, not the operand, is what declines.

Comparison meets the same boundary. Try asking whether one integer sits below
another:

<!-- source: src/04-less-than.ash -->
```ash
main : Unit -> Bool
main () = 1 < 2
```

Predict the message, then run it:

<!-- diagnostic: src/04-less-than.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en edges-of-the-language/src/04-less-than.ash
A logical line end is required here.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/04-less-than.ash:2:13
2 | main () = 1 < 2
  |             ^ A logical line end is required here.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/04-less-than.ash:2:16
2 | main () = 1 < 2
  |                ^ Parsing resumes at this boundary.
reason: parse.expected-form
```
<!-- markdownlint-enable MD013 -->

After `1`, the parser again expects the line to end; `<` plays its role in
declarations, not between expressions. What these operators would answer, Ash
programs build from data definitions — the next lesson shows the build. The
Cases path makes the same move at larger scale: its ordered tree derives
comparison by structural recursion over a data-built number type. The
boundary also excludes floating-point literals, character literals, and
integer literal patterns; the programs in this path need none of them.

## Composing conditions

The fourth lesson built decisions from `Bool`: `==` produces one, and `match`
spends it. Other languages also offer operators that combine Booleans, and
they are written with characters Ash's alphabet omits:

<!-- source: src/05-boolean-and.ash -->
```ash
main : Unit -> Bool
main () = true && false
```

Predict the answer, then run it:

<!-- diagnostic: src/05-boolean-and.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en edges-of-the-language/src/05-boolean-and.ash
This character cannot begin an Ash token.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/05-boolean-and.ash:2:16
2 | main () = true && false
  |                ^ This character cannot begin an Ash token.
reason: lex.unknown-character
This character cannot begin an Ash token.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/05-boolean-and.ash:2:17
2 | main () = true && false
  |                 ^ This character cannot begin an Ash token.
reason: lex.unknown-character
```
<!-- markdownlint-enable MD013 -->

The lexer — the stage that splits source into tokens — reports one message
per character: `&` cannot begin a token, so `&&` never reaches the parser.
Two unknown characters, two identical reports.

The idiom composes conditions without an operator. A `match` already selects
on a `Bool` directly, and the `choose` function of the fourth lesson routes a
condition to either of two results; when two conditions must hold together,
give the combination a name:

<!-- source: src/06-both.ash -->
```ash
both : Bool -> Bool -> Bool
both first second = match first {
    true => second
    false => false
}

main : Unit -> Bool
main () = both (20 + 22 == 42) (1 * 1 == 1)
```

Read `both` as a match on its first condition: when `first` is `true`, the
combined answer is whatever `second` is; when `first` is `false`, the
combination is `false`. Predict the call's result before running; Ash
answers `true : Bool`. A condition worth reusing is a condition worth
naming.

> **With a learning assistant:** Show the assistant one declined program from
> this lesson and its complete diagnostic. Ask which stage — lexer, parser,
> or type checker — produced each labelled part, and what rule its words
> name. Then explain the label positions back in your own words before
> asking for feedback.

## The operator's contract

The last stop is the subtlest, because the attempt looks almost legal. `+`
accepts two integer operands; what does the compiler say about an operand of
the wrong type?

<!-- source: src/07-bool-plus-int.ash -->
```ash
main : Unit -> Int
main () = true + 1
```

Predict the message before running it:

<!-- diagnostic: src/07-bool-plus-int.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en edges-of-the-language/src/07-bool-plus-int.ash
This operator requires an `Int` operand, but this operand has type `Bool`.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/07-bool-plus-int.ash:2:11
2 | main () = true + 1
  |           ^ This has type `Bool`.
  --> /path/to/ash-doc/content/learn/edges-of-the-language/src/07-bool-plus-int.ash:2:16
2 | main () = true + 1
  |                ^ This operator requires `Int` operands.
reason: type.operator-operand
```
<!-- markdownlint-enable MD013 -->

Unlike the earlier stops, this program parses; it fails one step later, when
types are checked. The two labels restate the operator's operand contract:
the label on `true` reports what the operand has, and the label on `+`
reports what the operator requires. The fix is the contract itself — give
`+` two `Int` operands — and when a calculation needs more than three
operators can say, an Ash program defines it from data, the move the next
lesson makes.

## Exercise: predict the boundary

Work in your scratch directory. Here are five tiny programs, each two lines
long, separated by blank lines. For each one, predict whether Ash accepts it.
For those you predict Ash accepts, predict the value and type it prints; for
those you predict it declines, predict which stage answers — lexer, parser,
or type checker — and what rule its words name. Then run all five and
reconcile each outcome with your prediction.

```text
main : Unit -> Int
main () = 6 * 7

main : Unit -> Bool
main () = 41 + 1 == 42

main : Unit -> Int
main () = 1 // one

main : Unit -> Bool
main () = 1 < 2

main : Unit -> Bool
main () = true == false
```

For any prediction that missed, read the message's labels again: each one
points at the character or operand where the rule engaged. Finish by writing
one more two-line program of your own that Ash accepts and that uses `==`;
predict its value and type before running it.

## The boundary is knowable

Six attempts, six answers — and each answer named its rule in words: no
comments, no negative literals, no subtraction, no ordering operators, no
boolean operators, and operator contracts checked before anything runs. Ash
declines at the exact stage responsible: the lexer for tokens, the parser for
grammar, the type checker for contracts.

The refusals were the lesson; the needs behind them are covered. Notes live
beside the program; conditions compose through `match` and named helpers; and
descent and comparison are built from data definitions, as the Cases path's
ordered tree already shows. Every need that arises in this book meets an
idiom in its remaining lessons.

One question stays open. With no subtraction and no ordering operators, how
does a program count downward or compare two numbers? The next lesson follows
that question: it defines a number type from data and builds comparison on
top of the definition.
