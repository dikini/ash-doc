"""Exercise the presentation boundary using real indexed lesson sources."""

import json
import importlib.util
import os
import re
import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
QUARTO = ROOT / ".build/toolchain/quarto-1.10.19/bin/quarto"


def fences(text):
    return re.findall(r"^```[ \t]*(ash|text)\n(.*?)^```\s*$", text, re.M | re.S)


class PreparationTests(unittest.TestCase):
    def test_chapter_notes_keep_their_own_text_when_combined(self):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        os.environ.setdefault("XDG_CACHE_HOME", str(ROOT / ".build/toolchain/cache"))
        with tempfile.TemporaryDirectory() as temporary:
            builder.ROOT = Path(temporary)
            staged = []
            for name, note in (("first", "First supplementary note."),
                               ("second", "Second supplementary note.")):
                text = (f"# {name.title()} {{#topic-{name}}}\n\n"
                        f"A claim.[^source]\n\n[^source]: {note}\n\n"
                        "```text\nLiteral spelling [^1] stays unchanged.\n```\n\n"
                        f"::: {{#reminder-{name} .column-margin}}\n"
                        "A local reminder.\n:::\n")
                (builder.ROOT / f"{name}.md").write_text(text)
                prepared, _ = builder.prepare_chapter(
                    QUARTO, f"{name}.md", {}, "0" * 40, [])
                self.assertEqual(fences(text), fences(prepared))
                self.assertIn(f"{{#topic-{name}}}", prepared)
                self.assertIn(f"{{#reminder-{name} .column-margin}}", prepared)
                staged.append(prepared)
            document = builder.parse(QUARTO, "\n\n".join(staged))
            notes = [builder.literal(node["c"]) for node in builder.walk(document["blocks"])
                     if node.get("t") == "Note"]
            self.assertEqual(notes, ["First supplementary note.", "Second supplementary note."])

    def test_note_body_formatting_survives_namespacing(self):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        os.environ.setdefault("XDG_CACHE_HOME", str(ROOT / ".build/toolchain/cache"))
        text = ("# Topic {#topic}\n\nA claim.[^detail]\n\n"
                "[^detail]: **A qualification** uses `notation` and [the topic](#topic).\n\n"
                "    A second paragraph retains its place.\n\n"
                "    - A supporting example.\n"
                "    - A literal `[^1]` spelling.\n")
        original = builder.parse(QUARTO, text)
        expected = [node["c"] for node in builder.walk(original["blocks"])
                    if node.get("t") == "Note"]
        with tempfile.TemporaryDirectory() as temporary:
            builder.ROOT = Path(temporary)
            (builder.ROOT / "topic.md").write_text(text)
            prepared, _ = builder.prepare_chapter(QUARTO, "topic.md", {}, "0" * 40, [])
        actual = [node["c"] for node in builder.walk(builder.parse(QUARTO, prepared)["blocks"])
                  if node.get("t") == "Note"]
        self.assertEqual(actual, expected)

    def test_figure_wrapper_repair_preserves_the_image_description(self):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        repair = getattr(builder, "repair_figure_wrappers", None)
        self.assertTrue(callable(repair), "figure wrapper repair is missing")
        original = '<div class="quarto-float" alt="Description"><img alt="Description"></div>'
        expected = '<div class="quarto-float"><img alt="Description"></div>'
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary)
            (output / "chapter.html").write_text(original)
            with zipfile.ZipFile(output / "ash-doc-specimen.epub", "w") as archive:
                archive.writestr("EPUB/text/ch001.xhtml", original)
            repair(output)
            self.assertEqual((output / "chapter.html").read_text(), expected)
            with zipfile.ZipFile(output / "ash-doc-specimen.epub") as archive:
                self.assertEqual(archive.read("EPUB/text/ch001.xhtml").decode(), expected)

    def prepare(self, config=None):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        output = Path(temporary.name) / "book"
        args = ["python3", str(ROOT / "rendering/build.py"), "--prepare-only",
                "--quarto", str(QUARTO), "--output", str(output)]
        if config is not None:
            manifest = Path(temporary.name) / "specimen.json"
            manifest.write_text(json.dumps(config), encoding="utf-8")
            args.extend(["--specimen", str(manifest)])
        result = subprocess.run(args, cwd=ROOT, capture_output=True, text=True)
        return result, output

    def test_existing_code_and_diagnostic_text_survive_staging(self):
        result, output = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        records = json.loads((output / "sources.json").read_text())
        for record in records:
            if record["source"].startswith("content/"):
                original = (ROOT / record["source"]).read_text()
                staged = (output / record["chapter"]).read_text()
                self.assertEqual(fences(original), fences(staged), record["source"])
                self.assertNotIn("<!-- ash-source", staged)
                self.assertNotIn("<!-- ash-diagnostic", staged)

    def test_selected_lessons_follow_their_family_index(self):
        config = json.loads((ROOT / "rendering/specimen.json").read_text())
        config["sources"] = ["content/learn/using-another-source-file/README.md",
                             "content/learn/what-is-an-ash-program/README.md"]
        result, output = self.prepare(config)
        self.assertEqual(result.returncode, 0, result.stderr)
        records = json.loads((output / "sources.json").read_text())
        selected = [item["source"] for item in records
                    if item["source"].startswith("content/")]
        self.assertEqual(selected, list(reversed(config["sources"])))

    def test_internal_and_external_source_links_resolve(self):
        result, output = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        fixture = (output / "notation.md").read_text()
        self.assertIn("learn-what-is-an-ash-program.md", fixture)
        self.assertRegex(fixture, r"https://github.com/dikini/ash-doc/blob/[0-9a-f]{40}/docs/project/workflow.md")
        setup = (output / "setup.md").read_text()
        self.assertIn("## Read a diagnostic", setup)
        self.assertNotIn("## Working here", setup)

    def test_full_width_example_keeps_its_quarto_page_break(self):
        result, output = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        fixture = (output / "notation.md").read_text()
        self.assertIn("{{< pagebreak >}}\n\n## A full-width aside", fixture)

    def test_unindexed_project_source_cannot_enter_the_book_as_a_lesson(self):
        config = json.loads((ROOT / "rendering/specimen.json").read_text())
        config["sources"] = ["docs/README.md"]
        result, _ = self.prepare(config)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not an indexed lesson", result.stderr)


if __name__ == "__main__":
    unittest.main()
