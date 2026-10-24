import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { after, before, test } from 'node:test';
import { createRuntime, FIGURES, PROFILES, ROOT, transformSvg, selectProfile, fontSources } from './sketch.mjs';

test('style selection accepts presets and finite custom roughness', () => {
  assert.equal(selectProfile('regular').roughness, 0);
  assert.equal(selectProfile('crisp').roughness, 0);
  assert.equal(selectProfile('mild').roughness, 0.6);
  assert.equal(selectProfile('rough').roughness, 1.8);
  assert.equal(selectProfile('custom', 1.25).roughness, 1.25);
  for (const value of [-1, 5.1, NaN, Infinity]) assert.throws(() => selectProfile('custom', value));
  assert.throws(() => selectProfile('unknown'));
});

test('the Latin-only font trial rejects missing glyphs', async () => {
  await assert.rejects(fontSources(sources.get(FIGURES[1].id)
    .replace('aria-label="first"', 'aria-label="първи"')), /KeyError/);
});

test('handwritten lettering changes glyphs but preserves text and geometry', async () => {
  for (const figure of FIGURES) {
    const source = sources.get(figure.id);
    const fonts = await fontSources(source);
    assert.equal(fonts.regular, source);
    assert.notEqual(fonts.handwritten, source);
    assert.equal((await fontSources(source)).handwritten, fonts.handwritten);
    const compare = await runtime.page.evaluate(({ source, output }) => {
      const parser = new DOMParser();
      const read = svg => {
        const document = parser.parseFromString(svg, 'image/svg+xml');
        const serializer = new XMLSerializer();
        return { labels: [...document.querySelectorAll('g[aria-label]')].map(node => node.getAttribute('aria-label')),
          geometry: [...document.querySelectorAll('rect,path,title,desc')].filter(node => !node.closest('g[aria-label]'))
            .map(node => serializer.serializeToString(node)) };
      };
      return [read(source), read(output)];
    }, { source, output: fonts.handwritten });
    assert.deepEqual(compare[0], compare[1]);
    assert.equal((await transform(figure, fonts.handwritten, selectProfile('crisp'))).svg, fonts.handwritten);
    await transform(figure, fonts.handwritten);
  }
});

let runtime;
const sources = new Map();
before(async () => {
  runtime = await createRuntime();
  for (const figure of FIGURES) sources.set(figure.id, await readFile(new URL(figure.source, ROOT), 'utf8'));
});
after(async () => { await runtime?.browser.close(); });

async function transform(figure, source = sources.get(figure.id), profile = PROFILES[0]) {
  return runtime.page.evaluate(transformSvg, { source, figure, profile });
}

test('both seeded treatments reproduce exactly for each pilot SVG', async () => {
  for (const figure of FIGURES) for (const profile of PROFILES) {
    const first = await transform(figure, sources.get(figure.id), profile);
    const second = await transform(figure, sources.get(figure.id), profile);
    assert.equal(first.svg, second.svg);
    assert.notEqual(first.svg, sources.get(figure.id));
  }
});

test('label glyphs, metadata, and blue fills survive the outline phase', async () => {
  for (const figure of FIGURES) {
    const result = await transform(figure);
    const comparison = await runtime.page.evaluate(({ source, output }) => {
      const parser = new DOMParser();
      const before = parser.parseFromString(source, 'image/svg+xml');
      const after = parser.parseFromString(output, 'image/svg+xml');
      const serializer = new XMLSerializer();
      const labels = document => [...document.querySelectorAll('g[aria-label], title, desc')]
        .map(node => serializer.serializeToString(node));
      const fills = document => [...document.querySelectorAll('rect')].map(rect => {
        for (let node = rect; node; node = node.parentElement) {
          if (node.hasAttribute('fill')) return node.getAttribute('fill');
        }
      });
      return { labelsBefore: labels(before), labelsAfter: labels(after),
        fillsBefore: fills(before), fillsAfter: fills(after),
        runtimeElements: after.querySelectorAll('script, filter, text, foreignObject').length };
    }, { source: sources.get(figure.id), output: result.svg });
    assert.deepEqual(comparison.labelsAfter, comparison.labelsBefore);
    assert.deepEqual(comparison.fillsAfter, comparison.fillsBefore);
    assert.equal(comparison.runtimeElements, 0);
  }
});

test('changing the saved seed changes the generated strokes', async () => {
  const figure = FIGURES[0];
  const first = await transform(figure);
  const second = await transform(figure, sources.get(figure.id),
    { ...PROFILES[0], seed: PROFILES[0].seed + 1 });
  assert.notEqual(first.svg, second.svg);
});

test('the pair seam meets explicit vertices on the one outer contour', async () => {
  const result = await transform(FIGURES[0]);
  assert.deepEqual(result.pairVertices, [[40, 42], [104, 42], [168, 42],
    [168, 106], [104, 106], [40, 106]]);
  const endpoints = await runtime.page.evaluate(svg => {
    const document = new DOMParser().parseFromString(svg, 'image/svg+xml');
    const path = document.querySelector('[data-sketch-role="seam"] path');
    const first = path.getPointAtLength(0);
    const last = path.getPointAtLength(path.getTotalLength());
    return [[first.x, first.y], [last.x, last.y]];
  }, result.svg);
  assert.deepEqual(endpoints, [[104, 42], [104, 106]]);
});

test('separate add inputs retain three distinct outlines and two arrows', async () => {
  const result = await transform(FIGURES[1]);
  assert.deepEqual(result.roles, ['first', 'second', 'result', 'first-arrow', 'second-arrow']);
  const count = await runtime.page.evaluate(svg => new DOMParser()
    .parseFromString(svg, 'image/svg+xml').querySelectorAll('rect').length, result.svg);
  assert.equal(count, 3);
});

test('the phase rejects geometry transformations it does not implement', async () => {
  const figure = FIGURES[1];
  await assert.rejects(transform(figure, sources.get(figure.id)
    .replace('<rect ', '<rect transform="translate(1, 0)" ')), /transformed geometry/);
});

test('unmarked lettering is not silently treated as drawing geometry', async () => {
  const figure = FIGURES[1];
  await assert.rejects(transform(figure, sources.get(figure.id)
    .replaceAll('aria-label=', 'data-unmarked-label=')), /pilot geometry/);
});

test('a disconnected seam is rejected instead of being restyled', async () => {
  const figure = FIGURES[0];
  await assert.rejects(transform(figure, sources.get(figure.id)
    .replace('M104 42v64', 'M105 42v64')), /pair seam/);
});

test('zero seeds cannot silently enable nondeterministic output', async () => {
  await assert.rejects(transform(FIGURES[0], sources.get(FIGURES[0].id),
    { ...PROFILES[0], seed: 0 }), /nonzero seed/);
});
