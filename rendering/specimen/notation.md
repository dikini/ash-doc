---
diagrams:
  - kind: mermaid
    id: fig-rendering-path
    caption: One source passes through checks before four layouts.
    description: Markdown is checked, then rendered as HTML, EPUB, book PDF, and A4 PDF.
  - kind: mermaid
    id: fig-interaction
    caption: A reader asks a build tool to prepare a book.
    description: The reader requests a build, the builder verifies sources and returns four artifacts.
  - kind: ebnf
    id: fig-grammar
    caption: A name is followed by zero or more comma-separated names.
    description: A list contains one name and a repeated comma and name; a name is either alpha or beta.
  - kind: sequent
    id: fig-inference
    caption: Two premises support one conclusion.
    description: From P and P implies Q, modus ponens derives Q; a nested fixture derives R.
---

# Notes and notation

This chapter is a rendering fixture. Its figures exercise layout and notation;
they make no claims about Ash behavior. The existing lessons in this specimen
provide the program and diagnostic material.

## Notes near their references

A note should remain associated with the sentence that introduces it.[^short]
The browser and printed book can place it in a margin. An e-reader needs a
linked note that remains reachable as its font size and line lengths change.
A one-sided A4 copy uses a footnote below the text.

[^short]: This short note tests the relationship between a reference and its
    associated explanation.

A longer note tests available space and the placement of nearby notes.[^long]
Neither note supplies an answer to an exercise in the existing chapters.

[^long]: This longer note contains several sentences so that a rendered page
    must allocate real space to it. The note is secondary material. Its text
    should stay readable when a narrow browser moves it out of the outer margin,
    when an EPUB reader enlarges the font, and when a PDF page contains another
    note nearby. The main paragraph should remain available in reading order.

## Output formats and print variants

The graph has one source and four outputs. Its labels should remain legible
at narrow widths and in a grayscale print.

```mermaid
flowchart TB
    source[Markdown source] --> checks[Source checks]
    checks --> prepare[Prepare book]
    prepare --> html[Responsive HTML]
    prepare --> epub[Reflowable EPUB 3]
    prepare --> pdf[PDF]
    pdf --> book[Double-sided book]
    pdf --> a4[One-sided A4]
```

## Interaction sequences

This sequence describes a build request and response. It is an interaction
sequence, separate from the inference-rule notation below.

```mermaid
sequenceDiagram
    participant Reader
    participant Builder
    Reader->>Builder: Prepare the specimen
    Builder->>Builder: Verify sources
    Builder-->>Reader: HTML, EPUB 3, book PDF, A4 PDF
```

## Railroad grammar

The grammar fixture combines alternatives, a reference to another production,
and repetition. The railroad renderer should retain those relationships in
its derived figure.

```ebnf
list ::= name { "," name } ;
name ::= "alpha" | "beta" ;
```

## Sequent inference rules

Each rule has premises above a bar and one conclusion below it. Formula
spelling and nested derivations belong to this specialised notation renderer.
The fixture uses propositional letters rather than Ash terms.

```sequent
family examples:
  Modus-Ponens :=
    P
    P -> Q
    ===>
    Q
  Nested :=
    [ P
      P -> Q
      ===>
      Q ]
    Q -> R
    ===>
    R
```

## A compact comparison

| Output | Reading behavior | Notes | Diagrams |
| --- | --- | --- | --- |
| HTML | Responsive chapters | Margin or linked | Static SVG |
| EPUB 3 | Reader-controlled reflow | Linked | Static SVG |
| Book PDF | Mirrored book pages | Outer margin | Vector figures |
| A4 PDF | One-sided pages | Footnotes | Vector figures |

The [first program](../../content/learn/what-is-an-ash-program/README.md) tests
an internal chapter link. The [writing workflow](../../docs/project/workflow.md)
tests a link to source material outside this specimen.
