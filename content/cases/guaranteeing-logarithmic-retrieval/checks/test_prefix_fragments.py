"""Reject changed or incomplete prefix-program teaching fragments."""

from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

import check_fragments


CHECKS = Path(__file__).resolve().parent
SOURCE = CHECKS.parent / "src" / "01-prefix-matrix.ash"
LIBRARY = CHECKS.parent / "src" / "dictionaries.ash"
OPERATIONS = ("has_value", "is_none", "prefix_run", "lookup_checks", "scenario")


class PrefixFragmentAgreementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.source = self.root / "01-prefix-matrix.ash"
        self.source.write_bytes(SOURCE.read_bytes())
        self.library = self.root / "dictionaries.ash"
        self.library.write_bytes(LIBRARY.read_bytes())
        self.readme = self.root / "README.md"
        lines = SOURCE.read_text().splitlines()

        def section(start, end):
            return "\n".join(lines[lines.index(start):lines.index(end)]).strip("\n")

        self.blocks = [
            ("excerpt", "imports", "\n".join(lines[:2])),
            ("excerpt", "representation", section("type PrefixCheck =", "has_value : Int -> Dictionaries.Option<Int> -> Bool")),
            ("excerpt", "keys", section("    let one = Dictionaries.Next(Dictionaries.Zero)", "    let ascending = Dictionaries.More(")),
            ("excerpt", "left_left", section("    let left_left = Dictionaries.More(", "    let left_right = Dictionaries.More(")),
            ("excerpt", "matrix_calls", "\n".join(lines[lines.index("    ("):-1])),
            ("signature", "main", "main : Unit -> (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)"),
        ]
        for name in OPERATIONS:
            start = next(i for i, line in enumerate(lines) if line.startswith(f"{name} :"))
            end = next(i for i in range(start + 1, len(lines))
                       if re.match(r"[a-z_]+ :", lines[i]))
            self.blocks += [("signature", name, lines[start]),
                            ("excerpt", name, "\n".join(lines[start:end]).strip("\n"))]
        dictionary = check_fragments.canonical_fragments(LIBRARY.read_text())
        self.dictionary_document = "\n\n".join(
            f"<!-- {kind}: src/dictionaries.ash#{name} -->\n\n```text\n{code}\n```"
            for (kind, name), code in dictionary.items()
        )
        self.document = self.dictionary_document + "\n\n" + "\n\n".join(
            self.marked(*block) for block in self.blocks
        )

    @staticmethod
    def marked(kind, name, code):
        return (f"<!-- {kind}: src/01-prefix-matrix.ash#{name} -->\n\n"
                f"```text\n{code}\n```")

    def check(self, document):
        self.readme.write_text(document + "\n")
        return subprocess.run(
            [sys.executable, str(CHECKS / "check_fragments.py"),
             str(self.readme), str(self.library), str(self.source)],
            text=True, capture_output=True, check=False,
        )

    def assert_rejected(self, document, reason):
        result = self.check(document)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(reason, result.stderr)

    def test_all_twenty_seven_fragments_pass(self):
        result = self.check(self.document)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("27 exact source fragments", result.stdout)

    def test_main_local_indent_is_exact(self):
        self.assert_rejected(self.document.replace("    let one =", "   let one =", 1),
                             "differs from canonical source")

    def test_recursive_dictionary_must_remain_exact(self):
        self.assert_rejected(self.document.replace(
            "let later_run = prefix_run rest retained_key retained_value absent_key next_dictionary",
            "let later_run = prefix_run rest retained_key retained_value absent_key dictionary", 1),
            "differs from canonical source")

    def test_lookup_base_case_must_keep_absence(self):
        self.assert_rejected(self.document.replace(
            "is_none (Dictionaries.lookup absent_key dictionary)", "true", 1),
            "differs from canonical source")

    def test_signature_cannot_lose_argument(self):
        self.assert_rejected(self.document.replace(
            "#scenario -->\n\n```text\nscenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int",
            "#scenario -->\n\n```text\nscenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Int", 1),
            "differs from canonical source")

    def test_main_signature_and_calls_are_not_interchangeable(self):
        self.assert_rejected(self.document.replace("<!-- signature: src/01-prefix-matrix.ash#main -->",
                                                  "<!-- excerpt: src/01-prefix-matrix.ash#main -->", 1),
                             "unknown fragment")

    def test_duplicate_local_fragment_is_rejected(self):
        self.assert_rejected(self.document + "\n\n" + self.marked(*self.blocks[2]),
                             "duplicate fragment")

    def test_removed_local_fragment_is_rejected(self):
        self.assert_rejected(self.document.replace(self.marked(*self.blocks[3]), "", 1),
                             "missing required fragment")

    def test_unknown_prefix_source_is_rejected(self):
        self.assert_rejected(self.document.replace("src/01-prefix-matrix.ash#imports", "src/other.ash#imports", 1),
                             "unknown source")

    def test_prefix_fragment_must_be_non_executable(self):
        self.assert_rejected(self.document.replace("#imports -->\n\n```text", "#imports -->\n\n```ash", 1),
                             "must immediately precede a text fence")

    def test_malformed_prefix_marker_is_rejected(self):
        self.assert_rejected(self.document.replace("#left_left -->", "#left_left-->", 1),
                             "malformed fragment marker")

    def test_fragments_work_inside_wide_divs(self):
        wide = self.document.replace(self.marked(*self.blocks[4]),
                                     "::: {.column-page-right}\n\n" + self.marked(*self.blocks[4]) + "\n\n:::")
        result = self.check(wide)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
