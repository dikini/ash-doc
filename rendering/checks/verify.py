#!/usr/bin/env python3
"""Check source text, book links, notes, and static assets in built output."""

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
        self.feed(source)

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
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

    def handle_endtag(self, tag):
        if tag == "pre" and self.current is not None:
            self.pre.append("".join(self.current).removesuffix("\n"))
            self.current = None


def check(condition, message):
    if not condition:
        raise ValueError(message)


def local_target(source, target):
    url = urlsplit(target)
    if url.scheme or url.netloc or not url.path and not url.fragment:
        return None
    return (posixpath.normpath(posixpath.join(posixpath.dirname(source), unquote(url.path)))
            if url.path else source), unquote(url.fragment)


def verify(project):
    output = project / "output"
    records = json.loads((project / "sources.json").read_text())
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

    with zipfile.ZipFile(output / "ash-doc-specimen.epub") as archive:
        xml = {name: ET.fromstring(archive.read(name)) for name in archive.namelist()
               if name.endswith((".xhtml", ".svg", ".opf"))}
        epub_ids = {name: {node.attrib["id"] for node in document.iter() if "id" in node.attrib}
                    for name, document in xml.items()}
        package = next(document for name, document in xml.items() if name.endswith(".opf"))
        check(package.attrib["version"] == "3.0", "EPUB is not EPUB 3")
        check("rendition:layout" not in archive.read("EPUB/content.opf").decode(), "EPUB unexpectedly fixes its layout")
        epub_pre = []
        notes = 0
        for name, document in xml.items():
            if not name.endswith(".xhtml"):
                continue
            for element in document.iter():
                tag = element.tag.rsplit("}", 1)[-1]
                if tag == "pre":
                    epub_pre.append("".join(element.itertext()).removesuffix("\n"))
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

    result = subprocess.run(["pdftotext", "-layout", str(output / "ash-doc-specimen.pdf"), "-"],
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
                  f"{record['source']}: PDF loses code/transcript characters")
    print(f"Verified {len(pages)} HTML pages, EPUB 3 links/notes, {len(jobs)} static diagrams, "
          f"and {total} complete code/transcript blocks in all three formats.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", nargs="?", type=Path,
                        default=Path(__file__).resolve().parents[2] / ".build/specimen")
    try:
        verify(parser.parse_args().project.resolve())
    except (OSError, ValueError, KeyError, ET.ParseError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"verification: {error}") from error
