import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRuntime, PROFILES, ROOT, selectProfile } from './sketch.mjs';

export const LESSON = 'content/cases/guaranteeing-logarithmic-retrieval/README.md';
const IDS = ['fig-restore-left-left'];
const hash = data => createHash('sha256').update(data).digest('hex');
const literal = node => node.t === 'Str' || node.t === 'MetaString' ? node.c :
  node.t === 'Space' || node.t === 'SoftBreak' ? ' ' : Array.isArray(node.c) ? node.c.map(literal).join('') : '';

export async function splitRuntime() {
  const root = fileURLToPath(ROOT);
  const config = JSON.parse(await readFile(new URL('rendering/specimen.json', ROOT)));
  const common = execFileSync('git', ['rev-parse', '--path-format=absolute', '--git-common-dir'],
    { cwd: root, encoding: 'utf8' }).trim();
  const directory = resolve(process.env.SPLIT_MD_ROOT ?? join(dirname(dirname(common)), 'split-md'));
  const commit = execFileSync('git', ['-C', directory, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
  assert.equal(commit, config.renderers.split, 'Use the exact approved split-md pin.');
  const files = ['index.js', 'parse.js', 'layout.js', 'style.js', 'svg.js'];
  const hashes = {};
  for (const name of files) {
    const path = `packages/core/src/${name}`;
    const bytes = await readFile(join(directory, path));
    const committed = execFileSync('git', ['-C', directory, 'show', `${commit}:${path}`]);
    assert.deepEqual(bytes, committed, `Pinned split-md source differs: ${path}`);
    hashes[path] = hash(bytes);
  }
  assert.equal(hashes['packages/core/src/index.js'], config.renderer_bundles.split.sha256);
  const module = name => import(pathToFileURL(join(directory, 'packages/core/src', name)).href);
  const { parse } = await module('parse.js');
  const { layout } = await module('layout.js');
  const { serialize } = await module('svg.js');
  const { mergeStyle } = await module('style.js');
  const shared = JSON.parse(await readFile(new URL('rendering/styles/diagram-style.json', ROOT)));
  const style = mergeStyle({ ...shared.kinds.split.style, categorical: shared.categorical });
  return { commit, hashes, construct(source, id, caption, description) {
    const parsed = parse(source);
    assert.deepEqual(parsed.diagnostics, []);
    const scene = layout(parsed.figure, style);
    return { id, caption, scene, source: serialize(scene,
      { title: caption, description, idBase: id }, style) };
  } };
}

export async function loadTrees() {
  const split = await splitRuntime();
  const quarto = fileURLToPath(new URL('.build/toolchain/quarto-1.10.19/bin/quarto', ROOT));
  const document = JSON.parse(execFileSync(quarto, ['pandoc', '--from', 'markdown', '--to', 'json',
    fileURLToPath(new URL(LESSON, ROOT))], { encoding: 'utf8' }));
  const descriptions = document.meta.diagrams.c.map(node => Object.fromEntries(
    Object.entries(node.c).map(([key, value]) => [key, literal(value)])));
  const trees = await Promise.all(descriptions.filter(description => IDS.includes(description.id)).map(async description => {
    const state = JSON.parse(await readFile(new URL(
      `${dirname(LESSON)}/assets/${description.id}/illustration.json`, ROOT)));
    return split.construct(state.construction.source, description.id, description.caption, description.description);
  }));
  return [split.construct('tree:\n  red/root\n    Empty\n    Empty\nhues: root=#f1c84e/#946c00',
    'fig-red-root-sketch', 'A red root with two black Empty forms.',
    'Standalone filter fixture: each path contains one black Empty form.'), ...trees];
}

export function transformTree({ source, scene, id, profile }) {
  if (!Number.isInteger(profile.seed) || profile.seed < 1 || profile.seed >= 2 ** 31) throw new Error('Invalid seed.');
  if (![profile.roughness, profile.bowing].every(value => Number.isFinite(value) && value >= 0)) {
    throw new Error('Invalid roughness or bowing.');
  }
  const document = new DOMParser().parseFromString(source, 'image/svg+xml');
  if (document.querySelector('parsererror')) throw new Error('Invalid SVG.');
  const svg = document.documentElement;
  if (svg.localName !== 'svg' || svg.querySelector('[transform], text, script, filter, foreignObject, image, defs')) {
    throw new Error('Unsupported tree SVG content.');
  }
  const geometry = [...svg.children].filter(node => !['title', 'desc'].includes(node.localName));
  const bindings = [];
  const counts = {};
  let index = 0;
  for (const element of scene.elements) {
    const kind = element.kind;
    counts[kind] = (counts[kind] ?? 0) + 1;
    if (!['circle', 'emptyCircle', 'solidCircle', 'triangle', 'edge', 'downArrow'].includes(kind)) {
      throw new Error(`Unsupported tree scene element: ${kind}`);
    }
    const split = kind === 'circle' || kind === 'emptyCircle';
    const tags = split ? ['path', 'path', 'circle'] : [kind === 'solidCircle' ? 'circle' : 'path'];
    const nodes = geometry.slice(index, index + tags.length);
    if (nodes.length !== tags.length || nodes.some((node, at) => node.localName !== tags[at])) {
      throw new Error('Tree geometry differs from the pinned scene.');
    }
    index += tags.length;
    bindings.push({ element, node: nodes.at(-1) });
  }
  if (index !== geometry.length) throw new Error('Unexpected tree geometry.');
  if (profile.roughness === 0) return { svg: source, counts };
  const renderer = rough.svg(svg);
  const serializer = new XMLSerializer();
  const protectedBytes = () => [...svg.querySelectorAll('title, desc')]
    .map(node => serializer.serializeToString(node)).join('\n');
  const metadata = protectedBytes();
  for (const [position, { element, node }] of bindings.entries()) {
    const kind = element.kind;
    let seed = profile.seed;
    for (const character of `${id}:${kind}:${position}`) seed = Math.imul(seed ^ character.charCodeAt(0), 16777619);
    const options = { seed: (seed >>> 0) % (2 ** 31 - 1) + 1,
      roughness: profile.roughness, bowing: profile.bowing, preserveVertices: true,
      stroke: element.stroke, strokeWidth: element.strokeWidth };
    const group = document.createElementNS(svg.namespaceURI, 'g');
    group.setAttribute('data-shape', kind);
    if (kind === 'triangle' || kind === 'solidCircle') {
      const fill = node.cloneNode(true);
      fill.setAttribute('stroke', 'none');
      group.append(fill);
    }
    if (['circle', 'emptyCircle', 'solidCircle'].includes(kind)) {
      group.append(renderer.circle(element.cx, element.cy, element.r * 2, options));
    } else if (kind === 'triangle') {
      const bottom = element.apex + element.height;
      group.append(renderer.polygon([[element.x, element.apex], [element.x - element.half, bottom],
        [element.x + element.half, bottom]], options));
    } else if (kind === 'edge') {
      group.append(renderer.line(element.x1, element.y1, element.x2, element.y2, options));
    } else {
      group.append(renderer.line(element.x, element.y1, element.x, element.y2, options));
      group.append(renderer.linearPath([[element.x - element.head, element.y2 - element.head],
        [element.x, element.y2], [element.x + element.head, element.y2 - element.head]], options));
    }
    node.replaceWith(group);
  }
  if (metadata !== protectedBytes()) throw new Error('Tree metadata changed.');
  return { svg: serializer.serializeToString(svg), counts };
}

function comparisonHtml(trees) {
  return `<!doctype html><html lang="en"><meta charset="utf-8"><title>Split tree stroke trial</title>
<style>body{margin:32px;font:18px Georgia,serif;background:#f6f4eb;color:#171c18}p{max-width:78ch;line-height:1.5}
main{display:grid;grid-template-columns:repeat(3,minmax(220px,1fr));gap:24px}section{padding:20px;background:white}
img{display:block;width:50mm;max-width:100%;height:auto;margin:24px auto}figure{margin:0 0 32px}figcaption{font-size:15px}
#enlarged:checked~main img{width:100%}@media(max-width:800px){main{grid-template-columns:1fr}}
</style><h1>Split trees: crisp, mild, rough</h1><p>Two existing split-md figures at 50 mm margin width.
The fill arcs, identity colors, subtree triangles, and edge endpoints retain their construction.
These sources have no printed labels, so there is no font substitution to compare.</p>
<input id="enlarged" type="checkbox"><label for="enlarged">Enlarge to inspect strokes</label>
<main>${['crisp', 'mild', 'rough'].map(name => `<section><h2>${name}</h2>${trees.map(tree =>
    `<figure><a href="${tree.id}-${name}.svg"><img src="${tree.id}-${name}.svg" alt="${tree.caption}"></a>
<figcaption>${tree.caption}</figcaption></figure>`).join('')}</section>`).join('')}</main>
<p>Saved seed 1729; unchanged pinned split-md; Rough.js 4.6.6. No lesson asset is replaced.</p>
<p><a href="end-to-end/index.html">Description → saved construction → diagram → prepared document</a></p></html>`;
}

async function main() {
  const output = new URL('.build/split-sketch/', ROOT);
  const trees = await loadTrees();
  const split = await splitRuntime();
  const runtime = await createRuntime();
  const report = { splitCommit: split.commit, splitFiles: split.hashes,
    roughBundleSha256: runtime.bundleSha256, widthMm: 50, figures: [] };
  try {
    await mkdir(output, { recursive: true });
    for (const tree of trees) {
      for (const profile of [selectProfile('crisp'), ...PROFILES]) {
        const first = await runtime.page.evaluate(transformTree, { ...tree, profile });
        const second = await runtime.page.evaluate(transformTree, { ...tree, profile });
        assert.equal(first.svg, second.svg);
        await writeFile(new URL(`${tree.id}-${profile.name}.svg`, output), first.svg);
        report.figures.push({ id: tree.id, sourceSha256: hash(tree.source), profile,
          counts: first.counts, outputSha256: hash(first.svg) });
      }
    }
    await writeFile(new URL('index.html', output), comparisonHtml(trees));
    const panels = ['crisp', 'mild', 'rough'].map(name => `[
      #heading(level: 2)[${name}]
      ${trees.map(tree => `#image("${tree.id}-${name}.svg", width: 50mm)
      #text(size: 8pt)[${tree.caption}]
      #v(6mm)`).join('\n')}
    ]`);
    await writeFile(new URL('comparison.typ', output), `#set page(paper: "a4", flipped: true, margin: 15mm)
#set text(font: "TeX Gyre Pagella", size: 10pt)
#heading(level: 1)[Split tree stroke trial — 50 mm]
#grid(columns: (50mm, 50mm, 50mm), column-gutter: 20mm, ${panels.join(',\n')})`);
    await writeFile(new URL('report.json', output), JSON.stringify(report, null, 2) + '\n');
    const page = await runtime.browser.newPage();
    await page.setViewport({ width: 1280, height: 1000, deviceScaleFactor: 2 });
    await page.goto(new URL('index.html', output).href);
    await page.screenshot({ path: fileURLToPath(new URL('margin.png', output)), fullPage: true });
    await page.click('#enlarged');
    await page.screenshot({ path: fileURLToPath(new URL('enlarged.png', output)), fullPage: true });
    console.log(`Split tree comparison: ${fileURLToPath(output)}`);
  } finally { await runtime.browser.close(); }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();
