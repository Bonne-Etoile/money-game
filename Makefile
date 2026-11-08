# Quality commands, identical locally, in the cloud session and in CI (docs/architecture.md, decision 9).
# Run all four before every PR: make lint check test build

GODOT ?= godot
GDLINT ?= gdlint
GDFORMAT ?= gdformat
XVFB_RUN ?= xvfb-run -a -s "-screen 0 1920x1080x24"

# Our GDScript sources (addons are third-party and excluded).
GD_SOURCES := game test tools

# Name of the exported binaries (tools/new-game.sh renames it).
GAME_NAME := my_game
BUILD_DIR := build

.PHONY: lint check test build import screenshot screenshots model-view

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

# Renders a scene and saves a PNG (tools/screenshot.gd). Needs Xvfb, like the tests.
#   make screenshot SCENE=res://game/ui/main_menu.tscn OUT=build/screenshots/menu.png
#   optional: CAMERA=x,y,z LOOK_AT=x,y,z LOCALE=fr FRAMES=10 RESOLUTION=1280x720
RESOLUTION ?= 1280x720
screenshot: import
	$(XVFB_RUN) $(GODOT) --path . --audio-driver Dummy --resolution $(RESOLUTION) \
		--script res://tools/screenshot.gd -- --scene=$(SCENE) --out=$(abspath $(OUT)) \
		$(if $(CAMERA),--camera=$(CAMERA)) $(if $(LOOK_AT),--look-at=$(LOOK_AT)) \
		$(if $(LOCALE),--locale=$(LOCALE)) $(if $(FRAMES),--frames=$(FRAMES))

# Screenshots Claude looks at before a PR (not run in CI). Add every scene worth reviewing.
SCREENSHOT_DIR := $(BUILD_DIR)/screenshots
screenshots:
	$(MAKE) screenshot SCENE=res://test/fixtures/screenshot_fixture.tscn \
		OUT=$(SCREENSHOT_DIR)/fixture.png CAMERA=4,3,6 LOOK_AT=0,0.5,0
	for locale in en fr; do \
		$(MAKE) screenshot SCENE=res://game/ui/main_menu.tscn FRAMES=10 LOCALE=$$locale \
			OUT=$(SCREENSHOT_DIR)/main_menu_$$locale.png || exit 1; \
	done

# Models side by side under the game's light, to judge them in the game (docs/recettes/modeles-3d.md).
#   make model-view MODELS=res://assets/models/a.res,res://assets/models/b.glb OUT=build/screenshots/models.png
model-view:
	MODELS=$(MODELS) $(MAKE) screenshot SCENE=res://test/fixtures/model_view.tscn FRAMES=20 \
		OUT=$(or $(OUT),$(SCREENSHOT_DIR)/models.png)
