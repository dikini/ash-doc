"""Run fixed private-helper probes using the canonical defining module."""

from pathlib import Path
import subprocess
import sys
import tempfile


MAIN_SIGNATURE = "main : Unit -> (Bool, Bool, Bool, Bool, Bool)\n"


def natural(number):
    return "Next(" * number + "Zero" + ")" * number


def node(color, left, key, value, right):
    return f"Node({color}, {left}, {natural(key)}, {value}, {right})"


def expected_output():
    a, b, c, d = (node("Black", "Empty", key, key * 11, "Empty")
                  for key in (1, 3, 5, 7))
    repaired = node("Red", node("Black", a, 2, 22, b), 4, 44,
                    node("Black", c, 6, 66, d))
    temporary = node("Red", node("Red", a, 2, 22, b), 4, 44, c)
    discriminator = node("Red", temporary, 6, 66, d)
    cases = [(repaired, True, True, False, True)] * 5 + [
        (node("Black", a, 2, 22, b), True, True, True, True),
        (node("Red", a, 2, 22, b), True, True, False, True),
        (temporary, True, False, False, True),
        (discriminator, True, False, False, False),
    ]
    observations = ["RepairObservation(" + tree + ", " +
                    ", ".join(str(flag).lower() for flag in flags) + ")"
                    for tree, *flags in cases]
    reported_type = "(" + ", ".join(["RepairObservation"] * len(cases)) + ")"
    return "(" + ", ".join(observations) + ") : " + reported_type + "\n"


def check_repair_cases(source, fixture, binary):
    if source.count(MAIN_SIGNATURE) != 1:
        raise ValueError("canonical module must contain one private matrix main")
    definitions = source.split(MAIN_SIGNATURE)[0]
    with tempfile.TemporaryDirectory(prefix="ash-doc-repair-cases-") as temporary:
        entry = Path(temporary) / "repair-cases.ash"
        entry.write_text(definitions + fixture)
        result = subprocess.run(
            [str(binary), "--message-format", "human", "--locale", "en", str(entry)],
            capture_output=True, text=True, check=False,
        )
    if result.returncode != 0 or result.stderr:
        raise ValueError(f"private repair probes exited {result.returncode}: {result.stderr}")
    if result.stdout != expected_output():
        raise ValueError("private repair probes changed a tree, association, or invariant observation")


def main():
    if len(sys.argv) != 4:
        print("usage: check_repair_cases.py dictionaries.ash repair-cases.ash /path/to/ash", file=sys.stderr)
        return 1
    try:
        check_repair_cases(Path(sys.argv[1]).read_text(), Path(sys.argv[2]).read_text(),
                           Path(sys.argv[3]))
    except (OSError, ValueError) as error:
        print(f"verify: {error}", file=sys.stderr)
        return 1
    print("Verified grouped helper, four repairs, and four fallback boundaries with distinct nonempty subtrees.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
