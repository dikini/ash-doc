import { execFile } from 'node:child_process';
import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { isAbsolute, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { promisify } from 'node:util';

const execute = promisify(execFile);
const escapeText = (value) => String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
const escapeAttribute = (value) => escapeText(value).replaceAll('"', '&quot;');
const browserArguments = ['--no-sandbox', '--disable-dev-shm-usage', '--font-render-hinting=none'];
const serif = 'DejaVu Serif';
const monospace = 'DejaVu Sans Mono';

async function pinnedFonts(directory) {
  const faces = [
    ['DejaVuSerif.ttf', serif, 'normal', 400], ['DejaVuSerif-Italic.ttf', serif, 'italic', 400],
    ['DejaVuSerif-Bold.ttf', serif, 'normal', 700], ['DejaVuSerif-BoldItalic.ttf', serif, 'italic', 700],
    ['DejaVuSansMono.ttf', monospace, 'normal', 400], ['DejaVuSansMono-Bold.ttf', monospace, 'normal', 700]
  ];
  return (await Promise.all(faces.map(async ([filename, family, style, weight]) => {
    const bytes = await readFile(join(directory, filename));
    return `@font-face{font-family:"${family}";font-style:${style};font-weight:${weight};src:url(data:font/ttf;base64,${bytes.toString('base64')}) format("truetype")}`;
  }))).join('\n');
}

function serialize(node) {
  if (node.type === 'text') return escapeText(node.value);
  const attributes = Object.entries(node.properties ?? {}).map(([key, value]) => {
    const name = key === 'className' ? 'class' : key;
    return ` ${name}="${escapeAttribute(Array.isArray(value) ? value.join(' ') : value)}"`;
  }).join('');
  return `<${node.tagName}${attributes}>${(node.children ?? []).map(serialize).join('')}</${node.tagName}>`;
}

function validate(job) {
  if (!isAbsolute(job.output ?? '')) throw new Error('Diagram output must be an absolute directory.');
  const identifiers = new Set();
  for (const diagram of job.diagrams ?? []) {
    if (!/^[a-z][a-z0-9-]*$/.test(diagram.id) || identifiers.has(diagram.id)) {
      throw new Error(`Invalid or duplicate diagram identifier: ${diagram.id}`);
    }
    identifiers.add(diagram.id);
    if (!['mermaid', 'ebnf', 'sequent'].includes(diagram.kind)) throw new Error(`Unknown diagram kind: ${diagram.kind}`);
    if (typeof diagram.source !== 'string' || !diagram.source.trim()) throw new Error(`${diagram.id}: empty diagram source`);
    if (!diagram.description || !diagram.path || !Number.isInteger(diagram.line) || diagram.line < 1) {
      throw new Error(`${diagram.id}: description, source path, and positive source line are required`);
    }
  }
  const required = ['puppeteer', 'browser', 'fonts', 'pdftocairo'];
  for (const diagram of job.diagrams ?? []) required.push({ mermaid: 'mermaid', ebnf: 'railroad', sequent: 'sequent' }[diagram.kind]);
  for (const key of new Set(required)) {
    if (!isAbsolute(job[key] ?? '')) throw new Error(`The pinned ${key} tool must have an absolute path.`);
  }
}

function locatedError(diagram, error) {
  const message = error.stderr?.trim() || error.message || String(error);
  const position = /(?:EBNF error at|Line)\s+(\d+)(?::|, column\s+)(\d+)/i.exec(message);
  const mermaidLine = /Parse error on line (\d+)/.exec(message);
  const relativeLine = Number(position?.[1] ?? mermaidLine?.[1] ?? 1);
  const column = position?.[2] ?? '1';
  return new Error(`${diagram.path}:${diagram.line + relativeLine - 1}:${column}: ${diagram.kind}: ${message}`, { cause: error });
}

async function railroadSvg(diagram, job, page) {
  const { default: rehypeRailroad } = await import(pathToFileURL(job.railroad));
  const tree = { type: 'root', children: [{ type: 'element', tagName: 'pre', properties: {}, children: [{
    type: 'element', tagName: 'code', properties: { className: ['language-ebnf'] },
    children: [{ type: 'text', value: diagram.source }]
  }] }] };
  const messages = [];
  const width = diagram.width ?? 320;
  if (!Number.isInteger(width) || width < 100 || width > 1200) throw new Error('Railroad layout width must be between 100 and 1200 pixels.');
  await rehypeRailroad({ width })(tree, { message(reason) { messages.push(reason); } });
  if (messages.length) throw new Error(messages.join('\n'));
  if (!tree.children.length) throw new Error('No EBNF productions were rendered.');
  await page.setContent(`<html><head><style>${job.fontCss}svg text{font-family:"${monospace}"!important}</style></head><body>${tree.children.map(serialize).join('')}</body></html>`);
  const productions = await page.evaluate(async () => {
    await document.fonts.ready;
    const context = document.createElement('canvas').getContext('2d');
    context.font = '14px "DejaVu Sans Mono"';
    return [...document.querySelectorAll('figure')].map((figure) => {
      const svg = figure.querySelector('svg');
      const bounds = svg.getBBox();
      const name = figure.querySelector('figcaption')?.textContent ?? '';
      return { name, labelWidth: context.measureText(name).width,
        content: svg.innerHTML, x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height };
    });
  });
  let height = 8;
  let viewportWidth = 0;
  const groups = productions.map((production) => {
    const top = height;
    viewportWidth = Math.max(viewportWidth, production.width + 16, production.labelWidth + 16);
    height += production.height + 40;
    return `<g transform="translate(8 ${top})"><text x="0" y="14" font-family="DejaVu Sans Mono" font-size="14">${escapeText(production.name)}</text>`
      + `<g transform="translate(${-production.x} ${24 - production.y})">${production.content}</g></g>`;
  });
  const paint = '.librrd-rail,.librrd-station rect,path{fill:none;stroke:#111;stroke-width:1px}text{fill:#111}';
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${Math.ceil(viewportWidth)}" height="${Math.ceil(height)}" viewBox="0 0 ${Math.ceil(viewportWidth)} ${Math.ceil(height)}"><style>${paint}</style>${groups.join('')}</svg>`;
}

async function sequentSvg(diagram, job, page) {
  const { render, styles } = await import(pathToFileURL(job.sequent));
  const rendered = render(diagram.source);
  if (rendered.diagnostics.length) {
    throw new Error(rendered.diagnostics.map(({ line, column, message }) => `Line ${line}, column ${column}: ${message}`).join('\n'));
  }
  const css = `body{margin:0;color:#111;font:17px/1.3 "DejaVu Serif",serif}#capture{padding:16px;width:max-content}`
    + `${styles}.sequent-family-grid{grid-template-columns:1fr}.sequent-proof-container{overflow:visible}`;
  await page.setContent(`<!doctype html><html><head><meta charset="utf-8"><style>${job.fontCss}${css}</style></head><body><main id="capture">${rendered.html}</main></body></html>`);
  return page.evaluate(async () => {
    await document.fonts.ready;
    const root = document.querySelector('#capture');
    const outer = root.getBoundingClientRect();
    const context = document.createElement('canvas').getContext('2d');
    const escape = (value) => String(value).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
    const texts = [...root.querySelectorAll('.sequent-formula,.sequent-rule-label,.sequent-family > h3')].map((node) => {
      const css = getComputedStyle(node);
      const range = document.createRange();
      range.selectNodeContents(node);
      const rect = range.getBoundingClientRect();
      context.font = `${css.fontStyle} ${css.fontWeight} ${css.fontSize} ${css.fontFamily}`;
      const metrics = context.measureText(node.textContent);
      const baseline = rect.top - outer.top + metrics.fontBoundingBoxAscent;
      return `<text x="${rect.left - outer.left}" y="${baseline}" fill="${escape(css.color)}" font-family="${escape(css.fontFamily)}" font-size="${escape(css.fontSize)}" font-style="${escape(css.fontStyle)}" font-weight="${escape(css.fontWeight)}" xml:space="preserve">${escape(node.textContent)}</text>`;
    });
    const bars = [...root.querySelectorAll('.sequent-bar')].map((node) => {
      const css = getComputedStyle(node);
      const rect = node.getBoundingClientRect();
      const thickness = Number.parseFloat(css.borderTopWidth);
      const x = rect.left - outer.left;
      const y = rect.top - outer.top + thickness / 2;
      return `<line x1="${x}" y1="${y}" x2="${x + rect.width}" y2="${y}" stroke="${escape(css.borderTopColor)}" stroke-width="${thickness}"/>`;
    });
    if (!texts.length || !bars.length) throw new Error('No sequent text and inference bars were rendered.');
    return `<svg xmlns="http://www.w3.org/2000/svg" width="${outer.width}" height="${outer.height}" viewBox="0 0 ${outer.width} ${outer.height}">${texts.join('')}${bars.join('')}</svg>`;
  });
}

async function mermaidSvg(diagram, job, temporary) {
  const decoded = diagram.source.replace(/\\(["'\\])/g, '$1')
    .replace(/\\([0-9a-f]{1,6})\s?|\\([^\r\n])/gi, (_, hex, character) => character ?? String.fromCodePoint(Number.parseInt(hex, 16)));
  if (/\bimg\s*:|<\s*img\b/i.test(decoded)) throw new Error('External diagram resources and Mermaid image nodes are not supported.');
  if (/@import\b/i.test(decoded)) throw new Error('External CSS resources are not supported in diagram notation.');
  for (const match of decoded.matchAll(/url\(\s*(["']?)(.*?)\1\s*\)/gi)) {
    if (!match[2].trim().startsWith('#')) throw new Error('External CSS resources are not supported in diagram notation.');
  }
  const input = join(temporary, `${diagram.id}.mmd`);
  const output = join(temporary, `${diagram.id}.svg`);
  const configuration = join(temporary, `${diagram.id}-mermaid.json`);
  const puppeteer = join(temporary, 'puppeteer.json');
  await writeFile(input, diagram.source);
  await writeFile(configuration, JSON.stringify({
    securityLevel: 'strict', theme: 'neutral', look: 'classic', htmlLabels: false,
    deterministicIds: true, deterministicIDSeed: diagram.id,
    fontFamily: serif, flowchart: { htmlLabels: false }
  }));
  await writeFile(puppeteer, JSON.stringify({ executablePath: job.browser, args: browserArguments }));
  await execute(job.mermaid, ['-i', input, '-o', output, '-c', configuration, '-p', puppeteer, '-b', 'transparent', '--no-font-embed'], {
    timeout: 60000, maxBuffer: 4 * 1024 * 1024, env: { ...process.env, FONTCONFIG_FILE: job.fontconfig }
  });
  return readFile(output, 'utf8');
}

async function accessibleSvg(source, diagram, page, displaySize) {
  return page.evaluate(({ source, diagram, displaySize }) => {
    const xml = new DOMParser().parseFromString(source, 'image/svg+xml');
    const svg = xml.documentElement;
    if (svg.localName !== 'svg' || xml.querySelector('parsererror')) throw new Error('Renderer returned invalid SVG.');
    if (svg.querySelector('foreignObject,script')) throw new Error('Diagram SVG requires HTML or a script.');
    const validateCss = (css) => {
      const decoded = css.replace(/\\([0-9a-f]{1,6})\s?|\\([^\r\n])/gi,
        (_, hex, character) => character ?? String.fromCodePoint(Number.parseInt(hex, 16)));
      if (/@import\b/i.test(decoded)) throw new Error('SVG contains an external CSS import.');
      for (const match of decoded.matchAll(/url\(\s*(["']?)(.*?)\1\s*\)/gi)) {
        if (!match[2].trim().startsWith('#')) throw new Error('SVG contains an external CSS resource.');
      }
    };
    for (const node of [svg, ...svg.querySelectorAll('*')]) {
      for (const attribute of node.attributes) {
        if (attribute.localName === 'href' && !attribute.value.trim().startsWith('#')) {
          throw new Error('SVG contains an external href resource.');
        }
        if (attribute.localName === 'style' || /url\(/i.test(attribute.value)) validateCss(attribute.value);
      }
      if (node.localName === 'style') validateCss(node.textContent);
    }
    if (!svg.hasAttribute('viewBox')) throw new Error('Diagram SVG has no intrinsic viewBox.');
    const dimensions = svg.getAttribute('viewBox').trim().split(/[ ,]+/).map(Number);
    if (dimensions.length !== 4 || dimensions.some((value) => !Number.isFinite(value)) || dimensions[2] <= 0 || dimensions[3] <= 0) {
      throw new Error('Diagram SVG has invalid dimensions.');
    }
    svg.setAttribute('width', String(displaySize?.width ?? dimensions[2]));
    svg.setAttribute('height', String(displaySize?.height ?? dimensions[3]));
    svg.setAttribute('role', 'img');
    svg.setAttribute('aria-labelledby', `${diagram.id}-title ${diagram.id}-description`);
    for (const node of svg.querySelectorAll(':scope > title,:scope > desc')) node.remove();
    const title = xml.createElementNS(svg.namespaceURI, 'title');
    title.id = `${diagram.id}-title`;
    title.textContent = diagram.id.replaceAll('-', ' ');
    const description = xml.createElementNS(svg.namespaceURI, 'desc');
    description.id = `${diagram.id}-description`;
    description.textContent = `${diagram.description}\n\nSource (${diagram.kind}):\n${diagram.source}`;
    svg.prepend(title, description);
    return new XMLSerializer().serializeToString(svg);
  }, { source, diagram, displaySize });
}

async function outlineSvg(source, diagram, job, page, temporary) {
  const family = diagram.kind === 'ebnf' ? monospace : serif;
  await page.setContent(`<!doctype html><html><head><meta charset="utf-8"><style>${job.fontCss}body{margin:0}svg{display:block;max-width:none!important}svg text,svg tspan{font-family:"${family}"!important}</style></head><body>${source}</body></html>`);
  const displaySize = await page.evaluate(async () => {
    await Promise.all([...document.fonts].map((font) => font.load()));
    await document.fonts.ready;
    const svg = document.querySelector('svg');
    const dimensions = svg.getAttribute('viewBox').trim().split(/[ ,]+/).map(Number);
    svg.style.width = `${dimensions[2]}px`;
    svg.style.height = `${dimensions[3]}px`;
    return { width: dimensions[2], height: dimensions[3] };
  });
  await page.emulateMediaType('screen');
  const pdf = join(temporary, `${diagram.id}.pdf`);
  const svg = join(temporary, `${diagram.id}-outlined.svg`);
  await page.pdf({ path: pdf, width: `${displaySize.width}px`, height: `${displaySize.height}px`,
    printBackground: true, margin: { top: 0, right: 0, bottom: 0, left: 0 } });
  await execute(job.pdftocairo, ['-svg', '-f', '1', '-l', '1', pdf, svg], { timeout: 60000, maxBuffer: 4 * 1024 * 1024 });
  return accessibleSvg(await readFile(svg, 'utf8'), diagram, page, displaySize);
}

export async function renderDiagrams(job) {
  validate(job);
  await mkdir(job.output, { recursive: true });
  const temporary = await mkdtemp(join(job.output, '.diagram-work-'));
  let browser;
  try {
    const { default: puppeteer } = await import(pathToFileURL(job.puppeteer));
    job = { ...job, fontCss: await pinnedFonts(job.fonts), fontconfig: join(temporary, 'fonts.conf') };
    await writeFile(job.fontconfig, `<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><dir>${escapeText(job.fonts)}</dir><cachedir>${escapeText(join(temporary, 'font-cache'))}</cachedir><alias><family>serif</family><prefer><family>${serif}</family></prefer></alias><alias><family>monospace</family><prefer><family>${monospace}</family></prefer></alias></fontconfig>`);
    browser = await puppeteer.launch({ executablePath: job.browser, headless: true, args: browserArguments,
      env: { ...process.env, FONTCONFIG_FILE: job.fontconfig } });
    const page = await browser.newPage();
    await page.setViewport({ width: 1200, height: 900, deviceScaleFactor: 1 });
    for (const diagram of job.diagrams) {
      const destination = join(job.output, `${diagram.id}.svg`);
      await rm(destination, { force: true });
      try {
        const source = diagram.kind === 'ebnf' ? await railroadSvg(diagram, job, page)
          : diagram.kind === 'sequent' ? await sequentSvg(diagram, job, page)
            : await mermaidSvg(diagram, job, temporary);
        const normalized = await accessibleSvg(source, diagram, page);
        await writeFile(destination, `${await outlineSvg(normalized, diagram, job, page, temporary)}\n`);
      } catch (error) {
        throw locatedError(diagram, error);
      }
    }
  } finally {
    if (browser) await browser.close();
    await rm(temporary, { recursive: true, force: true });
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    if (!process.argv[2]) throw new Error('usage: node rendering/diagrams.mjs JOB.json');
    await renderDiagrams(JSON.parse(await readFile(process.argv[2], 'utf8')));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
