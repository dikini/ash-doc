import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtemp, readFile, rename, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { createRuntime, FIGURES, fontSources, ROOT, transformSvg } from './sketch.mjs';
import { resolveAppearance } from './settings.mjs';

const repository = fileURLToPath(ROOT);
const globalPath = 'rendering/styles/diagram-style.json';
const { values } = parseArgs({ options: {
  lesson: { type: 'string' }, figure: { type: 'string' },
  'resolve-defaults': { type: 'boolean', default: false }, override: { type: 'string' }
} });
assert.equal(values.lesson, 'content/learn/values-travel-together/README.md', 'This authoring tool supports only the selected pilot.');
const figure = FIGURES.find(item => item.id === values.figure);
assert.ok(figure, 'Select one of the two pilot figures.');
assert.ok(!values.override || values['resolve-defaults'], 'Request overrides need explicit --resolve-defaults.');
const directory = new URL(`content/learn/values-travel-together/assets/${figure.id}/`, ROOT);
const statePath = new URL('illustration.json', directory);
const state = JSON.parse(await readFile(statePath));
let appearance = state.construction.appearance;
if (values['resolve-defaults']) {
  const quarto = fileURLToPath(new URL('.build/toolchain/quarto-1.10.19/bin/quarto', ROOT));
  const document = JSON.parse(execFileSync(quarto, ['pandoc', '--from', 'markdown', '--to', 'json',
    fileURLToPath(new URL(values.lesson, ROOT))], { encoding: 'utf8' }));
  const defaults = document.meta['illustration-defaults'];
  assert.ok(!defaults || defaults.t === 'MetaMap', 'illustration-defaults must be a YAML map.');
  const literal = node => node.t === 'Str' || node.t === 'MetaString' ? node.c :
    node.t === 'Space' ? ' ' : Array.isArray(node.c) ? node.c.map(literal).join('') : '';
  const documentDefaults = Object.fromEntries(Object.entries(defaults?.c ?? {}).map(([key, value]) => {
    assert.ok(['MetaInlines', 'MetaString'].includes(value.t), `Invalid document setting: ${key}`);
    const text = literal(value);
    return [key, ['roughness', 'bowing', 'seed'].includes(key) ? Number(text) : text];
  }));
  const globalDefaults = JSON.parse(await readFile(new URL(globalPath, ROOT))).illustrationDefaults;
  appearance = resolveAppearance(globalDefaults, documentDefaults, JSON.parse(values.override ?? '{}'));
  state.construction.appearance = appearance;
  state.appearanceSelection = { global: globalPath, document: values.lesson,
    request: JSON.parse(values.override ?? '{}') };
} else {
  assert.ok(appearance, 'No saved appearance; explicitly resolve defaults first.');
  appearance = resolveAppearance(appearance);
}
const temporary = await mkdtemp(join(tmpdir(), 'ash-illustration-'));
let runtime;
try {
  const basePath = join(temporary, 'base.svg');
  execFileSync('python3', [fileURLToPath(new URL('draw.py', directory)), '--output', basePath], {
    env: { ...process.env, PYTHONPATH: resolve(repository, '.build/illustration-python') }
  });
  const source = await readFile(basePath, 'utf8');
  const fonts = await fontSources(source);
  const selected = fonts[appearance.font === 'regular' ? 'regular' : 'handwritten'];
  runtime = await createRuntime();
  const first = await runtime.page.evaluate(transformSvg, { source: selected, figure, profile: appearance });
  const second = await runtime.page.evaluate(transformSvg, { source: selected, figure, profile: appearance });
  assert.equal(first.svg, second.svg, 'Rebuilds must be byte-identical.');
  const outputPath = join(temporary, 'figure.svg');
  await writeFile(outputPath, first.svg);
  execFileSync('python3', ['-c',
    'import pathlib,runpy,sys; runpy.run_path(sys.argv[1])["validate_source_svg"](pathlib.Path(sys.argv[2]).read_bytes(),sys.argv[2])',
    resolve(repository, 'rendering/build.py'), outputPath]);
  state.renderer = { source: 'draw.py', base: 'base.svg',
    command: `node rendering/illustrations/author.mjs --lesson ${values.lesson} --figure ${figure.id}`,
    dependencies: { Python: '3', fontTools: '4.61.1', Brotli: '1.1.0', RoughJS: '4.6.6', Chrome: '152.0.7977.75' } };
  for (const [name, contents] of [['base.svg', source], ['figure.svg', first.svg],
    ['illustration.json', JSON.stringify(state, null, 2) + '\n']]) {
    const pending = new URL(`.${name}.tmp`, directory);
    await writeFile(pending, contents);
    await rename(pending, new URL(name, directory));
  }
  console.log(`${figure.id}: ${JSON.stringify(appearance)}`);
} finally {
  await runtime?.browser.close();
  await rm(temporary, { recursive: true, force: true });
}
