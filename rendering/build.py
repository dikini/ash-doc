#!/usr/bin/env python3
"""Prepare a source-preserving Quarto book and build HTML, EPUB, and two PDFs."""

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / ".build/toolchain"


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


def markdown(quarto, document):
    return run([quarto, "pandoc", "--from", "json", "--to", "markdown-smart",
                "--wrap=none", "--markdown-headings=atx"], input=json.dumps(document),
               text=True, capture_output=True).stdout


def ordered_sources(quarto, selected):
    indexed = []
    root_index = parse(quarto, (ROOT / "content/README.md").read_text())
    families = []
    for node in walk(root_index["blocks"]):
        if node.get("t") == "Link":
            target = node["c"][2][0].split("#")[0]
            candidate = (ROOT / "content" / target).resolve()
            if candidate.parent.parent == ROOT / "content" and candidate.name == "README.md":
                if candidate not in families:
                    families.append(candidate)
    for index in families:
        for node in walk(parse(quarto, index.read_text())["blocks"]):
            if node.get("t") != "Link":
                continue
            target = urlsplit(node["c"][2][0])
            if target.scheme or not target.path:
                continue
            path = (index.parent / unquote(target.path)).resolve()
            if path.parent.parent == index.parent and path.name == "README.md":
                relative = path.relative_to(ROOT).as_posix()
                if relative not in indexed:
                    indexed.append(relative)
    for source in selected:
        if source not in indexed:
            raise ValueError(f"{source}: not an indexed lesson")
    return [source for source in indexed if source in selected]


def chapter_name(source):
    path = Path(source)
    if path.parts[0] == "content":
        return f"{path.parts[1]}-{path.parts[2]}.md"
    return path.stem + ".md"


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


def prepare_chapter(quarto, source, mapping, commit, jobs):
    text = (ROOT / source).read_text(encoding="utf-8")
    document = parse(quarto, text)
    transform_links(document, source, mapping, commit)
    descriptions = document["meta"].pop("diagrams", {"c": []})["c"]
    diagram_number = 0
    blocks = []
    code_records = []
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
            code_records.append({"kind": kind, "text": code})
        blocks.append(block)
    if diagram_number != len(descriptions):
        raise ValueError(f"{source}: unused diagram descriptions")
    document["blocks"] = blocks
    document["meta"] = {}
    return markdown(quarto, document), code_records


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
    return markdown(quarto, document)


def configuration(chapters):
    return {
        "project": {"type": "book", "output-dir": "output", "resources": ["fonts/**"]},
        "book": {"title": "Ash documentation rendering specimen",
                 "author": "Ash documentation project", "output-file": "ash-doc-specimen",
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
            "epub": {"toc": True, "epub-version": 3, "css": "styles/epub.css"},
            "typst": {"toc": True, "keep-typ": True, "mainfont": "TeX Gyre Pagella",
                      "monofont": "IBM Plex Mono", "reference-location": "margin",
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
    sources = ordered_sources(args.quarto, config["sources"]) + config["fixtures"]
    mapping = {source: chapter_name(source) for source in sources}
    if len(set(mapping.values())) != len(mapping):
        raise ValueError("chapter filenames collide")
    commit = run(["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    args.output.mkdir(parents=True, exist_ok=True)
    marker = args.output / ".ash-doc-rendering"
    if any(args.output.iterdir()) and not marker.exists():
        raise ValueError(f"{args.output}: existing directory is not a generated specimen")
    marker.write_text("Generated by ash-doc rendering/build.py\n", encoding="utf-8")
    shutil.copytree(ROOT / "rendering/styles", args.output / "styles", dirs_exist_ok=True)
    shutil.copytree(ROOT / "rendering/fonts", args.output / "fonts", dirs_exist_ok=True)
    jobs, records = [], []
    for source in sources:
        staged, codes = prepare_chapter(args.quarto, source, mapping, commit, jobs)
        chapter = mapping[source]
        (args.output / chapter).write_text(staged, encoding="utf-8")
        records.append({"source": source, "chapter": chapter, "code": codes,
                        "sha256": hashlib.sha256((ROOT / source).read_bytes()).hexdigest()})
    (args.output / "setup.md").write_text(reader_setup(args.quarto), encoding="utf-8")
    (args.output / "index.md").write_text(
        "# Ash documentation\n\nThis local specimen tests the presentation of verified lessons "
        "and labelled notation fixtures in three formats.\n\nThe lessons target `diag-ash`, commit `"
        + config["ash_commit"] + "`. The edition remains unpublished.\n\n"
        "Begin with reader setup, then use the contents to select a chapter.\n", encoding="utf-8")
    (args.output / "_quarto.yml").write_text(json.dumps(configuration(list(mapping.values())), indent=2), encoding="utf-8")
    (args.output / "_quarto-a4.yml").write_text(json.dumps({
        "book": {"output-file": "ash-doc-specimen-a4"},
        "pdf-a4": True,
        "format": {"typst": {"reference-location": "margin"}},
    }, indent=2), encoding="utf-8")
    (args.output / "sources.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
    (args.output / "diagram-jobs.json").write_text(json.dumps({"output": str(args.output / "assets"),
                                            "diagrams": jobs}, indent=2), encoding="utf-8")
    return config


def repair_figure_wrappers(output):
    """Compensate for QT-01 without changing the valid image alt attribute."""
    wrapper = re.compile(r'<div\b[^>]*\bclass="[^"]*\bquarto-float\b[^"]*"[^>]*>')

    def repair(text):
        return wrapper.sub(lambda match: re.sub(r'\s+alt="[^"]*"', '', match.group()), text)

    for path in output.glob("*.html"):
        text = path.read_text(encoding="utf-8")
        corrected = repair(text)
        if corrected != text:
            path.write_text(corrected, encoding="utf-8")
    path = output / "ash-doc-specimen.epub"
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
    shutil.copyfile(args.output / "index.typ", args.output / "ash-doc-specimen.typ")
    run([args.quarto, "render", "--to", "typst", "--profile", "a4", "--no-clean"],
        cwd=args.output, env=environment)
    shutil.copyfile(args.output / "index.typ", args.output / "ash-doc-specimen-a4.typ")
    repair_figure_wrappers(args.output / "output")
    for name in ("index.html", "ash-doc-specimen.epub", "ash-doc-specimen.pdf",
                 "ash-doc-specimen-a4.pdf"):
        if not (args.output / "output" / name).is_file():
            raise ValueError(f"required output missing: {name}")
    print(f"Built HTML, EPUB 3, book PDF, and A4 PDF in {args.output / 'output'}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--specimen", type=Path, default=ROOT / "rendering/specimen.json")
    parser.add_argument("--quarto", type=Path, default=TOOLS / "quarto-1.10.19/bin/quarto")
    parser.add_argument("--output", type=Path, default=ROOT / ".build/specimen")
    parser.add_argument("--railroad", type=Path)
    parser.add_argument("--sequent", type=Path)
    parser.add_argument("--browser", type=Path, default=TOOLS / "browser-cache/chrome/linux-152.0.7977.75/chrome-linux64/chrome")
    args = parser.parse_args()
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
