#!/usr/bin/env bash
# Turns a raw sound (MP3 or WAV, from a bank or generate_audio.py) into the game's OGG:
# silences cut at both ends, short fade-out, loudness normalised, Ogg Vorbis.
# Method: docs/recettes/sons-et-musique.md.
#
# Usage: tools/assets/process_audio.sh <kind> <input> <output.ogg> [lowpass_hz]
#   kind: sfx      mono, silences trimmed, 30 ms fade-out, peak at -1.5 dBFS
#         ambience stereo, kept whole (loops), loudness -28 LUFS
#         music    stereo, kept whole, 4 s fade-out, loudness -16 LUFS
#   lowpass_hz (optional): cuts what is above (a shrill sound, "strident" in a playtest: 5000)
set -euo pipefail

if [ "$#" -lt 3 ]; then
	sed -n '2,12p' "$0" >&2
	exit 1
fi
kind="$1"
input="$2"
output="$3"
lowpass="${4:-}"

filters=()
if [ -n "$lowpass" ]; then
	filters+=("lowpass=f=$lowpass")
fi

case "$kind" in
	sfx)
		# Trim the silence at the start, then at the end (reverse, trim, reverse back).
		# Mono first (average of the channels: -ac 1 alone sums them, +3 dB), so that the peak
		# is measured on what is encoded.
		if [ "$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "$input")" = "2" ]; then
			filters+=("pan=mono|c0=0.5*c0+0.5*c1")
		fi
		filters+=(
			"silenceremove=start_periods=1:start_threshold=-50dB"
			"areverse"
			"silenceremove=start_periods=1:start_threshold=-50dB"
			"areverse"
		)
		chain="$(IFS=,; echo "${filters[*]}")"
		# Peak normalisation needs the sound's own peak: measured on a first pass.
		peak="$(ffmpeg -hide_banner -nostats -i "$input" -af "$chain,volumedetect" -f null - 2>&1 |
			sed -n 's/.*max_volume: \(-\?[0-9.]*\) dB.*/\1/p')"
		gain="$(python3 -c "print(-1.5 - float('${peak:-0}'))")"
		duration="$(ffmpeg -hide_banner -nostats -i "$input" -af "$chain" -f null - 2>&1 |
			sed -n 's/.*time=\([0-9:.]*\).*/\1/p' | tail -1 |
			awk -F: '{ print $1 * 3600 + $2 * 60 + $3 }')"
		fade_start="$(python3 -c "print(max(0.0, float('${duration:-0}') - 0.03))")"
		ffmpeg -hide_banner -loglevel error -y -i "$input" \
			-af "$chain,volume=${gain}dB,afade=t=out:st=${fade_start}:d=0.03" \
			-ac 1 -c:a libvorbis -q:a 5 "$output"
		;;
	ambience | music)
		target="-28"
		fade=""
		if [ "$kind" = "music" ]; then
			target="-16"
			duration="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$input")"
			fade=",afade=t=out:st=$(python3 -c "print(max(0.0, float('$duration') - 4.0))"):d=4"
		fi
		filters+=("loudnorm=I=${target}:TP=-1.5:LRA=11")
		chain="$(IFS=,; echo "${filters[*]}")"
		ffmpeg -hide_banner -loglevel error -y -i "$input" -af "$chain$fade" \
			-ac 2 -ar 44100 -c:a libvorbis -q:a 5 "$output"
		;;
	*)
		echo "process_audio: unknown kind $kind (sfx, ambience, music)" >&2
		exit 1
		;;
esac
echo "process_audio: $output ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "$output") s)"
