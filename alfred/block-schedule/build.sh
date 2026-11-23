#!/usr/bin/env bash
# Packages this workflow into ../block-schedule.alfredworkflow (double-click it to import into Alfred).
#
# The zip is built to a temp file and the whole test suite is run against *that* file before it
# replaces the committed one, so a broken or stale artifact can never be produced silently.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

out="$PWD/../block-schedule.alfredworkflow"
tmp="$(mktemp -d)/block-schedule.alfredworkflow"

zip -q -X "$tmp" info.plist block.mjs icon.png
BLOCK_ARTIFACT="$tmp" node --test test/*.test.mjs
mv "$tmp" "$out"

echo "Built $out"
unzip -l "$out"
