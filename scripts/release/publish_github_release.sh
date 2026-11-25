#!/usr/bin/env bash
# Publish the GitHub release for a single release tag using monochange's
# rendered release metadata.
#
# `monochange step publish-release --from-ref HEAD` creates or updates every
# release target in the release record at once. When multiple tag runs execute
# independently, letting one tag publish every release creates companion
# releases before their packages exist on their registries and can race across
# concurrent runs. Running `--dry-run --format json` instead renders the exact
# title, notes, and prerelease flag without touching GitHub, and this script
# applies only the entry matching `<tag>`.
#
# Primary main-group tags (`v<version>`, non-prerelease) are marked Latest so
# `releases/latest/download/skribble-design-system.fig` stays on the main
# release; namespaced tags (`rust/v*`, `skribble_charts/v*`,
# `skribble_maps/v*`, `skribble_site/v*`, `js/v*`) pass `--latest=false`.
#
# Re-runs are safe: an existing published release is left untouched (preserving
# manual additions such as Figma links), an existing draft is promoted to
# published, and `--verify-tag` ensures GitHub never implicitly creates a tag.
#
# Usage:
#   ./scripts/release/publish_github_release.sh <tag> [--dry-run] [--plan <path>] [--output <path>] [--repo <owner/repo>]

set -euo pipefail

TAG=""
DRY_RUN=0
PLAN_PATH=""
OUTPUT_PATH=""
REPO="${GITHUB_REPOSITORY:-${SKRIBBLE_REPO:-openbudgetfun/skribble}}"

usage() {
	sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--dry-run)
		DRY_RUN=1
		shift
		;;
	--plan)
		if [[ $# -lt 2 ]]; then
			echo "Error: --plan requires a file path." >&2
			exit 1
		fi
		PLAN_PATH="$2"
		shift 2
		;;
	--output)
		if [[ $# -lt 2 ]]; then
			echo "Error: --output requires a file path." >&2
			exit 1
		fi
		OUTPUT_PATH="$2"
		shift 2
		;;
	--repo)
		if [[ $# -lt 2 ]]; then
			echo "Error: --repo requires owner/repo." >&2
			exit 1
		fi
		REPO="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*)
		echo "Error: unknown option '$1'." >&2
		usage >&2
		exit 1
		;;
	*)
		if [[ -n "$TAG" ]]; then
			echo "Error: tag given twice ('$TAG' and '$1')." >&2
			exit 1
		fi
		TAG="$1"
		shift
		;;
	esac
done

if [[ -z "$TAG" ]]; then
	echo "Error: a release tag is required." >&2
	usage >&2
	exit 1
fi

command -v jq >/dev/null || {
	echo "Error: 'jq' is required but was not found on PATH." >&2
	exit 1
}

if [[ -z "$PLAN_PATH" ]]; then
	command -v monochange >/dev/null || {
		echo "Error: 'monochange' is required when --plan is not given." >&2
		exit 1
	}
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
	command -v gh >/dev/null || {
		echo "Error: 'gh' is required but was not found on PATH." >&2
		exit 1
	}
fi

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

if [[ -n "$PLAN_PATH" ]]; then
	if [[ ! -r "$PLAN_PATH" ]]; then
		echo "Error: release plan '$PLAN_PATH' is not readable." >&2
		exit 1
	fi
	plan_json="$(cat "$PLAN_PATH")"
else
	if [[ -n "$(git rev-parse --show-toplevel 2>/dev/null || true)" ]]; then
		cd "$(git rev-parse --show-toplevel)"
	fi
	if ! plan_json="$(monochange step publish-release --from-ref HEAD --dry-run --format json 2>"$scratch/plan.err")"; then
		echo "Error: could not render GitHub release metadata at HEAD." >&2
		cat "$scratch/plan.err" >&2
		exit 1
	fi
fi

release_json="$(jq -c --arg tag "$TAG" 'first(.releases[]? | select(.tag_name == $tag)) // empty' <<<"$plan_json")"
if [[ -z "$release_json" ]]; then
	echo "Error: no GitHub release entry in the release record matches '$TAG'." >&2
	echo "Releases present: $(jq -r '[.releases[]?.tag_name] | join(", ")' <<<"$plan_json")" >&2
	exit 1
fi

title="$(jq -r '.name // .tag_name' <<<"$release_json")"
prerelease="$(jq -r '.prerelease // false' <<<"$release_json")"
generate_notes="$(jq -r '.generate_release_notes // false' <<<"$release_json")"
jq -r '.body // ""' <<<"$release_json" >"$scratch/notes.md"

latest="false"
if [[ "$TAG" == v[0-9]* && "$prerelease" != "true" ]]; then
	latest="true"
fi

write_output() {
	local action="$1"
	if [[ -n "$OUTPUT_PATH" ]]; then
		jq -n \
			--arg tag "$TAG" \
			--arg repo "$REPO" \
			--arg action "$action" \
			--arg latest "$latest" \
			--argjson release "$release_json" \
			'{
				tag_name: $tag,
				repository: $repo,
				action: $action,
				latest: ($latest == "true"),
				release: $release
			}' >"$OUTPUT_PATH"
	fi
}

if [[ "$DRY_RUN" -eq 1 ]]; then
	echo "Would publish GitHub release for $TAG in $REPO (title: $title, latest: $latest, prerelease: $prerelease)."
	write_output "dry_run"
	exit 0
fi

existing_is_draft="$(gh release view "$TAG" --repo "$REPO" --json isDraft --jq '.isDraft' 2>/dev/null || true)"
if [[ "$existing_is_draft" == "false" ]]; then
	echo "GitHub release for $TAG already exists in $REPO; skipping."
	write_output "already_exists"
	exit 0
fi

if [[ "$existing_is_draft" == "true" ]]; then
	echo "Promoting existing draft GitHub release for $TAG in $REPO (latest: $latest)..."
	gh release edit "$TAG" \
		--repo "$REPO" \
		--draft=false \
		--latest="$latest"
	write_output "promoted_draft"
	exit 0
fi

create_args=(
	"$TAG"
	--repo "$REPO"
	--verify-tag
	--title "$title"
	--latest="$latest"
)
if [[ "$prerelease" == "true" ]]; then
	create_args+=(--prerelease)
fi
if [[ -s "$scratch/notes.md" ]]; then
	create_args+=(--notes-file "$scratch/notes.md")
elif [[ "$generate_notes" == "true" ]]; then
	create_args+=(--generate-notes)
else
	create_args+=(--notes "")
fi

echo "Creating GitHub release for $TAG in $REPO (title: $title, latest: $latest, prerelease: $prerelease)..."
gh release create "${create_args[@]}"
write_output "created"
