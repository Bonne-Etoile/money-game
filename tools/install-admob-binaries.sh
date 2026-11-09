#!/usr/bin/env bash
# Installs the native binaries of the AdMob plugin (addons/admob, docs/architecture.md,
# decision 18) from its GitHub release, for the installed Godot version. Called by
# tools/setup-cloud.sh and tools/setup-android.sh; safe to run several times.
#
# Why: when they are missing, the plugin downloads them itself, without asking, each time Godot
# starts headless with the plugin enabled (addons/admob/internal/services/network/
# binary_installer.gd). Installing them here makes the download explicit. The iOS ones are
# unused (Android only) but installed too, so that the plugin never downloads them silently
# (Stelio agreed to both downloads on 2026-11-08). They are not versioned (13 MB for iOS).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="$(tr -d '[:space:]' < "$REPO_DIR/.godot-version")" # e.g. 4.7.2-stable
GODOT_TAG="v${GODOT_VERSION%-*}"                                   # e.g. v4.7.2
ADMOB_VERSION="v$(sed -n 's/^version="\(.*\)"$/\1/p' "$REPO_DIR/addons/admob/plugin.cfg")"
RELEASE_URL="https://github.com/poingstudios/godot-admob-plugin/releases/download/$ADMOB_VERSION"

log() { echo "install-admob-binaries: $*"; }

for platform in android ios; do
	bin="$REPO_DIR/addons/admob/$platform/bin"
	if [ -f "$bin/package.gd" ] && grep -q "\"$ADMOB_VERSION\"" "$bin/package.gd"; then
		log "$platform binaries $ADMOB_VERSION already installed"
		continue
	fi
	log "downloading the $platform binaries ($ADMOB_VERSION for Godot $GODOT_TAG)"
	tmp="$(mktemp -d)"
	curl --fail --silent --show-error --location --retry 4 --retry-delay 2 \
		-o "$tmp/binaries.zip" "$RELEASE_URL/$platform-template-$GODOT_TAG.zip"
	rm -rf "${bin:?}"
	mkdir -p "$bin"
	unzip -q -o "$tmp/binaries.zip" -d "$bin"
	rm -rf "${tmp:?}"
	# The marker the plugin looks for (what its own installer writes).
	printf '# This file is dynamically generated.\n# It defines the current installed version of the platform plugin.\n# Do not modify this manually.\n\nconst VERSION := "%s"\n' \
		"$ADMOB_VERSION" > "$bin/package.gd"
done
