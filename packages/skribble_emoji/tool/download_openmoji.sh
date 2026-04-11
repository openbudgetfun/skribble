#!/usr/bin/env bash
# Download and extract OpenMoji SVG files for emoji generation.
#
# Usage:
#   bash tool/download_openmoji.sh [target_dir]
#
# Defaults to /tmp/openmoji-svgs if no target directory is given.

set -euo pipefail

OPENMOJI_VERSION="15.1.0"
OPENMOJI_URL="https://github.com/hfg-gmuend/openmoji/releases/download/${OPENMOJI_VERSION}/openmoji-svg-color.zip"
TARGET_DIR="${1:-/tmp/openmoji-svgs}"

echo "=== OpenMoji SVG Downloader ==="
echo "Version: ${OPENMOJI_VERSION}"
echo "Target:  ${TARGET_DIR}"
echo

if [ -d "${TARGET_DIR}" ] && [ "$(ls -1 "${TARGET_DIR}"/*.svg 2>/dev/null | wc -l)" -gt 1000 ]; then
  echo "Target directory already contains SVGs. Skipping download."
  echo "Delete ${TARGET_DIR} to force re-download."
  exit 0
fi

TMPZIP="/tmp/openmoji-svg-color.zip"

echo "Downloading OpenMoji SVGs..."
curl -fSL -o "${TMPZIP}" "${OPENMOJI_URL}"

echo "Extracting to ${TARGET_DIR}..."
mkdir -p "${TARGET_DIR}"
unzip -q -o "${TMPZIP}" -d "${TARGET_DIR}"

# Some releases nest files in a subdirectory — flatten if needed
if [ ! -f "${TARGET_DIR}/1F600.svg" ] && [ -d "${TARGET_DIR}/openmoji-svg-color" ]; then
  mv "${TARGET_DIR}/openmoji-svg-color"/*.svg "${TARGET_DIR}/"
  rmdir "${TARGET_DIR}/openmoji-svg-color" 2>/dev/null || true
fi

SVG_COUNT=$(ls -1 "${TARGET_DIR}"/*.svg 2>/dev/null | wc -l)
echo "Done. ${SVG_COUNT} SVG files extracted."

rm -f "${TMPZIP}"
echo "Cleaned up temporary zip."
