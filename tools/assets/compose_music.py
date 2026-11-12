#!/usr/bin/env python3
"""Composes the game's background music by code (no sample, no outside source) and writes it
as a seamless loop: python3 -I tools/assets/compose_music.py assets/sounds/music_calm.ogg

A calm, bright loop for a puzzle game: soft electric-piano chords, a warm pad, a round bass and
a pentatonic pluck melody with a stereo echo. Every note is a sum of sines with an envelope,
so the result is ours (see assets/LICENSES.md). Needs numpy and ffmpeg (libvorbis).
"""

import subprocess
import sys
import tempfile
import wave

import numpy as np

RATE = 44100
BPM = 92.0
BEAT = 60.0 / BPM
BAR = 4 * BEAT
# Fmaj7, G6, Em7, Am7, then Dm9, G, Cmaj7, Am7 (C major: in tune with the game's sounds).
CHORDS = [
    [53, 57, 60, 64],
    [55, 59, 62, 64],
    [52, 55, 59, 62],
    [57, 60, 64, 67],
    [50, 57, 60, 64],
    [55, 59, 62, 65],
    [48, 55, 59, 64],
    [57, 60, 64, 67],
]
BASS = [41, 43, 40, 45, 38, 43, 36, 45]
# Melody: (bar, beat, midi note, beats), C major pentatonic; a phrase that answers itself.
MELODY = [
    (0, 0.0, 72, 1.0), (0, 1.5, 76, 0.5), (0, 2.0, 79, 1.5),
    (1, 0.0, 81, 1.0), (1, 1.0, 79, 0.5), (1, 1.5, 76, 1.5),
    (2, 0.0, 74, 1.0), (2, 1.5, 76, 0.5), (2, 2.0, 79, 2.0),
    (3, 1.0, 76, 0.5), (3, 1.5, 74, 0.5), (3, 2.0, 72, 2.0),
    (4, 0.0, 74, 1.0), (4, 1.5, 77, 0.5), (4, 2.0, 81, 1.5),
    (5, 0.0, 79, 1.0), (5, 1.0, 81, 0.5), (5, 1.5, 83, 1.5),
    (6, 0.0, 84, 1.5), (6, 2.0, 79, 1.0), (6, 3.0, 76, 1.0),
    (7, 0.0, 74, 1.0), (7, 1.0, 76, 1.0), (7, 2.0, 72, 2.0),
]
ROUNDS = 2  # the eight bars twice: the second time with the melody an octave lower, softer


def hz(midi: float) -> float:
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


def envelope(n: int, attack: float, decay: float, release: float, hold: int) -> np.ndarray:
    t = np.arange(n) / RATE
    env = np.minimum(t / attack, 1.0) * np.exp(-decay * t)
    if hold < n:
        tail = np.exp(-(t[hold:] - t[hold]) / release)
        env[hold:] *= tail
    return env


def e_piano(freq: float, seconds: float, length: float) -> np.ndarray:
    n = int(length * RATE)
    t = np.arange(n) / RATE
    mod = np.sin(2 * np.pi * freq * 14.0 * t) * np.exp(-6 * t) * 0.6
    tone = np.sin(2 * np.pi * freq * t + mod) + 0.25 * np.sin(2 * np.pi * freq * 2 * t)
    return tone * envelope(n, 0.004, 1.2, 0.25, int(seconds * RATE)) * 0.18


def pad(freq: float, seconds: float, length: float) -> np.ndarray:
    n = int(length * RATE)
    t = np.arange(n) / RATE
    tone = sum(np.sin(2 * np.pi * freq * d * t + p) for d, p in ((1.0, 0), (1.003, 1.0), (0.997, 2.0)))
    tone += 0.3 * np.sin(2 * np.pi * freq * 2.002 * t)
    env = np.minimum(t / 0.8, 1.0)
    hold = int(seconds * RATE)
    env[hold:] *= np.exp(-(t[hold:] - t[hold]) / 0.6)
    return tone * env * 0.035


