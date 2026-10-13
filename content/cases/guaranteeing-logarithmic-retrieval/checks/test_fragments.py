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
        self.blocks.append(("excerpt", "repair_args", next(
            line for line in lines if line.startswith("type RArg<K, V> ="))))
        for name in OPERATIONS:
            start = next(i for i, line in enumerate(lines)
                         if re.match(rf"(?:pub )?{name} :", line))
            end = next(i for i in range(start + 1, len(lines))
                       if re.match(r"(?:pub )?[a-z_]+ :", lines[i]))
            definition = "\n".join(lines[start:end]).strip("\n")
            first_equation = next(i for i in range(start + 1, end)
                                  if lines[i].startswith(name + " "))
            self.blocks.append(("signature", name, "\n".join(lines[start:first_equation])))
            if name != "restore":
                self.blocks.append(("excerpt", name, definition))
            else:
                starts = [i for i in range(first_equation, end)
                          if lines[i].startswith("restore ")]
                names = ("restore_left_left", "restore_left_right", "restore_right_left",
                         "restore_right_right", "restore_unchanged")
                self.blocks += [("excerpt", case, "\n".join(lines[begin:finish]).strip("\n"))
                                for case, begin, finish in zip(names, starts, starts[1:] + [end])]
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
        self.assertIn("16 exact source fragments", result.stdout)

    def test_restore_can_be_presented_as_five_complete_equations(self):
        cases = [block for block in self.blocks if block[1].startswith("restore_")
                 and block[1] != "restore_three" and block[0] == "excerpt"]
        self.assertEqual(len(cases), 5)
        result = self.check(self.document)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_multiline_signature_cannot_drop_arrow_domains(self):
        signature = next(block for block in self.blocks
                         if block[:2] == ("signature", "restore_three"))
        shortened = signature[2].replace("RArg<K, V> -> RArg<K, V> -> RArg<K, V> ->",
                                         "RArg<K, V> ->")
        self.assert_rejected(self.document.replace(self.marked(*signature),
                                                  self.marked("signature", "restore_three", shortened)),
                             "differs from canonical source")

    def test_removed_case_cannot_drop_required_coverage(self):
        case = next(block for block in self.blocks if block[:2] == ("excerpt", "restore_left_right"))
        self.assert_rejected(self.document.replace(self.marked(*case), "", 1),
                             "missing required fragment")

    def test_changed_group_in_one_case_is_rejected(self):
        case = next(block for block in self.blocks if block[:2] == ("excerpt", "restore_right_left"))
        changed = case[2].replace("(RArg(c, k3, v3))", "(RArg(b, k3, v3))")
        self.assert_rejected(self.document.replace(self.marked(*case),
                                                  self.marked("excerpt", "restore_right_left", changed)),
                             "differs from canonical source")

    def test_removed_repair_arg_declaration_is_rejected(self):
        declaration = next(block for block in self.blocks if block[:2] == ("excerpt", "repair_args"))
        self.assert_rejected(self.document.replace(self.marked(*declaration), "", 1),
                             "missing required fragment")

    def test_canonical_repair_arg_declaration_is_required(self):
        self.source.write_text(self.source.read_text().replace(
            "type RArg<K, V> = RArg(Dictionary<K, V>, K, V)\n", "", 1))
        self.assert_rejected(self.document, "canonical source must have one RArg declaration")

    def test_canonical_restore_case_cannot_go_missing(self):
        case = next(block for block in self.blocks if block[:2] == ("excerpt", "restore_left_right"))
        self.source.write_text(self.source.read_text().replace(case[2] + "\n", "", 1))
        self.assert_rejected(self.document, "canonical restore must contain five complete equations")

    def test_old_whole_dispatcher_marker_is_rejected(self):
        case = next(block for block in self.blocks if block[:2] == ("excerpt", "restore_left_left"))
        self.assert_rejected(self.document.replace(self.marked(*case),
                                                  self.marked("excerpt", "restore", case[2])),
                             "unknown fragment")

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
