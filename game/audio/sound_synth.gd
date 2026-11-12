class_name SoundSynth
extends RefCounted
## Short sounds made by code (the game has no sound files for its effects, G13): sounds are
## mixed into a buffer of samples (bells and wooden knocks made of a few sines, bursts of
## noise, glides), given an echo, then turned into a 16-bit mono AudioStreamWAV.

const MIX_RATE: int = 22050
## Seconds of the attack of each note (avoids a click).
const ATTACK_SECONDS: float = 0.004
## A note stops once its envelope falls under this (saves work: it can no longer be heard).
const SILENT: float = 0.001
## Partials of a sound, as pairs (ratio to the fundamental, loudness). Higher partials die
## faster (by the square root of their ratio), as on a real bell or bar.
const BELL: PackedFloat32Array = [1.0, 1.0, 2.0, 0.35, 3.0, 0.12, 4.2, 0.08]
## A wooden bar: the fundamental and the bright knock of a mallet.
const WOOD: PackedFloat32Array = [1.0, 1.0, 3.93, 0.3, 9.5, 0.08]
## A tile set down on a table: inharmonic partials, like a small hard object.
const CLACK: PackedFloat32Array = [1.0, 1.0, 1.58, 0.65, 2.41, 0.45, 3.3, 0.25]


## Silence of `seconds`, to mix sounds into.
static func buffer(seconds: float) -> PackedFloat32Array:
	var samples: PackedFloat32Array = []
	samples.resize(maxi(int(seconds * MIX_RATE), 1))
	samples.fill(0.0)
	return samples


## A note of `frequency` hertz starting at `at` seconds, made of `partials`, fading out
## (`decay`: how fast, higher is shorter), `volume` from 0 to 1.
static func add_note(
	samples: PackedFloat32Array,
	at: float,
	frequency: float,
	decay: float,
	volume: float,
	partials: PackedFloat32Array = BELL
) -> void:
	var start: int = int(at * MIX_RATE)
	var length: int = mini(int(log(1.0 / SILENT) / decay * MIX_RATE), samples.size() - start)
	var total: float = 0.0
	for pair in range(1, partials.size(), 2):
		total += partials[pair]
	for pair in range(0, partials.size(), 2):
		var ratio: float = partials[pair]
		var loudness: float = partials[pair + 1] / total * volume
		var partial_decay: float = decay * sqrt(ratio)
		var step: float = TAU * frequency * ratio / MIX_RATE
		for index in length:
			var time: float = float(index) / MIX_RATE
			var envelope: float = minf(time / ATTACK_SECONDS, 1.0) * exp(-partial_decay * time)
			samples[start + index] += sin(step * index) * envelope * loudness


## Notes one after the other, `spacing` seconds apart, each ringing on.
static func add_notes(
	samples: PackedFloat32Array,
	at: float,
	frequencies: Array[float],
	spacing: float,
	decay: float,
	volume: float,
	partials: PackedFloat32Array = BELL
) -> void:
	for index in frequencies.size():
		add_note(samples, at + index * spacing, frequencies[index], decay, volume, partials)


## A burst of noise starting at `at`, fading out (`decay`); `brightness` from 0 (dull) to 1
## (hiss). `rng` makes it the same at every run.
static func add_noise(
	samples: PackedFloat32Array,
	at: float,
	decay: float,
	volume: float,
	brightness: float,
	rng: RandomNumberGenerator
) -> void:
	var start: int = int(at * MIX_RATE)
	var length: int = mini(int(log(1.0 / SILENT) / decay * MIX_RATE), samples.size() - start)
	var smooth: float = 0.0
	for index in length:
		var time: float = float(index) / MIX_RATE
		# A one-pole low-pass filter: the lower the brightness, the duller the noise.
		smooth += (rng.randf_range(-1.0, 1.0) - smooth) * clampf(brightness, 0.02, 1.0)
		var envelope: float = minf(time / ATTACK_SECONDS, 1.0) * exp(-decay * time)
		samples[start + index] += smooth * envelope * volume


## A whoosh: noise that swells then fades over `seconds`, getting brighter as it goes when
## `rising` (darker otherwise).
static func add_whoosh(
	samples: PackedFloat32Array,
	at: float,
	seconds: float,
	volume: float,
	rising: bool,
	rng: RandomNumberGenerator
) -> void:
	var start: int = int(at * MIX_RATE)
	var length: int = mini(int(seconds * MIX_RATE), samples.size() - start)
	var smooth: float = 0.0
	for index in length:
		var progress: float = float(index) / length
		var brightness: float = lerpf(0.05, 0.5, progress if rising else 1.0 - progress)
		smooth += (rng.randf_range(-1.0, 1.0) - smooth) * brightness
		samples[start + index] += smooth * sin(PI * progress) * volume


## A sine sliding from `from_hz` to `to_hz` over `seconds`, swelling and fading.
static func add_glide(
	samples: PackedFloat32Array,
	at: float,
	from_hz: float,
	to_hz: float,
	seconds: float,
	volume: float
) -> void:
	var start: int = int(at * MIX_RATE)
	var length: int = mini(int(seconds * MIX_RATE), samples.size() - start)
	var phase: float = 0.0
	for index in length:
		var progress: float = float(index) / length
		phase += TAU * lerpf(from_hz, to_hz, progress) / MIX_RATE
		var envelope: float = minf(progress * 8.0, 1.0) * (1.0 - progress)
		samples[start + index] += sin(phase) * envelope * volume


## Repeats the sound `repeats` times, `delay` seconds apart, each `feedback` times softer
## (a sense of space). The buffer must be long enough for the tail.
static func add_echo(
	samples: PackedFloat32Array, delay: float, feedback: float, repeats: int
) -> void:
	var offset: int = int(delay * MIX_RATE)
	var dry: PackedFloat32Array = samples.duplicate()
	var gain: float = 1.0
	for repeat in range(1, repeats + 1):
		gain *= feedback
		for index in range(dry.size() - offset * repeat):
			samples[index + offset * repeat] += dry[index] * gain


## The buffer as a sound, scaled so that its loudest sample reaches `peak` (0 to 1).
static func to_stream(samples: PackedFloat32Array, peak: float) -> AudioStreamWAV:
	var loudest: float = 0.0
	for sample in samples:
		loudest = maxf(loudest, absf(sample))
	var scale: float = peak / loudest if loudest > 0.0 else 0.0
	var data: PackedByteArray = PackedByteArray()
	data.resize(samples.size() * 2)
	for index in samples.size():
		var value: int = clampi(int(samples[index] * scale * 32767.0), -32768, 32767)
		data.encode_s16(index * 2, value)
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream


## Frequency of a MIDI note number (69 is A4, 440 Hz; 60 is middle C).
static func midi(note: float) -> float:
	return 440.0 * pow(2.0, (note - 69.0) / 12.0)
