"""Reject unsafe captures, false evidence, and stale displayed projections."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


CHECKS = Path(__file__).resolve().parent
TYPE = "(Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)"


def more(items):
    result = "End"
    for item in reversed(items):
        result = f"More({item}, {result})"
    return result


class PrefixObservationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.fixture = self.root / "prefix-matrix.stdout"
        self.readme = self.root / "README.md"
        scenarios = []
        for count in (7, 7, 3, 3, 3, 3):
            checks = more(["PrefixCheck(true, true, true, true)"] * count)
            lookups = more(["true"] * (count + 1))
            scenarios.append(f"Scenario(true, {checks}, {lookups})")
        self.capture = "(" + ", ".join(scenarios) + f") : {TYPE}\n"
        self.observations = {
            "empty": "true",
            "prefix_1": "PrefixCheck(true, true, true, true)",
            "prefix_2": "PrefixCheck(true, true, true, true)",
            "prefix_3": "PrefixCheck(true, true, true, true)",
            "lookups": "More(true, More(true, More(true, More(true, End))))",
        }
        self.table = "\n".join([
            "<!-- summary: prefix-matrix -->", "",
            "| Input order | Empty | Prefix checks | Final flags |",
            "| --- | --- | --- | --- |",
            "| Ascending `1` to `7` | `true` | 7 | 8 |",
            "| Descending `7` to `1` | `true` | 7 | 8 |",
            "| Left-left `3, 2, 1` | `true` | 3 | 4 |",
            "| Left-right `3, 1, 2` | `true` | 3 | 4 |",
            "| Right-left `1, 3, 2` | `true` | 3 | 4 |",
            "| Right-right `1, 2, 3` | `true` | 3 | 4 |",
        ])
        self.document = "\n\n".join(
            self.marked(name, value) for name, value in self.observations.items()
        ) + "\n\n" + self.table

    @staticmethod
    def marked(name, value):
        return (f"<!-- observation: prefix-matrix#left_left.{name} -->\n\n"
                f"```text\n{value}\n```")

    def check(self, document=None, capture=None):
        self.fixture.write_text(self.capture if capture is None else capture)
        self.readme.write_text((self.document if document is None else document) + "\n")
        return subprocess.run(
            [sys.executable, str(CHECKS / "check_prefix_observations.py"),
             str(self.readme), str(self.fixture)],
            text=True, capture_output=True, check=False,
        )

    def assert_rejected(self, *, document=None, capture=None, reason):
        result = self.check(document, capture)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(reason, result.stderr)

    def test_exact_observations_and_summary_pass(self):
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("5 captured value fields", result.stdout)
        self.assertIn("26 prefix checks", result.stdout)

    def test_altered_observation_is_rejected(self):
        self.assert_rejected(document=self.document.replace(
            "#left_left.empty -->\n\n```text\ntrue", "#left_left.empty -->\n\n```text\nfalse", 1),
            reason="differs from captured value")

    def test_type_suffix_cannot_be_invented(self):
        self.assert_rejected(document=self.document.replace(
            "#left_left.empty -->\n\n```text\ntrue", "#left_left.empty -->\n\n```text\ntrue : Bool", 1),
            reason="differs from captured value")

    def test_wrong_selected_component_is_rejected(self):
        self.assert_rejected(document=self.document.replace("left_left.prefix_1", "ascending.prefix_1", 1),
                             reason="unknown observation")

    def test_duplicate_observation_is_rejected(self):
        self.assert_rejected(document=self.document + "\n\n" + self.marked("empty", "true"),
                             reason="duplicate observation")

    def test_missing_observation_is_rejected(self):
        self.assert_rejected(document=self.document.replace(self.marked("prefix_2", self.observations["prefix_2"]), "", 1),
                             reason="missing required observation")

    def test_malformed_observation_marker_is_rejected(self):
        self.assert_rejected(document=self.document.replace("#left_left.empty -->", "#left_left.empty-->", 1),
                             reason="malformed observation marker")

    def test_executable_observation_is_rejected(self):
        self.assert_rejected(document=self.document.replace("```text", "```ash", 1),
                             reason="must immediately precede a text fence")

    def test_stale_summary_count_is_rejected(self):
        self.assert_rejected(document=self.document.replace("| 7 | 8 |", "| 8 | 9 |", 1),
                             reason="summary differs from captured scenarios")

    def test_stale_summary_order_is_rejected(self):
        self.assert_rejected(document=self.document.replace("Left-left `3, 2, 1`", "Left-left `3, 1, 2`", 1),
                             reason="summary differs from captured scenarios")

    def test_missing_summary_is_rejected(self):
        self.assert_rejected(document=self.document.replace(self.table, "", 1),
                             reason="missing required summary")

    def test_duplicate_summary_is_rejected(self):
        self.assert_rejected(document=self.document + "\n\n" + self.table,
                             reason="duplicate summary")

    def test_malformed_summary_marker_is_rejected(self):
        self.assert_rejected(document=self.document.replace("<!-- summary: prefix-matrix -->", "<!-- summary: prefix-matrix-->"),
                             reason="malformed summary marker")

    def test_capture_must_keep_complete_type(self):
        self.assert_rejected(capture=self.capture.replace(TYPE, "Scenario"),
                             reason="captured type")

    def test_capture_cannot_lose_scenario(self):
        self.assert_rejected(capture="(Scenario(true, End, End),) : " + TYPE + "\n",
                             reason="six Scenario values")

    def test_false_prefix_flag_is_rejected(self):
        self.assert_rejected(capture=self.capture.replace("PrefixCheck(true,", "PrefixCheck(false,", 1),
                             reason="must be true")

    def test_wrong_prefix_cardinality_is_rejected(self):
        self.assert_rejected(capture=self.capture.replace(
            "More(PrefixCheck(true, true, true, true), End)", "End", 1),
            reason="prefix cardinalities")

    def test_capture_cannot_use_unknown_constructor(self):
        self.assert_rejected(capture=self.capture.replace("PrefixCheck", "UnknownCheck", 1),
                             reason="PrefixCheck")

    def test_capture_cannot_use_keywords(self):
        capture = "(" + ", ".join(["Scenario(initial=true, checks=End, lookups=End)"] * 6) + f") : {TYPE}\n"
        self.assert_rejected(capture=capture,
                             reason="Scenario")

    def test_capture_cannot_run_python(self):
        self.assert_rejected(capture=self.capture.replace("PrefixCheck(true,", "PrefixCheck(__import__('os').system('false'),", 1),
                             reason="must be true")

    def test_capture_must_be_one_complete_stdout_line(self):
        self.assert_rejected(capture=self.capture + "extra output\n",
                             reason="one complete stdout line")

    def test_capture_syntax_error_is_reported(self):
        self.assert_rejected(capture=self.capture.replace("(Scenario", "(Scenario(", 1),
                             reason="invalid captured value")


if __name__ == "__main__":
    unittest.main()
