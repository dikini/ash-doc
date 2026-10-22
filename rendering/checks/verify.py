#!/usr/bin/env python3
"""Check source text, links, static assets, and PDF page/note geometry."""

import argparse
import hashlib
import json
import os
import posixpath
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
import zipfile
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[2]
BOOK_FAMILIES = ("learn", "libraries", "effects", "cases")
FORMATS = ("html", "epub", "pdf", "pdf-a4")


class Html(HTMLParser):
    def __init__(self, source):
        super().__init__(convert_charrefs=True)
        self.ids, self.links, self.pre = set(), [], []
        self.current = None
        self.headings, self.heading_current = [], None
        self.images = []
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
        if tag == "img":
            self.images.append(attrs)
        for name in ("href", "src"):
            if name in attrs:
                self.links.append(attrs[name])
        if tag == "pre":
            self.current = []
        if tag == "h1":
            self.heading_current = []

    def handle_data(self, data):
        if self.current is not None:
            self.current.append(data)
        if self.heading_current is not None:
            self.heading_current.append(data)
        if self.full_width_current is not None:
            self.full_width_current["text"].append(data)

    def handle_endtag(self, tag):
        if tag == "pre" and self.current is not None:
            self.pre.append("".join(self.current).removesuffix("\n"))
            self.current = None
        if tag == "h1" and self.heading_current is not None:
            self.headings.append(" ".join("".join(self.heading_current).split()))
            self.heading_current = None
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


def indexed_lessons(root, family):
    """Read direct lesson links from the family index, independently of build records."""
    directory = root / "content" / family
    lessons = []
    for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", (directory / "README.md").read_text()):
        url = urlsplit(target)
        if url.scheme or url.netloc or not url.path:
            continue
        path = (directory / unquote(url.path)).resolve()
        if path.parent.parent == directory and path.name == "README.md":
            source = path.relative_to(root).as_posix()
            if source not in lessons:
                lessons.append(source)
    check(lessons, f"{family}: family index has no lessons")
    return lessons


def verify_diagram_sources(jobs, records):
    sources = {record["source"] for record in records}
    for job in jobs:
        check(job["path"] in sources, f"diagram {job['id']}: no recorded source for {job['path']}")


