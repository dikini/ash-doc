"""Exercise complete wide-code pagination, printable bounds, and note clearance."""

import importlib.util
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("render_verify", ROOT / "rendering/checks/verify.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


def page(words):
    document = ET.Element("page")
    for text, left, right, top, bottom in words:
        word = ET.SubElement(document, "word", xMin=str(left), xMax=str(right),
                             yMin=str(top), yMax=str(bottom))
        word.text = text
    return document


class WideCodePdfTests(unittest.TestCase):
    def verify(self, pages, text="f : D -> D\nf value = value", a4=False, notes=None,
               expected_occurrences=1):
        verifier = getattr(VERIFY, "verify_wide_code_pdf", None)
        self.assertTrue(callable(verifier), "wide-code PDF geometry check is missing")
        return verifier(pages, [{"id": "wide-f", "text": text,
                                 "expected_occurrences": expected_occurrences}], "test.pdf", a4,
                        {} if notes is None else notes)

    def test_wrapped_code_retains_complete_characters_on_one_page(self):
        document = page([
            ("f : D -> D", 54, 120, 100, 110),
            ("f value", 54, 100, 115, 125),
            ("= value", 54, 95, 130, 140),
        ])
        self.assertEqual(self.verify([document]), {"wide-f": 1})

    def test_complete_code_split_across_pages_is_rejected(self):
        first = page([("f : D -> D", 54, 120, 640, 650)])
        second = page([("f value = value", 36, 130, 54, 64)])
        for a4 in (False, True):
            with self.subTest(a4=a4), self.assertRaisesRegex(ValueError, "complete.*one page"):
                self.verify([first, second], a4=a4)

    def test_missing_code_character_is_rejected(self):
        document = page([("f : D > D f value = value", 54, 200, 100, 110)])
        with self.assertRaisesRegex(ValueError, "complete.*one page"):
            self.verify([document])

    def test_earliest_signature_controls_geometry_despite_later_duplicate(self):
        first = page([("f : D -> D", 20, 120, 100, 110)])
        second = page([("f : D -> D", 36, 120, 100, 110)])
        with self.assertRaisesRegex(ValueError, "printable bounds"):
            self.verify([first, second], text="f : D -> D", expected_occurrences=2)

    def test_later_complete_signature_cannot_hide_a_split_first_copy(self):
        first = page([("f : D", 54, 100, 640, 650)])
        second = page([("-> D", 36, 75, 54, 64)])
        later = page([("f : D -> D", 54, 120, 100, 110)])
        with self.assertRaisesRegex(ValueError, "complete.*one page"):
            self.verify([first, second, later], text="f : D -> D", expected_occurrences=2)

    def test_each_complete_signature_copy_must_fit_printable_bounds(self):
        first = page([("f : D -> D", 54, 120, 100, 110)])
        later = page([("f : D -> D", 20, 120, 100, 110)])
        with self.assertRaisesRegex(ValueError, "printable bounds"):
            self.verify([first, later], text="f : D -> D", expected_occurrences=2)

    def test_book_mirrored_page_bounds_are_enforced(self):
        for number, left, right in ((1, 52, 120), (1, 54, 542),
                                    (2, 34, 120), (2, 36, 524)):
            with self.subTest(number=number, left=left, right=right):
                pages = [page([])] * (number - 1)
                pages.append(page([("f : D -> D f value = value", left, right, 100, 110)]))
                with self.assertRaisesRegex(ValueError, "printable bounds"):
                    self.verify(pages)

    def test_a4_body_and_right_note_bounds_are_enforced(self):
        mm = 72 / 25.4
        cases = ((25 * mm - 2, 190 * mm, 100, 110),
                 (25 * mm, 190 * mm + 2, 100, 110),
                 (25 * mm, 190 * mm, 20 * mm - 2, 110),
                 (25 * mm, 190 * mm, 100, 277 * mm + 2))
        for bounds in cases:
            with self.subTest(bounds=bounds), self.assertRaisesRegex(ValueError, "printable bounds"):
                self.verify([page([("f : D -> D f value = value", *bounds)])], a4=True)

    def test_wide_code_cannot_overlap_a_note(self):
        document = page([("f : D -> D f value = value", 54, 500, 100, 140)])
        notes = {1: [{"left": 396, "right": 540, "top": 120, "bottom": 160}]}
        with self.assertRaisesRegex(ValueError, "overlaps.*note"):
            self.verify([document], notes=notes)

    def test_nearby_nonoverlapping_notes_remain_allowed(self):
        document = page([("f : D -> D f value = value", 54, 350, 100, 140)])
        notes = {1: [{"left": 396, "right": 540, "top": 100, "bottom": 140},
                     {"left": 54, "right": 540, "top": 150, "bottom": 170}]}
        self.assertEqual(self.verify([document], notes=notes), {"wide-f": 1})


class WideCodeSourceTests(unittest.TestCase):
    def test_native_wide_divs_select_ordinary_code_without_duplicate_nested_records(self):
        signature = {"t": "CodeBlock", "c": [["", ["text"], []], "f : D -> D"]}
        diagram = {"t": "CodeBlock", "c": [["", ["mermaid"], []], "flowchart TB"]}
        inner = {"t": "Div", "c": [["wide-inner", ["column-page-right"], []], [signature]]}
        outer = {"t": "Div", "c": [["wide-outer", ["column-page-right"], []], [inner, diagram]]}
        ordinary = {"t": "Div", "c": [["ordinary", [], []], [
            {"t": "CodeBlock", "c": [["", ["text"], []], "ordinary code"]}]]}
        extractor = getattr(VERIFY, "wide_code_blocks", None)
        self.assertTrue(callable(extractor), "wide-code source selection is missing")
        self.assertEqual(extractor([outer, ordinary]), [{"id": "wide-outer", "text": "f : D -> D",
                                                       "expected_occurrences": 1}])

    def test_signature_selection_counts_its_later_ordinary_definition(self):
        signature = {"t": "CodeBlock", "c": [["", ["text"], []], "f : D -> D"]}
        wide = {"t": "Div", "c": [["wide-f", ["column-page-right"], []], [signature]]}
        definition = {"t": "CodeBlock", "c": [["", ["text"], []],
                      "f : D -> D\nf value = value"]}
        extractor = getattr(VERIFY, "wide_code_blocks", None)
        self.assertTrue(callable(extractor), "wide-code source selection is missing")
        self.assertEqual(extractor([wide, definition]), [{"id": "wide-f", "text": "f : D -> D",
                                                        "expected_occurrences": 2}])


if __name__ == "__main__":
    unittest.main()
