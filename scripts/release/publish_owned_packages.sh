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
# which is how the v0.2.0 and v0.2.1 releases left 11 of the group's 13
# packages unpublished behind a single registry rejection. Per-package
# invocations isolate that failure and let the remaining packages publish; the
# run still exits non-zero so the failure is not hidden.
#
# Dependency order comes from `monochange step publish-readiness`, which is
# also where this differs from the workflow's own step ordering: that step
# dry-runs `pub publish` for every package, which resolves dependencies, and a
# publish-scoped pub.dev credential breaks resolution. In the publish workflow
# it therefore runs *before* setup-dart registers the credential, and the
# workflow passes that already-computed report here with `--readiness`. When
# the flag is omitted the script computes the order itself, which is correct
# for a local run against the developer's own credentials.
#
# The final verification reads the registry API directly rather than reusing a
# readiness report, so it stays correct whether or not one was supplied.
# pub.dev accepts an upload before its API lists the new version ("it may take
# up-to 10 minutes"), so a version this run just uploaded is polled for up to
# 10 minutes before it counts as missing. A package whose publish failed is
# reported at once.
#
# Usage:
#   ./scripts/release/publish_owned_packages.sh <tag> [--dry-run] [--readiness <path>]
#
# Exit codes:
#   0 — every package this tag owns exists on its registry
#   1 — setup error, or at least one package was not published

set -uo pipefail

# Operate on the checkout the script is run from, not on the script's own
# location. The publish workflow extracts this file to a temp path and runs it
# against the release tag's working tree, so deriving the repository root from
# `$BASH_SOURCE` would resolve outside the checkout and find no release record.
# Resolve the root from the working tree instead, and fall back to the script's
# own location only when the caller is not inside a checkout.
if [[ -n "$(git rev-parse --show-toplevel 2>/dev/null)" ]]; then
	ROOT_DIR="$(git rev-parse --show-toplevel)"
else
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

TAG=""
DRY_RUN=0
READINESS=""

usage() {
	sed -n '2,34p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
	arg="$1"
	case "$arg" in
	--dry-run)
		DRY_RUN=1
		shift
		;;
	--readiness)
		if [[ $# -lt 2 ]]; then
			echo "Error: --readiness needs a path." >&2
			exit 1
		fi
		READINESS="$2"
		shift 2
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
		shift
		;;
	esac
done

if [[ -z "$TAG" ]]; then
	echo "Error: a release tag is required." >&2
	usage >&2
	exit 1
fi

for tool in jq monochange curl; do
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

# Dependency order. The release record lists a target's members in declaration
# order, which is not safe to publish in: `skribble` declares a hosted
# constraint on `skribble_lints`, so publishing `skribble` first would fail to
# resolve. `publish-readiness` returns the dependency-corrected order. The
# workflow supplies its report with `--readiness` because it has to compute
# that order before registering the publish credential; anywhere else the
# script computes it.
if [[ -n "$READINESS" ]]; then
	if [[ ! -r "$READINESS" ]]; then
		echo "Error: readiness report '$READINESS' is not readable." >&2
		exit 1
	fi
	order_json="$(cat "$READINESS")"
else

	if ! order_json="$(monochange step publish-readiness --from HEAD --format json 2>"$scratch/readiness.err")"; then
		echo "Error: could not read publish readiness at HEAD." >&2

		cat "$scratch/readiness.err" >&2
		exit 1
	fi
fi

members_json="$(printf '%s' "$record" | jq -c --arg tag "$TAG" \
	'[.record.release_targets[]? | select(.tag_name == $tag) | .members[]]')"
ordered="$(jq -rn --argjson members "$members_json" \
	--argjson order "$(printf '%s' "$order_json" | jq '.publish_order')" \
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
uploaded=""

while IFS= read -r package; do
	[[ -n "$package" ]] || continue
	echo "=== $package ==="

	if [[ "$DRY_RUN" -eq 1 ]]; then
		set -- --dry-run
	else
		set --
	fi

	if monochange step publish-packages --package "$package" --stream-output --format json "$@"; then
		if [[ "$DRY_RUN" -eq 0 ]]; then
			uploaded="$uploaded $package "
		fi
	else
		echo "::warning::$package failed to publish; continuing with the remaining packages" >&2
		failed="$failed $package"
	fi
	echo
done <"$scratch/ordered.txt"

# Verify against the registry API rather than a readiness dry run: the dry run
# would resolve dependencies, which the publish credential breaks. A version
# that is present is a success whether this run published it or an earlier one
# did, so a re-run of a partial publish reports success.
echo "=== verifying every package $TAG owns is on the registry ==="
missing=""
deadline=$((SECONDS + 600))

# Whether pub.dev lists $1 at version $2. Sets `code` to the HTTP status.
on_registry() {
	code="$(curl -s -o "$scratch/pkg.json" -w '%{http_code}' \
		"https://pub.dev/api/packages/$1" || true)"
	[[ "$code" == "200" ]] &&
		[[ "$(jq -r --arg v "$2" '[.versions[]?.version] | index($v) != null' "$scratch/pkg.json" 2>/dev/null)" == "true" ]]
}

while IFS= read -r package; do
	[[ -n "$package" ]] || continue
	version="$(jq -r --arg p "$package" \
		'first(.record.package_publications[]? | select(.package == $p) | .version) // empty' <<<"$record")"

	if [[ -z "$version" ]]; then
		printf '  unknown     %s (no version in the release record)\n' "$package"
		missing="$missing $package"
		continue
	fi

	present=0
	waited=0
	while :; do
		if on_registry "$package" "$version"; then
			present=1
			break
		fi
		if [[ "$uploaded" != *" $package "* || $SECONDS -ge $deadline ]]; then
			break
		fi
		if [[ "$waited" -eq 0 ]]; then
			printf '  waiting     %s (%s was uploaded; pub.dev has not listed it yet)\n' "$package" "$version"
			waited=1
		fi
		sleep 15
	done

	if [[ "$present" -eq 1 ]]; then
		printf '  ok          %s (%s)\n' "$package" "$version"
	elif [[ "$code" != "200" ]]; then
		printf '  MISSING     %s (registry returned HTTP %s)\n' "$package" "${code:-none}"
		missing="$missing $package"
	else
		printf '  MISSING     %s (%s is not on the registry)\n' "$package" "$version"
		missing="$missing $package"
	fi
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

if [[ "$DRY_RUN" -eq 1 ]]; then
	echo "All $count package(s) from $TAG are already on the registry; a real run would skip them."
else
	echo "All $count package(s) from $TAG are present on the registry."
fi
