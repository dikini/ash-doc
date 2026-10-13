import test from 'node:test';
import assert from 'node:assert/strict';
import { access, mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const environment = {
  railroad: 'RAILROAD_BUNDLE', sequent: 'SEQUENT_BUNDLE', mermaid: 'MMDC',
  puppeteer: 'PUPPETEER_MODULE', browser: 'CHROME_BIN'
};
function tools() {
  return Object.fromEntries(Object.entries(environment).map(([key, name]) => {
    assert.ok(process.env[name], `Set ${name} to the pinned ${key} tool path.`);
    return [key, process.env[name]];
  }));
}
async function renderer() {
  try {
    return (await import('../diagrams.mjs')).renderDiagrams;
  } catch (error) {
    assert.fail(`Diagram build adapter is unavailable: ${error.message}`);
  }
}

const diagrams = [
  { id: 'graph', kind: 'mermaid', source: 'flowchart LR\n    source[Source] --> reader[Reader]\n',
    path: 'notation.md', line: 4, description: 'A source becomes a reader presentation.' },
  { id: 'sequence', kind: 'mermaid', source: 'sequenceDiagram\n    Reader->>Tool: Run source\n    Tool-->>Reader: Observe value\n',
    path: 'notation.md', line: 12, description: 'The reader requests an observation.' },
  { id: 'grammar', kind: 'ebnf', source: 'module_path ::= identifier { "." identifier } | "@" identifier ;\n',
    path: 'notation.md', line: 21, description: 'A module path has repeated segments or a named root.' },
  { id: 'inference', kind: 'sequent', source: 'T-Int :=\n    ===>\n    GAMMA |- n ⇒ Int\n',
    path: 'notation.md', line: 30, description: 'An integer inference with no premises.' }
];

test('all notation kinds produce deterministic, accessible standalone SVGs', async () => {
  const renderDiagrams = await renderer();
  const root = await mkdtemp(join(tmpdir(), 'ash-doc-diagrams-'));
  try {
    for (const run of ['first', 'second']) {
      await renderDiagrams({ ...tools(), output: join(root, run), diagrams });
    }
    for (const diagram of diagrams) {
      const svg = await readFile(join(root, 'first', `${diagram.id}.svg`), 'utf8');
      const repeated = await readFile(join(root, 'second', `${diagram.id}.svg`), 'utf8');
      assert.equal(svg, repeated, `${diagram.id} must have stable geometry and identifiers`);
      assert.match(svg, /xmlns="http:\/\/www\.w3\.org\/2000\/svg"/);
      assert.match(svg, /viewBox="[^\"]+"/);
      assert.match(svg, /width="[0-9.]+"/);
      assert.match(svg, /height="[0-9.]+"/);
      assert.match(svg, /<title[^>]*>/);
      assert.ok(svg.includes(diagram.description), `${diagram.id} retains its description`);
      assert.ok(svg.includes(diagram.source.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')),
        `${diagram.id} retains its canonical notation in its description`);
      assert.doesNotMatch(svg, /foreignObject|<script\b|https?:\/\/(?!www\.w3\.org\/)/i);
      if (diagram.kind === 'ebnf') assert.match(svg, /fill:\s*none/);
      if (diagram.kind === 'sequent') {
        assert.match(svg, /Γ.*⊢.*Int/);
        assert.match(svg, /<line\b/);
        assert.match(svg, /<text\b/);
      }
    }
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

for (const [kind, source, reason] of [
  ['ebnf', 'rule ::= ( "x" ;\n', /EBNF error at/],
  ['sequent', 'T-Int :=\n    GAMMA |- n ⇒ Int\n', /deduction operator/],
  ['mermaid', 'flowchart LR\n    A -->[\n', /Parse error/]
]) {
  test(`invalid ${kind} fails at its source location without an SVG`, async () => {
    const renderDiagrams = await renderer();
    const output = await mkdtemp(join(tmpdir(), 'ash-doc-invalid-diagram-'));
    try {
      await assert.rejects(renderDiagrams({ ...tools(), output, diagrams: [{
        id: 'invalid', kind, source, path: 'fixtures/invalid.md', line: 40,
        description: 'Invalid notation must stop rendering.'
      }] }), (error) => {
        assert.match(error.message, /fixtures\/invalid\.md:4[0-9]/);
        assert.match(error.message, reason);
        return true;
      });
      await assert.rejects(access(join(output, 'invalid.svg')), { code: 'ENOENT' });
    } finally {
      await rm(output, { recursive: true, force: true });
    }
  });
}

test('diagram identifiers cannot escape the asset directory', async () => {
  const renderDiagrams = await renderer();
  await assert.rejects(renderDiagrams({ ...tools(), output: '/tmp', diagrams: [{
    ...diagrams[2], id: '../outside'
  }] }), /diagram identifier/i);
});

test('a production caption wider than its grammar remains inside the SVG', async () => {
  const renderDiagrams = await renderer();
  const output = await mkdtemp(join(tmpdir(), 'ash-doc-grammar-caption-'));
  const name = 'module_path_with_a_caption_wider_than_its_terminal'.repeat(3);
  try {
    await renderDiagrams({ ...tools(), output, diagrams: [{ ...diagrams[2], source: `${name} ::= "x" ;\n` }] });
    const svg = await readFile(join(output, 'grammar.svg'), 'utf8');
    const width = Number(/<svg[^>]*\bwidth="([0-9.]+)"/.exec(svg)[1]);
    assert.ok(width > name.length * 8, 'The viewport must contain the caption as well as the grammar.');
  } finally {
    await rm(output, { recursive: true, force: true });
  }
});
