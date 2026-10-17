#!/usr/bin/env python3
"""Check the common source scale used by the three lesson figures."""

import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ASSETS = ROOT / 'content/learn/using-more-than-one-input/assets'
SOURCES = ('currying-types-source.svg', 'currying-type-value-source.svg',
           'add-20-application-source.svg')
NS = '{http://www.w3.org/2000/svg}'

for name in SOURCES:
    svg = ET.fromstring((ASSETS / name).read_text())
    assert float(svg.get('viewBox').split()[2]) == 480, (name, 'viewport width')
    boxes = [node for node in svg.iter(NS + 'rect') if node.get('stroke')]
    assert boxes, name
    assert all(node.get('width') == node.get('height') == '64' for node in boxes), name

    def check_labels(node, size=None, family=None):
        size = node.get('font-size', size)
        family = node.get('font-family', family)
        if node.tag == NS + 'text':
            assert size == '30', (name, node.text, size)
            assert family == 'DejaVu Sans Mono, monospace', (name, family)
        for child in node:
            check_labels(child, size, family)

    check_labels(svg)
    print(f'PASS {name}: 480-unit width, 64-unit squares, 30-unit labels.')
