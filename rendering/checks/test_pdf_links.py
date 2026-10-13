"""Check selected book links through the pinned Quarto and Typst tools."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET
import zipfile


ROOT = Path(__file__).resolve().parents[2]
QUARTO = ROOT / ".build/toolchain/quarto-1.10.19/bin/quarto"
FILTER = ROOT / "rendering/styles/book-links.lua"


class PdfBookLinksTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory(prefix="ash-doc-pdf-links-")
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.project = Path(cls.temporary.name)
        (cls.project / "styles").mkdir()
        shutil.copyfile(FILTER, cls.project / "styles/book-links.lua")
        # Avoid package imports while retaining Quarto's bundled book filters.
        (cls.project / "styles/typst-show.typ").write_text(
            "#let part(title) = heading(level: 1, numbering: none, title)\n"
            "#show heading.where(level: 1): it => {\n"
            "  pagebreak(weak: true)\n"
            "  it\n"
            "}\n", encoding="utf-8")
        chapters = {
            "index.md": (
                "# Root {#original-root}\n\n"
                "[Forward first](first.md), [Forward family](family.md), "
                "[Forward detail](last.md#original-detail).\n\n"
                "[External](https://example.test/reference.md#section).\n"),
            "first.md": (
                "# First chapter {#original-first}\n\n"
                "[Back root](index.md), [Forward last](last.md), "
                "[Forward part](family.md).\n"),
            "family.md": (
                "# Family *introduction* {#original-family}\n\n"
                "Part body. [Continue](last.md).\n\n"
                "```text\npart_example = 17\n```\n"),
            "last.md": (
                "# Last chapter {#original-last}\n\n"
                "[Back first](first.md), [Back family](family.md).\n\n"
                "## Detail {#original-detail}\n\nDetail body.\n"),
        }
        for name, text in chapters.items():
            (cls.project / name).write_text(text, encoding="utf-8")
        (cls.project / "sources.json").write_text(json.dumps([
            {"chapter": "first.md", "anchor": "original-first", "role": "lesson"},
            {"chapter": "family.md", "anchor": "original-family", "role": "introduction"},
            {"chapter": "last.md", "anchor": "original-last", "role": "lesson"},
        ]), encoding="utf-8")
        (cls.project / "_quarto.yml").write_text(json.dumps({
            "project": {"type": "book", "output-dir": "output"},
            "book": {"title": "PDF link probe", "output-file": "pdf-link-probe",
                     "chapters": ["index.md", "first.md",
                                  {"part": "family.md", "chapters": ["last.md"]}]},
            "number-sections": False,
            "execute": {"enabled": False},
            "format": {"epub": {
                "epub-version": 3,
                "filters": [{"path": "styles/book-links.lua", "at": "pre-quarto"}],
            }, "typst": {
                "keep-typ": True,
                "mainfont": "TeX Gyre Pagella",
                "monofont": "IBM Plex Mono",
                "template-partials": ["styles/typst-show.typ"],
                "filters": [{"path": "styles/book-links.lua", "at": "pre-quarto"}],
            }},
        }), encoding="utf-8")
        cls.environment = dict(os.environ, NO_COLOR="1", TERM="dumb",
                               SOURCE_DATE_EPOCH="0",
                               XDG_CACHE_HOME=str(cls.project / "cache"),
                               TYPST_FONT_PATHS=str(ROOT / "rendering/fonts"),
                               TYPST_IGNORE_SYSTEM_FONTS="true")
        cls.render = subprocess.run([str(QUARTO), "render", "--to", "typst"],
                                    cwd=cls.project, env=cls.environment, text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        generated = cls.project / "index.typ"
        if not generated.is_file():
            raise AssertionError(f"Quarto did not produce Typst source:\n{cls.render.stdout}")
        cls.typst = generated.read_text(encoding="utf-8")

    def test_epub_retains_part_title_body_code_and_navigation(self):
        result = subprocess.run([str(QUARTO), "render", "--to", "epub", "--no-clean"],
                                cwd=self.project, env=self.environment, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        self.assertEqual(result.returncode, 0, result.stdout)
        with zipfile.ZipFile(self.project / "output/pdf-link-probe.epub") as archive:
            documents = {name: ET.fromstring(archive.read(name))
                         for name in archive.namelist() if name.endswith(".xhtml")}
        matches = [(name, document) for name, document in documents.items()
                   if any(node.attrib.get("id") == "original-family"
                          for node in document.iter())]
        self.assertEqual(len(matches), 1, "EPUB dropped the file-backed part introduction")
        name, document = matches[0]
        self.assertIn("Part body.", "".join(document.itertext()))
        self.assertIn("part_example = 17", "".join(document.itertext()))
        headings = document.findall(".//{*}h1")
        self.assertIn("Family introduction", ["".join(node.itertext()) for node in headings])
        self.assertTrue(any(node.tag.endswith("em") for node in headings[0].iter()))
        links = [node.attrib["href"] for node in document.findall(".//{*}a")]
        self.assertTrue(any(target.endswith("#original-last") for target in links), links)
        nav_links = [node.attrib["href"] for node in documents["EPUB/nav.xhtml"].findall(".//{*}a")]
        self.assertIn(name.removeprefix("EPUB/") + "#original-family", nav_links)

    def test_chapter_links_resolve_forward_and_backward(self):
        for anchor, text in (("original-first", "Forward first"),
                             ("original-last", "Forward last"),
                             ("original-first", "Back first"),
                             ("original-root", "Back root")):
            with self.subTest(text=text):
                self.assertIn(f"#link(<{anchor}>)[{text}]", self.typst)
        self.assertNotIn('#link("first.md")', self.typst)
        self.assertNotIn('#link("last.md")', self.typst)

    def test_family_links_keep_the_original_anchor_on_the_part_heading(self):
        for text in ("Forward family", "Forward part", "Back family"):
            with self.subTest(text=text):
                self.assertIn(f"#link(<original-family>)[{text}]", self.typst)
        self.assertIn("#part[Family #emph[introduction]] <original-family>", self.typst)

    def test_fragments_and_external_urls_keep_their_destinations(self):
        self.assertIn("#link(<original-detail>)[Forward detail]", self.typst)
        self.assertIn(
            '#link("https://example.test/reference.md#section")[External]', self.typst)

    def test_pdf_compiles_with_links_to_the_intended_heading_pages(self):
        self.assertEqual(self.render.returncode, 0, self.render.stdout)
        pdf = self.project / "output/pdf-link-probe.pdf"
        self.assertTrue(pdf.read_bytes().startswith(b"%PDF-"))
        # Typst evaluates the same laid-out document used to compile the PDF.
        # A label on an unrelated element or before a part's page break fails
        # this check even if the document still compiles.
        expression = (
            "query(link).map(it => if type(it.dest) == label { "
            "let target = query(it.dest).first(); "
            "(destination: repr(it.dest), kind: repr(target.func()), "
            "page: target.location().position().page) "
            "} else { (destination: it.dest) })")
        result = subprocess.run([str(QUARTO), "typst", "eval", expression,
                                 "--in", "index.typ"], cwd=self.project,
                                env=self.environment, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        self.assertEqual(result.returncode, 0, result.stdout)
        destinations = json.loads(result.stdout)
        expected_pages = {"<original-root>": 1, "<original-first>": 2,
                          "<original-family>": 3, "<original-last>": 4,
                          "<original-detail>": 4}
        internal = [item for item in destinations if item["destination"] in expected_pages]
        self.assertEqual(len(internal), 9)
        for item in internal:
            with self.subTest(destination=item["destination"]):
                self.assertEqual(item["kind"], "heading")
                self.assertEqual(item["page"], expected_pages[item["destination"]])
        self.assertIn({"destination": "https://example.test/reference.md#section"},
                      destinations)


if __name__ == "__main__":
    unittest.main()
