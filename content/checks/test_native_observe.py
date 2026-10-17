"""Boundary checks for native observations; run real Ash pilots when configured."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

LIB = Path(__file__).with_name("lib.sh").resolve()


class NativeComparisonTests(unittest.TestCase):
    def observe(self, *, value="42\n", ty="Int\n", stderr="", status="0\n",
                observer_status=0, expected_value="42", expected_type="Int"):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            observer = root / "observer"
            observer.write_text(
                "#!/usr/bin/env python3\nimport pathlib,sys\n"
                "p=pathlib.Path(sys.argv[3]); p.mkdir()\n"
                + "\n".join(
                    f"(p/{name!r}).write_text({data!r})"
                    for name, data in [("result.stdout", value), ("result.type", ty),
                                       ("result.stderr", stderr), ("result.status", status)]
                ) + f"\nsys.exit({observer_status})\n"
            )
            observer.chmod(0o755)
            env = os.environ | {"ASH_DOC_VERIFY_DIR": str(root),
                                "ASH_DOC_NATIVE_OBSERVER": str(observer),
                                "ASH_DOC_LIBRARY_ROOT": str(root),
                                "EXPECTED_VALUE": expected_value,
                                "EXPECTED_TYPE": expected_type}
            result = subprocess.run(
                ["bash", "-c", 'set -euo pipefail; source "$1"; '
                 'ash_doc_run_native_accepted "$2" entry.ash "$EXPECTED_VALUE" "$EXPECTED_TYPE"',
                 "test", str(LIB), str(root)], env=env, text=True, capture_output=True,
            )
            self.assertFalse(list(root.glob("native-entry.*")), "per-entry artifacts leaked")
            return result

    def test_matching_separate_value_and_type(self):
        result = self.observe()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_type_is_rejected_even_with_correct_value(self):
        result = self.observe(expected_type="Bool")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("result type", result.stderr)

    def test_wrong_value_is_rejected(self):
        result = self.observe(value="41\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("standard output", result.stderr)

    def test_child_failure_is_rejected(self):
        result = self.observe(status="2\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("status 2", result.stderr)

    def test_unexpected_stderr_is_rejected(self):
        result = self.observe(stderr="failure\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("standard error", result.stderr)

    def test_build_failure_cannot_reuse_observation(self):
        result = self.observe(observer_status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("native observation failed", result.stderr)



class HumanCommandTests(unittest.TestCase):
    def check_mode(self, native):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            unit = root / 'content/effects/sample'
            unit.mkdir(parents=True)
            (unit / 'entry.ash').touch()
            option = ' --root ffi="$ASH_LIBRARIES"' if native else ''
            (unit / 'README.md').write_text(
                '<!-- diagnostic: entry.ash -->\n<!-- markdownlint-disable MD013 -->\n'
                '```text\n$ ash --message-format human --locale en' + option
                + ' entry.ash\nRejected.\n```\n')
            executable = root / 'ash'
            executable.write_text('#!/usr/bin/env python3\nimport sys\n'
                                  'sys.stderr.write("Rejected.\\n")\nsys.exit(1)\n')
            executable.chmod(0o755)
            env = os.environ | {'ASH_DOC_VERIFY_DIR': str(root),
                                'ASH_DOC_ASH_BIN': str(executable),
                                'ASH_DOC_LIBRARY_ROOT': str(root)}
            result = subprocess.run(
                ['bash', '-c', 'set -euo pipefail; source "$1"; '
                 'ash_doc_check_human "$2" entry.ash "$2"' + (' native' if native else ''),
                 'test', str(LIB), str(unit)], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_existing_human_command(self):
        self.check_mode(False)

    def test_native_human_command(self):
        self.check_mode(True)


@unittest.skipUnless(os.environ.get('ASH_DOC_TEST_OBSERVER'), 'requires prepared real observer')
class RealObserverTests(unittest.TestCase):
    def run_observer(self, source, *, stale=False, target=None):
        with tempfile.TemporaryDirectory(dir=os.environ['ASH_DOC_TEST_SCRATCH']) as directory:
            root = Path(directory)
            entry = root / 'entry.ash'; entry.write_text(source)
            output = root / 'observation'
            if stale:
                output.mkdir(); (output / 'program').write_text('stale executable')
            args = [os.environ['ASH_DOC_TEST_OBSERVER'], os.environ['ASH_DOC_TEST_LIBRARIES'],
                    str(entry), str(output), os.environ['ASH_DOC_TEST_CACHE']]
            if target:
                args.append(target)
            result = subprocess.run(args, capture_output=True, text=True, timeout=300)
            if result.returncode:
                self.assertFalse((output / 'result.status').exists())
            return result

    def test_stale_output_is_refused(self):
        result = self.run_observer('main : Unit -> Int\nmain () = 42\n', stale=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('fresh observation directory', result.stderr)

    def test_source_rejection_publishes_no_success(self):
        result = self.run_observer('main : Unit -> Int\nmain () = true\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('source compilation', result.stderr)

    def test_unsupported_target_publishes_no_success(self):
        result = self.run_observer('main : Unit -> Int\nmain () = 42\n', target='unsupported')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('native preparation', result.stderr)


    def test_real_native_value_does_not_hide_wrong_type(self):
        with tempfile.TemporaryDirectory(dir=os.environ['ASH_DOC_TEST_SCRATCH']) as directory:
            scratch = Path(directory)
            (scratch / 'target').symlink_to(os.environ['ASH_DOC_TEST_CACHE'], target_is_directory=True)
            unit = LIB.parent.parent / 'effects/acquiring-a-buffer'
            env = os.environ | {'ASH_DOC_NATIVE_OBSERVER': os.environ['ASH_DOC_TEST_OBSERVER'],
                                'ASH_DOC_LIBRARY_ROOT': os.environ['ASH_DOC_TEST_LIBRARIES'],
                                'ASH_DOC_VERIFY_DIR': str(scratch)}
            result = subprocess.run(
                ['bash', '-c', 'set -euo pipefail; source "$1"; '
                 'ash_doc_run_native_accepted "$2" src/01-zeroed-bytes.ash '
                 "'Success(Success(0))' Bool", 'test', str(LIB), str(unit)],
                env=env, capture_output=True, text=True, timeout=300)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('result type', result.stderr)
            self.assertFalse(list(scratch.glob('native-entry.*')))


class PinGuardTests(unittest.TestCase):
    def guard(self, *, actual='354c76b391fe4af665cf6a03479a9874a57cb3e3',
              prepared='354c76b391fe4af665cf6a03479a9874a57cb3e3', dirty=''):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            git = root / 'git'
            git.write_text('#!/usr/bin/env python3\nimport os,sys\n'
                           "if sys.argv[3:] == ['rev-parse','HEAD']: print(os.environ['FAKE_PIN'])\n"
                           "elif os.environ['FAKE_DIRTY']: print(os.environ['FAKE_DIRTY'])\n")
            git.chmod(0o755)
            env = os.environ | dict(PATH=str(root)+os.pathsep+os.environ['PATH'],
                                    FAKE_PIN=actual, FAKE_DIRTY=dirty,
                                    ASH_DOC_PREPARED_PIN=prepared, ASH_DOC_ASH_BIN='/bin/true',
                                    ASH_DOC_VERIFY_DIR=str(root))
            return subprocess.run(['bash', '-c', 'set -euo pipefail; source "$1"; '
                                   'ash_doc_prepare "$2"', 'test', str(LIB), str(root)],
                                  env=env, capture_output=True, text=True)

    def test_valid_prepared_pin(self):
        result = self.guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_checkout_pin(self):
        result = self.guard(actual='wrong')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('expected 354c76', result.stderr)

    def test_wrong_prepared_pin(self):
        result = self.guard(prepared='wrong')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('prepared Ash binary has the wrong pin', result.stderr)

    def test_dirty_checkout(self):
        result = self.guard(dirty=' M source.ash')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('checkout must be clean', result.stderr)


if __name__ == "__main__":
    unittest.main()
