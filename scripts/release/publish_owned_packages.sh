#!/usr/bin/env bash
# Publish the packages a release tag owns, in dependency order.
#
# pub.dev configures automated publishing per package and each package only
# accepts its own tag pattern, so the main-group `v<version>` tag owns the
# `main` group and a companion tag owns exactly one package. Resolving the
# target from the release record keeps a run from attempting packages another
# tag owns.
#
# Each package is published in its own `monochange publish packages`
# invocation. Monochange aborts the remaining batch once any package fails,
# which is how the v0.2.0 and v0.2.1 releases left 11 of the group's 13
# packages unpublished behind a single registry rejection. Per-package
# invocations isolate that failure and let the remaining packages publish; the
# run still exits non-zero so the failure is not hidden.
#
# Dependency order comes from `monochange publish readiness`, which is
# also where this differs from the workflow's own step ordering: that step
# dry-runs `pub publish` for every package, which resolves dependencies, and a
# publish-scoped pub.dev credential breaks resolution. In the publish workflow
# it therefore runs *before* setup-dart registers the credential, and the
# workflow passes that already-computed report here with `--readiness`. When
# the flag is omitted the script computes the order itself, which is correct
# for a local run against the developer's own credentials.
#
# The final verification reads each package's registry API directly (pub.dev,
# crates.io, or npm, taken from the release record's `package_publications`)
# rather than reusing a readiness report, so it stays correct whether or not
# one was supplied. Registries can accept an upload before their API lists the
# new version ("it may take up-to 10 minutes" on pub.dev), so a version this
# run just uploaded is polled for up to 10 minutes before it counts as missing.
# A package whose publish failed is reported at once.
#
# Usage:
#   ./scripts/release/publish_owned_packages.sh <tag> [--dry-run] [--readiness <path>]
#
# Exit codes:
#   0 — every package this tag owns exists on its registry, or the tag owns
#       none that are published to one (the website)
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

# Packages with `publish = { enabled = false }` (the website) are released and
# tagged but never sent to a registry, so a tag that owns only those has
# nothing to publish.
if ! config="$(monochange step config --format json 2>"$scratch/config.err")"; then
	echo "Error: could not read the monochange configuration." >&2
	cat "$scratch/config.err" >&2
	exit 1
fi

members_json="$(printf '%s' "$record" | jq -c --arg tag "$TAG" \
	'[.record.release_targets[]? | select(.tag_name == $tag) | .members[]]')"
members_json="$(printf '%s' "$config" | jq -c --argjson members "$members_json" \
	'[.config.packages[] | select(.publish.enabled != false) | .id] as $publishable
	| [$members[] | select(. as $member | $publishable | index($member))]')"

if [[ "$members_json" == "[]" ]]; then
	echo "Tag $TAG owns no package that is published to a registry; nothing to publish."
	exit 0
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
	readiness_args=(--from HEAD --format json)
	while IFS= read -r member; do
		[[ -n "$member" ]] && readiness_args+=(--package "$member")
	done < <(jq -r '.[]' <<<"$members_json")

	if ! order_json="$(monochange publish readiness "${readiness_args[@]}" 2>"$scratch/readiness.err")"; then
		echo "Error: could not read publish readiness at HEAD." >&2

		cat "$scratch/readiness.err" >&2
		exit 1
	fi
fi

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

package_registry() {
	jq -r --arg p "$1" '
		first(.record.package_publications[]? | select(.package == $p)) // {}
		| .registry // (
			if .ecosystem == "dart" then "pub_dev"
			elif .ecosystem == "cargo" then "crates_io"
			elif .ecosystem == "npm" then "npm"
			else ""
			end
		)
	' <<<"$record"
}

cargo_retry_delay="${CARGO_RETRY_DELAY_SECONDS:-60}"
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

	pkg_registry="$(package_registry "$package")"

	if monochange publish packages --package "$package" --stream-output --format json "$@"; then
		if [[ "$DRY_RUN" -eq 0 ]]; then
			uploaded="$uploaded $package "
		fi
	elif [[ "$DRY_RUN" -eq 0 && "$pkg_registry" == "crates_io" ]]; then
		# Dependent Cargo crates (such as `skribble_core` after
		# `skribble_rough`) can fail if crates.io's index lags past cargo's own
		# wait window. Wait once and retry that crate before recording a failure.
		echo "::warning::$package failed to publish to crates.io; waiting ${cargo_retry_delay}s and retrying once" >&2
		sleep "$cargo_retry_delay"
		if monochange publish packages --package "$package" --stream-output --format json "$@"; then
			uploaded="$uploaded $package "
		else
			echo "::warning::$package failed to publish on retry; continuing with the remaining packages" >&2
			failed="$failed $package"
		fi
	else
		echo "::warning::$package failed to publish; continuing with the remaining packages" >&2
		failed="$failed $package"
	fi
	echo
done <"$scratch/ordered.txt"

# Verify against each package's registry API rather than a readiness dry run:
# the dry run would resolve dependencies, which the publish credential breaks.
# A version that is present is a success whether this run published it or an
# earlier one did, so a re-run of a partial publish reports success.
echo "=== verifying every package $TAG owns is on the registry ==="
missing=""
verify_timeout="${PUBLISH_VERIFY_TIMEOUT_SECONDS:-600}"
poll_interval="${PUBLISH_POLL_INTERVAL_SECONDS:-15}"
deadline=$((SECONDS + verify_timeout))

pub_dev_api_url="${PUB_DEV_API_URL:-https://pub.dev/api}"
crates_io_api_url="${CRATES_IO_API_URL:-https://crates.io/api/v1}"
npm_registry_url="${NPM_REGISTRY_URL:-https://registry.npmjs.org}"
crates_io_user_agent="${CRATES_IO_USER_AGENT:-skribble-release-verify (https://github.com/openbudgetfun/skribble)}"

