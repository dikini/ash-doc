#!/usr/bin/env python3
"""Prepare a source-preserving Quarto book and build HTML, EPUB, and two PDFs."""

import argparse
import hashlib
import json
import math
import os
import re
import shutil
import subprocess
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / ".build/toolchain"
BOOK_FAMILIES = ("learn", "libraries", "effects", "cases")


def run(args, **kwargs):
    return subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def walk(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def literal(value):
    if isinstance(value, dict):
        if value.get("t") in ("Str", "MetaString"):
            return value["c"]
        if value.get("t") in ("Space", "SoftBreak", "LineBreak"):
            return " "
        return literal(value.get("c", []))
    if isinstance(value, list):
        return "".join(literal(item) for item in value)
    return ""


def parse(quarto, text):
    result = run([quarto, "pandoc", "--from", "markdown-smart", "--to", "json"],
                 input=text, text=True, capture_output=True)
    return json.loads(result.stdout)


def markdown(quarto, document, note_prefix=""):
    definitions = []
    if note_prefix:
        notes = [node for node in walk(document["blocks"]) if node.get("t") == "Note"]
        for number, note in enumerate(notes, 1):
            label = f"{note_prefix}{number}"
            body = {"pandoc-api-version": document["pandoc-api-version"],
                    "meta": {}, "blocks": note["c"]}
            lines = markdown(quarto, body).rstrip().splitlines()
            definition = f"[^{label}]: " + "\n".join(
                line if index == 0 else "    " + line
                for index, line in enumerate(lines))
            definitions.append(definition)
            note.clear()
            note.update({"t": "RawInline", "c": ["markdown", f"[^{label}]"]})
    result = run([quarto, "pandoc", "--from", "json", "--to", "markdown-smart",
                  "--wrap=none", "--markdown-headings=atx"], input=json.dumps(document),
                 text=True, capture_output=True).stdout
    return result + ("\n" + "\n\n".join(definitions) + "\n" if definitions else "")


def family_indexes(quarto):
    root_index = parse(quarto, (ROOT / "content/README.md").read_text())
    families = []
    for node in walk(root_index["blocks"]):
        if node.get("t") == "Link":
            target = node["c"][2][0].split("#")[0]
            candidate = (ROOT / "content" / target).resolve()
            if candidate.parent.parent == ROOT / "content" and candidate.name == "README.md":
                if candidate not in families:
                    families.append(candidate)
    return families


def family_lessons(quarto, index):
    indexed = []
    for node in walk(parse(quarto, index.read_text())["blocks"]):
        if node.get("t") != "Link":
            continue
        target = urlsplit(node["c"][2][0])
        if target.scheme or not target.path:
            continue
        path = (index.parent / unquote(target.path)).resolve()
        if path.parent.parent == index.parent and path.name == "README.md":
            if not path.is_file():
                raise ValueError(f"{index}: indexed lesson is missing: {target.path}")
            relative = path.relative_to(ROOT).as_posix()
            if relative not in indexed:
                indexed.append(relative)
    return indexed


def ordered_sources(quarto, selected):
    indexed = [source for index in family_indexes(quarto)
               for source in family_lessons(quarto, index)]
    for source in selected:
        if source not in indexed:
            raise ValueError(f"{source}: not an indexed lesson")
    return [source for source in indexed if source in selected]


def chapter_name(source):
    path = Path(source)
    if path.parts[0] == "content":
        if len(path.parts) == 3:
            return f"{path.parts[1]}-introduction.md"
        return f"{path.parts[1]}-{path.parts[2]}.md"
    return path.stem + ".md"


def whole_book_sources(quarto):
    available = {index.parent.name: index for index in family_indexes(quarto)}
    sources, parts = [], []
    for family in BOOK_FAMILIES:
        if family not in available:
            raise ValueError(f"whole book requires the indexed {family} family")
        index = available[family]
        introduction = index.relative_to(ROOT).as_posix()
        lessons = family_lessons(quarto, index)
        if not lessons:
            raise ValueError(f"{index}: family has no indexed lessons")
        sources.extend([introduction, *lessons])
        parts.append({"family": family, "introduction": chapter_name(introduction),
                      "chapters": [chapter_name(source) for source in lessons]})
    return sources, parts


def transform_links(document, source, mapping, commit):
    for node in walk(document["blocks"]):
        if node.get("t") != "Link":
            continue
        target = node["c"][2][0]
        url = urlsplit(target)
        if url.scheme or url.netloc or not url.path:
            continue
        destination = ((ROOT / source).parent / unquote(url.path)).resolve()
        if not destination.is_relative_to(ROOT) or not destination.exists():
            raise ValueError(f"{source}: unresolved local link {target}")
        relative = destination.relative_to(ROOT).as_posix()
        fragment = "#" + url.fragment if url.fragment else ""
        if relative == "README.md" and url.fragment in ("prepare-ash", "read-a-diagnostic"):
            replacement = "setup.md" + fragment
        elif relative in mapping:
            replacement = mapping[relative] + fragment
        else:
            replacement = f"https://github.com/dikini/ash-doc/blob/{commit}/{relative}{fragment}"
        node["c"][2][0] = replacement


def validate_source_svg(data, source):
    """Accept the self-contained outlined SVG boundary used by the specimen."""
    try:
        if re.search(br"<\?(?!xml[ \t\r\n])", data):
            raise ValueError("processing instructions are unsupported")
        if re.search(br"<!\s*(?:DOCTYPE|ENTITY)\b", data, re.I):
            raise ValueError("document declarations are unsupported")
        svg = ET.fromstring(data)
        if svg.tag != "{http://www.w3.org/2000/svg}svg":
            raise ValueError("an SVG root and namespace are required")
        viewport = [float(value) for value in re.split(r"[ ,]+", svg.get("viewBox", "").strip())]
        if (len(viewport) != 4 or not all(math.isfinite(value) for value in viewport)
                or viewport[2] <= 0 or viewport[3] <= 0):
            raise ValueError("a positive finite viewBox is required")

        def css_resources(css):
            decoded = re.sub(r"\\([0-9a-f]{1,6})\s?|\\([^\r\n])",
                             lambda match: chr(int(match[1], 16)) if match[1] else match[2],
                             css, flags=re.I)
            if re.search(r"@import\b|@font-face\b", decoded, re.I):
                raise ValueError("CSS imports and reader fonts are unsupported")
            for match in re.finditer(r"url\(\s*([\"']?)(.*?)\1\s*\)", decoded, re.I | re.S):
                if not match[2].strip().startswith("#"):
                    raise ValueError("external CSS resources are unsupported")

        allowed = {"svg", "g", "defs", "symbol", "use", "path", "rect", "line",
                   "circle", "ellipse", "polyline", "polygon", "title", "desc", "style",
                   "clipPath", "mask", "linearGradient", "radialGradient", "stop"}
        for node in svg.iter():
            kind = node.tag.rsplit("}", 1)[-1]
            if node.tag != f"{{http://www.w3.org/2000/svg}}{kind}" or kind not in allowed:
                raise ValueError(f"unsupported element {kind}")
            for attribute, value in node.attrib.items():
                name = attribute.rsplit("}", 1)[-1]
                if attribute == "{http://www.w3.org/XML/1998/namespace}base":
                    raise ValueError("resource base overrides are unsupported")
                if name.lower().startswith("on"):
                    raise ValueError("event handlers are unsupported")
                if name == "href" and not value.strip().startswith("#"):
                    raise ValueError("external href resources are unsupported")
                css_resources(value)
            if kind == "style":
                css_resources("".join(node.itertext()))
    except (ET.ParseError, ValueError) as error:
        raise ValueError(f"{source}: unsuitable SVG: {error}") from error


def stage_images(document, source, output):
    """Rebase native images, including those inside notes, without rewriting them."""
    assets = {}
    parent = (ROOT / source).parent.resolve()
    for node in walk(document["blocks"]):
        if node.get("t") != "Image":
            continue
        target = node["c"][2][0]
        url = urlsplit(target)
        path = Path(unquote(url.path))
        if (url.scheme or url.netloc or not url.path or path.is_absolute()
                or url.query or url.fragment):
            raise ValueError(f"{source}: image needs a plain relative lesson path: {target}")
        asset = (parent / path).resolve()
        if not asset.is_relative_to(parent) or not asset.is_file():
            raise ValueError(f"{source}: image is missing or outside its lesson: {target}")
        if asset.suffix.lower() != ".svg":
            raise ValueError(f"{source}: only outlined SVG lesson images are supported: {target}")
        if output is None:
            raise ValueError(f"{source}: image staging requires an output directory")
        relative = asset.relative_to(ROOT).as_posix()
        if relative not in assets:
            data = asset.read_bytes()
            validate_source_svg(data, relative)
            identifier = hashlib.sha256(relative.encode()).hexdigest()[:16]
            basename = re.sub(r"[^A-Za-z0-9._-]", "-", asset.stem) + ".svg"
            staged = f"assets/source-{identifier}-{basename}"
            destination = output / staged
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(data)
            assets[relative] = {"source": relative, "staged": staged,
                                "sha256": hashlib.sha256(data).hexdigest()}
        node["c"][2][0] = assets[relative]["staged"]
    return list(assets.values())


def prepare_chapter(quarto, source, mapping, commit, jobs, output=None, assets=None,
                    details=None):
    text = (ROOT / source).read_text(encoding="utf-8")
    document = parse(quarto, text)
    if details is not None:
        heading = next((block for block in document["blocks"]
                        if block.get("t") == "Header" and block["c"][0] == 1), None)
        if heading is None:
            raise ValueError(f"{source}: chapter needs a top-level title")
        details.update(title=literal(heading["c"][2]), anchor=heading["c"][1][0])
    transform_links(document, source, mapping, commit)
    staged_assets = stage_images(document, source, output)
    if assets is not None:
        assets.extend(staged_assets)
    descriptions = document["meta"].pop("diagrams", {"c": []})["c"]
    diagram_number = 0
    blocks = []
    for block in document["blocks"]:
        if block.get("t") == "Para" and literal(block["c"]) == "{{< pagebreak >}}":
            # Keep the used Quarto directive intact through the Markdown writer.
            blocks.append({"t": "RawBlock", "c": ["markdown", "{{< pagebreak >}}"]})
            continue
        if block.get("t") == "RawBlock" and block["c"][0] == "html" and block["c"][1].lstrip().startswith("<!--"):
            continue
        if block.get("t") == "CodeBlock":
            attributes, code = block["c"]
            kind = attributes[1][0] if attributes[1] else ""
            if kind in ("mermaid", "ebnf", "sequent"):
                if diagram_number >= len(descriptions):
                    raise ValueError(f"{source}: {kind} needs caption and description metadata")
                description = {key: literal(value) for key, value in descriptions[diagram_number]["c"].items()}
                if description["kind"] != kind:
                    raise ValueError(f"{source}: diagram metadata order does not match {kind}")
                diagram_number += 1
                line = text[:text.index(code)].count("\n") + 1
                jobs.append({**description, "source": code, "path": source, "line": line})
                image_attributes = [description["id"], [], [["fig-alt", description["description"]], ["width", "100%"]]]
                blocks.append({"t": "Para", "c": [{"t": "Image", "c": [image_attributes,
                               [{"t": "Str", "c": description["caption"]}],
                               ["assets/" + description["id"] + ".svg", ""]]}]})
                continue
        blocks.append(block)
    if diagram_number != len(descriptions):
        raise ValueError(f"{source}: unused diagram descriptions")
    document["blocks"] = blocks
    document["meta"] = {}
    code_records = []
    for block in walk(document["blocks"]):
        if block.get("t") != "CodeBlock":
            continue
        attributes, code = block["c"]
        kind = attributes[1][0] if attributes[1] else ""
        if kind not in ("mermaid", "ebnf", "sequent"):
            code_records.append({"kind": kind, "text": code})
    # Namespace note labels without changing source anchors or literal code.
    prefix = Path(chapter_name(source)).stem + "-"
    return markdown(quarto, document, prefix), code_records


def reader_setup(quarto):
    document = parse(quarto, (ROOT / "README.md").read_text())
    keep = False
    blocks = [{"t": "Header", "c": [1, ["reader-setup", [], []], [{"t": "Str", "c": "Reader setup"}]]}]
    for block in document["blocks"]:
        if block.get("t") == "Header" and block["c"][0] == 2:
            keep = literal(block["c"][2]) in ("Prepare Ash", "Read a diagnostic")
        if keep:
            blocks.append(block)
    document["blocks"], document["meta"] = blocks, {}
    return markdown(quarto, document, "setup-")


def configuration(chapters, title="Ash documentation rendering specimen",
                  output_file="ash-doc-specimen"):
    return {
        "project": {"type": "book", "output-dir": "output", "resources": ["fonts/**"]},
        "book": {"title": title,
                 "author": "Ash documentation project", "output-file": output_file,
                 "chapters": ["index.md", "setup.md"] + chapters},
        "lang": "en", "execute": {"enabled": False}, "number-sections": False,
        "pdf-a4": False,
        "syntax-highlighting": "none",
        "format": {
            "html": {"theme": ["cosmo", "styles/html.scss"], "toc": True,
                     "toc-location": "left", "reference-location": "margin",
                     "code-copy": False, "code-overflow": "scroll",
                     "grid": {"sidebar-width": "220px", "body-width": "650px", "margin-width": "210px"},
                     "include-in-header": "styles/fonts.html",
                     "include-after-body": "styles/navigation.html"},
            "epub": {"toc": True, "epub-version": 3, "css": "styles/epub.css",
                     "filters": [{"path": "styles/book-links.lua", "at": "pre-quarto"}]},
            "typst": {"toc": True, "keep-typ": True, "mainfont": "TeX Gyre Pagella",
                      "monofont": "IBM Plex Mono", "reference-location": "margin",
                      "filters": [{"path": "styles/book-links.lua", "at": "pre-quarto"}],
                      "template-partials": ["styles/typst-show.typ", "styles/book.typ"]},
        },
    }


def prepare(args):
    config = json.loads(args.specimen.read_text())
    version = run([args.quarto, "--version"], capture_output=True, text=True).stdout.strip()
    if version != config["quarto_version"]:
        raise ValueError(f"Quarto {config['quarto_version']} required; found {version}")
    if config["ash_commit"] not in (ROOT / "README.md").read_text():
        raise ValueError("specimen Ash target differs from the current edition")
    whole_book = getattr(args, "whole_book", False)
    if whole_book:
        sources, parts = whole_book_sources(args.quarto)
        title, output_file = "Ash documentation review draft", "ash-doc-review"
    else:
        sources = ordered_sources(args.quarto, config["sources"]) + config["fixtures"]
        parts = []
        title, output_file = "Ash documentation rendering specimen", "ash-doc-specimen"
    config["output_file"] = output_file
    mapping = {source: chapter_name(source) for source in sources}
    if len(set(mapping.values())) != len(mapping):
        raise ValueError("chapter filenames collide")
    commit = run(["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    args.output.mkdir(parents=True, exist_ok=True)
    marker = args.output / ".ash-doc-rendering"
    if any(args.output.iterdir()) and not marker.exists():
        raise ValueError(f"{args.output}: existing directory is not a generated book")
    marker.write_text("Generated by ash-doc rendering/build.py\n", encoding="utf-8")
    shutil.copytree(ROOT / "rendering/styles", args.output / "styles", dirs_exist_ok=True)
    shutil.copytree(ROOT / "rendering/fonts", args.output / "fonts", dirs_exist_ok=True)
    jobs, records = [], []
    for source in sources:
        assets = []
        details = {}
        staged, codes = prepare_chapter(args.quarto, source, mapping, commit, jobs,
                                       output=args.output, assets=assets, details=details)
        chapter = mapping[source]
        (args.output / chapter).write_text(staged, encoding="utf-8")
        path = Path(source)
        if path.parts[0] == "content":
            role = "introduction" if len(path.parts) == 3 else "lesson"
        else:
            role = "fixture"
        record = {"source": source, "chapter": chapter, "code": codes, "assets": assets,
                  "sha256": hashlib.sha256((ROOT / source).read_bytes()).hexdigest(),
                  "role": role, **details}
        if path.parts[0] == "content":
            record["family"] = path.parts[1]
        records.append(record)
    (args.output / "setup.md").write_text(reader_setup(args.quarto), encoding="utf-8")
    introduction = ("# Ash documentation\n\n"
        "The book begins with small calculations and follows how their data and "
        "functions connect. Work through the programs, predict their results, "
        "and use the observations to explain each step.\n\n"
        "Begin with reader setup and Learn Ash. The library chapters develop "
        "reusable abstractions; the effects chapters develop requests, control, "
        "and scoped resources. The Cases then calculate algorithms and apply "
        "those ideas to larger problems. Follow each part in order, using its "
        "introduction for reading and practice guidance.\n") if whole_book else (
        "# Ash documentation\n\nThis local specimen tests the presentation of verified lessons "
        "and labelled notation fixtures in three formats.\n\nThe lessons target `diag-ash`, commit `"
        + config["ash_commit"] + "`. The edition remains unpublished.\n\n"
        "Begin with reader setup, then use the contents to select a chapter.\n")
    (args.output / "index.md").write_text(introduction, encoding="utf-8")
    chapters = ([{"part": part["introduction"], "chapters": part["chapters"]} for part in parts]
                if whole_book else list(mapping.values()))
    (args.output / "_quarto.yml").write_text(json.dumps(configuration(chapters, title, output_file), indent=2), encoding="utf-8")
    (args.output / "_quarto-a4.yml").write_text(json.dumps({
        "book": {"output-file": output_file + "-a4"},
        "pdf-a4": True,
        "format": {"typst": {"reference-location": "margin"}},
    }, indent=2), encoding="utf-8")
    (args.output / "sources.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
    (args.output / "build.json").write_text(json.dumps({
        "mode": "book" if whole_book else "specimen", "title": title,
        "output_file": output_file, "source_commit": commit, "ash_commit": config["ash_commit"],
        "chapters": ["index.md", "setup.md", *mapping.values()], "parts": parts,
        "lesson_count": sum(record["role"] == "lesson" for record in records),
    }, indent=2), encoding="utf-8")
    (args.output / "diagram-jobs.json").write_text(json.dumps({"output": str(args.output / "assets"),
                                            "diagrams": jobs}, indent=2), encoding="utf-8")
    return config


def repair_figure_wrappers(output, output_file="ash-doc-specimen"):
    """Compensate for QT-01 without changing the valid image alt attribute."""
    wrapper = re.compile(r'<div\b[^>]*\bclass="[^"]*\bquarto-float\b[^"]*"[^>]*>')

    def repair(text):
        return wrapper.sub(lambda match: re.sub(r'\s+alt="[^"]*"', '', match.group()), text)

    for path in output.glob("*.html"):
        text = path.read_text(encoding="utf-8")
        corrected = repair(text)
        if corrected != text:
            path.write_text(corrected, encoding="utf-8")
    path = output / (output_file + ".epub")
    temporary = path.with_suffix(".epub.partial")
    try:
        with zipfile.ZipFile(path) as original, zipfile.ZipFile(temporary, "w") as corrected:
            for member in original.infolist():
                data = original.read(member.filename)
                if member.filename.endswith(".xhtml"):
                    data = repair(data.decode("utf-8")).encode("utf-8")
                corrected.writestr(member, data)
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def build(args, config):
    job_path = args.output / "diagram-jobs.json"
    jobs = json.loads(job_path.read_text())
    for key, path in (("railroad", args.railroad), ("sequent", args.sequent)):
        actual = run(["git", "rev-parse", "HEAD"], cwd=path, capture_output=True, text=True).stdout.strip()
        if actual != config["renderers"][key]:
            raise ValueError(f"{key} commit {config['renderers'][key]} required; found {actual}")
        run(["git", "diff", "--quiet", "HEAD"], cwd=path)
        bundle = config["renderer_bundles"][key]
        if hashlib.sha256((path / bundle["path"]).read_bytes()).hexdigest() != bundle["sha256"]:
            raise ValueError(f"{key} bundle differs from its evaluated source hash")
    jobs.update({"railroad": str(args.railroad / "dist/rehype.js"),
                 "sequent": str(args.sequent / "packages/core/src/index.js"),
                 "mermaid": str(TOOLS / "mermaid/node_modules/.bin/mmdc"),
                 "puppeteer": str(TOOLS / "mermaid/node_modules/puppeteer/lib/puppeteer/puppeteer.js"),
                 "browser": str(args.browser), "fonts": str(ROOT / "rendering/fonts"),
                 "pdftocairo": shutil.which("pdftocairo")})
    job_path.write_text(json.dumps(jobs, indent=2), encoding="utf-8")
    run(["node", ROOT / "rendering/diagrams.mjs", job_path])
    environment = os.environ.copy()
    environment["XDG_CACHE_HOME"] = str(TOOLS / "cache")
    environment["TYPST_FONT_PATHS"] = str(ROOT / "rendering/fonts")
    environment["TYPST_IGNORE_SYSTEM_FONTS"] = "true"
    environment.pop("QUARTO_PROFILE", None)
    environment["SOURCE_DATE_EPOCH"] = run(["git", "show", "-s", "--format=%ct", "HEAD"], cwd=ROOT,
                                          capture_output=True, text=True).stdout.strip()
    run([args.quarto, "render", "--to", "all"], cwd=args.output, env=environment)
    output_file = config["output_file"]
    shutil.copyfile(args.output / "index.typ", args.output / (output_file + ".typ"))
    run([args.quarto, "render", "--to", "typst", "--profile", "a4", "--no-clean"],
        cwd=args.output, env=environment)
    shutil.copyfile(args.output / "index.typ", args.output / (output_file + "-a4.typ"))
    repair_figure_wrappers(args.output / "output", output_file)
    for name in ("index.html", output_file + ".epub", output_file + ".pdf",
                 output_file + "-a4.pdf"):
        if not (args.output / "output" / name).is_file():
            raise ValueError(f"required output missing: {name}")
    print(f"Built HTML, EPUB 3, book PDF, and A4 PDF in {args.output / 'output'}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--whole-book", action="store_true",
                        help="render all indexed lessons in Learn, Libraries, Effects, Cases order")
    parser.add_argument("--specimen", type=Path, default=ROOT / "rendering/specimen.json")
    parser.add_argument("--quarto", type=Path, default=TOOLS / "quarto-1.10.19/bin/quarto")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--railroad", type=Path)
    parser.add_argument("--sequent", type=Path)
    parser.add_argument("--browser", type=Path, default=TOOLS / "browser-cache/chrome/linux-152.0.7977.75/chrome-linux64/chrome")
    args = parser.parse_args()
    args.output = args.output or ROOT / (".build/book" if args.whole_book else ".build/specimen")
    os.environ.setdefault("XDG_CACHE_HOME", str(TOOLS / "cache"))
    common = run(["git", "rev-parse", "--path-format=absolute", "--git-common-dir"],
                 cwd=ROOT, capture_output=True, text=True).stdout.strip()
    siblings = Path(common).parent.parent
    args.railroad = args.railroad or siblings / "railroad"
    args.sequent = args.sequent or siblings / "sequent-md"
    for key in ("specimen", "quarto", "output", "railroad", "sequent", "browser"):
        setattr(args, key, getattr(args, key).resolve())
    try:
        config = prepare(args)
        if not args.prepare_only:
            build(args, config)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"rendering: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stderr:
            print(error.stderr, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
