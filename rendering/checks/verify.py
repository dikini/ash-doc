#!/usr/bin/env python3
"""Check source text, links, static assets, and PDF page/note geometry."""

import argparse
import json
import posixpath
import re
import subprocess
import xml.etree.ElementTree as ET
import zipfile
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit


class Html(HTMLParser):
    def __init__(self, source):
        super().__init__(convert_charrefs=True)
        self.ids, self.links, self.pre = set(), [], []
        self.current = None
        self.full_width, self.full_width_current = [], None
        self.full_width_depth = 0
        self.feed(source)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if tag == "div":
            if self.full_width_current is not None:
                self.full_width_depth += 1
            elif attrs.get("id") == "full-width-note":
                self.full_width_current = {"text": [], "tags": set()}
                self.full_width_depth = 1
        if self.full_width_current is not None:
            self.full_width_current["tags"].add(tag)
        if "id" in attrs:
            self.ids.add(attrs["id"])
        for name in ("href", "src"):
            if name in attrs:
                self.links.append(attrs[name])
        if tag == "pre":
            self.current = []

    def handle_data(self, data):
        if self.current is not None:
            self.current.append(data)
        if self.full_width_current is not None:
            self.full_width_current["text"].append(data)

    def handle_endtag(self, tag):
        if tag == "pre" and self.current is not None:
            self.pre.append("".join(self.current).removesuffix("\n"))
            self.current = None
        if tag == "div" and self.full_width_current is not None:
            self.full_width_depth -= 1
            if self.full_width_depth == 0:
                self.full_width.append({"text": "".join(self.full_width_current["text"]),
                                        "tags": self.full_width_current["tags"]})
                self.full_width_current = None


def check(condition, message):
    if not condition:
        raise ValueError(message)


def local_target(source, target):
    url = urlsplit(target)
    if url.scheme or url.netloc or not url.path and not url.fragment:
        return None
    return (posixpath.normpath(posixpath.join(posixpath.dirname(source), unquote(url.path)))
            if url.path else source), unquote(url.fragment)


def pdf_words(element):
    return element.findall(".//{*}word")


def pdf_text(element):
    return " ".join(word.text or "" for word in pdf_words(element))


def heading_text(text):
    return text.translate(str.maketrans({
        "\u2019": "'", "\u2018": "'", "\u201c": '"', "\u201d": '"',
    }))


def source_notes(project, records):
    """Read the fixture's complete note bodies and their reference sentences."""
    notes = []
    for record in records:
        source = (project / record["chapter"]).read_text()
        for definition in re.finditer(r"^\[\^([^\]]+)\]:[ \t]*(.*)(?:\n[ \t]+.*)*", source, re.M):
            identifier, first_line = definition.group(1), definition.group(2)
            continuation = [line.strip() for line in definition.group().splitlines()[1:]]
            body = " ".join([first_line] + continuation)
            marker = f"[^{identifier}]"
            before = source[:definition.start()]
            reference_position = before.find(marker)
            check(reference_position >= 0, f"{record['chapter']}: note {identifier} has no reference")
            paragraph_boundary = before.rfind("\n\n", 0, reference_position)
            paragraph_start = paragraph_boundary + 2 if paragraph_boundary >= 0 else 0
            reference = " ".join(before[paragraph_start:reference_position].split())
            notes.append({"body": body, "reference": reference})
    check(len(notes) == 2, "PDF fixture does not contain both complete source notes")
    return notes


def plain_inline(text):
    return " ".join(text.replace("*", "").replace("`", "").split())


def source_full_width(records):
    """Read this bounded formatting fixture from its canonical Markdown."""
    root = Path(__file__).resolve().parents[2]
    examples = []
    for record in records:
        source = (root / record["source"]).read_text()
        for match in re.finditer(r"^:::[ \t]+\{([^}\n]+)\}\n(.*?)\n:::[ \t]*$", source, re.M | re.S):
            attributes, content = match.group(1).split(), match.group(2)
            if "#full-width-note" not in attributes:
                continue
            check(".column-page-right" in attributes, "full-width note does not span body and outer notes")
            before_table, separator, table = content.partition("\n|")
            check(separator, "full-width note has no formatting table")
            paragraph = plain_inline(before_table)
            cells = []
            for line in ("|" + table).splitlines():
                if not line.startswith("|") or not line.endswith("|"):
                    continue
                row = [cell.strip() for cell in line[1:-1].split("|")]
                if all(re.fullmatch(r":?-+:?", cell) for cell in row):
                    continue
                cells.extend(plain_inline(cell) for cell in row)
            check(paragraph and cells, "full-width note has no complete paragraph/table text")
            examples.append({"paragraph": paragraph, "cells": cells})
    check(len(examples) == 1, "full-width formatting example not found exactly once in source")
    return examples[0]


