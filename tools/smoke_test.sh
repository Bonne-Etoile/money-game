#!/usr/bin/env bash
# Launches an exported Linux build for a few frames under Xvfb and fails if it
# crashes or prints an engine or script error. Called by `make build`.
# No sound card in the cloud session nor in CI: audio uses the Dummy driver.
# Usage: tools/smoke_test.sh <exported binary>
set -euo pipefail

binary="$1"
log="$(mktemp)"
trap 'rm -f "$log"' EXIT

status=0
# 20 frames are enough to catch a crash or an error at start-up; the software renderer of the
# CI machines is slow (a heavy 3D scene can take a second per frame).
timeout 300 xvfb-run -a -s "-screen 0 1920x1080x24" "$binary" --audio-driver Dummy --quit-after 20 > "$log" 2>&1 || status=$?

errors="$(grep -E '^(SCRIPT ERROR|ERROR):' "$log" || true)"
if [ "$status" -ne 0 ] || [ -n "$errors" ]; then
	echo "smoke test: $binary failed (exit code $status)"
	cat "$log"
	exit 1
fi
echo "smoke test: $binary started and quit cleanly"
