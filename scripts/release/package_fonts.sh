#!/usr/bin/env bash
# Package the Skribble font families into release zip archives.
#
# One zip per font family, named "<Family>-<tag>.zip", with the family's TTFs
# and the OFL license at the archive root:
#
#   SkribbleRecursive-v1.0.0.zip   (the "Skribble" family, roughened from Recursive)
#   SkribbleGentle-v1.0.0.zip
#   SkribblePlayful-v1.0.0.zip
#   ArchitectsDaughter-v1.0.0.zip
#
# Usage:
#   ./scripts/release/package_fonts.sh <fonts-dir> <output-dir> <tag>
#
# Example:
#   ./scripts/release/package_fonts.sh packages/skribble/assets/fonts dist v1.0.0

set -euo pipefail

FONTS_DIR="${1:?Usage: $0 <fonts-dir> <output-dir> <tag>}"
OUTPUT_DIR="${2:?Usage: $0 <fonts-dir> <output-dir> <tag>}"
TAG="${3:?Usage: $0 <fonts-dir> <output-dir> <tag>}"

LICENSE="OFL.txt"

if [[ ! -d "$FONTS_DIR" ]]; then
  echo "Error: fonts directory not found at $FONTS_DIR" >&2
  exit 1
fi
if [[ ! -f "$FONTS_DIR/$LICENSE" ]]; then
  echo "Error: expected $FONTS_DIR/$LICENSE next to the font assets" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# family prefix in the TTF filenames -> release zip stem
families=(
  "Skribble:SkribbleRecursive"
  "SkribbleGentle:SkribbleGentle"
  "SkribblePlayful:SkribblePlayful"
  "ArchitectsDaughter:ArchitectsDaughter"
)

for entry in "${families[@]}"; do
  prefix="${entry%%:*}"
  stem="${entry##*:}"
  archive="$OUTPUT_DIR/$stem-$TAG.zip"

  ttf_files=()
  while IFS= read -r file; do
    ttf_files+=("$file")
  done < <(find "$FONTS_DIR" -maxdepth 1 -type f -name "$prefix-*.ttf" | sort)

  if [[ ${#ttf_files[@]} -eq 0 ]]; then
    echo "Error: no TTFs matching $prefix-*.ttf in $FONTS_DIR" >&2
    exit 1
  fi

  rm -f "$archive"
  zip -j -q "$archive" "${ttf_files[@]}" "$FONTS_DIR/$LICENSE"
  echo "Packaged $archive"
done
