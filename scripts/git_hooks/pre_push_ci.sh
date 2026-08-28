#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
cd "$REPO_ROOT"

# Ensure the pinned Flutter SDK is discoverable when the hook runs outside
# the devenv shell (plain git/CI callers without direnv).
if [[ -x "$REPO_ROOT/.fvm/flutter_sdk/bin/dart" ]]; then
  export PATH="$REPO_ROOT/.fvm/flutter_sdk/bin:$PATH"
fi

echo "pre-push: running CI parity formatting checks"
dprint check

echo "pre-push: running CI parity analysis checks"
melos exec --concurrency=2 -- dart analyze --fatal-infos .

echo "pre-push: running unit and widget tests"
melos exec --concurrency=1 --dir-exists=test --depends-on=flutter -- flutter test
