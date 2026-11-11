# Quality commands, identical locally, in the cloud session and in CI (docs/architecture.md, decision 9).
# Run all four before every PR: make lint check test build

GODOT ?= godot
GDLINT ?= gdlint
GDFORMAT ?= gdformat
XVFB_RUN ?= xvfb-run -a -s "-screen 0 1920x1080x24"

# Our GDScript sources (addons are third-party and excluded).
GD_SOURCES := game test tools

# Name of the exported binaries (tools/new-game.sh renames it).
GAME_NAME := block_tiles
BUILD_DIR := build

.PHONY: lint check test build android import screenshot screenshots

lint:
	$(GDLINT) $(GD_SOURCES)
	$(GDFORMAT) --check $(GD_SOURCES)

# Imports the project (needed after a fresh clone).
import:
	$(GODOT) --headless --path . --import

# The import does not compile scripts: tools/check_project.gd loads every script, scene and
# resource and checks their dependencies (docs/pitfalls/godot-gdscript-et-scenes.md).
check: import
	$(GODOT) --headless --path . --script res://tools/check_project.gd

# gdUnit4 needs a display: it refuses to run headless (exit code 103).
# GAME_TESTS=1 lets the game leave out slow, purely visual parts (AutomatedTests).
test: import
	GAME_TESTS=1 GODOT_BIN="$$(command -v $(GODOT))" $(XVFB_RUN) bash addons/gdUnit4/runtest.sh -a res://test

# Windows and Linux exports, then the Linux one is launched a few frames (tools/smoke_test.sh).
build: import
	mkdir -p $(BUILD_DIR)/linux $(BUILD_DIR)/windows
	$(GODOT) --headless --path . --export-release "Linux" $(BUILD_DIR)/linux/$(GAME_NAME).x86_64
	$(GODOT) --headless --path . --export-release "Windows" $(BUILD_DIR)/windows/$(GAME_NAME).exe
	tools/smoke_test.sh $(BUILD_DIR)/linux/$(GAME_NAME).x86_64

# Android test APK, signed with the debug key Godot makes. Run tools/setup-android.sh first;
# the Gradle build needs dl.google.com. Godot installs the Android build template in android/
# (not versioned).
ANDROID_HOME ?= /opt/android-sdk
# Godot's Gradle build wants JDK 17, whatever JAVA_HOME (21 in the cloud) says.
ANDROID_JAVA_HOME ?= $(firstword $(wildcard /usr/lib/jvm/java-17-openjdk*) \
	$(shell dirname "$$(dirname "$$(readlink -f "$$(command -v javac)")")"))
android: import
	mkdir -p $(BUILD_DIR)/android
	ANDROID_HOME="$(ANDROID_HOME)" \
		JAVA_HOME="$(ANDROID_JAVA_HOME)" \
		$(GODOT) --headless --path . --install-android-build-template \
		--export-debug "Android" $(BUILD_DIR)/android/$(GAME_NAME).apk

# Renders a scene and saves a PNG (tools/screenshot.gd). Needs Xvfb, like the tests.
#   make screenshot SCENE=res://game/ui/main_menu.tscn OUT=build/screenshots/menu.png
#   optional: LOCALE=fr FRAMES=10 RESOLUTION=720x1280 (a phone in portrait, the default)
RESOLUTION ?= 720x1280
screenshot: import
	$(XVFB_RUN) $(GODOT) --path . --audio-driver Dummy --resolution $(RESOLUTION) \
		--script res://tools/screenshot.gd -- --scene=$(SCENE) --out=$(abspath $(OUT)) \
		$(if $(LOCALE),--locale=$(LOCALE)) $(if $(FRAMES),--frames=$(FRAMES))

# Screenshots Claude looks at before a PR (not run in CI). Add every scene worth reviewing.
SCREENSHOT_DIR := $(BUILD_DIR)/screenshots
screenshots:
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_fixture.tscn FRAMES=10 LOCALE=fr \
		OUT=$(SCREENSHOT_DIR)/tile_blocks.png
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_game_over_fixture.tscn FRAMES=10 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/tile_blocks_game_over.png
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_trouble_fixture.tscn FRAMES=10 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/tile_blocks_trouble.png
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_clear_fixture.tscn FRAMES=12 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/tile_blocks_clear.png
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_hint_fixture.tscn FRAMES=10 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/tile_blocks_hint.png
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_mirror_fixture.tscn FRAMES=10 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/tile_blocks_mirror.png
	$(MAKE) screenshot SCENE=res://test/fixtures/tile_blocks_daily_fixture.tscn FRAMES=10 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/tile_blocks_daily.png
	$(MAKE) screenshot SCENE=res://test/fixtures/level_fixture.tscn FRAMES=10 LOCALE=fr \
		OUT=$(SCREENSHOT_DIR)/level.png
	$(MAKE) screenshot SCENE=res://test/fixtures/level_won_fixture.tscn FRAMES=10 LOCALE=fr \
		OUT=$(SCREENSHOT_DIR)/level_won.png
	$(MAKE) screenshot SCENE=res://test/fixtures/level_map_fixture.tscn FRAMES=10 LOCALE=fr \
		OUT=$(SCREENSHOT_DIR)/level_map.png
	$(MAKE) screenshot SCENE=res://test/fixtures/level_blocked_fixture.tscn FRAMES=10 \
		LOCALE=fr OUT=$(SCREENSHOT_DIR)/level_blocked.png
	for locale in en fr; do \
		$(MAKE) screenshot SCENE=res://game/ui/main_menu.tscn FRAMES=10 LOCALE=$$locale \
			OUT=$(SCREENSHOT_DIR)/main_menu_$$locale.png || exit 1; \
	done

