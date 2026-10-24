"""Inspect the saved structural fold trial after its explicit authoring command."""
import hashlib
import json
from pathlib import Path
import unittest
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[2]


class StructuralFoldTrial(unittest.TestCase):
    def test_structure_color_labels_and_paint_order(self):
        asset = ROOT / '.build/fold-tree-trial/assets/fig-fold-tree'
        state = json.loads((asset / 'illustration.json').read_text())
        svg = (asset / 'figure.svg').read_bytes()
        self.assertEqual(hashlib.sha256(svg).hexdigest(), state['provenance']['svgSha256'])
        document = ElementTree.fromstring(svg)
        self.assertFalse(any(node.tag.rsplit('}', 1)[-1] in
                             {'text', 'image', 'rect', 'script', 'foreignObject'}
                             for node in document.iter()))
        trees = [node for node in document if node.get('data-tree')]
        self.assertEqual(len(trees), 2)
        leaf_colors = []
        for index, tree in enumerate(trees):
            roles = [node.get('data-role') for node in tree if node.get('data-role')]
            self.assertEqual(roles, ['edge'] * 10 + ['circle'] * 5 + ['triangle'] * 6)
            labels = [node.get('aria-label') for node in tree if node.get('aria-label')]
            self.assertEqual(labels, [':' if index == 0 else 'f'] * 5 +
                             ['1', '2', '3', '4', '5', '[]' if index == 0 else 'z'])
            triangles = [node for node in tree if node.get('data-role') == 'triangle']
            fills = [[path.get('fill') for path in node if path.get('fill') not in
                      {None, 'none'}] for node in triangles]
            leaf_colors.append(fills)
        self.assertEqual(leaf_colors[0], leaf_colors[1])
        self.assertEqual(len({tuple(colors) for colors in leaf_colors[0]}), 6)


if __name__ == '__main__':
    unittest.main()
