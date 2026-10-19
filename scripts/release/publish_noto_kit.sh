#!/usr/bin/env bash
# Zip the all-scripts Skribble Noto kit and attach it to a GitHub release.
#
# The kit is every Noto script at the three hand-drawn levels, built by
# tool/skribble_noto/build.py. It is too large to commit (the CJK faces alone
# are tens of megabytes per level), so it is built on a developer machine and
# uploaded here, the same way the Figma export is published.
#
# One zip per level, each holding that level's TTFs, OFL.txt and README.md:
#
#   SkribbleNoto-Kit-<tag>.zip        (Soft, the default level)
#   SkribbleNotoSketch-Kit-<tag>.zip
#   SkribbleNotoLively-Kit-<tag>.zip
#
# Usage:
#   ./scripts/release/publish_noto_kit.sh <kit-dir> [<tag>] [--dry-run]
#
# <kit-dir> is the build output with soft/, sketch/ and lively/ folders. With no
# tag, the newest main-group release tag (v<version>) is used. Uploads replace
# same-named assets, so re-runs are safe.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

REPO="${SKRIBBLE_REPO:-openbudgetfun/skribble}"
LICENSE="$ROOT_DIR/packages/skribble_font_noto/assets/fonts/OFL.txt"
README="$ROOT_DIR/tool/skribble_noto/KIT.md"

KIT_DIR=""
TAG=""
DRY_RUN=0

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
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
      if [[ -z "$KIT_DIR" ]]; then
        KIT_DIR="$arg"
      elif [[ -z "$TAG" ]]; then
        TAG="$arg"
      else
        echo "Error: unexpected argument '$arg'." >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$KIT_DIR" ]]; then
  usage >&2
  exit 1
fi

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

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

for level in soft:SkribbleNoto sketch:SkribbleNotoSketch lively:SkribbleNotoLively; do
  dir="$KIT_DIR/${level%%:*}"
  stem="${level##*:}"
  archive="$scratch/$stem-Kit-$TAG.zip"

  if [[ ! -d "$dir" ]]; then
    echo "Error: missing level folder $dir" >&2
    exit 1
  fi

  ttf_files=()
  while IFS= read -r file; do
    ttf_files+=("$file")
  done < <(find "$dir" -maxdepth 1 -type f -name "$stem*-Regular.ttf" | sort)

  if [[ ${#ttf_files[@]} -eq 0 ]]; then
    echo "Error: no $stem*-Regular.ttf files in $dir" >&2
    exit 1
  fi

  zip -j -q -X "$archive" "${ttf_files[@]}" "$LICENSE" "$README"
  echo "Packaged $(basename "$archive") (${#ttf_files[@]} faces)"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "Dry run: $TAG would receive these assets in $REPO:"
  find "$scratch" -maxdepth 1 -type f -name '*.zip' -exec basename {} \; | sort
  exit 0
fi

command -v gh >/dev/null || {
  echo "Error: 'gh' is required but was not found on PATH." >&2
  exit 1
}

gh release upload "$TAG" "$scratch"/*.zip --clobber --repo "$REPO"
gh release view "$TAG" --repo "$REPO" --json assets -q '.assets[].name' | sort
