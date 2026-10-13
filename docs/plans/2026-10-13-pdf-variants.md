# PDF variants implementation plan

Can a reader print the same verified chapter as a double-sided book or bind a
one-sided A4 copy? This change crosses the page geometry and note placement
boundary. It changes neither learning source nor Ash behavior.

**Goal:** build both requested print variants from the existing specimen.

**Authority:** the user requested the current double-sided layout and normal
A4 with a slightly larger left binding margin. All sources still target
`diag-ash`, Ash commit `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
The edition remains unpublished.

**Architecture:** keep the existing book output and add a Quarto `a4` profile.
Both runs share source staging, assets, typography, and the Typst partial.
Only page geometry and note placement differ. The default build produces both.

**Tools:** existing pinned Quarto 1.10.19, Typst 0.15.1, and Poppler; no new
dependency or publishing mechanism.

## Bounded design

Separate complete Typst templates would isolate each layout but duplicate
typography and front matter. A small profile with a conditional page setup
keeps those choices together and permits independent rendering. Deferring the
profile would leave ordinary A4 printing unverified. Select the small profile.

- Book: retain 8 by 10 inch pages, mirrored margins, and outer margin notes.
  Retain `ash-doc-specimen.pdf` as its stable filename.
- A4: fixed 25 mm left margin and 20 mm right, top, and bottom margins.
  Use ordinary footnotes within the text area. Do not alternate margins by
  page parity. Write `ash-doc-specimen-a4.pdf`.
- Render HTML, EPUB, and the book PDF normally, then render only Typst through
  the `a4` profile. Keep the complete generated project for inspection.

These measurements are replaceable print defaults. Revisit the profile if an
actual binding or print requirement needs different margins. Remove the
conditional when a verified upstream layout interface supplies its behavior.

## Execution and verification

1. Extend `rendering/checks/verify.py` to require both PDFs and inspect their
   actual paper dimensions, body margins on odd and even pages, note placement,
   text bounds, and preserved code/transcript characters. Run it against the
   current specimen and confirm that the missing A4 output fails.
2. Change `rendering/build.py` to prepare `_quarto-a4.yml` and render the second
   Typst output. Change `rendering/styles/book.typ` to share typography while
   selecting fixed A4 margins or existing mirrored book margins. Set A4
   `reference-location: document` so Quarto retains ordinary footnotes.
3. Build both outputs. Run the existing preparation tests, artifact checks,
   EPUBCheck, and selected lesson checks against the exact Ash target.
   Inspect representative PDF pages, including both page parities, notes,
   long code, and diagrams. Review the changes independently.
4. Update `docs/project/rendering.md`, `rendering/README.md`, the verification
   guide, roadmap, and notation comparison fixture. State filenames, dimensions,
   print use, note behavior, and reproducible commands. Run Markdown lint and
   `git diff --check`; inspect every changed source file.
5. Remove this completed plan and its active links, commit the verified change
   on the specimen branch, and retain both PDFs for user review.
