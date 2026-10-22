# Render the local review book

Can the complete verified learning work remain readable in a browser, a
reflowing e-reader, and a printed book? The local review book assembles the
indexed lessons for that presentation boundary. The smaller specimen retains
focused regressions for notes, diagrams, diagnostics, and long code.

The user approved Quarto Book, Typst, reflowable EPUB 3, a book PDF with generous
outer margins, a one-sided A4 PDF with left binding space, and evaluation of
the existing railroad and sequent renderers. The complete review book extends
that local choice with Learn → Libraries → Effects → Cases order and the four
family introductions. Canonical learning source remains authoritative.
All lesson material still targets `ffi-base`, Ash commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. The edition remains unpublished.

The writing skill's
[formatting reference](../../.agents/skills/writing-ash-documentation/references/formatting.md)
explains how authors choose these elements and write their source. This guide
retains the implementation and verification boundary.

## Selected sources and authority

Whole-book mode derives all lessons from the existing family indexes:

- [Learn](../../content/learn/README.md): fourteen lessons;
- [Libraries](../../content/libraries/README.md): eight lessons;
- [Effects](../../content/effects/README.md): twelve lessons; and
- [Cases](../../content/cases/README.md): twenty-eight lessons.

Each family keeps its indexed lesson order. Its reader-facing introduction
becomes a native Quarto book part before those lessons. Reader setup comes from
the root README. The book contains no project notation fixture; that fixture
remains in the specimen. Unindexed lesson directories do not enter either
selection merely because they exist. The current selection has 62 lessons.
The complete selection's artifact, EPUB, browser, and both PDF reviews
predate the Learn extension; the next whole-book build refreshes them.

The default [specimen configuration](../../rendering/specimen.json) selects
three complete, indexed lessons:

- [What is an Ash program?](../../content/learn/what-is-an-ash-program/README.md)
  supplies short programs and a complete rejection.
- [Guarantee logarithmic retrieval](../../content/cases/guaranteeing-logarithmic-retrieval/README.md)
  derives colored insertion through checked definition excerpts and a small
  complete repair client. Its prefix client develops observation data and
  operations through checked excerpts, with selected result components and a
  six-run summary checked against the complete capture. The later persistence
  client retains its longer listing and structural output. The lesson supplies
  all three note forms:
  a numbered sketch illustrates the count of black forms, a margin cue
  clarifies the height counts, and a wide comparison follows left-left repair
  into its common result.
- [Require element behavior](../../content/libraries/requiring-element-behavior/README.md)
  supplies multiline diagnostics and their source relationships.

Their directories retain canonical programs and existing checks. The specimen
derives its selected lesson order from the content and family indexes, rather
than sorting directories. All scopes extract shared reader setup and diagnostic
conventions from the root README. Included lessons and family introductions
link within the book. Other local source links point to an immutable ash-doc
commit. Those source links require that commit to be available on GitHub; an
unpushed local build does not publish its source snapshot.

The search-tree lesson labels its displayed definition and signature fragments
as non-executable and checks them against the complete canonical dictionary
and prefix client with a lesson-local standard-library comparison. Its complete
displayed clients retain the shared whole-program agreement check. The prefix
section labels its smaller observations as components of one returned value.
The complete stdout fixture retains the value and type, and its local check
compares the selected fields and six-run summary with that capture. The full
client still verifies against the pinned tool with empty stderr and status zero.
Preparation preserves the displayed code and observation text in every output.
These local conventions serve this teaching trial; other lessons retain their
existing source and transcript checks.

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

The complete review book extends the same adapter. A separately assembled
Quarto project would duplicate source order, styles, links, and checks; leaving
only the specimen would leave complete-book navigation and pagination
unobserved. The extension reads the existing indexes and uses native parts,
sharing the tool pins, cache, fonts, notes, assets, and print geometry. Its
generated records serve preparation and verification; this choice establishes
no general content registry.

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
and a prepared wide SVG have been checked in all four layouts; generated
figures now sit inside notes and wide regions through the same fence
conversion described below.

Preparation gives each chapter's note references and definitions a distinct
prefix while preserving source anchors and literal code. Pandoc still writes
each note's formatted body. This prevents separately staged chapters from
reusing one another's definitions when Quarto assembles EPUB and PDF.

