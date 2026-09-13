#!/usr/bin/env bash
# Verify every committed icon catalog matches what its generator produces.
#
# Regeneration is cheap for these sets because the conversion is pure Dart, so
# CI can re-derive each catalog and fail on any diff rather than trusting that
# a contributor remembered to run the generator.
#
# Usage:
#   ./scripts/check_icon_catalogs.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

if [[ -x "$ROOT_DIR/.fvm/flutter_sdk/bin/dart" ]]; then
  DART="$ROOT_DIR/.fvm/flutter_sdk/bin/dart"
else
  DART="$(command -v dart)"
fi

status=0

echo "Checking the curated simple catalog..."
if ! "$DART" run packages/skribble_emoji_gen/bin/generate_icons.dart --check; then
  status=1
fi

echo "Checking the Iconify catalogs..."
if ! "$SCRIPT_DIR/generate_iconify_sets.sh" --check; then
  status=1
fi

if ((status != 0)); then
  echo >&2
  echo "Error: committed icon catalogs are stale." >&2
  echo "Run 'melos run icons-curated' and 'melos run icons-iconify', then commit" >&2
  echo "the regenerated .g.dart files." >&2
  exit 1
fi

echo "All icon catalogs are current."
