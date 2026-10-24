import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRuntime, ROOT } from './sketch.mjs';
import { foldlStates } from './foldl-state.mjs';

const root = fileURLToPath(ROOT);
const output = join(root, '.build/foldl-trial');
const asset = join(output, 'assets/fig-foldl-steps');
await mkdir(asset, { recursive: true });
const construction = { states: foldlStates(['1', '2', '3']),
  colors: { z: '#64b5cf', 1: '#efc34d', 2: '#9673be', 3: '#4e9d79' },
  functionColor: '#efaa70', profile: { roughness: 1.8, bowing: 1, seed: 1729 },
  font: 'Excalifont-Latin', layout: 'four recursive-call snapshots; left-associated expression trees' };
const runtime = await createRuntime();
try {
  const draw = ({ states, colors, functionColor, profile }) => {
    const namespace = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(namespace, 'svg');
    svg.setAttribute('xmlns', namespace);
    svg.setAttribute('viewBox', '0 0 720 1040');
    const renderer = rough.svg(svg);
    let sequence = 0;
    const options = () => ({ ...profile, seed: profile.seed + sequence++ * 97,
      preserveVertices: true, stroke: '#59534e', strokeWidth: 0.9 });
    const text = (parent, value, horizontal, vertical, size = 19) => {
      const node = document.createElementNS(namespace, 'text');
      for (const [key, content] of Object.entries({ x: horizontal, y: vertical,
        'font-size': size, fill: '#222222' })) node.setAttribute(key, content);
      node.textContent = value;
      parent.append(node);
    };
    const triangle = (parent, value, horizontal, vertical) => {
      const node = renderer.polygon([[horizontal, vertical - 10], [horizontal - 13, vertical + 10],
        [horizontal + 13, vertical + 10]], { ...options(), fill: colors[value], fillStyle: 'solid' });
      node.setAttribute('data-leaf', value);
      parent.append(node);
      text(parent, value, horizontal, vertical + 32);
    };
    text(svg, 'accumulator expression', 195, 28, 21);
    text(svg, 'remaining list', 540, 28, 21);
    text(svg, 'f: old accumulator on left, next element on right', 360, 58, 17);
    for (const [index, state] of states.entries()) {
      const panel = document.createElementNS(namespace, 'g');
      panel.setAttribute('data-step', index);
      panel.setAttribute('transform', `translate(0,${85 + index * 235})`);
      svg.append(panel);
      text(panel, index === 0 ? 'start' : `call ${index + 1}`, 41, 10, 16);
      const nodes = [];
      const edges = [];
      const place = (tree, depth = 0) => {
        if (typeof tree === 'string') {
          const horizontal = 85 + (tree === 'z' ? 0 : Number(tree)) * 65;
          const result = { horizontal, vertical: 145, leaf: tree };
          nodes.push(result);
          return result;
        }
        const left = place(tree.left, depth + 1);
        const right = place(tree.right, depth + 1);
        const result = { horizontal: (left.horizontal + right.horizontal) / 2,
          vertical: 35 + depth * 33 };
        edges.push([result, left], [result, right]);
        nodes.push(result);
        return result;
      };
      place(state.accumulator);
      for (const [parent, child] of edges) {
        const node = renderer.line(parent.horizontal, parent.vertical,
          child.horizontal, child.leaf ? child.vertical - 10 : child.vertical, options());
        node.setAttribute('data-role', 'edge');
        panel.append(node);
      }
      for (const node of nodes) {
        if (node.leaf) triangle(panel, node.leaf, node.horizontal, node.vertical);
        else {
          const circle = renderer.circle(node.horizontal, node.vertical, 28,
            { ...options(), fill: functionColor, fillStyle: 'solid' });
          circle.setAttribute('data-function', 'f');
          panel.append(circle);
          text(panel, 'f', node.horizontal, node.vertical + 5);
        }
      }
      text(panel, state.expression, 195, 207, 17);
      if (state.remaining.length) {
        text(panel, '[', 440, 125, 25);
        text(panel, ']', 640, 125, 25);
        state.remaining.forEach((value, position) => triangle(panel, value, 477 + position * 64, 112));
      } else {
        text(panel, '[]', 540, 110, 25);
        text(panel, 'return accumulator', 540, 151, 19);
        text(panel, 'no new f application', 540, 179, 16);
      }
      if (index < states.length - 1) {
        panel.append(renderer.line(372, 175, 372, 228, options()));
        panel.append(renderer.linearPath([[367, 220], [372, 228], [377, 220]], options()));
        text(panel, `take ${index + 1}; pass f acc ${index + 1}`, 534, 215, 16);
      }
    }
    return new XMLSerializer().serializeToString(svg);
  };
  const raw = await runtime.page.evaluate(draw, construction);
  assert.equal(raw, await runtime.page.evaluate(draw, construction));
  const counts = await runtime.page.evaluate(source => {
    const document = new DOMParser().parseFromString(source, 'image/svg+xml');
    return ['[data-step]', '[data-function]', '[data-leaf]', '[data-role="edge"]']
      .map(selector => document.querySelectorAll(selector).length);
  }, raw);
  assert.deepEqual(counts, [4, 6, 16, 12]);
  const svg = execFileSync('python3', ['rendering/illustrations/fold-tree-labels.py'], {
    cwd: root, input: raw, encoding: 'utf8',
    env: { ...process.env, PYTHONPATH: join(root, '.build/illustration-python') } });
  const hash = createHash('sha256').update(svg).digest('hex');
  assert(!svg.includes('<text'));
  await writeFile(join(asset, 'figure.svg'), svg);
  await writeFile(join(asset, 'illustration.json'), JSON.stringify({ version: 1, svg: 'figure.svg', construction,
    interpretation: { author: 'agent', intent: 'Track recursive-call states, not strict evaluation of f.',
      limits: 'Haskell-specific standalone trial; direct scene composition, not split-md grammar or an Ash claim.' },
    renderer: { command: 'node rendering/illustrations/foldl-trial.mjs' },
    provenance: { svgSha256: hash, roughJS: '4.6.6', bundleSha256: runtime.bundleSha256,
      lockSha256: runtime.lockSha256 } }, null, 2) + '\n');
  await writeFile(join(output, 'README.md'), await readFile(new URL('foldl-trial.md', import.meta.url)));
  execFileSync('python3', ['rendering/illustrations/prepare-trial.py',
    '.build/foldl-trial/README.md', join(output, 'document')], { cwd: root });
  execFileSync(join(root, '.build/toolchain/quarto-1.10.19/bin/quarto'), ['pandoc',
    'prepared.md', '--standalone', '--metadata', 'pagetitle=Foldl accumulator progression', '-o', 'index.html'],
  { cwd: join(output, 'document') });
  await writeFile(join(output, 'index.html'), `<!doctype html><html lang="en"><meta charset="utf-8">
<title>Foldl: growing the accumulator</title><style>body{font:18px Georgia;margin:24px;line-height:1.5}
main{max-width:850px;margin:auto}h1{font-size:30px}figure{margin:24px 0}img{width:100%;display:block}
p{max-width:75ch}a{color:#285f94}</style><main><h1>Foldl: growing the accumulator</h1>
<p>Each recursive call wraps the previous accumulator in a new application of <em>f</em>,
with the next element on its right. At the empty list, return the accumulated expression.</p>
<p><strong>Call order, not evaluation order:</strong> these are unevaluated expressions.
Haskell's foldl does not force each intermediate accumulator.</p>
<figure><a href="assets/fig-foldl-steps/figure.svg"><img src="assets/fig-foldl-steps/figure.svg"
alt="Four foldl states: z, f z 1, f (f z 1) 2, f (f (f z 1) 2) 3; the remaining list shrinks to empty"></a>
<figcaption>The previous accumulator is always the left argument of the newest f.</figcaption></figure>
<p><a href="README.md">Prose request</a> · <a href="assets/fig-foldl-steps/illustration.json">Construction state</a> ·
<a href="document/index.html">Prepared document</a>. Tap the figure to enlarge.</p></main></html>`);
  for (const [name, width] of [['wide', 1050], ['narrow', 390]]) {
    await runtime.page.setViewport({ width, height: 900, deviceScaleFactor: 2 });
    await runtime.page.goto(pathToFileURL(join(output, 'index.html')).href);
    await runtime.page.evaluate(async () => Promise.all([...document.images].map(image => image.decode())));
    assert(await runtime.page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
    await runtime.page.screenshot({ path: join(output, `${name}.png`), fullPage: true });
  }
  await runtime.page.setViewport({ width: 1050, height: 900, deviceScaleFactor: 2 });
  await runtime.page.addStyleTag({ content: 'img{filter:grayscale(1)}' });
  await runtime.page.screenshot({ path: join(output, 'grayscale.png'), fullPage: true });
  console.log(`Foldl trial: ${output}; ${hash}`);
} finally { await runtime.browser.close(); }
