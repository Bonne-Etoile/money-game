class_name SoundSynth
extends RefCounted
## Short sounds made by code (the prototype has no sound files yet, G13): notes played one
## after the other, each a sine with a quick attack and a decay, in a 16-bit mono AudioStreamWAV.

const MIX_RATE: int = 22050
## Seconds of the attack of each note (avoids a click).
const ATTACK_SECONDS: float = 0.005


## `frequencies` in hertz, one note after the other, each lasting `note_seconds` and fading
## out (`decay`: how fast, higher is shorter); `volume` from 0 to 1.
static func notes(
	frequencies: Array[float], note_seconds: float, decay: float, volume: float
) -> AudioStreamWAV:
	var samples_per_note: int = maxi(int(note_seconds * MIX_RATE), 1)
	var data: PackedByteArray = PackedByteArray()
	data.resize(frequencies.size() * samples_per_note * 2)
	var offset: int = 0
	for frequency in frequencies:
		for index in samples_per_note:
			var time: float = float(index) / MIX_RATE
			var envelope: float = minf(time / ATTACK_SECONDS, 1.0) * exp(-decay * time)
			# A touch of the octave makes it ring like a small bell rather than a beep.
			var wave: float = sin(TAU * frequency * time) + 0.3 * sin(TAU * 2.0 * frequency * time)
			var value: int = clampi(int(wave / 1.3 * envelope * volume * 32767.0), -32768, 32767)
			data.encode_s16(offset, value)
			offset += 2
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
