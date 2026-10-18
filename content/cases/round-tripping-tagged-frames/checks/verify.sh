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

# Hand-calculated format and channel oracles, before either implementation.
readonly ping='Byte(0, End)'
readonly reading_zero='Byte(1, Byte(0, End))'
readonly reading_max='Byte(1, Byte(255, End))'
readonly pair_forward='Byte(2, Byte(0, Byte(255, End)))'
readonly pair_reverse='Byte(2, Byte(255, Byte(0, End)))'
readonly decoded_ping='Success(Success(Decoded(Ping)))'
readonly decoded_zero='Success(Success(Decoded(Reading(0))))'
readonly decoded_max='Success(Success(Decoded(Reading(255))))'
readonly decoded_forward='Success(Success(Decoded(Pair(0, 255))))'
readonly decoded_reverse='Success(Success(Decoded(Pair(255, 0))))'
readonly result_type='Outcome<Outcome<DecodeResult>>'
readonly checked_five="Checked($decoded_ping, Checked($decoded_zero, Checked($decoded_max, Checked($decoded_forward, Checked($decoded_reverse, Done)))))"
readonly round_trips="(($ping, $reading_zero, $reading_max, $pair_forward, $pair_reverse), $checked_five, $checked_five)"
readonly round_trip_type="((ByteValues, ByteValues, ByteValues, ByteValues, ByteValues), Checks, Checks)"
readonly truncated='Success(Success(Truncated))'
readonly malformed="Checked(Success(Success(BadTag)), Checked($truncated, Checked($truncated, Checked(Success(Success(TrailingData)), Checked($truncated, Checked($truncated, Checked($decoded_ping, Done)))))))"
readonly malformed_type='Checks'
readonly failures='(Success(Failure(InvalidIndex)), Failure(InvalidLength), (Failure(InvalidLength), 0), Success(Failure(InvalidByte)), Success(Success(WriteControl(Failure(InvalidByte), Success(42)))))'
readonly failure_type="($result_type, $result_type, (Outcome<Outcome<Unit>>, Int), $result_type, Outcome<Outcome<WriteControl>>)"
readonly swapped="($pair_reverse, $decoded_reverse)"
readonly swapped_type="(ByteValues, $result_type)"

