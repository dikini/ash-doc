import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdir, readFile, readdir, unlink, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

export const ROOT = new URL('../../', import.meta.url);
const LESSON = 'content/learn/values-travel-together/assets/';
export const FIGURES = [
  { id: 'fig-sum-pair', source: `${LESSON}fig-sum-pair/base.svg`,
    caption: 'sum_pair : (Int, Int) → Int',
    roles: [['rect', 'pair'], ['path', 'seam'], ['rect', 'result'], ['path', 'arrow']] },
  { id: 'fig-add-inputs', source: `${LESSON}fig-add-inputs/base.svg`,
    caption: 'add : Int → Int → Int',
    roles: [['rect', 'first'], ['rect', 'second'], ['rect', 'result'],
      ['path', 'first-arrow'], ['path', 'second-arrow']] }
];
export const PROFILES = [
  { name: 'mild', seed: 1729, roughness: 0.6, bowing: 0.5 },
  { name: 'rough', seed: 1729, roughness: 1.8, bowing: 1 }
];
const sha256 = data => createHash('sha256').update(data).digest('hex');

export function selectProfile(name, roughness) {
  if (name === 'regular' || name === 'crisp') return { name: 'crisp', seed: 1729, roughness: 0, bowing: 0 };
  const preset = PROFILES.find(profile => profile.name === name);
  if (preset) return { ...preset };
  if (name === 'custom' && Number.isFinite(roughness) && roughness >= 0 && roughness <= 5) {
    return { name, seed: 1729, roughness, bowing: 1 };
  }
  throw new Error('Choose crisp, mild, rough, or custom roughness from 0 to 5.');
}

export async function fontSources(source) {
  const result = spawnSync('python3', [fileURLToPath(new URL('lettering.py', import.meta.url))], {
    input: source, encoding: 'utf8', env: { ...process.env,
      PYTHONPATH: fileURLToPath(new URL('.build/illustration-python', ROOT)) }
  });
  assert.equal(result.status, 0, result.stderr || result.error?.message);
  return { regular: source, handwritten: JSON.parse(result.stdout) };
}

export async function createRuntime() {
  const manifest = JSON.parse(await readFile(new URL('rendering/toolchain/manifest.json', ROOT)));
  const lock = await readFile(new URL('rendering/toolchain/mermaid/package-lock.json', ROOT));
  assert.equal(sha256(lock), manifest.mermaid_cli.lock_sha256, 'The frozen toolchain lock must match.');
  const installed = await readFile(new URL('.build/toolchain/mermaid/package-lock.json', ROOT));
  assert.equal(sha256(installed), sha256(lock), 'Installed tools must use the frozen lock.');
  const packageUrl = new URL('.build/toolchain/mermaid/node_modules/roughjs/', ROOT);
  const packageInfo = JSON.parse(await readFile(new URL('package.json', packageUrl)));
  assert.equal(packageInfo.version, '4.6.6', 'This authoring tool pins Rough.js 4.6.6.');
  assert.equal(packageInfo.version, JSON.parse(lock).packages['node_modules/roughjs'].version);
  const bundle = await readFile(new URL('bundled/rough.js', packageUrl), 'utf8');
  const moduleUrl = new URL('.build/toolchain/mermaid/node_modules/puppeteer/lib/puppeteer/puppeteer.js', ROOT);
  const { default: puppeteer } = await import(moduleUrl.href);
  const browser = await puppeteer.launch({
    executablePath: fileURLToPath(new URL('.build/toolchain/browser-cache/chrome/linux-152.0.7977.75/chrome-linux64/chrome', ROOT)),
    headless: true, args: ['--no-sandbox']
  });
  try {
    assert.equal(await browser.version(), 'Chrome/152.0.7977.75');
    const page = await browser.newPage();
    await page.addScriptTag({ content: bundle });
    return { browser, page, bundleSha256: sha256(bundle), lockSha256: sha256(lock) };
  } catch (error) {
    await browser.close();
    throw error;
  }
}

