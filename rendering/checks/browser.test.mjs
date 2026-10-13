import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

async function helper(name) {
  const code = await readFile(new URL('./browser.mjs', import.meta.url), 'utf8');
  assert.match(code, new RegExp(`export function ${name}\\b`), `${name} is missing`);
  const module = await import('./browser.mjs');
  return module[name];
}

test('HTML chapter order includes introductions from the build manifest', async () => {
  const browserPlan = await helper('browserPlan');
  const source = { source: 'content/effects/example/README.md',
    chapter: 'effects-example.md', title: 'Example', anchor: 'example', code: [], assets: [] };
  const build = { mode: 'book', output_file: 'ash-doc-review', chapters:
    ['index.md', 'setup.md', 'effects-introduction.md', 'effects-example.md'] };
  assert.deepEqual(browserPlan(build, [source], []).chapters,
    ['index.html', 'setup.html', 'effects-introduction.html', 'effects-example.html']);
  assert.equal(browserPlan(build, [source], []).fixture, undefined);
  assert.throws(() => browserPlan({ ...build, chapters: ['index.md'] }, [source], []),
    /effects-example.md.*manifest/);
});

test('the sidebar homepage alias identifies the manifest index chapter', async () => {
  const htmlChapterName = await helper('htmlChapterName');
  const base = 'http://127.0.0.1:8123/setup.html';
  assert.equal(htmlChapterName('/', base), 'index.html');
  assert.equal(htmlChapterName('./index.html', base), 'index.html');
  assert.equal(htmlChapterName('./learn-introduction.html#learn-ash', base), 'learn-introduction.html');
  assert.equal(htmlChapterName(undefined, base), undefined);
});

test('fitting code is accepted and overflowing code must be reachable', async () => {
  const codeReachability = await helper('codeReachability');
  assert.doesNotThrow(() => codeReachability([]));
  assert.doesNotThrow(() => codeReachability([true, true]));
  assert.throws(() => codeReachability([true, false]), /scroll to the end/);
  assert.throws(() => codeReachability([], true), /known long-code specimen/);
});

test('generated figure expectations come from the selected source jobs', async () => {
  const generatedFigures = await helper('generatedFigures');
  const source = { source: 'rendering/specimen/notation.md' };
  const jobs = [{ path: source.source, id: 'first' },
    { path: 'content/cases/other/README.md', id: 'unrelated' },
    { path: source.source, id: 'second' }];
  assert.deepEqual(generatedFigures(source, jobs), ['assets/first.svg', 'assets/second.svg']);
  assert.deepEqual(generatedFigures(source, []), []);
});

test('local navigation expectations retain headings and inline code from staged source', async () => {
  const chapterHeadings = await helper('chapterHeadings');
  const document = { blocks: [
    { t: 'Header', c: [1, ['lesson', [], []], [{ t: 'Str', c: 'Lesson' }]] },
    { t: 'Header', c: [2, ['exercise', [], []], [{ t: 'Str', c: 'Exercise:' },
      { t: 'Space' }, { t: 'Code', c: [['', [], []], 'square'] }]] },
    { t: 'CodeBlock', c: [['', [], []], '## This is literal code'] },
    { t: 'Header', c: [4, ['detail', [], []], [{ t: 'Str', c: 'Detail' }]] }
  ] };
  assert.deepEqual(chapterHeadings(document), [{ anchor: 'exercise', title: 'Exercise: square' }]);
});

test('homepage navigation includes the source H1 retained below the book title', async () => {
  const chapterHeadings = await helper('chapterHeadings');
  const document = { blocks: [
    { t: 'Header', c: [1, ['ash-documentation', [], []], [{ t: 'Str', c: 'Ash documentation' }]] }
  ] };
  assert.deepEqual(chapterHeadings(document, true), [{ anchor: 'ash-documentation', title: 'Ash documentation' }]);
  assert.deepEqual(chapterHeadings(document), []);
});

test('EPUB mapping follows the OPF spine despite renamed files and extra front matter', async () => {
  const mapEpubChapters = await helper('mapEpubChapters');
  const first = { source: 'content/learn/one/README.md', title: 'First lesson', anchor: 'first' };
  const last = { source: 'rendering/specimen/notation.md', title: 'Notation', anchor: 'notation' };
  const spine = [
    { href: 'EPUB/text/cover.xhtml', headings: [] },
    { href: 'EPUB/nav.xhtml', headings: [] },
    { href: 'EPUB/text/introduction.xhtml', headings: [] },
    { href: 'EPUB/text/unusual-name.xhtml', headings: [{ title: 'Notation', anchor: 'notation' }] },
    { href: 'EPUB/text/ch051.xhtml', headings: [{ title: 'First lesson', anchor: 'first' }] }
  ];
  const navigation = [
    { href: 'EPUB/text/ch051.xhtml#first', title: '1 First lesson' },
    { href: 'EPUB/text/unusual-name.xhtml#notation', title: 'Notation' }
  ];
  const result = mapEpubChapters(spine, navigation, [first, last]);
  assert.deepEqual(result.map(chapter => chapter.source?.source),
    [undefined, undefined, undefined, last.source, first.source]);
  assert.equal(result.find(chapter => chapter.source === last).href,
    'EPUB/text/unusual-name.xhtml');
});

test('EPUB mapping accepts a chapter anchor on its section through navigation', async () => {
  const mapEpubChapters = await helper('mapEpubChapters');
  const source = { source: 'content/libraries/example/README.md', title: 'Element behavior', anchor: 'element-behavior' };
  const spine = [{ href: 'EPUB/text/topic.xhtml', headings: [{ title: source.title, anchor: '' }] }];
  const navigation = [{ href: 'EPUB/text/topic.xhtml#element-behavior', title: source.title }];
  assert.equal(mapEpubChapters(spine, navigation, [source])[0].source, source);
});

test('EPUB mapping preserves the element behavior lesson through smart punctuation', async () => {
  const mapEpubChapters = await helper('mapEpubChapters');
  const source = { source: 'content/libraries/requiring-element-behavior/README.md',
    title: "How can an implementation depend on its element's behavior?",
    anchor: 'how-can-an-implementation-depend-on-its-elements-behavior' };
  const rendered = 'How can an implementation depend on its element’s behavior?';
  const spine = [{ href: 'EPUB/text/ch005.xhtml', headings: [{ title: rendered, anchor: '' }] }];
  const navigation = [{ href: `EPUB/text/ch005.xhtml#${source.anchor}`, title: rendered }];
  assert.equal(mapEpubChapters(spine, navigation, [source])[0].source, source);
});

test('HTML and navigation heading comparisons retain words through smart quotes', async () => {
  const headingText = await helper('headingText');
  assert.equal(headingText('  The “element’s” behavior\n'), 'The "element\'s" behavior');
  assert.notEqual(headingText('Element behavior'), headingText('Element order'));
});

test('EPUB mapping rejects a missing or ambiguous lesson instead of skipping its code', async () => {
  const mapEpubChapters = await helper('mapEpubChapters');
  const source = { source: 'content/learn/one/README.md', title: 'First lesson', anchor: 'first' };
  assert.throws(() => mapEpubChapters([], [], [source]), /one\/README.md.*missing/);
  const heading = { title: source.title, anchor: source.anchor };
  assert.throws(() => mapEpubChapters([
    { href: 'EPUB/text/a.xhtml', headings: [heading] },
    { href: 'EPUB/text/b.xhtml', headings: [heading] }
  ], [], [source]), /one\/README.md.*ambiguous/);
});