readonly sources=(
    src/01-round-trips.ash
    src/02-malformed.ash
    src/03-buffer-failures.ash
    src/04-swapped-pair.ash
    src/05-escaping-cursor.ash
    src/06-decode-in-scope.ash
    src/codec.ash
    src/frames.ash
)
mapfile -t actual_sources < <(
    find "$unit_root/src" -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"
ash_doc_check_sources "$unit_root" "$unit_root/README.md" "${sources[@]}"
ash_doc_prepare_native
ash_doc_run_native_accepted "$unit_root" src/01-round-trips.ash "$round_trips" "$round_trip_type"
ash_doc_run_native_accepted "$unit_root" src/02-malformed.ash "$malformed" "$malformed_type"
ash_doc_run_native_accepted "$unit_root" src/03-buffer-failures.ash "$failures" "$failure_type"
ash_doc_run_native_accepted "$unit_root" src/04-swapped-pair.ash "$swapped" "$swapped_type"
ash_doc_run_native_accepted "$unit_root" src/06-decode-in-scope.ash "$decoded_forward" "$result_type"
ash_doc_run_rejected "$unit_root" src/05-escaping-cursor.ash 1 native
ash_doc_check_human "$unit_root" src/05-escaping-cursor.ash "$unit_root/src" native
python3 - "$unit_root" "$round_trips" "$malformed" "$failures" \
    "$swapped" "$decoded_forward" <<'PY_CHECK'
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
readme = (root / "README.md").read_text()
sources = {path.name: path.read_text() for path in (root / "src").glob("*.ash")}

# These values have already been compared in full with the native captures.
# Parse their ordinary printed structure to check projections independently.
def parse_value(text):
    tokens = re.findall(r"[A-Za-z_][A-Za-z_0-9]*|-?[0-9]+|[(),]", text)
    assert "".join(tokens) == re.sub(r"\s+", "", text)
    position = 0

    def value():
        nonlocal position
        token = tokens[position]
        position += 1
        if token == "(":
            items = []
            if tokens[position] != ")":
                items.append(value())
                while tokens[position] == ",":
                    position += 1
                    items.append(value())
            assert tokens[position] == ")"
            position += 1
            return tuple(items)
        if re.fullmatch(r"-?[0-9]+", token):
            return int(token)
        fields = []
        if position < len(tokens) and tokens[position] == "(":
            position += 1
            if tokens[position] != ")":
                fields.append(value())
                while tokens[position] == ",":
                    position += 1
                    fields.append(value())
            assert tokens[position] == ")"
            position += 1
        return (token, *fields)

    result = value()
    assert position == len(tokens)
    return result


def byte_values(value):
    result = []
    while value != ("End",):
        name, item, value = value
        assert name == "Byte" and 0 <= item <= 255
        result.append(item)
    return result


def decoded(message):
    return ("Success", ("Success", ("Decoded", message)))


# Table rows are projections of the SAME complete checked literal captures.
def table(marker):
    tail = readme.split(f"<!-- {marker} -->", 1)[1]
    lines = tail.splitlines()
    rows = []
    started = False
    for line in lines:
        if line.startswith("|"):
            started = True
            rows.append([cell.strip() for cell in line.strip("|").split("|")])
        elif started:
            break
    assert len(rows) >= 3
    return rows[2:]


def code(cell):
    assert cell.startswith("`") and cell.endswith("`")
    return cell[1:-1]


messages = [("Ping",), ("Reading", 0), ("Reading", 255),
            ("Pair", 0, 255), ("Pair", 255, 0)]
goldens = [[0], [1, 0], [1, 255], [2, 0, 255], [2, 255, 0]]
def checked_values(value):
    results = []
    while value != ("Done",):
        name, item, value = value
        assert name == "Checked"
        results.append(item)
    return results


encoded, direct, round_trip = parse_value(sys.argv[2])
direct = checked_values(direct)
round_trip = checked_values(round_trip)
assert [byte_values(item) for item in encoded] == goldens
assert list(direct) == [decoded(message) for message in messages]
assert list(round_trip) == [decoded(message) for message in messages]
rows = table("golden-observations: src/01-round-trips.ash")
assert len(rows) == 5
for row, message, golden, first, second in zip(
        rows, messages, goldens, direct, round_trip):
    assert parse_value(code(row[0])) == message
    assert json.loads(code(row[1])) == golden
    assert parse_value(code(row[2])) == first
    assert parse_value(code(row[3])) == second

malformed = checked_values(parse_value(sys.argv[3]))
expected_malformed = [("BadTag",), ("Truncated",), ("Truncated",),
                      ("TrailingData",), ("Truncated",), ("Truncated",),
                      ("Decoded", ("Ping",))]
assert list(malformed) == [("Success", ("Success", item))
                           for item in expected_malformed]
malformed_inputs = [(1, [9]), (1, [1]), (2, [2, 7]), (2, [0, 9]),
                    (1, []), (2, [1]), (3, [0])]
rows = table("malformed-observations: src/02-malformed.ash")
assert len(rows) == 7
for row, (capacity, supplied), observation in zip(rows, malformed_inputs, malformed):
    assert int(code(row[0])) == capacity
    assert json.loads(code(row[1])) == supplied
    assert parse_value(code(row[2])) == observation

failures = parse_value(sys.argv[4])
assert failures == (
    ("Success", ("Failure", ("InvalidIndex",))),
    ("Failure", ("InvalidLength",)),
    (("Failure", ("InvalidLength",)), 0),
    ("Success", ("Failure", ("InvalidByte",))),
    ("Success", ("Success", ("WriteControl", ("Failure", ("InvalidByte",)),
                              ("Success", 42)))))
rows = table("buffer-observations: src/03-buffer-failures.ash")
assert len(rows) == 5
assert [parse_value(code(row[1])) for row in rows] == list(failures)

for filename, observation in [("04-swapped-pair.ash", sys.argv[5]),
                              ("06-decode-in-scope.ash", sys.argv[6])]:
    match = re.search(r"<!-- observation: src/" + re.escape(filename)
                      + r" -->\n<!-- markdownlint-disable MD013 -->\n```text\n(.*?)\n```",
                      readme, re.S)
    assert match and match.group(1) == observation
swapped_bytes, swapped_result = parse_value(sys.argv[5])
assert byte_values(swapped_bytes) == [2, 255, 0] != goldens[3]
assert swapped_result == decoded(("Pair", 255, 0))
assert parse_value(sys.argv[6]) == decoded(("Pair", 0, 255))

# Preserve the concrete causes taught by the chapter, beyond output equality.
codec = sources["codec.ash"]
write_all = codec.split("write_all (buffer, Frames.Byte(value, rest), index) =", 1)[1]
write_all = write_all.split("\nfinish :", 1)[0]
assert "match Buffer.write (buffer, index, value) {" in write_all
assert "Buffer.Failure(error) => Buffer.Failure error" in write_all
assert "Buffer.Success(()) => write_all (buffer, rest, index + 1)" in write_all
assert write_all.count("Buffer.write") == 1
run_frame = codec.split("run_frame (capacity, byte_values) =", 1)[1]
assert "let logical_length = byte_count byte_values" in run_frame
assert "resource Buffer.Buffer<R> buffer = capacity {" in run_frame
assert "match write_all (buffer, byte_values, 0) {" in run_frame
assert "Buffer.Failure(error) => Buffer.Failure error" in run_frame
assert "Buffer.Success(()) => resource cell<C> position = 0 {" in run_frame
assert "handle (decode ()) with Cursor {" in run_frame
assert "read_next (buffer, position, logical_length)" in run_frame
assert run_frame.count("resource Buffer.Buffer") == 1
assert run_frame.count("decode ()") == 1
assert "Buffer.length" not in codec
assert "Int, Frames.ByteValues\n) -> Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>" in codec
read_next = codec.split("read_next (buffer, position, logical_length) =", 1)[1]
read_next = read_next.split("\npub run_frame", 1)[0]
assert "let index = Cell.read position" in read_next
assert "match index == logical_length {\n        true => Buffer.Success Frames.EndOfFrame\n        false => match Buffer.read (buffer, index) {" in read_next
assert "Buffer.Success(value) => {\n                let ignored = Cell.write (position, index + 1)\n                Buffer.Success (Frames.Value value)" in read_next
assert read_next.count("Buffer.read") == read_next.count("Cell.write") == 1
assert "capacity" not in read_next
assert "true => finish Frames.Ping" in codec
assert "true => decode_reading ()" in codec and "true => decode_pair ()" in codec
assert "false => Buffer.Success Frames.BadTag" in codec
assert "Buffer.Success(Frames.Value(second)) => finish (Frames.Pair(first, second))" in codec
assert "Buffer.Success(Frames.EndOfFrame) => Buffer.Success (Frames.Decoded message)" in codec
assert "Buffer.Success(Frames.Value(extra)) => Buffer.Success Frames.TrailingData" in codec
assert "2, Frames.Byte(first, Frames.Byte(second, Frames.End))" in codec

round_source = sources["01-round-trips.ash"]
for declaration in [
    "let ping = Frames.Byte(0, Frames.End)",
    "let reading_zero = Frames.Byte(1, Frames.Byte(0, Frames.End))",
    "let reading_max = Frames.Byte(1, Frames.Byte(255, Frames.End))",
    "let pair_forward = Frames.Byte(2, Frames.Byte(0, Frames.Byte(255, Frames.End)))",
    "let pair_reverse = Frames.Byte(2, Frames.Byte(255, Frames.Byte(0, Frames.End)))",
]:
    assert declaration in round_source
golden_inputs = round_source.split("let golden_frames =", 1)[1].split("let encoded_frames", 1)[0]
assert "Codec.encode" not in golden_inputs
assert re.sub(r"\s+", "", golden_inputs) == (
    "Frame(1,ping,Frame(2,reading_zero,Frame(2,reading_max,"
    "Frame(3,pair_forward,Frame(3,pair_reverse,NoFrames)))))")
encoded_inputs = round_source.split("let encoded_frames =", 1)[1].split("\n    (", 1)[0]
assert re.sub(r"\s+", "", encoded_inputs) == (
    "Frame(1,Codec.encodeFrames.Ping,Frame(2,Codec.encode(Frames.Reading0),"
    "Frame(2,Codec.encode(Frames.Reading255),Frame(3,Codec.encode(Frames.Pair(0,255)),"
    "Frame(3,Codec.encode(Frames.Pair(255,0)),NoFrames)))))")
for name in ["01-round-trips.ash", "02-malformed.ash"]:
    source = sources[name]
    assert source.count("Codec.run_frame (capacity, byte_values)") == 1
    assert source.count("Codec.run_frame") == 1
    assert "check_frames NoFrames = Done" in source
    assert "check_frames (Frame(capacity, byte_values, rest)) = Checked (\n    Codec.run_frame (capacity, byte_values), check_frames rest\n)" in source
malformed_inputs_source = sources["02-malformed.ash"].split("let inputs =", 1)[1]
malformed_inputs_source = malformed_inputs_source.split("\n    check_frames inputs", 1)[0]
assert re.sub(r"\s+", "", malformed_inputs_source) == (
    "Frame(1,Frames.Byte(9,Frames.End),"
    "Frame(1,Frames.Byte(1,Frames.End),"
    "Frame(2,Frames.Byte(2,Frames.Byte(7,Frames.End)),"
    "Frame(2,Frames.Byte(0,Frames.Byte(9,Frames.End)),"
    "Frame(1,Frames.End,Frame(2,Frames.Byte(1,Frames.End),"
    "Frame(3,Frames.Byte(0,Frames.End),NoFrames)))))))")

failure_source = sources["03-buffer-failures.ash"]
assert "Codec.run_frame (0, Frames.Byte(0, Frames.End))" in failure_source
assert "invalid_acquisition () = resource cell<C> entered = 0 {\n    let result = resource Buffer.Buffer<R> buffer = 0 {\n        let ignored = Cell.write (entered, 1)\n        Buffer.Success ()\n    }\n    (result, Cell.read entered)" in failure_source
assert "match Buffer.write (buffer, 0, 42) {\n        Buffer.Failure(error) => Buffer.Failure error\n        Buffer.Success(()) => {\n            let refused = Buffer.write (buffer, 0, 256)\n            Buffer.Success (WriteControl(refused, Buffer.read (buffer, 0)))" in failure_source
assert failure_source.count("Buffer.read (buffer, 0)") == 1
assert "2, Frames.Byte(second, Frames.Byte(first, Frames.End))" in sources["04-swapped-pair.ash"]

# Semantic labels bind the exact escaping body to its actual buffer owner.
fixture = json.loads((root / "checks/05-escaping-cursor.diagnostic.json").read_text())
assert fixture["reason"] == "type.resource-escape"
assert fixture["responsibility"] == "source" and fixture["facts"] == []
labels = fixture["labels"]
assert [(item["role"], item["relationship"]) for item in labels] == [
    ("primary", "escaping_dependency"), ("related", "resource_acquisition")]
escaping = sources["05-escaping-cursor.ash"].encode()
body = b"""{
        let next : (
            Unit -> Buffer.Outcome<Int> ! {Cell.Ops<C>, Buffer.Ops<Buffer.Buffer<R>>}
        ) = fn(ignored) {
            Buffer.read (buffer, Cell.read position)
        }
        next
    }"""
owner = b"resource Buffer.Buffer<R> buffer = 1 " + body
for label, expected in zip(labels, [body, owner]):
    assert label["path"] == "src/05-escaping-cursor.ash" and label["facts"] == []
    assert escaping[label["byte_start"]:label["byte_end"]] == expected
    assert label["byte_start"] == escaping.index(expected)
assert escaping.index(b"resource cell<C> position = 0") < escaping.index(owner)
repair = sources["06-decode-in-scope.ash"]
assert "Codec.run_frame (\n    3, Frames.Byte(2, Frames.Byte(0, Frames.Byte(255, Frames.End)))\n)" in repair
assert "fn(" not in repair and "Buffer.Outcome<Buffer.Outcome<Frames.DecodeResult>>" in repair
PY_CHECK
ash_doc_finish 8
