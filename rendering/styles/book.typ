$if(pdf-a4)$
#set page(
  paper: "a4",
  numbering: "1",
)
$else$
#set page(width: 8in, height: 10in, numbering: "1")
$endif$
#set text(font: "TeX Gyre Pagella", size: 11pt, lang: "en")
#set par(justify: false, leading: 0.65em)
#set footnote.entry(separator: [])
#show raw: set text(font: "IBM Plex Mono", size: 8.5pt)
#show raw.where(block: true): set block(fill: none, inset: 0pt)
#set heading(numbering: none)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(above: 0pt, below: 18pt, text(size: 24pt, weight: "regular", it.body))
}
#let part(title) = heading(level: 1, numbering: none, title)
$if(pdf-a4)$
#show: marginalia.setup.with(
  inner: (far: 25mm, width: 0pt, sep: 0pt),
  outer: (far: 20mm, width: 50mm, sep: 6mm),
  top: 20mm,
  bottom: 20mm,
  book: false,
  clearance: 8pt,
)
$else$
#show: marginalia.setup.with(
  inner: (far: 0.75in, width: 0pt, sep: 0pt),
  outer: (far: 0.5in, width: 2in, sep: 0.25in),
  top: 0.75in,
  bottom: 0.75in,
  book: true,
  clearance: 8pt,
)
$endif$
#align(center, text(size: 26pt, [$title$]))
#pagebreak()
#outline(title: [Contents], indent: 1em, depth: 2)
#pagebreak()
