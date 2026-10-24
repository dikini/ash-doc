import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { renderDiagrams } from '../diagrams.mjs';
import { createRuntime, ROOT } from './sketch.mjs';
import { resolveAppearance } from './settings.mjs';

const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const literal = node => node.t === 'Str' || node.t === 'MetaString' ? node.c :
  node.t === 'Space' ? ' ' : Array.isArray(node.c) ? node.c.map(literal).join('') : '';

export function verifySequence(source) {
  const lines = source.trim().split('\n').map(line => line.trim());
  assert.equal(lines.shift(), 'sequenceDiagram');
  const participants = lines.filter(line => line.startsWith('participant ')).map(line => line.slice(12));
  const messages = lines.filter(line => !line.startsWith('participant '));
  assert.deepEqual(participants, ['Caller', 'Service', 'Store']);
  assert.deepEqual(messages, ['Caller->>Service: Get item', 'Service->>Store: Read item',
    'Store-->>Service: Item', 'Service-->>Caller: Item']);
  return { participants, messages };
}

async function main({ rebuild }) {
  const root = fileURLToPath(ROOT);
  const output = new URL('.build/mermaid-sequence/', ROOT);
  const asset = new URL('assets/fig-item-lookup-trial/', output);
  const documentOutput = new URL('document/', output);
  const brief = await readFile(rebuild ? new URL('README.md', output) : new URL('sequence-trial.md', import.meta.url), 'utf8');
  const state = JSON.parse(await readFile(rebuild ? new URL('illustration.json', asset) : new URL('sequence-trial.json', import.meta.url)));
  const observation = verifySequence(state.construction.source);
  const style = JSON.parse(await readFile(new URL('rendering/styles/diagram-style.json', ROOT)));
  const appearance = rebuild ? resolveAppearance(state.construction.appearance) :
    resolveAppearance(style.illustrationDefaults, {}, state.construction.requestAppearance);
  assert.equal(appearance.font, 'regular', 'This sequence trial supports regular lettering only.');
  assert.equal(appearance.stroke, 'crisp', 'Do not apply the box/tree sketch adapters to sequence geometry.');
  const tools = new URL('.build/toolchain/', ROOT);
  const manifest = JSON.parse(await readFile(new URL('rendering/toolchain/manifest.json', ROOT)));
  const mermaid = JSON.parse(await readFile(new URL('mermaid/node_modules/mermaid/package.json', tools)));
  const cli = JSON.parse(await readFile(new URL('mermaid/node_modules/@mermaid-js/mermaid-cli/package.json', tools)));
  assert.equal(mermaid.version, manifest.mermaid_cli.mermaid_version);
  assert.equal(cli.version, manifest.mermaid_cli.version);
  const fonts = {};
  for (const faces of Object.values(style.fonts.faces)) for (const [name] of faces) {
    fonts[name] = hash(await readFile(new URL(`rendering/fonts/${name}`, ROOT)));
    assert.equal(fonts[name], manifest.fonts[name]);
  }
  const quarto = fileURLToPath(new URL(`${manifest.quarto.binary}`, tools));
  const document = JSON.parse(execFileSync(quarto, ['pandoc', '--from', 'markdown', '--to', 'json'],
    { input: brief, encoding: 'utf8' }));
  const metadata = Object.fromEntries(Object.entries(document.meta.diagrams.c[0].c)
    .map(([key, value]) => [key, literal(value)]));
  const runtime = await createRuntime();
  try {
    await mkdir(asset, { recursive: true });
    await writeFile(new URL('source.mmd', asset), state.construction.source);
    const job = {
      output: fileURLToPath(new URL('rendered/', output)), style,
      diagrams: [{ id: metadata.id, kind: 'mermaid', source: state.construction.source,
        description: metadata.description,
        path: '.build/mermaid-sequence/assets/fig-item-lookup-trial/source.mmd', line: 1 }],
      mermaid: fileURLToPath(new URL(manifest.mermaid_cli.binary, tools)),
      puppeteer: fileURLToPath(new URL('mermaid/node_modules/puppeteer/lib/puppeteer/puppeteer.js', tools)),
      browser: fileURLToPath(new URL('browser-cache/chrome/linux-152.0.7977.75/chrome-linux64/chrome', tools)),
      fonts: fileURLToPath(new URL('rendering/fonts/', ROOT)), pdftocairo: '/usr/bin/pdftocairo'
    };
    await renderDiagrams(job);
    const renderedPath = new URL(`rendered/${metadata.id}.svg`, output);
    const first = await readFile(renderedPath);
    await renderDiagrams(job);
    assert.deepEqual(await readFile(renderedPath), first, 'Sequence SVGs must rebuild byte-identically.');
    assert.doesNotMatch(first.toString(), /<text\b|foreignObject|<script\b|@font-face/);
    state.construction.appearance = appearance;
    state.renderer = { command: 'node rendering/illustrations/sequence-cycle.mjs --rebuild',
      dependencies: { mermaid: mermaid.version, mermaidCLI: cli.version,
        Chrome: await runtime.browser.version(), pdftocairo: manifest.pdftocairo.version } };
    state.provenance = { briefSha256: hash(brief), lockSha256: runtime.lockSha256,
      fontFiles: fonts, svgSha256: hash(first), appearanceSelection: 'Explicit authoring request over global defaults' };
    await writeFile(new URL('README.md', output), brief);
    await writeFile(new URL('figure.svg', asset), first);
    await writeFile(new URL('source.mmd', asset), state.construction.source);
    await writeFile(new URL('illustration.json', asset), JSON.stringify(state, null, 2) + '\n');
    const source = '.build/mermaid-sequence/README.md';
    const prepareArgs = [fileURLToPath(new URL('prepare-trial.py', import.meta.url)), source, fileURLToPath(documentOutput)];
    const prepare = () => execFileSync('python3', prepareArgs, { cwd: root, encoding: 'utf8' });
    prepare();
    const prepared = await readFile(new URL('prepared.md', documentOutput), 'utf8');
    assert.ok(!prepared.includes('Make a Mermaid sequence diagram'));
    const records = JSON.parse(await readFile(new URL('assets.json', documentOutput)));
    assert.ok(JSON.stringify(records).includes(hash(first)));
    const changedBrief = brief.replace('do not add retries or failures.', 'add a retry.');
    assert.notEqual(changedBrief, brief);
    await writeFile(new URL('README.md', output), changedBrief);
    try {
      prepare();
      assert.equal(await readFile(new URL('prepared.md', documentOutput), 'utf8'), prepared);
    } finally { await writeFile(new URL('README.md', output), brief); }
    const saved = new URL('figure.svg', asset);
    const hidden = new URL('.figure.svg.check', asset);
    await rename(saved, hidden);
    try {
      const failure = spawnSync('python3', prepareArgs, { cwd: root, encoding: 'utf8' });
      assert.notEqual(failure.status, 0);
      assert.match(failure.stderr, /existing local SVG/);
    } finally { await rename(hidden, saved); }
    prepare();
    execFileSync('python3', ['-c',
      'import pathlib,runpy,sys; runpy.run_path(sys.argv[1])["validate_source_svg"](pathlib.Path(sys.argv[2]).read_bytes(),sys.argv[2])',
      resolve(root, 'rendering/build.py'), fileURLToPath(saved)]);
    await writeFile(new URL('style.css', documentOutput),
      'body{max-width:760px;margin:40px auto;padding:0 24px;font:19px Georgia,serif;line-height:1.5}' +
      'figure{margin:24px 0;max-width:100%;overflow-x:auto}img{width:660px!important;max-width:none;height:auto}' +
      'figcaption{font-size:16px}nav{font-size:15px}@media print{nav{display:none}img{width:100%!important;max-width:100%}}');
    execFileSync(quarto, ['pandoc', 'prepared.md', '--standalone', '--embed-resources', '--to', 'html5',
      '--metadata', 'pagetitle=Mermaid sequence illustration trial', '--css', 'style.css', '-o', '../index.html'],
    { cwd: fileURLToPath(documentOutput) });
    const htmlPath = new URL('index.html', output);
    const html = await readFile(htmlPath, 'utf8');
    await writeFile(htmlPath, html.replace('</body>', '<nav><a href="README.md">Prose brief</a> · ' +
      '<a href="assets/fig-item-lookup-trial/source.mmd">Mermaid construction</a> · ' +
      '<a href="assets/fig-item-lookup-trial/illustration.json">Saved state</a> · ' +
      '<a href="assets/fig-item-lookup-trial/figure.svg">Saved SVG</a></nav></body>'));
    const page = await runtime.browser.newPage();
    await page.setViewport({ width: 1000, height: 1000, deviceScaleFactor: 2 });
    await page.goto(htmlPath.href);
    await page.evaluate(async () => { await Promise.all([...document.images].map(image => image.decode())); await document.fonts.ready; });
    assert.equal(await page.$$eval('img', images => images.length === 1 && images[0].naturalWidth > 0), true);
    await page.screenshot({ path: fileURLToPath(new URL('preview.png', output)), fullPage: true });
    await (await page.$('figure')).screenshot({ path: fileURLToPath(new URL('diagram.png', output)) });
    await page.pdf({ path: fileURLToPath(new URL('preview.pdf', output)), format: 'A4', printBackground: true });
    await page.setViewport({ width: 390, height: 1000, deviceScaleFactor: 2 });
    assert.equal(await page.$eval('figure', element => {
      element.scrollLeft = element.scrollWidth;
      return element.scrollLeft > 0;
    }), true, 'Narrow readers can scroll through the full sequence.');
    await page.screenshot({ path: fileURLToPath(new URL('narrow.png', output)), fullPage: true });
    const report = { ...observation, svgSha256: hash(first), appearance,
      repeatedRenderAgrees: true, savedArtworkSubstituted: true, briefChangeDoesNotRegenerate: true,
      missingAssetFails: true, promptHidden: true, narrowScrollWorks: true };
    await writeFile(new URL('report.json', output), JSON.stringify(report, null, 2) + '\n');
    console.log(`Sequence illustration trial verified: ${fileURLToPath(output)}`);
  } finally { await runtime.browser.close(); }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const { values } = parseArgs({ options: { rebuild: { type: 'boolean', default: false } } });
  await main(values);
}
