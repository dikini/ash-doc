import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { createRuntime, PROFILES, selectProfile } from './sketch.mjs';
import { loadTrees, transformTree } from './split-sketch.mjs';

let runtime;
let trees;
before(async () => { trees = await loadTrees(); runtime = await createRuntime(); });
after(async () => { await runtime?.browser.close(); });
const draw = (tree, profile = PROFILES[0]) => runtime.page.evaluate(transformTree, { ...tree, profile });

test('both selected trees reproduce exactly at each stroke setting', async () => {
  for (const tree of trees) {
    const before = JSON.stringify(tree);
    assert.equal((await draw(tree, selectProfile('crisp'))).svg, tree.source);
    for (const profile of PROFILES) {
      const first = await draw(tree, profile);
      assert.equal(first.svg, (await draw(tree, profile)).svg);
      assert.notEqual(first.svg, tree.source);
      assert.notEqual(first.svg, (await draw(tree, { ...profile, seed: profile.seed + 1 })).svg);
    }
    assert.equal(JSON.stringify(tree), before);
  }
});

test('fill geometry, colors, metadata, and viewport survive unchanged', async () => {
  for (const tree of trees) for (const profile of PROFILES) {
    const result = await draw(tree, profile);
    const comparison = await runtime.page.evaluate(({ source, output }) => {
      const read = text => {
        const document = new DOMParser().parseFromString(text, 'image/svg+xml');
        const svg = document.documentElement;
        return {
          fills: [...svg.querySelectorAll('path, circle')].filter(node => node.hasAttribute('fill') && node.getAttribute('fill') !== 'none')
            .map(node => ['d', 'cx', 'cy', 'r', 'fill'].map(key => node.getAttribute(key))),
          metadata: [...svg.querySelectorAll('title, desc')].map(node => new XMLSerializer().serializeToString(node)),
          viewport: ['viewBox', 'width', 'height', 'aria-labelledby'].map(key => svg.getAttribute(key)),
          unsafe: svg.querySelectorAll('text, script, filter, foreignObject, image').length
        };
      };
      return [read(source), read(output)];
    }, { source: tree.source, output: result.svg });
    assert.deepEqual(comparison[0], comparison[1]);
    assert.equal(comparison[1].unsafe, 0);
  }
});

test('circle, subtree, edge, and phase-arrow roles remain distinct', async () => {
  assert.deepEqual((await draw(trees[0])).counts, { emptyCircle: 2, circle: 1, edge: 2 });
  assert.deepEqual((await draw(trees[1])).counts, { triangle: 8, circle: 6, edge: 12, downArrow: 1 });
});

test('rough edge shafts retain both canonical endpoints', async () => {
  for (const tree of trees) for (const profile of PROFILES) {
    const result = await draw(tree, profile);
    const endpoints = await runtime.page.evaluate(svg => {
      const document = new DOMParser().parseFromString(svg, 'image/svg+xml');
      return [...document.querySelectorAll('[data-shape="edge"] path')].map(path => {
        const start = path.getPointAtLength(0);
        const end = path.getPointAtLength(path.getTotalLength());
        return [start.x, start.y, end.x, end.y];
      });
    }, result.svg);
    const expected = tree.scene.elements.filter(element => element.kind === 'edge')
      .map(element => [element.x1, element.y1, element.x2, element.y2]);
    assert.deepEqual(endpoints, expected);
  }
});

test('unrecognized geometry and unsupported scene elements fail closed', async () => {
  await assert.rejects(draw({ ...trees[0], source: trees[0].source.replace('</svg>', '<rect/></svg>') }), /geometry/);
  const scene = structuredClone(trees[0].scene);
  scene.elements[0].kind = 'text';
  await assert.rejects(draw({ ...trees[0], scene }), /Unsupported/);
});

test('invalid random settings are rejected rather than silently randomized', async () => {
  await assert.rejects(draw(trees[0], { ...PROFILES[0], seed: 0 }), /seed/);
  await assert.rejects(draw(trees[0], { ...PROFILES[0], roughness: NaN }), /roughness/);
});
