# Rendering tool development report

Can ordinary Quarto book source preserve introductions, internal links, and
accessible figures in EPUB 3 and PDF? Five controlled failures cross those
conversion boundaries. This report separates them from the user's
[notation renderer findings](notation-renderer-bugs.md). It makes no Ash
language claim and changes no upstream source.

The browser capture limitation below is an integration observation, separate
from those five confirmed conversion failures.

## Evaluated tool boundary

The approved local review book and regression specimen use Quarto Book and
Typst. These observations use the downloaded and hash-checked tools in the
[rendering toolchain manifest](../../rendering/toolchain/manifest.json):

| Component | Evaluated version |
| --- | --- |
| Quarto | 1.10.19 |
| Bundled Pandoc | 3.10 |
| Bundled Typst | 0.15.1 |
| Bundled Orange Book package | 0.7.1 |
| EPUBCheck | 5.4.0 |
| Tested Java | Temurin 21.0.11+10 |

The Ash edition remains `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. The minimal books contain original
rendering fixtures, rather than Ash programs. They isolate tool behavior from
language semantics, diagram parsers, the specimen theme, and existing lessons.

The existing fixture probe covers QT-01 and QT-02 only. It runs each in its own
copied project and writes complete human captures, generated XHTML, statuses,
and a JSON report. From ash-doc, run:

```sh
python3 rendering/checks/rendering-tool-conformance.py \
    --quarto /path/to/quarto-1.10.19/bin/quarto \
    --epubcheck /path/to/epubcheck-5.4.0/epubcheck.jar \
    --output /tmp/ash-doc-tool-bugs-probe
