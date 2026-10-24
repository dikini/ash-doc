"""Construct a transparent typeset fold illustration from saved geometry."""
import argparse
import hashlib
from html import escape
import json
from pathlib import Path

from fontTools import __version__
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

DIRECTORY = Path(__file__).resolve().parent
ROOT = DIRECTORY.parents[1]
assert __version__ == '4.61.1'
state = json.loads((DIRECTORY / 'fold-trial.json').read_text())
construction = state['construction']
style = json.loads((ROOT / construction['style']).read_text())
manifest = json.loads((ROOT / 'rendering/toolchain/manifest.json').read_text())
ink = style['palette']['ink']['value']
fonts = {}
font_hashes = {}
for face, relative in construction['fonts'].items():
    path = ROOT / relative
    font_hashes[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
    assert font_hashes[relative] == manifest['fonts'][path.name]
    fonts[face] = TTFont(path)


def label(parts, center, baseline, size):
    width = 0
    glyph_parts = []
    for text, face in parts:
        font = fonts[face]
        scale = size / font['head'].unitsPerEm
        names = [font.getBestCmap()[ord(character)] for character in text]
        glyph_parts.append((names, font, scale, width))
        width += sum(font['hmtx'][name][0] for name in names) * scale
    body = []
    for names, font, scale, offset in glyph_parts:
        glyphs = font.getGlyphSet()
        position = 0
        paths = []
        for name in names:
            pen = SVGPathPen(glyphs)
            glyphs[name].draw(pen)
            if pen.getCommands():
                paths.append(f'<path transform="translate({position:g},0)" d="{pen.getCommands()}"/>')
            position += font['hmtx'][name][0]
        body.append(f'<g transform="translate({offset:.4f},0) scale({scale:.8f},-{scale:.8f})">'
                    + ''.join(paths) + '</g>')
    text = ''.join(text for text, _ in parts)
    return (f'<g aria-label="{escape(text)}" transform="translate({center-width/2:.4f},{baseline:g})">'
            + ''.join(body) + '</g>')


def tree(name, offset, constructor, terminal, face):
    body = [f'<g data-tree="{name}" transform="translate({offset},0)">']
    root_horizontal, root_vertical = construction['root']
    horizontal_step, vertical_step = construction['step']
    size = construction['label_size']
    branch_horizontal, branch_vertical = construction['numbered_branch_start'][name]
    for depth, value in enumerate(construction['values']):
        horizontal = root_horizontal + depth * horizontal_step
        vertical = root_vertical + depth * vertical_step
        body.append(f'<path d="M{horizontal+branch_horizontal} {vertical+branch_vertical}L{horizontal-16} {vertical+23} '
                    f'M{horizontal+8} {vertical+10}L{horizontal+horizontal_step-10} {vertical+vertical_step-6}" '
                    f'fill="none" stroke="{ink}" stroke-width="{construction["stroke_width"]}"/>')
        body.append(label([(constructor, face)], horizontal, vertical+7, size))
        body.append(label([(str(value), 'regular')], horizontal-24, vertical+32, size))
    depth = len(construction['values'])
    body.append(label([(terminal, face)], root_horizontal+depth*horizontal_step,
                      root_vertical+depth*vertical_step+7, size))
    body.append('</g>')
    return '\n'.join(body)


width, height = construction['canvas']
svg = '\n'.join([
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
    f'viewBox="0 0 {width} {height}" fill="{ink}" role="img" aria-labelledby="title desc">',
    '<title id="title">Replacing list constructors with f and the empty list with z</title>',
    '<desc id="desc">Two matched diagonal trees have numbered leaves 1 through 5. '
    'The left tree has colon constructors and ends in empty brackets. The right tree has '
    'italic f at each constructor position and italic z at the end. An arrow above is '
    'labelled foldr f z. There is no background or enclosing frame.</desc>',
    label([('foldr ', 'regular'), ('f', 'italic'), (' ', 'regular'), ('z', 'italic')], 196, 29, 24),
    f'<path d="M101 44H292" fill="none" stroke="{ink}" stroke-width="0.8"/>',
    f'<path d="M292 44L285 41L287 44L285 47Z" fill="{ink}"/>',
    tree('list', 0, ':', '[]', 'regular'),
    tree('application', construction['tree_offset'], 'f', 'z', 'italic'),
    '</svg>'
])
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, default=ROOT / '.build/fold-trial')
output = parser.parse_args().output
asset = output / 'assets/fig-foldr-structure'
asset.mkdir(parents=True, exist_ok=True)
(asset / 'figure.svg').write_text(svg)
brief = (DIRECTORY / 'fold-trial.md').read_text()
(output / 'README.md').write_text(brief)
state['provenance'] = {'brief_sha256': hashlib.sha256(brief.encode()).hexdigest(),
                       'font_sha256': font_hashes,
                       'svg_sha256': hashlib.sha256(svg.encode()).hexdigest(),
                       'reference': 'User-supplied visual style; original vector geometry and bundled font outlines.'}
(asset / 'illustration.json').write_text(json.dumps(state, indent=2) + '\n')
print(asset / 'figure.svg')