def verify_full_width_markup(examples, expected, label):
    check(len(examples) == 1, f"{label}: full-width formatting example not found exactly once")
    example = examples[0]
    compact = re.sub(r"\s+", "", example["text"])
    for text in [expected["paragraph"]] + expected["cells"]:
        check(re.sub(r"\s+", "", text) in compact, f"{label}: full-width note loses text: {text}")
    check({"table", "em", "strong", "code"}.issubset(example["tags"]),
          f"{label}: full-width note loses table or inline formatting")


def find_pdf_phrase(pages, text):
    """Return exact word runs, retaining their page and actual geometry."""
    expected = text.split()
    found = []
    for page_number, page in enumerate(pages, 1):
        words = pdf_words(page)
        actual = [word.text or "" for word in words]
        for start in range(len(actual) - len(expected) + 1):
            if actual[start:start + len(expected)] == expected:
                found.append((page_number, words[start:start + len(expected)]))
    return found


def word_bounds(words):
    return {
        "left": min(float(word.attrib["xMin"]) for word in words),
        "right": max(float(word.attrib["xMax"]) for word in words),
        "top": min(float(word.attrib["yMin"]) for word in words),
        "bottom": max(float(word.attrib["yMax"]) for word in words),
    }


def verify_pdf(project, records, notes, full_width, filename, a4=False):
    path = project / "output" / filename
    check(path.is_file(), f"required PDF variant missing: {filename}")
    result = subprocess.run(["pdftotext", "-bbox-layout", str(path), "-"],
                            check=True, capture_output=True, text=True)
    pages = ET.fromstring(result.stdout).findall(".//{*}page")
    check(pages, f"{filename}: PDF has no pages")
    millimetre = 72 / 25.4
    width, height = (210 * millimetre, 297 * millimetre) if a4 else (576, 720)
    for number, page in enumerate(pages, 1):
        check(abs(float(page.attrib["width"]) - width) <= 0.01
              and abs(float(page.attrib["height"]) - height) <= 0.01,
              f"{filename}: page {number} has the wrong paper dimensions")
        for word in pdf_words(page):
            bounds = word_bounds([word])
            # Glyph bearings may slightly overhang their layout boxes.
            check(bounds["left"] >= -1 and bounds["right"] <= width + 1
                  and bounds["top"] >= -1 and bounds["bottom"] <= height + 1,
                  f"{filename}: page {number} puts text outside the paper: {word.text!r}")

    titles = ["Ash documentation", "Reader setup"]
    for record in records:
        heading = re.search(r"^# (.+)$", (project / record["chapter"]).read_text(), re.M)
        check(heading is not None, f"{record['chapter']}: chapter has no title")
        titles.append(heading.group(1))
    parities = set()
    for title in titles:
        headings = []
        for number, page in enumerate(pages, 1):
            for block in page.findall(".//{*}block"):
                words = pdf_words(block)
                matches_title = heading_text(pdf_text(block)) == heading_text(title)
                heading_size = (float(words[0].attrib["yMax"]) - float(words[0].attrib["yMin"])
                                if words else 0)
                if matches_title and heading_size >= 20:
                    headings.append((number, words[0]))
        check(len(headings) == 1, f"{filename}: chapter title not found exactly once: {title}")
        number, first_word = headings[0]
        expected_left = 25 * millimetre if a4 else (54 if number % 2 else 198)
        check(abs(float(first_word.attrib["xMin"]) - expected_left) <= 1,
              f"{filename}: page {number} has an incorrect body margin at {title!r}")
        parities.add(number % 2)
    check(parities == {0, 1}, f"{filename}: body margin check does not cover odd and even pages")

    note_regions = {}
    for note in notes:
        occurrences = find_pdf_phrase(pages, note["body"])
        references = find_pdf_phrase(pages, note["reference"])
        check(len(occurrences) == 1, f"{filename}: complete note body not found exactly once: {note['body']}")
        check(len(references) == 1, f"{filename}: note reference not found exactly once: {note['reference']}")
        number, words = occurrences[0]
        reference_number, reference_words = references[0]
        bounds = word_bounds(words)
        check(number == reference_number, f"{filename}: note detached from its reference page")
        if a4:
            check(bounds["left"] >= 140 * millimetre - 1
                  and bounds["right"] <= 190 * millimetre + 1,
                  f"{filename}: page {number} does not place its sidenote in the fixed right column")
        else:
            in_outer_margin = (bounds["left"] >= 396 - 1 and bounds["right"] <= 540 + 1
                               if number % 2 else bounds["left"] >= 36 - 1 and bounds["right"] <= 180 + 1)
            check(in_outer_margin, f"{filename}: page {number} does not place its note in the outer margin")
        check(abs(bounds["top"] - float(reference_words[-1].attrib["yMin"])) <= 48,
              f"{filename}: page {number} puts its margin note too far from the reference")
        for previous in note_regions.get(number, []):
            check(bounds["top"] >= previous["bottom"] or bounds["bottom"] <= previous["top"],
                  f"{filename}: page {number} has overlapping sidenotes")
        note_regions.setdefault(number, []).append(bounds)

    wide_paragraph = find_pdf_phrase(pages, full_width["paragraph"])
    check(len(wide_paragraph) == 1, f"{filename}: complete full-width paragraph not found exactly once")
    wide_page, wide_words = wide_paragraph[0]
    paragraph_bounds = word_bounds(wide_words)
    for cell in full_width["cells"]:
        occurrences = find_pdf_phrase(pages, cell)
        check(len(occurrences) == 1, f"{filename}: full-width table cell not found exactly once: {cell}")
        number, words = occurrences[0]
        check(number == wide_page, f"{filename}: full-width note/table breaks across pages")
        wide_words.extend(words)
    wide_bounds = word_bounds(wide_words)
    if a4:
        wide_left, wide_right = 25 * millimetre, 190 * millimetre
        extends_notes = paragraph_bounds["right"] > 140 * millimetre + 1
    elif wide_page % 2:
        wide_left, wide_right = 54, 540
        extends_notes = paragraph_bounds["right"] > 396 + 1
    else:
        wide_left, wide_right = 36, 522
        extends_notes = paragraph_bounds["left"] < 180 - 1
    check(abs(float(wide_paragraph[0][1][0].attrib["xMin"]) - wide_left) <= 1,
          f"{filename}: full-width note has the wrong starting margin")
    check(wide_bounds["left"] >= wide_left - 1 and wide_bounds["right"] <= wide_right + 1,
          f"{filename}: full-width note extends outside usable print margins")
    check(extends_notes, f"{filename}: full-width paragraph does not extend into the note area")
    for note in note_regions.get(wide_page, []):
        overlaps = (wide_bounds["left"] < note["right"] and wide_bounds["right"] > note["left"]
                    and wide_bounds["top"] < note["bottom"] and wide_bounds["bottom"] > note["top"])
        check(not overlaps, f"{filename}: full-width note overlaps a sidenote")

    result = subprocess.run(["pdftotext", "-layout", str(path), "-"],
                            check=True, capture_output=True, text=True)
    body = []
    for number, page in enumerate(result.stdout.split("\f"), 1):
        lines = page.splitlines()
        last = next((index for index in range(len(lines) - 1, -1, -1) if lines[index].strip()), None)
        if last is not None and lines[last].strip() == str(number):
            lines.pop(last)
        body.append("\n".join(lines))
    compact_pdf = re.sub(r"\s+", "", "\n".join(body))
    for record in records:
        for block in record["code"]:
            check(re.sub(r"\s+", "", block["text"]) in compact_pdf,
                  f"{filename}: {record['source']}: PDF loses code/transcript characters")
    return len(pages)