```

Use a fresh output directory. The canonical fixtures are unchanged; passing
controls differ by one attribute or metadata field. The probe exits `0` when
the observed failures and controls agree. `--expect-fixed` instead requires
those two failing cases to succeed with candidate tools. QT-03 through QT-05
use the separate standalone book fixture and commands below.

## QT-01: figure alternative text becomes invalid EPUB XHTML

**Classification:** current EPUB conversion defect in the evaluated Quarto and
Pandoc combination. No earlier passing version is established.

The [canonical chapter][alt-source] uses a caption, figure identity, explicit
alternative text, and a self-contained SVG:

<!-- markdownlint-disable MD013 -->

```markdown
![A filled square.](square.svg){#fig-square fig-alt="A black square on white." width="100%"}
```

<!-- markdownlint-enable MD013 -->

Its [book configuration][alt-config] selects English metadata and EPUB 3.
The minimized render and validation commands, from the copied project, are:

```sh
quarto render . --to epub
java -jar /path/to/epubcheck-5.4.0/epubcheck.jar _book/figure-alt.epub
```

Quarto exits `0` and creates the EPUB. EPUBCheck exits `1`, with one `RSC-005`
error: the generated outer `div` has an `alt` attribute, which is not allowed
there. The nested image also has the intended alternative text. The
[complete captured message][alt-capture] includes the validator's entire list
of accepted attributes; it is not shortened in that capture. Its final summary
is:

```text
Check finished with errors
Messages: 0 fatals / 1 error / 0 warnings / 0 infos

EPUBCheck completed
```

The structural observation in `EPUB/text/ch001.xhtml` is:

```html
<div id="fig-square" class="quarto-float quarto-figure quarto-figure-center"
     alt="A black square on white.">
```

This excerpt identifies the rejected element; the probe retains the complete
generated XHTML. The generated `img` also carries
`alt="A black square on white."`. The correct image attribute does not make the
extra wrapper attribute valid.

Removing only `fig-alt` is the passing control: Quarto and EPUBCheck both exit
`0`, and no non-image element has `alt`. That control leaves the image's `alt`
empty, so deleting the description is not a suitable accessibility repair.

The bundled `share/filters/main.lua` code under `quarto_pre_figures` propagates
`fig-alt` to `float.attributes["alt"]` for HTML output. EPUB receives that
attribute on its wrapper. This is evidence for the conversion boundary; a
repair should confirm the full float-to-XHTML path before assigning the cause
to one filter or the Pandoc writer.

**Development prompt:** reproduce the fixture with the exact bundled versions,
then keep alternative text on the image without emitting an illegal wrapper
attribute. Preserve the caption, figure identifier, cross-reference target,
and image description. Add an EPUB schema validation test and an XHTML
structure test, with HTML and Typst controls for the same source. Do not make
the test pass by dropping the accessible description.

**Completion condition:** the unchanged `fig-alt` fixture produces EPUB 3 that
EPUBCheck accepts with zero errors and warnings; its image retains the exact
description, and its caption and figure identity remain present. Remove this
failure record after adopting verified tools. Keep the positive artifact
checks.

## QT-02: an omitted author breaks the bundled Typst book template

**Classification:** current failure of Quarto's bundled Orange Book defaults
with Typst 0.15.1. No earlier passing version is established.

The [minimal configuration][author-config] selects a book title, one chapter,
and Typst output. It omits `book.author` and uses the default template. From
its copied project, run:

```sh
quarto render . --to typst
```

The command exits `1`. The [complete failure capture][author-capture] retains
the compiler messages and Quarto's final error. The probe's separate render log
also retains the generated Pandoc options. The complete failure portion is:

```text
[typst]: Compiling index.typ to index.pdf...error: expected content, found array
    ┌─ @preview/orange-book:0.7.1/lib.typ:584:48
    │
584 │       #text(size: title-main-3, weight: "bold", author)
    │                                                 ^^^^^^

ERROR: error: expected content, found array
    ┌─ @preview/orange-book:0.7.1/lib.typ:584:48
    │
584 │       #text(size: title-main-3, weight: "bold", author)
    │                                                 ^^^^^^


ERROR: Typst compilation failed
```

Adding only `book.author: Ash documentation project` is the passing control:
the same chapter and default template compile with exit `0`.

The bundled Orange Book `lib.typ` defines `book` with `author: ()` at line 311.
Its cover passes that value to `text` at line 584. Quarto's
`typst-show.typ` supplies an author string only when author metadata exists.
When it does not, the package default is an array and the cover attempts to
typeset it as content. The failing source location and scalar control identify
that boundary directly.

**Development prompt:** make the default author value acceptable to the
template, or omit the author content when metadata is absent. Test omitted,
empty, scalar, and multiple-author metadata through Quarto's generated Typst,
not only by calling the package directly. Coordinate the package repair and
the Quarto bundle update; preserve books that already supply author metadata.

**Completion condition:** the unchanged no-author fixture produces a PDF with
the bundled default template, while the scalar-author control still succeeds.
The specimen supplies its own original book template; that selection does not
repair the upstream default. Remove this failure record after verified tool
adoption.

## Reproduce the book-navigation boundaries

The [minimal configuration][navigation-config] selects four original Markdown
files: [reader start][navigation-index], [first chapter][navigation-first],
[family introduction][navigation-family], and [last chapter][navigation-last].
The family file is a native book part. It contains a formatted title with an
explicit H1 anchor, a prose marker, one text block, and a link to the last
chapter. The other files distinguish bare forward links, an explicit forward
fragment, and backward links. The configuration supplies a scalar author and
uses the bundled default Typst template, so QT-02 does not confound the result.
It includes no ash-doc adapters, themes, diagrams, or lessons.

From ash-doc, copy it to a fresh scratch directory and render both formats:

```sh
navigation_quarto="$PWD/.build/toolchain/quarto-1.10.19/bin/quarto"
navigation_fonts="$PWD/rendering/fonts"
navigation_cache="$PWD/.build/toolchain/cache"
cp -R rendering/fixtures/conformance/quarto-book-navigation \
    /tmp/ash-doc-book-navigation
cd /tmp/ash-doc-book-navigation
XDG_CACHE_HOME="$navigation_cache" \
TYPST_FONT_PATHS="$navigation_fonts" TYPST_IGNORE_SYSTEM_FONTS=true \
SOURCE_DATE_EPOCH=0 NO_COLOR=1 \
    "$navigation_quarto" render --to epub --no-clean
XDG_CACHE_HOME="$navigation_cache" \
TYPST_FONT_PATHS="$navigation_fonts" TYPST_IGNORE_SYSTEM_FONTS=true \
SOURCE_DATE_EPOCH=0 NO_COLOR=1 \
    "$navigation_quarto" render --to typst --no-clean
```

The EPUB command exits `0` and writes `_book/book-navigation.epub`. The Typst
command exits `1`; `keep-typ: true` retains `index.typ` for inspection. The
[complete Typst failure capture][navigation-capture] records the compilation
messages and Quarto's final error. Use the same environment when repeating
either command for a control.
Inspection must include generated chapter content and destinations; an exit
status alone cannot detect the silently retained filename links or lost EPUB
introduction.

## QT-03: bare forward chapter links remain filename URLs

**Classification:** current single-file book link-resolution defect in the
evaluated Quarto and Pandoc combination, observed in EPUB and Typst. No earlier
passing version is established.

`index.md` links forward with `[Forward first](first.md)`. The EPUB stores
`href="first.md"` in `EPUB/text/ch001.xhtml`, although the selected first chapter
is packaged as `EPUB/text/ch002.xhtml`. There is no `first.md` archive member.
The first chapter's forward link to `last.md` likewise retains that filename.
The generated Typst contains:

```text
#link("first.md")[Forward first].
#link("last.md")[Forward last].
```

Those links do not address the selected chapters' labels. In a separate copy,
remove only `[Back family](family.md).` from `last.md` to avoid QT-05. Typst then
exits `0` and produces a PDF while retaining both filename links. The EPUB
already exits `0` with those unresolved destinations.

The explicit forward fragment `[Forward fragment](last.md#last-chapter)` is
the passing control in the unchanged fixture. It becomes
`ch003.xhtml#last-chapter` in the native-part EPUB and
`#link(<last-chapter>)[Forward fragment]` in Typst. The backward bare link
`[Back first](first.md)` also resolves to that chapter's original anchor in both
formats. The ordinary-chapter control below still leaves the bare forward
links unresolved, separating this failure from part conversion.

The bundled `share/filters/main.lua` indexes each file's first H1 into
`fileSectionIds` and resolves bare links through that map in one combined
preprocessing traversal. The forward/backward distinction is consistent with
looking up a destination before its heading has been visited. Explicit
fragments take a different branch that removes the filename prefix.

**Development prompt:** reproduce forward and backward bare links in one
single-file book with the exact bundle, then make every selected file's target
available before resolving links. Preserve explicit fragments and external
URLs. Test EPUB archive destinations and PDF heading destinations through the
generated artifacts, including links from a part introduction. Do not make the
test pass by changing author source to explicit fragments or treating selected
files as external URLs.

**Completion condition:** all unchanged selected bare links resolve to the
intended chapter or part heading in EPUB and Typst, in either direction; the
fragment and backward controls still pass. Remove this record after verified
tool adoption, retaining chapter-scoped link regressions.

## QT-04: EPUB drops a file-backed native part introduction

**Classification:** current Quarto single-file EPUB assembly defect. No earlier
passing version is established.

The native-part EPUB command above exits `0`, but its reading chapters and
navigation omit `Family introduction`, `Family retained marker.`, and
`part_example = 17`. The reader-start, first-chapter, and last-chapter markers
remain. The dropped material is ordinary Markdown in a selected file, not a
project-only fixture excluded by source selection.

In a separate copy, replace only the native part entry in `book.chapters` with
ordinary chapter entries, retaining all four source files:

```yaml
chapters:
  - index.md
  - first.md
  - family.md
  - last.md
```

Rendering this control as EPUB exits `0` and retains the family heading,
formatted title, prose marker, text block, original anchor, and navigation
destination. The control isolates native-part handling; the complete review
book still needs its family introductions and part organization together.

The bundled `bin/quarto.js` wraps the entire selected part file in a
`.quarto-book-part` Div. `cleanupBookPart` in `share/filters/main.lua` returns an
empty Div for formats other than LaTeX and Typst, including EPUB. The selected
part's title and body therefore disappear together.

**Development prompt:** retain the reader-facing content of a file-backed part
in EPUB while preserving native part grouping in formats that support it.
Compare the native-part fixture with the ordinary-chapter control and inspect
the EPUB spine and TOC as well as title, inline formatting, prose, code, and
anchors. Keep bare forward links in scope as the separate QT-03 boundary.

**Completion condition:** the unchanged native part appears in the EPUB
reading order before its lesson, with its complete title, body, code, anchor,
and navigation destination. The ordinary-chapter control still passes. Remove
this record after verified tool adoption, retaining the part-introduction
regression.

## QT-05: Typst discards a native part's original H1 anchor

**Classification:** current failure of the bundled Orange Book part conversion
to retain source identity in Typst. No earlier passing version is established.

The family source declares `{#family-introduction}` on its H1. The generated
Typst retains its title and body, but replaces that H1 with
`#part[Family introduction]` without the original label. The later backward
link becomes `#link(<family-introduction>)[Back family]`. Typst rejects that
missing destination. The complete failure portion of the retained capture is:

<!-- markdownlint-disable MD013 -->

```text
[typst]: Compiling index.typ to index.pdf...error: label `<family-introduction>` does not exist in the document
    ┌─ index.typ:492:1
    │
492 │ #link(<family-introduction>)[Back family].
    │  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ERROR: error: label `<family-introduction>` does not exist in the document
    ┌─ index.typ:492:1
    │
492 │ #link(<family-introduction>)[Back family].
    │  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


ERROR: Typst compilation failed
```

<!-- markdownlint-enable MD013 -->

The ordinary-chapter control from QT-04 exits `0` for Typst. It keeps
`<family-introduction>` on the family heading and resolves the same backward
link. Removing only that backward link from the native fixture also permits
compilation, but the missing label remains. That control separates a lost
destination from unrelated template or package failures.

The bundled Orange Book `orange-book.lua` replaces part H1 nodes with a raw
Typst `#part[...]` block assembled from their text. That replacement does not
carry `el.identifier`. The source H1 and ordinary-chapter control identify the
discarded anchor directly.

**Development prompt:** preserve each native part H1's original identifier on
the part heading produced by the bundled Typst extension. Render its inline
content without flattening or unsafe string insertion, and check that a link
lands on the intended heading's page. Test explicit part fragments and bare
links in both directions, separately accounting for QT-03. Keep the default
template and scalar-author control so the repair addresses the part boundary.

**Completion condition:** the unchanged native fixture compiles, its original
part label belongs to the intended heading, and part links reach that heading's
page. The ordinary-chapter and explicit chapter-fragment controls still pass.
Remove this record after verified tool adoption, retaining destination tests.

## QA-01: full-page browser capture can disturb mixed margin notes

**Classification:** browser QA and native margin-layout integration limitation.
This is not a confirmed persistent user-facing Quarto defect. Settled fresh
loads and ordinary viewport resizes passed with the evaluated tools.

The [canonical mixed-note fixture][mixed-source] places a static supplementary
diagram in a numbered note, followed nearby by an unnumbered `.column-margin`
reading cue. Its [configuration][mixed-config] uses Quarto Book's native margin
layout and a small note-style subset. The image retains explicit `fig-alt`;
diagram parsing is outside this check.

Copy the fixture to a fresh scratch directory and render it with the evaluated
Quarto version:

```sh
cp -R rendering/fixtures/conformance/mixed-margin-notes \
    /tmp/ash-doc-mixed-margin-notes
XDG_CACHE_HOME=/tmp/ash-doc-mixed-margin-notes/cache \
    /path/to/quarto-1.10.19/bin/quarto render \
    /tmp/ash-doc-mixed-margin-notes --to html
node rendering/fixtures/conformance/mixed-margin-notes/measure.mjs \
    /tmp/ash-doc-mixed-margin-notes/_book \
    /path/to/puppeteer/lib/puppeteer/puppeteer.js \
    /path/to/chrome \
    /tmp/ash-doc-mixed-margin-notes/evidence
```

The [measurement script][mixed-measure] uses Puppeteer 25.10.0 and Chrome
152.0.7977.75 at a 1440 by 1000 pixel viewport. It records an early sample after
navigation and font loading, a full-page screenshot, and the subsequent note
bounds. It then reloads, waits for font and image decoding and stable note
bounds, and checks ordinary width and height resizes and a viewport screenshot.
It writes complete JSON measurements and both screenshots. Early overlap is
recorded as an observation; the script requires the settled controls to pass.

The [retained capture][mixed-capture] records the numbered note from
`y=96.80` to `381.05` pixels. Before the early full-page screenshot, the reading
cue begins at `y=381.05`, clear of that note. Immediately after the capture it
begins at `y=203.70`, over the diagram. Waiting for stable bounds in that altered
capture state did not by itself restore the separation. A fresh settled load,
ordinary width and height changes, and a viewport capture kept the two notes
separate. The fixture render and the control measurement run both exit `0`.

Browser acceptance must wait for fonts, image decoding, and native margin
relayout before judging note placement. Prefer viewport captures for this
check, and measure the note bounds again after any capture or resize. Do not
treat a single early rectangle sample or screenshot as proof of a persistent
reading-layout failure. This observation does not require an upstream repair;
it identifies a timing and capture boundary for ash-doc's QA. Retain the fixture
while mixed note images remain part of the authoring guidance, and reassess
these controls when the browser or Quarto toolchain changes.

## Retention and exclusions

The local review book and specimen adapters may compensate for these boundaries
while preserving source descriptions and metadata. Such integration repairs
do not turn an upstream failing case into a passing one. This report retains the
unchanged upstream reproducers until verified tool updates make them obsolete.

The author, accessible figure, and book-navigation cases are independent of
railroad and sequent syntax. They do not justify changing those renderers,
changing Ash, or moving ash-doc's language checkpoint. Sandbox browser
restrictions, subprocess restrictions, and already corrected specimen mistakes
are not catalogued as upstream tool defects.

These fixtures and reports are original. The captures identify the exact
bundled tools; no template source is copied into this repository. The retained
toolchain manifest records download hashes, and the complete captures preserve
the observed human messages.

[alt-source]: ../../rendering/fixtures/conformance/quarto-fig-alt/index.qmd
[alt-config]: ../../rendering/fixtures/conformance/quarto-fig-alt/_quarto.yml
[alt-capture]: ../../rendering/fixtures/conformance/tool-captures/quarto-fig-alt-epubcheck.txt
[author-config]: ../../rendering/fixtures/conformance/quarto-no-author/_quarto.yml
[author-capture]: ../../rendering/fixtures/conformance/tool-captures/quarto-no-author-render.txt
[navigation-config]: ../../rendering/fixtures/conformance/quarto-book-navigation/_quarto.yml
[navigation-index]: ../../rendering/fixtures/conformance/quarto-book-navigation/index.md
[navigation-first]: ../../rendering/fixtures/conformance/quarto-book-navigation/first.md
[navigation-family]: ../../rendering/fixtures/conformance/quarto-book-navigation/family.md
[navigation-last]: ../../rendering/fixtures/conformance/quarto-book-navigation/last.md
[navigation-capture]: ../../rendering/fixtures/conformance/quarto-book-navigation/typst-render.txt
[mixed-source]: ../../rendering/fixtures/conformance/mixed-margin-notes/notes.qmd
[mixed-config]: ../../rendering/fixtures/conformance/mixed-margin-notes/_quarto.yml
[mixed-measure]: ../../rendering/fixtures/conformance/mixed-margin-notes/measure.mjs
[mixed-capture]: ../../rendering/fixtures/conformance/mixed-margin-notes/observations.json
