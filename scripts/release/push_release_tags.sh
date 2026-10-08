#!/usr/bin/env bash
# Tag a merged release commit and push its tags one at a time, watching each
# publish run to completion before pushing the next.
#
# pub.dev only accepts automated publishing from runs triggered by pushing a
# git tag, and GitHub starts no workflows for tags pushed with the Release PR
# workflow's GITHUB_TOKEN. Until that workflow has a credential whose pushes do
# start workflows, a maintainer pushes the tags with their own credentials by
# running this from a checkout of the release commit.
#
# Companion packages depend on the main group, and each package only accepts
# its own tag pattern, so `v<version>` is pushed first and its publish run has
# to succeed before the namespaced companion tags are pushed.
#
# The main tag's publish run creates every GitHub release in the release
# record, and with it each companion tag that was not pushed yet. Those tags
# come from the workflow's GITHUB_TOKEN, so they fire no publish run: a tag
# that is already on origin with no publish run is published from this
# checkout with publish_owned_packages.sh instead.
#
# Tags that already exist on origin are not pushed again, but their publish
# runs are still watched, so a rerun after a partial release is safe.
#
# Usage:
#   git fetch origin && git switch --detach origin/main
#   ./scripts/release/push_release_tags.sh
#
# Exit codes:
#   0 — every release tag is on origin and its publish run succeeded
#   1 — HEAD is not a release commit, a push failed, or a publish run failed

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git fetch --force --tags origin

# Creates the tags locally from the release record; a commit that is already
# tagged is reported as up to date.
monochange step tag-release --from HEAD --push=false --format json >/dev/null

release_commit="$(git rev-parse HEAD)"
release_tags=()
for pattern in 'v[0-9]*' 'skribble_maps/v[0-9]*' 'skribble_charts/v[0-9]*'; do
	while IFS= read -r release_tag; do
		release_tags+=("$release_tag")
	done < <(git tag --points-at HEAD --list "$pattern")
done
if [ "${#release_tags[@]}" -eq 0 ]; then
	echo "error: expected at least one release tag at HEAD ($release_commit)." >&2
	exit 1
fi

# The publish run for tag $1 at the release commit, or nothing.
publish_run() {
	gh run list \
		--workflow publish.yml \
		--event push \
		--branch "$1" \
		--limit 10 \
		--json databaseId,headSha \
		--jq "[.[] | select(.headSha == \"$release_commit\")][0].databaseId // empty"
}

for release_tag in "${release_tags[@]}"; do
	run_id=""
	if git ls-remote --exit-code --tags origin "refs/tags/$release_tag" >/dev/null; then
		run_id="$(publish_run "$release_tag")"
		if [ -z "$run_id" ]; then
			echo "$release_tag was created with its GitHub release; publishing it from this checkout"
			./scripts/release/publish_owned_packages.sh "$release_tag"
			continue
		fi
		echo "$release_tag already exists on origin; watching its publish run"
	else
		echo "pushing $release_tag"
		git push origin "refs/tags/$release_tag"
		for _ in {1..30}; do
			run_id="$(publish_run "$release_tag")"
			if [ -n "$run_id" ]; then
				break
			fi
			sleep 2
		done
		if [ -z "$run_id" ]; then
			echo "error: could not find the publish run for $release_tag." >&2
			exit 1
		fi
	fi

	gh run watch "$run_id" --exit-status
done
