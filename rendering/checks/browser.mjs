import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { createServer } from 'node:http';
import { access, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { dirname, extname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

export function browserPlan(build, sources, jobs) {
  assert.ok(['book', 'specimen'].includes(build.mode), 'The build names its book or specimen mode.');
  assert.ok(Array.isArray(build.chapters) && build.chapters.length > 0, 'The build records its chapters.');
  const chapters = build.chapters.map(chapter => {
    assert.match(chapter, /\.md$/, 'Chapter inputs are staged Markdown files.');
    return chapter.replace(/\.md$/, '.html');
  });
  assert.equal(new Set(chapters).size, chapters.length, 'Chapter filenames are distinct.');
  for (const source of sources) assert.ok(build.chapters.includes(source.chapter),
    `${source.chapter} is missing from the build manifest.`);
  return { chapters, sources, jobs, fixture: build.mode === 'specimen' ? sources.find(source =>
    source.source === 'rendering/specimen/notation.md') : undefined };
}

export function codeReachability(scroll, required = false) {
  assert.ok(!required || scroll.length > 0, 'The known long-code specimen still exercises overflow.');
  assert.ok(scroll.every(Boolean), 'Readers can scroll to the end of long lines.');
}

export function generatedFigures(source, jobs) {
  return jobs.filter(job => job.path === source.source).map(job => `assets/${job.id}.svg`);
}

export function htmlChapterName(href, base) {
  return href ? new URL(href, base).pathname.replace(/^\//, '') || 'index.html' : undefined;
}

export function chapterHeadings(document, includeTitle = false) {
  const text = node => {
    if (Array.isArray(node)) return node.map(text).join('');
    if (!node || typeof node !== 'object') return '';
    if (node.t === 'Str') return node.c;
    if (['Space', 'SoftBreak', 'LineBreak'].includes(node.t)) return ' ';
    if (['Code', 'Math'].includes(node.t)) return node.c[1];
    if (['Link', 'Image'].includes(node.t)) return text(node.c[1]);
    return text(node.c);
  };
  const result = [];
  const visit = node => {
    if (Array.isArray(node)) return node.forEach(visit);
    if (!node || typeof node !== 'object') return;
    if (node.t === 'Header' && ([2, 3].includes(node.c[0]) || (includeTitle && node.c[0] === 1))) {
      result.push({ anchor: node.c[1][0], title: text(node.c[2]) });
    } else if (node.t !== 'CodeBlock') Object.values(node).forEach(visit);
  };
  visit(document.blocks);
  return result;
}

export function headingText(value) {
  return value.replace(/[‘’]/g, "'").replace(/[“”]/g, '"').replace(/\s+/g, ' ').trim();
}

export function mapEpubChapters(spine, navigation, sources) {
  const title = value => headingText(value).replace(/^\d+(?:\.\d+)*\s+/, '');
  const byHref = new Map();
  for (const source of sources) {
    assert.ok(source.title && source.anchor, `${source.source} records its source heading and anchor.`);
    const candidates = spine.filter(chapter => {
      const heading = chapter.headings.some(heading => title(heading.title) === title(source.title) &&
        (!heading.anchor || heading.anchor === source.anchor));
      const link = navigation.some(link => link.href.split('#')[0] === chapter.href &&
        title(link.title) === title(source.title) && link.href.split('#')[1] === source.anchor);
      return heading || link;
    });
    assert.equal(candidates.length, 1,
      `${source.source}: EPUB source mapping is ${candidates.length ? 'ambiguous' : 'missing'}.`);
    const href = candidates[0].href;
    assert.ok(!byHref.has(href), `${source.source}: EPUB chapter is already assigned to another source.`);
    byHref.set(href, source);
  }
  return spine.map(chapter => ({ ...chapter, source: byHref.get(chapter.href) }));
}

async function main() {
  assert.ok(process.argv.length <= 3, 'Usage: node rendering/checks/browser.mjs [.build/book|.build/specimen]');
  const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
  const project = resolve(process.argv[2] ?? join(root, '.build/specimen'));
  const output = join(project, 'output');
  const qa = join(project, 'qa-browser');
  const toolchain = join(root, '.build/toolchain');
  const manifest = JSON.parse(await readFile(join(root, 'rendering/toolchain/manifest.json'), 'utf8'));
  const chromeVersion = manifest.mermaid_cli.browser.replace(/^Chrome /, '');
  const executablePath = process.env.CHROME_BIN ?? join(toolchain,
    `browser-cache/chrome/linux-${chromeVersion}/chrome-linux64/chrome`);
  const modulePath = process.env.PUPPETEER_MODULE ?? join(toolchain,
    'mermaid/node_modules/puppeteer/lib/puppeteer/puppeteer.js');
  const { default: puppeteer } = await import(pathToFileURL(modulePath).href);
  const sources = JSON.parse(await readFile(join(project, 'sources.json'), 'utf8'));
  const build = JSON.parse(await readFile(join(project, 'build.json'), 'utf8'));
  const jobs = JSON.parse(await readFile(join(project, 'diagram-jobs.json'), 'utf8')).diagrams;
  const { chapters, fixture } = browserPlan(build, sources, jobs);
  const quarto = join(toolchain, `quarto-${manifest.quarto.version}/bin/quarto`);
  const localHeadings = new Map(await Promise.all(build.chapters.map(async chapter => {
    const document = JSON.parse(execFileSync(quarto,
      ['pandoc', '--from', 'markdown-smart', '--to', 'json'],
      { input: await readFile(join(project, chapter), 'utf8'), encoding: 'utf8' }));
    return [chapter.replace(/\.md$/, '.html'), chapterHeadings(document, chapter === 'index.md')];
  })));
  const lessonSource = sources.find(source => source.source ===
    'content/cases/guaranteeing-logarithmic-retrieval/README.md');
  assert.ok(lessonSource, 'The real search-tree lesson is selected.');
  const lessonHtml = lessonSource.chapter.replace(/\.md$/, '.html');
  const fixtureHtml = fixture?.chapter.replace(/\.md$/, '.html');
  const report = { scope: 'Browser HTML and extracted EPUB XHTML; no e-reader compatibility claim.',
    mode: build.mode, outputFile: build.output_file, sourceCommit: build.source_commit,
    browser: '', checks: [], screenshots: [], secondaryEngine: null };
  const mime = { '.html': 'text/html', '.xhtml': 'application/xhtml+xml', '.css': 'text/css',
    '.js': 'text/javascript', '.svg': 'image/svg+xml', '.json': 'application/json',
    '.otf': 'font/otf', '.ttf': 'font/ttf', '.woff': 'font/woff' };
  await mkdir(qa, { recursive: true });
  const epub = join(qa, 'epub');
  await rm(epub, { recursive: true, force: true });
  execFileSync('python3', ['-c',
    'import sys,zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])',
    join(output, `${build.output_file}.epub`), epub]);
  const epubStructure = JSON.parse(execFileSync('python3', ['-c', String.raw`
import json, posixpath, sys, xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote, urlsplit
root = Path(sys.argv[1])
container = ET.parse(root / 'META-INF/container.xml')
package = container.find('.//{*}rootfile').attrib['full-path']
document = ET.parse(root / package)
base = posixpath.dirname(package)
items = {item.attrib['id']: item.attrib for item in document.findall('.//{*}manifest/{*}item')}
def href(base, value):
    url = urlsplit(value)
    if url.scheme or url.netloc:
        raise ValueError('EPUB chapter link is external: ' + value)
    path = posixpath.normpath(posixpath.join(base, unquote(url.path)))
    if path == '..' or path.startswith('../') or path.startswith('/'):
        raise ValueError('EPUB chapter link escapes the archive: ' + value)
    return path + ('#' + unquote(url.fragment) if url.fragment else '')
def text(node):
    return ''.join(node.itertext()).strip()
navigation = []
for item in items.values():
    if 'nav' not in item.get('properties', '').split():
        continue
    name = href(base, item['href'])
    nav = ET.parse(root / name)
    for node in nav.findall('.//{*}nav'):
        if 'toc' not in node.attrib.get('{http://www.idpf.org/2007/ops}type', '').split():
            continue
        navigation.extend({'href': href(posixpath.dirname(name), link.attrib['href']),
                           'title': text(link)} for link in node.findall('.//{*}a'))
spine = []
for reference in document.findall('.//{*}spine/{*}itemref'):
    item = items[reference.attrib['idref']]
    if item['media-type'] != 'application/xhtml+xml':
        continue
    name = href(base, item['href'])
    chapter = ET.parse(root / name)
    headings = [{'title': text(node), 'anchor': node.attrib.get('id', '')}
                for node in chapter.findall('.//{*}h1')]
    spine.append({'href': name, 'headings': headings})
print(json.dumps({'spine': spine, 'navigation': navigation}))
  `, epub], { encoding: 'utf8' }));
  const epubChapters = mapEpubChapters(epubStructure.spine, epubStructure.navigation, sources);

  const server = createServer(async (request, response) => {
    try {
      const url = new URL(request.url, 'http://localhost');
      const base = url.pathname.startsWith('/epub/') ? epub : output;
      const name = decodeURIComponent(url.pathname.replace(/^\/epub\//, '/')).replace(/^\//, '');
      const path = resolve(base, name || 'index.html');
      assert.ok(path === base || path.startsWith(base + sep), 'Request stays inside the artifact.');
      const body = await readFile(path);
      response.writeHead(200, { 'Content-Type': mime[extname(path)] ?? 'application/octet-stream' });
      response.end(body);
    } catch {
      response.writeHead(404);
      response.end();
    }
  });
  await new Promise((complete, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', complete);
  });
  const origin = `http://127.0.0.1:${server.address().port}`;
  let browser;

  async function check(name, action) {
    try {
      await action();
      report.checks.push({ name, status: 'pass' });
    } catch (error) {
      report.checks.push({ name, status: 'fail', message: error.message });
    }
  }

  async function load(page, name) {
    const response = await page.goto(`${origin}/${name}`, { waitUntil: 'networkidle0' });
    assert.equal(response.status(), 200, name);
    await page.evaluate(() => document.fonts.ready);
  }

  async function screenshot(page, name, element) {
    const path = join(qa, name);
    if (element) await (await page.$(element)).screenshot({ path });
    else await page.screenshot({ path, fullPage: true });
    report.screenshots.push(relative(root, path));
  }

  async function noOverflow(page) {
    const dimensions = await page.evaluate(() => ({
      width: document.documentElement.clientWidth,
      scroll: document.documentElement.scrollWidth
    }));
    assert.ok(dimensions.scroll <= dimensions.width + 1,
      `Page width ${dimensions.width}px is exceeded by ${dimensions.scroll - dimensions.width}px.`);
  }

  async function exactCode(page, source, selector = 'main pre > code') {
    const code = await page.$$eval(selector, nodes => nodes.map(node =>
      node.textContent.replace(/\n$/, '')));
    assert.deepEqual(code, source.code.map(block => block.text),
      `${source.source}: code and complete diagnostic text survive rendering.`);
  }

  async function images(page, source, selector = 'main img') {
    const figures = await page.$$eval(selector, nodes => nodes.map(node => ({
      alt: node.alt, src: node.getAttribute('src'), complete: node.complete, naturalWidth: node.naturalWidth,
      width: node.getBoundingClientRect().width, height: node.getBoundingClientRect().height,
      left: node.getBoundingClientRect().left, right: node.getBoundingClientRect().right,
      limit: document.documentElement.clientWidth
    })));
    const expected = generatedFigures(source, jobs).map(path => path.replace(/^assets\//, '').replace(/\.svg$/, ''));
    assert.ok(figures.length >= source.assets.length + expected.length,
      'Every selected source asset and diagram has a rendered image.');
    if (selector === 'main img') for (const asset of source.assets) assert.ok(
      figures.some(image => new URL(image.src, page.url()).pathname.endsWith(`/${asset.staged}`)),
      `${asset.source}: the selected source image is rendered.`);
    for (const image of figures) {
      assert.ok(image.alt.trim().length > 0, 'The figure has a textual explanation.');
      assert.ok(image.complete && image.naturalWidth > 0, 'The SVG loads through an img element.');
      assert.ok(image.width > 0 && image.height > 0, 'The figure has visible dimensions.');
      assert.ok(image.left >= -1 && image.right <= image.limit + 1, 'The figure fits the page.');
    }
    const diagrams = await page.evaluate(ids => ids.map(id => {
      const figure = document.getElementById(id);
      const image = figure?.matches('img') ? figure : figure?.querySelector('img');
      const box = image?.getBoundingClientRect();
      return image && { alt: image.alt, width: box.width, height: box.height };
    }), expected);
    assert.equal(diagrams.filter(Boolean).length, expected.length, 'Every selected diagram job has a rendered image.');
    for (const image of diagrams) {
      assert.ok(image.alt.length > 20, 'The generated diagram retains its complete description.');
      assert.ok(image.width > 140 && image.height > 40, 'The generated diagram has readable dimensions.');
    }
  }

  async function codeOverflow(page, selector = 'main pre', required = false) {
    const scroll = await page.$$eval(selector, nodes => nodes.filter(node =>
      node.scrollWidth > node.clientWidth + 1).map(node => {
        node.scrollLeft = node.scrollWidth;
        const reachable = node.scrollLeft > 0 && ['auto', 'scroll'].includes(getComputedStyle(node).overflowX);
        node.scrollLeft = 0;
        return reachable;
      }));
    codeReachability(scroll, required);
  }

  async function navigationChrome(page, chapter, label) {
    const navigation = await page.evaluate(() => ({
      book: [...document.querySelectorAll('#quarto-sidebar .sidebar-menu-container a[href]')]
        .map(node => node.getAttribute('href')),
      local: [...document.querySelectorAll('#TOC a[data-scroll-target]')].map(node => ({
        anchor: node.getAttribute('data-scroll-target').slice(1), title: node.textContent.trim()
      })),
      mobile: [...document.querySelectorAll('.on-this-page a[href]')].map(node => ({
        anchor: new URL(node.href).hash.slice(1), title: node.textContent.trim()
      })),
      insideArticle: !!document.querySelector('main #TOC, main #quarto-sidebar, main .on-this-page')
    }));
    const names = navigation.book.map(href => htmlChapterName(href, `${origin}/${chapter}`));
    assert.deepEqual(names, chapters, 'The book navigation retains every manifest chapter in order.');
    const headings = nodes => nodes.map(node => ({ ...node, title: headingText(node.title) }));
    assert.deepEqual(headings(navigation.local), headings(localHeadings.get(chapter)),
      'Local navigation follows the staged source headings.');
    assert.equal(navigation.insideArticle, false, 'Navigation stays outside the article.');
    if (label === 'mobile') assert.deepEqual(navigation.mobile, navigation.local,
      'The mobile disclosure retains the complete local navigation.');
  }

  async function localKeyboard(page, chapter, label) {
    const first = localHeadings.get(chapter)[0];
    if (!first) return;
    if (label === 'mobile') {
      await page.focus('.on-this-page summary');
      await page.keyboard.press('Enter');
      await page.keyboard.press('Tab');
      assert.equal(await page.evaluate(() => new URL(document.activeElement.href).hash), `#${first.anchor}`);
    } else await page.focus(`#TOC a[data-scroll-target="#${first.anchor}"]`);
    await page.keyboard.press('Enter');
    await page.waitForFunction(hash => location.hash === hash, {}, `#${first.anchor}`);
    if (label === 'mobile') {
      await page.focus('.on-this-page summary');
      await page.keyboard.press('Enter');
    }
  }

  async function mobileNavigationPlacement(page, chapter) {
    const placement = await page.evaluate(() => ({
      menuBottom: document.querySelector('.on-this-page summary')?.getBoundingClientRect().bottom,
      titleTop: document.querySelector('main h1').getBoundingClientRect().top,
      articleBottom: document.querySelector('main').getBoundingClientRect().bottom,
      navigationTop: document.querySelector('.page-navigation').getBoundingClientRect().top
    }));
    if (localHeadings.get(chapter).length) assert.ok(placement.menuBottom <= placement.titleTop,
      `The chapter menu ends at ${placement.menuBottom}px but the title starts at ${placement.titleTop}px.`);
    assert.ok(placement.navigationTop >= placement.articleBottom,
      `Page navigation starts at ${placement.navigationTop}px but the chapter ends at ${placement.articleBottom}px.`);
  }

  const fullWidthParagraph = 'Full-width note. The text and note columns can share a single aside when an explanation needs more room. This paragraph keeps the same reading order while using the space normally reserved for sidenotes. A narrow screen or e-reader returns the block to one flowing column.';

  async function fullWidthContent(page) {
    const content = await page.evaluate(() => {
      const block = document.getElementById('full-width-note');
      if (!block) return null;
      const text = node => node?.textContent.replace(/\s+/g, ' ').trim();
      const paragraph = block.querySelector('p');
      const emphasis = block.querySelector('p em');
      const strong = block.querySelector('td strong');
      const code = block.querySelector('td code');
      return {
        paragraph: text(paragraph), label: text(emphasis),
        headers: [...block.querySelectorAll('th')].map(text),
        rows: [...block.querySelectorAll('tbody tr')].map(row => [...row.querySelectorAll('td')].map(text)),
        italic: text(block.querySelector('td em')), bold: text(strong), code: text(code),
        emphasisStyle: emphasis && getComputedStyle(emphasis).fontStyle,
        boldWeight: strong && getComputedStyle(strong).fontWeight,
        codeFont: code && getComputedStyle(code).fontFamily,
        fontSize: paragraph && Number.parseFloat(getComputedStyle(paragraph).fontSize)
      };
    });
    assert.ok(content, 'The full-width note is rendered with its source identifier.');
    assert.equal(content.paragraph, fullWidthParagraph, 'The complete aside paragraph is preserved.');
    assert.equal(content.label, 'Full-width note.');
    assert.deepEqual(content.headers, ['Body text', 'Sidenote text', 'A shared aside']);
    assert.deepEqual(content.rows, [
      ['Regular type', 'Secondary explanation', 'A wider reading area'],
      ['inline_code', 'Short or long notes', 'One reading order']
    ]);
    assert.equal(content.italic, 'Secondary explanation');
    assert.equal(content.bold, 'A wider reading area');
    assert.equal(content.code, 'inline_code');
    assert.equal(content.emphasisStyle, 'italic', 'Emphasis retains its visible formatting.');
    assert.ok(Number(content.boldWeight) >= 600, 'Strong text remains visibly distinct.');
    assert.match(content.codeFont, /mono/i, 'Inline code retains a monospace face.');
    assert.ok(content.fontSize >= 12, 'The aside retains readable paragraph type.');
  }

  async function fullWidthLayout(page, layout) {
    const dimensions = await page.evaluate(() => {
      const block = document.getElementById('full-width-note');
      if (!block) return null;
      const box = node => {
        const bounds = node.getBoundingClientRect();
        return { left: bounds.left, right: bounds.right, top: bounds.top,
          bottom: bounds.bottom, width: bounds.width, height: bounds.height };
      };
      return {
        block: box(block), table: box(block.querySelector('table')),
        tableScroll: block.querySelector('table').scrollWidth,
        body: document.querySelector('main p') && box(document.querySelector('main p')),
        navigation: document.querySelector('#quarto-sidebar') && box(document.querySelector('#quarto-sidebar')),
        notes: ['fn1', 'fn2'].map(id => document.getElementById(id)).filter(Boolean).map(box),
        viewport: document.documentElement.clientWidth
      };
    });
    assert.ok(dimensions, 'The full-width note is available for layout checks.');
    const { block, body, navigation, notes, table, tableScroll, viewport } = dimensions;
    assert.ok(block.width > 0 && block.height > 0, 'The aside occupies visible space.');
    assert.ok(block.left >= 0 && block.right <= viewport + 1, 'The aside stays inside the page.');
    if (layout === 'desktop') {
      assert.ok(block.left >= body.left - 1, 'The aside starts in the body column.');
      assert.ok(block.left >= navigation.right, 'The aside leaves book and chapter navigation clear.');
      assert.ok(block.width >= body.width + 100, 'The aside uses the body and right note area.');
      assert.ok(block.right >= Math.max(...notes.map(note => note.right)) - 1,
        'The aside extends through the right note column.');
      for (const note of notes) assert.ok(note.bottom <= block.top || note.top >= block.bottom,
        'The full-width aside does not collide with a sidenote.');
    }
    assert.ok(table.width <= block.width + 1 && tableScroll <= block.width + 1,
      'The full table remains inside the reflowed aside.');
  }

  async function settledNotes(page) {
    await page.evaluate(async () => {
      await document.fonts.ready;
      await Promise.all([...document.images].map(image => image.decode().catch(() => {})));
    });
    let previous;
    let stableSince = Date.now();
    const started = Date.now();
    while (Date.now() - started < 10000) {
      const current = JSON.stringify(await page.$$eval('#red-root-sketch, #height-counting-cue, #repair-comparison',
        nodes => nodes.map(node => {
          const box = node.getBoundingClientRect();
          return [box.x, box.y, box.width, box.height].map(value => Math.round(value * 10));
        })));
      if (current !== previous) { previous = current; stableSince = Date.now(); }
      if (Date.now() - stableSince >= 750) return;
      await new Promise(complete => setTimeout(complete, 50));
    }
    throw new Error('Native mixed-note geometry did not settle within 10 seconds.');
  }

  async function realLessonNotes(page, layout) {
    await settledNotes(page);
    const geometry = await page.evaluate(() => {
      const box = node => {
        const bounds = node.getBoundingClientRect();
        return { left: bounds.left, right: bounds.right, top: bounds.top,
          bottom: bounds.bottom, width: bounds.width, height: bounds.height };
      };
      const sketch = document.getElementById('red-root-sketch');
      const image = sketch?.matches('img') ? sketch : sketch?.querySelector('img');
      const note = image?.closest('[role="doc-footnote"], .sidenote, .footnote, [id^="fn"]');
      const reference = note && [...document.querySelectorAll('a.footnote-ref')].find(ref =>
        new URL(ref.href).hash.slice(1) === note.id);
      const cue = document.getElementById('height-counting-cue');
      const wide = document.getElementById('repair-comparison');
      const wideFigure = document.getElementById('fig-tree-repair');
      const wideImage = wideFigure?.matches('img') ? wideFigure : wideFigure?.querySelector('img');
      if (!image || !note || !reference || !cue || !wide || !wideImage) return null;
      const imageData = image => ({ ...box(image), alt: image.alt,
        complete: image.complete, naturalWidth: image.naturalWidth });
      const cueParent = cue.parentElement.closest('section');
      return { sketch: imageData(image), note: box(note), reference: box(reference),
        referenceText: reference.parentElement.textContent.replace(/\s+/g, ' ').trim(),
        noteText: note.textContent.replace(/\s+/g, ' ').trim(), cue: box(cue),
        cueText: cue.textContent.replace(/\s+/g, ' ').trim(), cueSection: cueParent?.id,
        cueMarkers: cue.querySelectorAll('a.footnote-ref, a.footnote-back, a.footnote-backref').length,
        wide: box(wide), wideImage: imageData(wideImage),
        body: box(document.querySelector('main > section > p, main p') ?? document.querySelector('section > p')),
        viewport: document.documentElement.clientWidth };
    });
    assert.ok(geometry, 'The real lesson includes all three note forms and a linked graphical sidenote.');
    const { sketch, note, reference, cue, wide, wideImage, body, viewport } = geometry;
    for (const image of [sketch, wideImage]) {
      assert.ok(image.complete && image.naturalWidth > 0, 'The canonical lesson SVG loads.');
      assert.ok(image.alt.length > 20, 'The lesson figure retains a useful description.');
      assert.ok(image.width > 100 && image.height > 30, 'The lesson figure has readable dimensions.');
    }
    assert.ok(sketch.width <= note.width + 1 && sketch.left >= note.left - 1 && sketch.right <= note.right + 1,
      'The optional sketch fits the actual note width.');
    if (layout !== 'epub') assert.ok(Math.abs(note.top - reference.top) < 500,
      'The numbered sketch remains near its HTML reference.');
    assert.match(geometry.referenceText, /Empty counts as black/);
    assert.match(geometry.noteText, /Both paths contain one black form/);
    assert.match(geometry.cueText, /Counting cue/);
    assert.equal(geometry.cueMarkers, 0, 'The local counting cue has no footnote marker.');
    assert.match(geometry.cueSection ?? '', /height|logarithm|bound/, 'The counting cue stays with the height proof.');
    assert.ok(wideImage.width <= wide.width + 1 && wideImage.left >= wide.left - 1 && wideImage.right <= wide.right + 1,
      'The full-width image stays inside its reading region.');
    assert.ok(wide.left >= 0 && wide.right <= viewport + 1, 'The wide figure fits the viewport.');
    if (layout === 'desktop') {
      assert.ok(wide.width >= body.width + 100 && wideImage.width >= body.width + 100,
        'The figure itself uses the body and note columns.');
      assert.ok(note.left >= body.right - 1 && cue.left >= body.right - 1,
        'Both local note forms occupy the right margin.');
      for (const margin of [note, cue]) {
        assert.ok(margin.bottom <= wide.top || margin.top >= wide.bottom,
          'The wide figure has no collision with margin content.');
      }
      assert.ok(note.bottom <= cue.top || note.top >= cue.bottom, 'The two margin notes do not overlap.');
    }
    return geometry;
  }

  async function realLessonReference(page) {
    const start = page.url();
    const note = await page.$eval('#red-root-sketch', node =>
      node.closest('[role="doc-footnote"], [id^="fn"]').id);
    const selector = `a.footnote-ref[href="#${note}"]`;
    await page.click(selector);
    assert.equal(new URL(page.url()).hash, `#${note}`, 'The reference opens its own graphical note.');
    await page.goBack();
    assert.equal(page.url(), start, 'Browser history returns from the native EPUB note.');
  }

  async function realLessonCapture(page, label, layout = label) {
    await page.$eval('#red-root-sketch', node => node.scrollIntoView({ block: 'center' }));
    await settledNotes(page);
    const path = join(qa, `real-lesson-notes-${label}.png`);
    await page.screenshot({ path });
    report.screenshots.push(relative(root, path));
    await realLessonNotes(page, layout);
    await page.$eval('#repair-comparison', node => node.scrollIntoView({ block: 'center' }));
    await settledNotes(page);
    const widePath = join(qa, `real-lesson-wide-${label}.png`);
    await page.screenshot({ path: widePath });
    report.screenshots.push(relative(root, widePath));
    await realLessonNotes(page, layout);
  }

  try {
    browser = await puppeteer.launch({ executablePath, args: ['--no-sandbox', '--disable-dev-shm-usage'] });
    report.browser = await browser.version();
    assert.equal(report.browser, `Chrome/${chromeVersion}`, 'Use the pinned Chrome build.');
    const page = await browser.newPage();
    page.setDefaultTimeout(5000);
    const errors = [];
    const externalRequests = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.setRequestInterception(true);
    page.on('request', request => {
      if (/^https?:/.test(request.url()) && new URL(request.url()).origin !== origin) {
        externalRequests.push(request.url());
        void request.abort();
      } else void request.continue();
    });
    for (const [width, height, label] of [[1440, 1000, 'desktop'], [390, 844, 'mobile']]) {
      await page.setViewport({ width, height });
      for (const [index, chapter] of chapters.entries()) {
        await load(page, chapter);
        await check(`${label}: ${chapter} has no page overflow`, () => noOverflow(page));
        await check(`${label}: ${chapter} previous and next follow chapter order`, async () => {
          const navigation = await page.evaluate(() => ({
            previous: document.querySelector('.nav-page-previous a')?.getAttribute('href'),
            next: document.querySelector('.nav-page-next a')?.getAttribute('href')
          }));
          assert.equal(htmlChapterName(navigation.previous, origin), chapters[index - 1]);
          assert.equal(htmlChapterName(navigation.next, origin), chapters[index + 1]);
        });
        const source = sources.find(item => item.chapter.replace(/\.md$/, '.html') === chapter);
        if (source) {
          await check(`${label}: ${chapter} retains its source title`, async () => {
            assert.equal(headingText(await page.$eval('main h1', node => node.textContent)), headingText(source.title));
          });
          await check(`${label}: ${chapter} retains exact code text`, () => exactCode(page, source));
          await check(`${label}: ${chapter} source images load and fit`, () => images(page, source));
        }
        const requiredOverflow = build.mode === 'specimen' && [
          'content/cases/guaranteeing-logarithmic-retrieval/README.md',
          'content/libraries/requiring-element-behavior/README.md'
        ].includes(source?.source);
        await check(`${label}: ${chapter} overflowing code remains horizontally reachable`,
          () => codeOverflow(page, 'main pre', requiredOverflow));
        await check(`${label}: ${chapter} navigation follows the book and source headings`,
          () => navigationChrome(page, chapter, label));
        if (localHeadings.get(chapter).length) await check(`${label}: ${chapter} local navigation works by keyboard`,
          () => localKeyboard(page, chapter, label));
        if (label === 'mobile') await check(`${label}: ${chapter} navigation stays clear of the article`,
          () => mobileNavigationPlacement(page, chapter));
      }
      await load(page, lessonHtml);
      await check(`${label}: real lesson note forms, sketch, and wide figure fit`, () => realLessonNotes(page, label));
      await check(`${label}: viewport capture preserves mixed-note geometry`, () => realLessonCapture(page, label));
      if (label === 'mobile') await check('mobile: book navigation expands and collapses', async () => {
        await load(page, lessonHtml);
        await page.click('button.quarto-btn-toggle');
        await page.waitForFunction(() => document.querySelector('#quarto-sidebar').classList.contains('show'));
        assert.ok(await page.$eval('#quarto-sidebar .sidebar-menu-container', node =>
          node.getBoundingClientRect().width > 100));
        await page.click('button.quarto-btn-toggle');
        await page.waitForFunction(() => {
          const nav = document.querySelector('#quarto-sidebar');
          return !nav.classList.contains('show') && !nav.classList.contains('collapsing');
        });
      });
      await load(page, 'index.html');
      await screenshot(page, `html-${label}.png`);
      if (fixture) {
        await load(page, fixtureHtml);
        await check(`${label}: both notes remain available near their references`, async () => {
          const notes = await page.evaluate(() => [...document.querySelectorAll('a.footnote-ref')].map(ref => {
            const note = document.getElementById(new URL(ref.href).hash.slice(1));
            const reference = ref.getBoundingClientRect();
            const box = note?.getBoundingClientRect();
            return { reference: reference.top, top: box?.top, width: box?.width, height: box?.height,
              visible: note && getComputedStyle(note).visibility !== 'hidden', text: note?.textContent };
          }));
          assert.equal(notes.length, 2);
          for (const note of notes) {
            assert.ok(note.visible && note.width > 100 && note.height > 10,
              'Linked note text remains visibly available.');
            assert.ok(Math.abs(note.top - note.reference) < 500,
              'The note remains associated with the nearby reference.');
          }
        });
        await check(`${label}: selected static diagrams load and fit`, () => images(page, fixture));
        await check(`${label}: full-width aside preserves complete text and formatting`, () => fullWidthContent(page));
        await check(`${label}: full-width aside uses its reading area without overlap`, () => fullWidthLayout(page, label));
        await page.evaluate(() => window.scrollTo(0, 0));
        await screenshot(page, `html-notation-${label}.png`);
        if (await page.$('#full-width-note')) await screenshot(page, `html-full-width-${label}.png`, '#full-width-note');
        if (label === 'desktop') {
          await screenshot(page, 'html-railroad.png', '#fig-grammar');
          await screenshot(page, 'html-sequent.png', '#fig-inference');
        }
      }
    }
    await check('HTML has no uncaught JavaScript errors', () => assert.deepEqual(errors, []));
    await page.setViewport({ width: 1024, height: 900 });
    await load(page, fixtureHtml ?? lessonHtml);
    await check('tablet: in-chapter navigation remains visible at 1024px', async () => {
      const visible = await page.$eval('#TOC', node => {
        const box = node.getBoundingClientRect();
        return box.width > 100 && box.height > 0 && box.top < innerHeight && box.left >= 0 && box.right <= innerWidth;
      });
      assert.equal(visible, true, 'The floating chapter TOC remains available above the mobile cutoff.');
    });
    await page.setViewport({ width: 390, height: 844 });
    await check('EPUB: source chapters follow manifest order', () => assert.deepEqual(
      epubChapters.filter(chapter => chapter.source).map(chapter => chapter.source.chapter),
      sources.map(source => source.chapter)));
    for (const chapter of epubChapters) {
      await load(page, `epub/${chapter.href}`);
      await page.evaluate(() => { document.documentElement.style.fontSize = '28px'; });
      await check(`EPUB at enlarged text: ${chapter.href} reflows without overflow`, () => noOverflow(page));
      const source = chapter.source;
      if (source) {
        await check(`EPUB: ${chapter.href} retains exact code text`, () => exactCode(page, source, 'pre > code'));
        await check(`EPUB: ${chapter.href} source images load and fit`, () => images(page, source, 'img'));
      }
      await check(`EPUB: ${chapter.href} overflowing code remains reachable`, () => codeOverflow(page, 'pre'));
      if (source?.source === lessonSource.source) {
        await check('EPUB at enlarged text: real lesson notes and figures reflow', () => realLessonNotes(page, 'epub'));
        await check('EPUB: graphical note reference and history return work', () => realLessonReference(page));
        await check('EPUB: real lesson viewport capture preserves note geometry', () => realLessonCapture(page, 'epub'));
      }
    }
    const epubFixture = fixture && epubChapters.find(chapter => chapter.source === fixture);
    const epubLesson = epubChapters.find(chapter => chapter.source === lessonSource);
    const preview = epubFixture ?? epubLesson;
    await load(page, `epub/${preview.href}`);
    await page.evaluate(() => { document.documentElement.style.fontSize = '28px'; });
    if (epubFixture) {
      await check('EPUB: selected SVG diagrams and linked notes remain available', async () => {
        await images(page, fixture, 'img');
        const reference = await page.$eval('.footnote-ref', node => node.getAttribute('href'));
        await page.click('.footnote-ref');
        assert.equal(new URL(page.url()).hash, reference);
        assert.ok(await page.$eval(reference, node => node.getBoundingClientRect().height > 10));
      });
      await check('EPUB: full-width aside preserves complete text and formatting', () => fullWidthContent(page));
      await check('EPUB: full-width aside reflows at enlarged text', () => fullWidthLayout(page, 'epub'));
    }
    await check('Chrome HTML and EPUB previews require no external requests', () => assert.deepEqual(externalRequests, []));
    await page.evaluate(() => window.scrollTo(0, 0));
    await screenshot(page, 'epub-reflow-chrome.png');
    await page.close();
    try {
      await access('/usr/bin/firefox');
      await rm(join(qa, 'firefox-profile'), { recursive: true, force: true });
      await mkdir(join(qa, 'firefox-profile'), { recursive: true });
      const firefox = await puppeteer.launch({ browser: 'firefox', executablePath: '/usr/bin/firefox',
        userDataDir: join(qa, 'firefox-profile'),
        env: { ...process.env, MOZ_DISABLE_CONTENT_SANDBOX: '1' } });
      try {
        const second = await firefox.newPage();
        await second.setViewport({ width: 390, height: 844 });
        for (const chapter of epubChapters) {
          await load(second, `epub/${chapter.href}`);
          await second.evaluate(() => { document.documentElement.style.fontSize = '28px'; });
          await check(`EPUB at enlarged text in Firefox: ${chapter.href} reflows without overflow`, () => noOverflow(second));
          const source = chapter.source;
          if (source) {
            await check(`EPUB in Firefox: ${chapter.href} retains exact code text`, () => exactCode(second, source, 'pre > code'));
            await check(`EPUB in Firefox: ${chapter.href} source images load and fit`, () => images(second, source, 'img'));
          }
          await check(`EPUB in Firefox: ${chapter.href} overflowing code remains reachable`, () => codeOverflow(second, 'pre'));
          if (source?.source === lessonSource.source) {
            await check('EPUB in Firefox: real lesson notes and figures reflow at enlarged text',
              () => realLessonNotes(second, 'epub'));
            await check('EPUB in Firefox: viewport capture preserves mixed-note geometry',
              () => realLessonCapture(second, 'epub-firefox', 'epub'));
          }
        }
        await load(second, `epub/${preview.href}`);
        await second.evaluate(() => { document.documentElement.style.fontSize = '28px'; });
        if (epubFixture) {
          await check('EPUB: Firefox loads selected static diagrams', () => images(second, fixture, 'img'));
          await check('EPUB in Firefox: full-width aside preserves complete text and formatting', () => fullWidthContent(second));
          await check('EPUB in Firefox: full-width aside reflows at enlarged text', () => fullWidthLayout(second, 'epub'));
        }
        await screenshot(second, 'epub-reflow-firefox.png');
        report.secondaryEngine = { browser: await firefox.version(), status: 'previewed' };
      } finally { await firefox.close(); }
    } catch (error) {
      report.secondaryEngine = { status: 'unavailable', message: error.message };
    }
  } finally {
    await browser?.close();
    await new Promise(complete => server.close(complete));
    await writeFile(join(qa, 'browser.json'), JSON.stringify(report, null, 2) + '\n');
  }

  for (const result of report.checks) console.log(`${result.status.toUpperCase()} ${result.name}${result.message ? `: ${result.message}` : ''}`);
  console.log(`Evidence: ${join(qa, 'browser.json')}`);
  console.log(`Second engine: ${report.secondaryEngine?.status ?? 'not attempted'}`);
  if (report.checks.some(result => result.status === 'fail')) process.exitCode = 1;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) await main();
