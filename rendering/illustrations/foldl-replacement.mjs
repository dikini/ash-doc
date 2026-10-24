import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRuntime, ROOT } from './sketch.mjs';

const root = fileURLToPath(ROOT);
const output = join(root, '.build/foldl-replacement');
const asset = join(output, 'assets/fig-foldl-replacement');
const modules = join(output, 'split-source');
await mkdir(asset, { recursive: true });
await mkdir(modules, { recursive: true });
const config = JSON.parse(await readFile(new URL('rendering/specimen.json', ROOT)));
const common = execFileSync('git', ['rev-parse', '--path-format=absolute', '--git-common-dir'],
  { cwd: root, encoding: 'utf8' }).trim();
const repository = join(dirname(dirname(common)), 'split-md');
const hashes = {};
await writeFile(join(modules, 'package.json'), '{"type":"module"}\n');
for (const name of ['parse.js', 'layout.js', 'style.js']) {
  const bytes = execFileSync('git', ['-C', repository, 'show',
    `${config.renderers.split}:packages/core/src/${name}`]);
  hashes[name] = createHash('sha256').update(bytes).digest('hex');
  await writeFile(join(modules, name), bytes);
}
const { parse } = await import(pathToFileURL(join(modules, 'parse.js')));
const { layout } = await import(pathToFileURL(join(modules, 'layout.js')));
const { mergeStyle } = await import(pathToFileURL(join(modules, 'style.js')));
const sources = [
  'tree:\n  black\n    one\n    black\n      two\n      black\n        three\n        terminal\n',
  'tree:\n  black\n    black\n      black\n        terminal\n        one\n      two\n    three\n'
];
const binding = 'hues: one=#efc34d two=#9673be three=#4e9d79 terminal=#64b5cf\n';
const style = mergeStyle({ geometry: { radius: 14, leafPitch: 60, levelGap: 45,
  triangleHalf: 13, triangleHeight: 20 } });
const parsed = sources.map(source => parse(source + binding));
for (const result of parsed) assert.deepEqual(result.diagnostics, []);
const encode = node => node.type === 'subtree' ? node.name : node.children.map(encode);
assert.deepEqual(encode(parsed[0].figure.blocks[0].root), ['one', ['two', ['three', 'terminal']]]);
assert.deepEqual(encode(parsed[1].figure.blocks[0].root), [[['terminal', 'one'], 'two'], 'three']);
const scenes = parsed.map(result => layout(result.figure, style));
for (const scene of scenes) {
  assert.equal(scene.elements.filter(element => element.kind === 'solidCircle').length, 3);
  assert.equal(scene.elements.filter(element => element.kind === 'edge').length, 6);
  assert.equal(scene.elements.filter(element => element.kind === 'triangle').length, 4);
}
const construction = { sources: sources.map(source => source + binding), scenes,
  leafLabels: [['1', '2', '3', '[]'], ['z', '1', '2', '3']],
  profile: { roughness: 1.8, bowing: 1, seed: 1729 }, font: 'Excalifont-Latin' };
