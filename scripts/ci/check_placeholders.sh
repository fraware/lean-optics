#!/usr/bin/env bash
set -eu

echo "Scanning repository for placeholder/stub markers..."

patterns=(
  "\\bsorry\\b"
  "\\badmit\\b"
  "String\\.toNat!"
  "Would send to webhook"
  "In a real implementation"
  "placeholder proof"
)

exclude_globs=(
  "--glob=!**/.lake/**"
  "--glob=!**/build/**"
  "--glob=!**/.git/**"
)

for pattern in "${patterns[@]}"; do
  if git grep -nE "${pattern}" -- \
    '*.lean' '*.yml' '*.yaml' '*.sh' '*.ps1' \
    ':(exclude)docs/ModernizationInventory.md' \
    ':(exclude)scripts/ci/check_placeholders.sh' ; then
    echo "Found disallowed pattern: ${pattern}"
    exit 1
  fi
done

echo "No placeholder/stub markers found."
