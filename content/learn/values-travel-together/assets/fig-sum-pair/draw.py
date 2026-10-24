"""Construct the crisp pair-slot base during explicit illustration authoring."""
import json
import argparse
import re
from pathlib import Path
from html import escape
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[4]
state = json.loads((ROOT / 'illustration.json').read_text())['construction']
style = json.loads((REPO / state['style']).read_text())['kinds']['split']['style']
font = TTFont(REPO / 'rendering/fonts/IBMPlexMono-Regular.ttf')
glyphs = font.getGlyphSet()
cmap = font.getBestCmap()
units = font['head'].unitsPerEm

def text(label, x, y, size=16, color='#222222', anchor='middle'):
    names = [cmap[ord(c)] for c in label]
    width = sum(font['hmtx'][n][0] for n in names) * size / units
    start = x - width / 2 if anchor == 'middle' else x
    paths = []
    pos = 0
    for name in names:
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        d = pen.getCommands()
        if d:
            paths.append(f'<path transform="translate({pos},0)" d="{d}"/>')
        pos += font['hmtx'][name][0]
    return f'<g aria-label="{escape(label)}" fill="{color}" transform="translate({start:.4f},{y}) scale({size/units:.8f},-{size/units:.8f})">' + ''.join(paths) + '</g>'

s = state['slot_size']
x, y = state['input_origin']
rx, ry = state['result_origin']
blue = style['categories']['int']['fill']
stroke = style['strokes']
w, h = state['canvas']
title = 'sum_pair: one pair input, one integer result'
desc = ('Two adjoining blue squares share one rectangular outer contour. '
        'An internal seam distinguishes the two Int components of one tuple input. '
        'A right-pointing arrow leads to a separate square of the same blue for the Int result. '
        'Color denotes type, not value identity. This is not a storage diagram.')
body = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="title desc">',
        f'<title id="title">{escape(title)}</title><desc id="desc">{escape(desc)}</desc>',
        f'<g fill="{blue}" stroke="{stroke["node"]}" stroke-width="{stroke["nodeWidth"]}">',
        f'<rect x="{x}" y="{y}" width="{2*s}" height="{s}"/>',
        f'<path d="M{x+s} {y}v{s}" fill="none"/>',
        f'<rect x="{rx}" y="{ry}" width="{s}" height="{s}"/>', '</g>',
        text('(Int, Int)', x+s, y-14, state['label_size'], style['categories']['int']['ink']),
        text('Int', rx+s/2, ry-14, state['label_size'], style['categories']['int']['ink'])]
a, b, cy = x+2*s+22, rx-22, y+s/2
head = stroke['arrowHead']
body += [f'<path d="M{a} {cy}H{b} M{b-head} {cy-head}L{b} {cy}L{b-head} {cy+head}" fill="none" stroke="{stroke["arrow"]}" stroke-width="{stroke["arrowWidth"]}" stroke-linecap="round" stroke-linejoin="round"/>',
         text('pair input', x+s, y+s+34, state['label_size']),
         text('result', rx+s/2, ry+s+34, state['label_size']), '</svg>']
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, default=ROOT / 'base.svg')
output = parser.parse_args().output
temporary = output.with_name('.' + output.name + '.tmp')
temporary.write_text('\n'.join(body))
temporary.replace(output)
print(output)
