#!/usr/bin/env python3
"""Check the visual order of the three WIP captions in both lesson PDFs."""

import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / '.build/lessons/learn/using-more-than-one-input'
for suffix in ('', '-a4'):
    path = PROJECT / 'output' / (
        'ash-doc-learn-using-more-than-one-input' + suffix + '.pdf')
    xml = subprocess.check_output(['pdftotext', '-bbox-layout', str(path), '-'])
    document = ET.fromstring(xml)
    captions = []
    captions_text = {}
    for page_number, page in enumerate(document.findall('.//{*}page'), 1):
        for line in page.findall('.//{*}line'):
            words = [node.text or '' for node in line.findall('{*}word')]
            assert words != ['Curried', 'function'], (path.name, 'Unnumbered label remains')
            if len(words) > 1 and words[0] == 'Figure' and re.fullmatch('[123]:', words[1]):
                captions.append((page_number, float(line.get('yMin')), int(words[1][0])))
                captions_text[int(words[1][0])] = ' '.join(words[2:])
    assert len(captions) == 3, (path.name, captions)
    visual_order = sorted(captions)
    assert [entry[2] for entry in visual_order] == [1, 2, 3], (path.name, visual_order)
    assert len({entry[0] for entry in captions}) == 1, (path.name, captions)
    assert captions_text == {
        1: 'Curried function', 2: 'Function application', 3: 'Partial application',
    }, (path.name, captions_text)
    print(f'PASS {path.name}: correct captions in order 1, 2, 3 on page {captions[0][0]}.')
