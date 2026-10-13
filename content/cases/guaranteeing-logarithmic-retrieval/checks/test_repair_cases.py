"""Ensure distinct nonempty probes reject type-correct wiring mistakes."""

import os
from pathlib import Path
import unittest

from check_repair_cases import check_repair_cases


UNIT = Path(__file__).resolve().parent.parent
BINARY = os.environ.get("ASH_DOC_ASH_BIN")


@unittest.skipUnless(BINARY and Path(BINARY).is_file(), "requires the prepared pinned Ash binary")
class RepairCaseMutationTests(unittest.TestCase):
    def setUp(self):
        self.source = (UNIT / "src/dictionaries.ash").read_text()
        self.fixture = (UNIT / "fixtures/repair-cases.ash").read_text()

    def assert_wiring_rejected(self, old, new):
        self.assertIn(old, self.source)
        changed = self.source.replace(old, new, 1)
        with self.assertRaisesRegex(ValueError, "changed a tree, association, or invariant observation"):
            check_repair_cases(changed, self.fixture, Path(BINARY))

    def test_reusing_second_group_as_third_is_rejected(self):
        self.assert_wiring_rejected("let RArg(c, k3, v3) = third",
                                    "let RArg(c, k3, v3) = second")

    def test_left_left_case_cannot_exchange_nonempty_subtrees(self):
        self.assert_wiring_rejected("        (RArg(a, k1, v1))",
                                    "        (RArg(b, k1, v1))")

    def test_fallback_cannot_blacken_the_supplied_red_root(self):
        self.assert_wiring_rejected("restore color RArg(a, k, v) b = Node(color, a, k, v, b)",
                                    "restore color RArg(a, k, v) b = Node(Black, a, k, v, b)")


if __name__ == "__main__":
    unittest.main()
