#!/usr/bin/env bash
# Strict translation checks for every lesson carrying a Bulgarian chapter.
set -uo pipefail

cd "$(dirname "$0")/../../.." || exit 1

status=0
shopt -s nullglob
for chapter in content/learn/*/README.bg.md; do
    lesson_dir=$(dirname "$chapter")
    if ! python3 content/checks/translation/pipeline.py check --lesson "$lesson_dir"; then
        status=1
    fi
done
for family in learn cases libraries effects; do
    if [ -f "content/$family/README.bg.md" ]; then
        if ! python3 content/checks/translation/pipeline.py check --lesson "content/$family"; then
            status=1
        fi
    fi
done
shopt -u nullglob

if [ "$status" -eq 0 ]; then
    echo "translation sync: all translated lessons pass"
fi
exit "$status"
