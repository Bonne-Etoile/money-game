extends GdUnitTestSuite
## The sounds made by code (game/audio/sound_synth.gd, game/audio/game_sounds.gd).


func test_a_note_rings_then_fades_out() -> void:
	var samples: PackedFloat32Array = SoundSynth.buffer(0.5)
	SoundSynth.add_note(samples, 0.0, 440.0, 10.0, 1.0)
	assert_int(samples.size()).is_equal(int(0.5 * SoundSynth.MIX_RATE))
	assert_float(_loudest(samples, 0.0, 0.05)).is_greater(0.3)
	assert_float(_loudest(samples, 0.45, 0.5)).is_less(0.02)


func test_a_note_starts_at_its_time() -> void:
	var samples: PackedFloat32Array = SoundSynth.buffer(0.4)
	SoundSynth.add_note(samples, 0.2, 440.0, 10.0, 1.0)
	assert_float(_loudest(samples, 0.0, 0.19)).is_equal(0.0)
	assert_float(_loudest(samples, 0.2, 0.25)).is_greater(0.3)


func test_an_echo_repeats_the_sound_softer() -> void:
	var samples: PackedFloat32Array = SoundSynth.buffer(0.6)
	SoundSynth.add_note(samples, 0.0, 440.0, 60.0, 1.0)
	SoundSynth.add_echo(samples, 0.3, 0.5, 1)
	var first: float = _loudest(samples, 0.0, 0.05)
	var echo: float = _loudest(samples, 0.3, 0.35)
	assert_float(echo).is_between(first * 0.4, first * 0.6)


func test_a_stream_peaks_where_asked() -> void:
	var samples: PackedFloat32Array = SoundSynth.buffer(0.2)
	SoundSynth.add_note(samples, 0.0, 440.0, 10.0, 0.2)
	var stream: AudioStreamWAV = SoundSynth.to_stream(samples, 0.5)
	assert_int(stream.data.size()).is_equal(samples.size() * 2)
	var peak: int = 0
	for index in range(0, stream.data.size(), 2):
		peak = maxi(peak, absi(stream.data.decode_s16(index)))
	assert_int(peak).is_between(int(0.49 * 32767), int(0.5 * 32767))


func test_midi_notes_are_in_tune() -> void:
	assert_float(SoundSynth.midi(69)).is_equal_approx(440.0, 0.001)
	assert_float(SoundSynth.midi(81)).is_equal_approx(880.0, 0.001)


func test_every_game_sound_is_made_and_not_silent() -> void:
	var sounds: Dictionary[StringName, AudioStreamWAV] = GameSounds.make_all()
	for sound: StringName in [
		GameSounds.PICK,
		GameSounds.PLACE,
		GameSounds.RETURN,
		GameSounds.ROTATE,
		GameSounds.CLEAR,
		GameSounds.SPARKLE,
		GameSounds.EMPTY_GRID,
		GameSounds.RECORD,
		GameSounds.GAME_OVER,
		GameSounds.NEW_HAND,
		GameSounds.MIRROR,
		GameSounds.BUTTON,
	]:
		assert_bool(sounds.has(sound)).override_failure_message(String(sound)).is_true()
		assert_int(sounds[sound].data.size()).is_greater(1000)


func _loudest(samples: PackedFloat32Array, from: float, to: float) -> float:
	var loudest: float = 0.0
	for index in range(int(from * SoundSynth.MIX_RATE), int(to * SoundSynth.MIX_RATE)):
		loudest = maxf(loudest, absf(samples[index]))
	return loudest
