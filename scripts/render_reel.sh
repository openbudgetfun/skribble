#!/usr/bin/env bash
# Render one of skribble's intro reels to an MP4.
#
# Usage:
#   ./scripts/render_reel.sh <reel> <portrait|landscape|square> [output.mp4]
#
# Reels: fun-again, drawn-by-a-pen, emoji-party, make-it-yours.
#
# Renders the reel frame by frame on the Flutter test clock (identical on
# every run), then encodes H.264 at 30 frames a second with ffmpeg: 1080x1920
# for portrait, 1920x1080 for landscape, 1080x1080 for square. The default
# output is .screenshots/promo/skribble-<reel>-<aspect>.mp4, which is
# gitignored: share videos on a release or a pull request, never commit them.
set -euo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
  exit 64
fi

REEL="$1"
ASPECT="$2"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
OUTPUT="${3:-$REPO_ROOT/.screenshots/promo/skribble-$REEL-$ASPECT.mp4}"

for tool in flutter ffmpeg; do
  command -v "$tool" >/dev/null || {
    echo "Error: '$tool' is required but was not found on PATH." >&2
    exit 1
  }
done

frames="$(mktemp -d)"
trap 'rm -rf "$frames"' EXIT

echo "Rendering $REEL ($ASPECT) frames..."
(
  cd "$REPO_ROOT/apps/skribble_storybook"
  flutter test tool/render_reel_test.dart \
    --dart-define=REEL="$REEL" \
    --dart-define=ASPECT="$ASPECT" \
    --dart-define=REEL_OUT="$frames" >/dev/null
)

mkdir -p "$(dirname "$OUTPUT")"
echo "Encoding $OUTPUT..."
ffmpeg -y -loglevel error -framerate 30 -i "$frames/%05d.png" \
  -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart \
  "$OUTPUT"
echo "Done: $OUTPUT"