def verify_build_metadata(metadata, records, root=ROOT):
    """Check generated identity against canonical indexes and exact source digests."""
    mode = metadata["mode"]
    check(mode in ("book", "specimen", "lesson", "part"), f"unknown build mode: {mode}")
    formats = metadata.get("formats", list(FORMATS))
    check(isinstance(formats, list) and formats
          and all(isinstance(value, str) and value in FORMATS for value in formats)
          and len(set(formats)) == len(formats), "invalid requested formats")
    selection = metadata.get("selection")
    if mode == "lesson":
        path = Path(selection or "")
        lang = metadata.get("lang", "en")
        chapter_readme = "README.md" if lang == "en" else f"README.{lang}.md"
        check(len(path.parts) == 4 and path.parts[0] == "content"
              and path.parts[1] in BOOK_FAMILIES and path.name == chapter_readme,
              "lesson selection must name an indexed lesson")
        families = (path.parts[1],)
        expected_basename = f"ash-doc-{path.parts[1]}-{path.parts[2]}"
        if lang != "en":
            expected_basename += f"-{lang}"
    elif mode == "part":
        check(selection in BOOK_FAMILIES, "part selection is not an indexed family")
        families = (selection,)
        expected_basename = f"ash-doc-{selection}"
    else:
        families = BOOK_FAMILIES
        expected_basename = "ash-doc-review" if mode == "book" else "ash-doc-specimen"
    basename = metadata["output_file"]
    check(basename == expected_basename, f"output basename does not match {mode} mode")
    check(isinstance(metadata["title"], str) and metadata["title"].strip(), "build has no title")
    config = json.loads((root / "rendering/specimen.json").read_text())
    check(metadata["ash_commit"] == config["ash_commit"], "build Ash target differs from the pinned edition")
    check(isinstance(metadata["source_commit"], str) and
          re.fullmatch(r"[0-9a-f]{40}", metadata["source_commit"]), "build source commit is not exact")
    sources = [record["source"] for record in records]
    chapters = [record["chapter"] for record in records]
    check(len(set(sources)) == len(sources), "duplicate source records")
    check(len(set(chapters)) == len(chapters), "duplicate chapter records")
    check(metadata["chapters"] == ["index.md", "setup.md"] + chapters,
          "build chapter order differs from source records")
    if mode == "specimen":
        families = tuple(family for family in BOOK_FAMILIES
                         if any(Path(source).parts[1] == family for source in config["sources"]))
    lessons = {family: indexed_lessons(root, family) for family in families}
    if mode in ("book", "part"):
        expected_sources = [source for family in families
                            for source in [f"content/{family}/README.md"] + lessons[family]]
        check(sources == expected_sources, "book sources differ from complete indexed reading order")
        for record in records:
            family = Path(record["source"]).parts[1]
            role = "introduction" if record["source"] == f"content/{family}/README.md" else "lesson"
            check(record.get("role") == role, f"{record['source']}: role must be {role}")
            check(record.get("family") == family, f"{record['source']}: incorrect source family")
        expected_parts = [{"family": family,
                           "introduction": records[sources.index(f"content/{family}/README.md")]["chapter"],
                           "chapters": [records[sources.index(source)]["chapter"] for source in lessons[family]]}
                          for family in families]
        check(metadata["parts"] == expected_parts, "book part introductions/chapters differ from indexed sources")
        expected_count = sum(len(sources) for sources in lessons.values())
    elif mode == "lesson":
        selected = Path(selection).with_name("README.md").as_posix()
        check(selected in lessons[families[0]], "lesson selection is not an indexed lesson")
        check(sources == [selection], "lesson records differ from their selection")
        check(records[0].get("role") == "lesson" and records[0].get("family") == families[0],
              "lesson record has incorrect role or family")
        check(metadata["parts"] == [], "lesson unexpectedly contains book parts")
        expected_count = 1
    else:
        selected = set(config["sources"])
        family_order = []
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", (root / "content/README.md").read_text()):
            path = (root / "content" / urlsplit(target).path).resolve()
            if path.parent.name in lessons and path.name == "README.md" and path.parent.name not in family_order:
                family_order.append(path.parent.name)
        expected_sources = [source for family in family_order for source in lessons[family]
                            if source in selected] + config["fixtures"]
        check(sources == expected_sources, "specimen sources differ from indexed selection and fixtures")
        for record in records:
            role = "lesson" if record["source"] in selected else "fixture"
            check(record.get("role") == role, f"{record['source']}: role must be {role}")
        check(metadata["parts"] == [], "specimen unexpectedly contains book parts")
        expected_count = len(selected)
    check(metadata["lesson_count"] == expected_count, "reported lesson count differs from indexed coverage")
    for record in records:
        source = root / record["source"]
        check(source.is_file(), f"canonical source missing: {record['source']}")
        check(hashlib.sha256(source.read_bytes()).hexdigest() == record["sha256"],
              f"{record['source']}: canonical source differs from its recorded digest")
    return basename


def verify_epub_chapters(xml, package_name, records):
    """Associate chapters through spine, source heading and TOC before exact code comparison."""
    package = xml[package_name]
    manifest = {item.attrib["id"]: item for item in package.findall(".//{*}manifest/{*}item")}
    destinations = {identifier: local_target(package_name, item.attrib["href"])[0]
                    for identifier, item in manifest.items()}
    spine = []
    for item in package.findall(".//{*}spine/{*}itemref"):
        identifier = item.attrib["idref"]
        check(identifier in destinations, f"EPUB: missing spine item {identifier}")
        if item.attrib.get("linear", "yes") == "no":
            continue
        name = destinations[identifier]
        check(name in xml, f"EPUB: missing spine document {name}")
        spine.append(name)
    check(len(set(spine)) == len(spine), "EPUB: duplicate spine documents")
    nav_names = [destinations[identifier] for identifier, item in manifest.items()
                 if "nav" in item.attrib.get("properties", "").split()]
    check(len(nav_names) == 1 and nav_names[0] in xml, "EPUB: missing unique navigation document")
    nav_name = nav_names[0]
    toc_nodes = [node for node in xml[nav_name].iter()
                 if node.tag.rsplit("}", 1)[-1] == "nav" and
                 "toc" in node.attrib.get("{http://www.idpf.org/2007/ops}type", "").split()]
    check(len(toc_nodes) == 1, "EPUB: missing unique navigation TOC")

    def title(node):
        return heading_text(" ".join("".join(node.itertext()).split()))

    associated, previous = {}, -1
    for record in records:
        expected_title = heading_text(" ".join(record["title"].split()))
        candidates = [(number, name) for number, name in enumerate(spine)
                      for node in xml[name].iter()
                      if node.tag.rsplit("}", 1)[-1] == "h1" and title(node) == expected_title]
        check(len(candidates) == 1, f"EPUB: source chapter heading is not unique: {record['source']}")
        number, name = candidates[0]
        check(number > previous, f"EPUB: spine source chapter order differs at {record['source']}")
        previous = number
        document = xml[name]
        anchor = record["anchor"]
        check(any(node.attrib.get("id") == anchor for node in document.iter()),
              f"EPUB: source chapter anchor missing: {record['source']}")
        links = [node for node in toc_nodes[0].iter()
                 if node.tag.rsplit("}", 1)[-1] == "a" and
                 local_target(nav_name, node.attrib.get("href", "")) == (name, anchor) and
                 title(node) == expected_title]
        check(len(links) == 1, f"EPUB: navigation does not identify source chapter: {record['source']}")
        actual = ["".join(node.itertext()).removesuffix("\n") for node in document.iter()
                  if node.tag.rsplit("}", 1)[-1] == "pre"]
        check(actual == [block["text"] for block in record["code"]],
              f"{record['source']}: EPUB rendered code/transcript differs from its source chapter")
        associated[record["source"]] = (name, document)
    return associated