export function transformSvg({ source, figure, profile }) {
  if (!Number.isInteger(profile.seed) || profile.seed < 1 || profile.seed >= 2 ** 31) {
    throw new Error('A nonzero seed in the supported range is required.');
  }
  if (![profile.roughness, profile.bowing].every(value => Number.isFinite(value) && value >= 0)) {
    throw new Error('Roughness and bowing must be finite nonnegative numbers.');
  }
  const document = new DOMParser().parseFromString(source, 'image/svg+xml');
  if (document.querySelector('parsererror') || document.documentElement.localName !== 'svg') {
    throw new Error('The phase needs an SVG document.');
  }
  const svg = document.documentElement;
  const geometry = [...svg.querySelectorAll('rect, path, line, polygon, polyline, circle, ellipse')]
    .filter(node => !node.closest('g[aria-label]'));
  if (geometry.length !== figure.roles.length || geometry.some((node, index) =>
    node.localName !== figure.roles[index][0])) {
    throw new Error('The SVG does not match the approved pilot geometry.');
  }
  for (const node of geometry) {
    for (let ancestor = node; ancestor; ancestor = ancestor.parentElement) {
      if (ancestor.hasAttribute('transform')) throw new Error('The phase does not support transformed geometry.');
    }
  }
  const serializer = new XMLSerializer();
  const labelBytes = () => [...svg.querySelectorAll('g[aria-label], title, desc')]
    .map(node => serializer.serializeToString(node)).join('\n');
  const originalLabels = labelBytes();
  if (profile.roughness === 0) return { svg: source, pairVertices: null,
    roles: figure.roles.map(([, role]) => role) };
  const paint = (node, attribute, fallback) => {
    for (let ancestor = node; ancestor; ancestor = ancestor.parentElement) {
      if (ancestor.hasAttribute(attribute)) return ancestor.getAttribute(attribute);
    }
    return fallback;
  };
  const seedFor = role => {
    let hash = profile.seed;
    for (const character of `${figure.id}:${role}`) hash = Math.imul(hash ^ character.charCodeAt(0), 16777619);
    return (hash >>> 0) % (2 ** 31 - 1) + 1;
  };
  const renderer = rough.svg(svg);
  let pairVertices = null;
  const pairIndex = figure.roles.findIndex(([, role]) => role === 'pair');
  if (pairIndex >= 0) {
    const pair = geometry[pairIndex];
    const seam = geometry[figure.roles.findIndex(([, role]) => role === 'seam')];
    const horizontal = Number(pair.getAttribute('x'));
    const vertical = Number(pair.getAttribute('y'));
    const width = Number(pair.getAttribute('width'));
    const height = Number(pair.getAttribute('height'));
    const start = seam.getPointAtLength(0);
    const end = seam.getPointAtLength(seam.getTotalLength());
    if (start.x !== horizontal + width / 2 || start.y !== vertical ||
        end.x !== start.x || end.y !== vertical + height) {
      throw new Error('The pair seam must meet the outer contour at both ends.');
    }
    pairVertices = [[horizontal, vertical], [start.x, vertical], [horizontal + width, vertical],
      [horizontal + width, vertical + height], [end.x, vertical + height], [horizontal, vertical + height]];
  }
  for (const [index, node] of geometry.entries()) {
    const role = figure.roles[index][1];
    const options = { seed: seedFor(role), roughness: profile.roughness, bowing: profile.bowing,
      preserveVertices: true, stroke: paint(node, 'stroke', 'none'),
      strokeWidth: Number(paint(node, 'stroke-width', '1')) };
    const replacement = document.createElementNS(svg.namespaceURI, 'g');
    replacement.setAttribute('data-sketch-role', role);
    replacement.setAttribute('stroke-linecap', paint(node, 'stroke-linecap', 'butt'));
    replacement.setAttribute('stroke-linejoin', paint(node, 'stroke-linejoin', 'miter'));
    let outline;
    if (node.localName === 'rect') {
      const fill = node.cloneNode(true);
      fill.setAttribute('stroke', 'none');
      replacement.append(fill);
      outline = role === 'pair' ? renderer.polygon(pairVertices, options) : renderer.rectangle(
        Number(node.getAttribute('x')), Number(node.getAttribute('y')),
        Number(node.getAttribute('width')), Number(node.getAttribute('height')), options);
    } else if (role === 'seam') {
      const start = node.getPointAtLength(0);
      const end = node.getPointAtLength(node.getTotalLength());
      outline = renderer.line(start.x, start.y, end.x, end.y, options);
    } else {
      outline = renderer.path(node.getAttribute('d'), options);
    }
    replacement.append(outline);
    node.replaceWith(replacement);
  }
  if (labelBytes() !== originalLabels) throw new Error('The outline phase changed protected lettering or metadata.');
  return { svg: serializer.serializeToString(svg), pairVertices,
    roles: figure.roles.map(([, role]) => role) };
}

