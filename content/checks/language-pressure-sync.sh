#!/usr/bin/env bash

# Verify the language-pressure register and volatile lesson flags agree:
# every volatile-flagged lesson names the register, and every lesson path
# the register names exists.

set -euo pipefail

content_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly content_root
repo_root=$(cd "$content_root/.." && pwd)
readonly repo_root
register="$repo_root/docs/project/language-pressure.md"
readonly register

if [[ ! -f $register ]]; then
    printf 'pressure-sync: register missing at %s\n' "$register" >&2
    exit 1
fi

failures=0

while IFS= read -r lesson; do
    lesson_dir=${lesson%/README.md}
    if ! grep -q "content/$lesson_dir" "$register"; then
        printf 'pressure-sync: %s is volatile but names no register entry\n' \
            "$lesson" >&2
        failures=$((failures + 1))
    fi
done < <(grep -rln '^volatile:' "$content_root/learn" \
    "$content_root/cases" "$content_root/libraries" \
    "$content_root/effects" 2>/dev/null | grep '/README\.md$' |
    sed "s|^$content_root/||")

while IFS= read -r path; do
    if [[ ! -d "$repo_root/$path" ]]; then
        printf 'pressure-sync: register names missing lesson %s\n' "$path" >&2
        failures=$((failures + 1))
    fi
done < <(grep -o 'content/[a-z]*/[a-z0-9-]*/' "$register" | sort -u)

if ((failures > 0)); then
    printf 'pressure-sync: %d mismatch(es) with %s\n' "$failures" "$register" >&2
    exit 1
fi

printf 'pressure-sync: register and volatile flags agree\n'