const runtime = await createRuntime();
try {
  const draw = ({ scenes, leafLabels, profile }) => {
    const namespace = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(namespace, 'svg');
    svg.setAttribute('xmlns', namespace);
    svg.setAttribute('viewBox', '0 0 700 335');
    const renderer = rough.svg(svg);
    let sequence = 0;
    const options = () => ({ ...profile, seed: profile.seed + sequence++ * 97,
      preserveVertices: true, stroke: '#59534e', strokeWidth: 0.9 });
    const text = (parent, value, horizontal, vertical, size = 18) => {
      const node = document.createElementNS(namespace, 'text');
      for (const [key, content] of Object.entries({ x: horizontal, y: vertical,
        'font-size': size, fill: '#222222' })) node.setAttribute(key, content);
      node.textContent = value;
      parent.append(node);
    };
    for (const [index, scene] of scenes.entries()) {
      const group = document.createElementNS(namespace, 'g');
      group.setAttribute('data-tree', index === 0 ? 'list' : 'application');
      group.setAttribute('transform', `translate(${index === 0 ? 40 : 430},55)`);
      svg.append(group);
      for (const edge of scene.elements.filter(element => element.kind === 'edge')) {
        const node = renderer.line(edge.x1, edge.y1, edge.x2, edge.y2, options());
        node.setAttribute('data-role', 'edge');
        group.append(node);
      }
      const circles = scene.elements.filter(element => element.kind === 'solidCircle');
      for (const [position, circle] of circles.entries()) {
        const node = renderer.circle(circle.cx, circle.cy, circle.r * 2,
          { ...options(), fill: index === 0 ? '#79b6df' : '#efaa70', fillStyle: 'solid' });
        node.setAttribute('data-role', 'circle');
        group.append(node);
        text(group, index === 0 ? ':' : 'f', circle.cx, circle.cy + 5);
        if (index === 1) text(group, ['first', 'next', 'last'][position], circle.cx - 35, circle.cy - 16, 13);
      }
      for (const [position, leaf] of scene.elements.filter(element => element.kind === 'triangle').entries()) {
        const node = renderer.polygon([[leaf.x, leaf.apex], [leaf.x - leaf.half, leaf.apex + leaf.height],
          [leaf.x + leaf.half, leaf.apex + leaf.height]], { ...options(), fill: leaf.fill, fillStyle: 'solid' });
        node.setAttribute('data-role', 'triangle');
        group.append(node);
        text(group, leafLabels[index][position], leaf.x, leaf.apex + leaf.height + 24);
      }
    }
    text(svg, 'foldl f z', 350, 30, 21);
    svg.append(renderer.line(305, 53, 395, 53, options()));
    svg.append(renderer.linearPath([[387, 48], [395, 53], [387, 58]], options()));
    text(svg, '1 : (2 : (3 : []))', 150, 293, 18);
    text(svg, '((z `f` 1) `f` 2) `f` 3', 540, 293, 16);
    text(svg, 'first / next / last: accumulator extensions, not evaluation times', 350, 326, 15);
    return new XMLSerializer().serializeToString(svg);
  };
  const raw = await runtime.page.evaluate(draw, construction);
  assert.equal(raw, await runtime.page.evaluate(draw, construction));
  const svg = execFileSync('python3', ['rendering/illustrations/fold-tree-labels.py'], {
    cwd: root, input: raw, encoding: 'utf8',
    env: { ...process.env, PYTHONPATH: join(root, '.build/illustration-python') } });
  const hash = createHash('sha256').update(svg).digest('hex');
  assert(!svg.includes('<text'));
  await writeFile(join(asset, 'figure.svg'), svg);
  await writeFile(join(asset, 'illustration.json'), JSON.stringify({ version: 1, svg: 'figure.svg', construction,
    interpretation: { author: 'agent', intent: 'Expose reassociation, seed relocation, and accumulator-extension order.',
      limits: 'Haskell structural trial; accumulator-extension order does not specify forced evaluation.' },
    renderer: { command: 'node rendering/illustrations/foldl-replacement.mjs' },
    provenance: { svgSha256: hash, splitCommit: config.renderers.split, splitSourceHashes: hashes,
      roughJS: '4.6.6', bundleSha256: runtime.bundleSha256, lockSha256: runtime.lockSha256 }
  }, null, 2) + '\n');
  await writeFile(join(output, 'README.md'), await readFile(new URL('foldl-replacement.md', import.meta.url)));
  execFileSync('python3', ['rendering/illustrations/prepare-trial.py',
    '.build/foldl-replacement/README.md', join(output, 'document')], { cwd: root });
  execFileSync(join(root, '.build/toolchain/quarto-1.10.19/bin/quarto'), ['pandoc',
    'prepared.md', '--standalone', '--metadata', 'pagetitle=Foldl reassociates the structure', '-o', 'index.html'],
  { cwd: join(output, 'document') });
  await writeFile(join(output, 'index.html'), `<!doctype html><html lang="en"><meta charset="utf-8">
<title>Foldl: changing the association</title><style>body{font:18px Georgia;margin:24px;line-height:1.5}
main{max-width:1000px;margin:auto}figure{margin:28px 0}img{width:100%}a{color:#285f94}</style>
<main><h1>Foldl: changing the association</h1><p>The right-branching list becomes a left-branching application tree.
Each new <em>f</em> takes the previous accumulator on the left and the next element on the right.</p>
<figure><a href="assets/fig-foldl-replacement/figure.svg"><img src="assets/fig-foldl-replacement/figure.svg"
alt="Right-branching colon tree becomes left-branching f tree; leaves 1 2 3 empty become z 1 2 3"></a>
<figcaption>The seed z starts the accumulated expression. The last accumulator extension is the root.</figcaption></figure>
<p>First, next, and last mark recursive accumulator extensions—not Haskell evaluation times.
The expression beneath the right tree uses f as an infix operation for comparison with colon.</p>
<p><a href="README.md">Prose illustration request</a> · <a href="assets/fig-foldl-replacement/illustration.json">Construction</a> ·
<a href="document/index.html">Prepared document</a>. Tap the figure to enlarge.</p></main></html>`);
  for (const [name, width] of [['wide', 1150], ['narrow', 390]]) {
    await runtime.page.setViewport({ width, height: 800, deviceScaleFactor: 2 });
    await runtime.page.goto(pathToFileURL(join(output, 'index.html')).href);
    await runtime.page.evaluate(async () => Promise.all([...document.images].map(image => image.decode())));
    assert(await runtime.page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
    await runtime.page.screenshot({ path: join(output, `${name}.png`), fullPage: true });
  }
  console.log(`Foldl replacement: ${output}; ${hash}`);
} finally { await runtime.browser.close(); }
