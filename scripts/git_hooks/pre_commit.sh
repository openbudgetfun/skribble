#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
cd "$REPO_ROOT"

# Ensure the pinned Flutter SDK is discoverable when the hook runs outside
# the devenv shell (plain git callers without direnv).
if [[ -x "$REPO_ROOT/.fvm/flutter_sdk/bin/dart" ]]; then
  export PATH="$REPO_ROOT/.fvm/flutter_sdk/bin:$PATH"
fi

if [[ $# -eq 0 ]]; then
  echo "pre-commit: no staged files to check"
  exit 0
fi

mapfile -t staged_files < <(
  for file in "$@"; do
    [[ -e "$file" ]] || continue
    printf '%s\n' "$file"
  done | awk '!seen[$0]++'
)

if [[ ${#staged_files[@]} -eq 0 ]]; then
  echo "pre-commit: no existing staged files to check"
  exit 0
fi

mapfile -t dart_files < <(printf '%s\n' "${staged_files[@]}" | rg '\.dart$' | rg -v '(^third_party/|/generated/|\.g\.dart$)' || true)
mapfile -t format_files < <(
  printf '%s\n' "${staged_files[@]}" | rg '\.(dart|json|jsonc|md|markdown|toml|ya?ml|nix|sh|bash)$' | rg -v '(^third_party/|/generated/|\.g\.dart$)' || true
)

if [[ ${#format_files[@]} -gt 0 ]]; then
  echo "pre-commit: formatting staged files"
  dprint fmt --allow-no-files --config "$REPO_ROOT/dprint.json" "${format_files[@]}"
fi

if [[ ${#dart_files[@]} -gt 0 ]]; then
  mapfile -t package_dirs < <(
    for file in "${dart_files[@]}"; do
      dir="$(dirname "$file")"
      while :; do
        if [[ -f "$dir/pubspec.yaml" ]]; then
          printf '%s\n' "$dir"
          break
        fi
        if [[ "$dir" == "." || "$dir" == "/" ]]; then
          break
        fi
        dir="$(dirname "$dir")"
      done
    done | awk '!seen[$0]++'
  )

  for package_dir in "${package_dirs[@]}"; do
    # Vendored third-party code must not be auto-fixed by dart fix; the
    # analysis server's rewrites corrupt unported/upstream code.
    if [[ "$package_dir" == third_party/* ]]; then
      continue
    fi
    # Root-level scripts/tools don't belong to a lint-managed package and
    # dart fix at the workspace root also sweeps path dependencies
    # (third_party). Analyze only.
    if [[ "$package_dir" == "." ]]; then
      echo "pre-commit: skipping dart fix for repo-root scripts"
      continue
    fi
    echo "pre-commit: applying dart fixes in $package_dir"
    (
      cd "$REPO_ROOT/$package_dir"
      dart fix --apply
    )
  done

  echo "pre-commit: re-formatting staged Dart files"
  dart format "${dart_files[@]}"

  echo "pre-commit: analyzing staged Dart files"
  dart analyze --fatal-infos "${dart_files[@]}"
fi
