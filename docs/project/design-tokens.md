# Shared HTML design tokens

The HTML reader shares paper, ink, link, focus, and code colors with ash-site.
The book retains its bundled fonts, chapter layout, and notes in `html.scss`.
EPUB and PDF retain their own format styles. The edition continues to target
`ffi-base` at `354c76b391fe4af665cf6a03479a9874a57cb3e3`.

Either repository can originate edits to the version 1 token contract.
`rendering/styles/ash-tokens.css` is the book's copy; ash-site uses
`public/tokens.css`. Both carry `.design-tokens-base.css`, the last shared
content. The identical Python engine lives in `rendering/token_sync.py` here
and `scripts/token_sync.py` in ash-site. Keep both engine and test copies aligned.
It uses the Python standard library and POSIX locks, with no hosted CI or
network access.

## Build and verify locally

HTML preparation through `rendering/build.py` synchronizes before copying styles.
PDF/EPUB-only preparation does not synchronize. The HTML build manifest records
`design_tokens_sha256`; verification checks staged and published CSS against it.

```sh
python3 rendering/token_sync.py
python3 rendering/token_sync.py --check
python3 -m unittest discover -s rendering/checks -p test_token_sync.py
```

The HTML artifact verifier also runs the read-only synchronization check. A running
external Quarto preview does not rerun Python preparation; synchronize explicitly
and rebuild the generated project after editing source tokens.

The default peer is `ash-site` beside the primary ash-doc checkout. Worktrees
use that primary location too. Set `ASH_SITE_CHECKOUT=/path/to/ash-site-worktree`
or pass `--peer /path/to/ash-site` to select another checkout. Ash-site accepts
`ASH_DOC_CHECKOUT` for the reverse direction.

An absent automatic peer permits standalone use without advancing the baseline.
An explicit invalid peer or incomplete existing peer fails. Set
`ASH_TOKENS_STANDALONE=1` to use local tokens even when a peer exists; this also
bypasses cross-repository drift checks. No fetch or commit happens automatically.

## Review synchronized changes

One-sided edits propagate to the other checkout and both baselines advance.
Identical edits are accepted. Conflicting edits or incompatible baselines fail
without changing files. Reconcile the reported diff, place the intended identical
content in both token files, and rerun synchronization. Do not reset baselines
to choose a winner. Review and commit the token and baseline changes in both
repositories. Separate repository commits are not an atomic transaction.

Synchronization locks both checkouts and replaces individual files atomically.
If interrupted between replacements, rerun; a baseline conflict requires the
same explicit reconciliation. The full workflow is documented in
[ash-site's design system](https://github.com/dikini/ash-site/blob/main/docs/design-system.md).
Presentation changes do not alter canonical programs or their verification.
