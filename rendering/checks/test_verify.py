"""Exercise complete wide-code pagination, printable bounds, and note clearance."""

import importlib.util
import copy
import hashlib
import json
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch


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


class HtmlTitleTests(unittest.TestCase):
    def test_source_title_survives_the_html_title_wrapper_without_a_source_anchor(self):
        rendered = VERIFY.Html('<header id="title-block-header"><h1 class="title">'
                               '<span class="chapter-title">What is an Ash program?</span>'
                               '</h1></header><p>Reader text.</p>')
        self.assertEqual(getattr(rendered, "headings", None), ["What is an Ash program?"],
                         "HTML chapter titles need their text preserved inside nested markup")


class DiagramSourceTests(unittest.TestCase):
    def verify(self, jobs, records):
        verifier = getattr(VERIFY, "verify_diagram_sources", None)
        self.assertTrue(callable(verifier), "diagram source coverage check is missing")
        verifier(jobs, records)

    def test_real_lesson_diagrams_are_allowed_in_the_book(self):
        self.verify([{"id": "lesson-grammar", "path": "content/learn/example/README.md"}],
                    [{"source": "content/learn/example/README.md", "role": "lesson"}])

    def test_unrecorded_project_fixture_diagram_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "diagram.*recorded source"):
            self.verify([{"id": "fixture-grammar", "path": "rendering/specimen/notation.md"}],
                        [{"source": "content/learn/example/README.md", "role": "lesson"}])


class BookCoverageTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.records, parts = [], []
        for family in ("learn", "libraries", "effects", "cases"):
            directory = self.root / "content" / family
            directory.mkdir(parents=True)
            index = directory / "README.md"
            index.write_text(f"# {family.title()}\n\n"
                             "1. [First](first/README.md)\n"
                             "2. [Second](second/README.md)\n")
            introduction = f"{family}-introduction.md"
            self.add_record(index, introduction, "introduction", family)
            chapters = []
            for name in ("first", "second"):
                source = directory / name / "README.md"
                source.parent.mkdir()
                source.write_text(f"# {family.title()} {name}\n")
                chapter = f"{family}-{name}.md"
                self.add_record(source, chapter, "lesson", family)
                chapters.append(chapter)
            parts.append({"family": family, "introduction": introduction, "chapters": chapters})
        (self.root / "rendering").mkdir()
        (self.root / "rendering/specimen.json").write_text(json.dumps({
            "ash_commit": "354c76b391fe4af665cf6a03479a9874a57cb3e3"}))
        self.metadata = {
            "mode": "book", "title": "Ash documentation review book",
            "output_file": "ash-doc-review",
            "ash_commit": "354c76b391fe4af665cf6a03479a9874a57cb3e3",
            "source_commit": "a" * 40, "parts": parts, "lesson_count": 8,
            "chapters": ["index.md", "setup.md"] + [record["chapter"] for record in self.records],
        }

    def add_record(self, source, chapter, role, family):
        self.records.append({"source": source.relative_to(self.root).as_posix(),
                             "chapter": chapter, "role": role, "family": family,
                             "sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                             "code": [], "assets": []})

    def verify(self):
        verifier = getattr(VERIFY, "verify_build_metadata", None)
        self.assertTrue(callable(verifier), "build identity and indexed coverage check is missing")
        return verifier(self.metadata, self.records, self.root)

    def resync_chapters(self):
        self.metadata["chapters"] = ["index.md", "setup.md"] + [
            record["chapter"] for record in self.records]

    def test_complete_index_order_and_parts_are_accepted(self):
        self.assertEqual(self.verify(), "ash-doc-review")

    def test_missing_lesson_cannot_be_hidden_by_adjusting_reported_count(self):
        self.records.pop(2)
        self.metadata["parts"][0]["chapters"].pop()
        self.metadata["lesson_count"] -= 1
        self.resync_chapters()
        with self.assertRaisesRegex(ValueError, "indexed reading order"):
            self.verify()

    def test_reordered_lessons_cannot_be_hidden_by_matching_metadata(self):
        self.records[1:3] = reversed(self.records[1:3])
        self.metadata["parts"][0]["chapters"].reverse()
        self.resync_chapters()
        with self.assertRaisesRegex(ValueError, "indexed reading order"):
            self.verify()

    def test_family_order_must_follow_the_approved_book_order(self):
        self.records[3:9] = self.records[6:9] + self.records[3:6]
        self.metadata["parts"][1:3] = reversed(self.metadata["parts"][1:3])
        self.resync_chapters()
        with self.assertRaisesRegex(ValueError, "indexed reading order"):
            self.verify()

    def test_book_rejects_an_introduction_reported_as_a_lesson(self):
        self.records[0]["role"] = "lesson"
        self.metadata["lesson_count"] += 1
        with self.assertRaisesRegex(ValueError, "role.*introduction"):
            self.verify()

    def test_part_chapters_must_match_source_records(self):
        self.metadata["parts"][0]["chapters"].reverse()
        with self.assertRaisesRegex(ValueError, "part.*chapters"):
            self.verify()

    def test_output_basename_cannot_leak_between_modes(self):
        self.metadata["output_file"] = "ash-doc-specimen"
        with self.assertRaisesRegex(ValueError, "output.*book"):
            self.verify()

    def test_changed_canonical_source_invalidates_its_recorded_digest(self):
        (self.root / self.records[1]["source"]).write_text("# Changed source\n")
        with self.assertRaisesRegex(ValueError, "source.*digest"):
            self.verify()


class EpubChapterTests(unittest.TestCase):
    def setUp(self):
        self.records = [
            {"source": "first/README.md", "title": "First chapter", "anchor": "first-chapter",
             "code": [{"text": "first : Int\nfirst = 1"}, {"text": "$ ash first.ash\n1 : Int"}]},
            {"source": "second/README.md", "title": "Second chapter", "anchor": "second-chapter",
             "code": [{"text": "second : Int\nsecond = 2"}]},
        ]
        self.xml = {"EPUB/content.opf": ET.fromstring(
            '<package xmlns="http://www.idpf.org/2007/opf" version="3.0"><manifest>'
            '<item id="nav" href="nav.xhtml" properties="nav"/>'
            '<item id="one" href="text/one.xhtml"/>'
            '<item id="two" href="text/two.xhtml"/>'
            '</manifest><spine><itemref idref="one"/><itemref idref="two"/></spine></package>')}
        nav = ET.fromstring('<html xmlns="http://www.w3.org/1999/xhtml" '
                            'xmlns:epub="http://www.idpf.org/2007/ops"><body>'
                            '<nav epub:type="toc"/></body></html>')
        for number, record in enumerate(self.records):
            filename = ("one", "two")[number] + ".xhtml"
            document = ET.fromstring('<html xmlns="http://www.w3.org/1999/xhtml"><body/></html>')
            body = document.find("{*}body")
            section = ET.SubElement(body, "section", id=record["anchor"])
            ET.SubElement(section, "h1").text = record["title"]
            for block in record["code"]:
                ET.SubElement(section, "pre").text = block["text"] + "\n"
            self.xml["EPUB/text/" + filename] = document
            ET.SubElement(nav.find(".//{*}nav"), "a",
                          href="text/" + filename + "#" + record["anchor"]).text = record["title"]
        self.xml["EPUB/nav.xhtml"] = nav

    def verify(self):
        verifier = getattr(VERIFY, "verify_epub_chapters", None)
        self.assertTrue(callable(verifier), "chapter-scoped EPUB agreement check is missing")
        return verifier(self.xml, "EPUB/content.opf", self.records)

    def test_spine_headings_and_navigation_associate_each_source_chapter(self):
        result = self.verify()
        self.assertEqual([result[record["source"]][0] for record in self.records],
                         ["EPUB/text/one.xhtml", "EPUB/text/two.xhtml"])

    def test_code_moved_to_another_chapter_is_rejected(self):
        first = self.xml["EPUB/text/one.xhtml"].find(".//section")
        second = self.xml["EPUB/text/two.xhtml"].find(".//section")
        block = first.find("pre")
        first.remove(block)
        second.append(block)
        with self.assertRaisesRegex(ValueError, "first/README.md.*code/transcript"):
            self.verify()

    def test_duplicate_code_in_its_own_chapter_is_rejected(self):
        first = self.xml["EPUB/text/one.xhtml"].find(".//section")
        first.append(copy.deepcopy(first.find("pre")))
        with self.assertRaisesRegex(ValueError, "code/transcript"):
            self.verify()

    def test_reordered_transcript_blocks_are_rejected(self):
        first = self.xml["EPUB/text/one.xhtml"].find(".//section")
        block = first.find("pre")
        first.remove(block)
        first.append(block)
        with self.assertRaisesRegex(ValueError, "code/transcript"):
            self.verify()

    def test_wrong_spine_order_cannot_be_hidden_by_the_nav_order(self):
        spine = self.xml["EPUB/content.opf"].find("{*}spine")
        first = spine[0]
        spine.remove(first)
        spine.append(first)
        with self.assertRaisesRegex(ValueError, "spine.*order"):
            self.verify()

    def test_chapter_needs_its_own_navigation_destination(self):
        nav = self.xml["EPUB/nav.xhtml"].find(".//{*}nav")
        nav.remove(nav[0])
        with self.assertRaisesRegex(ValueError, "navigation.*first/README.md"):
            self.verify()


class BookPdfTests(unittest.TestCase):
    def verify_chapter_order(self, titles_by_page):
        with tempfile.TemporaryDirectory() as temporary:
            project = Path(temporary)
            (project / "output").mkdir()
            (project / "output/ash-doc-review.pdf").touch()
            for chapter, title in (("index.md", "Review"), ("setup.md", "Reader setup"),
                                   ("first.md", "First lesson"), ("second.md", "Second lesson")):
                (project / chapter).write_text(f"# {title}\n")
            document = ET.Element("document")
            for number, titles in enumerate(titles_by_page, 1):
                sheet = ET.SubElement(document, "page", width="576", height="720")
                for index, title in enumerate(titles):
                    block = ET.SubElement(sheet, "block")
                    word = ET.SubElement(block, "word", xMin=str(54 if number % 2 else 198),
                                         xMax="330", yMin=str(60 + index * 40),
                                         yMax=str(84 + index * 40))
                    word.text = title
            results = [SimpleNamespace(stdout=ET.tostring(document, encoding="unicode")),
                       SimpleNamespace(stdout="\f".join("\n".join(titles) for titles in titles_by_page))]
            records = [{"chapter": "first.md", "code": []}, {"chapter": "second.md", "code": []}]
            with patch.object(VERIFY.subprocess, "run", side_effect=results):
                return VERIFY.verify_pdf(project, records, [], None, "ash-doc-review.pdf")

    def test_complete_chapters_on_reordered_pages_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "chapter reading order"):
            self.verify_chapter_order((("Review",), ("Reader setup", "Second lesson"), ("First lesson",)))

    def test_complete_chapters_reordered_within_one_page_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "chapter reading order"):
            self.verify_chapter_order((("Review",), ("Reader setup", "Second lesson", "First lesson")))

    def test_successive_chapters_can_share_a_page_in_reading_order(self):
        self.assertEqual(self.verify_chapter_order((("Review",),
                                                   ("Reader setup", "First lesson", "Second lesson"))), 2)

    def test_book_without_the_specimen_fixture_keeps_generic_pdf_checks(self):
        with tempfile.TemporaryDirectory() as temporary:
            project = Path(temporary)
            (project / "output").mkdir()
            (project / "output/ash-doc-review.pdf").touch()
            for chapter, title in (("index.md", "Review"), ("setup.md", "Reader setup"),
                                   ("lesson.md", "Lesson")):
                (project / chapter).write_text(f"# {title}\n")
            document = ET.Element("document")
            for number, titles in enumerate((("Review",), ("Reader setup", "Lesson")), 1):
                sheet = ET.SubElement(document, "page", width="576", height="720")
                for index, title in enumerate(titles):
                    block = ET.SubElement(sheet, "block")
                    word = ET.SubElement(block, "word", xMin=str(54 if number % 2 else 198),
                                         xMax="300", yMin=str(60 + index * 40),
                                         yMax=str(84 + index * 40))
                    word.text = title
            results = [SimpleNamespace(stdout=ET.tostring(document, encoding="unicode")),
                       SimpleNamespace(stdout="Review\fReader setup Lesson\f")]
            with patch.object(VERIFY.subprocess, "run", side_effect=results):
                try:
                    count = VERIFY.verify_pdf(project, [{"chapter": "lesson.md", "code": []}],
                                              [], None, "ash-doc-review.pdf")
                except (ValueError, TypeError) as error:
                    self.fail(f"complete-book PDF cannot be verified without the fixture: {error}")
                self.assertEqual(count, 2)


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