function comparisonHtml(fonts) {
  const columns = ['crisp', ...PROFILES.map(profile => profile.name)];
  return `<!doctype html>
<html lang="en"><meta charset="utf-8"><title>Illustration outline study</title>
<style>
body{margin:32px;color:#171c18;background:#f6f4eb;font:18px Georgia,serif}
h1{font-weight:normal}p{max-width:80ch;line-height:1.5}
main{display:grid;grid-template-columns:repeat(3,minmax(260px,1fr));gap:24px}
section{padding:20px;background:white;border:1px solid #d6d6ce}h2{font-size:21px;font-weight:normal}
figure{margin:28px 0}img{display:block;width:50mm;height:auto;max-width:100%;margin:0 auto}
figcaption{font:14px monospace;text-align:center;margin-top:12px}
#enlarged:checked~main img{width:100%}label{display:block;margin-bottom:24px}
nav{display:flex;gap:24px;flex-wrap:wrap}nav label{display:inline-block}
#selected{display:flex;gap:32px;flex-wrap:wrap;background:white;padding:20px;margin-bottom:24px}
#enlarged:checked~#selected img{width:408px}output{display:block;min-height:1.5em;color:#963020}
@media(max-width:850px){main{grid-template-columns:1fr}}
</style>
<h1>Illustration outline study</h1>
<p>Select lettering independently of geometry. Regular crisp is the construction baseline;
the pilot selects handwritten mild. The default image width is 50 mm, matching the A4 margin.</p>
<nav><label>Lettering <select id="font"><option value="regular">Regular — IBM Plex Mono</option><option value="handwritten" selected>Handwritten — Excalifont</option></select></label>
<label>Stroke <select id="stroke"><option value="crisp">Crisp / regular</option><option value="mild" selected>Mild</option><option value="rough">Rough</option><option value="custom">Custom</option></select></label>
<label>Roughness <input id="roughness" type="number" min="0" max="5" step="any" value="0.6"></label></nav>
<output id="error" role="alert"></output>
<input id="enlarged" type="checkbox"><label for="enlarged">Enlarge for stroke inspection</label>
<div id="selected">${FIGURES.map(figure => `<figure><a download="${figure.id}.svg"><img alt="Selected treatment for ${figure.id}"></a><figcaption>${figure.caption}</figcaption></figure>`).join('')}</div>
<main>${columns.map(name => `<section><h2>${name === 'crisp' ? 'Crisp' :
    `${name[0].toUpperCase() + name.slice(1)} — roughness ${PROFILES.find(profile => profile.name === name).roughness}`}</h2>
${FIGURES.map(figure => `<figure><a href="${figure.id}-handwritten-${name}.svg"><img src="${figure.id}-handwritten-${name}.svg"
alt="${name} outline treatment for ${figure.id}"></a><figcaption>${figure.caption}</figcaption></figure>`).join('\n')}</section>`).join('\n')}</main>
<p>Fixed base seed 1729; Rough.js 4.6.6. The pair has one outer contour with anchored seam endpoints.
This is an authoring preview, not document preparation or a replacement lesson build.
Click a selected figure to download its outlined SVG. Custom roughness is limited to 0–5 for this trial.</p>
<script src="rough.js"></script><script>
const FIGURES = ${JSON.stringify(FIGURES)};
const SOURCES = ${JSON.stringify(fonts).replaceAll('<', '\\u003c')};
const PROFILES = ${JSON.stringify(PROFILES)};
${selectProfile.toString()}
${transformSvg.toString()}
const font = document.querySelector('#font');
const stroke = document.querySelector('#stroke');
const amount = document.querySelector('#roughness');
let urls = [];
function refresh() {
  try {
    const profile = selectProfile(stroke.value, amount.value === '' ? NaN : Number(amount.value));
    const next = FIGURES.map(figure => {
      const result = transformSvg({ source: SOURCES[figure.id][font.value], figure, profile });
      return URL.createObjectURL(new Blob([result.svg], { type: 'image/svg+xml' }));
    });
    document.querySelectorAll('#selected figure').forEach((node, index) => {
      node.querySelector('img').src = next[index];
      node.querySelector('a').href = next[index];
    });
    urls.forEach(url => URL.revokeObjectURL(url));
    urls = next;
    document.querySelectorAll('main section').forEach((section, index) => {
      const name = ['crisp', 'mild', 'rough'][index];
      section.querySelectorAll('figure').forEach((node, figureIndex) => {
        const path = FIGURES[figureIndex].id + '-' + font.value + '-' + name + '.svg';
        node.querySelector('img').src = path;
        node.querySelector('a').href = path;
      });
    });
    document.querySelector('#error').textContent = '';
  } catch (error) { document.querySelector('#error').textContent = error.message; }
}
font.addEventListener('change', refresh);
stroke.addEventListener('change', () => {
  if (stroke.value !== 'custom') amount.value = selectProfile(stroke.value).roughness;
  refresh();
});
amount.addEventListener('input', () => { stroke.value = 'custom'; refresh(); });
refresh();
</script></html>`;
}

