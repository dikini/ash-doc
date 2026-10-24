"""Check the transparent mathematical SVG trial without browser dependencies."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from xml.etree import ElementTree

DIRECTORY = Path(__file__).resolve().parent
ROOT = DIRECTORY.parents[1]
SVG = '{http://www.w3.org/2000/svg}'


class FoldTrialTests(unittest.TestCase):
    def test_matched_trees_and_portable_transparent_output(self):
        with tempfile.TemporaryDirectory() as directory:
            command = ['python3', str(DIRECTORY / 'fold-trial.py'), '--output', directory]
            environment = {**os.environ, 'PYTHONPATH': str(ROOT / '.build/illustration-python')}
            subprocess.run(command, env=environment, check=True, capture_output=True)
            path = Path(directory) / 'assets/fig-foldr-structure/figure.svg'
            first = path.read_bytes()
            subprocess.run(command, env=environment, check=True, capture_output=True)
            self.assertEqual(path.read_bytes(), first)
            root = ElementTree.fromstring(first)
            self.assertEqual(root.get('viewBox'), '0 0 536 282')
            for tag in ['rect', 'text', 'script', 'image', 'foreignObject', 'filter']:
                self.assertFalse(list(root.iter(SVG + tag)), tag)
            trees = [node for node in root if node.get('data-tree')]
            self.assertEqual(len(trees), 2)
            left_edges = [node.get('d') for node in trees[0].findall(SVG + 'path')]
            right_edges = [node.get('d') for node in trees[1].findall(SVG + 'path')]
            self.assertTrue(right_edges[0].startswith('M47 79L40 87 '),
                            'The numbered branch must start below the italic f descender.')
            for left, right in zip(left_edges, right_edges):
                self.assertEqual(left.split('L', 1)[1], right.split('L', 1)[1])
            left_values = [node.get('transform') for node in trees[0].findall(SVG + 'g')
                           if node.get('aria-label', '').isdigit()]
            right_values = [node.get('transform') for node in trees[1].findall(SVG + 'g')
                            if node.get('aria-label', '').isdigit()]
            self.assertEqual(left_values, right_values)
            labels = [[node.get('aria-label') for node in tree.findall(SVG + 'g')] for tree in trees]
            self.assertEqual(labels[0], [item for number in range(1, 6) for item in [':', str(number)]] + ['[]'])
            self.assertEqual(labels[1], [item for number in range(1, 6) for item in ['f', str(number)]] + ['z'])


if __name__ == '__main__':
    unittest.main()
