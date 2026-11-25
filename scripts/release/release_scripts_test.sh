#!/usr/bin/env bash
# Unit tests for the release automation scripts under scripts/release/.
#
# Uses stubbed `gh`, `monochange`, `curl`, and a temporary git repository so
# every script can be tested without touching GitHub or any package registry.
# Exercises the exact 0.4.1 release record from PR #284 (5 tags, 21
# publications) alongside synthetic multi-ecosystem, partial-failure, and
# recovery fixtures.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

DISPATCH_SCRIPT="$SCRIPT_DIR/dispatch_publish_runs.sh"
PUBLISH_OWNED_SCRIPT="$SCRIPT_DIR/publish_owned_packages.sh"
PUBLISH_RELEASE_SCRIPT="$SCRIPT_DIR/publish_github_release.sh"
DEPLOY_WEBSITE_SCRIPT="$SCRIPT_DIR/deploy_website.sh"

for tool in jq git awk; do
	command -v "$tool" >/dev/null || {
		echo "Error: '$tool' is required to run release script tests." >&2
		exit 1
	}
done

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

PASSED=0
FAILED=0

pass() {
	PASSED=$((PASSED + 1))
	printf '  PASS  %s\n' "$1"
}

fail() {
	FAILED=$((FAILED + 1))
	printf '  FAIL  %s\n' "$1" >&2
	if [[ $# -gt 1 ]]; then
		printf '        %s\n' "$2" >&2
	fi
}

assert_eq() {
	local name="$1"
	local expected="$2"
	local actual="$3"
	if [[ "$expected" == "$actual" ]]; then
		pass "$name"
	else
		fail "$name" "expected: [$expected], actual: [$actual]"
	fi
}

assert_contains() {
	local name="$1"
	local needle="$2"
	local haystack="$3"
	if grep -Fq -- "$needle" <<<"$haystack"; then
		pass "$name"
	else
		fail "$name" "expected output to contain: [$needle]"
	fi
}

assert_not_contains() {
	local name="$1"
	local needle="$2"
	local haystack="$3"
	if ! grep -Fq -- "$needle" <<<"$haystack"; then
		pass "$name"
	else
		fail "$name" "expected output NOT to contain: [$needle]"
	fi
}

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

PR284_COMMIT="0548512301acafdc1292baae4cd821b630338760"
PR284_RECORD="$TMP_ROOT/pr284-record.json"
cat >"$PR284_RECORD" <<'EOF'
{
  "record_commit": "0548512301acafdc1292baae4cd821b630338760",
  "resolved_commit": "0548512301acafdc1292baae4cd821b630338760",
  "record": {
    "release_targets": [
      {
        "id": "main",
        "kind": "group",
        "version": "0.4.1",
        "version_format": "primary",
        "tag": true,
        "release": true,
        "tag_name": "v0.4.1",
        "members": [
          "skribble",
          "skribble_icons",
          "skribble_icons_simple",
          "skribble_icons_material",
          "skribble_icons_lucide",
          "skribble_icons_bxs",
          "skribble_icons_cib",
          "skribble_emoji",
          "skribble_emoji_gen",
          "skribble_font_noto",
          "skribble_font_noto_sketch",
          "skribble_font_noto_lively",
          "skribble_font_recursive",
          "skribble_font_roughen",
          "skribble_lints",
          "dart:skribble_rough",
          "skribble_jaspr"
        ]
      },
      {
        "id": "rust",
        "kind": "group",
        "version": "0.1.1",
        "version_format": "namespaced",
        "tag": true,
        "release": true,
        "tag_name": "rust/v0.1.1",
        "members": [
          "rust:skribble_rough",
          "skribble_core"
        ]
      },
      {
        "id": "skribble_charts",
        "kind": "package",
        "version": "0.4.1",
        "version_format": "namespaced",
        "tag": true,
        "release": true,
        "tag_name": "skribble_charts/v0.4.1",
        "members": [
          "skribble_charts"
        ]
      },
      {
        "id": "skribble_maps",
        "kind": "package",
        "version": "0.4.1",
        "version_format": "namespaced",
        "tag": true,
        "release": true,
        "tag_name": "skribble_maps/v0.4.1",
        "members": [
          "skribble_maps"
        ]
      },
      {
        "id": "skribble_site",
        "kind": "package",
        "version": "1.1.0",
        "version_format": "namespaced",
        "tag": true,
        "release": true,
        "tag_name": "skribble_site/v1.1.0",
        "members": [
          "skribble_site"
        ]
      }
    ],
    "package_publications": [
      { "package": "dart:skribble_rough", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "rust:skribble_rough", "ecosystem": "cargo", "registry": "crates_io", "version": "0.1.1" },
      { "package": "skribble", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_charts", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_core", "ecosystem": "cargo", "registry": "crates_io", "version": "0.1.1" },
      { "package": "skribble_emoji", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_emoji_gen", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_font_noto", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_font_noto_lively", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_font_noto_sketch", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_font_recursive", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_font_roughen", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_icons", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_icons_bxs", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_icons_cib", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_icons_lucide", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_icons_material", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_icons_simple", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_jaspr", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_lints", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" },
      { "package": "skribble_maps", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.1" }
    ]
  }
}
EOF

PR284_CONFIG="$TMP_ROOT/pr284-config.json"
cat >"$PR284_CONFIG" <<'EOF'
{
  "config": {
    "packages": [
      { "id": "skribble", "path": "packages/skribble", "publish": { "enabled": true } },
      { "id": "skribble_icons", "path": "packages/skribble_icons", "publish": { "enabled": true } },
      { "id": "skribble_icons_simple", "path": "packages/skribble_icons_simple", "publish": { "enabled": true } },
      { "id": "skribble_icons_material", "path": "packages/skribble_icons_material", "publish": { "enabled": true } },
      { "id": "skribble_icons_lucide", "path": "packages/skribble_icons_lucide", "publish": { "enabled": true } },
      { "id": "skribble_icons_bxs", "path": "packages/skribble_icons_bxs", "publish": { "enabled": true } },
      { "id": "skribble_icons_cib", "path": "packages/skribble_icons_cib", "publish": { "enabled": true } },
      { "id": "skribble_emoji", "path": "packages/skribble_emoji", "publish": { "enabled": true } },
      { "id": "skribble_emoji_gen", "path": "packages/skribble_emoji_gen", "publish": { "enabled": true } },
      { "id": "skribble_font_noto", "path": "packages/skribble_font_noto", "publish": { "enabled": true } },
      { "id": "skribble_font_noto_sketch", "path": "packages/skribble_font_noto_sketch", "publish": { "enabled": true } },
      { "id": "skribble_font_noto_lively", "path": "packages/skribble_font_noto_lively", "publish": { "enabled": true } },
      { "id": "skribble_font_recursive", "path": "packages/skribble_font_recursive", "publish": { "enabled": true } },
      { "id": "skribble_font_roughen", "path": "packages/skribble_font_roughen", "publish": { "enabled": true } },
      { "id": "skribble_lints", "path": "packages/skribble_lints", "publish": { "enabled": true } },
      { "id": "dart:skribble_rough", "path": "packages/skribble_rough", "publish": { "enabled": true } },
      { "id": "skribble_jaspr", "path": "packages/skribble_jaspr", "publish": { "enabled": true } },
      { "id": "skribble_maps", "path": "packages/skribble_maps", "publish": { "enabled": true } },
      { "id": "skribble_charts", "path": "packages/skribble_charts", "publish": { "enabled": true } },
      { "id": "skribble_site", "path": "apps/skribble_site", "publish": { "enabled": false } },
      { "id": "rust:skribble_rough", "path": "rust/rough", "publish": { "enabled": true } },
      { "id": "skribble_core", "path": "rust/core", "publish": { "enabled": true } },
      { "id": "@skribble.dev/rough", "path": "js/rough", "publish": { "enabled": true } },
      { "id": "@skribble.dev/react", "path": "js/react", "publish": { "enabled": true } },
      { "id": "skribble-cli", "path": "js/cli", "publish": { "enabled": true } }
    ]
  }
}
EOF

PR284_READINESS="$TMP_ROOT/pr284-readiness.json"
cat >"$PR284_READINESS" <<'EOF'
{
  "publish_order": [
    "rust:skribble_rough",
    "skribble_core",
    "dart:skribble_rough",
    "skribble_lints",
    "skribble_emoji_gen",
    "skribble_font_noto",
    "skribble_font_noto_lively",
    "skribble_font_noto_sketch",
    "skribble_font_recursive",
    "skribble_font_roughen",
    "skribble",
    "skribble_jaspr",
    "skribble_emoji",
    "skribble_icons_bxs",
    "skribble_icons_cib",
    "skribble_icons_lucide",
    "skribble_icons_material",
    "skribble_icons_simple",
    "skribble_icons",
    "skribble_charts",
    "skribble_maps"
  ]
}
EOF

echo "=== 1. dispatch_publish_runs.sh: tag ordering and wave classification ==="

all_tags="$("$DISPATCH_SCRIPT" --record "$PR284_RECORD" --list)"
expected_all=$'v0.4.1\nrust/v0.1.1\nskribble_site/v1.1.0\nskribble_charts/v0.4.1\nskribble_maps/v0.4.1'
assert_eq "PR #284 --list returns all 5 tags in dependency order" "$expected_all" "$all_tags"

wave1_tags="$("$DISPATCH_SCRIPT" --record "$PR284_RECORD" --wave initial --list)"
expected_wave1=$'v0.4.1\nrust/v0.1.1\nskribble_site/v1.1.0'
assert_eq "PR #284 Wave 1 contains main, rust, and site" "$expected_wave1" "$wave1_tags"

wave2_tags="$("$DISPATCH_SCRIPT" --record "$PR284_RECORD" --wave dependents --list)"
expected_wave2=$'skribble_charts/v0.4.1\nskribble_maps/v0.4.1'
assert_eq "PR #284 Wave 2 contains charts and maps" "$expected_wave2" "$wave2_tags"

plan_json="$("$DISPATCH_SCRIPT" --record "$PR284_RECORD" --plan)"
assert_eq "PR #284 --plan sets record_commit" "$PR284_COMMIT" "$(jq -r '.record_commit' <<<"$plan_json")"
assert_eq "PR #284 --plan sets main_tag" "v0.4.1" "$(jq -r '.main_tag' <<<"$plan_json")"

# 6-target release including js/v0.1.0.
SIX_TAG_RECORD="$TMP_ROOT/six-tag-record.json"
jq '.record.release_targets += [{
	"id": "js",
	"kind": "group",
	"version": "0.1.0",
	"version_format": "namespaced",
	"tag": true,
	"release": true,
	"tag_name": "js/v0.1.0",
	"members": ["@skribble.dev/rough"]
}] | .record.package_publications += [{
	"package": "@skribble.dev/rough",
	"ecosystem": "npm",
	"registry": "npm",
	"version": "0.1.0"
}]' "$PR284_RECORD" >"$SIX_TAG_RECORD"

six_wave1="$("$DISPATCH_SCRIPT" --record "$SIX_TAG_RECORD" --wave initial --list)"
assert_eq "6-target Wave 1 includes js/v0.1.0 before site" $'v0.4.1\nrust/v0.1.1\njs/v0.1.0\nskribble_site/v1.1.0' "$six_wave1"
six_wave2="$("$DISPATCH_SCRIPT" --record "$SIX_TAG_RECORD" --wave dependents --list)"
assert_eq "6-target Wave 2 keeps only Dart companions" $'skribble_charts/v0.4.1\nskribble_maps/v0.4.1' "$six_wave2"

# Companion-only release (no main group): companions run immediately in Wave 1.
COMPANION_ONLY_RECORD="$TMP_ROOT/companion-only-record.json"
cat >"$COMPANION_ONLY_RECORD" <<'EOF'
{
  "record_commit": "1111111111111111111111111111111111111111",
  "record": {
    "release_targets": [
      { "id": "skribble_maps", "kind": "package", "version": "0.4.2", "version_format": "namespaced", "tag": true, "release": true, "tag_name": "skribble_maps/v0.4.2", "members": ["skribble_maps"] },
      { "id": "skribble_charts", "kind": "package", "version": "0.4.2", "version_format": "namespaced", "tag": true, "release": true, "tag_name": "skribble_charts/v0.4.2", "members": ["skribble_charts"] }
    ],
    "package_publications": [
      { "package": "skribble_maps", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.2" },
      { "package": "skribble_charts", "ecosystem": "dart", "registry": "pub_dev", "version": "0.4.2" }
    ]
  }
}
EOF
assert_eq "Companion-only Wave 1 runs both companions immediately" \
	$'skribble_charts/v0.4.2\nskribble_maps/v0.4.2' \
	"$("$DISPATCH_SCRIPT" --record "$COMPANION_ONLY_RECORD" --wave initial --list)"
assert_eq "Companion-only Wave 2 is empty" \
	"" \
	"$("$DISPATCH_SCRIPT" --record "$COMPANION_ONLY_RECORD" --wave dependents --list)"

# Rust-only and site-only releases.
RUST_ONLY_RECORD="$TMP_ROOT/rust-only-record.json"
cat >"$RUST_ONLY_RECORD" <<'EOF'
{
  "record_commit": "2222222222222222222222222222222222222222",
  "record": {
    "release_targets": [
      { "id": "rust", "kind": "group", "version": "0.1.2", "version_format": "namespaced", "tag": true, "release": true, "tag_name": "rust/v0.1.2", "members": ["rust:skribble_rough", "skribble_core"] }
    ],
    "package_publications": [
      { "package": "rust:skribble_rough", "ecosystem": "cargo", "registry": "crates_io", "version": "0.1.2" },
      { "package": "skribble_core", "ecosystem": "cargo", "registry": "crates_io", "version": "0.1.2" }
    ]
  }
}
EOF
assert_eq "Rust-only Wave 1 contains rust/v0.1.2" "rust/v0.1.2" "$("$DISPATCH_SCRIPT" --record "$RUST_ONLY_RECORD" --wave initial --list)"

echo "=== 2. dispatch_publish_runs.sh: reconcile & idempotent dispatch ==="

STUB_BIN="$TMP_ROOT/stub-bin"
mkdir -p "$STUB_BIN"
GH_LOG="$TMP_ROOT/gh-dispatch.log"
GH_RUNS_JSON="$TMP_ROOT/gh-runs.json"

cat >"$STUB_BIN/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == "api" ]]; then
	url="$2"
	# Extract URL-encoded branch query param and decode %2F -> /.
	branch="$(printf '%s' "$url" | sed -n 's/.*branch=\([^&]*\).*/\1/p' | sed 's/%2F/\//gi; s/%2f/\//gi')"
	jq -c --arg b "$branch" '{workflow_runs: (.[$b] // [])}' "$STUB_GH_RUNS_FILE"
	exit 0
fi
if [[ "$1" == "workflow" && "$2" == "run" ]]; then
	printf '%s\n' "$*" >>"$STUB_GH_LOG"
	exit 0
fi
echo "Unexpected gh invocation: $*" >&2
exit 1
EOF
chmod +x "$STUB_BIN/gh"

# Scenario A: fresh release — no existing runs.
cat >"$GH_RUNS_JSON" <<'EOF'
{}
EOF
: >"$GH_LOG"
out="$(PATH="$STUB_BIN:$PATH" STUB_GH_RUNS_FILE="$GH_RUNS_JSON" STUB_GH_LOG="$GH_LOG" \
	"$DISPATCH_SCRIPT" --plan-json "$plan_json" --wave reconcile --skip-remote-check --repo openbudgetfun/skribble)"
expected_dispatches=$'workflow run publish.yml --repo openbudgetfun/skribble --ref v0.4.1 -f tag=v0.4.1 -f dispatch_dependents=true\nworkflow run publish.yml --repo openbudgetfun/skribble --ref rust/v0.1.1 -f tag=rust/v0.1.1 -f dispatch_dependents=false\nworkflow run publish.yml --repo openbudgetfun/skribble --ref skribble_site/v1.1.0 -f tag=skribble_site/v1.1.0 -f dispatch_dependents=false'
assert_eq "Fresh reconcile dispatches Wave 1 only with --ref <tag>" "$expected_dispatches" "$(cat "$GH_LOG")"
assert_contains "Fresh reconcile defers skribble_charts/v0.4.1" "Deferring skribble_charts/v0.4.1" "$out"
assert_contains "Fresh reconcile defers skribble_maps/v0.4.1" "Deferring skribble_maps/v0.4.1" "$out"

# Scenario B: partial Wave 1 (v0.4.1 waiting, rust succeeded, site failed).
cat >"$GH_RUNS_JSON" <<EOF
{
  "v0.4.1": [{ "head_sha": "$PR284_COMMIT", "status": "waiting", "conclusion": null }],
  "rust/v0.1.1": [{ "head_sha": "$PR284_COMMIT", "status": "completed", "conclusion": "success" }],
  "skribble_site/v1.1.0": [{ "head_sha": "$PR284_COMMIT", "status": "completed", "conclusion": "failure" }]
}
EOF
: >"$GH_LOG"
PATH="$STUB_BIN:$PATH" STUB_GH_RUNS_FILE="$GH_RUNS_JSON" STUB_GH_LOG="$GH_LOG" \
	"$DISPATCH_SCRIPT" --plan-json "$plan_json" --wave reconcile --skip-remote-check --repo openbudgetfun/skribble >/dev/null
assert_eq "Reconcile during Wave 1 re-dispatches only failed site tag" \
	"workflow run publish.yml --repo openbudgetfun/skribble --ref skribble_site/v1.1.0 -f tag=skribble_site/v1.1.0 -f dispatch_dependents=false" \
	"$(cat "$GH_LOG")"

# Scenario C: recovery after v0.4.1 succeeded; charts already active, maps missing.
cat >"$GH_RUNS_JSON" <<EOF
{
  "v0.4.1": [{ "head_sha": "$PR284_COMMIT", "status": "completed", "conclusion": "success" }],
  "rust/v0.1.1": [{ "head_sha": "$PR284_COMMIT", "status": "completed", "conclusion": "success" }],
  "skribble_site/v1.1.0": [{ "head_sha": "$PR284_COMMIT", "status": "completed", "conclusion": "success" }],
  "skribble_charts/v0.4.1": [{ "head_sha": "$PR284_COMMIT", "status": "in_progress", "conclusion": null }]
}
EOF
: >"$GH_LOG"
PATH="$STUB_BIN:$PATH" STUB_GH_RUNS_FILE="$GH_RUNS_JSON" STUB_GH_LOG="$GH_LOG" \
	"$DISPATCH_SCRIPT" --plan-json "$plan_json" --wave reconcile --skip-remote-check --repo openbudgetfun/skribble >/dev/null
assert_eq "Reconcile after main succeeds dispatches only missing Wave 2 tag" \
	"workflow run publish.yml --repo openbudgetfun/skribble --ref skribble_maps/v0.4.1 -f tag=skribble_maps/v0.4.1 -f dispatch_dependents=false" \
	"$(cat "$GH_LOG")"

# Scenario D: publish.yml dispatch_dependents handoff via --tags-json.
: >"$GH_LOG"
PATH="$STUB_BIN:$PATH" STUB_GH_RUNS_FILE="$GH_RUNS_JSON" STUB_GH_LOG="$GH_LOG" \
	"$DISPATCH_SCRIPT" --tags-json '["skribble_charts/v0.4.1","skribble_maps/v0.4.1"]' \
	--commit "$PR284_COMMIT" --wave initial --dispatch-dependents false \
	--skip-remote-check --repo openbudgetfun/skribble >/dev/null
assert_eq "Wave 2 --tags-json handoff skips active charts and dispatches maps" \
	"workflow run publish.yml --repo openbudgetfun/skribble --ref skribble_maps/v0.4.1 -f tag=skribble_maps/v0.4.1 -f dispatch_dependents=false" \
	"$(cat "$GH_LOG")"

echo "=== 3. publish_owned_packages.sh: registry routing for all 21 PR #284 publications + npm ==="

PUB_STUB_BIN="$TMP_ROOT/pub-stub-bin"
mkdir -p "$PUB_STUB_BIN"
CURL_LOG="$TMP_ROOT/curl.log"
MC_LOG="$TMP_ROOT/monochange.log"

cat >"$PUB_STUB_BIN/monochange" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == "step" && "$2" == "release-record" ]]; then
	cat "$STUB_RECORD_FILE"
	exit 0
fi
if [[ "$1" == "step" && "$2" == "config" ]]; then
	cat "$STUB_CONFIG_FILE"
	exit 0
fi
if [[ "$1" == "publish" && "$2" == "readiness" ]]; then
	cat "$STUB_READINESS_FILE"
	exit 0
fi
if [[ "$1" == "publish" && "$2" == "packages" ]]; then
	pkg=""
	shift 2
	while [[ $# -gt 0 ]]; do
		if [[ "$1" == "--package" ]]; then
			pkg="$2"
			shift 2
		else
			shift
		fi
	done
	printf '%s\n' "$pkg" >>"$STUB_MC_LOG"
	if [[ -n "${STUB_FAIL_PACKAGE:-}" && "$pkg" == "$STUB_FAIL_PACKAGE" ]]; then
		echo "simulated publish failure for $pkg" >&2
		exit 1
	fi
	exit 0
fi
echo "Unexpected monochange invocation: $*" >&2
exit 1
EOF
chmod +x "$PUB_STUB_BIN/monochange"

cat >"$PUB_STUB_BIN/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
out_file=""
ua=""
url=""
while [[ $# -gt 0 ]]; do
	case "$1" in
	-o)
		out_file="$2"
		shift 2
		;;
	-H)
		if [[ "$2" == User-Agent:* ]]; then
			ua="$2"
		fi
		shift 2
		;;
	-w)
		shift 2
		;;
	-s)
		shift
		;;
	*)
		url="$1"
		shift
		;;
	esac