function comparisonTypst() {
  const columns = ['crisp', ...PROFILES.map(profile => profile.name)];
  const page = font => {
    const panels = columns.map(name => `[
    #text(size: 13pt)[${name}]
    #v(8mm)
    ${FIGURES.map(figure => `#image("${figure.id}-${font}-${name}.svg", width: 50mm)
    #v(2mm)
    #text(size: 8pt, font: "IBM Plex Mono")[${figure.caption.replaceAll('→', '->')}]
    #v(8mm)`).join('\n')}
  ]`);
    return `#heading(level: 1)[Illustration study — ${font} lettering]
Crisp, mild, and rough outlines. All images are 50 mm wide. Fills are preserved.
The pilot selects handwritten mild; other combinations remain comparisons.
#v(10mm)
#grid(columns: (50mm, 50mm, 50mm), column-gutter: 15mm, ${panels.join(',\n')})`;
  };
  return `#set page(paper: "a4", flipped: true, margin: 20mm)
#set text(font: "TeX Gyre Pagella", size: 10pt)
${page('regular')}
#pagebreak()
${page('handwritten')}
`;
}

async function main() {
  const output = new URL('.build/illustration-sketch/', ROOT);
  const runtime = await createRuntime();
  const report = { roughjs: '4.6.6', chrome: await runtime.browser.version(),
    bundleSha256: runtime.bundleSha256, lockSha256: runtime.lockSha256,
    widthMm: 50, acceptedAssetsChanged: false, figures: [] };
  try {
    const files = new Map();
    const fonts = {};
    for (const figure of FIGURES) {
      const sourceUrl = new URL(figure.source, ROOT);
      const source = await readFile(sourceUrl, 'utf8');
      const record = { id: figure.id, source: figure.source, sourceSha256: sha256(source), phases: [] };
      fonts[figure.id] = await fontSources(source);
      for (const [font, selectedSource] of Object.entries(fonts[figure.id])) {
        for (const profile of [selectProfile('crisp'), ...PROFILES]) {
          const first = await runtime.page.evaluate(transformSvg, { source: selectedSource, figure, profile });
          const second = await runtime.page.evaluate(transformSvg, { source: selectedSource, figure, profile });
          assert.equal(first.svg, second.svg, 'The style phase must reproduce byte-identically.');
          files.set(`${figure.id}-${font}-${profile.name}.svg`, first.svg);
          record.phases.push({ ...profile, font, svgSha256: sha256(first.svg),
            outlinePhasePreservedLabels: true, pairVertices: first.pairVertices, roles: first.roles });
        }
      }
      assert.equal(sha256(await readFile(sourceUrl)), record.sourceSha256, 'Accepted artwork must stay unchanged.');
      report.figures.push(record);
    }
    await mkdir(output, { recursive: true });
    for (const name of await readdir(output)) {
      if (FIGURES.some(figure => name.startsWith(figure.id + '-')) && name.endsWith('.svg')) {
        await unlink(new URL(name, output));
      }
    }
    for (const [name, contents] of files) await writeFile(new URL(name, output), contents);
    await writeFile(new URL('index.html', output), comparisonHtml(fonts));
    await writeFile(new URL('rough.js', output), await readFile(new URL(
      '.build/toolchain/mermaid/node_modules/roughjs/bundled/rough.js', ROOT)));
    report.lettering = { font: 'Excalifont Regular 1.000 (Latin subset)',
      upstreamCommit: 'b7de45e88111f5680ae4bb3c3f3541c7d3b279fe',
      sha256: 'e4423b318e11432aff2e6e865e300b7ca270f92321a3f56632268fede01c1b48',
      fontTools: '4.61.1', brotli: '1.1.0' };
    await writeFile(new URL('comparison.typ', output), comparisonTypst());
    await writeFile(new URL('report.json', output), JSON.stringify(report, null, 2) + '\n');
    const preview = await runtime.browser.newPage();
    const pageErrors = [];
    preview.on('pageerror', error => pageErrors.push(error.message));
    await preview.setViewport({ width: 1280, height: 900, deviceScaleFactor: 2 });
    await preview.goto(new URL('index.html', output).href);
    assert.equal(await preview.$eval('#error', node => node.textContent), '');
    await preview.select('#stroke', 'rough');
    await preview.select('#font', 'regular');
    await preview.$eval('#roughness', node => { node.value = '1.25'; node.dispatchEvent(new Event('input')); });
    assert.equal(await preview.$eval('#stroke', node => node.value), 'custom');
    assert.equal(await preview.$eval('#error', node => node.textContent), '');
    await preview.$eval('#roughness', node => { node.value = '-1'; node.dispatchEvent(new Event('input')); });
    assert.match(await preview.$eval('#error', node => node.textContent), /0 to 5/);
    await preview.select('#font', 'handwritten');
    await preview.select('#stroke', 'mild');
    assert.deepEqual(pageErrors, []);
    const downloads = await preview.$$eval('#selected a', async nodes =>
      Promise.all(nodes.map(async node => (await fetch(node.href)).text())));
    for (const [index, source] of downloads.entries()) {
      assert.equal(source, files.get(`${FIGURES[index].id}-handwritten-mild.svg`));
    }
    await (await preview.$('#selected')).screenshot({ path: fileURLToPath(new URL('selected-handwritten.png', output)) });
    await preview.screenshot({ path: fileURLToPath(new URL('margin-comparison.png', output)), fullPage: true });
    await (await preview.$('main')).screenshot({ path: fileURLToPath(new URL('margin-treatments.png', output)) });
    await preview.click('#enlarged');
    await preview.screenshot({ path: fileURLToPath(new URL('enlarged-comparison.png', output)), fullPage: true });
    await (await preview.$('main')).screenshot({ path: fileURLToPath(new URL('enlarged-treatments.png', output)) });
    console.log(`Wrote ${files.size} SVGs and comparison previews to ${fileURLToPath(output)}`);
  } finally {
    await runtime.browser.close();
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  await main();
}
