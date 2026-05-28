#!/bin/bash

# Script to run font roughener tests and validation in CI.
#
# Usage:
#   ./scripts/check_font_roughener_ci.sh [command]
#
# Commands:
#   test      - Run all font roughener tests
#   validate  - Validate the font roughener package
#   all       - Run all checks (default)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FONT_ROUGHEREN_DIR="$PROJECT_ROOT/packages/skribble_font_roughen"

# Default command
COMMAND="${1:-all}"

run_tests() {
    echo "Running font roughener tests..."
    cd "$FONT_ROUGHEREN_DIR"
    dart test
    echo "Tests passed!"
}

validate_package() {
    echo "Validating font roughener package..."
    cd "$FONT_ROUGHEREN_DIR"

    # Check for analysis issues
    echo "Running dart analyze..."
    dart analyze --fatal-infos .

    # Check formatting
    echo "Checking formatting..."
    dart format --output=none --set-exit-if-changed .

    # Check that package can be resolved
    echo "Checking pubspec resolution..."
    dart pub get --dry-run

    echo "Validation passed!"
}

case "$COMMAND" in
    test)
        run_tests
        ;;
    validate)
        validate_package
        ;;
    all)
        run_tests
        validate_package
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: $0 [test|validate|all]"
        exit 1
        ;;
esac

echo "All font roughener checks passed!"