def verify(project):
    output = project / "output"
    check((output / "ash-doc-specimen-a4.pdf").is_file(),
          "required PDF variant missing: ash-doc-specimen-a4.pdf")
    records = json.loads((project / "sources.json").read_text())
    full_width = source_full_width(records)
    jobs = json.loads((project / "diagram-jobs.json").read_text())["diagrams"]
    pages = {path.name: Html(path.read_text()) for path in output.glob("*.html")}
    total = 0
    for record in records:
        page_name = Path(record["chapter"]).with_suffix(".html").name
        page = pages[page_name]
        expected = [block["text"] for block in record["code"]]
        check(page.pre == expected, f"{page_name}: rendered code/transcript differs from source")
        total += len(expected)
    for name, page in pages.items():
        for href in page.links:
            target = local_target(name, href)
            if target is None:
                continue
            path, anchor = target
            check((output / path).exists(), f"{name}: missing destination {href}")
            if anchor and path in pages:
                check(anchor in pages[path].ids, f"{name}: missing anchor {href}")
    verify_full_width_markup([example for page in pages.values() for example in page.full_width],
                             full_width, "HTML")

    with zipfile.ZipFile(output / "ash-doc-specimen.epub") as archive:
        xml = {name: ET.fromstring(archive.read(name)) for name in archive.namelist()
               if name.endswith((".xhtml", ".svg", ".opf"))}
        epub_ids = {name: {node.attrib["id"] for node in document.iter() if "id" in node.attrib}
                    for name, document in xml.items()}
        package = next(document for name, document in xml.items() if name.endswith(".opf"))
        check(package.attrib["version"] == "3.0", "EPUB is not EPUB 3")
        check("rendition:layout" not in archive.read("EPUB/content.opf").decode(), "EPUB unexpectedly fixes its layout")
        epub_pre = []
        epub_full_width = []
        notes = 0
        for name, document in xml.items():
            if not name.endswith(".xhtml"):
                continue
            for element in document.iter():
                tag = element.tag.rsplit("}", 1)[-1]
                if tag == "pre":
                    epub_pre.append("".join(element.itertext()).removesuffix("\n"))
                if element.attrib.get("id") == "full-width-note":
                    epub_full_width.append({"text": "".join(element.itertext()),
                                            "tags": {node.tag.rsplit("}", 1)[-1] for node in element.iter()}})
                if tag == "div":
                    check("alt" not in element.attrib, f"{name}: invalid alt attribute on div")
                if element.attrib.get("{http://www.idpf.org/2007/ops}type") == "noteref":
                    notes += 1
                for attribute in ("href", "src"):
                    if attribute not in element.attrib:
                        continue
                    target = local_target(name, element.attrib[attribute])
                    if target is None:
                        continue
                    path, anchor = target
                    check(path in archive.namelist(), f"{name}: missing EPUB destination {target}")
                    if anchor:
                        check(anchor in epub_ids.get(path, set()), f"{name}: missing EPUB anchor {target}")
        for record in records:
            for block in record["code"]:
                check(block["text"] in epub_pre, f"{record['source']}: EPUB loses source text")
        check(notes == 2, "EPUB does not contain both linked notes")
        verify_full_width_markup(epub_full_width, full_width, "EPUB")

    for job in jobs:
        svg = ET.parse(output / "assets" / (job["id"] + ".svg")).getroot()
        check("viewBox" in svg.attrib, f"{job['id']}: SVG has no viewport")
        descriptions = ["".join(node.itertext()) for node in svg if node.tag.endswith("}desc")]
        check(any(job["source"] in description for description in descriptions), f"{job['id']}: canonical notation missing")
        for node in svg.iter():
            check(node.tag.rsplit("}", 1)[-1] not in ("foreignObject", "script", "text"), f"{job['id']}: nonportable SVG element")
            for attribute, value in node.attrib.items():
                if attribute.rsplit("}", 1)[-1] == "href":
                    check(value.startswith("#"), f"{job['id']}: external SVG resource")

    notes = source_notes(project, records)
    book_pages = verify_pdf(project, records, notes, full_width, "ash-doc-specimen.pdf")
    a4_pages = verify_pdf(project, records, notes, full_width, "ash-doc-specimen-a4.pdf", a4=True)
    print(f"Verified {len(pages)} HTML pages, EPUB 3 links/notes, {len(jobs)} static diagrams, "
          f"and {total} complete code/transcript blocks in all formats; "
          f"book PDF {book_pages} pages and A4 PDF {a4_pages} pages with checked margins/notes.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", nargs="?", type=Path,
                        default=Path(__file__).resolve().parents[2] / ".build/specimen")
    try:
        verify(parser.parse_args().project.resolve())
    except (OSError, ValueError, KeyError, ET.ParseError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"verification: {error}") from error
