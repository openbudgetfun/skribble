#!/usr/bin/env bash
# Cursor cloud agent bootstrap for skribble.
#
# Idempotent. Installs single-user Nix (this VM has no systemd, so a
# daemon-based multi-user install cannot stay up) with flakes and
# nix-command, then devenv and the public devenv.cachix.org binary cache.
# `nix` and `devenv` are wrapped onto /usr/local/bin so login and
# non-login shells both find them. The shell is then evaluated once so
# later agents reuse the Nix store.
#
# macOS and iOS builds cannot run on this Linux VM.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

log() {
	printf '==> %s\n' "$*"
}

apt_install_if_missing() {
	local missing=()
	local pkg
	for pkg in "$@"; do
		if ! dpkg -s "$pkg" >/dev/null 2>&1; then
			missing+=("$pkg")
		fi
	done
	if [[ ${#missing[@]} -eq 0 ]]; then
		log "system packages already installed"
		return 0
	fi
	log "installing system packages: ${missing[*]}"
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
}

# Host libraries Flutter's Linux desktop toolchain links against. devenv does
# not install these; they belong to the base image.
apt_install_if_missing \
	ca-certificates \
	clang \
	cmake \
	curl \
	git \
	libglu1-mesa \
	libgtk-3-dev \
	liblzma-dev \
	ninja-build \
	pkg-config \
	python3 \
	unzip \
	xz-utils \
	zip

load_nix_profile() {
	# shellcheck disable=SC1091
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
}

ensure_nix_conf() {
	mkdir -p "$HOME/.config/nix"
	local conf="$HOME/.config/nix/nix.conf"
	touch "$conf"
	if ! grep -q '^experimental-features = .*nix-command' "$conf" ||
		! grep -q '^experimental-features = .*flakes' "$conf"; then
		local tmp
		tmp="$(mktemp)"
		grep -v '^experimental-features' "$conf" >"$tmp" || true
		printf 'experimental-features = nix-command flakes\n' >>"$tmp"
		mv "$tmp" "$conf"
	fi
}

install_nix() {
	if [[ -x "$HOME/.nix-profile/bin/nix" ]]; then
		log "Nix already installed"
		return 0
	fi
	log "installing single-user Nix"
	local tmp
	tmp="$(mktemp)"
	curl -fsSL --retry 4 --retry-delay 2 https://nixos.org/nix/install -o "$tmp"
	# --yes is forwarded to the unpacked installer. The outer script only
	# special-cases --tarball-url-prefix.
	sh "$tmp" --no-daemon --yes
	rm -f "$tmp"
}

install_profile_wrapper() {
	local name="$1"
	local wrapper="/usr/local/bin/$name"
	# Keep the profile path unresolved so a later `nix profile upgrade`
	# is picked up without rewriting the wrapper.
	sudo tee "$wrapper" >/dev/null <<EOF
#!/bin/bash
set -euo pipefail
if [[ -f "\${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
	# shellcheck disable=SC1091
	. "\${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi
exec "\${HOME}/.nix-profile/bin/${name}" "\$@"
EOF
	sudo chmod 755 "$wrapper"
}

profile_has() {
	local name="$1"
	[[ -x "$HOME/.nix-profile/bin/$name" ]]
}

install_nix
ensure_nix_conf
load_nix_profile
install_profile_wrapper nix

if ! profile_has cachix; then
	log "installing cachix"
	nix profile add --accept-flake-config nixpkgs#cachix
fi
install_profile_wrapper cachix
hash -r

if ! grep -q 'devenv.cachix.org' "$HOME/.config/nix/nix.conf"; then
	log "configuring the devenv binary cache"
	cachix use devenv
fi

if ! profile_has devenv; then
	log "installing devenv"
	nix profile add --accept-flake-config nixpkgs#devenv
fi
install_profile_wrapper devenv
hash -r

log "warming the devenv shell"
# Same retry as CI: a fresh Nix store can record a fetcher path before it
# is valid (cachix/devenv#2729). Deleting that path and retrying resolves it.
warmed=0
for attempt in 1 2 3; do
	if out="$(devenv shell -- true 2>&1)"; then
		log "devenv shell evaluated on attempt ${attempt}"
		warmed=1
		break
	fi
	echo "devenv shell attempt ${attempt} failed:" >&2
	printf '%s\n' "$out" | tail -30 >&2
	bad="$(printf '%s\n' "$out" |
		grep "is not valid" |
		grep -oE "/nix/store/[a-z0-9]{32}-[^'[:space:]]+" |
		head -1 || true)"
	if [[ -n "$bad" ]]; then
		log "removing invalid store path: $bad"
		rm -rf "$bad" || true
	fi
	sleep 2
done
if [[ "$warmed" != 1 ]]; then
	echo "devenv shell failed to evaluate after 3 attempts" >&2
	exit 1
fi

log "installing workspace toolchains inside devenv"
# fvm use rewrites the tracked .fvmrc; CI restores it, and so do we.
devenv shell -- bash -lc 'set -euo pipefail; fvm install; fvm use --force; install:all; pnpm install --frozen-lockfile; rustup show; rustup target add wasm32-unknown-unknown; cargo fetch --locked'
git restore --worktree -- .fvmrc || true

log "cloud agent install complete"
nix --version
devenv version
