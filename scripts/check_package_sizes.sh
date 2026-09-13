#!/usr/bin/env bash
# Verify every publishable package stays inside its compressed-size budget.
#
# pub.dev documents a recommendation of "less than 100 MB after gzip
# compression and less than 256 MB uncompressed" in its publishing guide. That
# is advice rather than a hard cap, so this check enforces a much tighter
# per-package budget: a design-system package should not ship tens of megabytes
# of artwork, and a surprise jump is nearly always a generated catalog that
# should live in its own package instead.
#
# Usage:
#   ./scripts/check_package_sizes.sh [--json] [--verbose]
#
# Budgets live in scripts/package_size_budgets.txt, one "<package> <MiB>" pair
# per line. A package without an entry uses DEFAULT_BUDGET_MIB.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUDGET_FILE="$SCRIPT_DIR/package_size_budgets.txt"

DEFAULT_BUDGET_MIB="${PACKAGE_SIZE_DEFAULT_MIB:-10}"

JSON=0
VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --json) JSON=1 ;;
    --verbose) VERBOSE=1 ;;
    -h | --help)
      sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Error: unknown option '$arg'." >&2
      exit 1
      ;;
  esac
done

cd "$ROOT_DIR"

# Locate the pinned Flutter SDK so `pub publish --dry-run` resolves the same
# SDK the workspace uses.
if [[ -x "$ROOT_DIR/.fvm/flutter_sdk/bin/flutter" ]]; then
  FLUTTER="$ROOT_DIR/.fvm/flutter_sdk/bin/flutter"
  DART="$ROOT_DIR/.fvm/flutter_sdk/bin/dart"
else
  FLUTTER="$(command -v flutter)"
  DART="$(command -v dart)"
fi

# Budget lookup: the file wins, the environment default applies otherwise.
budget_for() {
  local package="$1"
  if [[ -f "$BUDGET_FILE" ]]; then
    local found
    found="$(awk -v pkg="$package" '$1 == pkg { print $2; exit }' "$BUDGET_FILE")"
    if [[ -n "$found" ]]; then
      echo "$found"
      return
    fi
  fi
  echo "$DEFAULT_BUDGET_MIB"
}

# Every workspace package that would actually publish.
mapfile -t PACKAGES < <(
  find packages -mindepth 2 -maxdepth 2 -name pubspec.yaml -print0 |
    xargs -0 awk '
      FNR == 1 { file = FILENAME }
      /^name:/ { name = $2 }
      /^publish_to:[[:space:]]*none/ { skip = 1 }
      ENDFILE {
        if (!skip && name != "") print FILENAME "\t" name
        skip = 0; name = ""
      }' |
    sort
)

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  echo "Error: found no publishable packages under packages/." >&2
  exit 1
fi

# `pub publish --dry-run` prints the archive size as "N KB" or "N MB".
# Returns whole kibibytes so the comparison stays integer-only.
measure_kib() {
  local dir="$1"
  # pub packs the package rooted in the current directory, so run from there.
  pushd "$dir" >/dev/null || {
    echo "ERROR"
    return
  }
  local runner="$DART"
  # Flutter packages need `flutter pub`, pure Dart packages prefer `dart pub`.
  # Already inside $dir after the pushd above, so use a relative path.
  if grep -qE '^\s+(flutter|flutter_test):' pubspec.yaml ||
    grep -q 'sdk: flutter' pubspec.yaml; then
    runner="$FLUTTER"
  fi

  local output
  output="$("$runner" pub publish --dry-run 2>&1 || true)"
  local size
  size="$(sed -n 's/^Total compressed archive size: \(.*\)\.$/\1/p' <<<"$output" | tail -n1)"

  if [[ -z "$size" ]]; then
    # Surface the dry-run text so a real validation failure is diagnosable.
    if [[ "$VERBOSE" -eq 1 ]]; then
      printf '%s\n' "$output" | tail -n 30 >&2
    fi
    popd >/dev/null
    echo "ERROR"
    return
  fi

  popd >/dev/null
  awk -v value="$size" 'BEGIN {
    unit = value
    sub(/^[0-9.]+ ?/, "", unit)
    number = value
    sub(/ ?[A-Za-z]+$/, "", number)
    if (number == "") number = 0
    if (unit ~ /KB/) print (number < 1 ? 1 : int(number + 0.999))
    else if (unit ~ /MB/) print int(number * 1024 + 0.999)
    else if (unit ~ /GB/) print int(number * 1024 * 1024 + 0.999)
    else print int(number + 0.999)
  }'
}

# Dry-run validation is CPU-heavy (pub analyzes each package), so run the
# packages concurrently and stream results as they land.
CONCURRENCY="${PACKAGE_SIZE_CONCURRENCY:-4}"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

measure_package() {
  local entry="$1" slot="$2"
  local dir name budget
  # The registry lists pubspec paths; every later operation wants the package.
  dir="$(dirname "${entry%%$'\t'*}")"
  name="${entry##*$'\t'}"
  budget="$(budget_for "$name")"

  local kib
  kib="$(measure_kib "$dir")"
  if [[ "$kib" == "ERROR" ]]; then
    printf 'ERROR\t%s\t%s\t0\n' "$name" "$budget" > "$WORKDIR/$slot"
    return
  fi

  local status="OK"
  if ((kib > budget * 1024)); then status="OVER"; fi
  printf '%s\t%s\t%s\t%s\n' "$status" "$name" "$budget" "$kib" > "$WORKDIR/$slot"
}

running=0
slot=0
for entry in "${PACKAGES[@]}"; do
  measure_package "$entry" "$slot" &
  slot=$((slot + 1))
  running=$((running + 1))
  if ((running >= CONCURRENCY)); then
    wait -n
    running=$((running - 1))
  fi
done
wait

failures=0
rows=()
for result in "$WORKDIR"/*; do
  rows+=("$(cat "$result")")
done
# Report in workspace order regardless of completion order.
mapfile -t rows < <(for result in "$WORKDIR"/*; do cat "$result"; done)
for row in "${rows[@]}"; do
  [[ "${row%%$'\t'*}" != "OK" ]] && failures=$((failures + 1))
done

if [[ "$JSON" -eq 1 ]]; then
  printf '{'
  printf '"defaultBudgetMiB":%s,' "$DEFAULT_BUDGET_MIB"
  printf '"packages":['
  first=1
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r status name budget kib <<<"$row"
    [[ "$first" -eq 0 ]] && printf ','
    first=0
    printf '{"name":"%s","status":"%s","budgetMiB":%s,"actualMiB":%.3f}' \
      "$name" "$status" "$budget" "$(awk -v k="$kib" 'BEGIN { print k / 1024 }')"
  done
  printf ']}\n'
else
  printf '%-34s %12s %12s   %s\n' "PACKAGE" "ACTUAL" "BUDGET" "STATUS"
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r status name budget kib <<<"$row"
    human="$(awk -v k="$kib" 'BEGIN { printf "%.2f MiB", k / 1024 }')"
    [[ "$status" == "ERROR" ]] && human="n/a"
    printf '%-34s %12s %9s MiB   %s\n' "$name" "$human" "$budget" "$status"
  done
fi

if ((failures > 0)); then
  echo >&2
  echo "Error: $failures package(s) failed the size check." >&2
  echo "If a catalog legitimately grew, raise its budget in" >&2
  echo "scripts/package_size_budgets.txt. If it jumped unexpectedly, check" >&2
  echo "whether a generated catalog belongs in its own package." >&2
  exit 1
fi

[[ "$JSON" -eq 0 ]] && echo && echo "All packages are inside their size budgets."
exit 0
