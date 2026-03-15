#!/usr/bin/env bash
# Run rough icon CI parity checks locally or in CI.
#
# Usage:
#   ./scripts/check_rough_icons_ci.sh [regression|baseline-sync|generated-sync|all]

set -euo pipefail

MODE="${1:-all}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

run_regression_check() {
  (
    cd packages/skribble
    dart run tool/generate_rough_icons.dart \
      --kit flutter-material \
      --rough-only \
      --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json \
      --unresolved-baseline tool/examples/material_rough_icons.unresolved-baseline.json \
      --unresolved-output unresolved-report.json \
      --fail-on-new-unresolved
  )
}

run_baseline_sync_check() {
  (
    cd packages/skribble
    dart run tool/generate_rough_icons.dart \
      --kit flutter-material \
      --rough-only \
      --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json \
      --unresolved-baseline-output tool/examples/material_rough_icons.unresolved-baseline.json
  )

  dprint fmt packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json
  git diff --exit-code -- packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json
}

run_generated_sync_check() {
  (
    cd packages/skribble
    dart run tool/generate_rough_icons.dart \
      --kit flutter-material \
      --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json \
      --unresolved-baseline tool/examples/material_rough_icons.unresolved-baseline.json \
      --fail-on-new-unresolved \
      --output lib/src/generated/material_rough_icons.g.dart \
      --font-dart-output lib/src/generated/material_rough_icon_font.g.dart
  )

  git diff --exit-code -- \
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
