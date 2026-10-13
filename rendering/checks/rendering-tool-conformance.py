"""Reproduce the evaluated Quarto failures without changing canonical inputs."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import zipfile
import xml.etree.ElementTree as ET


def run(command, cwd, environment, log):
    result = subprocess.run(command, cwd=cwd, env=environment, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            check=False)
    log.write_text(result.stdout)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--quarto", type=Path, required=True)
    parser.add_argument("--epubcheck", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--expect-fixed", action="store_true")
    args = parser.parse_args()
    quarto = str(args.quarto.resolve())
    epubcheck = str(args.epubcheck.resolve())
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    fixtures = Path(__file__).resolve().parents[1] / "fixtures" / "conformance"
    prose = (Path(__file__).resolve().parents[2] / "docs" / "project" / "rendering-tool-bugs.md").read_text()
    image_source = next(line for line in (fixtures / "quarto-fig-alt" / "index.qmd").read_text().splitlines()
                        if line.startswith("!["))
    assert image_source in prose, "The displayed figure must match its canonical fixture."
    environment = dict(os.environ, NO_COLOR="1", TERM="dumb",
                       XDG_CACHE_HOME=str(output / "cache"))
    results = {}
    versions = {}
    for component, command in [
            ("quarto", [quarto, "--version"]),
            ("pandoc", [quarto, "pandoc", "--version"]),
            ("typst", [quarto, "typst", "--version"]),
            ("epubcheck", ["java", "-jar", epubcheck, "--version"])]:
        result = run(command, output, environment, output / f"{component}-version.txt")
        assert result.returncode == 0, result.stdout
        versions[component] = result.stdout.strip().splitlines()[0]
    if not args.expect_fixed:
        assert versions["quarto"] == "1.10.19"
        assert versions["pandoc"].startswith("pandoc 3.10")
        assert versions["typst"].startswith("typst 0.15.1")
        assert "5.4.0" in versions["epubcheck"]

    for case, fixture in [("fig-alt", "quarto-fig-alt"),
                          ("no-fig-alt", "quarto-fig-alt"),
                          ("no-author", "quarto-no-author"),
                          ("scalar-author", "quarto-no-author")]:
        destination = output / case
        if destination.exists():
            raise ValueError(f"Use a fresh output directory; {destination} already exists.")
        shutil.copytree(fixtures / fixture, destination)
        source = destination / "index.qmd"
        configuration = destination / "_quarto.yml"
        if case == "no-fig-alt":
            source.write_text(source.read_text().replace(' fig-alt="A black square on white."', ""))
        if case == "scalar-author":
            configuration.write_text(configuration.read_text().replace(
                "  title: An optional author reproduction\n",
                "  title: An optional author reproduction\n  author: Ash documentation project\n"))
        current_environment = dict(environment, XDG_CACHE_HOME=str(destination / "cache"))
        format_name = "epub" if "fig-alt" in case else "typst"
        render = run([quarto, "render", str(destination), "--to", format_name],
                     destination, current_environment, output / f"{case}-render.txt")
        observation = {"render_status": render.returncode}
        if format_name == "epub" and render.returncode == 0:
            artifact = destination / "_book" / "figure-alt.epub"
            check = run(["java", "-jar", epubcheck, str(artifact)], destination,
                        current_environment, output / f"{case}-epubcheck.txt")
            observation["epubcheck_status"] = check.returncode
            with zipfile.ZipFile(artifact) as archive:
                content = archive.read("EPUB/text/ch001.xhtml").decode()
            (output / f"{case}-chapter.xhtml").write_text(content)
            root = ET.fromstring(content)
            observation["non_image_alt"] = [
                {"element": element.tag.rsplit("}", 1)[-1], "alt": element.attrib["alt"]}
                for element in root.iter()
                if "alt" in element.attrib and element.tag.rsplit("}", 1)[-1] != "img"
            ]
            observation["image_alt"] = [
                element.attrib.get("alt") for element in root.iter()
                if element.tag.rsplit("}", 1)[-1] == "img"
            ]
        results[case] = observation

    (output / "report.json").write_text(json.dumps({"versions": versions, "cases": results}, indent=2) + "\n")
    assert results["no-fig-alt"]["render_status"] == 0
    assert results["no-fig-alt"]["epubcheck_status"] == 0
    assert results["no-fig-alt"]["non_image_alt"] == []
    assert results["scalar-author"]["render_status"] == 0
    assert results["fig-alt"]["render_status"] == 0
    assert results["fig-alt"]["image_alt"] == ["A black square on white."]
    if args.expect_fixed:
        assert results["fig-alt"]["epubcheck_status"] == 0
        assert results["fig-alt"]["non_image_alt"] == []
        assert results["no-author"]["render_status"] == 0
    else:
        assert results["fig-alt"]["epubcheck_status"] == 1
        assert results["fig-alt"]["non_image_alt"] == [
            {"element": "div", "alt": "A black square on white."}]
        assert results["no-author"]["render_status"] == 1
        assert "expected content, found array" in (output / "no-author-render.txt").read_text()
        expected_error = (fixtures / "tool-captures" / "quarto-no-author-render.txt").read_text()
        assert expected_error in (output / "no-author-render.txt").read_text()
        expected_epub = (fixtures / "tool-captures" / "quarto-fig-alt-epubcheck.txt").read_text()
        assert expected_epub == (output / "fig-alt-epubcheck.txt").read_text()
    print(json.dumps({"output": str(output), "versions": versions, "cases": results}, indent=2))


if __name__ == "__main__":
    main()
