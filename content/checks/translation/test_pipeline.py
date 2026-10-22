"""Hermetic tests for the translation pipeline: segmentation round-trip,
protection, and the strict checks with planted violations."""

from __future__ import annotations

import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import pipeline

LESSON = pipeline.REPO_ROOT / "content" / "learn" / "what-is-an-ash-program"
LESSONS = [
    LESSON,
    pipeline.REPO_ROOT / "content" / "learn" / "using-another-source-file",
    pipeline.REPO_ROOT / "content" / "learn" / "using-more-than-one-input",
]


class LessonFixture:
    """A scratch copy of lesson 1 with an identity-translated Bulgarian
    chapter, so planted violations start from a known-good pair."""

    def __init__(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name) / LESSON.name
        shutil.copytree(LESSON, self.dir)
        en = (self.dir / "README.md").read_text()
        blocks, blanks, trailing, newline = pipeline.parse(en)
        prepared = pipeline.prepare_segments(blocks)
        identity = {i: prepared[i][0] for i in sorted(prepared)}
        translated = {i: pipeline.restore(identity[i], blocks[i].spans) for i in identity}
        (self.dir / "README.bg.md").write_text(pipeline.assemble(
            blocks, blanks, trailing, newline, translated))
        state = {
            "language": "bg",
            "tier": "mt-draft",
            "claimed_english_sha256": pipeline.sha256_text(en),
            "generated_at": "2026-10-22T00:00:00+00:00",
            "provenance": {"model": "identity-fixture"},
        }
        (self.dir / "checks" / "translation.json").write_text(json.dumps(state))
        self.violations = lambda: pipeline.check_lesson(self.dir)

    def bg_text(self) -> str:
        return (self.dir / "README.bg.md").read_text()

    def write_bg(self, text: str) -> None:
        (self.dir / "README.bg.md").write_text(text)

    def cleanup(self) -> None:
        self.tmp.cleanup()

    def __enter__(self) -> "LessonFixture":
        return self

    def __exit__(self, *args: object) -> None:
        self.cleanup()


class RoundTripTest(unittest.TestCase):
    def test_english_reassembles_byte_identically(self) -> None:
        for lesson in LESSONS:
            source = (lesson / "README.md").read_text()
            blocks, blanks, trailing, newline = pipeline.parse(source)
            rebuilt = pipeline.assemble(blocks, blanks, trailing, newline)
            self.assertEqual(source, rebuilt, lesson.name)

    def test_protect_restore_round_trip(self) -> None:
        text = "Use `main` and see [entry rules][entry] at (https://x.y) end"
        protected, spans = pipeline.protect(text)
        self.assertNotIn("`main`", protected)
        self.assertIn("<!--t0-->", protected)
        self.assertEqual(text, pipeline.restore(protected, spans))

    def test_restore_tolerates_stripped_placeholder_padding(self) -> None:
        text = "Дефиниция `multiply_three : Int -> Int -> Int -> Int` тук"
        protected, spans = pipeline.protect(text)
        damaged = protected.replace(
            pipeline.placeholder_token(0, len(spans[0])), "<!--t0-->")
        self.assertEqual(text, pipeline.restore(damaged, spans))

    def test_formatting_never_splits_inline_spans(self) -> None:
        text = ("В извикването `add 20 22` входовете съответстват на параметрите "
                "отляво надясно в този файл и още малко текст за ширина")
        block = pipeline.Block("paragraph", [], text=text)
        for line in pipeline.format_block(block, text):
            self.assertEqual(line.count("`") % 2, 0, line)
            self.assertLessEqual(len(line), 80, line)
        long_span = ("Дефинирайте `multiply_three : Int -> Int -> Int -> Int` в "
                     "файла, като умножите входа сам по себе си, и маркирайте")
        for line in pipeline.format_block(block, long_span):
            self.assertLessEqual(len(line), 80, line)

    def test_glossary_parsing(self) -> None:
        never = pipeline.glossary_never_translate()
        for term in ("main", "pub", "import", "Unit", "Int",
                     "entry.missing-main", "resolve.unavailable-export"):
            self.assertIn(term, never)
        renderings = pipeline.glossary_renderings()
        self.assertEqual(renderings["currying"], "къринг")
        self.assertEqual(renderings["partial application"], "частично прилагане")


