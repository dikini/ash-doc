#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi
ash_doc_prepare "$1"

readonly sources=(
    src/01-explicit-policy.ash
    src/02-imported-policy.ash
    src/03-local-policy.ash
    src/04-nested-policies.ash
    src/05-returned-closure.ash
    src/06-boundary-orders.ash
    src/07-mixed-units-fixed.ash
    src/07-mixed-units.ash
    src/08-before-evidence-fixed.ash
    src/08-before-evidence.ash
    src/09-local-escape.ash
    src/base_policy.ash
    src/orders.ash
    src/pricing.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -printf 'src/%P\n' | LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"

# These are independent literal prices, not equality between implementations.
# Keep one observation table for execution and displayed-summary agreement.
readonly accepted_sources=(
    01-explicit-policy.ash
    02-imported-policy.ash
    03-local-policy.ash
    04-nested-policies.ash
    05-returned-closure.ash
    06-boundary-orders.ash
    07-mixed-units-fixed.ash
    08-before-evidence-fixed.ash
)
readonly accepted_observations=(
    'Priced(4900) : Quote'
    'Priced(4900) : Quote'
    '(Priced(5400), Priced(5900)) : (Quote, Quote)'
    '(Priced(5400), Priced(5900), Priced(5400)) : (Quote, Quote, Quote)'
    '(Priced(5400), Priced(5900), Priced(5400)) : (Quote, Quote, Quote)'
    '(Priced(0), Priced(0), Unavailable, Unavailable, Unavailable, Unavailable, Unavailable, Unavailable, Priced(0)) : (Quote, Quote, Quote, Quote, Quote, Quote, Quote, Quote, Quote)'
    '4000 : Money'
    'Priced(5400) : Quote'
)
for index in "${!accepted_sources[@]}"; do
    ash_doc_run_accepted "$unit_root" "src/${accepted_sources[$index]}" \
        "${accepted_observations[$index]}"
done

for rejected in 07-mixed-units 08-before-evidence 09-local-escape; do
    ash_doc_run_rejected "$unit_root" "src/$rejected.ash" 1
    ash_doc_check_human "$unit_root" "src/$rejected.ash" "$content_root/cases"
done

# Check the causal source relationships taught beside the diagnostics separately
# from the shared exact JSON and human-message comparisons.
python3 - "$unit_root" "${accepted_sources[@]}" -- \
    "${accepted_observations[@]}" <<'PYTHON'
import json
import re
from pathlib import Path
import sys

root = Path(sys.argv[1])
read = lambda name: (root / "src" / name).read_text()
expected_files = {"README.md", "checks/verify.sh"}
expected_files.update("src/" + name for name in [
    "01-explicit-policy.ash", "02-imported-policy.ash", "03-local-policy.ash",
    "04-nested-policies.ash", "05-returned-closure.ash", "06-boundary-orders.ash",
    "07-mixed-units.ash", "07-mixed-units-fixed.ash", "08-before-evidence.ash",
    "08-before-evidence-fixed.ash", "09-local-escape.ash", "orders.ash",
    "pricing.ash", "base_policy.ash",
])
stems = ["07-mixed-units", "08-before-evidence", "09-local-escape"]
expected_files.update("checks/" + name + ".diagnostic.json" for name in stems)
actual_files = {str(path.relative_to(root)) for path in root.rglob("*") if path.is_file()}
assert actual_files == expected_files, (actual_files - expected_files, expected_files - actual_files)

causes = {
    "07-mixed-units": [
        ("argument", "src/07-mixed-units.ash", "(Money(2000), Money(2))"),
        ("function_domain", "src/orders.ash", "line_total"),
        ("application", "src/07-mixed-units.ash", "line_total (Money(2000), Money(2))"),
    ],
    "08-before-evidence": [
        ("interface_obligation", "src/08-before-evidence.ash", "quote_order"),
        ("obligation_declaration", "src/pricing.ash", "quote_order"),
        ("declaration_import", "src/08-before-evidence.ash", "quote_order"),
        ("selection_interface", "src/pricing.ash", "pub interface PricePolicy<P> {\n    unit_price : (P, Orders.Product) -> Orders.Quote\n}"),
    ],
    "09-local-escape": [
        ("escaping_dependency", "src/09-local-escape.ash", "TariffPolicy(())"),
        ("local_nominal_scope", "src/09-local-escape.ash", "newtype TariffPolicy = TariffPolicy(Unit)"),
    ],
}
for stem, expected_labels in causes.items():
    diagnostic = json.loads((root / "checks" / (stem + ".diagnostic.json")).read_text())
    actual_labels = []
    for label in diagnostic["labels"]:
        source = (root / label["path"]).read_bytes()
        excerpt = source[label["byte_start"]:label["byte_end"]].decode()
        actual_labels.append((label["relationship"], label["path"], excerpt))
    assert actual_labels == expected_labels, (stem, actual_labels)

mixed = read("07-mixed-units.ash")
assert read("07-mixed-units-fixed.ash") == mixed.replace(
    "(Money, line_total)", "(Money, Quantity, line_total)"
).replace("Money(2)", "Quantity(2)")

before = read("08-before-evidence.ash")
call = "    let before = quote_order (TariffPolicy(()), Orders.sample_order ())\n"
assert before.index(call) < before.index("    with PricePolicy<TariffPolicy>")
fixed = before.replace(call, "").replace(
    "    before\n", call.replace("before", "quoted") + "    quoted\n"
)
assert read("08-before-evidence-fixed.ash") == fixed
assert fixed.index("    with PricePolicy<TariffPolicy>") < fixed.index("let quoted")

closure = read("05-returned-closure.ash")
assert "make_pricer : Int -> (Orders.Order -> Orders.Quote)" in closure
assert closure.index("with PricePolicy<TariffPolicy>") < closure.index("fn(order)")
assert "fn(order) {\n        quote_order (policy, order)\n    }" in closure
assert "(first order, second order, first order)" in closure

nested = read("04-nested-policies.ash")
assert nested.count("with PricePolicy<OuterPolicy>") == 1
assert nested.count("with PricePolicy<InnerPolicy>") == 1
assert "let before = quote_order (OuterPolicy(()), order)" in nested
assert "quote_order (InnerPolicy(()), order)" in nested
assert "let after = quote_order (OuterPolicy(()), order)" in nested

# Both line prices precede the availability match, including zero-count lines.
orders = read("orders.ash")
assert orders.index("let first_price = unit_price first") < orders.index("let second_price = unit_price second") < orders.index("match (first_price, second_price)")
assert "line_total (left, first_count)" in orders
assert "line_total (right, second_count)" in orders
assert "pub newtype Money = Money(Int)" in orders
assert "pub newtype Quantity = Quantity(Int)" in orders

# Every displayed successful line and the ordered table agree with the
# independently asserted observations above; the table is one tuple's fields.
readme = (root / "README.md").read_text()
separator = sys.argv.index("--")
accepted = dict(zip(sys.argv[2:separator], sys.argv[separator + 1:], strict=True))
for source, observation in accepted.items():
    if source == "06-boundary-orders.ash":
        continue
    command = "$ ash supplying-a-local-pricing-policy/src/" + source
    assert readme.count(command + "\n" + observation + "\n") == 1, source
boundary_rows = re.findall(
    r"^\| ([1-9]) \| ([^|]+) \| `([^`]+)` \| `([^`]+)` \|$", readme, re.M
)
assert boundary_rows == [
    ("1", "Explicit zero prices", "(2, 3)", "Priced(0)"),
    ("2", "Explicit base prices", "(0, 0)", "Priced(0)"),
    ("3", "Explicit books only", "(2, 3)", "Unavailable"),
    ("4", "Explicit pens only", "(0, 3)", "Unavailable"),
    ("5", "Explicit books only", "(2, 0)", "Unavailable"),
    ("6", "Explicit books only", "(0, 0)", "Unavailable"),
    ("7", "Local missing-pen policy", "(2, 3)", "Unavailable"),
    ("8", "Local missing-pen policy", "(2, 0)", "Unavailable"),
    ("9", "Local free policy", "(2, 3)", "Priced(0)"),
]
table_observation = "(" + ", ".join(row[3] for row in boundary_rows) + ") : (" + ", ".join(["Quote"] * len(boundary_rows)) + ")"
assert table_observation == accepted["06-boundary-orders.ash"]

# An arithmetic reference uses cents and counts independently of Ash helpers.
books, pens = 2, 3
book_cents, pen_cents = 2000, 300
assert books * book_cents + pens * pen_cents == 4900
assert books * (book_cents + 100) + pens * (pen_cents + 100) == 5400
assert books * (book_cents + 200) + pens * (pen_cents + 200) == 5900
PYTHON

ash_doc_finish 14