HTML keeps the book TOC, local TOC, and previous/next navigation in chrome
outside the article. The right margin carries notes. A mobile disclosure
retains chapter navigation when Quarto hides its floating TOC. Local fonts and
assets supply the page; the theme's external web-font import is disabled.
Below 1200 pixels, the chapter disclosure remains available when a long book
sidebar would push the local TOC below the viewport.
On narrow screens, inline constructors and long identifiers wrap. Program
blocks retain their own horizontal scrolling.

EPUB 3 uses linked notes and reader-controlled reflow. Its separate CSS wraps
long identifiers and code, and lets narrow table cells break. The two PDF
variants share selectable body text, typography, and page breaks through long
code. An original narrow Typst show partial replaces the bundled book's cover
and decorative chapter styling.

For EPUB and Typst, a filter reads the existing generated source records before
Quarto processes the book. At this pin, a selected forward page link can remain
a filename URL. Bundled part handling also discards an introduction's original
H1 identifier in Typst and drops its entire part block in EPUB. The filter
changes selected page links to their original destination labels and preserves
explicit fragments. In EPUB it returns the part's heading and body to the
ordinary reading flow. In Typst it attaches each part label to its heading;
Pandoc renders the title's inline formatting, and a small shared Typst function
supplies the heading. HTML, staged Markdown, and canonical sources retain their
existing links and anchors. Focused regressions check the EPUB part title,
body, code, navigation, and forward link, and compile PDF links to their intended
headings and pages with the pinned tools.

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

The search-tree derivation also uses native wide Divs for selected long
signatures and equation groups. Their extra width makes parameters and cases
easier to follow at the shared 8.5 pt code size. Preparation records ordinary
code recursively, including code inside wide Divs, so source and output checks
retain these blocks in reading order. It converts diagram fences recursively
as well, so figures keep their positions inside wide regions and notes. Each
wide code block must fit one page in both PDFs
and stay clear of notes; narrow HTML and EPUB wrap the unchanged source text.
The formatting reference gives the authoring example and selection criteria.

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
`packages/core/src/index.js`. Build preparation requires the selected diagram
kinds' commits, clean tracked source, and the recorded hashes of each consumed
module or bundle. A Git commit alone cannot authenticate an ignored build artifact.

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

From ash-doc, prepare the cached toolchain and build the default specimen:

```sh
python3 rendering/bootstrap.py
python3 rendering/build.py \
    --railroad /path/to/railroad \
    --sequent /path/to/sequent-md
```

Build the complete review book with the same tools:

```sh
python3 rendering/build.py --whole-book \
    --railroad /path/to/railroad \
    --sequent /path/to/sequent-md
```

The default renderer paths are siblings of the primary Git checkout. The
explicit paths above make the dependency boundary visible. Quarto's cache and
Typst font search are controlled by the build command. Chromium may need
execution outside a restricted shell sandbox to create local process sockets.

The specimen's generated project stays in `.build/specimen/`. Its four outputs
under `output/` are `index.html`, `ash-doc-specimen.epub`,
`ash-doc-specimen.pdf` for the double-sided book, and
`ash-doc-specimen-a4.pdf` for one-sided A4 printing.

The complete review project stays in `.build/book/`, with `index.html`,
`ash-doc-review.epub`, `ash-doc-review.pdf`, and `ash-doc-review-a4.pdf` under
`output/`. Its title and output names distinguish it from the specimen. Both
projects retain each PDF's generated Typst source beside their staged chapters,
using the corresponding PDF basename and `.typ` extension.

Each project retains `build.json` with its scope, requested formats, title,
output basename, exact Ash and ash-doc commits, flattened chapter order, book
parts, and lesson count.
`sources.json` retains the selected canonical chapter paths and SHA-256 hashes,
staged filenames, source titles and anchors, complete code/transcript blocks,
and source asset records. Whole-book records distinguish introductions from
lessons and name their families. These are generated build records, rather than
a second source registry. Preparation records ash-doc's current commit for
source links and hashes the current canonical files; rebuild after source
changes.

To render a prepared A4 copy independently, use the same controlled toolchain
environment as `build.py` and run `quarto render --to typst --profile a4
--no-clean` from the generated project. The second render keeps the existing
HTML, EPUB, and book PDF. Rebuild through `build.py` after source changes.

