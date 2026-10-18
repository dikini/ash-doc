import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';
import { pathToFileURL, fileURLToPath } from 'node:url';

const run = promisify(execFile);
const ashTarget = '354c76b391fe4af665cf6a03479a9874a57cb3e3';
const sequentTarget = '21dad3d34b206b7964d2dd7edcab89a7b8f2b612';
const railroadTarget = '366d5eaa937e9e9fbae3bf8d44265ccc2c528067';

// The expanded foreign grammar can exhaust the renderer. Isolate this corpus
// probe so known resource refusal cannot kill the controls and their report.
if (process.argv.includes('--grammar-corpus-worker')) {
  const railroad = await import(pathToFileURL(process.env.RAILROAD_BUNDLE));
  const { stdout } = await run('git', ['-C', process.env.ASH_REPO, 'show', `${ashTarget}:spec/syntax.md`],
    { maxBuffer: 2 * 1024 * 1024 });
  const records = [];
  for (const match of stdout.matchAll(/```ebnf\n([\s\S]*?)\n```/g)) {
    const tree = fenceTree(match[1]);
    const messages = [];
    await railroad.rehypeRailroad()(tree, { message(value) { messages.push(value); } });
    records.push({ chapter: 'syntax', fenceLine: stdout.slice(0, match.index).split('\n').length,
      messages, svgCount: nodes(tree, 'svg').length });
  }
  process.stdout.write(JSON.stringify(records));
  process.exit(0);
}

const args = process.argv.slice(2);
const reproduce = args.includes('--reproduce');
const expectFixed = args.includes('--expect-fixed');
const reportFlag = args.indexOf('--report');
const reportPath = reportFlag === -1 ? null : args[reportFlag + 1];
if (reportFlag !== -1 && !reportPath) throw new Error('--report requires an output path.');
if (!process.env.SEQUENT_BUNDLE) throw new Error('Set SEQUENT_BUNDLE to the pinned sequent-md core module or bundle.');
const sequent = await import(pathToFileURL(process.env.SEQUENT_BUNDLE));
const fixtures = new URL('../fixtures/conformance/', import.meta.url);
const source = await readFile(new URL('sequent-continuation.sequent', fixtures), 'utf8');
const control = await readFile(new URL('sequent-control.sequent', fixtures), 'utf8');
const aliases = await readFile(new URL('sequent-additional-aliases.sequent', fixtures), 'utf8');
const prose = await readFile(new URL('../../docs/project/notation-renderer-bugs.md', import.meta.url), 'utf8');
assert.ok(prose.includes(`\`\`\`sequent\n${source}\`\`\``), 'The displayed failure must match its canonical fixture.');

assert.deepEqual(sequent.parse(control).diagnostics, [], 'The unchanged kind-checking control must parse.');
assert.match(sequent.render(control).html, /Δ; (?:OMEGA|Ω); (?:XI|Ξ) ⊢ monotype =&gt; Type/);
const failure = sequent.render(source);
const diagnostic = {
  line: 3, column: 1,
  message: 'Unexpected indentation outside a bracketed derivation.'
};
const aliasResult = sequent.render(aliases);
assert.deepEqual(aliasResult.diagnostics, []);
if (!expectFixed) assert.match(aliasResult.html, /Γ; Δ; OMEGA; XI; IOTA; PHI; MU ⊢ expression ⇒ type/);
const customAliases = sequent.render(aliases, { symbols: { OMEGA: 'Ω', XI: 'Ξ', IOTA: 'Ι', PHI: 'Φ', MU: 'Μ' } });
assert.match(customAliases.html, /Γ; Δ; Ω; Ξ; Ι; Φ; Μ ⊢ expression ⇒ type/);

