"""Scope boundaries must exclude unrelated sources and unrequested outputs."""

import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
QUARTO = ROOT / ".build/toolchain/quarto-1.10.19/bin/quarto"


def module(file):
    spec = importlib.util.spec_from_file_location(file.stem, file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


class SelectionTests(unittest.TestCase):
    def setUp(self):
        self.build = module(ROOT / "rendering/build.py")
        self.assertTrue(
            callable(getattr(self.build, "select_sources", None)),
            "scope selection is missing",
        )
        self.temp = tempfile.TemporaryDirectory(dir=ROOT / ".build")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.build.ROOT = self.root
        (self.root / "content/cases").mkdir(parents=True)
        (self.root / "content/README.md").write_text(
            "[Learn](learn/README.md)\n[Cases](cases/README.md)\n"
        )
        # The unrelated Learn index deliberately does not exist.
        (self.root / "content/cases/README.md").write_text(
            "# Cases\n\n[Second](second/README.md)\n[First](first/README.md)\n"
        )
        for name in ("first", "second", "draft"):
            path = self.root / f"content/cases/{name}/README.md"
            path.parent.mkdir()
            path.write_text("# " + name + "\n")
        self.config = {"sources": [], "fixtures": []}
        self.args = SimpleNamespace(
            quarto=QUARTO, lesson=None, part=None, whole_book=False
        )

    def select(self):
        return self.build.select_sources(self.args, self.config)

    def test_lesson_reads_only_its_family_index(self):
        self.args.lesson = Path("content/cases/first/README.md")
        result = self.select()
        self.assertEqual(result["sources"], ["content/cases/first/README.md"])
        self.assertEqual(result["parts"], [])
        self.assertEqual(result["mode"], "lesson")

    def test_lesson_does_not_check_an_unselected_lesson_file(self):
        self.args.lesson = Path("content/cases/first/README.md")
        (self.root / "content/cases/second/README.md").unlink()
        self.assertEqual(self.select()["sources"], ["content/cases/first/README.md"])

    def test_specimen_does_not_check_unselected_siblings(self):
        self.config["sources"] = ["content/cases/first/README.md"]
        (self.root / "content/cases/second/README.md").unlink()
        self.assertEqual(self.select()["sources"], self.config["sources"])

    def test_empty_part_is_rejected(self):
        self.args.part = "cases"
        (self.root / "content/cases/README.md").write_text("# Cases\n")
        with self.assertRaisesRegex(ValueError, "no indexed lessons"):
            self.select()

    def test_output_directory_cannot_overwrite_another_scope(self):
        self.args.lesson = Path("content/cases/first/README.md")
        self.args.output = self.root / "prepared"
        self.args.output.mkdir()
        (self.args.output / ".ash-doc-rendering").write_text("generated")
        (self.args.output / "build.json").write_text(
            json.dumps(
                {"mode": "lesson", "selection": "content/cases/second/README.md"}
            )
        )
        config = {"quarto_version": "test", "ash_commit": "a" * 40}
        self.args.specimen = self.root / "specimen.json"
        self.args.specimen.write_text(json.dumps(config))
        (self.root / "README.md").write_text(config["ash_commit"])
        selection = self.select()
        with (
            patch.object(self.build, "select_sources", return_value=selection),
            patch.object(
                self.build,
                "run",
                side_effect=[
                    SimpleNamespace(stdout="test"),
                    SimpleNamespace(stdout="b" * 40),
                ],
            ),
        ):
            with self.assertRaisesRegex(ValueError, "another build scope"):
                self.build.prepare(self.args)
        self.assertFalse((self.args.output / "index.md").exists())

    def test_part_retains_intro_and_index_order_without_other_parts(self):
        self.args.part = "cases"
        result = self.select()
        self.assertEqual(
            result["sources"],
            [
                "content/cases/README.md",
                "content/cases/second/README.md",
                "content/cases/first/README.md",
            ],
        )
        self.assertEqual(
            result["parts"][0]["chapters"], ["cases-second.md", "cases-first.md"]
        )
        self.assertEqual(result["mode"], "part")

    def test_unindexed_lesson_is_rejected(self):
        self.args.lesson = Path("content/cases/draft/README.md")
        with self.assertRaisesRegex(ValueError, "indexed lesson"):
            self.select()

    def test_outside_repository_input_is_rejected(self):
        self.args.lesson = self.root.parent / "outside/README.md"
        with self.assertRaises(ValueError):
            self.select()

    def test_conflicting_scope_is_rejected(self):
        self.args.lesson = Path("content/cases/first/README.md")
        self.args.part = "cases"
        with self.assertRaisesRegex(ValueError, "scope"):
            self.select()


class FormatTests(unittest.TestCase):
    def setUp(self):
        self.build = module(ROOT / "rendering/build.py")
        self.assertTrue(
            callable(getattr(self.build, "render_formats", None)),
            "format dispatch is missing",
        )

    def test_pdf_pair_does_not_render_html_or_epub(self):
        args = SimpleNamespace(quarto=Path("/quarto"), output=Path("/book"))

        def run(command, **kwargs):
            (args.output / "index.typ").write_text("compiled source")

        with tempfile.TemporaryDirectory() as directory:
            args.output = Path(directory)
            with patch.object(self.build, "run", side_effect=run) as calls:
                self.build.render_formats(args, ["pdf", "pdf-a4"], {}, "example")
            self.assertEqual(len(calls.call_args_list), 2)
            commands = [c.args[0] for c in calls.call_args_list]
            self.assertEqual(commands[0][commands[0].index("--to") + 1], "typst")
            self.assertNotIn("--profile", commands[0])
            self.assertIn("a4", commands[1])
            self.assertTrue((args.output / "example.typ").is_file())
            self.assertTrue((args.output / "example-a4.typ").is_file())

    def test_html_only_dispatches_one_render(self):
        args = SimpleNamespace(quarto=Path("/quarto"), output=Path("/book"))
        with patch.object(self.build, "run") as calls:
            self.build.render_formats(args, ["html"], {}, "example")
        self.assertEqual(len(calls.call_args_list), 1)
        self.assertIn("html", calls.call_args.args[0])
        self.assertNotIn("all", calls.call_args.args[0])

    def test_repair_works_when_epub_is_not_requested(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            page = output / "index.html"
            page.write_text('<div class="quarto-float" alt="wrong"></div>')
            self.build.repair_figure_wrappers(output, "example")
            self.assertNotIn("alt=", page.read_text())

    def test_html_only_repair_does_not_open_existing_epub(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            (output / "example.epub").write_bytes(b"unrequested prior output")
            page = output / "index.html"
            page.write_text('<div class="quarto-float" alt="wrong"></div>')
            self.build.repair_figure_wrappers(output, "example", ["html"])
            self.assertNotIn("alt=", page.read_text())
            self.assertEqual(
                (output / "example.epub").read_bytes(), b"unrequested prior output"
            )

    def test_pdf_only_repair_does_not_modify_prior_html(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            page = output / "index.html"
            original = '<div class="quarto-float" alt="wrong"></div>'
            page.write_text(original)
            self.build.repair_figure_wrappers(output, "example", ["pdf"])
            self.assertEqual(page.read_text(), original)


class IdentityTests(unittest.TestCase):
    def setUp(self):
        self.verify = module(ROOT / "rendering/checks/verify.py")
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "rendering").mkdir()
        (self.root / "rendering/specimen.json").write_text(
            json.dumps({"ash_commit": "a" * 40})
        )
        (self.root / "content/cases/first").mkdir(parents=True)
        (self.root / "content/cases/README.md").write_text(
            "# Cases\n[First](first/README.md)\n"
        )
        source = self.root / "content/cases/first/README.md"
        source.write_text("# First\n")
        import hashlib

        self.records = [
            {
                "source": "content/cases/first/README.md",
                "chapter": "cases-first.md",
                "role": "lesson",
                "family": "cases",
                "sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            }
        ]
        self.metadata = {
            "mode": "lesson",
            "selection": "content/cases/first/README.md",
            "formats": ["pdf", "pdf-a4"],
            "output_file": "ash-doc-cases-first",
            "title": "First",
            "ash_commit": "a" * 40,
            "source_commit": "b" * 40,
            "parts": [],
            "lesson_count": 1,
            "chapters": ["index.md", "setup.md", "cases-first.md"],
        }

    def test_lesson_identity_requires_no_other_family_indexes(self):
        self.assertEqual(
            self.verify.verify_build_metadata(self.metadata, self.records, self.root),
            "ash-doc-cases-first",
        )

    def test_lesson_identity_cannot_claim_another_selection(self):
        self.metadata["selection"] = "content/cases/other/README.md"
        self.metadata["output_file"] = "ash-doc-cases-other"
        with self.assertRaisesRegex(ValueError, "indexed|selection"):
            self.verify.verify_build_metadata(self.metadata, self.records, self.root)

    def test_invalid_format_record_is_rejected(self):
        self.metadata["formats"] = ["pdf", "pdf"]
        with self.assertRaisesRegex(ValueError, "format"):
            self.verify.verify_build_metadata(self.metadata, self.records, self.root)

    def test_part_identity_retains_its_intro_and_complete_index_order(self):
        import hashlib

        intro = self.root / "content/cases/README.md"
        record = {
            "source": "content/cases/README.md",
            "chapter": "cases-introduction.md",
            "role": "introduction",
            "family": "cases",
            "sha256": hashlib.sha256(intro.read_bytes()).hexdigest(),
        }
        records = [record, *self.records]
        self.metadata.update(
            mode="part",
            selection="cases",
            output_file="ash-doc-cases",
            chapters=[
                "index.md",
                "setup.md",
                "cases-introduction.md",
                "cases-first.md",
            ],
            parts=[
                {
                    "family": "cases",
                    "introduction": "cases-introduction.md",
                    "chapters": ["cases-first.md"],
                }
            ],
        )
        self.assertEqual(
            self.verify.verify_build_metadata(self.metadata, records, self.root),
            "ash-doc-cases",
        )
        self.metadata["chapters"].remove("cases-introduction.md")
        with self.assertRaisesRegex(ValueError, "complete indexed"):
            self.verify.verify_build_metadata(self.metadata, self.records, self.root)

    def test_pdf_only_verification_does_not_require_html_epub_or_search_tree(self):
        project = self.root / "prepared"
        output = project / "output"
        output.mkdir(parents=True)
        (project / "build.json").write_text(json.dumps(self.metadata))
        self.records[0].update(title="First", anchor="first", code=[], assets=[])
        (project / "sources.json").write_text(json.dumps(self.records))
        (project / "diagram-jobs.json").write_text(json.dumps({"diagrams": []}))
        for suffix in (".pdf", "-a4.pdf"):
            (output / (self.metadata["output_file"] + suffix)).write_bytes(
                b"checked by PDF parser"
            )
        original = self.verify.verify_build_metadata
        with (
            patch.object(
                self.verify,
                "verify_build_metadata",
                side_effect=lambda metadata, records: original(
                    metadata, records, self.root
                ),
            ),
            patch.object(self.verify, "verify_pdf", return_value=1) as calls,
        ):
            self.verify.verify(project)
        self.assertEqual(calls.call_count, 2)


if __name__ == "__main__":
    unittest.main()
