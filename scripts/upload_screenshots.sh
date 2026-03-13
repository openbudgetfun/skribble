#!/usr/bin/env bash
# Upload screenshots to Backblaze B2
#
# Usage:
#   ./scripts/upload_screenshots.sh
#
# Requires B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY env vars
# or pass them as arguments:
#   ./scripts/upload_screenshots.sh <key_id> <app_key>

set -euo pipefail

BUCKET_NAME="skribble-screenshots"
SCREENSHOTS_DIR="${DEVENV_ROOT:-.}/.screenshots"

KEY_ID="${B2_APPLICATION_KEY_ID:-${1:-}}"
APP_KEY="${B2_APPLICATION_KEY:-${2:-}}"

if [[ -z "$KEY_ID" || -z "$APP_KEY" ]]; then
  echo "Error: B2_APPLICATION_KEY_ID and B2_APPLICATION_KEY must be set"
  echo "Usage: $0 [key_id] [app_key]"
  exit 1
fi

if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
  echo "Error: Screenshots directory not found at $SCREENSHOTS_DIR"
  echo "Run 'melos run screenshot' first to capture screenshots."
  exit 1
fi

MANIFEST_FILE="${DEVENV_ROOT:-.}/docs/ui-snapshots/screenshot-manifest.txt"
if [[ -f "$MANIFEST_FILE" ]]; then
  echo "Validating screenshot manifest before upload..."
  "${DEVENV_ROOT:-.}/scripts/check_screenshot_manifest.sh" "$MANIFEST_FILE" "$SCREENSHOTS_DIR"
else
  echo "Warning: Screenshot manifest file not found at $MANIFEST_FILE (skipping manifest validation)."
fi

echo "Authorizing with Backblaze B2..."
b2 authorize-account "$KEY_ID" "$APP_KEY"

echo "Uploading screenshots from $SCREENSHOTS_DIR to b2://$BUCKET_NAME/"
b2 sync --replaceNewer "$SCREENSHOTS_DIR/" "b2://$BUCKET_NAME/"

echo "Upload complete."
echo "Screenshots available at: https://f005.backblazeb2.com/file/$BUCKET_NAME/"