def source_notes(project, records):
    """Read the fixture's complete note bodies and their reference sentences."""
    notes = []
    for record in records:
        if record["source"] != "rendering/specimen/notation.md":
            continue
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


def pdf_code_matches(pages, text, layout_text, a4=False):
    """Keep exact characters when margin captions interrupt layout extraction."""
    expected = re.sub(r"\s+", "", text)
    if expected in re.sub(r"\s+", "", layout_text):
        return True
    body = []
    mm = 72 / 25.4
    for number, page in enumerate(pages, 1):
        left, right = ((25 * mm, 134 * mm) if a4 else
                       (54, 378) if number % 2 else (198, 522))
        top, bottom = (20 * mm, 277 * mm) if a4 else (54, 666)
        for word in pdf_words(page):
            bounds = word_bounds([word])
            if (bounds["left"] >= left - 1 and bounds["right"] <= right + 1
                    and bounds["top"] >= top - 1 and bounds["bottom"] <= bottom + 1):
                body.append(word.text or "")
    return expected in re.sub(r"\s+", "", "".join(body))


def find_pdf_phrase(pages, text):
    """Match complete phrase characters across inline-font word boundaries."""
    expected = re.sub(r"\s+", "", text)
    found = []
    for page_number, page in enumerate(pages, 1):
        words = pdf_words(page)
        actual = [re.sub(r"\s+", "", word.text or "") for word in words]
        for start in range(len(actual)):
            joined = ""
            for end in range(start, len(actual)):
                joined += actual[end]
                if not expected.startswith(joined):
                    break
                if joined == expected:
                    found.append((page_number, words[start:end + 1]))
                    break
    return found


def word_bounds(words):
    return {
        "left": min(float(word.attrib["xMin"]) for word in words),
        "right": max(float(word.attrib["xMax"]) for word in words),
        "top": min(float(word.attrib["yMin"]) for word in words),
        "bottom": max(float(word.attrib["yMax"]) for word in words),
    }


