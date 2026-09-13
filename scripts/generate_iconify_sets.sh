#!/usr/bin/env bash
# Regenerate the Iconify-backed icon catalogs from their pinned sources.
#
# Reads the iconify block of tool/asset_sources.txt, downloads any missing payload into
# .audit/iconify/<prefix>/icons.json after verifying its SHA-256, then runs the
# generator once per set. Pass --check to verify the committed catalogs match
# instead of writing them.
#
# Usage:
#   ./scripts/generate_iconify_sets.sh [--check]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCES="$ROOT_DIR/tool/asset_sources.txt"
CACHE_DIR="$ROOT_DIR/.audit/iconify"

CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

cd "$ROOT_DIR"

if [[ -x "$ROOT_DIR/.fvm/flutter_sdk/bin/dart" ]]; then
  DART="$ROOT_DIR/.fvm/flutter_sdk/bin/dart"
else
  DART="$(command -v dart)"
fi

[[ -f "$SOURCES" ]] || {
  echo "Error: missing $SOURCES." >&2
  exit 1
}

# PascalCases a package suffix: skribble_icons_simple_icons -> SimpleIcons.
stem_for() {
  local pkg="$1"
  local suffix="${pkg#skribble_icons_}"
  printf '%s' "$suffix" | awk -v FS='' '{
    out = ""
    cap = 1
    for (i = 1; i <= NF; i++) {
      c = $i
      if (c == "_") { cap = 1; continue }
      out = out (cap ? toupper(c) : c)
      cap = 0
    }
    print out
  }'
}

generate_one() {
  local prefix="$1" version="$2" sha="$3" base="$4" license="$5"
  local package="$6" attribution="$7" url="$8"
  local stem
  stem="$(stem_for "$package")"
  # snake_case of the package suffix, used for the generated file name so a
  # hyphenated Iconify prefix never reaches a Dart path.
  local snake="${package#skribble_icons_}"

  local dir="$CACHE_DIR/$prefix"
  local json="$dir/icons.json"

  if [[ ! -f "$json" ]]; then
    echo "Downloading $prefix@$version..."
    mkdir -p "$dir"
    curl -fsSL "https://unpkg.com/@iconify-json/$prefix@$version/icons.json" \
      -o "$json"
  fi

  local actual
  actual="$(shasum -a 256 "$json" | cut -d' ' -f1)"
  if [[ "$actual" != "$sha" ]]; then
    echo "Error: checksum mismatch for $prefix." >&2
    echo "  expected $sha" >&2
    echo "  actual   $actual" >&2
    echo "Update the version and checksum together in tool/asset_sources.txt." >&2
    exit 1
  fi

  local args=(
    run packages/skribble_emoji_gen/bin/generate_iconify_set.dart
    --prefix "$prefix"
    --package "$package"
    --stem "$stem"
    --icons-json "$json"
    --output "packages/$package/lib/src/generated/${snake}_icons.g.dart"
    --base-code-point "$base"
    --license "$license"
    --attribution "$attribution"
    --attribution-url "$url"
  )
  [[ "$CHECK" -eq 1 ]] && args+=(--check)

  "$DART" "${args[@]}"
}

# Only the pinned iconify block is machine-read; the rest of the registry is
# provenance documentation for the emoji, Material, font, and simple sources.
while read -r prefix version sha base license package attribution url; do
  [[ -z "$prefix" || "$prefix" == \#* ]] && continue
  generate_one "$prefix" "$version" "$sha" "$base" "$license" \
    "$package" "$attribution" "$url"
done < <(sed -n '/^# >>> iconify/,/^# <<< iconify/p' "$SOURCES")

echo "Iconify catalogs are current."
