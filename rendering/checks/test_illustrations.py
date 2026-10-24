"""Check authored-artwork resolution without invoking an agent or drawing code."""
import copy
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('illustration_build', ROOT / 'rendering/build.py')
build = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(build)
SVG = b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64"/></svg>'


class IllustrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.patch = patch.object(build, 'ROOT', self.root)
        self.patch.start()
        self.addCleanup(self.patch.stop)
        self.source = 'content/learn/pair/README.md'
        self.lesson = self.root / 'content/learn/pair'
        self.directory = self.lesson / 'assets/fig-pair'
        self.directory.mkdir(parents=True)
        self.sidecar = self.directory / 'illustration.json'
        self.state = {'version': 1, 'svg': 'figure.svg', 'construction': {'anything': 'renderer owned'}}
        self.sidecar.write_text(json.dumps(self.state))
        (self.directory / 'figure.svg').write_bytes(SVG)
        # A build must not execute this file or interpret its construction.
        (self.directory / 'draw.py').write_text('raise RuntimeError("must not run")')

    def test_resolves_renderer_independent_state_without_editing_it(self):
        original = self.sidecar.read_bytes()
        self.assertEqual(build.illustration_target(self.source, 'fig-pair'), 'assets/fig-pair/figure.svg')
        self.assertEqual(self.sidecar.read_bytes(), original)

    def test_missing_state_is_an_error_not_a_generation_request(self):
        self.sidecar.unlink()
        with self.assertRaisesRegex(ValueError, 'missing.*state'):
            build.illustration_target(self.source, 'fig-pair')
        self.assertFalse(self.sidecar.exists())

    def test_bad_ids_and_sidecars(self):
        for identifier in ['', '../escape', 'fig-UPPER']:
            with self.subTest(identifier=identifier), self.assertRaises(ValueError):
                build.illustration_target(self.source, identifier)
        for content in ['{', '[]', '{"version": true}', '{"version": 2}', '{"version": 1}']:
            self.sidecar.write_text(content)
            with self.subTest(content=content), self.assertRaises(ValueError):
                build.illustration_target(self.source, 'fig-pair')

    def test_rejects_missing_external_and_escaping_svg(self):
        for target in ['missing.svg', '../other.svg', '/tmp/figure.svg',
                       'https://example.com/figure.svg', 'figure.svg#part',
                       'figure.svg?download=1', '%2e%2e/other.svg']:
            self.sidecar.write_text(json.dumps({'version': 1, 'svg': target}))
            with self.subTest(target=target), self.assertRaises(ValueError):
                build.illustration_target(self.source, 'fig-pair')

    def test_rejects_symlink_escape(self):
        outside = self.root / 'outside.svg'
        outside.write_bytes(SVG)
        (self.directory / 'figure.svg').unlink()
        (self.directory / 'figure.svg').symlink_to(outside)
        with self.assertRaises(ValueError):
            build.illustration_target(self.source, 'fig-pair')

    def prepare(self, blocks, descriptions=None, metadata=None):
        self.lesson.joinpath('README.md').write_text('Canonical lesson stays unchanged.\n')
        if descriptions is None:
            descriptions = [self.description('illustration', 'fig-pair')]
        document = {'pandoc-api-version': [1, 23], 'meta': {
            'diagrams': {'t': 'MetaList', 'c': descriptions}, **(metadata or {})}, 'blocks': blocks}
        jobs, assets = [], []
        with patch.object(build, 'parse', return_value=copy.deepcopy(document)), \
                patch.object(build, 'markdown', side_effect=lambda _, doc, __: doc):
            result, records = build.prepare_chapter(None, self.source, {}, 'commit', jobs,
                                                    output=self.root / 'output', assets=assets)
        return result, records, jobs, assets

    @staticmethod
    def description(kind, identifier):
        return {'t': 'MetaMap', 'c': {k: {'t': 'MetaString', 'c': v} for k, v in {
            'kind': kind, 'id': identifier, 'caption': 'One pair.', 'description': 'Two parts.'}.items()}}

    @staticmethod
    def fence(identifier='fig-pair'):
        return {'t': 'CodeBlock', 'c': [[identifier, ['illustration'], []],
                'A private authoring brief, not published lesson text.']}

    def test_nested_fences_become_accessible_images_and_assets(self):
        blocks = [{'t': 'Div', 'c': [['note', ['column-margin'], []], [self.fence()]]}]
        result, records, jobs, assets = self.prepare(blocks)
        self.assertEqual(result['blocks'][0]['t'], 'Div')
        image = result['blocks'][0]['c'][1][0]['c'][0]
        self.assertEqual(image['t'], 'Image')
        self.assertIn(['fig-alt', 'Two parts.'], image['c'][0][2])
        self.assertEqual((self.root / 'output' / image['c'][2][0]).read_bytes(), SVG)
        self.assertEqual(len(assets), 1)
        self.assertEqual(records, [])
        self.assertEqual(jobs, [])
        self.assertNotIn('private authoring', json.dumps(result))
        self.assertEqual((self.lesson / 'README.md').read_text(), 'Canonical lesson stays unchanged.\n')

    def test_duplicate_and_mismatched_ids(self):
        descriptions = [self.description('illustration', 'fig-pair')] * 2
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            self.prepare([self.fence(), self.fence()], descriptions)
        with self.assertRaisesRegex(ValueError, 'does not match'):
            self.prepare([self.fence('fig-other')])

    def test_literal_physical_width_is_preserved_without_authoring(self):
        description = self.description('illustration', 'fig-pair')
        description['c']['width'] = {'t': 'MetaString', 'c': '42mm'}
        result, _, jobs, _ = self.prepare([self.fence()], [description])
        self.assertIn(['width', '42mm'], result['blocks'][0]['c'][0]['c'][0][2])
        self.assertIn('authored-illustration', result['blocks'][0]['c'][0]['c'][0][1])
        self.assertIn(['style', '--illustration-width:42mm;--illustration-note-fraction:0.84000000'],
                      result['blocks'][0]['c'][0]['c'][0][2])
        self.assertEqual(jobs, [])

    def test_invalid_physical_width_is_rejected(self):
        for width in ['0mm', '-2mm', 'auto', '120%', 'javascript:bad']:
            description = self.description('illustration', 'fig-pair')
            description['c']['width'] = {'t': 'MetaString', 'c': width}
            with self.subTest(width=width), self.assertRaisesRegex(ValueError, 'width'):
                self.prepare([self.fence()], [description])

    def test_preparation_ignores_authoring_defaults_and_saved_appearance(self):
        self.state['construction']['appearance'] = {'font': 'unknown', 'roughness': -1}
        self.sidecar.write_text(json.dumps(self.state))
        original = self.sidecar.read_bytes()
        with patch.object(build, 'run', side_effect=AssertionError('No authoring execution')):
            result, _, jobs, assets = self.prepare([self.fence()], metadata={
                'illustration-defaults': {'t': 'MetaString', 'c': 'not an authoring map'}})
        image = result['blocks'][0]['c'][0]
        self.assertEqual((self.root / 'output' / image['c'][2][0]).read_bytes(), SVG)
        self.assertEqual(self.sidecar.read_bytes(), original)
        self.assertEqual(jobs, [])
        self.assertEqual(len(assets), 1)

    def test_mixed_notation_keeps_metadata_order_and_only_notation_jobs(self):
        notation = {'t': 'CodeBlock', 'c': [['', ['split'], []], 'row: int']}
        descriptions = [self.description('illustration', 'fig-pair'),
                        self.description('split', 'fig-int')]
        with patch.object(build, 'locate_fence', return_value=0):
            result, codes, jobs, assets = self.prepare([self.fence(), notation], descriptions)
        self.assertEqual([job['id'] for job in jobs], ['fig-int'])
        self.assertEqual(len(assets), 1)
        self.assertEqual(codes, [])
        self.assertEqual(len(result['blocks']), 2)

    def test_invalid_svg_uses_existing_validation(self):
        (self.directory / 'figure.svg').write_text(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"><script/></svg>')
        with self.assertRaisesRegex(ValueError, 'unsuitable SVG'):
            self.prepare([self.fence()])

    @unittest.skipUnless(shutil.which('pandoc'), 'standalone Pandoc is not installed')
    def test_real_markdown_parser_and_writer_preserve_fence_position(self):
        text = '''---
diagrams:
  - kind: illustration
    id: fig-pair
    caption: One pair.
    description: Two parts.
---
# Pair

Before.

::: {.column-margin}
```{#fig-pair .illustration}
Describe this pair.
```
:::

After.
'''
        (self.lesson / 'README.md').write_text(text)
        original_run = build.run

        def standalone(args, **kwargs):
            # Exercise real Pandoc parsing/writing without claiming pinned Quarto QA.
            if len(args) > 1 and args[1] == 'pandoc':
                args = ['pandoc', *args[2:]]
            return original_run(args, **kwargs)

        with patch.object(build, 'run', side_effect=standalone):
            staged, codes = build.prepare_chapter('quarto', self.source, {}, 'commit', [],
                                                  output=self.root / 'output', assets=[])
        self.assertLess(staged.index('Before.'), staged.index('![One pair.]'))
        self.assertLess(staged.index('![One pair.]'), staged.index('After.'))
        self.assertNotIn('Describe this pair.', staged)
        self.assertEqual(codes, [])
        self.assertEqual((self.lesson / 'README.md').read_text(), text)


if __name__ == '__main__':
    unittest.main()
