#!/usr/bin/env bash
# Installs the tooling needed by `make lint check test build` on Linux x86_64:
# Godot (version from .godot-version) and its Linux/Windows export templates,
# Xvfb and the Mesa software Vulkan driver, and gdtoolkit (requirements-dev.txt).
# Used by the Claude Code cloud session hook and by CI. Safe to run several times:
# each step is skipped when already done.
#
# Environment:
#   BIN_DIR       where godot, gdlint and gdformat are linked (default /usr/local/bin;
#                 must exist, CI uses a directory of the runner)
#   OPT_DIR       where Godot and the gdtoolkit virtualenv live (default /opt/godot-tools)
#   SKIP_APT=1    do not install system packages
#   SKIP_EXPORT_TEMPLATES=1   do not install export templates (1.3 GB download)
#   XDG_DATA_HOME where Godot (and this script) put the export templates (default ~/.local/share)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"
OPT_DIR="${OPT_DIR:-/opt/godot-tools}"

GODOT_VERSION="$(tr -d '[:space:]' < "$REPO_DIR/.godot-version")" # e.g. 4.7.2-stable
GODOT_VERSION_DOTTED="${GODOT_VERSION//-/.}"                      # e.g. 4.7.2.stable
RELEASE_URL="https://github.com/godotengine/godot/releases/download/$GODOT_VERSION"
# Where Godot looks for them: $XDG_DATA_HOME when set (absolute path), else ~/.local/share.
TEMPLATES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$GODOT_VERSION_DOTTED"
TEMPLATE_FILES=(
	linux_release.x86_64
	linux_debug.x86_64
	windows_release_x86_64.exe
	windows_release_x86_64_console.exe
	windows_debug_x86_64.exe
	windows_debug_x86_64_console.exe
)

if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

log() { echo "setup-cloud: $*"; }

link_tool() { # target name
	if [ -w "$BIN_DIR" ]; then
		ln -sf "$1" "$BIN_DIR/$2"
	else
		$SUDO ln -sf "$1" "$BIN_DIR/$2"
	fi
}

# OPT_DIR belongs to the current user, so that CI can cache it without sudo.
prepare_opt_dir() {
	if ! mkdir -p "$OPT_DIR" 2> /dev/null; then
		$SUDO mkdir -p "$OPT_DIR"
		$SUDO chown "$(id -u):$(id -g)" "$OPT_DIR"
	fi
}

download() { # url destination
	curl --fail --silent --show-error --location --retry 4 --retry-delay 2 -o "$2" "$1"
}

install_apt_packages() {
	if [ "${SKIP_APT:-}" = "1" ]; then
		log "system packages skipped (SKIP_APT=1)"
		return
	fi
	local packages=(make curl xvfb xauth mesa-vulkan-drivers libgl1 unzip python3-venv)
	local missing=()
	for package in "${packages[@]}"; do
		dpkg -s "$package" > /dev/null 2>&1 || missing+=("$package")
	done
	if [ "${#missing[@]}" -eq 0 ]; then
		log "system packages already installed"
		return
	fi
	log "installing system packages: ${missing[*]}"
	$SUDO apt-get update -q > /dev/null
	$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -q "${missing[@]}" > /dev/null
}

install_godot() {
	local godot_dir="$OPT_DIR/godot-$GODOT_VERSION"
	local binary="$godot_dir/Godot_v${GODOT_VERSION}_linux.x86_64"
	if [ ! -x "$binary" ]; then
		log "downloading Godot $GODOT_VERSION"
		local tmp
		tmp="$(mktemp -d)"
		download "$RELEASE_URL/Godot_v${GODOT_VERSION}_linux.x86_64.zip" "$tmp/godot.zip"
		mkdir -p "$godot_dir"
		unzip -q -o "$tmp/godot.zip" -d "$godot_dir"
		rm -rf "$tmp"
	else
		log "Godot $GODOT_VERSION already installed"
	fi
	link_tool "$binary" godot
	local version
	version="$("$BIN_DIR/godot" --version)"
	if [[ "$version" != "$GODOT_VERSION_DOTTED"* ]]; then
		log "unexpected godot version: $version"
		exit 1
	fi
}

install_export_templates() {
	if [ "${SKIP_EXPORT_TEMPLATES:-}" = "1" ]; then
		log "export templates skipped (SKIP_EXPORT_TEMPLATES=1)"
		return
	fi
	local all_present=1
	for file in "${TEMPLATE_FILES[@]}"; do
		[ -f "$TEMPLATES_DIR/$file" ] || all_present=0
	done
	if [ "$all_present" -eq 1 ]; then
		log "export templates already installed"
		return
	fi
	log "downloading export templates (1.3 GB, only Linux and Windows x86_64 are kept)"
	local tmp
	tmp="$(mktemp -d)"
	download "$RELEASE_URL/Godot_v${GODOT_VERSION}_export_templates.tpz" "$tmp/templates.tpz"
	mkdir -p "$TEMPLATES_DIR"
	local entries=(templates/version.txt)
	for file in "${TEMPLATE_FILES[@]}"; do
		entries+=("templates/$file")
	done
	unzip -q -o -j "$tmp/templates.tpz" "${entries[@]}" -d "$TEMPLATES_DIR"
	rm -rf "$tmp"
}

install_gdtoolkit() {
	local venv="$OPT_DIR/gdtoolkit-venv"
	local wanted
	wanted="$(grep -E '^gdtoolkit==' "$REPO_DIR/requirements-dev.txt" | cut -d= -f3)"
	local installed=""
	if [ -x "$venv/bin/pip" ]; then
		# Captured first: with pipefail, `pip show | grep -q` fails when grep exits early.
		installed="$("$venv/bin/pip" show gdtoolkit 2> /dev/null || true)"
	fi
	if [ -x "$venv/bin/gdlint" ] && grep -q "^Version: $wanted$" <<< "$installed"; then
		log "gdtoolkit $wanted already installed"
	else
		log "installing gdtoolkit $wanted"
		python3 -m venv "$venv"
		"$venv/bin/pip" install --quiet --disable-pip-version-check -r "$REPO_DIR/requirements-dev.txt"
	fi
	link_tool "$venv/bin/gdlint" gdlint
	link_tool "$venv/bin/gdformat" gdformat
}

install_apt_packages
prepare_opt_dir
install_godot
install_export_templates
install_gdtoolkit
log "done (Godot $GODOT_VERSION, $("$BIN_DIR/gdlint" --version))"
