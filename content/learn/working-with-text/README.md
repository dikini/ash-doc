---
volatile: strings-bytes
---

# Working with text

Every result so far was an integer, a Boolean, or a tuple built from them.
A program that greets its user, signs a message, or answers with a word
works with text. Text is a value in Ash too. It has its own type, `String`,
and `ash` displays it beside its type, as it displayed `42 : Int`.

## A first piece of text

A string literal is text written between double quotes:

<!-- source: src/01-greeting.ash -->
```ash
main : Unit -> String
main () = "Hello, Ash!"
```

Predict what `ash` will display for this program, then run it:

```text
"Hello, Ash!" : String
```

The display puts the value in quotes and its type after the colon. The
quotes mark where the text begins and ends; the string is the text between
them, held as one value.

## A line break inside the quotes

Some characters cannot be typed directly between the quotes. The escape
`\n` stands for the line break, so one string can hold two lines:

<!-- source: src/02-escapes.ash -->
```ash
main : Unit -> String
main () = "line one\nline two"
```

Predict the displayed value before running it:

```text
"line one\nline two" : String
```

The value does not split across two output lines. The display repeats the
escape spelling `\n`, keeping the result readable as one string. Ash admits
six escapes: `\"` and `\\` write a quote and a backslash, `\n` and `\r`
write line breaks, `\t` writes a tab, and `\0` writes a NUL. The
[lexical structure][lexical] chapter lists them.

## Measuring text

How much text does a string hold? The `@builtin.string` module supplies
the [operations defined for strings][builtin]. It belongs to the `@builtin`
root, which names modules that ship with the compiler, so this import
needs no file of our own:

<!-- source: src/03-byte-length.ash -->
```ash
import @builtin.string as Text

main : Unit -> Int
main () = Text.byte_length "a\nb"
```

The alias `Text` gives the operations short qualified names.
`Text.byte_length` reports how many bytes the string's text occupies.
Count them here: a letter, one line break written as an escape, another
letter. Predict the integer before running:

```text
3 : Int
```

The escape `\n` counts once, as one character of the text.

## Text as bytes

A string is text. A program that stores text or sends it along works with
its bytes, and `Text.to_utf8` converts a string into those bytes:

<!-- source: src/04-to-utf8.ash -->
```ash
import @builtin.string as Text

main : Unit -> Bytes
main () = Text.to_utf8 "a\nb"
```

Predict the result's type and how many numbers its display will hold, then
run it:

```text
[97, 10, 98] : Bytes
```

The result's type is `Bytes`, displayed as a list of numbers, one per byte.
Three numbers appear, the same three that `byte_length` reported, so
measuring a string and converting it describe its text consistently. The
number in the middle is where the line break landed.

## Equality still belongs to integers

The choosing-a-result lesson asked whether two integers are equal with
`==`. The same question about two strings comes naturally. Predict whether
`ash` accepts this program, then run it from `content/learn` to compare
with the complete message:

<!-- source: src/05-string-equality.ash -->
```ash
main : Unit -> Bool
main () = "a" == "a"
```

`ash` refuses the program before running it:

<!-- diagnostic: src/05-string-equality.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en working-with-text/src/05-string-equality.ash
This operator requires an `Int` operand, but this operand has type `String`.
  --> /path/to/ash-doc/content/learn/working-with-text/src/05-string-equality.ash:2:11
2 | main () = "a" == "a"
  |           ^ This has type `String`.
  --> /path/to/ash-doc/content/learn/working-with-text/src/05-string-equality.ash:2:15
2 | main () = "a" == "a"
  |               ^ This operator requires `Int` operands.
reason: type.operator-operand
```
<!-- markdownlint-enable MD013 -->

The first label points at the left operand and reports its type, `String`.
The second label points at the operator itself and repeats its requirement:
operands of type `Int`. The [operator rules][primitive] fix those operand
types, and they cover addition too: in this edition `+` and `==` combine
and compare integers only, so no operator joins two strings into one. The
string module does supply a comparison by name — `Text.equal` takes the two
strings as one pair — but at this surface text is measured and converted,
not combined.

## Exercise: a two-line greeting

Start from a fresh copy of `src/03-byte-length.ash` in your scratch
directory.

A name tag holds two lines — `Hello,` on the first and `Ada` on the second
— built from one string literal. Adapt the program so that `main` displays
that string, then predict and check two more things: how many bytes
`Text.byte_length` reports for the greeting, and which number in the
`Text.to_utf8` display holds the line break.

## Text among the values

Text behaves like the values you already know: it displays beside its
type, and escapes write the characters the keyboard cannot. The
`@builtin.string` module measures text and converts it to bytes. What this
edition does not offer is an operator that combines strings; `+` and `==`
remain with integers.

A string suits text written at the point of use. A program also needs data
whose names say what a value means and which forms it may take; the next
lesson defines such data.

[lexical]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/lexical-structure.md#tokens
[builtin]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#independent-byte-and-string-modules
[primitive]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#primitive-operations