def ast_walk(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from ast_walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from ast_walk(child)


def wide_code_blocks(blocks):
    """Select ordinary code in native wide Divs, preserving source order."""
    ordinary_codes = [re.sub(r"\s+", "", block["c"][1]) for block in ast_walk(blocks)
                      if block.get("t") == "CodeBlock" and
                      (not block["c"][0][1] or
                       block["c"][0][1][0] not in ("mermaid", "ebnf", "sequent", "split"))]
    codes, seen = [], set()
    for div in ast_walk(blocks):
        if div.get("t") != "Div" or "column-page-right" not in div["c"][0][1]:
            continue
        identifier = div["c"][0][0]
        selected = 0
        for block in ast_walk(div["c"][1]):
            if block.get("t") != "CodeBlock" or id(block) in seen:
                continue
            attributes, code = block["c"]
            kind = attributes[1][0] if attributes[1] else ""
            if kind in ("mermaid", "ebnf", "sequent", "split"):
                continue
            check(identifier, "real lesson: wide code has no stable region identifier")
            seen.add(id(block))
            selected += 1
            label = identifier if selected == 1 else f"{identifier}-{selected}"
            compact = re.sub(r"\s+", "", code)
            codes.append({"id": label, "text": code,
                          "expected_occurrences": sum(text.count(compact) for text in ordinary_codes)})
    return codes


def verify_wide_code_pdf(pages, codes, filename, a4, note_regions):
    """Require each complete wide code block on one usable, unobstructed page."""
    millimetre = 72 / 25.4
    code_pages = {}
    for code in codes:
        occurrences = find_pdf_phrase(pages, code["text"])
        label = code["id"]
        required = code.get("expected_occurrences", 1)
        check(len(occurrences) == required,
              f"{filename}: complete wide code {label} not found on one page for all "
              f"{required} source occurrences (found {len(occurrences)})")
        for number, words in occurrences:
            bounds = word_bounds(words)
            left, right = ((25 * millimetre, 190 * millimetre) if a4 else
                           ((54, 540) if number % 2 else (36, 522)))
            top, bottom = ((20 * millimetre, 277 * millimetre) if a4 else (54, 666))
            check(bounds["left"] >= left - 1 and bounds["right"] <= right + 1
                  and bounds["top"] >= top - 1 and bounds["bottom"] <= bottom + 1,
                  f"{filename}: wide code {label} leaves printable bounds on page {number}")
            for note in note_regions.get(number, []):
                overlaps = (bounds["left"] < note["right"] and bounds["right"] > note["left"]
                            and bounds["top"] < note["bottom"] and bounds["bottom"] > note["top"])
                check(not overlaps, f"{filename}: wide code {label} overlaps a note on page {number}")
        code_pages[label] = occurrences[0][0]
    return code_pages


def repair_reading_units(blocks):
    """Select the four explained equations and the complete shared helper."""
    codes = [node["c"][1] for node in ast_walk(blocks) if node.get("t") == "CodeBlock"]
    cases = [code for code in codes if code.startswith("restore Black ")]
    helpers = [code for code in codes if code.startswith("restore_three : (")
               and "restore_three first second third d =" in code]
    check(len(cases) == 4 and len(helpers) == 1,
          "real lesson: four repair equations and one complete helper are required")
    names = ("restore-left-left", "restore-left-right", "restore-right-left", "restore-right-right")
    return [{"id": name, "text": code} for name, code in zip(names, cases)] + [
        {"id": "restore-three", "text": helpers[0]}]


def verify_repair_units_pdf(pages, units, filename, a4):
    """Keep each short wiring comparison complete in the ordinary body column."""
    millimetre = 72 / 25.4
    found = {}
    for unit in units:
        occurrences = find_pdf_phrase(pages, unit["text"])
        check(len(occurrences) == 1,
              f"{filename}: complete repair unit {unit['id']} not found on one page")
        number, words = occurrences[0]
        bounds = word_bounds(words)
        left, right = ((25 * millimetre, 134 * millimetre) if a4 else
                       ((54, 378) if number % 2 else (198, 522)))
        top, bottom = ((20 * millimetre, 277 * millimetre) if a4 else (54, 666))
        check(bounds["left"] >= left - 1 and bounds["right"] <= right + 1
              and bounds["top"] >= top - 1 and bounds["bottom"] <= bottom + 1,
              f"{filename}: repair unit {unit['id']} leaves the body column on page {number}")
        found[unit["id"]] = number
    return found


def inline_text(inlines):
    parts = []
    for node in inlines:
        kind, content = node.get("t"), node.get("c")
        if kind == "Str":
            parts.append(content)
        elif kind in ("Space", "SoftBreak", "LineBreak"):
            parts.append(" ")
        elif kind in ("Code", "Math"):
            parts.append(content[1])
        elif kind in ("Link", "Span"):
            parts.append(inline_text(content[1]))
        elif kind in ("Emph", "Strong", "Strikeout", "SmallCaps", "Superscript", "Subscript"):
            parts.append(inline_text(content))
    return "".join(parts)


def real_lesson_source(project, record):
    root = Path(__file__).resolve().parents[2]
    environment = {**os.environ, "XDG_CACHE_HOME": str(root / ".build/toolchain/cache")}
    result = subprocess.run([str(root / ".build/toolchain/quarto-1.10.19/bin/quarto"),
                             "pandoc", str(project / record["chapter"]), "-t", "json"],
                            check=True, capture_output=True, text=True, env=environment)
    document = json.loads(result.stdout)
    nodes = list(ast_walk(document["blocks"]))
    images = {node["c"][0][0]: node for node in nodes if node.get("t") == "Image"}
    for figure in (node for node in nodes if node.get("t") == "Figure"):
        image = next((child for child in ast_walk(figure["c"][2])
                      if child.get("t") == "Image"), None)
        if image is not None:
            images[figure["c"][0][0]] = image
    divs = {node["c"][0][0]: node for node in nodes if node.get("t") == "Div"}
    check({"fig-red-root-sketch", "fig-tree-repair"}.issubset(images),
          "real lesson: source images have no stable identifiers")
    for identifier in ("height-counting-cue", "repair-comparison"):
        check(identifier in divs, f"real lesson: source has no {identifier} region")
    check("column-margin" in divs["height-counting-cue"]["c"][0][1],
          "real lesson: counting cue is not an unnumbered margin note")
    check("column-page-right" in divs["repair-comparison"]["c"][0][1],
          "real lesson: repair figure does not request body and note space")
    note_nodes = [node for node in nodes if node.get("t") == "Note" and
                  any(child.get("t") in ("Image", "Figure") and child["c"][0][0] == "fig-red-root-sketch"
                      for child in ast_walk(node))]
    check(len(note_nodes) == 1, "real lesson: sketch is not in exactly one numbered note")
    note = note_nodes[0]
    note_parent = next(node for node in nodes if node.get("t") in ("Para", "Plain")
                       and any(inline is note for inline in node["c"]))
    reference = inline_text(note_parent["c"][:note_parent["c"].index(note)]).strip()
    check(reference, "real lesson: graphical note lost its source reference text")
    note_text = " ".join(inline_text(block["c"]).strip() for block in note["c"]
                         if block["t"] in ("Para", "Plain") and
                         not any(child.get("t") == "Image" for child in ast_walk(block)))
    check(note_text, "real lesson: numbered sketch has no explanatory note text")
    cue_text = " ".join(inline_text(block["c"]).strip()
                        for block in divs["height-counting-cue"]["c"][1]
                        if block["t"] in ("Para", "Plain"))
    cue_index = document["blocks"].index(divs["height-counting-cue"])
    cue_before = document["blocks"][cue_index - 1]
    check(cue_before["t"] == "Para", "real lesson: counting cue lost its local paragraph")
    # The definition paragraph may begin on the previous print page.
    cue_reference = " ".join(inline_text(cue_before["c"]).split()[-8:])
    expected_images = {}
    for identifier, image in images.items():
        if identifier not in ("fig-red-root-sketch", "fig-tree-repair"):
            continue
        attributes = dict(image["c"][0][2])
        check(attributes.get("fig-alt"), f"real lesson: {identifier} has no explicit description")
        svg = ET.parse(project / image["c"][2][0]).getroot()
        view_box = [float(value) for value in svg.attrib["viewBox"].split()]
        expected_images[identifier] = {"caption": inline_text(image["c"][1]),
                                       "alt": attributes["fig-alt"], "src": image["c"][2][0],
                                       "height_ratio": view_box[3] / view_box[2]}
    return {"images": expected_images, "note": note_text, "cue": cue_text,
            "wide_code": wide_code_blocks(document["blocks"]),
            "repair_units": repair_reading_units(document["blocks"]),
            "cue_reference": cue_reference, "references": reference}


def verify_canonical_assets(project, records, published=True):
    root = Path(__file__).resolve().parents[2]
    count = 0
    for record in records:
        for asset in record.get("assets", []):
            canonical = root / asset["source"]
            staged = project / asset["staged"]
            delivered = project / "output" / asset["staged"]
            paths = (canonical, staged, delivered) if published else (canonical, staged)
            for path in paths:
                check(path.is_file(), f"canonical lesson asset missing: {path}")
                check(hashlib.sha256(path.read_bytes()).hexdigest() == asset["sha256"],
                      f"canonical lesson asset differs from recorded source: {path}")
            svg = ET.parse(canonical).getroot()
            check("viewBox" in svg.attrib, f"{canonical}: SVG has no viewport")
            for node in svg.iter():
                check(node.tag.rsplit("}", 1)[-1] not in ("foreignObject", "script", "text"),
                      f"{canonical}: nonportable SVG element")
                for attribute, value in node.attrib.items():
                    if attribute.rsplit("}", 1)[-1] == "href":
                        check(value.startswith("#"), f"{canonical}: external SVG resource")
            count += 1
    return count


def verify_lesson_pdf(pages, expected, filename, a4, known_notes=None):
    millimetre = 72 / 25.4
    regions = {}
    def phrase(text):
        occurrences = find_pdf_phrase(pages, text)
        check(len(occurrences) == 1, f"{filename}: real lesson text not found once: {text}")
        return occurrences[0][0], word_bounds(occurrences[0][1])

    for role, text in (("numbered note", expected["note"]),
                       ("sketch caption", expected["images"]["fig-red-root-sketch"]["caption"]),
                       ("counting cue", expected["cue"])):
        number, bounds = phrase(text)
        left, right = ((140 * millimetre, 190 * millimetre) if a4 else
                       ((396, 540) if number % 2 else (36, 180)))
        check(bounds["left"] >= left - 1 and bounds["right"] <= right + 1,
              f"{filename}: real lesson {role} leaves its note column")
        regions[role] = (number, bounds)
    note_page, _ = regions["numbered note"]
    caption_page, caption_bounds = regions["sketch caption"]
    check(note_page == caption_page, f"{filename}: sketch caption detached from note text")
    reference_page, reference_bounds = phrase(expected["references"])
    check(reference_page == note_page, f"{filename}: graphical note detached from reference page")
    check(abs(caption_bounds["top"] - reference_bounds["top"]) < 230,
          f"{filename}: graphical note too far from its reference")
    cue_reference_page, cue_reference_bounds = phrase(expected["cue_reference"])
    cue_page, cue_bounds = regions["counting cue"]
    check(cue_page == cue_reference_page and abs(cue_bounds["top"] - cue_reference_bounds["top"]) < 100,
          f"{filename}: counting cue detached from its local height definitions")
    wide_page, wide_bounds = phrase(expected["images"]["fig-tree-repair"]["caption"])
    left, right = ((25 * millimetre, 190 * millimetre) if a4 else
                   ((54, 540) if wide_page % 2 else (36, 522)))
    check(wide_bounds["left"] >= left - 1 and wide_bounds["right"] <= right + 1,
          f"{filename}: wide figure caption extends outside print margins")
    extends_notes = (wide_bounds["right"] > 140 * millimetre if a4 else
                     (wide_bounds["right"] > 396 if wide_page % 2 else wide_bounds["left"] < 180))
    check(extends_notes, f"{filename}: figure caption does not use the wide region")
    top = 20 * millimetre if a4 else 54
    height = 297 * millimetre if a4 else 720
    figure_height = (right - left) * expected["images"]["fig-tree-repair"]["height_ratio"]
    check(wide_bounds["top"] - figure_height >= top - 3,
          f"{filename}: full-width figure and its caption cannot fit on the same print page")
    check(wide_bounds["bottom"] <= height - top + 1,
          f"{filename}: wide figure caption extends below the printable region")
    check(caption_bounds["bottom"] <= height - top + 1,
          f"{filename}: graphical sidenote extends below the printable region")
    for role, (number, bounds) in regions.items():
        if number == wide_page:
            check(bounds["bottom"] <= wide_bounds["top"] or bounds["top"] >= wide_bounds["bottom"],
                  f"{filename}: wide figure caption overlaps {role}")
    note_regions = {number: list(bounds) for number, bounds in (known_notes or {}).items()}
    for number, bounds in regions.values():
        note_regions.setdefault(number, []).append(bounds)
    note_left, note_right = ((140 * millimetre, 190 * millimetre) if a4 else
                            ((396, 540) if caption_page % 2 else (36, 180)))
    sketch_height = ((note_right - note_left)
                     * expected["images"]["fig-red-root-sketch"]["height_ratio"])
    note_regions[caption_page].append({"left": note_left, "right": note_right,
                                      "top": caption_bounds["top"] - sketch_height,
                                      "bottom": caption_bounds["bottom"]})
    code_pages = verify_wide_code_pdf(pages, expected["wide_code"], filename, a4, note_regions)
    repair_pages = verify_repair_units_pdf(pages, expected["repair_units"], filename, a4)
    return {"graphical_note_page": note_page, "counting_cue_page": regions["counting cue"][0],
            "wide_figure_page": wide_page, "wide_code_pages": code_pages,
            "repair_unit_pages": repair_pages}


def verify_pdf(project, records, notes, full_width, filename, a4=False, lesson=None):
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

    titles = []
    for record in [{"chapter": "index.md"}, {"chapter": "setup.md"}] + records:
        heading = re.search(r"^# (.+?)(?: \{[^}]+\})?$", (project / record["chapter"]).read_text(), re.M)
        check(heading is not None, f"{record['chapter']}: chapter has no title")
        titles.append(record.get("title", heading.group(1)))
    parities, previous_heading = set(), None
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
        position = (number, float(first_word.attrib["yMin"]))
        check(previous_heading is None or position > previous_heading,
              f"{filename}: chapter reading order differs at {title!r}")
        previous_heading = position
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

    if full_width is not None:
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

    if lesson is not None:
        verification = verify_lesson_pdf(pages, lesson, filename, a4, note_regions)
        print(f"{filename}: real lesson layout {verification}")

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
            check(pdf_code_matches(pages, block["text"], compact_pdf, a4),
                  f"{filename}: {record['source']}: PDF loses code/transcript characters")
    return len(pages)


def verify_generated_diagrams(project, jobs, published=False):
    """Validate staged notation, and exact delivered copies when HTML is selected."""
    for job in jobs:
        path = project / "assets" / (job["id"] + ".svg")
        if published:
            exported = project / "output/assets" / path.name
            check(exported.read_bytes() == path.read_bytes(),
                  f"{job['id']}: published diagram differs from checked staged SVG")
        svg = ET.parse(path).getroot()
        check("viewBox" in svg.attrib, f"{job['id']}: SVG has no viewport")
        descriptions = ["".join(node.itertext()) for node in svg if node.tag.endswith("}desc")]
        check(any(job["source"] in description for description in descriptions), f"{job['id']}: canonical notation missing")
        for node in svg.iter():
            check(node.tag.rsplit("}", 1)[-1] not in ("foreignObject", "script", "text"), f"{job['id']}: nonportable SVG element")
            for attribute, value in node.attrib.items():
                if attribute.rsplit("}", 1)[-1] == "href":
                    check(value.startswith("#"), f"{job['id']}: external SVG resource")



def verify(project):
    output = project / "output"
    metadata = json.loads((project / "build.json").read_text())
    token_hash = metadata.get("design_tokens_sha256")
    if token_hash is not None:
        for token_file in [project / "styles/ash-tokens.css", output / "styles/ash-tokens.css"]:
            check(hashlib.sha256(token_file.read_bytes()).hexdigest() == token_hash,
                  f"design token hash mismatch: {token_file}")
    records = json.loads((project / "sources.json").read_text())
    basename = verify_build_metadata(metadata, records)
    specimen = metadata["mode"] == "specimen"
    formats = metadata.get("formats", list(FORMATS))
    names = {"html": "index.html", "epub": basename + ".epub",
             "pdf": basename + ".pdf", "pdf-a4": basename + "-a4.pdf"}
    for format in formats:
        check((output / names[format]).is_file(), f"required output missing: {names[format]}")
    full_width = source_full_width(records) if specimen else None
    lesson = next((record for record in records if record["source"] ==
                   "content/cases/guaranteeing-logarithmic-retrieval/README.md"), None)
    jobs = json.loads((project / "diagram-jobs.json").read_text())["diagrams"]
    verify_diagram_sources(jobs, records)
    lesson_expected = real_lesson_source(project, lesson) if lesson else None
    canonical_assets = verify_canonical_assets(project, records, published="html" in formats)
    if lesson:
        check(canonical_assets >= 1, "real lesson: the annotated repair figure is not recorded and staged")
    total = sum(len(record["code"]) for record in records)
    pages = {}
    if "html" in formats:
        pages = {Path(chapter).with_suffix(".html").name: Html(
            (output / Path(chapter).with_suffix(".html")).read_text()) for chapter in metadata["chapters"]}
        if lesson is not None:
            lesson_page = pages[Path(lesson["chapter"]).with_suffix(".html").name]
            for identifier in ("fig-red-root-sketch", "repair-comparison", "fig-tree-repair", "height-counting-cue"):
                check(identifier in lesson_page.ids, f"real lesson: missing rendered note/figure {identifier}")
            for identifier, image in lesson_expected["images"].items():
                matches = [actual for actual in lesson_page.images if actual.get("src") == image["src"]]
                check(len(matches) == 1, f"real lesson: missing or duplicate {identifier} image")
                check(matches[0].get("alt") == image["alt"], f"real lesson: {identifier} loses its description")
        for record in records:
            page_name = Path(record["chapter"]).with_suffix(".html").name
            check(page_name in pages, f"required source chapter missing: {page_name}")
            page = pages[page_name]
            check([heading_text(title) for title in page.headings] == [heading_text(record["title"])],
                  f"{page_name}: source chapter title differs from rendered HTML")
            expected = [block["text"] for block in record["code"]]
            check(page.pre == expected, f"{page_name}: rendered code/transcript differs from source")
        for name, page in pages.items():
            for href in page.links:
                target = local_target(name, href)
                if target is None:
                    continue
                path, anchor = target
                check((output / path).exists(), f"{name}: missing destination {href}")
                if anchor and path in pages:
                    check(anchor in pages[path].ids, f"{name}: missing anchor {href}")
        if full_width is not None:
            verify_full_width_markup([example for page in pages.values() for example in page.full_width],
                                     full_width, "HTML")

    if "epub" in formats:
        with zipfile.ZipFile(output / (basename + ".epub")) as archive:
            xml = {name: ET.fromstring(archive.read(name)) for name in archive.namelist()
                   if name.endswith((".xhtml", ".svg", ".opf"))}
            epub_ids = {name: {node.attrib["id"] for node in document.iter() if "id" in node.attrib}
                        for name, document in xml.items()}
            package_names = [name for name in xml if name.endswith(".opf")]
            check(len(package_names) == 1, "EPUB has no unique package document")
            package_name = package_names[0]
            package = xml[package_name]
            check(package.attrib["version"] == "3.0", "EPUB is not EPUB 3")
            check("rendition:layout" not in archive.read(package_name).decode(), "EPUB unexpectedly fixes its layout")
            associated = verify_epub_chapters(xml, package_name, records)
            epub_full_width = []
            notes = 0
            expected_notes = sum(len(re.findall(r"^\[\^[^\]]+\]:",
                                (project / record["chapter"]).read_text(), re.M)) for record in records)
            for name, document in xml.items():
                if not name.endswith(".xhtml"):
                    continue
                for element in document.iter():
                    tag = element.tag.rsplit("}", 1)[-1]
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
            check(notes == expected_notes, "EPUB loses or duplicates source note references")
            if lesson is not None:
                lesson_name, lesson_document = associated[lesson["source"]]
                check("height-counting-cue" in epub_ids[lesson_name], "EPUB omits real lesson note styles")
                for identifier, expected in lesson_expected["images"].items():
                    candidates = [node for node in lesson_document.iter()
                                  if node.attrib.get("id") == identifier]
                    check(len(candidates) == 1, f"EPUB: missing {identifier}")
                    image = next((node for node in candidates[0].iter()
                                  if node.tag.endswith("}img")), None)
                    check(image is not None and image.attrib.get("alt") == expected["alt"],
                          f"EPUB: {identifier} loses its image or description")
                notes_with_image = [node for node in lesson_document.iter()
                                    if node.attrib.get("{http://www.idpf.org/2007/ops}type") == "footnote"
                                    and any(child.attrib.get("id") == "fig-red-root-sketch" for child in node.iter())]
                check(len(notes_with_image) == 1, "EPUB: sketch is not inside its linked note")
                note_id = notes_with_image[0].attrib["id"]
                references = [node for node in lesson_document.iter()
                              if node.attrib.get("{http://www.idpf.org/2007/ops}type") == "noteref"
                              and node.attrib.get("href") == "#" + note_id]
                check(len(references) == 1, "EPUB: graphical note has no unique reference")
                check(references[0].attrib.get("id") in epub_ids[lesson_name],
                      "EPUB: graphical note reference has no return destination")
            if full_width is not None:
                verify_full_width_markup(epub_full_width, full_width, "EPUB")

    verify_generated_diagrams(project, jobs, published="html" in formats)

    notes = source_notes(project, records) if specimen else []
    print_pages = {}
    for format in (value for value in formats if value.startswith("pdf")):
        print_pages[format] = verify_pdf(project, records, notes, full_width, names[format],
                                         a4=format == "pdf-a4", lesson=lesson_expected)
    print(f"Verified {metadata['mode']} with {metadata['lesson_count']} indexed lessons: "
          f"{', '.join(formats)}; {len(pages)} HTML pages, {len(jobs)} static diagrams, "
          f"{canonical_assets} canonical lesson assets, {total} complete code/transcript blocks; "
          f"PDF pages {print_pages} with checked margins/notes.")



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", nargs="?", type=Path,
                        default=Path(__file__).resolve().parents[2] / ".build/specimen")
    try:
        args = parser.parse_args()
        project = args.project.resolve()
        if "html" in json.loads((project / "build.json").read_text()).get("formats", FORMATS):
            subprocess.run([sys.executable, str(ROOT / "rendering/token_sync.py"), "--check"], check=True)
        verify(project)
    except (OSError, ValueError, KeyError, ET.ParseError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"verification: {error}") from error
