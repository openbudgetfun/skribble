#!/usr/bin/env bash
# Publish the packages a release tag owns, in dependency order.
#
# pub.dev configures automated publishing per package and each package only
# accepts its own tag pattern, so the main-group `v<version>` tag owns the
# `main` group and a companion tag owns exactly one package. Resolving the
# target from the release record keeps a run from attempting packages another
# tag owns.
#
# Each package is published in its own `monochange step publish-packages`
# invocation. Monochange aborts the remaining batch once any package fails,
# which is how the v0.2.0 and v0.2.1 releases left 11 and 12 packages
# unpublished behind a single registry rejection. Per-package invocations
# isolate that failure and let the remaining packages publish; the run still
# exits non-zero so the failure is not hidden.
#
# Usage:
#   ./scripts/release/publish_owned_packages.sh <tag> [--dry-run]
#
# Exit codes:
#   0 — every package this tag owns exists on its registry
#   1 — setup error, or at least one package failed to publish

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TAG=""
DRY_RUN=0

usage() {
	sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
	case "$arg" in
	--dry-run)
		DRY_RUN=1
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*)
		echo "Error: unknown option '$arg'." >&2
		usage >&2
		exit 1
		;;
	*)
		if [[ -n "$TAG" ]]; then
			echo "Error: tag given twice ('$TAG' and '$arg')." >&2
			exit 1
		fi
		TAG="$arg"
		;;
	esac
done

if [[ -z "$TAG" ]]; then
	echo "Error: a release tag is required." >&2
	usage >&2
	exit 1
fi

for tool in jq monochange; do
	command -v "$tool" >/dev/null || {
		echo "Error: '$tool' is required but was not found on PATH." >&2
		exit 1
	}
done

cd "$ROOT_DIR" || exit 1

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

# The release record for HEAD describes the release the tag points at. A tag
# that names no target is a setup error: publishing nothing would otherwise
# look like success.
if ! record="$(monochange step release-record --from HEAD --format json 2>"$scratch/record.err")"; then
	echo "Error: could not read the release record at HEAD." >&2
	cat "$scratch/record.err" >&2
	exit 1
fi

members="$(printf '%s' "$record" | jq -r --arg tag "$TAG" \
	'.record.release_targets[]? | select(.tag_name == $tag) | .members[]')"
if [[ -z "$members" ]]; then
	echo "Error: no release target in the release record matches '$TAG'." >&2
	echo "Targets present: $(printf '%s' "$record" | jq -r '[.record.release_targets[]?.tag_name] | join(", ")')" >&2
	exit 1
fi

# Publishing order follows the dependency-corrected order, not the record's
# declaration order: `skribble_maps` and `skribble_charts` depend on
# `skribble`, so a dependent must not be attempted before its dependency.
if ! readiness="$(monochange step publish-readiness --from HEAD --format json 2>"$scratch/readiness.err")"; then
	echo "Error: could not read publish readiness at HEAD." >&2
	cat "$scratch/readiness.err" >&2
	exit 1
fi

ordered="$(jq -rn \
	--argjson members "$(printf '%s' "$record" | jq --arg tag "$TAG" '[.record.release_targets[]? | select(.tag_name == $tag) | .members[]]')" \
	--argjson order "$(printf '%s' "$readiness" | jq '.publish_order')" \
	'$order[] as $p | select($members | index($p)) | $p')"
if [[ -z "$ordered" ]]; then
	echo "Error: publish readiness listed none of $TAG's packages." >&2
	exit 1
fi

printf '%s\n' "$ordered" >"$scratch/ordered.txt"

count="$(grep -c . "$scratch/ordered.txt")"
echo "Tag $TAG owns $count package(s), published in dependency order:"
sed 's/^/  /' "$scratch/ordered.txt"
echo

failed=""
while IFS= read -r package; do
	[[ -n "$package" ]] || continue
	echo "=== $package ==="
	if [[ "$DRY_RUN" -eq 1 ]]; then
		set -- --dry-run
	else
		set --
	fi
	if ! monochange step publish-packages --package "$package" --stream-output --format json "$@"; then
		echo "::warning::$package failed to publish; continuing with the remaining packages" >&2
		failed="$failed $package"
	fi
	echo
done <"$scratch/ordered.txt"

# A package that already existed is a skip, not a publish, so the check is the
# registry state rather than the per-package exit status.
echo "=== verifying every package $TAG owns is on the registry ==="
monochange step publish-readiness --from HEAD --format json --output "$scratch/final-readiness.json" >/dev/null 2>&1 || true

missing=""
while IFS= read -r package; do
	[[ -n "$package" ]] || continue
	status="$(jq -r --arg p "$package" '.packages[]? | select(.package == $p) | .status' "$scratch/final-readiness.json" 2>/dev/null)"
	case "$status" in
	already_published | published)
		printf '  ok      %s (%s)\n' "$package" "$status"
		;;
	*)
		printf '  MISSING %s (%s)\n' "$package" "${status:-unknown}"
		missing="$missing $package"
		;;
	esac
done <"$scratch/ordered.txt"

echo
if [[ -n "$failed" ]]; then
	echo "::warning::publish failures this run:${failed}" >&2
fi
if [[ -n "$missing" ]]; then
	count="$(printf '%s' "$missing" | wc -w | tr -d ' ')"
	echo "Error: $count package(s) from $TAG are not published:${missing}" >&2
	exit 1
fi

echo "All $(grep -c . "$scratch/ordered.txt") package(s) from $TAG are present on their registry."
