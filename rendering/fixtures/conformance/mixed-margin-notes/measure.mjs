import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { extname, resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';

assert.equal(process.argv.length, 6,
  'Usage: node measure.mjs HTML_OUTPUT PUPPETEER_MODULE CHROME_BINARY EVIDENCE_OUTPUT');
const [html, module, chrome, evidence] = process.argv.slice(2).map(path => resolve(path));
const { default: puppeteer } = await import(pathToFileURL(module));
const mime = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript',
  '.svg': 'image/svg+xml', '.woff': 'font/woff' };
await mkdir(evidence, { recursive: true });
const server = createServer(async (request, response) => {
  try {
    const name = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const file = resolve(html, name.slice(1) || 'index.html');
    assert.ok(file.startsWith(html + sep), 'Request stays inside the rendered fixture.');
    const body = await readFile(file);
    response.writeHead(200, { 'Content-Type': mime[extname(file)] ?? 'application/octet-stream' });
    response.end(body);
  } catch { response.writeHead(404); response.end(); }
});
await new Promise((complete, reject) => {
  server.once('error', reject); server.listen(0, '127.0.0.1', complete);
});
const origin = `http://127.0.0.1:${server.address().port}`;
const report = { scope: 'Early automation capture versus settled native HTML layout.',
  browser: '', observations: [] };
let browser;
async function measure(page, name) {
  const geometry = await page.evaluate(() => {
    const box = id => {
      const r = document.getElementById(id).getBoundingClientRect();
      return { top: r.top, bottom: r.bottom, left: r.left, right: r.right };
    };
    return { note: box('fn1'), cue: box('reading-cue') };
  });
  const overlap = geometry.cue.top < geometry.note.bottom && geometry.cue.bottom > geometry.note.top;
  report.observations.push({ name, ...geometry, overlap });
  return overlap;
}
async function settle(page) {
  await page.evaluate(async () => {
    await document.fonts.ready;
    await Promise.all([...document.images].map(image => image.decode()));
    await new Promise((complete, reject) => {
      let previous = '', changed = performance.now();
      const started = changed;
      function sample() {
        const bounds = ['fn1', 'reading-cue'].map(id => {
          const r = document.getElementById(id).getBoundingClientRect();
          return [r.top, r.bottom, r.left, r.right];
        });
        const current = JSON.stringify(bounds);
        if (current !== previous) { previous = current; changed = performance.now(); }
        if (performance.now() - changed >= 750) return complete();
        if (performance.now() - started >= 10000) return reject(new Error('Margin layout did not settle.'));
        requestAnimationFrame(sample);
      }
      requestAnimationFrame(sample);
    });
  });
}
try {
  browser = await puppeteer.launch({ executablePath: chrome, headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage'] });
  report.browser = await browser.version();
  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 1000 });
  const response = await page.goto(`${origin}/notes.html`, { waitUntil: 'networkidle0' });
  assert.equal(response.status(), 200);
  await page.evaluate(() => document.fonts.ready);
  await measure(page, 'Early sample after navigation and fonts');
  await page.screenshot({ path: resolve(evidence, 'early-full-page.png'), fullPage: true });
  await measure(page, 'Immediately after early full-page capture');
  await settle(page);
  await measure(page, 'Stable bounds after early full-page capture');
  await page.goto(`${origin}/notes.html`, { waitUntil: 'networkidle0' });
  await settle(page);
  assert.equal(await measure(page, 'Fresh settled load after image decoding'), false);
  for (const [name, width, height] of [['Width resize', 1441, 1000],
    ['Original width', 1440, 1000], ['Height resize', 1440, 1001],
    ['Original height', 1440, 1000]]) {
    await page.setViewport({ width, height }); await settle(page);
    assert.equal(await measure(page, name), false);
  }
  await page.screenshot({ path: resolve(evidence, 'settled-viewport.png'), fullPage: false });
  await settle(page);
  assert.equal(await measure(page, 'Settled after viewport capture'), false);
} finally {
  await writeFile(resolve(evidence, 'measurements.json'), JSON.stringify(report, null, 2) + '\n');
  if (browser) await browser.close();
  await new Promise(complete => server.close(complete));
}
console.log(JSON.stringify(report, null, 2));
