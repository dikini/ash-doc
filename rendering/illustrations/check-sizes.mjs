import assert from 'node:assert/strict';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRuntime, ROOT } from './sketch.mjs';

const root = fileURLToPath(ROOT);
const cases = [
  ['learn', 'using-more-than-one-input', false], ['learn', 'using-more-than-one-input', true],
  ['learn', 'values-travel-together', false], ['learn', 'values-travel-together', true],
  ['cases', 'guaranteeing-logarithmic-retrieval', false]
];
const output = join(root, '.build/illustration-size-review');
await mkdir(output, { recursive: true });
const runtime = await createRuntime();
const report = [];
try {
  for (const [family, lesson, translated] of cases) {
    const directory = join(root, `content/${family}/${lesson}`);
    const text = await readFile(join(directory, translated ? 'README.bg.md' : 'README.md'), 'utf8');
    const project = join(root, `.build/lessons/${family}/${lesson}${translated ? '-bg' : ''}`);
    for (const width of [1500, 1000, 820, 760, 640, 400, 390]) {
      await runtime.page.setViewport({ width, height: 1000, deviceScaleFactor: 2 });
      await runtime.page.goto(pathToFileURL(join(project, `output/${family}-${lesson}.html`)).href);
      await runtime.page.evaluate(async () => { await document.fonts.ready;
        await Promise.all([...document.images].map(image => image.decode())); });
      assert(await runtime.page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
      for (const [, id] of text.matchAll(/^    id: (fig-[\w-]+)$/gm)) {
        const state = JSON.parse(await readFile(join(directory, 'assets', id, 'illustration.json')));
        const svg = await readFile(join(directory, 'assets', id, state.svg), 'utf8');
        const viewWidth = Number(/viewBox="[^"]*?\s([\d.]+)\s[\d.]+"/.exec(svg)?.[1]);
        const actual = await runtime.page.$eval(`#${id} img`, image => ({
          width: image.getBoundingClientRect().width, declared: image.style.width,
          scale: Number(getComputedStyle(image).getPropertyValue('--aside-illustration-scale')) || 1,
          noteWidth: image.closest('.column-margin')?.getBoundingClientRect().width }));
        const display = state.construction.display ?? { placement: 'aside', primitiveUnits: 64, primitiveMm: 6.5 };
        const primitiveMm = actual.width / (96 / 25.4) / viewWidth * display.primitiveUnits;
        const expectedScale = display.placement !== 'aside' ? 1
          : actual.noteWidth >= 450 ? 1.5 : width >= 992 && actual.noteWidth >= 210 ? 1.1 : 1;
        assert.equal(actual.scale, display.placement === 'aside' ? expectedScale : 1);
        const fittedScale = display.placement === 'aside'
          ? Math.min(expectedScale, actual.noteWidth / (50 * 96 / 25.4)) : 1;
        const expectedMm = display.primitiveMm * fittedScale;
        if (width === 1500 || display.placement === 'aside') {
          assert(Math.abs(primitiveMm - expectedMm) < 0.03,
            `${lesson}/${id} at ${width}px: ${primitiveMm}mm instead of ${expectedMm}mm`);
        }
        report.push({ lesson, language: translated ? 'bg' : 'en', viewport: width, id,
          primitiveMm, expectedMm, declared: actual.declared });
        await (await runtime.page.$(`#${id}`)).screenshot({
          path: join(output, `${lesson}-${translated ? 'bg' : 'en'}-${width}-${id}.png`) });
        if (width === 1500) {
          const treatment = await runtime.page.addStyleTag({ content: 'img{filter:grayscale(1)}' });
          await (await runtime.page.$(`#${id}`)).screenshot({
            path: join(output, `${lesson}-${translated ? 'bg' : 'en'}-grayscale-${id}.png`) });
          await treatment.evaluate(node => node.remove());
        }
      }
    }
  }
  await writeFile(join(output, 'sizes.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(`Verified ${report.length} displayed primitive sizes in wide/narrow English/Bulgarian HTML.`);
} finally { await runtime.browser.close(); }
