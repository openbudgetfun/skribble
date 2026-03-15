#!/usr/bin/env bash
# Run rough icon CI parity checks locally or in CI.
#
# Usage:
#   ./scripts/check_rough_icons_ci.sh [regression|baseline-sync|generated-sync|all]
#
# Optional env vars:
#   ROUGH_ICONS_KEEP_UNRESOLVED_REPORT=1  Keep unresolved-report.json after
#                                         successful local regression checks.
#   ROUGH_ICONS_MAX_NEW_UNRESOLVED=<int>  Allow up to this many newly unresolved
#                                         baseline regressions before failing
#                                         (default: 0 / strict-equivalent threshold).

set -euo pipefail

MODE="${1:-all}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

UNRESOLVED_REPORT_PATH="packages/skribble/unresolved-report.json"
BASELINE_SYNC_DIFF_PATH="rough-icons-baseline-sync.diff"
GENERATED_SYNC_DIFF_PATH="rough-icons-generated-sync.diff"

BASELINE_REGRESSION_ARGS=()
BASELINE_REGRESSION_MODE_DESCRIPTION=""

emit_sync_diff_if_needed() {
  local diff_output_path="$1"
  shift
  local tracked_paths=("$@")

  rm -f "$diff_output_path"

  if git diff --quiet -- "${tracked_paths[@]}"; then
    return 0
  fi

  echo "::group::Rough icon sync diff ($diff_output_path)"
  git --no-pager diff -- "${tracked_paths[@]}"
  echo "::endgroup::"

  git --no-pager diff -- "${tracked_paths[@]}" > "$diff_output_path"
  echo "Saved sync diff to $diff_output_path"
  return 1
}

build_baseline_regression_args() {
  local max_new_unresolved="${ROUGH_ICONS_MAX_NEW_UNRESOLVED:-0}"

  if [[ ! "$max_new_unresolved" =~ ^[0-9]+$ ]]; then
    echo "ROUGH_ICONS_MAX_NEW_UNRESOLVED must be a non-negative integer." >&2
    echo "Received: $max_new_unresolved" >&2
    return 1
  fi

  BASELINE_REGRESSION_ARGS=(--max-new-unresolved "$max_new_unresolved")
  BASELINE_REGRESSION_MODE_DESCRIPTION="threshold (--max-new-unresolved $max_new_unresolved)"
}

run_regression_check() {
  build_baseline_regression_args
  echo "Using unresolved baseline regression gate: $BASELINE_REGRESSION_MODE_DESCRIPTION"

  (
    cd packages/skribble
    dart run tool/generate_rough_icons.dart \
      --kit flutter-material \
      --rough-only \
      --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json \
      --unresolved-baseline tool/examples/material_rough_icons.unresolved-baseline.json \
      --unresolved-output unresolved-report.json \
      "${BASELINE_REGRESSION_ARGS[@]}"
  )

  if [[ "${CI:-}" != "true" ]] && [[ "${ROUGH_ICONS_KEEP_UNRESOLVED_REPORT:-0}" != "1" ]]; then
    rm -f "$UNRESOLVED_REPORT_PATH"
  fi
}

run_baseline_sync_check() {
  (
    cd packages/skribble
    dart run tool/generate_rough_icons.dart \
      --kit flutter-material \
      --rough-only \
      --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json \
      --unresolved-baseline-output tool/examples/material_rough_icons.unresolved-baseline.json \
      --unresolved-baseline-output-format codepoints
  )

  dprint fmt packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json

  emit_sync_diff_if_needed \
    "$BASELINE_SYNC_DIFF_PATH" \
    packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json
}

run_generated_sync_check() {
  build_baseline_regression_args
  echo "Using unresolved baseline regression gate: $BASELINE_REGRESSION_MODE_DESCRIPTION"

  (
    cd packages/skribble
    dart run tool/generate_rough_icons.dart \
      --kit flutter-material \
      --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json \
      --unresolved-baseline tool/examples/material_rough_icons.unresolved-baseline.json \
      "${BASELINE_REGRESSION_ARGS[@]}" \
      --output lib/src/generated/material_rough_icons.g.dart \
      --font-dart-output lib/src/generated/material_rough_icon_font.g.dart
  )

  emit_sync_diff_if_needed \
    "$GENERATED_SYNC_DIFF_PATH" \
    packages/skribble/lib/src/generated/material_rough_icons.g.dart \
    packages/skribble/lib/src/generated/material_rough_icon_font.g.dart
}

case "$MODE" in
  regression)
    run_regression_check
    ;;
  baseline-sync)
    run_baseline_sync_check
    ;;
  generated-sync)
    run_generated_sync_check
    ;;
  all)
    run_regression_check
    run_baseline_sync_check
    run_generated_sync_check
    ;;
  *)
    echo "Unknown mode: $MODE"
    echo "Usage: ./scripts/check_rough_icons_ci.sh [regression|baseline-sync|generated-sync|all]"
    exit 1
    ;;
esac
