import test from 'node:test';
import assert from 'node:assert/strict';
import { access, mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import http from 'node:http';

const contract = JSON.parse(await readFile(new URL('../styles/diagram-style.json', import.meta.url), 'utf8'));

const environment = {
  railroad: 'RAILROAD_BUNDLE', sequent: 'SEQUENT_BUNDLE', split: 'SPLIT_BUNDLE', mermaid: 'MMDC',
  puppeteer: 'PUPPETEER_MODULE', browser: 'CHROME_BIN', fonts: 'DIAGRAM_FONTS', pdftocairo: 'PDFTOCAIRO'
};
function tools() {
  const paths = Object.fromEntries(Object.entries(environment).map(([key, name]) => {
    const value = process.env[name] ?? (key === 'pdftocairo' ? '/usr/bin/pdftocairo' : undefined);
    assert.ok(value, `Set ${name} to the pinned ${key} tool path.`);
    return [key, value];
  }));
  return { ...paths, style: contract };
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
    path: 'notation.md', line: 30, description: 'An integer inference with no premises.' },
  { id: 'grouped', kind: 'sequent', source: 'family primitive-typing:\n  T-Int :=\n    ===>\n    GAMMA |- n ⇒ Int\n\n  T-Unit :=\n    ===>\n    GAMMA |- () ⇒ Unit\n',
    path: 'notation.md', line: 38, description: 'Integer and unit rules remain a labeled family.' },
  { id: 'nested', kind: 'sequent', source: 'Chain :=\n    [ A\n      ===>\n      B ]\n    ===>\n    C\n',
    path: 'notation.md', line: 51, description: 'A derived premise remains above its parent inference.' },
  { id: 'squares', kind: 'split', source: 'sig: [add] : [Int] -> [Int] -> [Int]\nrow: fn/add int/20 int/22 int/42\narrows: 3->4\n',
    path: 'notation.md', line: 124, description: 'A signature aligns over split squares; lower halves name the values.' },
  { id: 'circles', kind: 'split', source: 'tree:\n  black/(k1,v1)\n    red/(k2,v2)\n      red/(k3,v3)\n        a\n        b\n      c\n    d\n\ntree:\n  red/(k2,v2)\n    black/(k3,v3)\n      a\n      b\n    black/(k1,v1)\n      c\n      d\n',
    path: 'notation.md', line: 133, description: 'A candidate tree repairs to a reconstructed tree with unchanged subtrees.' }
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
      assert.doesNotMatch(svg, /<text\b|font-family|@font-face/i, `${diagram.id} must not depend on reader fonts`);
      assert.match(svg, /<path\b/, `${diagram.id} retains vector drawing and outlined glyphs`);
      if (diagram.kind === 'sequent') {
        assert.match(svg, /<use\b/, `${diagram.id} uses vector glyphs`);
      }
    }
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test('every generated figure stays inside the style contract palette', async () => {
  const renderDiagrams = await renderer();
  const output = await mkdtemp(join(tmpdir(), 'ash-doc-style-contract-'));
  const allowed = new Set();
  const collect = (value) => {
    if (typeof value === 'string') {
      for (const match of value.matchAll(/#[0-9a-f]{6}/gi)) allowed.add(match[0].toLowerCase());
    } else if (Array.isArray(value)) {
      value.forEach(collect);
    } else if (value && typeof value === 'object') {
      Object.values(value).forEach(collect);
    }
  };
  collect(contract);
  const toChannels = (hex) => [1, 3, 5].map((at) => Number.parseInt(hex.slice(at, at + 2), 16));
  const parsePaint = (value) => {
    if (value === 'none') return null;
    const hex = /^#([0-9a-f]{6})$/i.exec(value);
    if (hex) return toChannels(hex[0].toLowerCase());
    const percent = /^rgb\(\s*([0-9.]+)%\s*,\s*([0-9.]+)%\s*,\s*([0-9.]+)%\s*\)$/.exec(value);
    if (percent) return percent.slice(1, 4).map((part) => Math.round(Number(part) * 255 / 100));
    const absolute = /^rgb\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)$/.exec(value);
    if (absolute) return absolute.slice(1, 4).map((part) => Math.round(Number(part)));
    return undefined;
  };
  try {
    await renderDiagrams({ ...tools(), output, diagrams });
    for (const diagram of diagrams) {
      const svg = await readFile(join(output, `${diagram.id}.svg`), 'utf8');
      for (const match of svg.matchAll(/(?:fill|stroke)="([^"]+)"/g)) {
        const channels = parsePaint(match[1]);
        assert.notEqual(channels, undefined, `${diagram.id} carries an unrecognised paint ${match[1]}`);
        if (channels === null) continue;
        const ok = [...allowed].some((hex) => {
          const expected = toChannels(hex);
          return expected.every((channel, index) => Math.abs(channel - channels[index]) <= 1);
        });
        assert.ok(ok, `${diagram.id} carries ${match[1]} outside the style contract`);
      }
    }
  } finally {
    await rm(output, { recursive: true, force: true });
  }
});

for (const [kind, source, reason] of [
  ['ebnf', 'rule ::= ( "x" ;\n', /EBNF error at/],
  ['sequent', 'T-Int :=\n    GAMMA |- n ⇒ Int\n', /deduction operator/],
  ['mermaid', 'flowchart LR\n    A -->[\n', /Parse error/],
  ['split', 'row: bool/20\n', /unknown square top/]
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

test('a short railroad remains readable at the mobile article width', async () => {
  const renderDiagrams = await renderer();
  const output = await mkdtemp(join(tmpdir(), 'ash-doc-mobile-grammar-'));
  try {
    await renderDiagrams({ ...tools(), output, diagrams: [diagrams[2]] });
    const svg = await readFile(join(output, 'grammar.svg'), 'utf8');
    const width = Number(/<svg[^>]*\bwidth="([0-9.]+)"/.exec(svg)[1]);
    assert.ok(width <= 336, `Short grammar width ${width} must fit a 330px article without shrinking 14px labels below 13px.`);
  } finally {
    await rm(output, { recursive: true, force: true });
  }
});

test('external Mermaid images and CSS resources fail without network requests', async () => {
  const renderDiagrams = await renderer();
  const output = await mkdtemp(join(tmpdir(), 'ash-doc-external-diagram-'));
  let requests = 0;
  const pixel = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==', 'base64');
  const server = http.createServer((_request, response) => {
    requests += 1;
    response.setHeader('Content-Type', 'image/png');
    response.end(pixel);
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const url = `http://127.0.0.1:${server.address().port}/resource`;
  try {
    for (const source of [
      `flowchart LR\n  A@{ img: "${url}", label: "Image", w: 60, h: 60 }\n`,
      `%%{init: {"themeCSS":"@import url(${url});"}}%%\nflowchart LR\n  A --> B\n`
    ]) {
      await assert.rejects(renderDiagrams({ ...tools(), output, diagrams: [{ ...diagrams[0], source }] }), /external|image nodes|resources/i);
      await assert.rejects(access(join(output, 'graph.svg')), { code: 'ENOENT' });
    }
    const localStyle = JSON.stringify({ themeCSS: '.node rect { fill: url("#unused") #eee; }' });
    await renderDiagrams({ ...tools(), output, diagrams: [{ ...diagrams[0],
      source: `%%{init: ${localStyle}}%%\nflowchart LR\n    A --> B\n` }] });
    assert.equal(requests, 0, 'Diagram notation cannot fetch external resources.');
  } finally {
    await new Promise((resolve) => server.close(resolve));
    await rm(output, { recursive: true, force: true });
  }
});
