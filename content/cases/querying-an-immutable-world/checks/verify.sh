#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

[[ $# -eq 1 ]] || ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"

readonly sources=(
    src/01-direct-movement.ash
    src/02-generic-movement.ash
    src/03-repeated-step.ash
    src/04-store-boundaries.ash
    src/05-positional-zip.ash
    src/06-missing-evidence.ash
    src/07-wrong-component.ash
    src/stores.ash
    src/systems.ash
    src/world.ash
)
for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] || ash_doc_fail "missing canonical source: $source"
done

# Independent literal rows fixed before running Ash. No movement or join
# algorithm computes these expected stores from the input fixtures.
readonly original_rows='Row(EntityId(1), Position(10, 5), Row(EntityId(2), Position(20, 7), Row(EntityId(3), Position(30, 9), NoRows)))'
readonly first_rows='Row(EntityId(1), Position(12, 4), Row(EntityId(2), Position(20, 7), Row(EntityId(3), Position(31, 11), NoRows)))'
readonly second_rows='Row(EntityId(1), Position(14, 3), Row(EntityId(2), Position(20, 7), Row(EntityId(3), Position(32, 13), NoRows)))'
readonly velocity_rows='Row(EntityId(3), Velocity(1, 2), Row(EntityId(1), Velocity(2, -1), Row(EntityId(4), Velocity(9, 9), NoRows)))'
readonly joined_rows='Row(EntityId(1), (Position(10, 5), Velocity(2, -1)), Row(EntityId(3), (Position(30, 9), Velocity(1, 2)), NoRows))'
readonly wrong_rows='Row(EntityId(1), (EntityId(3), Position(10, 5), Velocity(1, 2)), Row(EntityId(2), (EntityId(1), Position(20, 7), Velocity(2, -1)), Row(EntityId(3), (EntityId(4), Position(30, 9), Velocity(9, 9)), NoRows)))'
readonly wrong_positions='Row(EntityId(1), Position(11, 7), Row(EntityId(2), Position(22, 6), Row(EntityId(3), Position(39, 18), NoRows)))'
readonly replaced_rows='Row(EntityId(1), Position(99, 98), Row(EntityId(2), Position(20, 7), Row(EntityId(3), Position(30, 9), NoRows)))'
readonly inserted_rows='Row(EntityId(1), Position(10, 5), Row(EntityId(2), Position(20, 7), Row(EntityId(3), Position(30, 9), Row(EntityId(4), Position(40, 12), NoRows))))'
readonly original_world="World(Store($original_rows), Store($velocity_rows))"
readonly first_world="World(Store($first_rows), Store($velocity_rows))"
readonly second_world="World(Store($second_rows), Store($velocity_rows))"
readonly empty_world='World(Store(NoRows), Store(NoRows))'
readonly observation="($joined_rows, $first_world, $original_world) : (Rows<(Position, Velocity)>, World, World)"
readonly repeated="($original_world, $first_world, $second_world) : (World, World, World)"
readonly boundaries="($replaced_rows, $inserted_rows, None, $empty_world, World(Store($original_rows), Store(NoRows)), World(Store(NoRows), Store($velocity_rows))) : (Rows<Position>, Rows<Position>, Option<Position>, World, World, World)"
readonly zipped="($wrong_rows, $wrong_positions, $joined_rows) : (Rows<(EntityId, Position, Velocity)>, Rows<Position>, Rows<(Position, Velocity)>)"

ash_doc_prepare "$1"
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -printf 'src/%P\n' | LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"

ash_doc_run_accepted "$unit_root" src/01-direct-movement.ash "$observation"
ash_doc_run_accepted "$unit_root" src/02-generic-movement.ash "$observation"
ash_doc_run_accepted "$unit_root" src/03-repeated-step.ash "$repeated"
ash_doc_run_accepted "$unit_root" src/04-store-boundaries.ash "$boundaries"
ash_doc_run_accepted "$unit_root" src/05-positional-zip.ash "$zipped"

for rejected in 06-missing-evidence 07-wrong-component; do
    ash_doc_run_rejected "$unit_root" "src/$rejected.ash" 1
    ash_doc_check_human "$unit_root" "src/$rejected.ash" "$content_root/cases"
done

# Execute each minimal correction without adding another canonical example.
# Imports remain relative to a temporary copy of this Case's three modules.
repair_root=$(mktemp -d "$ASH_DOC_VERIFY_DIR/repairs.XXXXXX")
readonly repair_root
mkdir "$repair_root/src"
cp "$unit_root"/src/{stores,systems,world}.ash "$repair_root/src/"
python3 - "$unit_root" "$repair_root" <<'PYTHON'
from pathlib import Path
import sys

unit, repairs = map(Path, sys.argv[1:])
for name, old, new in [
    ("06-missing-evidence.ash", "import world (World, initial)",
     "import world (World, initial, impl StoreAccess)"),
    ("07-wrong-component.ash", "Velocity(2, 1)", "Position(2, 1)"),
]:
    source = (unit / "src" / name).read_text()
    assert source.count(old) == 1
    (repairs / "src" / name).write_text(source.replace(old, new))
PYTHON
ash_doc_run_accepted "$repair_root" src/06-missing-evidence.ash "$first_world : World"
ash_doc_run_accepted "$repair_root" src/07-wrong-component.ash \
    'Store(Row(EntityId(1), Position(2, 1), NoRows)) : Store<Position>'
printf 'Verified both minimal repairs.\n'

python3 - "$unit_root" "$original_rows" "$first_rows" "$second_rows" \
    "$velocity_rows" "$joined_rows" "$wrong_rows" "$wrong_positions" \
    "$replaced_rows" "$inserted_rows" "$boundaries" <<'PYTHON'
import json
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
(original, first, second, velocities, joined, wrong, wrong_positions,
 replaced, inserted, boundaries) = sys.argv[2:]
read = lambda name: (root / "src" / name).read_text()

expected_sources = {
    "01-direct-movement.ash", "02-generic-movement.ash", "03-repeated-step.ash",
    "04-store-boundaries.ash", "05-positional-zip.ash", "06-missing-evidence.ash",
    "07-wrong-component.ash", "stores.ash", "systems.ash", "world.ash",
}
expected_files = {"README.md", "checks/verify.sh"}
expected_files.update("src/" + name for name in expected_sources)
expected_files.update("checks/" + name + ".diagnostic.json" for name in [
    "06-missing-evidence", "07-wrong-component",
])
assert {str(p.relative_to(root)) for p in root.rglob("*") if p.is_file()} == expected_files

# The labels must identify the source relationships the explanation teaches,
# independently of exact-edition human wording and the semantic JSON check.
causes = {
    "06-missing-evidence": [
        ("interface_obligation", "06-missing-evidence.ash", "move_world"),
        ("obligation_declaration", "systems.ash", "move_world"),
        ("declaration_import", "06-missing-evidence.ash", "move_world"),
        ("selection_interface", "systems.ash", "pub interface StoreAccess<W, C> {\n    component_store : W -> Store<C>\n    replace_store : (W, Store<C>) -> W\n}"),
    ],
    "07-wrong-component": [
        ("definition_result", "07-wrong-component.ash", "put(EntityId(1), Velocity(2, 1), empty())"),
        ("result_annotation", "07-wrong-component.ash", "Store<Position>"),
    ],
}
for stem, expected in causes.items():
    diagnostic = json.loads((root / "checks" / (stem + ".diagnostic.json")).read_text())
    labels = diagnostic["labels"]
    assert len(labels) == len(expected)
    for label, (relationship, name, snippet) in zip(labels, expected, strict=True):
        assert label["relationship"] == relationship
        assert label["path"] == "src/" + name
        source = (root / label["path"]).read_bytes()
        assert source[label["byte_start"]:label["byte_end"]].decode() == snippet

# Guard the boundaries relied on by the preservation argument and the repairs.
stores = read("stores.ash")
systems = read("systems.ash")
world = read("world.ash")
assert "pub opaque type Store<C> = Store(Rows<C>)" in stores
assert re.findall(r"^pub (\w+) : .* -> Store<C>$", stores, re.M) == ["empty", "put"]
assert "pub interface StoreAccess<W, C> {" in systems
assert "where W -> C" not in systems
assert "import world" not in systems and "import systems" not in stores
assert "let positions : Store<Position> = component_store world" in systems
assert "let velocities : Store<Velocity> = component_store world" in systems
assert "pub impl StoreAccess<World, Position> {" in world
assert "pub impl StoreAccess<World, Velocity> {" in world
assert "impl StoreAccess" not in read("06-missing-evidence.ash")
assert "import world (World, initial, impl StoreAccess)" in read("02-generic-movement.ash")
assert "StoreAccess" not in read("07-wrong-component.ash")
assert "foreign library FixtureNumbers {\n    profile \"x86_64-unknown-linux-gnu\"\n    repr Signed = signed(64)\n    const DecreaseOne : Signed = -1\n}" in world
assert "Velocity(2, DecreaseOne)" in world
assert "symbol " not in world and "perform " not in world

# Every summary selects from the same complete literal observations verified
# above. Reconstruct only the displayed representation, never movement logic.
text = (root / "README.md").read_text()
assert text.count("```text\n" + joined + "\n```") == 1
assert "Its type is `(Rows<(Position, Velocity)>, World, World)`." in text
assert "The single result has type `(World, World, World)`, in original, first, and" in text
tables = re.findall(r"(?:^\|.*\|\n)+", text, re.M)
assert len(tables) == 5
def rows(table):
    return [[cell.strip() for cell in line.strip().strip("|").split("|")]
            for line in table.splitlines()[2:]]

def coordinate(text):
    match = re.fullmatch(r"\((-?\d+), (-?\d+)\)", text)
    assert match, text
    return tuple(map(int, match.groups()))

def render_rows(items, component):
    result = "NoRows"
    for entity, (x, y) in reversed(items):
        result = f"Row(EntityId({entity}), {component}({x}, {y}), {result})"
    return result

position_input = [(int(e), coordinate(p)) for e, p in rows(tables[0])]
velocity_input = [(int(e), coordinate(v)) for e, v in rows(tables[1])]
assert render_rows(position_input, "Position") == original
assert render_rows(velocity_input, "Velocity") == velocities
snapshots = rows(tables[2])
for column, expected in enumerate([original, first, second], 1):
    selected = [(int(row[0]), coordinate(row[column])) for row in snapshots]
    assert render_rows(selected, "Position") == expected

assert rows(tables[3]) == [
    ["1", "Replace position 1", "IDs 1, 2, 3; position 1 is (99, 98)"],
    ["2", "Insert position 4", "IDs 1, 2, 3, 4; position 4 is (40, 12)"],
    ["3", "Look up absent position 4", "`None`"],
    ["4", "Move two empty stores", "Both stores are empty"],
    ["5", "Move with no velocities", "All original positions remain"],
    ["6", "Move with no positions", "No positions; all original velocities remain"],
]
assert re.findall(r"EntityId\((\d+)\)", replaced) == ["1", "2", "3"]
assert "Position(99, 98)" in replaced
assert re.findall(r"EntityId\((\d+)\)", inserted) == ["1", "2", "3", "4"]
assert "Position(40, 12)" in inserted
assert boundaries == (
    f"({replaced}, {inserted}, None, World(Store(NoRows), Store(NoRows)), "
    f"World(Store({original}), Store(NoRows)), World(Store(NoRows), Store({velocities})))"
    " : (Rows<Position>, Rows<Position>, Option<Position>, World, World, World)"
)

zipped = rows(tables[4])
assert render_rows([(int(e), coordinate(p)) for e, _, p in zipped], "Position") == wrong_positions
position_map, velocity_map = dict(position_input), dict(velocity_input)
rendered = "NoRows"
for entity, other, _ in reversed(zipped):
    x, y = position_map[int(entity)]
    dx, dy = velocity_map[int(other)]
    rendered = (f"Row(EntityId({entity}), (EntityId({other}), Position({x}, {y}), "
                f"Velocity({dx}, {dy})), {rendered})")
assert rendered == wrong
PYTHON

ash_doc_finish 10
