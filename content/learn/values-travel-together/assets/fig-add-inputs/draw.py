"""Rebuild the literal add-signature figure during authoring only."""
import json
from html import escape
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen

DIRECTORY = Path(__file__).resolve().parent
REPOSITORY = DIRECTORY.parents[4]
construction = json.loads((DIRECTORY / 'illustration.json').read_text())['construction']
style = json.loads((REPOSITORY / construction['style']).read_text())['kinds']['split']['style']
font = TTFont(REPOSITORY / 'rendering/fonts/IBMPlexMono-Regular.ttf')
glyphs = font.getGlyphSet()
characters = font.getBestCmap()
units = font['head'].unitsPerEm


def label(text, center, baseline, size, color='#222222'):
    names = [characters[ord(character)] for character in text]
    width = sum(font['hmtx'][name][0] for name in names) * size / units
    paths = []
    position = 0
    for name in names:
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        commands = pen.getCommands()
        if commands:
            paths.append(f'<path transform="translate({position},0)" d="{commands}"/>')
        position += font['hmtx'][name][0]
    return (f'<g aria-label="{escape(text)}" fill="{color}" '
            f'transform="translate({center-width/2:.4f},{baseline}) '
            f'scale({size/units:.8f},-{size/units:.8f})">' + ''.join(paths) + '</g>')


width, height = construction['canvas']
size = construction['slot_size']
strokes = style['strokes']
integer = style['categories']['int']
body = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',
        '<title id="title">The integer positions in the add signature</title>',
        '<desc id="desc">Three separate blue squares labelled Int, ordered as first input, '
        'second input, and result. Arrows between adjacent squares follow the type signature. '
        'They do not show integers converting into other integers.</desc>']
for (horizontal, vertical), name in zip(construction['origins'], construction['labels']):
    body += [f'<rect x="{horizontal}" y="{vertical}" width="{size}" height="{size}" '
             f'fill="{integer["fill"]}" stroke="{strokes["node"]}" stroke-width="{strokes["nodeWidth"]}"/>',
             label('Int', horizontal+size/2, vertical-14, construction['label_size'], integer['ink']),
             label(name, horizontal+size/2, vertical+size+34, construction['label_size'])]
for origin, following in zip(construction['origins'], construction['origins'][1:]):
    start = origin[0]+size+16
    end = following[0]-16
    middle = origin[1]+size/2
    head = strokes['arrowHead']
    body.append(f'<path d="M{start} {middle}H{end} M{end-head} {middle-head}'
                f'L{end} {middle}L{end-head} {middle+head}" fill="none" '
                f'stroke="{strokes["arrow"]}" stroke-width="{strokes["arrowWidth"]}" '
                'stroke-linecap="round" stroke-linejoin="round"/>')
body.append('</svg>')
temporary = DIRECTORY / '.figure.svg.tmp'
temporary.write_text('\n'.join(body))
temporary.replace(DIRECTORY / 'figure.svg')
print(DIRECTORY / 'figure.svg')