`python3 rendering/bootstrap.py --offline` validates the already prepared
tools without downloading. The build then uses local assets. Repeated diagram
generation is checked for byte agreement. Whole-book byte identity is not
claimed: Quarto and Pandoc retain generated identifiers and output metadata.

## Build a selected scope

A lesson review should assemble that lesson. A part review should assemble its
introduction and indexed lessons. Both share the book's adapters, fonts, styles,
and tool pins. Filtering an already assembled whole book would retain its cost;
these selections happen before staging or rendering. Caching can be reconsidered
if measurements expose substantial remaining work within a selected scope.

Scope and output formats are independent:

| Selection | Generated project |
| --- | --- |
| No scope flag: specimen | `.build/specimen/` |
| `--lesson <lesson-path>` | `.build/lessons/<family>/<lesson>/` |
| `--part <family>` | `.build/parts/<family>/` |
| `--whole-book` | `.build/book/` |

Lesson outputs use the basename `ash-doc-<family>-<lesson>`; part outputs use
`ash-doc-<family>`.

Choose one scope flag. A lesson must be linked from its active family index;
unindexed drafts and paths outside the repository are rejected. A part retains
its introduction and indexed lesson order. Scoped builds include shared reader
setup; links to excluded chapters use the existing immutable source-link rule.

Without `--formats`, the build renders HTML, EPUB 3, book PDF, and A4 PDF.
Choose one or more of `html`, `epub`, `pdf`, and `pdf-a4` for a narrower review:

```sh
# Review a lesson in both print layouts.
python3 rendering/build.py \
    --lesson content/cases/resuming-tree-traversal/README.md \
    --formats pdf pdf-a4

# Review a part's browser navigation.
python3 rendering/build.py --part learn --formats html

# Prepare the complete book without rendering it.
python3 rendering/build.py --whole-book --prepare-only
```

`--output <directory>` overrides the generated project location. A directory
already prepared for another scope is rejected, so one draft cannot overwrite
another. Rebuilding the same scope with different formats is allowed. Older,
unrequested outputs may remain available there; they are not repaired or counted
as current verification evidence. `build.json` records the scope, selected
lesson or part, and requested formats. Artifact and browser checks use those
records, and never substitute another scope or format when one is missing.

Use the same project directory for the selected checks:

```sh
project=.build/lessons/cases/resuming-tree-traversal
python3 rendering/checks/verify.py "$project"
node rendering/checks/browser.mjs "$project"
```

For a PDF-only build, the artifact checker verifies only those PDFs and selected
sources; browser review reports that it does not apply without launching a
browser. HTML-only review never opens an EPUB. EPUB-only review never opens HTML
pages. Run EPUBCheck only when EPUB is selected. Complete-book pagination still
requires a complete-book render.

## Static notation and known tool boundaries

The fixture's YAML `diagrams` list is a concrete metadata consumer. Each entry
has `kind`, unique `id`, `caption`, and `description`, in fence order. The
supported fences are bare `mermaid`, `ebnf`, `sequent`, and `split`. Mermaid
covers both graphs and interaction sequences. Invalid notation fails the build
with its source path, line, and column; no malformed figure silently replaces
it.

Every generated figure takes its typefaces and palette from the normative
[style contract](../../rendering/styles/diagram-style.json): TeX Gyre Pagella
and IBM Plex Mono, the book's own faces, and palette roles mirroring the
design tokens, with the split vocabulary's categorical hues recorded as
contract data. A whitelist check fails the build on any generated paint
outside the contract, so renderer defaults cannot ship silently. The
formatting reference names the contract for authors.

The asset adapter reuses the existing railroad and sequent parsers, and the
pinned split-md renderer consumes the contract through render options.
Railroad geometry receives standalone dimensions and painting styles. Sequent
HTML layout supplies measured text and inference bars. A pinned browser and
fonts then derive vector glyph paths for all figures. This avoids font
substitution in standalone SVG images across outputs. SVG descriptions retain
the canonical notation and explanation; captions and surrounding prose remain
readable. Diagram glyphs are shapes and are not selectable text. Body programs
and diagnostic text remain selectable.