class PlantedViolationTest(unittest.TestCase):
    def test_identity_translation_passes(self) -> None:
        with LessonFixture() as fx:
            # The identity fixture is English text, and English homographs
            # ("as", "program", "answer") legitimately trip the prose
            # glossary scan; the scan itself is covered by synthetic tests.
            non_glossary = [v for v in fx.violations()
                            if not v.startswith("glossary")]
            self.assertEqual(non_glossary, [])

    def test_planted_transplant_corruption_fails(self) -> None:
        with LessonFixture() as fx:
            self.write_bg_corrupted_fence(fx)
            codes = [v.split(":")[0] for v in fx.violations()]
            self.assertIn("transplant", codes)

    def test_planted_glossary_violation_fails(self) -> None:
        with LessonFixture() as fx:
            self.assertFalse(any("'main'" in v for v in fx.violations()))
            text = fx.bg_text().replace("`main`", "main", 1)
            fx.write_bg(text)
            hits = [v for v in fx.violations()
                    if v.startswith("glossary") and "'main'" in v]
            self.assertTrue(hits, fx.violations())

    def test_planted_heading_level_change_fails(self) -> None:
        with LessonFixture() as fx:
            text = fx.bg_text().replace(
                "## Expressions calculate values", "### Expressions calculate values")
            fx.write_bg(text)
            codes = [v.split(":")[0] for v in fx.violations()]
            self.assertIn("skeleton", codes)

    def test_drift_reported_when_english_changes(self) -> None:
        with LessonFixture() as fx:
            en_path = fx.dir / "README.md"
            en_path.write_text(en_path.read_text() + "\nA new sentence.\n")
            hits = [v for v in fx.violations() if v.startswith("drift")]
            self.assertTrue(hits, fx.violations())

    def test_unadjudicated_divergence_fails_then_resolves(self) -> None:
        with LessonFixture() as fx:
            divergence = {"flags": [{"segment": 3, "adjudication": None}]}
            (fx.dir / "checks" / "divergence.json").write_text(json.dumps(divergence))
            hits = [v for v in fx.violations() if v.startswith("quiescence")]
            self.assertTrue(hits, fx.violations())
            divergence["flags"][0]["adjudication"] = "keep-stored"
            (fx.dir / "checks" / "divergence.json").write_text(json.dumps(divergence))
            non_glossary = [v for v in fx.violations()
                            if not v.startswith("glossary")]
            self.assertEqual(non_glossary, [])

    def test_glossary_scan_on_bulgarian_prose(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            lesson = Path(tmp) / "synthetic"
            (lesson / "checks").mkdir(parents=True)
            (lesson / "README.md").write_text("# Урок\n\nИзползвайте `main` тук.\n")
            (lesson / "README.bg.md").write_text("# Урок\n\nИзползвайте `main` тук.\n")
            (lesson / "checks" / "translation.json").write_text(json.dumps({
                "language": "bg",
                "tier": "mt-draft",
                "claimed_english_sha256": pipeline.sha256_text(
                    (lesson / "README.md").read_text()),
                "provenance": {},
            }))
            self.assertEqual(pipeline.check_lesson(lesson), [])
            (lesson / "README.bg.md").write_text("# Урок\n\nИзползвайте main тук.\n")
            hits = [v for v in pipeline.check_lesson(lesson)
                    if v.startswith("glossary")]
            self.assertTrue(hits)

    @staticmethod
    def write_bg_corrupted_fence(fx: LessonFixture) -> None:
        text = fx.bg_text()
        fence = text.index("```text\nash program.ash\n42 : Int\n```")
        corrupted = text[:fence] + "```text\nash program.ash\n43 : Int\n```" + text[fence:].replace(
            "```text\nash program.ash\n42 : Int\n```", "", 1)
        fx.write_bg(corrupted)


class FrontMatterTranslationTest(unittest.TestCase):
    lesson = pipeline.REPO_ROOT / "content" / "learn" / "using-more-than-one-input"

    @staticmethod
    def echo_mt(prompt: str) -> str:
        segments = prompt.split("## Segments\n\n")[1].strip().split("\n")
        body = "\n".join(line for line in segments if line.startswith("[bg-seg-"))
        return f"<<<BG-START>>>\n{body}\n<<<BG-END>>>"

    def test_identity_translate_round_trips_lesson3(self) -> None:
        source = (self.lesson / "README.md").read_text()
        with tempfile.TemporaryDirectory() as tmp:
            lesson = Path(tmp) / self.lesson.name
            shutil.copytree(self.lesson, lesson)
            (lesson / "README.bg.md").unlink(missing_ok=True)
            original = pipeline.run_mt
            pipeline.run_mt = self.echo_mt
            try:
                pipeline.cmd_translate(lesson)
            finally:
                pipeline.run_mt = original
            bg_text = (lesson / "README.bg.md").read_text()
            en_blocks, _, _, _ = pipeline.parse(source)
            bg_blocks, bg_blanks, bg_trailing, bg_nl = pipeline.parse(bg_text)
            self.assertEqual(en_blocks[0].lines, bg_blocks[0].lines)
            self.assertEqual(bg_text, pipeline.assemble(
                bg_blocks, bg_blanks, bg_trailing, bg_nl))

    def test_front_matter_structure_checked_values_free(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            lesson = Path(tmp) / "synthetic"
            (lesson / "checks").mkdir(parents=True)
            en = ("---\ndiagrams:\n  - kind: split\n    id: fig-one\n"
                  "    caption: Curried function.\n"
                  '    description: "The signature add : Int -> Int."\n---\n\n# Урок\n\nТекст.\n')
            (lesson / "README.md").write_text(en)
            (lesson / "README.bg.md").write_text(en.replace(
                "caption: Curried function.", 'caption: "Кърингната функция."'))
            (lesson / "checks" / "translation.json").write_text(json.dumps({
                "language": "bg", "tier": "mt-draft",
                "claimed_english_sha256": pipeline.sha256_text(en),
                "provenance": {}}))
            self.assertEqual(pipeline.check_lesson(lesson), [])
            (lesson / "README.bg.md").write_text(
                (lesson / "README.bg.md").read_text().replace(
                    "diagrams:", "diagrams-x:", 1))
            violations = pipeline.check_lesson(lesson)
            self.assertTrue(
                any(v.startswith("transplant: front matter") for v in violations),
                violations)


if __name__ == "__main__":
    unittest.main()
