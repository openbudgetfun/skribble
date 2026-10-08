#!/usr/bin/env bash
# Export skribble's animated emoji as Lottie files and attach the zip to a
# GitHub release. Prefer the devenv wrapper: `publish:emoji-lottie`.
#
# Usage:
#   ./scripts/release/publish_emoji_lottie.sh [<tag>] [--dry-run]
#
# With no tag, the newest main-group release tag (v<version>) is used. The
# animations are exported from the tag's own sources, in a temporary
# worktree, so the zip always describes the release it is attached to. The
# upload replaces a same-named asset, so re-runs are safe.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

REPO="${SKRIBBLE_REPO:-openbudgetfun/skribble}"
ASSET="skribble-emoji-lottie.zip"

TAG=""
DRY_RUN=0

usage() {
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
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
      if [[ -n "$TAG" ]]; then
        echo "Error: tag given twice ('$TAG' and '$arg')." >&2
        exit 1
      fi
      TAG="$arg"
      ;;
  esac
done

for tool in zip flutter; do
  command -v "$tool" >/dev/null || {
    echo "Error: '$tool' is required but was not found on PATH." >&2
    exit 1
  }
done

cd "$ROOT_DIR"

if [[ -z "$TAG" ]]; then
  TAG="$(git tag --list 'v[0-9]*' --sort=-v:refname | head -n1)"
fi
if [[ -z "$TAG" ]]; then
  echo "Error: no main-group v<version> tag found. Pass a tag explicitly." >&2
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
    exit 1
  fi
fi

scratch="$(mktemp -d)"
cleanup() {
  git -C "$ROOT_DIR" worktree remove --force "$scratch/src" >/dev/null 2>&1 || true
  rm -rf "$scratch"
}
trap cleanup EXIT

git worktree add --quiet --detach "$scratch/src" "$TAG"
if [[ ! -f "$scratch/src/packages/skribble_emoji/test/emoji_lottie_test.dart" ]]; then
  echo "Error: $TAG predates Lottie export; nothing to attach." >&2
  exit 1
fi

echo "Exporting animated emoji from $TAG..."
(
  cd "$scratch/src"
  flutter pub get >/dev/null
  cd packages/skribble_emoji
  if ! EMOJI_LOTTIE_OUT="$scratch/lottie" flutter test test/emoji_lottie_test.dart \
    --plain-name 'export Lottie files' >"$scratch/export.log" 2>&1; then
    cat "$scratch/export.log" >&2
    echo "Error: the Lottie export failed; its output is above." >&2
    exit 1
  fi
)
cp "$scratch/src/LICENSE" "$scratch/lottie/LICENSE"
(cd "$scratch/lottie" && zip -q -r "$scratch/$ASSET" .)
count="$(find "$scratch/lottie" -name '*.json' | wc -l | tr -d ' ')"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run: $TAG would receive $ASSET ($count animations, $(du -h "$scratch/$ASSET" | cut -f1)) in $REPO."
  exit 0
fi

echo "Uploading $ASSET ($count animations) to the $TAG release in $REPO..."
gh release upload "$TAG" "$scratch/$ASSET" --clobber --repo "$REPO"
