#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"

# shellcheck source=../../../checks/lib.sh
source "$content_root/checks/lib.sh"

[[ $# -eq 1 ]] || ash_doc_fail \
    "usage: checks/verify.sh /path/to/pinned/ash-lang"
ash_doc_prepare "$1"

readonly sources=(src/01-explicit-kind.ash src/02-omitted-kind.ash)
for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] ||
        ash_doc_fail "missing canonical source: $source"
done

mapfile -t actual_sources < <(
    find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' -printf 'src/%f\n' |
        LC_ALL=C sort
)
[[ ${actual_sources[*]} == "${sources[*]}" ]] ||
    ash_doc_fail "canonical source inventory differs from the declared inventory"

readonly explicit_source="$unit_root/src/01-explicit-kind.ash"
[[ $(grep -Fxc 'keep<F : Type -> Type, A> : F<A> -> F<A>' \
    "$explicit_source" || true) -eq 1 ]] ||
    ash_doc_fail "the accepted keep binder must state Type -> Type"
[[ $(grep -Fxc 'main () = keep(Some(42))' "$explicit_source" || true) -eq 1 ]] ||
    ash_doc_fail "the accepted entry must apply keep to Some(42)"
ash_doc_run_accepted \
    "$unit_root" src/01-explicit-kind.ash 'Some(42) : Option<Int>'

readonly omitted_source="$unit_root/src/02-omitted-kind.ash"
[[ $(grep -Fxc 'keep<F, A> : F<A> -> F<A>' "$omitted_source" || true) -eq 1 ]] ||
    ash_doc_fail "the rejected keep binder must omit F's kind"

normalized_explicit=$(mktemp "$ASH_DOC_VERIFY_DIR/explicit.XXXXXX")
readonly normalized_explicit
sed 's/F : Type -> Type/F/' "$explicit_source" > "$normalized_explicit"
cmp -s "$normalized_explicit" "$omitted_source" ||
    ash_doc_fail "the programs must differ only by F's kind annotation"

ash_doc_run_rejected "$unit_root" src/02-omitted-kind.ash 1
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 2
