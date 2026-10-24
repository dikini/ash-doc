"""Outline supported authoring SVG labels with the pinned handwritten font."""
import hashlib
from pathlib import Path
import sys
from xml.etree import ElementTree

from fontTools import __version__
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

assert __version__ == '4.61.1'
font_path = Path(__file__).parent / 'fonts/Excalifont-Latin.woff2'
assert hashlib.sha256(font_path.read_bytes()).hexdigest() == (
    'e4423b318e11432aff2e6e865e300b7ca270f92321a3f56632268fede01c1b48')
font = TTFont(font_path)
glyphs = font.getGlyphSet()
namespace = 'http://www.w3.org/2000/svg'
ElementTree.register_namespace('', namespace)
document = ElementTree.fromstring(sys.stdin.read())
for parent in list(document.iter()):
    for node in list(parent):
        if node.tag != f'{{{namespace}}}text':
            continue
        text = node.text
        names = [font.getBestCmap()[ord(character)] for character in text]
        scale = float(node.get('font-size')) / font['head'].unitsPerEm
        width = sum(font['hmtx'][name][0] for name in names) * scale
        anchor = node.get('text-anchor', 'middle')
        horizontal = float(node.get('x')) - (width / 2 if anchor == 'middle' else width if anchor == 'end' else 0)
        group = ElementTree.Element(f'{{{namespace}}}g', {
            'aria-label': text, 'fill': node.get('fill', '#222222'),
            'transform': f'translate({horizontal:.5f},{node.get("y")}) scale({scale:.8f},{-scale:.8f})'})
        position = 0
        for name in names:
            pen = SVGPathPen(glyphs)
            glyphs[name].draw(pen)
            if pen.getCommands():
                ElementTree.SubElement(group, f'{{{namespace}}}path', {
                    'transform': f'translate({position},0)', 'd': pen.getCommands()})
            position += font['hmtx'][name][0]
        parent.insert(list(parent).index(node), group)
        parent.remove(node)
print(ElementTree.tostring(document, encoding='unicode'))
