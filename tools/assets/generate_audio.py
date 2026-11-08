#!/usr/bin/env python3
"""Generates sound effects and music with the ElevenLabs API, from versioned prompts.

Usage (raw MP3s go OUTSIDE the repository; tools/assets/process_audio.sh then makes the
game's OGG files):
    ELEVENLABS_API_KEY=... python3 -I tools/assets/generate_audio.py sfx OUT_DIR [NAME...]
    ELEVENLABS_API_KEY=... python3 -I tools/assets/generate_audio.py music OUT_DIR [NAME...]
    ELEVENLABS_API_KEY=... python3 -I tools/assets/generate_audio.py credits

Prompts live in tools/assets/audio_prompts.json (versioned: a sound can be made again or
varied). The key comes from the environment only (a secret of the cloud environment), never
from the repository. Each generation prints its cost (the `character-cost` header; music has
none: compare `credits` before and after, the counter lags a few minutes). The Starter plan
allows two requests at a time. Method: docs/recettes/sons-et-musique.md.
"""

import json
import os
import sys
import urllib.request
from pathlib import Path

API = "https://api.elevenlabs.io/v1"
PROMPTS = Path(__file__).with_name("audio_prompts.json")


def _request(path, body=None):
    headers = {"xi-api-key": os.environ["ELEVENLABS_API_KEY"]}
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode()
    request = urllib.request.Request(API + path, data=data, headers=headers)
    with urllib.request.urlopen(request, timeout=600) as response:
        return response.read(), response.headers.get("character-cost")


def credits():
    data, _ = _request("/user/subscription")
    info = json.loads(data)
    print(f"{info['character_count']} / {info['character_limit']} credits used ({info['tier']})")


def generate(kind, out_dir, names):
    prompts = json.loads(PROMPTS.read_text(encoding="utf-8"))
    table = prompts[kind]
    unknown = [name for name in names if name not in table]
    if unknown:
        sys.exit(f"unknown {kind} names: {', '.join(unknown)}")
    os.makedirs(out_dir, exist_ok=True)
    for name, entry in table.items():
        if names and name not in names:
            continue
        if kind == "sfx":
            body = {
                "text": entry["prompt"],
                "duration_seconds": entry["seconds"],
                # Higher: follows the prompt more closely (retakes of a sound that drifted).
                "prompt_influence": entry.get("influence", 0.5),
            }
            if entry.get("loop"):
                body["loop"] = True
            data, cost = _request("/sound-generation?output_format=mp3_44100_192", body)
        else:
            body = {
                "prompt": entry["prompt"],
                "music_length_ms": int(entry.get("seconds", 120) * 1000),
                "model_id": "music_v1",
                "force_instrumental": True,
            }
            data, cost = _request("/music?output_format=mp3_44100_192", body)
        Path(out_dir, name + ".mp3").write_bytes(data)
        print(name, "cost:", cost if cost else "unknown")


if __name__ == "__main__":
    if sys.argv[1:2] == ["credits"]:
        credits()
    elif len(sys.argv) >= 3 and sys.argv[1] in ("sfx", "music"):
        generate(sys.argv[1], sys.argv[2], sys.argv[3:])
    else:
        sys.exit(__doc__)
