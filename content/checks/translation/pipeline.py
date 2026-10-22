#!/usr/bin/env python3
"""Translation pipeline: segment, machine-translate, assemble, check,
compare, and converge Bulgarian lesson chapters.

The pipeline touches plain prose only. Fenced blocks, HTML comments,
reference link definitions, inline code spans, URLs, and identifiers are
transplanted byte-identical; the MT engine never sees them. See the pilot
plan at docs/plans/2026-10-22-multilingual-workflow-pilot.md.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
import textwrap
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

TRANSLATION_DIR = Path(__file__).resolve().parent
REPO_ROOT = TRANSLATION_DIR.parents[2]
PROMPT_TEMPLATE = (TRANSLATION_DIR / "prompt-bg.txt").read_text()
GLOSSARY_TEXT = (TRANSLATION_DIR / "glossary-bg.md").read_text()
MANIFEST = json.loads((TRANSLATION_DIR / "manifest.json").read_text())

INLINE_CODE_RE = re.compile(r"`[^`\n]+`")
REF_LABEL_RE = re.compile(r"(?<=\])\[[^\[\]\n]+\]")
LINK_URL_RE = re.compile(r"\((https?://[^)\s]+)\)")
BARE_URL_RE = re.compile(r"https?://[^\s)]+")
PROTECT_PATTERNS = [INLINE_CODE_RE, REF_LABEL_RE, LINK_URL_RE, BARE_URL_RE]
PLACEHOLDER_RE = re.compile(r"<!--t(\d+)-->")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)$")
LIST_ITEM_RE = re.compile(r"^(\s*)(\d+\.|[-*])\s+(.*)$")
LINKDEF_RE = re.compile(r"^\[[^\]]+\]:\s*\S+")

TRANSLATABLE = {"heading", "quote", "list_item", "paragraph"}
TRANSPLANT_KINDS = {"front_matter", "comment", "fence", "divfence", "linkdef"}


@dataclass
class Block:
    kind: str
    lines: list[str]
    text: str | None = None
    level: int = 0
    indent: str = ""
    marker: str = ""
    spans: list[str] = field(default_factory=list)


def sha256_text(text: str) -> str:
    return hash256(text.encode())


def hash256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def parse(source: str) -> tuple[list[Block], list[int], int, bool]:
    """Split Markdown into blocks, tracking blank lines between them so
    reassembly reproduces the source exactly."""
    trailing_newline = source.endswith("\n")
    lines = source.split("\n")
    if trailing_newline:
        lines = lines[:-1]
    blocks: list[Block] = []
    blanks_before: list[int] = []
    pending_blanks = 0
    i = 0
    n = len(lines)

    def starts_block(line: str) -> bool:
        return (
            line.startswith("```")
            or line.startswith(":::")
            or line.startswith("<!--")
            or line.startswith(">")
            or bool(HEADING_RE.match(line))
            or bool(LIST_ITEM_RE.match(line))
            or bool(LINKDEF_RE.match(line))
        )

    while i < n:
        line = lines[i]
        if not line.strip():
            pending_blanks += 1
            i += 1
            continue
        start = i
        if line == "---" and not blocks:
            i += 1
            while i < n and lines[i] != "---":
                i += 1
            i += 1
            blocks.append(Block("front_matter", lines[start:i]))
        elif line.startswith("```"):
            i += 1
            while i < n and not lines[i].startswith("```"):
                i += 1
            i += 1
            blocks.append(Block("fence", lines[start:i]))
        elif line.startswith("<!--"):
            while i < n and lines[i].startswith("<!--"):
                i += 1
            blocks.append(Block("comment", lines[start:i]))
        elif line.startswith(":::"):
            blocks.append(Block("divfence", lines[start : start + 1]))
            i += 1
        elif line.startswith(">"):
            while i < n and lines[i].startswith(">"):
                i += 1
            text = " ".join(l.lstrip("> ").strip() for l in lines[start:i])
            blocks.append(Block("quote", lines[start:i], text=text))
        else:
            heading = HEADING_RE.match(line)
            item = LIST_ITEM_RE.match(line)
            linkdef = LINKDEF_RE.match(line)
            if heading:
                blocks.append(
                    Block(
                        "heading",
                        lines[start : start + 1],
                        text=heading.group(2),
                        level=len(heading.group(1)),
                    )
                )
                i += 1
            elif linkdef:
                blocks.append(Block("linkdef", lines[start : start + 1]))
                i += 1
            elif item:
                indent, marker = item.group(1), item.group(2)
                i += 1
                while i < n and lines[i].strip() and (
                    len(lines[i]) - len(lines[i].lstrip()) > len(indent)
                ):
                    i += 1
                text = " ".join(l.strip() for l in lines[start:i])
                blocks.append(
                    Block(
                        "list_item",
                        lines[start:i],
                        text=text[len(indent) + len(marker) + 1 :],
                        indent=indent,
                        marker=marker,
                    )
                )
            else:
                i += 1
                while i < n and lines[i].strip() and not starts_block(lines[i]):
                    i += 1
                text = " ".join(l.strip() for l in lines[start:i])
                blocks.append(Block("paragraph", lines[start:i], text=text))
        blanks_before.append(pending_blanks)
        pending_blanks = 0
    return blocks, blanks_before, pending_blanks, trailing_newline


def protect(text: str) -> tuple[str, list[str]]:
    """Replace inline code, reference labels, and URLs with placeholders."""
    matches: list[tuple[int, int, str]] = []
    for pattern in PROTECT_PATTERNS:
        matches.extend((m.start(), m.end(), m.group(0)) for m in pattern.finditer(text))
    matches.sort()
    chosen: list[tuple[int, int, str]] = []
    last = -1
    for start, end, group in matches:
        if start >= last:
            chosen.append((start, end, group))
            last = end
    out: list[str] = []
    spans: list[str] = []
    pos = 0
    for index, (start, end, group) in enumerate(chosen):
        out.append(text[pos:start])
        out.append(f"<!--t{index}-->")
        spans.append(group)
        pos = end
    out.append(text[pos:])
    return "".join(out), spans


def restore(text: str, spans: list[str]) -> str:
    for index, span in enumerate(spans):
        text = text.replace(f"<!--t{index}-->", span, 1)
    leftover = PLACEHOLDER_RE.search(text)
    if leftover:
        raise ValueError(f"unresolved placeholder {leftover.group(0)}")
    return text


def format_block(block: Block, text: str) -> list[str]:
    if block.kind == "heading":
        return ["#" * block.level + " " + text]
    if block.kind == "quote":
        protected, spans = protect(text)
        return ["> " + restore(line, spans) for line in textwrap.wrap(
            protected, width=76, break_long_words=False, break_on_hyphens=False)]
    if block.kind == "list_item":
        initial = f"{block.indent}{block.marker} "
        hanging = block.indent + " " * (len(block.marker) + 1)
        protected, spans = protect(text)
        lines = textwrap.wrap(
            protected,
            width=78,
            initial_indent=initial,
            subsequent_indent=hanging,
            break_long_words=False,
            break_on_hyphens=False,
        )
        return [restore(line, spans) for line in lines]
    protected, spans = protect(text)
    return [restore(line, spans) for line in textwrap.wrap(
        protected, width=78, break_long_words=False, break_on_hyphens=False)]


def assemble(
    blocks: list[Block],
    blanks_before: list[int],
    trailing_blanks: int,
    trailing_newline: bool,
    translated: dict[int, str] | None = None,
) -> str:
    """Rebuild Markdown. Transplant blocks keep their original lines;
    translated blocks (when provided) reformat from their new text."""
    out: list[str] = []
    for index, block in enumerate(blocks):
        out.extend([""] * blanks_before[index])
        if translated is not None and index in translated and block.text is not None:
            out.extend(format_block(block, translated[index]))
        else:
            out.extend(block.lines)
    out.extend([""] * trailing_blanks)
    text = "\n".join(out)
    if trailing_newline:
        text += "\n"
    return text


def translatable_indices(blocks: list[Block]) -> list[int]:
    return [i for i, block in enumerate(blocks) if block.kind in TRANSLATABLE]


def prepare_segments(blocks: list[Block]) -> dict[int, tuple[str, list[str]]]:
    prepared: dict[int, tuple[str, list[str]]] = {}
    for index in translatable_indices(blocks):
        protected, spans = protect(blocks[index].text or "")
        blocks[index].spans = spans
        prepared[index] = (protected, spans)
    return prepared


def build_prompt(blocks: list[Block]) -> tuple[list[int], str]:
    prepared = prepare_segments(blocks)
    ids = sorted(prepared)
    segments = "\n".join(f"[bg-seg-{i}] {prepared[i][0]}" for i in ids)
    prompt = (
        PROMPT_TEMPLATE
        + "\n## Glossary\n\n"
        + GLOSSARY_TEXT
        + "\n## Segments\n\n"
        + segments
        + "\n"
    )
    return ids, prompt


def run_mt(prompt_text: str) -> str:
    cmd = [
        "codex", "exec",
        "-m", MANIFEST["model"],
        "--sandbox", MANIFEST["sandbox"],
        "--skip-git-repo-check",
        "-",
    ]
    proc = subprocess.run(
        cmd, input=prompt_text, capture_output=True, text=True,
        timeout=1800, cwd=REPO_ROOT,
    )
    if proc.returncode != 0:
        raise RuntimeError(f"codex exec failed ({proc.returncode}):\n{proc.stderr[-2000:]}")
    return proc.stdout


def parse_mt_output(stdout: str, expected: list[int]) -> dict[int, str]:
    marked = re.search(r"<<<BG-START>>>(.*?)<<<BG-END>>>", stdout, re.S)
    if not marked:
        raise RuntimeError(f"output markers missing; tail:\n{stdout[-1000:]}")
    found: dict[int, str] = {}
    for line in marked.group(1).split("\n"):
        match = re.match(r"\s*\[bg-seg-(\d+)\]\s?(.*)$", line)
        if match:
            found[int(match.group(1))] = match.group(2).strip()
    missing = [i for i in expected if i not in found]
    if missing:
        raise RuntimeError(f"segments missing from output: {missing}")
    return found


def translate_blocks(
    blocks: list[Block], mt_output: str, expected: list[int]
) -> dict[int, str]:
    raw = parse_mt_output(mt_output, expected)
    prepared = {i: blocks[i].spans for i in expected}
    return {i: restore(raw[i], prepared[i]) for i in expected}


def glossary_never_translate() -> list[str]:
    section = GLOSSARY_TEXT.split("## Never translate")[1].split("## ")[0]
    terms: list[str] = []
    for line in section.split("\n"):
        if line.strip().startswith("- "):
            terms.extend(re.findall(r"`([^`]+)`", line))
    return terms


def glossary_renderings() -> dict[str, str]:
    section = GLOSSARY_TEXT.split("## Approved renderings")[1].split("## ")[0]
    rows: dict[str, str] = {}
    for line in section.split("\n"):
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) >= 2 and cells[0] and cells[0] != "English" and not set(cells[0]) <= {"-"}:
            rows[cells[0]] = cells[1]
    return rows


def scan_never_translate(text: str, terms: list[str]) -> list[str]:
    prose = INLINE_CODE_RE.sub("", text)
    hits = []
    for term in terms:
        if re.search(r"(?<![\w])" + re.escape(term) + r"(?![\w])", prose):
            hits.append(term)
    return hits


def normalize(text: str) -> str:
    return " ".join(text.split())


def translation_paths(lesson_dir: Path) -> tuple[Path, Path, Path]:
    return (
        lesson_dir / "README.bg.md",
        lesson_dir / "checks" / "translation.json",
        lesson_dir / "checks" / "divergence.json",
    )


def check_lesson(lesson_dir: Path) -> list[str]:
    """Strict checks: skeleton, transplants, glossary, drift, quiescence."""
    violations: list[str] = []
    en = (lesson_dir / "README.md").read_text()
    bg_path, state_path, divergence_path = translation_paths(lesson_dir)
    if not bg_path.exists():
        return [f"{lesson_dir}: README.bg.md missing"]
    bg = bg_path.read_text()
    if state_path.exists():
        state = json.loads(state_path.read_text())
        current = sha256_text(en)
        if state.get("claimed_english_sha256") != current:
            violations.append(
                "drift: English changed since claim; run "
                "content/checks/translation/pipeline.py compare --lesson "
                f"{lesson_dir}")
        if divergence_path.exists():
            divergence = json.loads(divergence_path.read_text())
            open_flags = [
                f["segment"] for f in divergence.get("flags", [])
                if f.get("adjudication") not in
                ("keep-stored", "adopt-fresh", "rewrite")
            ]
            if open_flags:
                violations.append(
                    f"quiescence: unadjudicated divergence segments {open_flags}")

    en_blocks, _, _, _ = parse(en)
    bg_blocks, _, _, _ = parse(bg)

    en_kinds = [b.kind for b in en_blocks]
    bg_kinds = [b.kind for b in bg_blocks]
    if en_kinds != bg_kinds:
        violations.append(f"skeleton: block kinds differ\n  en={en_kinds}\n  bg={bg_kinds}")
        return violations

    en_levels = [b.level for b in en_blocks if b.kind == "heading"]
    bg_levels = [b.level for b in bg_blocks if b.kind == "heading"]
    if en_levels != bg_levels:
        violations.append(f"skeleton: heading levels differ {en_levels} vs {bg_levels}")

    terms = glossary_never_translate()
    for index, (en_block, bg_block) in enumerate(zip(en_blocks, bg_blocks)):
        if en_block.kind in TRANSPLANT_KINDS:
            if en_block.lines != bg_block.lines:
                violations.append(
                    f"transplant: {en_block.kind} block {index} differs from English")
            continue
        if en_block.text is None or bg_block.text is None:
            continue
        en_protected, en_spans = protect(en_block.text)
        for span in en_spans:
            if span not in bg_block.text:
                violations.append(
                    f"transplant: inline span {span!r} missing in block {index}")
        hits = scan_never_translate(bg_block.text, terms)
        for term in hits:
            violations.append(f"glossary: never-translate term {term!r} bare in block {index}")
    return violations


def fresh_candidate(lesson_dir: Path) -> tuple[list[Block], list[int], list[int], bool, dict[int, str], str]:
    """Run the MT engine over current English and return parsed blocks plus
    restored fresh translations."""
    en = (lesson_dir / "README.md").read_text()
    blocks, blanks_before, trailing_blanks, trailing_newline = parse(en)
    ids, prompt = build_prompt(blocks)
    output = run_mt(prompt)
    fresh = translate_blocks(blocks, output, ids)
    return blocks, blanks_before, trailing_blanks, trailing_newline, fresh, output


def cmd_translate(lesson_dir: Path) -> None:
    en = (lesson_dir / "README.md").read_text()
    bg_path, state_path, _ = translation_paths(lesson_dir)
    blocks, blanks_before, trailing_blanks, trailing_newline = parse(en)
    ids, prompt = build_prompt(blocks)
    output = run_mt(prompt)
    translated = translate_blocks(blocks, output, ids)
    bg_path.write_text(assemble(
        blocks, blanks_before, trailing_blanks, trailing_newline, translated))
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps({
        "language": "bg",
        "tier": "mt-draft",
        "claimed_english_sha256": sha256_text(en),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "provenance": {
            "engine": MANIFEST["engine"],
            "engine_version": MANIFEST["engine_version"],
            "model": MANIFEST["model"],
            "prompt_sha256": hash256(PROMPT_TEMPLATE.encode()),
            "glossary_sha256": hash256(GLOSSARY_TEXT.encode()),
            "segments": len(ids),
        },
    }, indent=2) + "\n")
    print(f"wrote {bg_path} and {state_path}")


def cmd_compare(lesson_dir: Path) -> None:
    _, state_path, divergence_path = translation_paths(lesson_dir)
    blocks, _, _, _, fresh, _ = fresh_candidate(lesson_dir)
    bg_path, _, _ = translation_paths(lesson_dir)
    bg_blocks, _, _, _ = parse(bg_path.read_text())
    terms = glossary_never_translate()
    flags = []
    for index in translatable_indices(blocks):
        stored_text = bg_blocks[index].text or ""
        fresh_text = fresh[index]
        if normalize(stored_text) == normalize(fresh_text):
            continue
        mechanical = None
        if scan_never_translate(fresh_text, terms):
            mechanical = "reject-fresh"
        for span in blocks[index].spans:
            if span not in fresh_text:
                mechanical = "reject-fresh"
        flags.append({
            "segment": index,
            "kind": blocks[index].kind,
            "english": blocks[index].text,
            "stored": stored_text,
            "fresh": fresh_text,
            "mechanical": mechanical,
            "adjudication": "keep-stored" if mechanical else None,
        })
    divergence_path.write_text(json.dumps({
        "lesson": str(lesson_dir),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "flags": flags,
    }, indent=2, ensure_ascii=False) + "\n")
    print(f"wrote {divergence_path} with {len(flags)} flagged segments")


def cmd_converge(lesson_dir: Path) -> None:
    en = (lesson_dir / "README.md").read_text()
    bg_path, state_path, divergence_path = translation_paths(lesson_dir)
    state = json.loads(state_path.read_text())
    if divergence_path.exists():
        divergence = json.loads(divergence_path.read_text())
        flags = divergence.get("flags", [])
        unresolved = [
            f["segment"] for f in flags
            if f.get("adjudication") not in ("keep-stored", "adopt-fresh", "rewrite")
        ]
        if unresolved:
            raise SystemExit(
                f"unadjudicated divergence segments: {unresolved}; "
                "edit checks/divergence.json first")
        adopt = {f["segment"]: f["fresh"] for f in flags
                 if f.get("adjudication") == "adopt-fresh"}
        if adopt:
            bg_blocks, bg_blanks, bg_trailing, bg_nl = parse(bg_path.read_text())
            bg_path.write_text(assemble(
                bg_blocks, bg_blanks, bg_trailing, bg_nl, adopt))
        state["provenance"]["last_convergence"] = datetime.now(
            timezone.utc).isoformat()
        divergence_path.unlink()
    state["claimed_english_sha256"] = sha256_text(en)
    state_path.write_text(json.dumps(state, indent=2) + "\n")
    print(f"converged {lesson_dir}; drift marker refreshed")


def cmd_check(lesson_dir: Path) -> None:
    violations = check_lesson(lesson_dir)
    for violation in violations:
        print(violation)
    if violations:
        raise SystemExit(1)
    print(f"{lesson_dir}: translation checks pass")


def main(argv: list[str]) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("translate", "check", "compare", "converge"):
        cmd = sub.add_parser(name)
        cmd.add_argument("--lesson", type=Path, required=True)
    args = parser.parse_args(argv)
    lesson_dir = args.lesson
    if args.command == "translate":
        cmd_translate(lesson_dir)
    elif args.command == "check":
        cmd_check(lesson_dir)
    elif args.command == "compare":
        cmd_compare(lesson_dir)
    elif args.command == "converge":
        cmd_converge(lesson_dir)


if __name__ == "__main__":
    main(sys.argv[1:])
