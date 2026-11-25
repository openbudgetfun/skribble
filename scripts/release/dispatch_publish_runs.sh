#!/usr/bin/env bash
# Plan and dispatch publish.yml workflow runs for a release commit's tags in
# dependency order.
#
# Every release target in the monochange release record is grouped into two
# waves:
#   - Wave 1 (initial): independent targets that can publish right away
#     (`main` v*, `rust/v*`, `js/v*`, non-registry tags such as
#     `skribble_site/v*`, plus Dart companion tags when `main` is not in the
#     release).
#   - Wave 2 (dependents): non-`main` Dart targets (`skribble_charts/v*`,
#     `skribble_maps/v*`, or any future Dart companion package) when `main` is
#     part of the release, because they depend on the new `skribble` version on
#     pub.dev.
#
# Each tag is dispatched on its own tag ref (`gh workflow run publish.yml
# --ref <tag>`) so pub.dev receives `ref_type=tag` and `ref=refs/tags/<tag>`,
# and every run stops at the `publisher` environment without holding up any
# other workflow with a polling loop.
#
# Re-runs are idempotent: any tag that already has an active (`queued`,
# `in_progress`, `waiting`, `pending`, `requested`) or successful publish run
# at the release commit is skipped unless `--force` is given. In `reconcile`
# mode (used by release.yml), Wave 2 tags are dispatched only if the `main`
# tag's publish run has already succeeded at the release commit.
#
# Usage:
#   ./scripts/release/dispatch_publish_runs.sh [OPTIONS]
#
# Options:
#   --list                     Print release tags in dependency order and exit
#   --plan                     Print the JSON wave plan and exit
#   --wave <wave>              initial | dependents | all | reconcile (default: reconcile)
#   --record <path>            Read release record JSON from a file instead of monochange
#   --plan-json <json>         Use an already-computed JSON wave plan (from `--plan`)
#   --tags-json <json>         Dispatch an explicit JSON array of tags (requires --commit)
#   --commit <sha>             Release commit SHA the tags must point to
#   --repo <owner/repo>        GitHub repository (default: $GITHUB_REPOSITORY or openbudgetfun/skribble)
#   --workflow <file>          Workflow file to dispatch (default: publish.yml)
#   --dispatch-dependents <b?> Override the `dispatch_dependents` input (true|false)
#   --dry-run                  Print what would be dispatched without calling gh workflow run
#   --skip-remote-check        Skip waiting for tags on the remote before dispatching
#   --force                    Dispatch even if an active or successful run already exists
#   -h, --help                 Show this help message

set -euo pipefail

MODE="dispatch"
WAVE="reconcile"
RECORD_PATH=""
PLAN_JSON_INPUT=""
TAGS_JSON=""
COMMIT=""
REPO="${GITHUB_REPOSITORY:-openbudgetfun/skribble}"
WORKFLOW="publish.yml"
DISPATCH_DEPENDENTS_OVERRIDE=""
DRY_RUN=0
SKIP_REMOTE_CHECK=0
FORCE=0

TAG_WAIT_ATTEMPTS="${TAG_WAIT_ATTEMPTS:-12}"
TAG_WAIT_SLEEP_SECONDS="${TAG_WAIT_SLEEP_SECONDS:-5}"

