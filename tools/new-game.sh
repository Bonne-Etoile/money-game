#!/usr/bin/env bash
# Renames the template's placeholder game everywhere it appears: the displayed name
# ("My Game": project.godot, translations, CLAUDE.md, README) and the file name ("my_game" /
# "my-game": exported binaries, CI artifacts). Run once, right after creating the repository.
# Usage: tools/new-game.sh "Displayed Name" file_name
set -euo pipefail

if [ "$#" -ne 2 ] || [[ ! "$2" =~ ^[a-z][a-z0-9_]*$ ]]; then
	echo "usage: tools/new-game.sh \"Displayed Name\" file_name (snake_case)" >&2
	exit 1
fi
display_name="$1"
file_name="$2"
dashed_name="${file_name//_/-}"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
files=(
	project.godot
	export_presets.cfg
	Makefile
	locale/translations.csv
	CLAUDE.md
	.github/workflows/build.yml
)
for file in "${files[@]}"; do
	DISPLAY_NAME="$display_name" FILE_NAME="$file_name" DASHED_NAME="$dashed_name" \
		python3 - "$file" << 'EOF'
import os
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as source:
    text = source.read()
text = (
    text.replace("My Game", os.environ["DISPLAY_NAME"])
    .replace("my_game", os.environ["FILE_NAME"])
    .replace("my-game", os.environ["DASHED_NAME"])
)
with open(path, "w", encoding="utf-8") as target:
    target.write(text)
EOF
done
echo "new-game: renamed to \"$display_name\" ($file_name). Check git diff, then: make lint check test build"
