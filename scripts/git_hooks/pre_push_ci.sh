#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
cd "$REPO_ROOT"

# Git exports repository-local paths into hooks. Flutter runs Git inside its
# own SDK; inherited paths make it identify this app as the SDK checkout.
while IFS= read -r git_env_name; do
  unset "$git_env_name"
done < <(git rev-parse --local-env-vars)

# Ensure the pinned Flutter SDK is discoverable when the hook runs outside
# the devenv shell (plain git/CI callers without direnv).
if [[ -x "$REPO_ROOT/.fvm/flutter_sdk/bin/dart" ]]; then
  export PATH="$REPO_ROOT/.fvm/flutter_sdk/bin:$PATH"
fi

echo "pre-push: running CI parity formatting checks"
dprint check

echo "pre-push: running CI parity analysis checks"
flutter pub run melos exec --concurrency=2 -- dart analyze --fatal-infos .

echo "pre-push: running unit and widget tests"
flutter pub run melos exec --concurrency=1 --dir-exists=test --depends-on=flutter -- flutter test --no-pub --concurrency=4