class RepairReadingUnitTests(unittest.TestCase):
    def verify(self, pages, a4=False):
        verifier = getattr(VERIFY, "verify_repair_units_pdf", None)
        self.assertTrue(callable(verifier), "repair reading-unit pagination check is missing")
        return verifier(pages, [{"id": "restore-left-left", "text": "f : D -> D\nf value = value"}],
                        "test.pdf", a4)

    def test_complete_ordinary_unit_stays_on_one_page(self):
        document = page([("f : D -> D", 72, 130, 100, 110),
                         ("f value = value", 72, 160, 115, 125)])
        self.assertEqual(self.verify([document], a4=True), {"restore-left-left": 1})

    def test_case_or_helper_split_across_pages_is_rejected(self):
        first = page([("f : D -> D", 72, 130, 640, 650)])
        second = page([("f value = value", 72, 160, 60, 70)])
        with self.assertRaisesRegex(ValueError, "complete.*one page"):
            self.verify([first, second], a4=True)

    def test_ordinary_unit_cannot_enter_the_sidenote_column(self):
        document = page([("f : D -> D f value = value", 72, 410, 100, 110)])
        with self.assertRaisesRegex(ValueError, "body column"):
            self.verify([document], a4=True)


class BodyColumnCodeTests(unittest.TestCase):
    def matches(self, pages, text, layout_text, a4=False):
        function = getattr(VERIFY, 'pdf_code_matches', None)
        self.assertTrue(callable(function), 'column-aware PDF code comparison is missing')
        return function(pages, text, layout_text, a4)

    def test_margin_caption_does_not_interrupt_intact_body_code(self):
        source = 'f : Int -> Int\nf value = value'
        for number, left, margin in [(1, 54, 396), (2, 198, 36)]:
            with self.subTest(number=number):
                sheets = [page([])] * (number - 1) + [page([
                    ('f : Int -> Int', left, left + 100, 100, 110),
                    ('Figure 1', margin, margin + 80, 112, 122),
                    ('f value = value', left, left + 100, 125, 135),
                ])]
                self.assertTrue(self.matches(sheets, source,
                                             'f : Int -> Int Figure 1 f value = value'))

    def test_margin_arrow_cannot_repair_missing_body_character(self):
        sheet = page([('f : Int > Int', 54, 154, 100, 110),
                      ('Figure ->', 396, 476, 112, 122),
                      ('f value = value', 54, 154, 125, 135)])
        self.assertFalse(self.matches([sheet], 'f : Int -> Int\nf value = value',
                                      'f : Int > Int Figure -> f value = value'))

    def test_a4_fixed_note_column_is_excluded(self):
        mm = 72 / 25.4
        sheet = page([('f : Int -> Int', 25 * mm, 65 * mm, 100, 110),
                      ('Figure 1', 140 * mm, 170 * mm, 112, 122),
                      ('f value = value', 25 * mm, 65 * mm, 125, 135)])
        self.assertTrue(self.matches([sheet], 'f : Int -> Int\nf value = value',
                                     'f : Int -> Int Figure 1 f value = value', True))

    def test_complete_wide_code_keeps_existing_full_layout_check(self):
        self.assertTrue(self.matches([], 'f : Int -> Int', 'f : Int -> Int'))


if __name__ == "__main__":
    unittest.main()
