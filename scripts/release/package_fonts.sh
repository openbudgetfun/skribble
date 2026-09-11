#!/usr/bin/env bash
# Package the Skribble font families into release zip archives.
#
# One zip per font family, named "<stem>-<tag>.zip", with the family's TTFs and
# the OFL license at the archive root:
#
#   SkribbleRecursive-v1.0.0.zip   (the Skribble family, roughened from Recursive)
#   SkribbleGentle-v1.0.0.zip
#   SkribbleLinearGentle-v1.0.0.zip
#   ...
#
# Families come from the `fonts:` block of packages/skribble/pubspec.yaml, so a
# newly declared family ships without editing this script. A TTF that no
# declared family claims fails the run instead of being silently left out.
# The stem is the family name except where `zip_stem` overrides it to keep an
# already-published archive name stable.
#
# Usage:
#   ./scripts/release/package_fonts.sh <fonts-dir> <output-dir> <tag> [pubspec]
#
# Example:
#   ./scripts/release/package_fonts.sh packages/skribble/assets/fonts dist v1.0.0

set -euo pipefail

FONTS_DIR="${1:?Usage: $0 <fonts-dir> <output-dir> <tag> [pubspec]}"
OUTPUT_DIR="${2:?Usage: $0 <fonts-dir> <output-dir> <tag> [pubspec]}"
TAG="${3:?Usage: $0 <fonts-dir> <output-dir> <tag> [pubspec]}"

# The package that declares the fonts is the nearest ancestor with a pubspec.
find_pubspec() {
  local dir="$1"
  while [[ -n "$dir" && "$dir" != "/" && "$dir" != "." ]]; do
    if [[ -f "$dir/pubspec.yaml" ]]; then
      printf '%s\n' "$dir/pubspec.yaml"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}
PUBSPEC="${4:-$(find_pubspec "$FONTS_DIR" || true)}"

LICENSE="OFL.txt"

if [[ ! -d "$FONTS_DIR" ]]; then
  echo "Error: fonts directory not found at $FONTS_DIR" >&2
  exit 1
fi
if [[ ! -f "$FONTS_DIR/$LICENSE" ]]; then
  echo "Error: expected $FONTS_DIR/$LICENSE next to the font assets" >&2
  exit 1
fi
if [[ ! -f "$PUBSPEC" ]]; then
  echo "Error: pubspec not found at $PUBSPEC" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Declared families from the pubspec `fonts:` block, which ends at the next
# two-space `flutter:` child key such as `assets:`.
families="$(
  sed -n '/^  fonts:/,/^  [a-z]/p' "$PUBSPEC" |
    grep -E '^[[:space:]]*-[[:space:]]*family:' |
    sed -E 's/^[[:space:]]*-[[:space:]]*family:[[:space:]]*//' |
    tr -d '"' |
    sort -u
)"

if [[ -z "$families" ]]; then
  echo "Error: no font families declared in $PUBSPEC" >&2
  exit 1
fi

# The published archive name for a family. `SkribbleRecursive` is kept for the
# Skribble family because releases before this script shipped under that name.
zip_stem() {
  case "$1" in
    Skribble) printf 'SkribbleRecursive\n' ;;
    *) printf '%s\n' "$1" ;;
  esac
}

claimed="$(mktemp)"
trap 'rm -f "$claimed"' EXIT

while IFS= read -r family; do
  [[ -n "$family" ]] || continue
  archive="$OUTPUT_DIR/$(zip_stem "$family")-$TAG.zip"

  ttf_files=()
  while IFS= read -r file; do
    ttf_files+=("$file")
  done < <(find "$FONTS_DIR" -maxdepth 1 -type f -name "$family-*.ttf" | sort)

  if [[ ${#ttf_files[@]} -eq 0 ]]; then
    echo "Error: family '$family' is declared in $PUBSPEC but no $family-*.ttf exists in $FONTS_DIR" >&2
    exit 1
  fi

  printf '%s\n' "${ttf_files[@]}" >>"$claimed"
  rm -f "$archive"
  zip -j -q -X "$archive" "${ttf_files[@]}" "$FONTS_DIR/$LICENSE"
  echo "Packaged $archive (${#ttf_files[@]} faces)"
done <<<"$families"

unclaimed="$(
  find "$FONTS_DIR" -maxdepth 1 -type f -name '*.ttf' | sort |
    grep -vxF -f <(sort -u "$claimed") || true
)"
if [[ -n "$unclaimed" ]]; then
  echo "Error: font files are not covered by any family declared in $PUBSPEC:" >&2
  echo "$unclaimed" >&2
  exit 1
fi
