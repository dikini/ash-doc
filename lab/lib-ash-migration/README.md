# Lib Ash migration evidence

This family retains executable observations found while ash-doc moves from Ash
commit `dca16039923475c48025c5f17beadeb6bcb6a4bf` to exact `lib-ash` commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`.

Each case preserves the triggering source and compares the two clean compiler
checkouts. A result can identify an ash-doc mistake, an Ash regression
candidate, an unspecified design question, or tool and application pressure.
It cannot define Ash semantics or prescribe an upstream implementation change.

## Cases

- [Imported body-free summaries fail authentication](body-free-summary-authentication/README.md)
  retains all eight status-2 compiler failures found in three
  recursive-algorithm Cases.
