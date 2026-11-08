#!/usr/bin/env bash
# Installs what an Android export needs (docs/architecture.md, decisions 16 and 18), on top of
# tools/setup-cloud.sh: a JDK 17, the Android SDK (command-line tools, platform tools, build
# tools, platform, NDK and CMake at the versions of Godot's Gradle template) and Godot's
# Android export templates. Safe to run several times: each step is skipped when already done.
#
# Network: the SDK comes from dl.google.com, and the Gradle build of `make android` needs
# Google's Maven repository (maven.google.com, which redirects to dl.google.com). In the cloud,
# run it in a session of the "money-game" environment, which allows that host.
#
# Environment:
#   ANDROID_HOME  where the SDK goes (default /opt/android-sdk); `make android` reads it too
#   XDG_DATA_HOME where Godot looks for its export templates (default ~/.local/share)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
GODOT_VERSION="$(tr -d '[:space:]' < "$REPO_DIR/.godot-version")" # e.g. 4.7.2-stable
GODOT_VERSION_DOTTED="${GODOT_VERSION//-/.}"
RELEASE_URL="https://github.com/godotengine/godot/releases/download/$GODOT_VERSION"
TEMPLATES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$GODOT_VERSION_DOTTED"
# Versions of Godot 4.7.2's Gradle template (platform/android/java/app/config.gradle).
# Update them with Godot.
SDK_REPOSITORY="https://dl.google.com/android/repository"
SDK_PACKAGES=(
	"platform-tools"
	"build-tools;36.1.0"
	"platforms;android-36"
	"ndk;29.0.14206865"
	"cmake;3.10.2.4988404"
)
ANDROID_TEMPLATES=(android_source.zip android_debug.apk android_release.apk)

if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

log() { echo "setup-android: $*"; }

download() { # url destination
	curl --fail --silent --show-error --location --retry 4 --retry-delay 2 -o "$2" "$1"
}

check_network() {
	if ! curl --silent --head --fail --max-time 20 "$SDK_REPOSITORY/repository2-3.xml" > /dev/null; then
		log "dl.google.com is not reachable: the network of this session refuses it."
		log "In the cloud, start a session on the \"money-game\" environment (it allows dl.google.com)."
		exit 1
	fi
}

install_jdk() {
	if dpkg -s openjdk-17-jdk-headless > /dev/null 2>&1; then
		log "JDK 17 already installed"
		return
	fi
	log "installing JDK 17"
	$SUDO apt-get update -q > /dev/null
	$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -q openjdk-17-jdk-headless > /dev/null
}

install_sdk() {
	local sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
	if [ ! -x "$sdkmanager" ]; then
		local tmp archive
		tmp="$(mktemp -d)"
		# The newest Linux archive listed by Google's SDK repository.
		download "$SDK_REPOSITORY/repository2-3.xml" "$tmp/repository.xml"
		archive="$(grep -oE 'commandlinetools-linux-[0-9]+_latest\.zip' "$tmp/repository.xml" | sort -V | tail -n 1)"
		if [ -z "$archive" ]; then
			log "no command-line tools archive found in $SDK_REPOSITORY/repository2-3.xml"
			exit 1
		fi
		log "downloading the Android command-line tools ($archive)"
		download "$SDK_REPOSITORY/$archive" "$tmp/tools.zip"
		$SUDO mkdir -p "$ANDROID_HOME/cmdline-tools"
		$SUDO chown -R "$(id -u):$(id -g)" "$ANDROID_HOME"
		unzip -q -o "$tmp/tools.zip" -d "$tmp"
		rm -rf "$ANDROID_HOME/cmdline-tools/latest"
		mv "$tmp/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
		rm -rf "$tmp"
	fi
	log "installing SDK packages: ${SDK_PACKAGES[*]}"
	yes | "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses > /dev/null || true
	"$sdkmanager" --sdk_root="$ANDROID_HOME" "${SDK_PACKAGES[@]}" > /dev/null
}

install_android_templates() {
	local all_present=1
	for file in "${ANDROID_TEMPLATES[@]}"; do
		[ -f "$TEMPLATES_DIR/$file" ] || all_present=0
	done
	if [ "$all_present" -eq 1 ]; then
		log "Android export templates already installed"
		return
	fi
	log "downloading export templates (1.3 GB, only the Android ones are added)"
	local tmp
	tmp="$(mktemp -d)"
	download "$RELEASE_URL/Godot_v${GODOT_VERSION}_export_templates.tpz" "$tmp/templates.tpz"
	mkdir -p "$TEMPLATES_DIR"
	local entries=(templates/version.txt)
	for file in "${ANDROID_TEMPLATES[@]}"; do
		entries+=("templates/$file")
	done
	unzip -q -o -j "$tmp/templates.tpz" "${entries[@]}" -d "$TEMPLATES_DIR"
	rm -rf "$tmp"
}

check_network
install_jdk
install_sdk
install_android_templates
log "done (ANDROID_HOME=$ANDROID_HOME, JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")"))"
