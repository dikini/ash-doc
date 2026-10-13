"""Check the lesson's exact, explicitly non-executable source fragments."""

from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest


CHECKS = Path(__file__).resolve().parent
SOURCE = CHECKS.parent / "src" / "dictionaries.ash"
OPERATIONS = ("restore_three", "restore", "insert_colored", "blacken_root", "insert")


class FragmentAgreementTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.source = self.root / "dictionaries.ash"
        self.source.write_bytes(SOURCE.read_bytes())
        self.readme = self.root / "README.md"
        lines = SOURCE.read_text().splitlines()
        start = lines.index("type Color =")
        end = lines.index("type BalanceCheck =")
        representation = "\n".join(lines[start:end]).strip("\n")
        self.blocks = [("excerpt", "representation", representation)]
        for name in OPERATIONS:
            start = next(i for i, line in enumerate(lines)
                         if re.match(rf"(?:pub )?{name} :", line))
            end = next(i for i in range(start + 1, len(lines))
                       if re.match(r"(?:pub )?[a-z_]+ :", lines[i]))
            definition = "\n".join(lines[start:end]).strip("\n")
            self.blocks += [("signature", name, lines[start]),
                            ("excerpt", name, definition)]
        self.document = "\n\n".join(self.marked(*block) for block in self.blocks)

    @staticmethod
    def marked(kind, name, code, fence="text"):
        return (f"<!-- {kind}: src/dictionaries.ash#{name} -->\n\n"
                f"```{fence}\n{code}\n```")

    def check(self, document):
        self.readme.write_text(document + "\n")
        return subprocess.run(
            [sys.executable, str(CHECKS / "check_fragments.py"),
             str(self.readme), str(self.source)],
            text=True, capture_output=True, check=False,
        )

    def assert_rejected(self, document, reason):
        result = self.check(document)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(reason, result.stderr)

    def test_exact_representation_signatures_and_bodies_pass(self):
        result = self.check(self.document)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("11 exact source fragments", result.stdout)

    def test_changed_definition_is_rejected(self):
        self.assert_rejected(self.document.replace("Red,\n", "Black,\n", 1),
                             "differs from canonical source")

    def test_changed_indentation_is_rejected(self):
        self.assert_rejected(self.document.replace("    | Black", "   | Black", 1),
                             "differs from canonical source")

    def test_changed_signature_is_rejected(self):
        self.assert_rejected(self.document.replace("#insert -->\n\n```text\npub insert : K",
                                                  "#insert -->\n\n```text\npub insert : V", 1),
                             "differs from canonical source")

    def test_unknown_fragment_is_rejected(self):
        self.assert_rejected(self.document.replace("#representation", "#unknown", 1),
                             "unknown fragment")

    def test_unknown_source_is_rejected(self):
        self.assert_rejected(self.document.replace("src/dictionaries.ash#", "src/other.ash#", 1),
                             "unknown source")

    def test_orphan_marker_is_rejected(self):
        self.assert_rejected(self.document + "\n\n<!-- excerpt: src/dictionaries.ash#insert -->",
                             "must immediately precede a text fence")

    def test_intervening_prose_is_rejected(self):
        self.assert_rejected(self.document.replace("#representation -->\n\n```text",
                                                  "#representation -->\n\nAn explanation.\n\n```text", 1),
                             "must immediately precede a text fence")

    def test_fragment_cannot_be_marked_executable(self):
        self.assert_rejected(self.document.replace("```text", "```ash", 1),
                             "must immediately precede a text fence")

    def test_removed_marker_cannot_drop_required_coverage(self):
        self.assert_rejected(self.document.replace("<!-- signature: src/dictionaries.ash#restore -->", "", 1),
                             "missing required fragment")

    def test_removed_body_cannot_drop_required_coverage(self):
        body = next(block for block in self.blocks if block[:2] == ("excerpt", "insert_colored"))
        self.assert_rejected(self.document.replace(self.marked(*body), "", 1),
                             "missing required fragment")

    def test_duplicate_marker_is_rejected(self):
        self.assert_rejected(self.document + "\n\n" + self.marked(*self.blocks[0]),
                             "duplicate fragment")

    def test_malformed_marker_is_rejected(self):
        self.assert_rejected(self.document.replace("#representation -->", "#representation-->", 1),
                             "malformed fragment marker")

    def test_unclosed_fragment_is_rejected(self):
        self.assert_rejected(self.document.rsplit("\n```", 1)[0], "unclosed text fence")


if __name__ == "__main__":
    unittest.main()
