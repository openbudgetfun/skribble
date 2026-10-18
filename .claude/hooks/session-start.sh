#!/bin/bash
# SessionStart hook for Claude Code cloud sessions.
#
# Installs the Flutter SDK pinned in .fvmrc at .fvm/flutter_sdk (the path
# melos and CI use) and resolves the pub workspace, so `dart analyze`,
# `dart format` and `flutter test` work without devenv/Nix.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
	exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"

version="$(python3 -c 'import json; print(json.load(open(".fvmrc"))["flutter"])')"
sdk_dir="$PWD/.fvm/flutter_sdk"

version_file="$sdk_dir/bin/cache/flutter.version.json"
installed=""
if [ -f "$version_file" ]; then
	installed="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["frameworkVersion"])' "$version_file")"
fi

if [ "$installed" != "$version" ]; then
	echo "Installing Flutter $version into $sdk_dir" >&2
	archive="flutter_linux_${version}-stable.tar.xz"
	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' EXIT
	curl -sSfL --retry 4 --retry-delay 2 \
		"https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${archive}" \
		-o "$tmp/$archive"
	rm -rf "$sdk_dir"
	mkdir -p "$(dirname "$sdk_dir")"
	tar -xJf "$tmp/$archive" -C "$tmp"
	mv "$tmp/flutter" "$sdk_dir"
fi

# The SDK is a git checkout; root in the container does not own it.
git config --global --get-all safe.directory | grep -qxF "$sdk_dir" ||
	git config --global --add safe.directory "$sdk_dir"

export PATH="$sdk_dir/bin:$HOME/.pub-cache/bin:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
	echo "export PATH=\"$sdk_dir/bin:\$HOME/.pub-cache/bin:\$PATH\"" >>"$CLAUDE_ENV_FILE"
fi

flutter config --no-analytics >/dev/null 2>&1 || true
dart --disable-analytics >/dev/null 2>&1 || true

# One resolution covers the whole pub workspace. `dart pub get` gives the same
# result as devenv's `install:all` (`dart pub get && flutter pub get`) here but
# skips flutter's per-package plugin regeneration, which takes minutes.
dart pub get
# Download the engine artifacts `flutter test` needs.
flutter precache --universal >/dev/null
