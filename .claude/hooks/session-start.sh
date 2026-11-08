#!/bin/bash
# Claude Code cloud sessions only: installs the tooling, then imports the project
# so that `make lint check test build` work right away (docs/architecture.md, decision 16).
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
	exit 0
fi

cd "$CLAUDE_PROJECT_DIR"
tools/setup-cloud.sh
godot --headless --path . --import > /dev/null 2>&1 || echo "session-start: godot import failed, run 'make import' to see why"
