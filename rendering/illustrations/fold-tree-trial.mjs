import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRuntime, ROOT } from './sketch.mjs';

const root = fileURLToPath(ROOT);
const output = join(root, '.build/fold-tree-trial');
const asset = join(output, 'assets/fig-fold-tree');
await mkdir(asset, { recursive: true });
const config = JSON.parse(await readFile(new URL('rendering/specimen.json', ROOT)));
const common = execFileSync('git', ['rev-parse', '--path-format=absolute', '--git-common-dir'],
  { cwd: root, encoding: 'utf8' }).trim();
const repository = join(dirname(dirname(common)), 'split-md');
const modules = join(output, 'split-source');
await mkdir(modules, { recursive: true });
await writeFile(join(modules, 'package.json'), '{"type":"module"}\n');
const hashes = {};
for (const name of ['parse.js', 'layout.js', 'style.js']) {
  const bytes = execFileSync('git', ['-C', repository, 'show',
    `${config.renderers.split}:packages/core/src/${name}`]);
  hashes[name] = createHash('sha256').update(bytes).digest('hex');
  await writeFile(join(modules, name), bytes);
}
const { parse } = await import(pathToFileURL(join(modules, 'parse.js')));
const { layout } = await import(pathToFileURL(join(modules, 'layout.js')));
const { mergeStyle } = await import(pathToFileURL(join(modules, 'style.js')));
const colors = ['#efc34d', '#9673be', '#4e9d79', '#e59b63', '#c86b9d', '#64b5cf'];
const source = `tree:\n${Array.from({ length: 5 }, (_, depth) =>
  `${'  '.repeat(depth + 1)}black\n${'  '.repeat(depth + 2)}value${depth + 1}`).join('\n')}\n            terminal\n` +
  `hues: ${['value1', 'value2', 'value3', 'value4', 'value5', 'terminal'].map((name, index) => `${name}=${colors[index]}`).join(' ')}\n`;
const parsed = parse(source);
assert.deepEqual(parsed.diagnostics, []);
const scene = layout(parsed.figure, mergeStyle({ geometry: {
  radius: 13, leafPitch: 42, levelGap: 36, triangleHalf: 12, triangleHeight: 18
} }));
assert.equal(scene.elements.filter(element => element.kind === 'solidCircle').length, 5);
assert.equal(scene.elements.filter(element => element.kind === 'triangle').length, 6);
assert.equal(scene.elements.filter(element => element.kind === 'edge').length, 10);
const state = { version: 1, svg: 'figure.svg', construction: {
  source, scene, colors, constructorColors: ['#79b6df', '#efaa70'],
  profile: { roughness: 1.8, bowing: 1, seed: 1729 },
  font: 'Excalifont-Latin', renderer: 'split-md layout with explicit authoring scene adapter'
}, provenance: { splitCommit: config.renderers.split, splitSourceHashes: hashes },
renderer: { command: 'node rendering/illustrations/fold-tree-trial.mjs' },
interpretation: { author: 'agent',
  intent: 'Preserve ordered leaves and branching while replacing constructors and the terminal.',
  limits: 'Standalone rough-only trial. Solid function colors and labels are authoring adaptations, not split-md grammar. Leaf baseline comes from split-md; no accepted lesson changes.' } };
