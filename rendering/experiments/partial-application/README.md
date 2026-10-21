# Curried functions: types and values

Learn lesson 3 asks how a function's type relates to its inputs and result,
and how supplying one input leaves a function. This accepted visualization
experiment targets `ffi-base`, Ash commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. The pinned
[application rules][application] govern the calls.

On 2026-10-20 the three figures migrated from hand-authored SVG to `split`
notation fences rendered by the pinned
[split-md](https://github.com/dikini/split-md) renderer through the shared
figure style contract. The lesson's grouped margin note now holds three
`split` fences:

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

The vocabulary and teaching intent are unchanged from the accepted
experiment. The figure sources are now the lesson's `split` fences, and the
renderer, palette, and geometry are pinned and checked in shared
infrastructure rather than lesson-local scripts.

## Historical record

The accepted experiment originally shipped hand-authored SVG sources
(`currying-types-source.svg` and siblings) converted to outlined assets by
the local Inkscape CLI, with `check_figure_order.py` and
`check_figure_scale.py` guarding caption order and source geometry. That
machinery was retired when the figures migrated; the split-md conformance
corpus and the shared diagram determinism and style-contract checks now own
those concerns. All sources were original and copied no image pixels or
artwork. JavaScript-like syntax and the uncurrying comparison were excluded.

Review evidence from 2026-10-17, before the migration: the revised lesson
rendered in HTML, EPUB, and both PDF layouts. Both PDFs showed Figures 1, 2,
and 3 together on one page with readable labels. A native `.block` inside
the margin Div kept the figures in one note; independent floats had
reordered them. Browser checks passed for desktop and narrow HTML and
enlarged EPUB text. All three canonical sources and displayed programs
passed lesson-local verification at the exact Ash pin.

The [user-supplied reference][reference] contributed the idea of colored
blocks. Google Drive retains the earlier single-figure review.

Reproduce the lesson review from the repository root:

```sh
python3 rendering/build.py \
    --lesson content/learn/using-more-than-one-input/README.md
python3 rendering/checks/verify.py \
    .build/lessons/learn/using-more-than-one-input
python3 rendering/experiments/partial-application/build_delivery.py
```

[application]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application
[reference]: https://media.licdn.com/dms/image/v2/D4D12AQEkJw3PenxFlw/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1672944261013?e=2147483647&v=beta&t=LOeI0l95GEXwQiqPeHYwBnmlYA3ClDhrgMw8Lgl2YEw
