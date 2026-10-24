"""Select outlined lettering for the two pilot figures, during authoring only."""
import hashlib
import json
from pathlib import Path
import re
import sys
from xml.etree import ElementTree

import brotli
from fontTools import __version__
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

DIRECTORY = Path(__file__).resolve().parent
ROOT = DIRECTORY.parents[1]
FONT_PATH = DIRECTORY / 'fonts/Excalifont-Latin.woff2'
assert __version__ == '4.61.1'
assert brotli.__version__ == '1.1.0'
assert hashlib.sha256(FONT_PATH.read_bytes()).hexdigest() == (
    'e4423b318e11432aff2e6e865e300b7ca270f92321a3f56632268fede01c1b48')
regular = TTFont(ROOT / 'rendering/fonts/IBMPlexMono-Regular.ttf')
handwritten = TTFont(FONT_PATH)
namespace = 'http://www.w3.org/2000/svg'
ElementTree.register_namespace('', namespace)
document = ElementTree.fromstring(sys.stdin.read())
for group in document.iter(f'{{{namespace}}}g'):
    text = group.get('aria-label')
    if text is None:
        continue
    match = re.fullmatch(r'translate\(([-\d.]+),([-\d.]+)\) scale\(([-\d.]+),([-\d.]+)\)',
                         group.get('transform', ''))
    if not match:
        raise ValueError('Unsupported pilot lettering placement')
    horizontal, baseline, scale, inverted = map(float, match.groups())
    if inverted != -scale:
        raise ValueError('Unsupported pilot lettering scale')
    size = scale * regular['head'].unitsPerEm
    old_names = [regular.getBestCmap()[ord(character)] for character in text]
    center = horizontal + sum(regular['hmtx'][name][0] for name in old_names) * scale / 2
    names = [handwritten.getBestCmap()[ord(character)] for character in text]
    units = handwritten['head'].unitsPerEm
    width = sum(handwritten['hmtx'][name][0] for name in names) * size / units
    group.set('transform', f'translate({center-width/2:.4f},{baseline:g}) '
              f'scale({size/units:.8f},{-size/units:.8f})')
    for child in list(group):
        group.remove(child)
    position = 0
    glyphs = handwritten.getGlyphSet()
    for name in names:
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        if pen.getCommands():
            ElementTree.SubElement(group, f'{{{namespace}}}path', {
                'transform': f'translate({position},0)', 'd': pen.getCommands()})
        position += handwritten['hmtx'][name][0]
print(json.dumps(ElementTree.tostring(document, encoding='unicode')))
