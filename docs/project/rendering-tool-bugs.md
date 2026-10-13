# Rendering tool development report

Can a maintainer give Quarto ordinary book metadata and an accessible figure,
then receive valid EPUB 3 and PDF output? Two controlled cases found failures
in the bundled conversion tools. This report separates them from the user's
[notation renderer findings](notation-renderer-bugs.md). It makes no Ash
language claim and changes no upstream source.

The browser capture limitation below is an integration observation, separate
from those two confirmed conversion failures.

## Evaluated tool boundary

The approved specimen uses Quarto Book and Typst. These observations use the
downloaded and hash-checked tools in the
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

The fixture probe runs each case in its own copied project and writes complete
human captures, generated XHTML, statuses, and a JSON report. From ash-doc, run:

```sh
python3 rendering/checks/rendering-tool-conformance.py \
    --quarto /path/to/quarto-1.10.19/bin/quarto \
    --epubcheck /path/to/epubcheck-5.4.0/epubcheck.jar \
    --output /tmp/ash-doc-tool-bugs-probe
```

Use a fresh output directory. The canonical fixtures are unchanged; passing
controls differ by one attribute or metadata field. The probe exits `0` when
the observed failures and controls agree. `--expect-fixed` instead requires
both failing cases to succeed with candidate tools.

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

The current specimen's adapters may compensate for these tool boundaries while
preserving source descriptions and metadata. Such integration repairs do not
turn an upstream failing case into a passing one. This report retains the
unchanged upstream reproducers until verified tool updates make them obsolete.

The optional author and accessible figure cases are independent of railroad
and sequent syntax. They do not justify changing those renderers, changing Ash,
or moving ash-doc's language checkpoint. Sandbox browser restrictions,
subprocess restrictions, and already corrected specimen implementation mistakes
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
[mixed-source]: ../../rendering/fixtures/conformance/mixed-margin-notes/notes.qmd
[mixed-config]: ../../rendering/fixtures/conformance/mixed-margin-notes/_quarto.yml
[mixed-measure]: ../../rendering/fixtures/conformance/mixed-margin-notes/measure.mjs
[mixed-capture]: ../../rendering/fixtures/conformance/mixed-margin-notes/observations.json
