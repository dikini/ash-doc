import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { createRuntime, ROOT } from './sketch.mjs';
import { resolveAppearance } from './settings.mjs';
import { splitRuntime, transformTree } from './split-sketch.mjs';

const hash = data => createHash('sha256').update(data).digest('hex');
const literal = node => node.t === 'Str' || node.t === 'MetaString' ? node.c :
  node.t === 'Space' ? ' ' : Array.isArray(node.c) ? node.c.map(literal).join('') : '';

export async function runCycle(runtime, { rebuild = false } = {}) {
  const root = fileURLToPath(ROOT);
  const output = new URL('.build/split-sketch/end-to-end/', ROOT);
  const documentOutput = new URL('document/', output);
  const asset = new URL('assets/fig-tree-repair-trial/', output);
  const brief = await readFile(rebuild ? new URL('README.md', output) : new URL('tree-trial.md', import.meta.url), 'utf8');
  const quarto = fileURLToPath(new URL('.build/toolchain/quarto-1.10.19/bin/quarto', ROOT));
  const parsed = JSON.parse(execFileSync(quarto, ['pandoc', '--from', 'markdown', '--to', 'json'],
    { input: brief, encoding: 'utf8' }));
  const metadata = Object.fromEntries(Object.entries(parsed.meta.diagrams.c[0].c)
    .map(([key, value]) => [key, literal(value)]));
  const documentDefaults = Object.fromEntries(Object.entries(parsed.meta['illustration-defaults'].c)
    .map(([key, value]) => [key, literal(value)]));
  const state = JSON.parse(await readFile(rebuild ? new URL('illustration.json', asset) : new URL('tree-trial.json', import.meta.url)));
  let appearance;
  if (rebuild) appearance = resolveAppearance(state.construction.appearance);
  else {
    const global = JSON.parse(await readFile(new URL('rendering/styles/diagram-style.json', ROOT)));
    appearance = resolveAppearance(global.illustrationDefaults, documentDefaults, state.construction.requestAppearance);
  }
  const split = await splitRuntime();
  const tree = split.construct(state.construction.source, metadata.id, metadata.caption, metadata.description);
  const first = await runtime.page.evaluate(transformTree, { ...tree, profile: appearance });
  assert.equal(first.svg, (await runtime.page.evaluate(transformTree, { ...tree, profile: appearance })).svg);
  state.construction.appearance = appearance;
  state.provenance = { briefSha256: hash(brief), splitCommit: split.commit,
    splitFiles: split.hashes, roughJS: '4.6.6', roughBundleSha256: runtime.bundleSha256,
    fontApplied: false, reason: 'The requested tree has no printed labels.' };
  state.renderer = { command: 'node rendering/illustrations/tree-cycle.mjs --rebuild' };
  await mkdir(asset, { recursive: true });
  const sourcePath = new URL('README.md', output);
  await writeFile(sourcePath, brief);
  await writeFile(new URL('base.svg', asset), tree.source);
  await writeFile(new URL('figure.svg', asset), first.svg);
  await writeFile(new URL('illustration.json', asset), JSON.stringify(state, null, 2) + '\n');
  const prepare = () => execFileSync('python3', [fileURLToPath(new URL('prepare-trial.py', import.meta.url)),
    '.build/split-sketch/end-to-end/README.md', fileURLToPath(documentOutput)], { cwd: root, encoding: 'utf8' });
  prepare();
  const prepared = await readFile(new URL('prepared.md', documentOutput), 'utf8');
  const staged = JSON.parse(await readFile(new URL('assets.json', documentOutput)));
  assert.ok(JSON.stringify(staged).includes(hash(first.svg)), 'Preparation records the saved SVG hash.');
  await writeFile(sourcePath, brief.replace('Use mild hand-drawn strokes.', 'Use rough hand-drawn strokes.'));
  try {
    prepare();
    assert.equal(await readFile(new URL('prepared.md', documentOutput), 'utf8'), prepared,
      'Changing the brief must not decide semantic freshness during preparation.');
  } finally { await writeFile(sourcePath, brief); }
  const saved = new URL('figure.svg', asset);
  const hidden = new URL('.figure.svg.check', asset);
  await rename(saved, hidden);
  try {
    const failure = spawnSync('python3', [fileURLToPath(new URL('prepare-trial.py', import.meta.url)),
      '.build/split-sketch/end-to-end/README.md', fileURLToPath(documentOutput)], { cwd: root, encoding: 'utf8' });
    assert.notEqual(failure.status, 0);
    assert.match(failure.stderr, /existing local SVG/);
  } finally { await rename(hidden, saved); }
  prepare();
  await writeFile(new URL('style.css', documentOutput),
    'body{max-width:760px;margin:40px auto;padding:0 24px;font:19px Georgia,serif;line-height:1.5}' +
    'img{display:block;width:50mm!important;max-width:100%;height:auto;margin:24px auto}figcaption{text-align:center}' +
    'nav{font-size:15px;margin-top:32px}@media print{nav{display:none}}');
  execFileSync(quarto, ['pandoc', 'prepared.md', '--standalone', '--embed-resources', '--to', 'html5',
    '--metadata', 'pagetitle=Description-to-diagram trial', '--css', 'style.css', '-o', '../index.html'],
  { cwd: fileURLToPath(documentOutput) });
  const htmlPath = new URL('index.html', output);
  const html = await readFile(htmlPath, 'utf8');
  await writeFile(htmlPath, html.replace('</body>',
    '<nav><a href="README.md">Authoring brief</a> · ' +
    '<a href="assets/fig-tree-repair-trial/illustration.json">Saved construction</a> · ' +
    '<a href="assets/fig-tree-repair-trial/figure.svg">Saved SVG</a> · ' +
    '<a href="../index.html">Stroke comparison</a></nav></body>'));
  const page = await runtime.browser.newPage();
  await page.setViewport({ width: 1000, height: 1100, deviceScaleFactor: 2 });
  await page.goto(new URL('index.html', output).href);
  assert.equal(await page.$$eval('img', images => images.length), 1);
  assert.equal(await page.$eval('img', image => image.complete && image.naturalWidth > 0), true);
  assert.ok(Math.abs(await page.$eval('img', image => image.getBoundingClientRect().width) - 50 * 96 / 25.4) < 1);
  await page.screenshot({ path: fileURLToPath(new URL('prepared.png', output)), fullPage: true });
  await page.pdf({ path: fileURLToPath(new URL('prepared.pdf', output)), format: 'A4', printBackground: true });
  await page.close();
  const report = { brief: 'rendering/illustrations/tree-trial.md', interpretation: 'rendering/illustrations/tree-trial.json',
    appearance, svgSha256: hash(first.svg), preparation: {
      savedAssetSubstituted: true, authoringJobs: 0, briefChangePreservesSavedArtwork: true,
      missingAssetFails: true, promptHidden: true }, fontApplied: false };
  await writeFile(new URL('report.json', output), JSON.stringify(report, null, 2) + '\n');
  console.log('Description → agent-authored construction → saved SVG → pure document preparation: verified.');
  return report;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const { values } = parseArgs({ options: { rebuild: { type: 'boolean', default: false } } });
  const runtime = await createRuntime();
  try { await runCycle(runtime, values); } finally { await runtime.browser.close(); }
}
