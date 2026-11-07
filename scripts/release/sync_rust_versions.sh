#!/usr/bin/env bash
# Pins the Rust crates' internal path dependencies to the workspace version,
# then refreshes Cargo.lock. monochange runs this after it rewrites versions.
#
# monochange matches dependencies by package name across ecosystems, and the
# Dart engine is also called skribble_rough, so the release can write the Dart
# version into the Rust workspace's `skribble_rough` dependency. Every crate in
# rust/ shares one version, so this resets each `path = "rust/…"` entry to it.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

version="$(sed -n '/^\[workspace.package\]/,/^\[/s/^version = "\(.*\)"$/\1/p' Cargo.toml | head -n 1)"
if [ -z "$version" ]; then
	echo "error: no [workspace.package] version in Cargo.toml" >&2
	exit 1
fi

sed -E "/^[a-z0-9_-]+ = \{ path = \"rust\//s/version = \"[^\"]*\"/version = \"$version\"/" Cargo.toml >Cargo.toml.next
mv Cargo.toml.next Cargo.toml

cargo update --workspace
