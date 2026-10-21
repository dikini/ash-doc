#!/usr/bin/env python3
"""Package the Lesson 3 experiment without changing shared rendering tools."""

import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
PROJECT = ROOT / '.build/lessons/learn/using-more-than-one-input'
DELIVERY = PROJECT / 'delivery'
DELIVERY.mkdir(exist_ok=True)
quarto = ROOT / '.build/toolchain/quarto-1.10.19/bin/quarto'
html = DELIVERY / 'lesson-3.html'
subprocess.run([
    str(quarto), 'pandoc', 'learn-using-more-than-one-input.md',
    '--standalone', '--embed-resources', '--section-divs',
    '--metadata', 'lang=en', '--metadata',
    'pagetitle=Using more than one input',
    '--css', str(HERE / 'preview.css'), '--output', str(html),
], cwd=PROJECT, check=True)
for source, name in [
    ('ash-doc-learn-using-more-than-one-input.epub', 'lesson-3.epub'),
    ('ash-doc-learn-using-more-than-one-input.pdf', 'lesson-3-book.pdf'),
    ('ash-doc-learn-using-more-than-one-input-a4.pdf', 'lesson-3-a4.pdf'),
]:
    shutil.copyfile(PROJECT / 'output' / source, DELIVERY / name)
print(DELIVERY)