const observations = [{
  id: 'SQ-01', classification: 'Current Ash notation conformance gap',
  source: 'rendering/fixtures/conformance/sequent-continuation.sequent',
  expected: 'An indented quantified judgment in current Ash source parses without diagnostics.',
  actual: failure.diagnostics, sourceRetained: failure.html.includes(source.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')),
  fixed: failure.diagnostics.length === 0
}, {
  id: 'SQ-02', classification: 'Optional vocabulary extension',
  expected: 'The required Ash alias vocabulary normalizes; additional names remain readable.',
  actual: aliasResult.html.replace(/<[^>]+>/g, ''),
  customSymbolsSupported: true
}];

function nodes(root, tagName) {
  return [root, ...(root.children ?? []).flatMap(child => nodes(child, tagName))]
    .filter(node => node.tagName === tagName);
}
function text(root) {
  return root.type === 'text' ? root.value : (root.children ?? []).map(text).join('');
}
function fenceTree(content) {
  return { type: 'root', children: [{ type: 'element', tagName: 'pre', properties: {},
    children: [{ type: 'element', tagName: 'code', properties: { className: ['language-ebnf'] },
      children: [{ type: 'text', value: content }] }] }] };
}
let railroad = null;
if (process.env.RAILROAD_BUNDLE) {
  railroad = await import(pathToFileURL(process.env.RAILROAD_BUNDLE));
  const grammar = await readFile(new URL('railroad-control.ebnf', fixtures), 'utf8');
  const invalid = await readFile(new URL('railroad-invalid.ebnf', fixtures), 'utf8');
  assert.ok(prose.includes(`\`\`\`ebnf\n${invalid}\`\`\``), 'The displayed invalid grammar must match its canonical fixture.');
  const tree = fenceTree(grammar);
  const messages = [];
  await railroad.rehypeRailroad()(tree, { message(message) { messages.push(message); } });
  assert.deepEqual(messages, [], 'The bare ::= production must parse.');
  const [svg] = nodes(tree, 'svg');
  assert.ok(svg, 'A valid production must produce an SVG.');
  const shapes = [...nodes(svg, 'path'), ...nodes(svg, 'rect')];
  const incompleteExport = svg.properties.height === undefined && svg.properties.viewBox === undefined;
  const unstyledExport = nodes(svg, 'style').length === 0 && shapes.every(shape =>
    shape.properties.stroke === undefined && shape.properties.fill === undefined && shape.properties.style === undefined);
  observations.push({ id: 'RR-01', classification: 'Standalone SVG export feature gap',
    expected: 'A standalone export carries bounds and painting styles independently of editor CSS.',
    actual: { svgProperties: svg.properties, shapes: shapes.length, incompleteExport, unstyledExport },
    fixed: !incompleteExport && !unstyledExport });
  if (!expectFixed) {
    assert.equal(incompleteExport, true);
    assert.equal(unstyledExport, true);
  }
  const broken = fenceTree(invalid);
  const errors = [];
  await railroad.rehypeRailroad()(broken, { message(message) { errors.push(message); } });
  assert.equal(errors.length, 1);
  const sourceRetained = text(broken).includes(invalid.trim());
  observations.push({ id: 'RR-03', classification: 'Current Ash failure-presentation conformance gap',
    expected: 'Report a source location and keep the invalid fence for correction.',
    actual: { messages: errors, renderedText: text(broken), sourceRetained }, fixed: sourceRetained });
  if (!expectFixed) {
    assert.equal(sourceRetained, false);
    assert.equal(errors[0], 'Railroad diagram error: EBNF error at 1:16: expected a terminal, nonterminal, or grouped expression');
  }
}

if (process.env.RAILROAD_REPO) {
  const cache = await mkdtemp(join(tmpdir(), 'ash-doc-pack-check-'));
  try {
    const { stdout } = await run('npm', ['pack', '--dry-run', '--json', '--ignore-scripts', '--cache', cache],
      { cwd: process.env.RAILROAD_REPO, maxBuffer: 2 * 1024 * 1024 });
    const [pack] = JSON.parse(stdout);
    const paths = pack.files.map(file => file.path);
    const entries = ['dist/rehype.js', 'dist/extension.cjs'];
    const absentEntries = entries.filter(entry => !paths.includes(entry));
    observations.push({ id: 'RR-02', classification: 'Package publication defect',
      expected: 'The npm archive includes each entry declared in package.json.',
      actual: { name: pack.name, version: pack.version, absentEntries }, fixed: absentEntries.length === 0 });
    if (!expectFixed) assert.deepEqual(absentEntries, entries);
    const { stdout: tracked } = await run('git', ['-C', process.env.RAILROAD_REPO, 'ls-files', 'vendor/librrd-main/project/build.properties']);
    const { stdout: ignore } = await run('git', ['-C', process.env.RAILROAD_REPO, 'check-ignore', '-v', 'vendor/librrd-main/project/build.properties'])
      .catch(error => { if (error.code === 1) return { stdout: '' }; throw error; });
    const localPin = await readFile(join(process.env.RAILROAD_REPO, 'vendor/librrd-main/project/build.properties'), 'utf8').catch(error => {
      if (error.code === 'ENOENT') return null;
      throw error;
    });
    observations.push({ id: 'RR-04', classification: 'Build reproducibility gap',
      expected: 'A clean checkout retains an explicit sbt version or documents an externally pinned launcher.',
      actual: { tracked: tracked.trim(), ignoredBy: ignore.trim(), localPin }, fixed: tracked.trim() !== '' });
    if (!expectFixed) assert.equal(tracked.trim(), '');
  } finally {
    await rm(cache, { recursive: true, force: true });
  }
}

if (!expectFixed) {
  assert.deepEqual(failure.diagnostics, [diagnostic], 'Inspect and update the catalogue if the pinned behavior changes.');
  assert.equal(observations[0].sourceRetained, true, 'An unsuccessful render must preserve its source.');
}

let corpus = null;
if (process.env.ASH_REPO) {
  corpus = [];
  for (const chapter of ['static-semantics', 'dynamic-semantics', 'elaboration']) {
    const { stdout } = await run('git', ['-C', process.env.ASH_REPO, 'show', `${ashTarget}:spec/${chapter}.md`], { maxBuffer: 2 * 1024 * 1024 });
    for (const [index, match] of [...stdout.matchAll(/```sequent\n([\s\S]*?)\n```/g)].entries()) {
      const fenceLine = stdout.slice(0, match.index).split('\n').length;
      corpus.push({ chapter, fence: index + 1, fenceLine, diagnostics: sequent.parse(match[1]).diagnostics });
    }
  }
  if (!expectFixed) {
    assert.equal(corpus.length, 39);
    assert.equal(corpus.filter(fence => fence.diagnostics.length === 0).length, 25);
    for (const item of corpus.filter(fence => fence.diagnostics.length)) {
      const row = `| ${item.fenceLine} | ${item.diagnostics.map(diagnostic => diagnostic.line).join(', ')} |`;
      assert.ok(prose.includes(row), `The report must catalogue ${item.chapter}:${item.fenceLine}.`);
    }
  }
}

let railroadCorpus = null;
if (process.env.ASH_REPO && railroad) {
  try {
    const { stdout } = await run(process.execPath,
      ['--max-old-space-size=256', fileURLToPath(import.meta.url), '--grammar-corpus-worker'],
      { timeout: 30000, maxBuffer: 2 * 1024 * 1024 });
    railroadCorpus = JSON.parse(stdout);
    if (!expectFixed) assert.fail('Inspect the newly successful full grammar before updating this baseline.');
  } catch (error) {
    if (!/heap out of memory/i.test(error.stderr ?? '')) throw error;
    railroadCorpus = [{ chapter: 'syntax', status: 'worker-heap-exhausted', heapLimitMiB: 256 }];
    observations.push({ id: 'RR-05', classification: 'Full grammar resource limitation',
      expected: 'Render the complete pinned EBNF fence within the bounded worker.',
      actual: railroadCorpus[0], fixed: false });
  }
}

const report = { baselines: { ash: ashTarget, sequent: sequentTarget, railroad: railroadTarget },
  modules: { sequent: process.env.SEQUENT_BUNDLE, railroad: process.env.RAILROAD_BUNDLE ?? null },
  observations, corpus, railroadCorpus };
if (reportPath) await writeFile(reportPath, JSON.stringify(report, null, 2) + '\n');
if (reproduce) {
  process.stdout.write(`rendering/fixtures/conformance/sequent-continuation.sequent\n${source}\n`);
  process.stderr.write(failure.diagnostics.map(item => `Line ${item.line}, column ${item.column}: ${item.message}`).join('\n') + '\n');
  process.exitCode = failure.diagnostics.length ? 1 : 0;
} else {
  process.stdout.write(JSON.stringify(reportPath ? {
    report: reportPath, observations,
    sequentCorpus: corpus && { fences: corpus.length, passed: corpus.filter(item => item.diagnostics.length === 0).length },
    railroadCorpus
  } : report, null, 2) + '\n');
  if (expectFixed && (observations.some(item => item.fixed === false) || corpus?.some(item => item.diagnostics.length)
      || railroadCorpus?.some(item => item.status || item.messages.length))) process.exitCode = 1;
}
