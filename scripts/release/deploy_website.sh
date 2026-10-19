#!/usr/bin/env bash
# Deploy the website for a release: the skribble.dev landing page, the docs
# under docs/, and the storybook under docs/storybook/.
#
# The website ships with releases. Every publish run calls this with its tag,
# and one tag per release commit owns the deploy, so a release with several
# tags deploys once. The owner is the first release tag at the commit in the
# order push_release_tags.sh pushes them: `v<version>`, then
# `skribble_maps/v*`, `skribble_charts/v*`, and `skribble_site/v*`. That tag is
# always pushed with a maintainer's credentials, so its publish run always
# starts; tags created later with the workflow's GITHUB_TOKEN start none.
#
# The deploy itself is the `Docs Pages` workflow, dispatched on `main` with the
# tag: the github-pages environment only accepts deployments from `main`, so
# the tag-push run cannot deploy. A dispatch is one of the few events the
# workflow's GITHUB_TOKEN may start, and it needs `actions: write`.
#
# Usage:
#   ./scripts/release/deploy_website.sh <tag> [--dry-run]
#
# Exit codes:
#   0 — the deploy was dispatched, or another tag of this release owns it
#   1 — the tag does not exist, or the dispatch failed

set -euo pipefail

TAG=""
DRY_RUN=0

for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=1 ;;
	-h | --help)
		sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	-*)
		echo "Error: unknown option '$arg'." >&2
		exit 1
		;;
	*) TAG="$arg" ;;
	esac
done

if [[ -z "$TAG" ]]; then
	echo "Error: a release tag is required." >&2
	exit 1
fi

cd "$(git rev-parse --show-toplevel)"

if ! commit="$(git rev-list -n1 "refs/tags/$TAG" 2>/dev/null)"; then
	echo "Error: tag '$TAG' does not exist in this checkout." >&2
	exit 1
fi

owner=""
for pattern in 'v[0-9]*' 'skribble_maps/v[0-9]*' 'skribble_charts/v[0-9]*' 'skribble_site/v[0-9]*'; do
	owner="$(git tag --points-at "$commit" --list "$pattern" | head -n1)"
	[[ -n "$owner" ]] && break
done

if [[ -n "$owner" && "$owner" != "$TAG" ]]; then
	echo "$owner owns the website deploy for this release; nothing to do for $TAG."
	exit 0
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
	echo "Would dispatch Docs Pages on main for $TAG."
	exit 0
fi

gh workflow run docs-pages.yml --ref main -f release_tag="$TAG"
echo "Dispatched Docs Pages on main for $TAG."
