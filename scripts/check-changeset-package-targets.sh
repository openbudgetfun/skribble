#!/usr/bin/env bash
# Rejects changesets that target a version group (or an unknown package)
# instead of an explicitly declared package.
#
# Group-targeted changesets (e.g. `main: patch`) are reserved for coordinated
# multi-package releases driven by maintainers; contributor changesets must
# target individual packages so version bumps stay reviewable per package.
#
# Usage: check-changeset-package-targets.sh <path/to/changeset.md> ...
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
CONFIG="$REPO_ROOT/monochange.toml"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required" >&2
  exit 1
fi

# Collect declared package ids and group ids from monochange.toml.
package_ids="$(rg -o '^\[package\.([A-Za-z0-9_-]+)\]' -r '$1' "$CONFIG" || true)"
group_ids="$(rg -o '^\[group\.([A-Za-z0-9_-]+)\]' -r '$1' "$CONFIG" || true)"

if [[ -z "$package_ids" ]]; then
  echo "error: no [package.*] entries found in monochange.toml" >&2
  exit 1
fi

fail=0

declare -a errors=()

for changeset in "$@"; do
  [[ -f "$changeset" ]] || continue

  # Read YAML front-matter between the first two '---' lines.
  frontmatter="$(awk 'NR==1 && $0=="---" {in_fm=1; next} in_fm && $0=="---" {exit} in_fm {print}' "$changeset")"

  if [[ -z "$frontmatter" ]]; then
    errors+=("$changeset: missing YAML front-matter (expected '---' delimiters and a '<package>: <bump>' entry)")
    fail=1
    continue
  fi

  # Each non-empty line in the front-matter is a `<target>: <bump>` mapping.
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    target="$(printf '%s' "$line" | sed -E 's/^([A-Za-z0-9_-]+).*/\1/')"
    [[ -z "$target" ]] && continue

    # Skip comment lines.
    [[ "$target" == \#* ]] && continue

    if printf '%s\n' "$group_ids" | grep -qx "$target"; then
      errors+=("$changeset: targets version group '$target'; group-targeted changesets are reserved for maintainer-coordinated releases. Target individual packages instead (e.g. 'skribble: patch').")
      fail=1
    elif ! printf '%s\n' "$package_ids" | grep -qx "$target"; then
      errors+=("$changeset: targets unknown package '$target'. Known packages: $(printf '%s' "$package_ids" | tr '\n' ' ')")
      fail=1
    fi
  done <<< "$frontmatter"
done

if (( fail )); then
  for e in "${errors[@]}"; do
    echo "✗ $e"
  done
  exit 1
fi

echo "✓ all changesets target declared packages"