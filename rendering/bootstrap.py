#!/usr/bin/env python3
"""Prepare the pinned Linux x86_64 rendering tools in local build storage."""

import argparse
import hashlib
import json
import os
import platform
import shutil
import subprocess
import tarfile
import urllib.request
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / ".build/toolchain"


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def run(args, **kwargs):
    return subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def archive(item, offline):
    target = TOOLS / "downloads" / item["url"].rsplit("/", 1)[1]
    target.parent.mkdir(parents=True, exist_ok=True)
    if not target.exists():
        if offline:
            raise ValueError(f"offline preparation needs cached archive: {target}")
        temporary = target.with_suffix(target.suffix + ".partial")
        try:
            with urllib.request.urlopen(item["url"], timeout=60) as response, temporary.open("wb") as stream:
                shutil.copyfileobj(response, stream)
            if digest(temporary) != item["sha256"]:
                raise ValueError(f"download checksum mismatch: {target.name}")
            temporary.replace(target)
        finally:
            temporary.unlink(missing_ok=True)
    if digest(target) != item["sha256"]:
        raise ValueError(f"archive checksum mismatch: {target}")
    return target


def main(offline):
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise ValueError("this specimen bootstrap targets Linux x86_64")
    manifest = json.loads((ROOT / "rendering/toolchain/manifest.json").read_text())
    for name, checksum in manifest["fonts"].items():
        if digest(ROOT / "rendering/fonts" / name) != checksum:
            raise ValueError(f"font or notice checksum mismatch: {name}")
    for key in ("quarto", "epubcheck"):
        item = manifest[key]
        downloaded = archive(item, offline)
        binary = TOOLS / item.get("binary", item.get("jar"))
        if not binary.exists():
            if downloaded.name.endswith(".tar.gz"):
                with tarfile.open(downloaded) as source:
                    source.extractall(TOOLS, filter="data")
            else:
                with zipfile.ZipFile(downloaded) as source:
                    for member in source.namelist():
                        if not (TOOLS / member).resolve().is_relative_to(TOOLS.resolve()):
                            raise ValueError("archive path escapes local tool storage")
                    source.extractall(TOOLS)
    environment = os.environ.copy()
    environment["XDG_CACHE_HOME"] = str(TOOLS / "cache")
    environment["PUPPETEER_CACHE_DIR"] = str(TOOLS / "browser-cache")
    mermaid = TOOLS / "mermaid"
    installed_lock = mermaid / "package-lock.json"
    source_lock = ROOT / "rendering/toolchain/mermaid/package-lock.json"
    if digest(source_lock) != manifest["mermaid_cli"]["lock_sha256"]:
        raise ValueError("checked-in npm lock checksum mismatch")
    cli = TOOLS / manifest["mermaid_cli"]["binary"]
    browser = TOOLS / "browser-cache/chrome/linux-152.0.7977.75/chrome-linux64/chrome"
    if not cli.exists() or not installed_lock.exists() or digest(installed_lock) != digest(source_lock):
        if offline:
            raise ValueError("offline preparation needs the installed, locked Mermaid tools")
        mermaid.mkdir(parents=True, exist_ok=True)
        for name in ("package.json", "package-lock.json"):
            shutil.copyfile(ROOT / "rendering/toolchain/mermaid" / name, mermaid / name)
        run(["npm", "ci", "--prefix", mermaid, "--cache", TOOLS / "npm-cache",
             "--no-audit", "--no-fund"], env=environment)
    for command, expected in (([TOOLS / manifest["quarto"]["binary"], "--version"], manifest["quarto"]["version"]),
                              ([cli, "--version"], manifest["mermaid_cli"]["version"]),
                              ([browser, "--version"], "152.0.7977.75"),
                              (["pdftocairo", "-v"], manifest["pdftocairo"]["version"])):
        result = run(command, capture_output=True, text=True, env=environment)
        if expected not in result.stdout + result.stderr:
            raise ValueError(f"tool version differs from its pin: {command[0]}")
    run(["java", "-jar", TOOLS / manifest["epubcheck"]["jar"], "--version"],
        capture_output=True, text=True)
    print("Pinned Quarto, Typst, Mermaid, browser, EPUBCheck, Poppler, and font resources are ready.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--offline", action="store_true", help="validate cached tools without downloading")
    try:
        main(parser.parse_args().offline)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"bootstrap: {error}") from error
