#!/usr/bin/env bash
# Capture responsive screenshots of the Skribble storybook web preview
# across device form factors, and build a local HTML gallery.
#
# Usage:
#   ./scripts/capture_showcase.sh [base_url]
#
# Defaults to a local static server over apps/skribble_storybook/build/web.
# Output (gitignored): .screenshots/showcase/<device>/<page>.png plus an
# index.html gallery.
#
# Upload to Backblaze afterwards with ./scripts/upload_screenshots.sh
# (requires B2 credentials; see upload_screenshots.sh).
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/playwright-browsers}"
export PLAYWRIGHT_BROWSERS_PATH
BASE_URL="${1:-}"
PORT="${PORT:-8123}"
OUT="$REPO_ROOT/.screenshots/showcase"

# Serve the storybook web build locally if no URL is provided.
if [[ -z "$BASE_URL" ]]; then
  WEB_DIR="$REPO_ROOT/apps/skribble_storybook/build/web"
  if [[ ! -f "$WEB_DIR/index.html" ]]; then
    echo "Storybook web build missing. Building it first..."
    (cd apps/skribble_storybook && flutter build web --release \
      --no-web-resources-cdn --no-tree-shake-icons \
      --base-href /skribble/storybook/ --pwa-strategy=none)
  fi
  python3 -m http.server "$PORT" --directory "$WEB_DIR" >/dev/null 2>&1 &
  SERVER_PID=$!
  trap 'kill $SERVER_PID 2>/dev/null || true' EXIT
  sleep 1
  BASE_URL="http://127.0.0.1:$PORT"
fi

# Device presets: name:width:height
DEVICES=(
  "mobile:390:844"
  "mobile-large:430:932"
  "tablet:820:1180"
  "desktop:1440:900"
)

# Page presets: name:route (routes are the storybook hash routes).
PAGES=(
  "home:/"
  "buttons:/buttons"
  "inputs:/inputs"
  "navigation:/navigation"
  "selection:/selection"
  "feedback:/feedback"
  "layout:/layout"
  "data-display:/data-display"
  "font-specimen:/font-specimen"
)

mkdir -p "$OUT"

echo "Capturing pages from $BASE_URL"
for device in "${DEVICES[@]}"; do
  name="${device%%:*}"
  sizes="${device#*:}"
  width="${sizes%%:*}"
  height="${sizes##*:}"
  device_dir="$OUT/$name"
  mkdir -p "$device_dir"
  for page in "${PAGES[@]}"; do
    page_name="${page%%:*}"
    route="${page#*:}"
    npx playwright screenshot \
      --viewport-size="${width},${height}" \
      --wait-for-timeout=3000 \
      --full-page \
      "${BASE_URL}/#${route}" \
      "$device_dir/$page_name.png" 2>/dev/null || true
  done
  echo "  ✓ $name complete"
done

python3 - "$OUT" <<'PY'
import pathlib, sys
out = pathlib.Path(sys.argv[1])
devices = ["mobile", "mobile-large", "tablet", "desktop"]
pages = ["home", "buttons", "inputs", "navigation", "selection",
         "feedback", "layout", "data-display", "font-specimen"]
cards = []
for device in devices:
    d = out / device
    if d.is_dir():
        cards.append(
            f'<h2>{device}</h2><div class="grid">'
            + "".join(
                f'<div class="card"><img src="{device}/{page}.png" '
                f'loading="lazy" alt="{device} {page}">'
                f'<figcaption>{page}</figcaption></div>'
                for page in pages
                if (d / f"{page}.png").exists())
            + "</div>")
html = (
    "<!DOCTYPE html><html><head><meta charset='utf-8'>"
    "<title>Skribble Showcase</title>"
    "<style>body{font-family:system-ui;margin:24px;background:#fffdf6;"
    "color:#2b2930}img{max-width:100%;border:1px dashed #a39aad;"
    "border-radius:6px}.grid{display:flex;flex-wrap:wrap;gap:16px;"
    "margin-bottom:32px}.card{width:320px;text-align:center}"
    "figcaption{font-size:12px;color:#7a7686}</style></head><body>"
    "<h1>Skribble Showcase</h1>"
    "<p>Hand-drawn widgets, icons, emoji, and the Skribble typeface "
    "across device sizes.</p>" + "".join(cards) + "</body></html>")
(out / "index.html").write_text(html)
print(f"gallery written with {len(devices)} device sections")
PY

echo "Done. Gallery: $OUT/index.html"