#!/usr/bin/env bash
# Render skribble's promo reel to an MP4.
#
# Usage:
#   ./scripts/render_promo.sh [output.mp4]
#
# Renders the storybook's PromoReel frame by frame on the Flutter test clock
# (identical on every run), then encodes 1080x1080 H.264 at 30 frames a
# second with ffmpeg. The default output is .screenshots/promo/skribble-promo.mp4,
# which is gitignored: share the video on a release or a pull request, never
# commit it.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
OUTPUT="${1:-$REPO_ROOT/.screenshots/promo/skribble-promo.mp4}"

for tool in flutter ffmpeg; do
  command -v "$tool" >/dev/null || {
    echo "Error: '$tool' is required but was not found on PATH." >&2
    exit 1
  }
done

frames="$(mktemp -d)"
trap 'rm -rf "$frames"' EXIT

echo "Rendering frames..."
(
  cd "$REPO_ROOT/apps/skribble_storybook"
  flutter test tool/render_promo_test.dart --dart-define=PROMO_OUT="$frames" >/dev/null
)

mkdir -p "$(dirname "$OUTPUT")"
echo "Encoding $OUTPUT..."
ffmpeg -y -loglevel error -framerate 30 -i "$frames/%05d.png" \
  -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart \
  "$OUTPUT"
echo "Done: $OUTPUT"
