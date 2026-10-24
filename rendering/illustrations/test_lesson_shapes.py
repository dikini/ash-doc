"""Check migrated illustration meaning, shape sizes, and saved-SVG boundaries."""
import hashlib
import json
from pathlib import Path
import re
import unittest
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[2]
LESSONS = ['content/learn/using-more-than-one-input',
           'content/learn/values-travel-together',
           'content/cases/guaranteeing-logarithmic-retrieval']


class LessonShapes(unittest.TestCase):
    def test_all_figures_have_briefs_physical_sizes_and_valid_saved_geometry(self):
        figures = 0
        for lesson in LESSONS:
            text = (ROOT / lesson / 'README.md').read_text()
            self.assertNotIn('```split', text)
            self.assertNotIn('kind: split', text)
            self.assertNotIn('fig-red-root-sketch', text)
            self.assertNotIn('red-root-example', text)
            for identifier, width in re.findall(r'    id: (fig-[\w-]+)\n    width: ([\d.]+)mm', text):
                figures += 1
                asset = ROOT / lesson / 'assets' / identifier
                state = json.loads((asset / 'illustration.json').read_text())
                svg = (asset / state['svg']).read_bytes()
                document = ElementTree.fromstring(svg)
                self.assertFalse(any(node.tag.endswith('}text') for node in document.iter()))
                view_width = float(document.get('viewBox').split()[2])
                if 'display' in state['construction']:
                    display = state['construction']['display']
                    self.assertEqual(display['width'], width + 'mm')
                    self.assertAlmostEqual(float(width) / view_width * display['primitiveUnits'],
                                           display['primitiveMm'], places=3)
                    self.assertEqual(state['provenance']['svgSha256'], hashlib.sha256(svg).hexdigest())
                    scene = state['construction'].get('scene', {}).get('elements', [])
                    if display['shape'] == 'circle':
                        self.assertTrue(all(element['r'] * 2 == display['primitiveUnits'] for element in scene
                                            if element['kind'] in {'circle', 'emptyCircle', 'solidCircle'}))
                        geometry = [node.get('data-shape') for node in document]
                        edges = geometry.count('edge')
                        self.assertEqual(geometry[:edges], ['edge'] * edges)
                else:
                    self.assertAlmostEqual(float(width) / view_width * state['construction']['slot_size'],
                                           6.5, places=3)
                self.assertIn(f'```{{#{identifier} .illustration}}', text)
        self.assertEqual(figures, 10)

    def test_wide_repair_keeps_program_names_and_order(self):
        state = json.loads((ROOT / LESSONS[2] / 'assets/fig-tree-repair/illustration.json').read_text())
        source = state['construction']['source']
        self.assertIn('black/(k3,v3)\n    red/(k2,v2)\n      red/(k1,v1)', source)
        self.assertIn('red/(k2,v2)\n    black/(k1,v1)\n      a\n      b\n    black/(k3,v3)', source)
        scene = state['construction']['scene']['elements']
        labels = [element['content'] for element in scene if element['kind'] == 'text']
        self.assertEqual(labels.count('(k1, v1)'), 2)
        self.assertEqual(labels.count('(k3, v3)'), 2)
        self.assertEqual([label for label in labels if label in 'abcd'], list('abcdabcd'))


if __name__ == '__main__':
    unittest.main()
