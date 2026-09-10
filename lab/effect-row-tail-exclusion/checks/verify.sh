#!/usr/bin/env bash

set -euo pipefail
case_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
repo_root=$(cd "$case_root/../.." && pwd)
# shellcheck source=../../../content/checks/lib.sh
source "$repo_root/content/checks/lib.sh"
if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi
ash_doc_prepare "$1"
ash_doc_run_accepted "$case_root" src/control.ash '43 : Int'
# This assertion preserves the observed regression, not correct Ash behavior.
ash_doc_run_accepted "$case_root" src/excluded-callback.ash '44 : Int'
printf 'Reproduced acceptance of the excluded callback at %s.\n' "$ash_doc_expected_pin"
