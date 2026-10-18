# Shared HTML design tokens

The HTML reader uses Ash's shared paper, ink, link, focus, and code colors.
The reader's bundled fonts, chapter layout, and notes remain in `html.scss`.
EPUB and PDF retain their own format styles.

`rendering/styles/ash-tokens.css` is a portable copy of the version 1 contract
owned by [ash-site](https://github.com/dikini/ash-site/blob/main/public/tokens.css).
`rendering/build.py` includes it in HTML outputs. The website also loads the
same contract around embedded development snapshots.

Update the copy from an ash-site checkout:

```sh
node scripts/sync-design-tokens.mjs /path/to/ash-doc-worktree
node scripts/sync-design-tokens.mjs --check /path/to/ash-doc-worktree
```

Pass the worktree being changed. Review both diffs and render a representative
HTML lesson after a shared presentation change. Keep token changes in ash-site
and copy the complete file; independent edits would cause the two readers to
drift. This presentation contract does not change the edition's Ash target,
source examples, or verification evidence.
