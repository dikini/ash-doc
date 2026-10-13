# Render the local book specimen

Can the same verified explanation, program, and diagnostic remain readable in
a browser, a reflowing e-reader, and a printed book? The first rendering
specimen tests that presentation boundary without changing learning source or
Ash behavior.

The user approved Quarto Book, Typst, reflowable EPUB 3, a book PDF with generous
outer margins, a one-sided A4 PDF with left binding space, and evaluation of
the existing railroad and sequent renderers.
All lesson material still targets `diag-ash`, Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. The edition remains unpublished.

The writing skill's
[formatting reference](../../.agents/skills/writing-ash-documentation/references/formatting.md)
explains how authors choose these elements and write their source. This guide
retains the implementation and verification boundary.

## Selected sources and authority

The [specimen configuration](../../rendering/specimen.json) selects three
complete, indexed lessons:

- [What is an Ash program?](../../content/learn/what-is-an-ash-program/README.md)
  supplies short programs and a complete rejection.
- [Guarantee logarithmic retrieval](../../content/cases/guaranteeing-logarithmic-retrieval/README.md)
  supplies a table, a 248-line listing, a 1,721-character output line, and all
  three note forms. A numbered sketch illustrates the count of black forms,
  a margin cue clarifies the height counts, and a wide
  comparison follows left-left repair into its common result.
- [Require element behavior](../../content/libraries/requiring-element-behavior/README.md)
  supplies multiline diagnostics and their source relationships.

Their directories retain canonical programs and existing checks. The
preparation step derives selected lesson order from the content and family
indexes, rather than sorting directories. It extracts shared reader setup and
diagnostic conventions from the root README. Unselected local source links
point to an immutable ash-doc commit; included chapters link within the book.
Those source links require that commit to be available on GitHub; an unpushed
local build does not publish its source snapshot.

The separate [notation fixture](../../rendering/specimen/notation.md) contains
two notes, a table, Mermaid graph and interaction sequence, EBNF railroad
grammar, and nested sequent inference rules. It is labelled rendering material
and makes no Ash language claim. A sequent rule is not an interaction sequence.

## Rendering choice

| Approach | Responsibility retained locally |
| --- | --- |
| Quarto Book and Typst | Source preparation, styles, diagrams, and checks |
| Direct Pandoc templates | Those checks plus navigation and coordination |

Quarto Book is selected for the first specimen because it already assembles
chapters and coordinates the required outputs. Deferring that choice would
leave the existing long listings and diagnostics untested in book layouts.
Markdown and declarative diagram sources remain replaceable inputs.

