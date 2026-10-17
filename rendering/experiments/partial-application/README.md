# Curried functions: types and values

Learn lesson 3 asks how a function's type relates to its inputs and result,
and how supplying one input leaves a function. This accepted visualization
experiment targets `diag-ash`, Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. The pinned
[application rules][application] govern the calls.

The existing unnumbered margin aside contains three numbered figures:

1. **Curried function:** `add : Int -> Int -> Int` above solid boxes.
   Red marks the function; blue marks the integer positions.
2. **Function application:** upper box halves show types; lower halves show
   values. Rose denotes `add`, gold `20`, violet `22`, and green `42`.
3. **Partial application:** `add 20` yields the orange function value
   `add_20 : Int -> Int`, which receives violet `22` and produces green `42`.

Labels retain the correspondence without color. The second diagram's lower
arrows are schematic guides for successive application, not Ash expression
syntax or conversions between integers. The diagrams show source-level
relationships, not runtime memory layout.

The lesson now binds `let add_20 = add 20` inside `main` and applies
`add_20 22`. Its canonical program returns `42 : Int` at the exact pin.
The former `add_twenty` definition and the section “Each input keeps its type”
were removed at the user's request, together with the latter's source and
obsolete diagnostic fixture. Three canonical programs remain.

## Assets and reproduction

Editable SVG sources live beside the outlined lesson assets in the lesson's
`assets/` directory. Sources are `currying-types-source.svg`,
`currying-type-value-source.svg`, and `add-20-application-source.svg`.
All three share a 480-unit viewport width, 64-unit square boxes, and 30-unit
DejaVu Sans Mono labels. Figure 3 folds into two rows to preserve that scale.
At the book's 2-inch margin, labels are 9 points; at A4's 50 mm margin,
approximately 8.9 points.

The [user-supplied reference][reference] contributed the idea of colored
blocks. All sources are original and copy no image pixels or artwork.
JavaScript-like syntax and the uncurrying comparison are excluded.

Reproduce the lesson review from the repository root:

```sh
python3 rendering/experiments/partial-application/build_delivery.py \
    --refresh-figure
python3 rendering/build.py \
    --lesson content/learn/using-more-than-one-input/README.md
python3 rendering/experiments/partial-application/build_delivery.py
python3 rendering/experiments/partial-application/check_figure_order.py
python3 rendering/experiments/partial-application/check_figure_scale.py
```

The local Inkscape CLI outlines all source SVGs. The lesson includes those
prepared assets, captions, and alternative descriptions. No shared renderer
behavior changes. The packaging script produces standalone HTML and copies
the EPUB and both PDFs into the scoped build's `delivery/` directory.

## Review evidence

On 2026-10-17, the revised lesson rendered in HTML, EPUB, and both PDF layouts.
Both PDFs show Figures 1, 2, and 3 together on page 6 with readable labels.
A native `.block` inside the margin Div keeps the figures in one note;
independent floats had reordered them. The order check verifies caption text
and positions; the scale check verifies source geometry and label style.

Browser checks pass for desktop and narrow HTML and enlarged EPUB text in
Chromium and Firefox, including exact code, image loading, navigation, and
absence of overflow or external requests. All three canonical sources and
displayed programs pass lesson-local verification at the exact Ash pin.
Markdown lint, ShellCheck, and `git diff --check` pass.

A known shared artifact-check limitation interleaves margin captions with code
in whole-page PDF extraction. Visual review confirms the revised program is
complete in both PDFs. Repairing that checker remains a separate task.

The accepted experiment is merged into the active documentation source;
it does not publish the edition. Google Drive still holds an earlier
single-figure review and has not been refreshed with this version.

[application]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#application
[reference]: https://media.licdn.com/dms/image/v2/D4D12AQEkJw3PenxFlw/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1672944261013?e=2147483647&v=beta&t=LOeI0l95GEXwQiqPeHYwBnmlYA3ClDhrgMw8Lgl2YEw