registry_display_name() {
	case "$1" in
	pub_dev) printf 'pub.dev' ;;
	crates_io) printf 'crates.io' ;;
	npm) printf 'npm' ;;
	*) printf '%s' "$1" ;;
	esac
}

# Resolve the package's real registry name (for example `dart:skribble_rough`
# and `rust:skribble_rough` both publish under the name `skribble_rough`).
# Prefer the package manifest at the configured path, falling back to stripping
# any `<ecosystem>:` prefix from the monochange package id.
resolve_registry_name() {
	local pkg_id="$1"
	local registry="$2"
	local pkg_path name=""

	pkg_path="$(jq -r --arg p "$pkg_id" 'first(.config.packages[]? | select(.id == $p) | .path) // empty' <<<"$config")"
	if [[ -n "$pkg_path" ]]; then
		case "$registry" in
		pub_dev)
			if [[ -r "$pkg_path/pubspec.yaml" ]]; then
				name="$(awk '
					/^[[:space:]]*name[[:space:]]*:/ {
						line = $0
						sub(/^[^:]*:[[:space:]]*/, "", line)
						sub(/[[:space:]]*#.*$/, "", line)
						gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
						gsub(/^["'\'']|["'\'']$/, "", line)
						print line
						exit
					}
				' "$pkg_path/pubspec.yaml")"
			fi
			;;
		crates_io)
			if [[ -r "$pkg_path/Cargo.toml" ]]; then
				name="$(awk '
					/^\[/ { in_pkg = ($0 == "[package]"); next }
					in_pkg && /^[[:space:]]*name[[:space:]]*=/ {
						line = $0
						sub(/^[^=]*=[[:space:]]*"/, "", line)
						sub(/".*$/, "", line)
						print line
						exit
					}
				' "$pkg_path/Cargo.toml")"
			fi
			;;
		npm)
			if [[ -r "$pkg_path/package.json" ]]; then
				name="$(jq -r '.name // empty' "$pkg_path/package.json" 2>/dev/null || true)"
			fi
			;;
		esac
	fi

	if [[ -n "$name" ]]; then
		printf '%s' "$name"
	else
		printf '%s' "${pkg_id#*:}"
	fi
}

# Whether registry $1 lists package $2 at version $3. Sets `code` to the HTTP
# status (or `unsupported` for an unknown registry).
on_registry() {
	local registry="$1"
	local pkg_name="$2"
	local pkg_version="$3"

	case "$registry" in
	pub_dev)
		code="$(curl -s -o "$scratch/pkg.json" -w '%{http_code}' \
			"${pub_dev_api_url%/}/packages/${pkg_name}" || true)"
		[[ "$code" == "200" ]] &&
			[[ "$(jq -r --arg v "$pkg_version" '[.versions[]?.version] | index($v) != null' "$scratch/pkg.json" 2>/dev/null)" == "true" ]]
		return
		;;
	crates_io)
		code="$(curl -s -H "User-Agent: $crates_io_user_agent" -o "$scratch/pkg.json" -w '%{http_code}' \
			"${crates_io_api_url%/}/crates/${pkg_name}" || true)"
		[[ "$code" == "200" ]] &&
			[[ "$(jq -r --arg v "$pkg_version" '[.versions[]?.num] | index($v) != null' "$scratch/pkg.json" 2>/dev/null)" == "true" ]]
		return
		;;
	npm)
		code="$(curl -s -o "$scratch/pkg.json" -w '%{http_code}' \
			"${npm_registry_url%/}/${pkg_name/\//%2f}" || true)"
		[[ "$code" == "200" ]] &&
			[[ "$(jq -r --arg v "$pkg_version" '.versions | has($v)' "$scratch/pkg.json" 2>/dev/null)" == "true" ]]
		return
		;;
	*)
		code="unsupported"
		return 1
		;;
	esac
}

while IFS= read -r package; do
	[[ -n "$package" ]] || continue
	registry="$(package_registry "$package")"
	version="$(jq -r --arg p "$package" 'first(.record.package_publications[]? | select(.package == $p) | .version) // ""' <<<"$record")"

	if [[ -z "$version" || -z "$registry" ]]; then
		printf '  unknown     %s (missing registry or version in the release record)\n' "$package"
		missing="$missing $package"
		continue
	fi

	registry_name="$(resolve_registry_name "$package" "$registry")"
	registry_label="$(registry_display_name "$registry")"

	present=0
	waited=0
	while :; do
		if on_registry "$registry" "$registry_name" "$version"; then
			present=1
			break
		fi
		if [[ "$code" == "unsupported" || "$uploaded" != *" $package "* || $SECONDS -ge $deadline ]]; then
			break
		fi
		if [[ "$waited" -eq 0 ]]; then
			printf '  waiting     %s (%s was uploaded; %s has not listed it yet)\n' "$package" "$version" "$registry_label"
			waited=1
		fi
		sleep "$poll_interval"
	done

	if [[ "$present" -eq 1 ]]; then
		printf '  ok          %s (%s on %s)\n' "$package" "$version" "$registry_label"
	elif [[ "$code" == "unsupported" ]]; then
		printf '  MISSING     %s (unsupported registry '\''%s'\'')\n' "$package" "$registry"
		missing="$missing $package"
	elif [[ "$code" != "200" ]]; then
		printf '  MISSING     %s (%s returned HTTP %s)\n' "$package" "$registry_label" "${code:-none}"
		missing="$missing $package"
	else
		printf '  MISSING     %s (%s is not on %s)\n' "$package" "$version" "$registry_label"
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
