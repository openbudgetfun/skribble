#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
cd "$REPO_ROOT"

echo "pre-push: running CI parity formatting checks"
dprint check

echo "pre-push: running CI parity analysis checks"
melos exec -- dart analyze --fatal-infos .

echo "pre-push: running unit and widget tests"
melos exec --concurrency=1 --dir-exists=test --depends-on=flutter -- flutter test
