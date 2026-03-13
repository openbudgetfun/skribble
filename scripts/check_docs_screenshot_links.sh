#!/usr/bin/env bash
set -euo pipefail

DOCS_DIR="${1:-docs/ui-snapshots}"
SCREENSHOTS_DIR="${2:-.screenshots}"
BASE_URL="https://f005.backblazeb2.com/file/skribble-screenshots/"

if [[ ! -d "$DOCS_DIR" ]]; then
  echo "Error: docs directory not found at $DOCS_DIR"
  exit 1
fi

if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
  echo "Error: screenshots directory not found at $SCREENSHOTS_DIR"
  exit 1
fi

missing=0
checked=0

echo "Checking docs image links in $DOCS_DIR against files in $SCREENSHOTS_DIR"

while IFS= read -r -d '' file; do
  while IFS= read -r url; do
    rel_path="${url#$BASE_URL}"

    if [[ "$rel_path" == "$url" ]]; then
      continue
    fi

    ((checked+=1))
    target="$SCREENSHOTS_DIR/$rel_path"

    if [[ ! -f "$target" ]]; then
      echo "Missing screenshot for docs link:"
      echo "  doc: $file"
      echo "  url: $url"
      echo "  expected file: $target"
      missing=1
    fi
  done < <(grep -Eo 'https://f005\.backblazeb2\.com/file/skribble-screenshots/[^)"[:space:]]+' "$file" || true)
done < <(find "$DOCS_DIR" -type f -name '*.md' -print0)

if [[ "$checked" -eq 0 ]]; then
  echo "Error: No screenshot URLs found in docs markdown files."
  exit 1
fi

if [[ "$missing" -ne 0 ]]; then
  echo "Screenshot link integrity check failed."
  exit 1
fi

echo "Screenshot link integrity check passed. Checked $checked link(s)."