usage() {
	sed -n '2,44p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--list)
		MODE="list"
		shift
		;;
	--plan)
		MODE="plan"
		shift
		;;
	--wave)
		if [[ $# -lt 2 ]]; then
			echo "Error: --wave requires a value (initial|dependents|all|reconcile)." >&2
			exit 1
		fi
		WAVE="$2"
		shift 2
		;;
	--record)
		if [[ $# -lt 2 ]]; then
			echo "Error: --record requires a file path." >&2
			exit 1
		fi
		RECORD_PATH="$2"
		shift 2
		;;
	--plan-json)
		if [[ $# -lt 2 ]]; then
			echo "Error: --plan-json requires a JSON object." >&2
			exit 1
		fi
		PLAN_JSON_INPUT="$2"
		shift 2
		;;
	--tags-json)
		if [[ $# -lt 2 ]]; then
			echo "Error: --tags-json requires a JSON array." >&2
			exit 1
		fi
		TAGS_JSON="$2"
		shift 2
		;;
	--commit)
		if [[ $# -lt 2 ]]; then
			echo "Error: --commit requires a commit SHA." >&2
			exit 1
		fi
		COMMIT="$2"
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
	--workflow)
		if [[ $# -lt 2 ]]; then
			echo "Error: --workflow requires a workflow file name." >&2
			exit 1
		fi
		WORKFLOW="$2"
		shift 2
		;;
	--dispatch-dependents)
		if [[ $# -lt 2 ]]; then
			echo "Error: --dispatch-dependents requires true or false." >&2
			exit 1
		fi
		DISPATCH_DEPENDENTS_OVERRIDE="$2"
		shift 2
		;;
	--dry-run)
		DRY_RUN=1
		shift
		;;
	--skip-remote-check)
		SKIP_REMOTE_CHECK=1
		shift
		;;
	--force)
		FORCE=1
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Error: unknown option '$1'." >&2
		usage >&2
		exit 1
		;;
	esac
done

case "$WAVE" in
initial | dependents | all | reconcile) ;;
*)
	echo "Error: invalid --wave '$WAVE' (expected initial, dependents, all, or reconcile)." >&2
	exit 1
	;;
esac

if [[ -n "$DISPATCH_DEPENDENTS_OVERRIDE" && "$DISPATCH_DEPENDENTS_OVERRIDE" != "true" && "$DISPATCH_DEPENDENTS_OVERRIDE" != "false" ]]; then
	echo "Error: --dispatch-dependents must be true or false." >&2
	exit 1
fi

command -v jq >/dev/null || {
	echo "Error: 'jq' is required but was not found on PATH." >&2
	exit 1
}

# Build the normalized release wave plan JSON from a monochange release record.
build_plan_from_record() {
	jq -c '
		(.record_commit // "") as $record_commit
		| (.record.package_publications // []) as $pubs
		| [
			$pubs[]
			| select((.registry // "") == "pub_dev" or (.ecosystem // "") == "dart")
			| .package
		] as $dart_pkgs
		| [
			$pubs[]
			| select((.registry // "") == "crates_io" or (.ecosystem // "") == "cargo")
			| .package
		] as $cargo_pkgs
		| [
			$pubs[]
			| select((.registry // "") == "npm" or (.ecosystem // "") == "npm")
			| .package
		] as $npm_pkgs
		| [
			(.record.release_targets // [])[]
			| select(.tag == true and ((.tag_name // "") | length > 0))
		] as $targets
		| (
			[
				$targets[]
				| select(.id == "main" or .version_format == "primary")
				| .tag_name
			][0] // ""
		) as $main_tag
		| [
			$targets[]
			| (.members // []) as $members
			| (.id == "main" or .version_format == "primary") as $is_main
			| ([ $members[] | select(. as $m | $dart_pkgs | index($m)) ] | length > 0) as $has_dart
			| ([ $members[] | select(. as $m | $cargo_pkgs | index($m)) ] | length > 0) as $has_cargo
			| ([ $members[] | select(. as $m | $npm_pkgs | index($m)) ] | length > 0) as $has_npm
			| (
				if $is_main then
					{ wave: "initial", rank: 0 }
				elif ($has_dart and ($main_tag != "")) then
					{ wave: "dependents", rank: 5 }
				elif $has_dart then
					{ wave: "initial", rank: 1 }
				elif $has_cargo then
					{ wave: "initial", rank: 2 }
				elif $has_npm then
					{ wave: "initial", rank: 3 }
				else
					{ wave: "initial", rank: 4 }
				end
			) as $meta
			| {
				id: .id,
				tag_name: .tag_name,
				wave: $meta.wave,
				rank: $meta.rank
			}
		]
		| sort_by(.rank, .tag_name) as $sorted
		| {
			record_commit: $record_commit,
			main_tag: $main_tag,
			initial_tags: [ $sorted[] | select(.wave == "initial") | .tag_name ],
			dependent_tags: [ $sorted[] | select(.wave == "dependents") | .tag_name ],
			all_tags: [ $sorted[] | .tag_name ]
		}
	'
}

PLAN_JSON=""
if [[ -n "$PLAN_JSON_INPUT" ]]; then
	if ! jq -e '
		type == "object"
		and (.initial_tags | type == "array")
		and (.dependent_tags | type == "array")
		and (.all_tags | type == "array")
	' <<<"$PLAN_JSON_INPUT" >/dev/null 2>&1; then
		echo "Error: --plan-json must be a valid plan JSON object from --plan." >&2
		exit 1
	fi
	PLAN_JSON="$(jq -c '.' <<<"$PLAN_JSON_INPUT")"
elif [[ -n "$TAGS_JSON" ]]; then
	if ! jq -e 'type == "array" and all(.[]; type == "string" and length > 0)' <<<"$TAGS_JSON" >/dev/null 2>&1; then
		echo "Error: --tags-json must be a JSON array of non-empty tag strings." >&2
		exit 1
	fi
	PLAN_JSON="$(jq -cn --arg commit "$COMMIT" --argjson tags "$TAGS_JSON" '{
		record_commit: $commit,
		main_tag: "",
		initial_tags: $tags,
		dependent_tags: [],
		all_tags: $tags
	}')"
else
	if [[ -n "$RECORD_PATH" ]]; then
		if [[ ! -r "$RECORD_PATH" ]]; then
			echo "Error: release record '$RECORD_PATH' is not readable." >&2
			exit 1
		fi
		RECORD_JSON="$(cat "$RECORD_PATH")"
	else
		command -v monochange >/dev/null || {
			echo "Error: 'monochange' is required when --record is not given." >&2
			exit 1
		}
		if [[ -n "$(git rev-parse --show-toplevel 2>/dev/null || true)" ]]; then
			cd "$(git rev-parse --show-toplevel)"
		fi
		RECORD_JSON="$(monochange step release-record --from HEAD --format json)"
	fi
	PLAN_JSON="$(printf '%s' "$RECORD_JSON" | build_plan_from_record)"
fi

if [[ -z "$COMMIT" ]]; then
	COMMIT="$(jq -r '.record_commit' <<<"$PLAN_JSON")"
fi
MAIN_TAG="$(jq -r '.main_tag' <<<"$PLAN_JSON")"

if [[ "$MODE" == "plan" ]]; then
	printf '%s\n' "$PLAN_JSON"
	exit 0
fi

if [[ "$MODE" == "list" ]]; then
	case "$WAVE" in
	initial)
		jq -r '.initial_tags[]' <<<"$PLAN_JSON"
		;;
	dependents)
		jq -r '.dependent_tags[]' <<<"$PLAN_JSON"
		;;
	all | reconcile)
		jq -r '.all_tags[]' <<<"$PLAN_JSON"
		;;
	esac
	exit 0
fi

# Dispatch mode requires gh (unless dry-run with force) and git when checking
# remote tags.
if [[ "$DRY_RUN" -eq 0 || "$FORCE" -eq 0 ]]; then
	command -v gh >/dev/null || {
		echo "Error: 'gh' is required but was not found on PATH." >&2
		exit 1
	}
fi

if [[ "$DRY_RUN" -eq 0 && "$SKIP_REMOTE_CHECK" -eq 0 ]]; then
	command -v git >/dev/null || {
		echo "Error: 'git' is required to verify remote tags." >&2
		exit 1
	}
fi

# Query GitHub Actions for existing runs of WORKFLOW on the given tag ref at
# COMMIT. Prints `succeeded`, `active`, or `none`.
existing_run_state() {
	local tag="$1"
	local encoded_tag
	encoded_tag="$(jq -rn --arg t "$tag" '$t | @uri')"
	gh api "repos/${REPO}/actions/workflows/${WORKFLOW}/runs?branch=${encoded_tag}&per_page=20" |
		jq -r --arg sha "$COMMIT" '
			[
				.workflow_runs[]?
				| select($sha == "" or .head_sha == $sha)
			] as $runs
			| if any($runs[]; .status == "completed" and .conclusion == "success") then
				"succeeded"
			elif any(
				$runs[];
				.status == "queued"
				or .status == "in_progress"
				or .status == "waiting"
				or .status == "pending"
				or .status == "requested"
			) then
				"active"
			else
				"none"
			end
		'
}

wait_for_remote_tag() {
	local tag="$1"
	local remote_target="https://github.com/${REPO}.git"
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git remote get-url origin >/dev/null 2>&1; then
		remote_target="origin"
	fi

	local attempt remote_sha
	for attempt in $(seq 1 "$TAG_WAIT_ATTEMPTS"); do
		remote_sha="$(
			git ls-remote --tags "$remote_target" "refs/tags/${tag}" "refs/tags/${tag}^{}" 2>/dev/null |
				awk '{ sha = $1 } END { print sha }'
		)"
		if [[ -n "$remote_sha" ]]; then
			if [[ -n "$COMMIT" && "$remote_sha" != "$COMMIT" ]]; then
				echo "Error: remote tag '$tag' points to $remote_sha, expected $COMMIT." >&2
				return 1
			fi
			return 0
		fi
		if [[ "$attempt" -eq "$TAG_WAIT_ATTEMPTS" ]]; then
			echo "Error: tag '$tag' was not visible on '$remote_target' after $TAG_WAIT_ATTEMPTS attempt(s)." >&2
			return 1
		fi
		echo "Tag $tag is not visible on $remote_target yet (attempt $attempt/$TAG_WAIT_ATTEMPTS); waiting ${TAG_WAIT_SLEEP_SECONDS}s..."
		sleep "$TAG_WAIT_SLEEP_SECONDS"
	done
}

tags_to_dispatch=()
deferred_tags=()

append_tags_from_jq() {
	local expr="$1"
	local target_array="$2"
	local tag
	while IFS= read -r tag; do
		[[ -n "$tag" ]] || continue
		if [[ "$target_array" == "dispatch" ]]; then
			tags_to_dispatch+=("$tag")
		else
			deferred_tags+=("$tag")
		fi
	done < <(jq -r "$expr" <<<"$PLAN_JSON")
}

case "$WAVE" in
initial)
	append_tags_from_jq '.initial_tags[]' dispatch
	append_tags_from_jq '.dependent_tags[]' deferred
	;;
dependents)
	append_tags_from_jq '.dependent_tags[]' dispatch
	;;
all)
	append_tags_from_jq '.all_tags[]' dispatch
	;;
reconcile)
	append_tags_from_jq '.initial_tags[]' dispatch
	dep_count="$(jq '.dependent_tags | length' <<<"$PLAN_JSON")"
	if [[ "$dep_count" -gt 0 ]]; then
		main_state="none"
		if [[ -n "$MAIN_TAG" && "$FORCE" -eq 0 ]]; then
			main_state="$(existing_run_state "$MAIN_TAG")"
		fi
		if [[ "$main_state" == "succeeded" ]]; then
			append_tags_from_jq '.dependent_tags[]' dispatch
		else
			append_tags_from_jq '.dependent_tags[]' deferred
		fi
	fi
	;;
esac

if [[ "${#tags_to_dispatch[@]}" -eq 0 ]]; then
	echo "No release tags to dispatch for wave '$WAVE'."
	exit 0
fi

summary_lines=()

for tag in "${tags_to_dispatch[@]}"; do
	state="none"
	if [[ "$FORCE" -eq 0 ]]; then
		state="$(existing_run_state "$tag")"
	fi

	if [[ "$state" == "succeeded" ]]; then
		echo "Skipping $tag: publish run already succeeded at ${COMMIT:-HEAD}."
		summary_lines+=("| \`$tag\` | skipped (already succeeded) |")
		continue
	fi
	if [[ "$state" == "active" ]]; then
		echo "Skipping $tag: publish run is already active or awaiting approval at ${COMMIT:-HEAD}."
		summary_lines+=("| \`$tag\` | skipped (already active/waiting) |")
		continue
	fi

	if [[ "$DRY_RUN" -eq 0 && "$SKIP_REMOTE_CHECK" -eq 0 ]]; then
		wait_for_remote_tag "$tag"
	fi

	dispatch_dep="false"
	if [[ -n "$MAIN_TAG" && "$tag" == "$MAIN_TAG" ]]; then
		dispatch_dep="true"
	fi
	if [[ -n "$DISPATCH_DEPENDENTS_OVERRIDE" ]]; then
		dispatch_dep="$DISPATCH_DEPENDENTS_OVERRIDE"
	fi

	if [[ "$DRY_RUN" -eq 1 ]]; then
		echo "Would dispatch $WORKFLOW on --ref $tag (tag=$tag, dispatch_dependents=$dispatch_dep)"
		summary_lines+=("| \`$tag\` | would dispatch (\`dispatch_dependents=$dispatch_dep\`) |")
		continue
	fi

	echo "Dispatching $WORKFLOW on --ref $tag (dispatch_dependents=$dispatch_dep)..."
	gh workflow run "$WORKFLOW" \
		--repo "$REPO" \
		--ref "$tag" \
		-f "tag=$tag" \
		-f "dispatch_dependents=$dispatch_dep"
	summary_lines+=("| \`$tag\` | dispatched (\`dispatch_dependents=$dispatch_dep\`) |")
done

for tag in "${deferred_tags[@]}"; do
	echo "Deferring $tag: will be dispatched automatically after $MAIN_TAG succeeds."
	summary_lines+=("| \`$tag\` | deferred until \`$MAIN_TAG\` succeeds |")
done

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
	{
		echo "### Publish workflow dispatch ($WAVE)"
		echo
		echo "| Tag | Status |"
		echo "| --- | --- |"
		printf '%s\n' "${summary_lines[@]}"
	} >>"$GITHUB_STEP_SUMMARY"
fi
