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

run_omitted_kind_rejection() {
    local rejected_stdout rejected_stderr rejected_status
    rejected_stdout=$(mktemp "$ASH_DOC_VERIFY_DIR/stdout.XXXXXX")
    rejected_stderr=$(mktemp "$ASH_DOC_VERIFY_DIR/stderr.XXXXXX")
    if "$ASH_DOC_ASH_BIN" "$omitted_source" \
        > "$rejected_stdout" 2> "$rejected_stderr"; then
        rejected_status=0
    else
        rejected_status=$?
    fi
    [[ $rejected_status -eq 1 ]] ||
        ash_doc_fail "02-omitted-kind.ash must exit with status 1"
    [[ ! -s $rejected_stdout ]] ||
        ash_doc_fail "02-omitted-kind.ash must write empty stdout"
    [[ $(sed -n '1p' "$rejected_stderr") == 'kind.not-applicable' ]] ||
        ash_doc_fail "02-omitted-kind.ash must report kind.not-applicable"
    grep -Fxq 'expected Type -> _' "$rejected_stderr" ||
        ash_doc_fail "the rejection must retain the expected function kind"
    grep -Fxq 'found Type' "$rejected_stderr" ||
        ash_doc_fail "the rejection must retain F's fixed Type kind"

    local applications=()
    mapfile -t applications < <(
        LC_ALL=C grep -aboF 'F<A>' "$omitted_source" || true
    )
    [[ ${#applications[@]} -eq 2 ]] ||
        ash_doc_fail "the rejected signature must contain two F<A> applications"
    local application_start=${applications[0]%%:*}
    local application_end=$((application_start + 4))
    local binder_matches=()
    mapfile -t binder_matches < <(
        LC_ALL=C grep -aboF 'keep<F, A>' "$omitted_source" || true
    )
    [[ ${#binder_matches[@]} -eq 1 ]] ||
        ash_doc_fail "the rejected signature must contain one keep binder list"
    local binder_start=$(( ${binder_matches[0]%%:*} + 5 ))
    local binder_end=$((binder_start + 1))

    local primary_lines=() related_lines=()
    mapfile -t primary_lines < <(
        LC_ALL=C grep -F 'primary: source ' "$rejected_stderr" || true
    )
    mapfile -t related_lines < <(
        LC_ALL=C grep -F 'related: source ' "$rejected_stderr" || true
    )
    [[ ${#primary_lines[@]} -eq 1 ]] ||
        ash_doc_fail "the rejection must contain one primary label"
    [[ ${primary_lines[0]} == \
        "primary: source 0 $application_start..$application_end:"* ]] ||
        ash_doc_fail "the primary label must cover the first F<A> application"
    [[ ${#related_lines[@]} -eq 1 ]] ||
        ash_doc_fail "the rejection must contain one related label"
    [[ ${related_lines[0]} == \
        "related: source 0 $binder_start..$binder_end:"* ]] ||
        ash_doc_fail "the related label must cover F's declaration"
}

run_omitted_kind_rejection
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
ash_doc_finish 2
