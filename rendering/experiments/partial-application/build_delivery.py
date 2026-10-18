#!/usr/bin/env python3
"""Package the Lesson 3 experiment without changing shared rendering tools."""

import argparse
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
PROJECT = ROOT / '.build/lessons/learn/using-more-than-one-input'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--refresh-figure', action='store_true')
args = parser.parse_args()
if args.refresh_figure:
    assets = ROOT / 'content/learn/using-more-than-one-input/assets'
    for source, output in [
        ('currying-types-source.svg', 'fig-add-types.svg'),
        ('currying-type-value-source.svg', 'fig-add-type-value.svg'),
        ('add-20-application-source.svg', 'fig-add-20-application.svg'),
    ]:
        subprocess.run([
            'inkscape', str(assets / source),
            '--export-text-to-path', '--export-plain-svg', '--export-type=svg',
            '--export-filename=' + str(assets / output),
        ], check=True)
    raise SystemExit(0)
DELIVERY = PROJECT / 'delivery'
DELIVERY.mkdir(exist_ok=True)
quarto = ROOT / '.build/toolchain/quarto-1.10.19/bin/quarto'
html = DELIVERY / 'lesson-3.html'
subprocess.run([
    str(quarto), 'pandoc', 'learn-using-more-than-one-input.md',
    '--standalone', '--embed-resources', '--section-divs',
    '--metadata', 'lang=en', '--metadata',
    'pagetitle=How can a function use more than one input?',
    '--css', str(HERE / 'preview.css'), '--output', str(html),
], cwd=PROJECT, check=True)
for source, name in [
    ('ash-doc-learn-using-more-than-one-input.epub', 'lesson-3.epub'),
    ('ash-doc-learn-using-more-than-one-input.pdf', 'lesson-3-book.pdf'),
    ('ash-doc-learn-using-more-than-one-input-a4.pdf', 'lesson-3-a4.pdf'),
]:
    shutil.copyfile(PROJECT / 'output' / source, DELIVERY / name)
print(DELIVERY)