done

printf '%s|%s\n' "$url" "$ua" >>"$STUB_CURL_LOG"

if [[ -n "${STUB_FLAKY_ONCE_FILE:-}" && -f "$STUB_FLAKY_ONCE_FILE" ]]; then
	rm -f "$STUB_FLAKY_ONCE_FILE"
	printf '{}' >"$out_file"
	printf '404'
	exit 0
fi

if [[ -n "${STUB_MISSING_URL_SUBSTR:-}" && "$url" == *"$STUB_MISSING_URL_SUBSTR"* ]]; then
	printf '{"versions":[]}' >"$out_file"
	printf '200'
	exit 0
fi

if [[ "$url" == https://pub.dev/api/packages/* ]]; then
	printf '{"versions":[{"version":"0.4.1"}]}' >"$out_file"
	printf '200'
elif [[ "$url" == https://crates.io/api/v1/crates/* ]]; then
	if [[ -z "$ua" ]]; then
		printf '{}' >"$out_file"
		printf '403'
	else
		printf '{"versions":[{"num":"0.1.1"}]}' >"$out_file"
		printf '200'
	fi
elif [[ "$url" == https://registry.npmjs.org/* ]]; then
	printf '{"versions":{"0.1.0":{}}}' >"$out_file"
	printf '200'
else
	printf '{}' >"$out_file"
	printf '404'
fi
EOF
chmod +x "$PUB_STUB_BIN/curl"

# Run against every one of the 5 PR #284 tags and collect all 21 registry requests.
ALL_CURL_LOG="$TMP_ROOT/all-pr284-curl.log"
: >"$ALL_CURL_LOG"

# 3a. v0.4.1 (17 Dart packages in main group)
: >"$CURL_LOG"
: >"$MC_LOG"
out="$(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$PR284_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	"$PUBLISH_OWNED_SCRIPT" v0.4.1 --readiness "$PR284_READINESS")"
assert_eq "v0.4.1 publishes all 17 main Dart packages" "17" "$(wc -l <"$MC_LOG" | tr -d ' ')"
assert_eq "v0.4.1 verifies all 17 packages against pub.dev" "17" "$(grep -c '^https://pub\.dev/api/packages/' "$CURL_LOG")"
assert_contains "dart:skribble_rough verifies pub.dev/api/packages/skribble_rough (no dart: prefix)" \
	"https://pub.dev/api/packages/skribble_rough|" "$(cat "$CURL_LOG")"
assert_not_contains "v0.4.1 never queries dart:skribble_rough literally" \
	"dart:skribble_rough" "$(cat "$CURL_LOG")"
assert_contains "v0.4.1 reports ok on pub.dev" "ok          dart:skribble_rough (0.4.1 on pub.dev)" "$out"
cat "$CURL_LOG" >>"$ALL_CURL_LOG"

# 3b. rust/v0.1.1 (2 Cargo crates)
: >"$CURL_LOG"
: >"$MC_LOG"
out="$(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$PR284_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	"$PUBLISH_OWNED_SCRIPT" rust/v0.1.1 --readiness "$PR284_READINESS")"
assert_eq "rust/v0.1.1 publishes rust:skribble_rough then skribble_core" \
	$'rust:skribble_rough\nskribble_core' "$(cat "$MC_LOG")"
assert_contains "rust:skribble_rough verifies crates.io/api/v1/crates/skribble_rough with User-Agent" \
	"https://crates.io/api/v1/crates/skribble_rough|User-Agent:" "$(cat "$CURL_LOG")"
assert_contains "skribble_core verifies crates.io/api/v1/crates/skribble_core with User-Agent" \
	"https://crates.io/api/v1/crates/skribble_core|User-Agent:" "$(cat "$CURL_LOG")"
assert_not_contains "rust/v0.1.1 never queries pub.dev" "pub.dev" "$(cat "$CURL_LOG")"
assert_not_contains "rust/v0.1.1 never queries rust:skribble_rough literally" "rust:skribble_rough" "$(cat "$CURL_LOG")"
assert_contains "rust/v0.1.1 reports ok on crates.io" "ok          rust:skribble_rough (0.1.1 on crates.io)" "$out"
cat "$CURL_LOG" >>"$ALL_CURL_LOG"

# 3c. skribble_charts/v0.4.1 and skribble_maps/v0.4.1
for companion in skribble_charts skribble_maps; do
	: >"$CURL_LOG"
	: >"$MC_LOG"
	(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
		STUB_RECORD_FILE="$PR284_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
		STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
		"$PUBLISH_OWNED_SCRIPT" "${companion}/v0.4.1" --readiness "$PR284_READINESS") >/dev/null
	assert_eq "${companion}/v0.4.1 publishes only ${companion}" "$companion" "$(cat "$MC_LOG")"
	assert_eq "${companion}/v0.4.1 verifies against pub.dev" \
		"https://pub.dev/api/packages/${companion}|" "$(cat "$CURL_LOG")"
	cat "$CURL_LOG" >>"$ALL_CURL_LOG"
done

# 3d. skribble_site/v1.1.0 (no registry packages)
: >"$CURL_LOG"
: >"$MC_LOG"
out="$(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$PR284_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	"$PUBLISH_OWNED_SCRIPT" skribble_site/v1.1.0 --readiness "$PR284_READINESS")"
assert_contains "skribble_site/v1.1.0 skips registry publishing" "owns no package that is published to a registry" "$out"
assert_eq "skribble_site/v1.1.0 makes zero registry calls" "0" "$(wc -l <"$CURL_LOG" | tr -d ' ')"

# Combined check across all 21 publications in PR #284: 19 pub.dev + 2 crates.io = 21.
assert_eq "PR #284 routes all 21 publications (19 pub.dev + 2 crates.io)" \
	"21" "$(wc -l <"$ALL_CURL_LOG" | tr -d ' ')"
assert_eq "PR #284 routes exactly 19 publications to pub.dev" \
	"19" "$(grep -c '^https://pub\.dev/api/packages/' "$ALL_CURL_LOG")"
assert_eq "PR #284 routes exactly 2 publications to crates.io" \
	"2" "$(grep -c '^https://crates\.io/api/v1/crates/' "$ALL_CURL_LOG")"

# 3e. npm routing by record.package_publications[].registry (both scoped and unscoped!).
NPM_RECORD="$TMP_ROOT/npm-record.json"
cat >"$NPM_RECORD" <<'EOF'
{
  "record_commit": "3333333333333333333333333333333333333333",
  "record": {
    "release_targets": [
      {
        "id": "js",
        "kind": "group",
        "version": "0.1.0",
        "version_format": "namespaced",
        "tag": true,
        "release": true,
        "tag_name": "js/v0.1.0",
        "members": ["@skribble.dev/rough", "skribble-cli"]
      }
    ],
    "package_publications": [
      { "package": "@skribble.dev/rough", "ecosystem": "npm", "registry": "npm", "version": "0.1.0" },
      { "package": "skribble-cli", "ecosystem": "npm", "registry": "npm", "version": "0.1.0" }
    ]
  }
}
EOF
NPM_READINESS="$TMP_ROOT/npm-readiness.json"
cat >"$NPM_READINESS" <<'EOF'
{"publish_order": ["@skribble.dev/rough", "skribble-cli"]}
EOF
: >"$CURL_LOG"
: >"$MC_LOG"
(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$NPM_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$NPM_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	"$PUBLISH_OWNED_SCRIPT" js/v0.1.0 --readiness "$NPM_READINESS") >/dev/null
assert_contains "Scoped npm package routes to registry.npmjs.org" \
	"https://registry.npmjs.org/@skribble.dev%2frough|" "$(cat "$CURL_LOG")"
assert_contains "Unscoped npm package routes to registry.npmjs.org (not pub.dev)" \
	"https://registry.npmjs.org/skribble-cli|" "$(cat "$CURL_LOG")"

# 3f. Failure isolation: failing rust:skribble_rough still attempts skribble_core, exits 1.
: >"$CURL_LOG"
: >"$MC_LOG"
set +e
out="$(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$PR284_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	STUB_FAIL_PACKAGE="rust:skribble_rough" STUB_MISSING_URL_SUBSTR="/crates/skribble_rough" \
	"$PUBLISH_OWNED_SCRIPT" rust/v0.1.1 --readiness "$PR284_READINESS" 2>&1)"
rc=$?
set -e
assert_eq "Failure isolation exits non-zero when one crate fails" "1" "$rc"
assert_eq "Failure isolation still publishes remaining crate" \
	$'rust:skribble_rough\nskribble_core' "$(cat "$MC_LOG")"
assert_contains "Failure isolation reports missing crate on crates.io" \
	"MISSING     rust:skribble_rough (0.1.1 is not on crates.io)" "$out"
assert_contains "Failure isolation reports ok for sibling crate" \
	"ok          skribble_core (0.1.1 on crates.io)" "$out"

# 3g. Delayed registry visibility polling for a just-uploaded crate.
FLAKY_FLAG="$TMP_ROOT/flaky-once"
touch "$FLAKY_FLAG"
: >"$CURL_LOG"
: >"$MC_LOG"
out="$(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$PR284_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	STUB_FLAKY_ONCE_FILE="$FLAKY_FLAG" PUBLISH_POLL_INTERVAL_SECONDS=0 \
	"$PUBLISH_OWNED_SCRIPT" rust/v0.1.1 --readiness "$PR284_READINESS")"
assert_contains "Delayed crates.io indexing prints waiting message for crates.io" \
	"crates.io has not listed it yet" "$out"
assert_contains "Delayed crates.io indexing succeeds on retry" \
	"ok          rust:skribble_rough (0.1.1 on crates.io)" "$out"

# 3h. Unknown registry fails loudly instead of falling back to pub.dev.
UNKNOWN_REG_RECORD="$TMP_ROOT/unknown-reg-record.json"
cat >"$UNKNOWN_REG_RECORD" <<'EOF'
{
  "record_commit": "4444444444444444444444444444444444444444",
  "record": {
    "release_targets": [
      { "id": "rust", "kind": "group", "version": "0.1.1", "version_format": "namespaced", "tag": true, "release": true, "tag_name": "rust/v0.1.1", "members": ["skribble_core"] }
    ],
    "package_publications": [
      { "package": "skribble_core", "ecosystem": "cargo", "registry": "unknown_registry", "version": "0.1.1" }
    ]
  }
}
EOF
: >"$CURL_LOG"
: >"$MC_LOG"
set +e
out="$(cd "$ROOT_DIR" && PATH="$PUB_STUB_BIN:$PATH" \
	STUB_RECORD_FILE="$UNKNOWN_REG_RECORD" STUB_CONFIG_FILE="$PR284_CONFIG" \
	STUB_READINESS_FILE="$PR284_READINESS" STUB_CURL_LOG="$CURL_LOG" STUB_MC_LOG="$MC_LOG" \
	"$PUBLISH_OWNED_SCRIPT" rust/v0.1.1 --readiness "$PR284_READINESS" 2>&1)"
rc=$?
set -e
assert_eq "Unknown registry exits non-zero" "1" "$rc"
assert_contains "Unknown registry reports unsupported registry" "unsupported registry 'unknown_registry'" "$out"
assert_eq "Unknown registry makes zero HTTP calls" "0" "$(wc -l <"$CURL_LOG" | tr -d ' ')"

echo "=== 4. publish_github_release.sh: per-tag GitHub release creation & idempotency ==="

GH_REL_PLAN="$TMP_ROOT/release-plan.json"
cat >"$GH_REL_PLAN" <<'EOF'
{
  "releases": [
    { "tag_name": "v0.4.1", "name": "v0.4.1 (2026-11-24)", "body": "Main release notes", "prerelease": false, "draft": false, "generate_release_notes": false },
    { "tag_name": "rust/v0.1.1", "name": "rust v0.1.1 (2026-11-24)", "body": "Rust release notes", "prerelease": false, "draft": false, "generate_release_notes": false },
    { "tag_name": "skribble_charts/v0.4.1", "name": "skribble_charts v0.4.1 (2026-11-24)", "body": "Charts release notes", "prerelease": false, "draft": false, "generate_release_notes": false },
    { "tag_name": "skribble_maps/v0.4.1", "name": "skribble_maps v0.4.1 (2026-11-24)", "body": "Maps release notes", "prerelease": false, "draft": false, "generate_release_notes": false },
    { "tag_name": "skribble_site/v1.1.0", "name": "skribble.dev v1.1.0 (2026-11-24)", "body": "Site release notes", "prerelease": false, "draft": false, "generate_release_notes": false }
  ]
}
EOF

REL_STUB_BIN="$TMP_ROOT/rel-stub-bin"
mkdir -p "$REL_STUB_BIN"
REL_GH_LOG="$TMP_ROOT/rel-gh.log"

cat >"$REL_STUB_BIN/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == "release" && "$2" == "view" ]]; then
	case "${STUB_RELEASE_STATE:-missing}" in
	published)
		printf 'false\n'
		exit 0
		;;
	draft)
		printf 'true\n'
		exit 0
		;;
	*)
		exit 1
		;;
	esac
fi
printf '%s\n' "$*" >>"$STUB_REL_GH_LOG"
EOF
chmod +x "$REL_STUB_BIN/gh"

# Main tag creates ONLY v0.4.1 with --verify-tag and --latest=true.
: >"$REL_GH_LOG"
PATH="$REL_STUB_BIN:$PATH" STUB_REL_GH_LOG="$REL_GH_LOG" STUB_RELEASE_STATE="missing" \
	"$PUBLISH_RELEASE_SCRIPT" v0.4.1 --plan "$GH_REL_PLAN" --output "$TMP_ROOT/rel-main.json" --repo openbudgetfun/skribble >/dev/null
assert_eq "v0.4.1 calls gh release create once" "1" "$(wc -l <"$REL_GH_LOG" | tr -d ' ')"
assert_contains "v0.4.1 uses --verify-tag" "--verify-tag" "$(cat "$REL_GH_LOG")"
assert_contains "v0.4.1 sets --latest=true" "--latest=true" "$(cat "$REL_GH_LOG")"
assert_not_contains "v0.4.1 never touches companion tags" "skribble_maps/v0.4.1" "$(cat "$REL_GH_LOG")"
assert_eq "v0.4.1 output action is created" "created" "$(jq -r '.action' "$TMP_ROOT/rel-main.json")"

# Namespaced tags each create ONLY their own tag with --latest=false.
for ns_tag in rust/v0.1.1 skribble_charts/v0.4.1 skribble_maps/v0.4.1 skribble_site/v1.1.0; do
	: >"$REL_GH_LOG"
	PATH="$REL_STUB_BIN:$PATH" STUB_REL_GH_LOG="$REL_GH_LOG" STUB_RELEASE_STATE="missing" \
		"$PUBLISH_RELEASE_SCRIPT" "$ns_tag" --plan "$GH_REL_PLAN" --repo openbudgetfun/skribble >/dev/null
	assert_contains "$ns_tag creates its own release with --latest=false" \
		"release create $ns_tag --repo openbudgetfun/skribble --verify-tag" "$(cat "$REL_GH_LOG")"
	assert_contains "$ns_tag sets --latest=false" "--latest=false" "$(cat "$REL_GH_LOG")"
done

# Existing published release is skipped idempotently.
: >"$REL_GH_LOG"
PATH="$REL_STUB_BIN:$PATH" STUB_REL_GH_LOG="$REL_GH_LOG" STUB_RELEASE_STATE="published" \
	"$PUBLISH_RELEASE_SCRIPT" v0.4.1 --plan "$GH_REL_PLAN" --output "$TMP_ROOT/rel-existing.json" --repo openbudgetfun/skribble >/dev/null
assert_eq "Existing published release skips gh release create" "0" "$(wc -l <"$REL_GH_LOG" | tr -d ' ')"
assert_eq "Existing published release reports already_exists" "already_exists" "$(jq -r '.action' "$TMP_ROOT/rel-existing.json")"

# Existing draft release is promoted cleanly.
: >"$REL_GH_LOG"
PATH="$REL_STUB_BIN:$PATH" STUB_REL_GH_LOG="$REL_GH_LOG" STUB_RELEASE_STATE="draft" \
	"$PUBLISH_RELEASE_SCRIPT" rust/v0.1.1 --plan "$GH_REL_PLAN" --output "$TMP_ROOT/rel-draft.json" --repo openbudgetfun/skribble >/dev/null
assert_contains "Existing draft release is promoted with gh release edit" \
	"release edit rust/v0.1.1 --repo openbudgetfun/skribble --draft=false --latest=false" "$(cat "$REL_GH_LOG")"
assert_eq "Promoted draft reports promoted_draft" "promoted_draft" "$(jq -r '.action' "$TMP_ROOT/rel-draft.json")"

echo "=== 5. deploy_website.sh: single-owner website deploy including rust/v* ==="

SITE_REPO="$TMP_ROOT/site-repo"
mkdir -p "$SITE_REPO"
git -C "$SITE_REPO" init -q
printf 'hello\n' >"$SITE_REPO/README.md"
git -C "$SITE_REPO" add README.md
tree1="$(git -C "$SITE_REPO" write-tree)"
commit1="$(GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.invalid GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.invalid \
	git -C "$SITE_REPO" commit-tree "$tree1" -m "release 0.4.1")"
git -C "$SITE_REPO" update-ref HEAD "$commit1"
git -C "$SITE_REPO" tag v0.4.1 "$commit1"
git -C "$SITE_REPO" tag rust/v0.1.1 "$commit1"
git -C "$SITE_REPO" tag skribble_charts/v0.4.1 "$commit1"
git -C "$SITE_REPO" tag skribble_maps/v0.4.1 "$commit1"
git -C "$SITE_REPO" tag skribble_site/v1.1.0 "$commit1"

pushd "$SITE_REPO" >/dev/null
assert_contains "v0.4.1 owns website deploy on 5-tag commit" \
	"Would dispatch Docs Pages on main for v0.4.1." \
	"$("$DEPLOY_WEBSITE_SCRIPT" v0.4.1 --dry-run)"
for other in rust/v0.1.1 skribble_charts/v0.4.1 skribble_maps/v0.4.1 skribble_site/v1.1.0; do
	assert_contains "$other yields website deploy to v0.4.1" \
		"v0.4.1 owns the website deploy" \
		"$("$DEPLOY_WEBSITE_SCRIPT" "$other" --dry-run)"
done

printf 'rust only\n' >>"$SITE_REPO/README.md"
git -C "$SITE_REPO" add README.md
tree2="$(git -C "$SITE_REPO" write-tree)"
commit2="$(GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.invalid GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.invalid \
	git -C "$SITE_REPO" commit-tree "$tree2" -p "$commit1" -m "release rust 0.1.2")"
git -C "$SITE_REPO" update-ref HEAD "$commit2"
git -C "$SITE_REPO" tag rust/v0.1.2 "$commit2"
git -C "$SITE_REPO" tag skribble_site/v1.1.1 "$commit2"

assert_contains "rust/v0.1.2 owns website deploy on rust+site commit" \
	"Would dispatch Docs Pages on main for rust/v0.1.2." \
	"$("$DEPLOY_WEBSITE_SCRIPT" rust/v0.1.2 --dry-run)"
assert_contains "skribble_site/v1.1.1 yields website deploy to rust/v0.1.2" \
	"rust/v0.1.2 owns the website deploy" \
	"$("$DEPLOY_WEBSITE_SCRIPT" skribble_site/v1.1.1 --dry-run)"
popd >/dev/null

echo
printf 'Results: %d passed, %d failed\n' "$PASSED" "$FAILED"
[[ "$FAILED" -eq 0 ]]