const runtime = await createRuntime();
try {
  const draw = ({ scene, colors, constructorColors, profile }) => {
    const namespace = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(namespace, 'svg');
    svg.setAttribute('xmlns', namespace);
    const gap = 110;
    svg.setAttribute('viewBox', `0 0 ${scene.width * 2 + gap} ${scene.height + 86}`);
    const roughRenderer = rough.svg(svg);
    let counter = 0;
    const options = () => ({ ...profile, seed: profile.seed + counter++ * 97,
      preserveVertices: true, stroke: '#59534e', strokeWidth: 0.9 });
    const text = (parent, value, horizontal, vertical, size = 17) => {
      const node = document.createElementNS(namespace, 'text');
      for (const [key, content] of Object.entries({ x: horizontal, y: vertical, 'font-size': size, fill: '#222222' })) {
        node.setAttribute(key, content);
      }
      node.textContent = value;
      parent.append(node);
    };
    for (const [index, constructor] of [':', 'f'].entries()) {
      const group = document.createElementNS(namespace, 'g');
      group.setAttribute('data-tree', index === 0 ? 'list' : 'application');
      group.setAttribute('transform', `translate(${index * (scene.width + gap)},44)`);
      svg.append(group);
      for (const edge of scene.elements.filter(element => element.kind === 'edge')) {
        const node = roughRenderer.line(edge.x1, edge.y1, edge.x2, edge.y2, options());
        node.setAttribute('data-role', 'edge');
        group.append(node);
      }
      for (const circle of scene.elements.filter(element => element.kind === 'solidCircle')) {
        const node = roughRenderer.circle(circle.cx, circle.cy, circle.r * 2,
          { ...options(), fill: constructorColors[index], fillStyle: 'solid' });
        node.setAttribute('data-role', 'circle');
        group.append(node);
        text(group, constructor, circle.cx, circle.cy + 5);
      }
      for (const [leafIndex, leaf] of scene.elements.filter(element => element.kind === 'triangle').entries()) {
        const vertices = [[leaf.x, leaf.apex], [leaf.x - leaf.half, leaf.apex + leaf.height],
          [leaf.x + leaf.half, leaf.apex + leaf.height]];
        const node = roughRenderer.polygon(vertices, { ...options(), fill: colors[leafIndex], fillStyle: 'solid' });
        node.setAttribute('data-role', 'triangle');
        group.append(node);
        text(group, leafIndex < 5 ? String(leafIndex + 1) : index === 0 ? '[]' : 'z',
          leaf.x, leaf.apex + leaf.height + 23);
      }
    }
    const center = scene.width + gap / 2;
    text(svg, 'foldr f z', center, 24, 19);
    svg.append(roughRenderer.line(center - 39, 42, center + 39, 42, options()));
    svg.append(roughRenderer.linearPath([[center + 32, 37], [center + 39, 42], [center + 32, 47]], options()));
    return new XMLSerializer().serializeToString(svg);
  };
  const first = await runtime.page.evaluate(draw, state.construction);
  assert.equal(first, await runtime.page.evaluate(draw, state.construction));
  const svg = execFileSync('python3', ['rendering/illustrations/fold-tree-labels.py'], {
    cwd: root, input: first, encoding: 'utf8',
    env: { ...process.env, PYTHONPATH: join(root, '.build/illustration-python') }
  });
  assert(!svg.includes('<text'));
  assert.equal((svg.match(/aria-label=/g) ?? []).length, 23);
  state.provenance.svgSha256 = createHash('sha256').update(svg).digest('hex');
  state.provenance.roughJS = { version: '4.6.6', bundleSha256: runtime.bundleSha256, lockSha256: runtime.lockSha256 };
  await writeFile(join(asset, 'figure.svg'), svg);
  await writeFile(join(asset, 'illustration.json'), JSON.stringify(state, null, 2) + '\n');
  await writeFile(join(output, 'README.md'), await readFile(new URL('fold-tree-trial.md', import.meta.url)));
  execFileSync('python3', ['rendering/illustrations/prepare-trial.py',
    '.build/fold-tree-trial/README.md', join(output, 'document')], { cwd: root });
  execFileSync(join(root, '.build/toolchain/quarto-1.10.19/bin/quarto'), ['pandoc',
    'prepared.md', '--standalone', '--metadata', 'pagetitle=Structural fold trial', '-o', 'index.html'],
  { cwd: join(output, 'document') });
  await writeFile(join(output, 'index.html'), `<!doctype html><html lang="en"><meta charset="utf-8">
<title>Rough structural fold trial</title><style>body{font:18px Georgia;margin:32px;line-height:1.5}
figure{margin:24px 0;max-width:900px}img{width:100%}pre{white-space:pre-wrap;max-width:90ch}</style>
<h1>Replacing constructors, keeping structure</h1><figure><img src="assets/fig-fold-tree/figure.svg"
alt="Matching colored triangular leaves beneath blue colon circles and orange f circles">
<figcaption>Blue : → orange f. The terminal [] → z; numbered leaves retain their colors.</figcaption></figure>
<p>Split-md aligns all triangular leaves along a baseline. Rough strokes and handwritten labels are applied explicitly during authoring.</p>
<p><a href="README.md">Prose illustration request</a> · <a href="assets/fig-fold-tree/illustration.json">Saved construction</a> ·
<a href="document/index.html">Prepared document</a></p></html>`);
  await runtime.page.setViewport({ width: 1100, height: 650, deviceScaleFactor: 2 });
  await runtime.page.goto(pathToFileURL(join(output, 'index.html')).href);
  await runtime.page.evaluate(async () => Promise.all([...document.images].map(image => image.decode())));
  await runtime.page.screenshot({ path: join(output, 'review.png'), fullPage: true });
  await runtime.page.setViewport({ width: 390, height: 800, deviceScaleFactor: 2 });
  assert(await runtime.page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
  await runtime.page.screenshot({ path: join(output, 'narrow.png'), fullPage: true });
  await runtime.page.setViewport({ width: 1100, height: 650, deviceScaleFactor: 2 });
  await runtime.page.addStyleTag({ content: 'img{filter:grayscale(1)}' });
  await runtime.page.screenshot({ path: join(output, 'grayscale.png'), fullPage: true });
  console.log(`Structural trial saved: ${output}; ${state.provenance.svgSha256}`);
} finally { await runtime.browser.close(); }