Self-contained assets have explicit viewports, no browser scripts or HTML
foreign objects, and no external image or font resources. Short railroad
figures use a bounded width so responsive scaling keeps their labels readable.

Native Markdown images can also reference checked-in, outlined SVG files
within their lesson directory. Preparation visits images inside notes and
Divs as well as ordinary paragraphs, preserves captions and layout
attributes, and copies unchanged bytes into distinct generated asset paths.
Each chapter's source record retains its image paths and SHA-256 values.
Missing, escaping, or nonportable SVG inputs fail preparation. Diagram fences
themselves convert at any depth — body column, notes, margin Divs, and wide
Divs — keeping each figure where its fence sits, and their YAML entries
follow source order wherever the fences appear.

The split-shape figures in the currying and search-tree lessons render from
`split` fences at their accepted positions, including the grouped margin note
and the numbered footnote sketches. Their vocabulary and captions are
unchanged; the figure sources are the fences. The annotated wide
`tree-repair` composite remains a checked-in static SVG whose bespoke
annotations sit outside the v1 notation. The [split-md conformance
corpus](https://github.com/dikini/split-md) pins the eight figures' structure
and geometry at the renderer's commit.

The [notation renderer report](notation-renderer-bugs.md) retains three
confirmed defects, separately classified integration gaps, executable controls,
and proposed priorities for the specialised sequent renderer. The
[rendering tool report](rendering-tool-bugs.md) retains five independent Quarto
conversion failures and a separate browser-capture limitation for mixed margin
notes. Its existing automated conformance probe covers the figure and author
cases; separate native-book fixtures isolate the link and part boundaries.
No upstream repository was changed.

For QT-01, both builds keep Quarto's image alternative text and remove only
the illegal `alt` attribute from generated figure wrapper `div` elements in
HTML and EPUB. Its regression check confirms that the image description
survives. Remove this compensation after unchanged upstream fixtures validate
with adopted tools. The original Typst partial also avoids the defective
bundled no-author cover default; it does not repair that default.

## Verify the affected scope

Follow the [task boundary](workflow.md#bound-the-task). Run affected lesson
checks when canonical programs, observations, promises, checks, or compiler
inputs change, as described in the [verification guide](verification.md).
Reuse exact-pin evidence for unchanged inputs during a rendering task. A lesson
review does not run the four family aggregates or build the complete book.

When changing shared rendering infrastructure, run its affected preparation,
artifact, and browser helper regressions:

```sh
python3 -m unittest discover -s rendering/checks -p 'test_*.py'
node --test --test-isolation=none rendering/checks/browser.test.mjs
```

Verify the complete book explicitly:

```sh
python3 rendering/checks/verify.py .build/book
node rendering/checks/browser.mjs .build/book
java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
    .build/book/output/ash-doc-review.epub
```

The no-argument artifact and browser commands retain the specimen workflow:

```sh
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

The preparation checks cover source text, index order, part introductions,
internal and immutable source links, rejection of unindexed lesson inputs, and
the figure-wrapper repair. Artifact checks independently read the canonical
indexes and verify complete selection and order, source hashes, and build
identity. Each HTML and EPUB source chapter retains its title and complete
code/transcript blocks. EPUB association follows its package spine, headings,
anchors, and navigation, rather than chapter-number offsets. Links and source
assets are checked in both formats. The specimen also retains all four static
notation cases.

PDF checks compare code characters after visual whitespace and page-footer
normalization. Both PDFs check actual chapter reading order, paper dimensions,
text bounds, body margins on odd and even pages, and their distinct note
placement. The specimen's full-width aside must retain its text and formatting,
extend into the note area, avoid note collisions, and reflow in narrow browser
and EPUB previews. Both builds retain the search-tree checks: wide lesson code
must remain complete on one print page, within the body and outer margins and
clear of notes, and repair units retain their reading order. Focused regressions
reject reordered chapters, split blocks, missing characters, invalid bounds,
and note collisions.

The browser check visits all manifest chapters in desktop and mobile HTML. It
compares book and previous/next navigation with their complete order, derives
local navigation from staged source headings, and checks keyboard use, code
overflow, notes, image descriptions, and local-only resource requests. It also
inspects extracted EPUB chapters at enlarged text in Chromium and the available
Firefox, using their spine and source headings to identify chapters. Those are
browser reflow checks, not evidence for physical e-readers or every EPUB reading
system. Inspect the book in intended readers before publication.

Render PDF pages with Poppler and inspect their typography, note placement,
diagram labels, code alignment, table wrapping, and page breaks. Browser
screenshots and structured observations stay under each build's `qa-browser/`,
so `.build/book/qa-browser/` and `.build/specimen/qa-browser/` retain separate
evidence.
The conformance probes documented in the two development reports retain the
upstream failures separately from specimen success. Lint changed Markdown and
run ShellCheck when Bash changes. Review affected links and source, then run
`git diff --check`.

## Scoped build evidence

On October 21, 2026, the complete review book was rebuilt for FFI Base at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`, using the declared Quarto, Typst,
and renderer pins. Its ash-doc build identity is
`73f11abc03d26bae2b9f20e4f908509dd5c12c2d`. It selects all 61 lessons and
four family introductions in indexed order. Artifact checks verify
67 HTML pages, 65 source chapters, one canonical asset, and 780 complete code
and transcript blocks across HTML, EPUB, and the two PDFs. The book PDF has
474 pages; the one-sided A4 PDF has 415.

The book EPUB passes EPUBCheck without errors or warnings. Browser checks cover
desktop and mobile HTML and enlarged EPUB text in Chromium and Firefox. These
previews do not establish physical e-reader compatibility. Visual review
inspected all pages of A1–A8 in both PDF layouts, including their complete code,
diagnostics, pagination, tables, chapter order, and navigation. These Cases
add no notes or diagrams; shared checks retain the existing note and figure
regressions.

PDF checks retain exact code characters, page order, paper sizes, and print
geometry. Where a margin caption interleaves with code in Poppler's full-page
text, the comparison uses words inside the measured body column. It cannot
borrow missing code from a margin note. Four focused controls cover odd and
even book pages, the A4 note column, and the original wide-code comparison.
The rendering suite passes 101 tests; browser helpers pass twelve.

The default specimen was rebuilt on October 21 at ash-doc commit
`f5c36bdae0e17b3297376939ca8d9a7c81ced609`, with the same FFI Base and
rendering pins, after the split-shape figures migrated to notation fences.
It verifies three lessons, six HTML pages, eleven generated diagrams, one
canonical asset, and 87 complete code and transcript blocks. Its book PDF
has 56 pages and its A4 PDF has 46. Its EPUB passes EPUBCheck without errors or
warnings; browser checks cover desktop and mobile HTML and enlarged EPUB text
in Chromium and Firefox. The sequent renderer uses an isolated clean checkout
at its declared pin because the sibling development checkout has advanced.

Later project-record edits reuse these outputs only while canonical chapter
hashes, the extracted reader-setup AST, styles, tool pins, assets, shared HTML
token bytes, and indexed selection remain unchanged. Read-only artifact checks
must pass again at the final record revision. These checks preserve the build
identities above; a later record commit is not another render.

Shared checks continue to cover selection, format dispatch, output isolation,
source identity, and layout. Scoped tasks still select only their affected
lessons, parts, and formats. This complete rebuild verifies local book
integration; it does not publish the edition.

## Replacement and publication boundary

Revisit Quarto if maintaining source preservation, links, accessible figures,
or readable pagination requires substantial template forks or recurring lesson
rewrites. Replace a local adapter when a verified upstream interface supplies
its function, retaining the artifact checks. Remove resolved bug records after
adopting verified tool or renderer commits; Git retains earlier evidence.

Revisit whole-book assembly when another complete outcome needs a different
selection or order, or the shared adapter cannot preserve source meaning and
readable pagination. Remove the EPUB and Typst link and part compensation when
adopted Quarto tools pass the unchanged forward-link, part-introduction, and
part-anchor regressions.

This decision establishes a bounded local review book and retained regression
specimen. It selects no hosting, CI service, publication mechanism, or
repository-wide license. A publication still requires the complete edition's
checks and its immutable `ffi-base` tag under the existing project workflow.

## Shared HTML palette

See [shared design tokens](design-tokens.md) for the website token contract,
HTML ownership, and synchronization commands.
