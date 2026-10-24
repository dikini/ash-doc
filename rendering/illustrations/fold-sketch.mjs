import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRuntime, ROOT, PROFILES, selectProfile } from './sketch.mjs';

export function roughenFold({ source, profile }) {
  if (!Number.isInteger(profile.seed) || profile.seed < 1 || profile.seed >= 2 ** 31 ||
      !Number.isFinite(profile.roughness) || profile.roughness < 0 || profile.roughness > 5 ||
      !Number.isFinite(profile.bowing) || profile.bowing < 0) throw new Error('Invalid saved stroke profile.');
  const document = new DOMParser().parseFromString(source, 'image/svg+xml');
  if (document.querySelector('parsererror')) throw new Error('Invalid SVG.');
  const svg = document.documentElement;
  const geometry = [...svg.querySelectorAll('path')].filter(node => !node.closest('g[aria-label]') &&
    node.getAttribute('stroke') && node.getAttribute('stroke') !== 'none');
  if (geometry.length !== 11 || svg.querySelector('[data-sketch-segment]')) throw new Error('Expected crisp fold construction.');
  const serializer = new XMLSerializer();
  const protectedBytes = () => [...svg.querySelectorAll('g[aria-label], title, desc')]
    .map(node => serializer.serializeToString(node)).join('\n');
  const lettering = protectedBytes();
  const renderer = rough.svg(svg);
  const segments = [];
  for (const node of geometry) {
    const path = node.getAttribute('d');
    const horizontal = /^M(\d+) (\d+)H(\d+)$/.exec(path);
    let lines;
    if (horizontal) lines = [[Number(horizontal[1]), Number(horizontal[2]), Number(horizontal[3]), Number(horizontal[2])]];
    else {
      const expression = /M(-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)L(-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?)/g;
      lines = [...path.matchAll(expression)].map(match => match.slice(1).map(Number));
      if (!lines.length || path.replace(expression, '').trim()) throw new Error('Unsupported fold connector.');
    }
    const group = document.createElementNS(svg.namespaceURI, 'g');
    group.setAttribute('stroke-linecap', 'round');
    for (const line of lines) {
      const index = segments.length;
      segments.push(line);
      const outline = renderer.line(...line, { seed: (profile.seed + index * 7919) % (2 ** 31 - 1) + 1,
        roughness: profile.roughness, bowing: profile.bowing, preserveVertices: true,
        stroke: node.getAttribute('stroke'), strokeWidth: Number(node.getAttribute('stroke-width')) });
      outline.setAttribute('data-sketch-segment', String(index));
      group.append(outline);
    }
    node.replaceWith(group);
  }
  if (protectedBytes() !== lettering) throw new Error('Sketching changed the protected lettering.');
  return { svg: profile.roughness === 0 ? source : serializer.serializeToString(svg), segments };
}

async function main() {
  const root = fileURLToPath(ROOT);
  execFileSync('python3', [fileURLToPath(new URL('fold-trial.py', import.meta.url))],
    { env: { ...process.env, PYTHONPATH: resolve(root, '.build/illustration-python') } });
  const output = new URL('.build/fold-trial/', ROOT);
  const asset = new URL('assets/fig-foldr-structure/', output);
  const source = await readFile(new URL('figure.svg', asset), 'utf8');
  await writeFile(new URL('base.svg', asset), source);
  const state = JSON.parse(await readFile(new URL('illustration.json', asset)));
  const runtime = await createRuntime();
  try {
    for (const profile of [selectProfile('crisp'), ...PROFILES]) {
      const first = await runtime.page.evaluate(roughenFold, { source, profile });
      const second = await runtime.page.evaluate(roughenFold, { source, profile });
      assert.equal(first.svg, second.svg);
      await writeFile(new URL(`${profile.name}.svg`, output), first.svg);
    }
    const profile = state.construction.stroke_profile;
    const result = await runtime.page.evaluate(roughenFold, { source, profile });
    await writeFile(new URL('figure.svg', asset), result.svg);
    state.provenance.svg_sha256 = createHash('sha256').update(result.svg).digest('hex');
    state.provenance.roughJS = { version: '4.6.6', bundleSha256: runtime.bundleSha256, lockSha256: runtime.lockSha256 };
    state.renderer.command = 'node rendering/illustrations/fold-sketch.mjs';
    await writeFile(new URL('illustration.json', asset), JSON.stringify(state, null, 2) + '\n');
    execFileSync('python3', [fileURLToPath(new URL('prepare-trial.py', import.meta.url)),
      '.build/fold-trial/README.md', fileURLToPath(new URL('document/', output))], { cwd: root });
    const quarto = fileURLToPath(new URL('.build/toolchain/quarto-1.10.19/bin/quarto', ROOT));
    execFileSync(quarto, ['pandoc', 'prepared.md', '--standalone', '--metadata', 'pagetitle=Hand-drawn fold illustration',
      '-o', 'index.html'], { cwd: fileURLToPath(new URL('document/', output)) });
    const html = `<!doctype html><html lang="en"><meta charset="utf-8"><title>Fold stroke comparison</title>
<style>body{font:18px Georgia;margin:24px}main{display:grid;grid-template-columns:repeat(3,1fr);gap:24px}img{width:100%}
@media(max-width:800px){main{grid-template-columns:1fr}}</style><h1>Hand-drawn fold illustration</h1>
<p>Math lettering is unchanged. Branch endpoints stay fixed, including the clearance below f.</p><main>
${['crisp', 'mild', 'rough'].map(name => `<section><h2>${name}</h2><img src="${name}.svg" alt="${name} fold illustration"></section>`).join('')}
</main><p><a href="document/index.html">Selected rough illustration in the document</a></p></html>`;
    await writeFile(new URL('comparison.html', output), html);
    const page = await runtime.browser.newPage();
    await page.setViewport({ width: 1400, height: 700, deviceScaleFactor: 2 });
    await page.goto(new URL('comparison.html', output).href);
    await page.evaluate(async () => { await Promise.all([...document.images].map(image => image.decode())); });
    await page.screenshot({ path: fileURLToPath(new URL('stroke-comparison.png', output)), fullPage: true });
    await page.goto(new URL('document/index.html', output).href);
    await page.evaluate(async () => { await Promise.all([...document.images].map(image => image.decode())); });
    await (await page.$('figure')).screenshot({ path: fileURLToPath(new URL('hand-drawn.png', output)) });
    console.log(`Hand-drawn fold illustration: roughness ${profile.roughness}, seed ${profile.seed}.`);
  } finally { await runtime.browser.close(); }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();
