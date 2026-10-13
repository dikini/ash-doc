"""Exercise the presentation boundary using real indexed lesson sources."""

import json
import hashlib
import importlib.util
import os
import re
import subprocess
import tempfile
import unittest
import zipfile
from contextlib import contextmanager
from pathlib import Path
from types import SimpleNamespace


ROOT = Path(__file__).resolve().parents[2]
QUARTO = ROOT / ".build/toolchain/quarto-1.10.19/bin/quarto"


def fences(text):
    return re.findall(r"^```[ \t]*(ash|text)\n(.*?)^```\s*$", text, re.M | re.S)


class PreparationTests(unittest.TestCase):
    @contextmanager
    def asset_book(self, chapters, images):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        os.environ.setdefault("XDG_CACHE_HOME", str(ROOT / ".build/toolchain/cache"))
        with tempfile.TemporaryDirectory(dir=ROOT / ".build") as temporary:
            root = Path(temporary)
            builder.ROOT = root
            (root / "content/cases").mkdir(parents=True)
            (root / "rendering/styles").mkdir(parents=True)
            (root / "rendering/fonts").mkdir(parents=True)
            config = json.loads((ROOT / "rendering/specimen.json").read_text())
            config["sources"] = list(chapters)
            config["fixtures"] = []
            (root / "specimen.json").write_text(json.dumps(config))
            (root / "README.md").write_text(config["ash_commit"])
            (root / "content/README.md").write_text("[Cases](cases/README.md)\n")
            (root / "content/cases/README.md").write_text("\n".join(
                f"[Lesson]({Path(source).parent.name}/README.md)" for source in chapters))
            for source, text in chapters.items():
                (root / source).parent.mkdir(parents=True, exist_ok=True)
                (root / source).write_text(text)
            for path, data in images.items():
                (root / path).parent.mkdir(parents=True, exist_ok=True)
                (root / path).write_bytes(data)
            args = SimpleNamespace(quarto=QUARTO, specimen=root / "specimen.json",
                                   output=root / "book")
            yield builder, root, args

    def test_wide_code_keeps_source_records_in_reading_order(self):
        source = "content/cases/example/README.md"
        before = "identity : Int -> Int\nidentity value = value"
        wide = ("combine : Tree<Key, Value> -> Key -> Value -> Tree<Key, Value>\n"
                "combine tree key value = {\n"
                "    restore tree key value\n"
                "}")
        after = "The result remains Tree<Key, Value>."
        text = (f"# Lesson\n\n```ash\n{before}\n```\n\n"
                "::: {#wide-definition .column-page-right}\n\n"
                f"```text\n{wide}\n```\n\n:::\n\n"
                f"```text\n{after}\n```\n")
        with self.asset_book({source: text}, {}) as (builder, root, args):
            builder.prepare(args)
            record = json.loads((args.output / "sources.json").read_text())[0]
            self.assertEqual(record["code"], [
                {"kind": "ash", "text": before},
                {"kind": "text", "text": wide},
                {"kind": "text", "text": after},
            ])
            original = builder.parse(QUARTO, text)
            staged = (args.output / record["chapter"]).read_text()
            prepared = builder.parse(QUARTO, staged)
            self.assertEqual(prepared["blocks"], original["blocks"],
                             "wide attributes and literal code must survive staging")
            self.assertEqual((root / source).read_text(), text)

    def test_lesson_images_keep_note_and_wide_structure_with_exact_assets(self):
        source = "content/cases/example/README.md"
        svg = (b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 40">'
               b'<title>A useful sketch</title><desc>A relation between values.</desc>'
               b'<path d="M 10 20 L 70 20" stroke="black"/></svg>')
        image = ('![A useful sketch.](assets/relation.svg)'
                 '{#fig-relation fig-alt="A relation between values." width=100%}')
        text = ("# Lesson {#lesson}\n\nA specific claim.[^detail]\n\n"
                f"[^detail]: Optional detail.\n\n    {image}\n\n"
                "::: {#counting-cue .column-margin}\nA local reminder.\n"
                f"{image}\n:::\n\n"
                f"::: {{#wide-comparison .column-page-right}}\n{image}\n:::\n\n"
                "```text\nLiteral assets/relation.svg stays unchanged.\n```\n")
        asset_path = "content/cases/example/assets/relation.svg"
        with self.asset_book({source: text}, {asset_path: svg}) as (builder, root, args):
            builder.prepare(args)
            records = json.loads((args.output / "sources.json").read_text())
            staged = (args.output / records[0]["chapter"]).read_text()
            original = builder.parse(QUARTO, text)
            prepared = builder.parse(QUARTO, staged)
            expected_images = [node for node in builder.walk(original["blocks"])
                               if node.get("t") == "Image"]
            actual_images = [node for node in builder.walk(prepared["blocks"])
                             if node.get("t") == "Image"]
            self.assertEqual(len(actual_images), 3)
            for original_image, staged_image in zip(expected_images, actual_images):
                self.assertNotEqual(staged_image["c"][2][0], "assets/relation.svg",
                                    "canonical lesson images need a distinct staged path")
                self.assertEqual(staged_image["c"][:2], original_image["c"][:2])
                original_image["c"][2][0] = staged_image["c"][2][0]
            # The existing --wrap=none writer joins soft paragraph line breaks.
            for node in builder.walk(original["blocks"]):
                if node.get("t") == "SoftBreak":
                    node["t"] = "Space"
            self.assertEqual(original["blocks"], prepared["blocks"])
            self.assertEqual(fences(text), fences(staged))
            self.assertEqual((root / source).read_text(), text)
            self.assertEqual((root / asset_path).read_bytes(), svg)
            assets = records[0]["assets"]
            self.assertEqual(len(assets), 1, "repeated use records one canonical asset")
            self.assertEqual(assets[0]["source"], asset_path)
            self.assertEqual(assets[0]["sha256"], hashlib.sha256(svg).hexdigest())
            self.assertEqual(assets[0]["staged"], actual_images[0]["c"][2][0])
            self.assertEqual((args.output / assets[0]["staged"]).read_bytes(), svg)

    def test_distinct_lesson_assets_with_the_same_basename_do_not_collide(self):
        chapters, images = {}, {}
        for name, endpoint in (("first", 10), ("second", 20)):
            source = f"content/cases/{name}/README.md"
            chapters[source] = (f"# {name.title()}\n\n"
                                '![A relation.](assets/relation.svg){fig-alt="A relation."}\n')
            images[f"content/cases/{name}/assets/relation.svg"] = (
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 40">'
                f'<path d="M 0 0 L {endpoint} 0"/></svg>').encode()
        with self.asset_book(chapters, images) as (builder, root, args):
            builder.prepare(args)
            records = json.loads((args.output / "sources.json").read_text())
            staged_images = []
            for record in records:
                prepared = builder.parse(QUARTO, (args.output / record["chapter"]).read_text())
                node = next(node for node in builder.walk(prepared["blocks"])
                            if node.get("t") == "Image")
                staged_images.append(node["c"][2][0])
            self.assertEqual(len(set(staged_images)), 2,
                             "same-basename images from different lessons need separate paths")
            for record in records:
                asset = record["assets"][0]
                self.assertEqual((args.output / asset["staged"]).read_bytes(),
                                 (root / asset["source"]).read_bytes())

    def test_unsuitable_lesson_image_sources_fail_preparation(self):
        source = "content/cases/example/README.md"
        svg = b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><path d="M0 0"/></svg>'
        cases = ["assets/missing.svg", "../other.svg", "/absolute.svg",
                 "https://example.test/figure.svg", "//example.test/figure.svg",
                 "assets/relation.svg?download=1", "assets/relation.svg#part",
                 "assets/relation.png"]
        for target in cases:
            with self.subTest(target=target):
                text = f"# Lesson\n\n![A relation.]({target}){{fig-alt=\"A relation.\"}}\n"
                images = {"content/cases/example/assets/relation.svg": svg,
                          "content/cases/other.svg": svg,
                          "content/cases/example/assets/relation.png": svg}
                with self.asset_book({source: text}, images) as (builder, root, args):
                    with self.assertRaisesRegex(ValueError, "image|SVG"):
                        builder.prepare(args)

    def test_a_symlink_cannot_stage_an_asset_from_outside_its_lesson(self):
        source = "content/cases/example/README.md"
        text = '# Lesson\n\n![A relation.](assets/relation.svg){fig-alt="A relation."}\n'
        svg = b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><path d="M0 0"/></svg>'
        with self.asset_book({source: text}, {"content/cases/other.svg": svg}) as (builder, root, args):
            asset = root / "content/cases/example/assets/relation.svg"
            asset.parent.mkdir()
            asset.symlink_to(root / "content/cases/other.svg")
            with self.assertRaisesRegex(ValueError, "image|SVG"):
                builder.prepare(args)

    def test_nonportable_svg_content_fails_preparation(self):
        source = "content/cases/example/README.md"
        text = '# Lesson\n\n![A relation.](assets/relation.svg){fig-alt="A relation."}\n'
        cases = [
            '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0"/></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 NaN 10"/>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 -1"/>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><text>A label</text></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><script/></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><foreignObject/></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10" onload="doWork()"/>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><image href="https://example.test/a.svg"/></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><path style="fill:url(https://example.test/a.svg)"/></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><style>@import "external.css";</style></svg>',
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><style>path{fill:u\\72l(https://example.test/a.svg)}</style></svg>',
        ]
        for svg in cases:
            with self.subTest(svg=svg):
                with self.asset_book({source: text}, {
                        "content/cases/example/assets/relation.svg": svg.encode()}) as (builder, root, args):
                    with self.assertRaisesRegex(ValueError, "SVG"):
                        builder.prepare(args)

    def test_svg_internal_links_cannot_inherit_an_external_base(self):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        svg = (b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10" '
               b'xml:base="https://example.test/figure.svg">'
               b'<use href="#shape"/></svg>')
        with self.assertRaisesRegex(ValueError, "SVG"):
            builder.validate_source_svg(svg, "assets/relation.svg")

    def test_css_line_continuations_cannot_hide_an_external_resource(self):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        svg = (b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">'
               b'<style>path{fill:url("https://example.test/\\\nasset.svg")}</style></svg>')
        with self.assertRaisesRegex(ValueError, "SVG"):
            builder.validate_source_svg(svg, "assets/relation.svg")

    def test_xml_stylesheet_processing_instruction_is_rejected(self):
        spec = importlib.util.spec_from_file_location("render_build", ROOT / "rendering/build.py")
        builder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(builder)
        svg = b'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><path d="M0 0"/></svg>'
        builder.validate_source_svg(b'<?xml version="1.0"?>' + svg, "assets/relation.svg")
        stylesheet = b'<?xml-stylesheet type="text/css" href="https://example.test/external.css"?>'
        with self.assertRaisesRegex(ValueError, "SVG"):
            builder.validate_source_svg(stylesheet + svg, "assets/relation.svg")

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
