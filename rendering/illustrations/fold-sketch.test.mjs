import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { before, after, test } from 'node:test';
import { createRuntime, ROOT, selectProfile } from './sketch.mjs';
import { roughenFold } from './fold-sketch.mjs';

let runtime;
let source;
before(async () => {
  runtime = await createRuntime();
  source = await readFile(new URL('.build/fold-trial/assets/fig-foldr-structure/base.svg', ROOT), 'utf8')
    .catch(() => readFile(new URL('.build/fold-trial/assets/fig-foldr-structure/figure.svg', ROOT), 'utf8'));
});
after(async () => { await runtime?.browser.close(); });

test('hand-drawn strokes reproduce while preserving lettering and line endpoints', async () => {
  const profile = selectProfile('rough');
  const first = await runtime.page.evaluate(roughenFold, { source, profile });
  assert.equal(first.svg, (await runtime.page.evaluate(roughenFold, { source, profile })).svg);
  assert.notEqual(first.svg, source);
  assert.equal(first.segments.length, 21);
  const checked = await runtime.page.evaluate(({ source, output, segments }) => {
    const parser = new DOMParser();
    const before = parser.parseFromString(source, 'image/svg+xml');
    const after = parser.parseFromString(output, 'image/svg+xml');
    const protectedBytes = document => [...document.querySelectorAll('g[aria-label], title, desc')]
      .map(node => new XMLSerializer().serializeToString(node));
    const endpoints = [...after.querySelectorAll('[data-sketch-segment] path')].map(path => {
      const first = path.getPointAtLength(0);
      const last = path.getPointAtLength(path.getTotalLength());
      return [first.x, first.y, last.x, last.y];
    });
    return { before: protectedBytes(before), after: protectedBytes(after), endpoints,
      background: after.querySelectorAll('rect, image, text, script, filter, foreignObject').length };
  }, { source, output: first.svg, segments: first.segments });
  assert.deepEqual(checked.before, checked.after);
  assert.deepEqual(checked.endpoints, first.segments);
  assert.equal(checked.background, 0);
});