def bass(freq: float, seconds: float, length: float) -> np.ndarray:
    n = int(length * RATE)
    t = np.arange(n) / RATE
    tone = np.sin(2 * np.pi * freq * t) + 0.2 * np.sin(2 * np.pi * freq * 2 * t)
    return tone * envelope(n, 0.01, 0.8, 0.15, int(seconds * RATE)) * 0.22


def pluck(freq: float, seconds: float, length: float) -> np.ndarray:
    n = int(length * RATE)
    t = np.arange(n) / RATE
    tone = (
        np.sin(2 * np.pi * freq * t)
        + 0.35 * np.sin(2 * np.pi * freq * 2 * t) * np.exp(-8 * t)
        + 0.12 * np.sin(2 * np.pi * freq * 3 * t) * np.exp(-12 * t)
    )
    return tone * envelope(n, 0.003, 3.0, 0.12, int(seconds * RATE)) * 0.16


def shaker(length: float, rng: np.random.Generator) -> np.ndarray:
    n = int(length * RATE)
    t = np.arange(n) / RATE
    noise = rng.standard_normal(n)
    noise = np.diff(noise, prepend=0.0)  # brighter: a crude high-pass
    return noise * np.exp(-60 * t) * 0.012


def add(buffer: np.ndarray, sound: np.ndarray, at: float, pan: float) -> None:
    start = int(at * RATE) % buffer.shape[0]
    left, right = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
    # Wrap around the end of the loop, so that tails ring into its start (seamless).
    end = start + sound.shape[0]
    indices = np.arange(start, end) % buffer.shape[0]
    np.add.at(buffer[:, 0], indices, sound * left)
    np.add.at(buffer[:, 1], indices, sound * right)


def compose() -> np.ndarray:
    rng = np.random.default_rng(7)
    loop_seconds = ROUNDS * len(CHORDS) * BAR
    music = np.zeros((int(loop_seconds * RATE), 2))
    for round_index in range(ROUNDS):
        for bar, chord in enumerate(CHORDS):
            at = (round_index * len(CHORDS) + bar) * BAR
            for note in chord:
                add(music, pad(hz(note), BAR, BAR + 1.5), at, 0.0)
            # Electric piano: the chord on beat 1 and a lighter echo of it on beat 3 and a half.
            for index, note in enumerate(chord):
                add(music, e_piano(hz(note + 12), BEAT * 1.5, 2.5), at + index * 0.012, -0.3)
                add(music, 0.6 * e_piano(hz(note + 12), BEAT, 2.0), at + 2.5 * BEAT, 0.3)
            add(music, bass(hz(BASS[bar]), BEAT * 1.8, 2.5), at, 0.0)
            add(music, bass(hz(BASS[bar] + 7), BEAT * 0.8, 1.5), at + 2.5 * BEAT, 0.0)
            for eighth in range(8):
                accent = 1.0 if eighth % 2 else 0.5
                add(music, accent * shaker(0.2, rng), at + eighth * BEAT / 2, 0.4)
        for bar, beat, note, beats in MELODY:
            at = (round_index * len(CHORDS) + bar) * BAR + beat * BEAT
            shift, gain = (0, 1.0) if round_index == 0 else (-12, 0.8)
            sound = gain * pluck(hz(note + shift), beats * BEAT, beats * BEAT + 1.5)
            add(music, sound, at, -0.15)
            # Stereo echo, a dotted eighth later, on the other side.
            add(music, 0.35 * sound, at + 0.75 * BEAT, 0.6)
            add(music, 0.15 * sound, at + 1.5 * BEAT, -0.6)
    peak = np.max(np.abs(music))
    return music / peak * 0.7


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("usage: compose_music.py <out.ogg>")
    music = compose()
    pcm = (music * 32767).astype("<i2")
    with tempfile.NamedTemporaryFile(suffix=".wav") as wav_file:
        with wave.open(wav_file.name, "wb") as out:
            out.setnchannels(2)
            out.setsampwidth(2)
            out.setframerate(RATE)
            out.writeframes(pcm.tobytes())
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", wav_file.name,
             "-c:a", "libvorbis", "-q:a", "3", sys.argv[1]],
            check=True,
        )
    print(f"{sys.argv[1]}: {music.shape[0] / RATE:.1f} s loop")


if __name__ == "__main__":
    main()
