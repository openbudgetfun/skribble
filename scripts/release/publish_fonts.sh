#!/usr/bin/env bash
# Package the bundled Skribble fonts and attach the zips to a GitHub release.
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
FONTS_PATH="packages/skribble/assets/fonts"
PUBSPEC_PATH="packages/skribble/pubspec.yaml"

TAG=""
DRY_RUN=0

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
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

git archive "$TAG" "$FONTS_PATH" "$PUBSPEC_PATH" | tar -x -C "$scratch"

echo "Packaging fonts from $TAG..."
"$SCRIPT_DIR/package_fonts.sh" \
  "$scratch/$FONTS_PATH" \
  "$scratch/artifacts" \
  "$TAG" \
  "$scratch/$PUBSPEC_PATH"

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
