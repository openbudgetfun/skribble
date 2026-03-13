#!/usr/bin/env bash
# Compare generated screenshots against a baseline set.
#
# Usage:
#   ./scripts/check_screenshot_baseline_diff.sh <baseline_dir> <current_dir> <manifest_file> <diff_dir>

set -euo pipefail

BASELINE_DIR="${1:-.screenshots-baseline}"
CURRENT_DIR="${2:-.screenshots}"
MANIFEST_FILE="${3:-docs/ui-snapshots/screenshot-manifest.txt}"
DIFF_DIR="${4:-.artifacts/screenshot-diff}"
FAIL_ON_DIFF="${FAIL_ON_SCREENSHOT_DIFF:-1}"

if [[ ! -d "$BASELINE_DIR" ]]; then
  echo "::error::Baseline screenshots directory not found: $BASELINE_DIR"
  exit 1
fi

if [[ ! -d "$CURRENT_DIR" ]]; then
  echo "::error::Current screenshots directory not found: $CURRENT_DIR"
  exit 1
fi

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "::error::Manifest file not found: $MANIFEST_FILE"
  exit 1
fi

mkdir -p "$DIFF_DIR"
REPORT_FILE="$DIFF_DIR/report.txt"
: > "$REPORT_FILE"

mapfile -t EXPECTED_PATHS < <(
  grep -vE '^[[:space:]]*(#|$)' "$MANIFEST_FILE" | sed -E 's/[[:space:]]+$//' | sort -u
)

if [[ ${#EXPECTED_PATHS[@]} -eq 0 ]]; then
  echo "::error::No expected screenshot paths found in manifest: $MANIFEST_FILE"
  exit 1
fi

missing_baseline=()
missing_current=()
changed=()

for rel_path in "${EXPECTED_PATHS[@]}"; do
  baseline_file="$BASELINE_DIR/$rel_path"
  current_file="$CURRENT_DIR/$rel_path"

  if [[ ! -f "$baseline_file" ]]; then
    missing_baseline+=("$rel_path")
    continue
  fi

  if [[ ! -f "$current_file" ]]; then
    missing_current+=("$rel_path")
    continue
  fi

  if ! cmp -s "$baseline_file" "$current_file"; then
    changed+=("$rel_path")

    rel_dir="$(dirname "$rel_path")"
    rel_name="$(basename "$rel_path" .png)"
    out_dir="$DIFF_DIR/$rel_dir"
    mkdir -p "$out_dir"

    cp "$baseline_file" "$out_dir/${rel_name}.baseline.png"
    cp "$current_file" "$out_dir/${rel_name}.current.png"
  fi
done

{
  echo "Screenshot baseline comparison report"
  echo "- Baseline dir: $BASELINE_DIR"
  echo "- Current dir:  $CURRENT_DIR"
  echo "- Manifest:     $MANIFEST_FILE"
  echo

  echo "Missing baseline files (${#missing_baseline[@]}):"
  for item in "${missing_baseline[@]}"; do
    echo "  - $item"
  done
  echo

  echo "Missing current files (${#missing_current[@]}):"
  for item in "${missing_current[@]}"; do
    echo "  - $item"
  done
  echo

  echo "Changed files (${#changed[@]}):"
  for item in "${changed[@]}"; do
    echo "  - $item"
  done
} >> "$REPORT_FILE"

issues=$(( ${#missing_baseline[@]} + ${#missing_current[@]} + ${#changed[@]} ))

if [[ $issues -gt 0 ]]; then
  echo "::warning::Screenshot baseline differences detected ($issues issue(s))."
  echo "See $REPORT_FILE and uploaded artifact for details."

  if [[ "$FAIL_ON_DIFF" == "1" ]]; then
    echo "::error::Failing because FAIL_ON_SCREENSHOT_DIFF=1"
    exit 1
  fi

  echo "Continuing despite differences because FAIL_ON_SCREENSHOT_DIFF=$FAIL_ON_DIFF"
else
  echo "No screenshot baseline differences detected." | tee -a "$REPORT_FILE"
fi
