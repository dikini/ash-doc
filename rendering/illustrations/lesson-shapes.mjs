import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRuntime, ROOT } from './sketch.mjs';
import { figureWidth } from './size.mjs';
import { resolveAppearance } from './settings.mjs';

const root = fileURLToPath(ROOT);
const lessons = ['content/learn/using-more-than-one-input/README.md',
  'content/cases/guaranteeing-logarithmic-retrieval/README.md'];
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const config = JSON.parse(await readFile(new URL('rendering/specimen.json', ROOT)));
const shared = JSON.parse(await readFile(new URL('rendering/styles/diagram-style.json', ROOT)));
const common = execFileSync('git', ['rev-parse', '--path-format=absolute', '--git-common-dir'],
  { cwd: root, encoding: 'utf8' }).trim();
const repository = join(dirname(dirname(common)), 'split-md');
const cache = join(root, '.build/illustration-split');
await mkdir(cache, { recursive: true });
await writeFile(join(cache, 'package.json'), '{"type":"module"}\n');
const sourceHashes = {};
for (const name of ['parse.js', 'layout.js', 'style.js']) {
  const bytes = execFileSync('git', ['-C', repository, 'show',
    `${config.renderers.split}:packages/core/src/${name}`]);
  sourceHashes[name] = hash(bytes);
  await writeFile(join(cache, name), bytes);
}
const { parse } = await import(pathToFileURL(join(cache, 'parse.js')));
const { layout } = await import(pathToFileURL(join(cache, 'layout.js')));
const { mergeStyle } = await import(pathToFileURL(join(cache, 'style.js')));
const runtime = await createRuntime();
const report = [];
try {
  for (const lesson of lessons) {
    const text = await readFile(join(root, lesson), 'utf8');
    const identifiers = [...text.matchAll(/^    id: (fig-[\w-]+)$/gm)].map(match => match[1]);
    for (const id of identifiers) {
      const directory = join(root, dirname(lesson), 'assets', id);
      const state = JSON.parse(await readFile(join(directory, 'illustration.json')));
      assert.equal(state.construction.appearance.font, 'excalifont', 'This adapter outlines Excalifont only.');
      state.construction.appearance = resolveAppearance(state.construction.appearance);
      const parsed = parse(state.construction.source);
      assert.deepEqual(parsed.diagnostics, []);
      const wide = state.construction.labelled;
      const shape = parsed.figure.shape === 'square' ? 'square' : 'circle';
      const style = mergeStyle({ ...shared.kinds.split.style, categorical: shared.categorical,
        geometry: { ...shared.kinds.split.style.geometry, pitch: 120, fontSize: 28,
          treeMargin: wide ? 40 : 20, leafPitch: wide ? 45 : 40, levelGap: wide ? 50 : 30 } });
      let scene;
      if (wide) {
        const panels = parsed.figure.blocks.map(block => layout({ ...parsed.figure, blocks: [block] }, style));
        const offset = panels[0].width + 50;
        scene = { width: offset + panels[1].width, height: Math.max(...panels.map(panel => panel.height)) + 35,
          elements: panels.flatMap((panel, panelIndex) => {
            const shift = panelIndex * offset;
            const elements = panel.elements.map(element => ({ ...element,
              ...(element.cx !== undefined ? { cx: element.cx + shift } : {}),
              ...(element.x !== undefined ? { x: element.x + shift } : {}),
              ...(element.x1 !== undefined ? { x1: element.x1 + shift, x2: element.x2 + shift } : {}),
              ...(element.cy !== undefined ? { cy: element.cy + 25 } : {}),
              ...(element.apex !== undefined ? { apex: element.apex + 25 } : {}),
              ...(element.y1 !== undefined ? { y1: element.y1 + 25, y2: element.y2 + 25 } : {}) }));
            const names = [];
            const walk = node => {
              if (node.type === 'node') { node.children.forEach(walk); names.push(node.bottom); }
            };
            walk(parsed.figure.blocks[panelIndex].root);
            let circleIndex = 0;
            let leafIndex = 0;
            for (const element of [...elements]) {
              if (element.kind === 'circle') {
                const name = names[circleIndex++];
                const left = (panelIndex === 0 && name !== '(k3,v3)') ||
                  (panelIndex === 1 && name === '(k1,v1)');
                elements.push({ kind: 'text', x: element.cx + (left ? -15 : 15),
                  y: element.cy - 8, size: 10, fill: shared.palette.ink.value,
                  content: name.replace(',', ', '), anchor: left ? 'end' : 'start' });
              }
              if (element.kind === 'triangle') elements.push({ kind: 'text', x: element.x,
                y: element.apex + element.height + 15, size: 12, fill: shared.palette.ink.value,
                content: ['a', 'b', 'c', 'd'][leafIndex++], anchor: 'middle' });
            }
            return elements;
          }) };
        scene.elements.push({ kind: 'arrow', x1: panels[0].width + 8, x2: offset - 8,
          y1: 55, y2: 55, stroke: '#59534e', strokeWidth: 1 });
      } else scene = layout(parsed.figure, style);
      const primitive = shape === 'square' ? style.geometry.box : style.geometry.radius * 2;
      const width = figureWidth(scene.width, primitive, state.construction.placement, shape, shared.illustrationSizes);
      const draw = ({ scene, appearance }) => {
        const ns = 'http://www.w3.org/2000/svg';
        const svg = document.createElementNS(ns, 'svg');
        svg.setAttribute('xmlns', ns);
        svg.setAttribute('viewBox', `-4 -4 ${scene.width + 8} ${scene.height + 8}`);
        const renderer = rough.svg(svg);
        let count = 0;
        const element = (tag, attributes) => {
          const node = document.createElementNS(ns, tag);
          for (const [name, value] of Object.entries(attributes)) node.setAttribute(name, value);
          return node;
        };
        const geometry = [...scene.elements.filter(item => item.kind === 'edge'),
          ...scene.elements.filter(item => item.kind !== 'edge')];
        for (const item of geometry) {
          const group = element('g', { 'data-shape': item.kind });
          const options = { seed: appearance.seed + count++ * 97, roughness: appearance.roughness,
            bowing: appearance.bowing, preserveVertices: true, stroke: item.stroke, strokeWidth: item.strokeWidth };
          if (item.kind === 'text') {
            const text = element('text', { x: item.x, y: item.y, 'font-size': item.size, fill: item.fill,
              'text-anchor': item.anchor });
            text.textContent = item.content;
            group.append(text);
          } else if (['solid', 'halves'].includes(item.kind)) {
            group.append(element('rect', { x: item.x, y: item.y, width: item.width, height: item.height,
              fill: item.kind === 'solid' ? item.fill : item.topFill }));
            if (item.kind === 'halves') group.append(element('rect', { x: item.x, y: item.y + item.height / 2,
              width: item.width, height: item.height / 2, fill: item.bottomFill }));
            group.append(renderer.rectangle(item.x, item.y, item.width, item.height, options));
            if (item.kind === 'halves') group.append(renderer.line(item.x, item.y + item.height / 2,
              item.x + item.width, item.y + item.height / 2, { ...options, stroke: '#ffffff', strokeWidth: 1 }));
          } else if (['circle', 'emptyCircle', 'solidCircle'].includes(item.kind)) {
            const { cx, cy, r } = item;
            if (item.kind === 'solidCircle') group.append(element('circle', { cx, cy, r, fill: item.fill }));
            else {
              group.append(element('path', { d: `M${cx-r} ${cy}A${r} ${r} 0 0 1 ${cx+r} ${cy}Z`, fill: item.topFill }));
              group.append(element('path', { d: `M${cx+r} ${cy}A${r} ${r} 0 0 1 ${cx-r} ${cy}Z`, fill: item.bottomFill }));
            }
            group.append(renderer.circle(cx, cy, r * 2, options));
          } else if (item.kind === 'triangle') {
            const vertices = [[item.x, item.apex], [item.x-item.half, item.apex+item.height],
              [item.x+item.half, item.apex+item.height]];
            group.append(element('path', { d: `M${vertices.map(point => point.join(' ')).join('L')}Z`, fill: item.fill }));
            group.append(renderer.polygon(vertices, options));
          } else if (item.kind === 'edge') group.append(renderer.line(item.x1, item.y1, item.x2, item.y2, options));
          else if (['arrow', 'downArrow'].includes(item.kind)) {
            const vertical = item.kind === 'downArrow';
            const start = vertical ? [item.x, item.y1] : [item.x1, item.y1];
            const end = vertical ? [item.x, item.y2] : [item.x2, item.y2];
            group.append(renderer.line(...start, ...end, options));
            const head = item.head ?? 5;
            group.append(renderer.linearPath(vertical ? [[end[0]-head, end[1]-head], end, [end[0]+head, end[1]-head]] :
              [[end[0]-head, end[1]-head], end, [end[0]-head, end[1]+head]], options));
          } else throw new Error(`Unsupported scene element ${item.kind}`);
          svg.append(group);
        }
        return new XMLSerializer().serializeToString(svg);
      };
      const input = { scene, appearance: state.construction.appearance };
      const first = await runtime.page.evaluate(draw, input);
      assert.equal(first, await runtime.page.evaluate(draw, input));
      const svg = execFileSync('python3', ['rendering/illustrations/fold-tree-labels.py'], {
        cwd: root, input: first, encoding: 'utf8', env: { ...process.env, PYTHONPATH: join(root, '.build/illustration-python') } });
      const fits = await runtime.page.evaluate(source => {
        const svg = new DOMParser().parseFromString(source, 'image/svg+xml').documentElement;
        document.body.append(svg);
        const bounds = svg.getBBox();
        const view = svg.viewBox.baseVal;
        const fits = bounds.x >= view.x && bounds.y >= view.y &&
          bounds.x + bounds.width <= view.x + view.width && bounds.y + bounds.height <= view.y + view.height;
        svg.remove();
        return fits;
      }, svg);
      assert(fits, `${id}: outlined labels or rough geometry leave the viewBox.`);
      await mkdir(directory, { recursive: true });
      state.construction.scene = scene;
      state.construction.display = { placement: state.construction.placement, shape, primitiveUnits: primitive,
        primitiveMm: shared.illustrationSizes[state.construction.placement][`${shape}Mm`],
        width: figureWidth(scene.width + 8, primitive, state.construction.placement, shape, shared.illustrationSizes) };
      const declared = new RegExp(`    id: ${id}\\n    width: ([^\\n]+)`).exec(text)?.[1];
      assert.equal(declared, state.construction.display.width,
        `${id}: explicitly update the lesson's physical display width when changing geometry or size tokens.`);
      state.renderer = { command: 'node rendering/illustrations/lesson-shapes.mjs',
        splitCommit: config.renderers.split, splitSourceHashes: sourceHashes,
        roughJS: '4.6.6', bundleSha256: runtime.bundleSha256, lockSha256: runtime.lockSha256,
        font: 'Excalifont-Latin', fontApplied: scene.elements.some(element => element.kind === 'text'),
        fontTools: '4.61.1', Brotli: '1.1.0' };
      state.provenance = { svgSha256: hash(svg) };
      const pendingSvg = join(directory, '.figure.svg.pending');
      await writeFile(pendingSvg, svg);
      execFileSync('python3', ['-c',
        'import pathlib,runpy,sys; runpy.run_path(sys.argv[1])["validate_source_svg"](pathlib.Path(sys.argv[2]).read_bytes(),sys.argv[2])',
        join(root, 'rendering/build.py'), pendingSvg]);
      for (const [name, bytes] of [['figure.svg', svg], ['illustration.json', JSON.stringify(state, null, 2) + '\n']]) {
        await writeFile(join(directory, `.${name}.pending`), bytes);
        await rename(join(directory, `.${name}.pending`), join(directory, name));
      }
      report.push({ id, lesson, width: state.construction.display.width, shape, widthWithoutPadding: width });
    }
  }
  console.log(JSON.stringify(report, null, 2));
} finally { await runtime.browser.close(); }