The typography and relationship between prose, notes, and figures draw
inspiration from [Tufte CSS](https://edwardtufte.github.io/tufte-css/). The local
styles are original. They do not copy Tufte's book pages or illustrations.

The writing skill's note guidance also draws on Tufte's own comments in
[Sidenotes or footnotes or what?](https://www.edwardtufte.com/notebook/sidenotes-or-footnotes-or-what/),
dated September 13, 2003 and September 4, 2006. It adapts the principle that
annotations serve a content need. The numbered sidenote, unnumbered margin
note, and full-width aside are ash-doc authoring conventions, rather than a
taxonomy prescribed in that discussion. The formatting reference also gives
figure-width review criteria using aspect ratio, label scale, and page height.
Width remains an author choice informed by rendered output.

Numbered sidenotes attach optional detail or credit to specific words.
Unnumbered `.column-margin` notes supply brief local reminders, including
legible supplementary sketches. Full-width regions can hold diagrams,
illustrations, tables, or other content needing the space. Notes must assist
understanding without competing with the main account. Native note placement
and a prepared wide SVG have been checked in all four layouts; bare diagram
fences retain the top-level conversion boundary described below.

Preparation gives each chapter's note references and definitions a distinct
prefix while preserving source anchors and literal code. Pandoc still writes
each note's formatted body. This prevents separately staged chapters from
reusing one another's definitions when Quarto assembles EPUB and PDF.

HTML keeps the book TOC, local TOC, and previous/next navigation in chrome
outside the article. The right margin carries notes. A mobile disclosure
retains chapter navigation when Quarto hides its floating TOC. Local fonts and
assets supply the page; the theme's external web-font import is disabled.

EPUB 3 uses linked notes and reader-controlled reflow. Its separate CSS wraps
long identifiers and code, and lets narrow table cells break. The two PDF
variants share selectable body text, typography, and page breaks through long
code. An original narrow Typst show partial replaces the bundled book's cover
and decorative chapter styling.

## PDF print variants

The default build produces both variants from the same staged chapters and
static figures:

| Variant | Paper and margins | Notes |
| --- | --- | --- |
| Double-sided book | 8 by 10 inches; mirrored margins | Outer margin |
| One-sided A4 | Fixed binding space and a wider right note area | Sidenotes |

The book keeps its existing geometry: a 0.75 inch inner margin and a 2.75 inch
outer area comprising the note column, its separation, and the paper edge.
The left and right areas alternate by page parity for double-sided printing.

A4 uses fixed geometry on every page: 25 mm on the left for binding, 20 mm
above and below, and a 50 mm right note column with 6 mm separation from the
text and 20 mm to the paper edge. The main column is 109 mm wide; the main and
note columns together use 165 mm. The short and long notes use smaller
secondary type, retain their reference numbers, and stay beside their
references without overlapping. Choose one-sided printing for this copy.

Both PDF profiles set `reference-location: margin`. Marginalia alternates the
book's outer note area by page parity; A4 uses fixed left/right geometry with
notes always on the right. EPUB retains linked notes within its reading flow.
The shared print style removes the empty bottom separator left after margin
conversion; it retains the numbered sidenotes.

A Quarto `a4` profile changes the PDF filename and page setup. Shared note
handling, typography, and front matter remain in one Typst partial.
Separate complete templates would duplicate those choices. Leaving A4 to a
printer's scaling control would not verify binding space or note placement.

## Full-width formatting

The notation fixture includes an unnumbered full-width aside with a paragraph,
emphasis, inline monospace text, and a table. Its fenced Div uses
`{#full-width-note .column-page-right}`. This native Quarto class spans the body
and adjoining note area while retaining the binding margin and leaving HTML
navigation outside the content. In the mirrored book it expands into the
outer area; in A4 it expands to the right. Mobile HTML and EPUB return it to
their available reading width.

The example begins with Quarto's standalone `{{< pagebreak >}}` directive so
the paragraph and table stay together. Preparation preserves that exact
directive through its Pandoc Markdown round-trip. In PDF it begins a new page;
EPUB carries the same page-break request, while screen HTML retains its
continuous reading flow.

Keep the print example short enough to stay on one page. The pinned Marginalia
package does not reliably handle a wide block across mirrored page breaks.
Artifact checks require the entire paragraph and table on one page, with no
intersection between its text and any sidenote. Revise this bound only after
verifying a layout implementation that handles longer blocks.

## Tool and renderer pins

The [toolchain manifest](../../rendering/toolchain/manifest.json) records the
download URLs, archive SHA-256 values, exact dependency versions, and hashes of
font files and notices:

- Quarto 1.10.19, bundling Pandoc 3.10 and Typst 0.15.1;
- EPUBCheck 5.4.0;
- Mermaid CLI 12.0.0, Mermaid 12.1.0, Puppeteer 25.10.0, and
  Chrome 152.0.7977.75; and
- Poppler's `pdftocairo` 26.01.0 for portable diagram glyphs.

The evaluated runtime uses Python 3.12, Node 24.0.1, and Java 21.0.11.
The current bootstrap targets Linux x86_64. It installs into ignored local
storage and redirects caches there; it performs no host package installation.

Railroad is evaluated at `366d5eaa937e9e9fbae3bf8d44265ccc2c528067`.
Its callable input is `dist/rehype.js`. Sequent is evaluated at
`21dad3d34b206b7964d2dd7edcab89a7b8f2b612`; its core input is
`packages/core/src/index.js`. Build preparation requires these commits, clean
tracked source, and the separately recorded hashes of the consumed module or
bundle. A Git commit alone cannot authenticate an ignored build artifact.

The fresh railroad source rebuild produced the same bundle hash recorded in
the specimen configuration. It used the exact source archive, frozen npm
dependencies, sbt 1.11.2, Node 24.0.1, npm 11.3.0, and Java 21.0.11. All six
upstream test files passed. The temporary sbt launcher is evaluation evidence;
it is not a maintained specimen dependency installer.

Use the evaluated local checkouts, or build fresh copies of those exact
sources. The railroad build needs Node, Java 17 or later, and sbt; its ignored
local sbt pin is a retained upstream gap. The bootstrap does not provision or
repair that upstream build. Do not regenerate a bundle hash merely to make a
different build pass; review its source and tool boundary first.

## Prepare and build

From ash-doc, prepare the cached toolchain and build the specimen:

```sh
python3 rendering/bootstrap.py
python3 rendering/build.py \
    --railroad /path/to/railroad \
    --sequent /path/to/sequent-md
```

The default renderer paths are siblings of the primary Git checkout. The
explicit paths above make the dependency boundary visible. Quarto's cache and
Typst font search are controlled by the build command. Chromium may need
execution outside a restricted shell sandbox to create local process sockets.

The result is `.build/specimen/output/index.html`,
`.build/specimen/output/ash-doc-specimen.epub`,
`.build/specimen/output/ash-doc-specimen.pdf` for the double-sided book, and
`.build/specimen/output/ash-doc-specimen-a4.pdf` for one-sided A4 printing.
The complete generated Quarto project stays in `.build/specimen/`; source
records retain each input path, source hash, and code/transcript text.
Each PDF's generated Typst source is also retained there as
`ash-doc-specimen.typ` and `ash-doc-specimen-a4.typ`.

To render a prepared A4 copy independently, use the same controlled toolchain
environment as `build.py` and run `quarto render --to typst --profile a4
--no-clean` from the generated project. The second render keeps the existing
HTML, EPUB, and book PDF. Rebuild through `build.py` after source changes.

`python3 rendering/bootstrap.py --offline` validates the already prepared
tools without downloading. The build then uses local assets. Repeated diagram
generation is checked for byte agreement. Whole-book byte identity is not
claimed: Quarto and Pandoc retain generated identifiers and output metadata.

## Static notation and known tool boundaries

The fixture's YAML `diagrams` list is a concrete metadata consumer. Each entry
has `kind`, unique `id`, `caption`, and `description`, in fence order. The
supported fences are bare `mermaid`, `ebnf`, and `sequent`. Mermaid covers both
graphs and interaction sequences. Invalid notation fails the build with its
source path, line, and column; no malformed figure silently replaces it.

The asset adapter reuses the existing railroad and sequent parsers. Railroad
geometry receives standalone dimensions and painting styles. Sequent HTML
layout supplies measured text and inference bars. A pinned browser and fonts
then derive vector glyph paths for all four figures. This avoids font
substitution in standalone SVG images across outputs. SVG descriptions retain
the canonical notation and explanation; captions and surrounding prose remain
readable. Diagram glyphs are shapes and are not selectable text. Body programs
and diagnostic text remain selectable.

Self-contained assets have explicit viewports, no browser scripts or HTML
foreign objects, and no external image or font resources. Short railroad
figures use a bounded width so responsive scaling keeps their labels readable.

Native Markdown images can also reference checked-in, outlined SVG files within
their lesson directory. Preparation visits images inside notes and Divs as
well as ordinary paragraphs, preserves captions and layout attributes, and
copies unchanged bytes into distinct generated asset paths. Each chapter's
source record retains its image paths and SHA-256 values. Missing, escaping,
or nonportable SVG inputs fail preparation. This boundary does not add nested
diagram-fence conversion or a placement schema for generated notation.

The search-tree figures are original source diagrams with labels derived from
the canonical program. Their descriptions retain the editable SVG source.
The evaluated font-outline helpers generated their standalone glyph paths;
regeneration of the book uses the checked-in figures directly.

The [notation renderer report](notation-renderer-bugs.md) retains three
confirmed defects, separately classified integration gaps, executable controls,
and proposed priorities for the specialised sequent renderer. The
[rendering tool report](rendering-tool-bugs.md) retains two independent Quarto
failures and a separate browser-capture limitation for mixed margin notes.
No upstream repository was changed.

For QT-01, the specimen keeps Quarto's image alternative text and removes only
the illegal `alt` attribute from generated figure wrapper `div` elements in
HTML and EPUB. Its regression check confirms that the image description
survives. Remove this compensation after unchanged upstream fixtures validate
with adopted tools. The original Typst partial also avoids the defective
bundled no-author cover default; it does not repair that default.

## Verify the specimen

Run the existing checks for all three selected lessons against the exact Ash
checkout, as described in the [verification guide](verification.md). Then run:

```sh
python3 -m unittest discover -s rendering/checks -p test_build.py
python3 rendering/checks/verify.py
node rendering/checks/browser.mjs
java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
    .build/specimen/output/ash-doc-specimen.epub
```

The static export checks need the same explicit renderer and tool paths:

```sh
mermaid_dir="$PWD/.build/toolchain/mermaid/node_modules"
browser_dir="$PWD/.build/toolchain/browser-cache/chrome"
RAILROAD_BUNDLE=/path/to/railroad/dist/rehype.js \
SEQUENT_BUNDLE=/path/to/sequent-md/packages/core/src/index.js \
MMDC="$mermaid_dir/.bin/mmdc" \
PUPPETEER_MODULE="$mermaid_dir/puppeteer/lib/puppeteer/puppeteer.js" \
CHROME_BIN="$browser_dir/linux-152.0.7977.75/chrome-linux64/chrome" \
DIAGRAM_FONTS="$PWD/rendering/fonts" \
PDFTOCAIRO=/path/to/pdftocairo \
    node rendering/checks/diagrams.test.mjs
```

The preparation checks cover source text, index order, internal and immutable
source links, rejection of unindexed lesson inputs, and the figure-wrapper
repair. Artifact checks cover six HTML pages, EPUB links and notes, all four
static diagrams, and all code/transcript blocks in each output. PDF checks
compare characters after visual whitespace and page-footer normalization;
HTML and EPUB preserve complete preformatted text directly. Both PDFs are
checked for paper dimensions, text bounds, body margins on odd and even pages,
and their distinct note placement. The full-width aside must retain its text
and formatting, extend into the note area, avoid note collisions, and reflow in
narrow browser and EPUB previews.

The browser check inspects desktop and mobile HTML, code overflow, navigation,
keyboard use, notes, image descriptions, and local-only resource requests. It
also inspects extracted EPUB chapters at enlarged text in Chromium and the
available Firefox. Those are browser reflow checks, not evidence for physical
e-readers or every EPUB reading system. Inspect the book in intended readers
before publication.

Render PDF pages with Poppler and inspect their typography, note placement,
diagram labels, code alignment, table wrapping, and page breaks. Browser
screenshots and structured observations stay under `.build/qa/`.
The conformance probes documented in the two development reports retain the
upstream failures separately from specimen success. Finish with Markdown lint,
ShellCheck, relative-link review, source inspection, and `git diff --check`.

## Replacement and publication boundary

Revisit Quarto if maintaining source preservation, links, accessible figures,
or readable pagination requires substantial template forks or recurring lesson
rewrites. Replace a local adapter when a verified upstream interface supplies
its function, retaining the artifact checks. Remove resolved bug records after
adopting verified tool or renderer commits; Git retains earlier evidence.

This decision establishes one local rendering specimen. It selects no hosting,
CI service, publication mechanism, or repository-wide license. A publication
still requires the complete edition's checks and its immutable `diag-ash` tag
under the existing project workflow.
