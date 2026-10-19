#!/usr/bin/env bash
# Package the bundled skribble fonts and attach the zips to a GitHub release.
#
# Covers every font package: skribble_font_recursive and the three Skribble
# Noto packages (skribble_font_noto, skribble_font_noto_sketch,
# skribble_font_noto_lively). skribble_font_recursive must exist at the tag; a
# Noto package missing at the tag is skipped, so older tags still re-attach. The all-scripts Skribble Noto kit is attached separately
# by scripts/release/publish_noto_kit.sh.
#
# Local replacement for the "Attach the font zips to the release" step of
# .github/workflows/publish.yml, for releases published from a developer
# machine. Prefer the devenv wrapper: `publish:fonts`.
#
# Usage:
#   ./scripts/release/publish_fonts.sh [<tag>] [--dry-run]
#
# With no tag, the newest main-group release tag (v<version>) is used. Font
# assets attach to that tag only: companion tags (`skribble_maps/v*`,
# `skribble_charts/v*`) have no font zips.
#
# The zips are built from the tag's committed fonts with `git archive`, not
# from the working tree, so the archives always describe the release they are
# attached to. Uploads replace same-named assets, so re-runs are safe.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

REPO="${SKRIBBLE_REPO:-openbudgetfun/skribble}"
FONT_PACKAGES=(
  skribble_font_recursive
  skribble_font_noto
  skribble_font_noto_sketch
  skribble_font_noto_lively
)

TAG=""
DRY_RUN=0

usage() {
  sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: unknown option '$arg'." >&2
      usage >&2
      exit 1
      ;;
    *)

      if [[ -n "$TAG" ]]; then
        echo "Error: tag given twice ('$TAG' and '$arg')." >&2
        exit 1
      fi
      TAG="$arg"

      ;;
  esac
done

command -v zip >/dev/null || {
  echo "Error: 'zip' is required but was not found on PATH." >&2
  exit 1
}

cd "$ROOT_DIR"

if [[ -z "$TAG" ]]; then
  TAG="$(git tag --list 'v[0-9]*' --sort=-v:refname | head -n1)"
fi

if [[ -z "$TAG" ]]; then
  echo "Error: no main-group v<version> tag found. Pass a tag explicitly." >&2
  exit 1
fi

if [[ "$TAG" == */* ]]; then
  echo "Error: font assets attach to main-group v<version> tags only, not '$TAG'." >&2
  exit 1
fi

if ! git rev-parse --verify --quiet "refs/tags/$TAG" >/dev/null; then
  echo "Error: tag '$TAG' does not exist in this repository." >&2
  exit 1
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  command -v gh >/dev/null || {
    echo "Error: 'gh' is required but was not found on PATH." >&2
    exit 1
  }

  if ! gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
    echo "Error: no GitHub release found for tag '$TAG' in $REPO." >&2
    echo "Create it first, for example:" >&2
    echo "  monochange run release --commit --push --tag --publish-release" >&2
    exit 1
  fi
fi

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

for package in "${FONT_PACKAGES[@]}"; do
  fonts_path="packages/$package/assets/fonts"
  pubspec_path="packages/$package/pubspec.yaml"

  if ! git cat-file -e "$TAG:$fonts_path" 2>/dev/null; then
    if [[ "$package" == skribble_font_recursive ]]; then
      echo "Error: $fonts_path is missing at $TAG." >&2
      exit 1
    fi
    echo "Skipping $package: not present at $TAG."
    continue
  fi

  git archive "$TAG" "$fonts_path" "$pubspec_path" | tar -x -C "$scratch"

  echo "Packaging $package fonts from $TAG..."
  "$SCRIPT_DIR/package_fonts.sh" \
    "$scratch/$fonts_path" \
    "$scratch/artifacts" \
    "$TAG" \
    "$scratch/$pubspec_path"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "Dry run: $TAG would receive these assets in $REPO:"
  find "$scratch/artifacts" -maxdepth 1 -type f -name '*.zip' -exec basename {} \; | sort
  exit 0
fi

echo
echo "Uploading to the $TAG release in $REPO..."
gh release upload "$TAG" "$scratch"/artifacts/*.zip --clobber --repo "$REPO"

echo
gh release view "$TAG" --repo "$REPO" --json assets -q '.assets[].name' | sort
