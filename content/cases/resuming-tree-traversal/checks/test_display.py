"""Exercise source drift and wrong selections in the traversal explanation."""
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DisplayTests(unittest.TestCase):
    def setUp(self):
        path = ROOT / 'checks/check_display.py'
        self.assertTrue(path.is_file(), 'traversal display agreement check is missing')
        spec = importlib.util.spec_from_file_location('display', path)
        self.check = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.check)
        self.sources = {p.name: p.read_text() for p in (ROOT / 'src').glob('*.ash')}
        self.fragments = self.check.fragments(self.sources)
        self.captures = {name: (ROOT / f'fixtures/{name}.stdout').read_text()
                         for name in ('sequence', 'retained-state')}
        self.parts = self.check.observations(self.captures)
        self.document = '\n\n'.join(
            f'<!-- {kind}: {key} -->\n```text\n{value}\n```'
            for kind, values in (('excerpt', self.fragments), ('observation', self.parts))
            for key, value in values.items())

    def verify(self, document=None, sources=None, captures=None):
        return self.check.verify(self.document if document is None else document,
                                 self.sources if sources is None else sources,
                                 self.captures if captures is None else captures)

    def test_exact_source_and_capture_selections(self):
        self.assertEqual(self.verify(), (len(self.fragments), len(self.parts)))

    def test_changed_pending_subtree_is_detected(self):
        changed = dict(self.sources)
        changed['dictionaries.ash'] = changed['dictionaries.ash'].replace(
            'push_left right rest', 'push_left right NoFrame')
        with self.assertRaisesRegex(ValueError, 'differs'):
            self.verify(sources=changed)

    def test_changed_replay_association_is_detected(self):
        changed = dict(self.captures)
        changed['retained-state'] = changed['retained-state'].replace('20)', '21)', 1)
        with self.assertRaisesRegex(ValueError, 'differs'):
            self.verify(captures=changed)

    def test_returned_state_cannot_replace_retained_state(self):
        old = self.parts['retained-state#saved']
        new = self.parts['retained-state#first']
        with self.assertRaisesRegex(ValueError, 'differs'):
            self.verify(self.document.replace(old, new, 1))

    def test_missing_selection_is_detected(self):
        with self.assertRaisesRegex(ValueError, 'missing'):
            self.verify(self.document[:self.document.rfind('<!-- observation:')])

    def test_duplicate_selection_is_detected(self):
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            self.verify(self.document + '\n' + self.document)

    def test_unknown_selection_is_detected(self):
        with self.assertRaisesRegex(ValueError, 'unknown'):
            self.verify(self.document.replace('sequence#empty', 'sequence#fourth'))

    def test_malformed_marker_is_detected(self):
        with self.assertRaisesRegex(ValueError, 'malformed'):
            self.verify(self.document.replace('<!-- observation:', '<!-- observation :', 1))

    def test_incomplete_capture_is_detected(self):
        changed = dict(self.captures)
        changed['sequence'] = '(true, End) : (Bool, List<(Natural, Int)>)\n'
        with self.assertRaises(ValueError):
            self.verify(captures=changed)

    def test_changed_result_type_is_detected(self):
        changed = dict(self.captures)
        changed['retained-state'] = changed['retained-state'].replace('ReplayObservation', 'Int')
        with self.assertRaisesRegex(ValueError, 'type'):
            self.verify(captures=changed)

    def test_wrong_frame_shape_is_detected(self):
        changed = dict(self.captures)
        changed['retained-state'] = changed['retained-state'].replace(', NoFrame', '', 1)
        with self.assertRaises(ValueError):
            self.verify(captures=changed)


if __name__ == '__main__':
    unittest.main()
