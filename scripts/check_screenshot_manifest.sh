#!/usr/bin/env bash
# Validate generated screenshots against a manifest of expected paths.
#
# Usage:
#   ./scripts/check_screenshot_manifest.sh <manifest_file> <screenshots_dir>
#
# Example:
#   ./scripts/check_screenshot_manifest.sh docs/ui-snapshots/screenshot-manifest.txt .screenshots

set -euo pipefail

MANIFEST_FILE="${1:-docs/ui-snapshots/screenshot-manifest.txt}"
SCREENSHOTS_DIR="${2:-.screenshots}"
STRICT_MODE="${SCREENSHOT_MANIFEST_STRICT:-0}"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "::error::Manifest file not found: $MANIFEST_FILE"
  exit 1
fi

if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
  echo "::error::Screenshots directory not found: $SCREENSHOTS_DIR"
  exit 1
fi

mapfile -t EXPECTED_PATHS < <(
  grep -vE '^[[:space:]]*(#|$)' "$MANIFEST_FILE" | sed -E 's/[[:space:]]+$//' | sort -u
)

if [[ ${#EXPECTED_PATHS[@]} -eq 0 ]]; then
  echo "::error::No expected screenshot paths found in manifest: $MANIFEST_FILE"
  exit 1
fi

MISSING=()
for rel_path in "${EXPECTED_PATHS[@]}"; do
  if [[ ! -f "$SCREENSHOTS_DIR/$rel_path" ]]; then
    MISSING+=("$rel_path")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "::error::Missing screenshots required by manifest ($MANIFEST_FILE):"
  printf '  - %s\n' "${MISSING[@]}"
  exit 1
fi

echo "✅ Manifest check passed: all ${#EXPECTED_PATHS[@]} required screenshots exist."

if [[ "$STRICT_MODE" == "1" ]]; then
  mapfile -t ACTUAL_PATHS < <(
    find "$SCREENSHOTS_DIR" -type f -name '*.png' | sed "s#^$SCREENSHOTS_DIR/##" | sort -u
  )

  EXTRA=()
  for rel_path in "${ACTUAL_PATHS[@]}"; do
    if ! grep -Fxq "$rel_path" "$MANIFEST_FILE"; then
      EXTRA+=("$rel_path")
    fi
  done

  if [[ ${#EXTRA[@]} -gt 0 ]]; then
    echo "::error::Unexpected screenshots found (strict mode enabled):"
    printf '  - %s\n' "${EXTRA[@]}"
    exit 1
  fi

  echo "✅ Strict manifest check passed: no unexpected screenshot files found."
fi
