class_name GameSounds
extends Node
## The sounds of a game (G13), made by SoundSynth until real ones are chosen: a wooden knock
## when a piece is picked up or turned, a tile clack when it is set down, a soft bump when it
## goes back, a bright arpeggio when something clears (higher at each move of the combo, with
## sparkles for a strong move), a long shimmering one for an empty grid, a fanfare for a new
## record, a gentle falling phrase at the end of a game, and whooshes for the bonuses. All in C
## major, in tune with the music. Made once per run (they take a moment to compute).

const BUS: StringName = &"Effects"
## How many times the same sound can overlap (two quick clears, two quick drops).
const POLYPHONY: int = 3
## Each play of the clack is a little higher or lower: never twice exactly the same knock.
const PLACE_PITCH_SPREAD: float = 0.06

## Names of the sounds.
const PICK: StringName = &"pick"
const PLACE: StringName = &"place"
const RETURN: StringName = &"return"
const ROTATE: StringName = &"rotate"
const CLEAR: StringName = &"clear"
const SPARKLE: StringName = &"sparkle"
const EMPTY_GRID: StringName = &"empty_grid"
const RECORD: StringName = &"record"
const GAME_OVER: StringName = &"game_over"
const NEW_HAND: StringName = &"new_hand"
const MIRROR: StringName = &"mirror"
const BUTTON: StringName = &"button"

## Steps of the shimmer over the record fanfare, in semitones.
const RECORD_SHIMMER: Array[int] = [0, 4, 7, 12, 7, 4, 12]

## The sounds, made by the first GameSounds of the run.
static var _streams: Dictionary[StringName, AudioStreamWAV] = {}

## The name of the last sound played (tests).
var last_played: StringName = &""
var _players: Dictionary[StringName, AudioStreamPlayer] = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 5
	if _streams.is_empty():
		_streams = make_all()
	for sound: StringName in _streams:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.stream = _streams[sound]
		player.max_polyphony = POLYPHONY
		player.bus = BUS if AudioServer.get_bus_index(BUS) >= 0 else &"Master"
		add_child(player)
		_players[sound] = player


func play_pick() -> void:
	play(PICK)


func play_place() -> void:
	play(PLACE, 1.0 + _rng.randf_range(-PLACE_PITCH_SPREAD, PLACE_PITCH_SPREAD))


func play_return() -> void:
	play(RETURN)


func play_rotate() -> void:
	play(ROTATE)


## The clear arpeggio, `pitch` times higher (it climbs with the combo); with sparkles on top
## for a strong move.
func play_clear(pitch: float, strong: bool) -> void:
	play(CLEAR, pitch)
	if strong:
		play(SPARKLE)


func play_empty_grid() -> void:
	play(EMPTY_GRID)


func play_record() -> void:
	play(RECORD)


func play_game_over() -> void:
	play(GAME_OVER)


func play_new_hand() -> void:
	play(NEW_HAND)


func play_mirror() -> void:
	play(MIRROR)


func play_button() -> void:
	play(BUTTON)


func play(sound: StringName, pitch: float = 1.0) -> void:
	var player: AudioStreamPlayer = _players.get(sound)
	if player == null:
		return
	player.pitch_scale = maxf(pitch, 0.1)
	player.play()
	last_played = sound


## Every sound of the game, by name.
static func make_all() -> Dictionary[StringName, AudioStreamWAV]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 11
	var sounds: Dictionary[StringName, AudioStreamWAV] = {}
	var samples: PackedFloat32Array

	samples = SoundSynth.buffer(0.15)
	SoundSynth.add_note(samples, 0.0, SoundSynth.midi(81), 45.0, 0.6, SoundSynth.WOOD)
	SoundSynth.add_noise(samples, 0.0, 250.0, 0.15, 0.6, rng)
	sounds[PICK] = SoundSynth.to_stream(samples, 0.35)

	samples = SoundSynth.buffer(0.25)
	SoundSynth.add_note(samples, 0.0, 150.0, 30.0, 0.7, SoundSynth.WOOD)
	SoundSynth.add_note(samples, 0.0, 1250.0, 55.0, 0.45, SoundSynth.CLACK)
	SoundSynth.add_noise(samples, 0.0, 180.0, 0.4, 0.7, rng)
	sounds[PLACE] = SoundSynth.to_stream(samples, 0.6)

	samples = SoundSynth.buffer(0.3)
	SoundSynth.add_glide(samples, 0.0, 330.0, 196.0, 0.22, 0.6)
	SoundSynth.add_note(samples, 0.0, SoundSynth.midi(55), 25.0, 0.4, SoundSynth.WOOD)
	sounds[RETURN] = SoundSynth.to_stream(samples, 0.3)

	samples = SoundSynth.buffer(0.15)
	SoundSynth.add_notes(
		samples, 0.0, [SoundSynth.midi(84), SoundSynth.midi(88)], 0.035, 50.0, 0.5, SoundSynth.WOOD
	)
	sounds[ROTATE] = SoundSynth.to_stream(samples, 0.25)

	samples = SoundSynth.buffer(1.0)
	SoundSynth.add_whoosh(samples, 0.0, 0.3, 0.25, true, rng)
	SoundSynth.add_notes(samples, 0.0, _midis([72, 76, 79, 84]), 0.045, 7.0, 0.5)
	SoundSynth.add_note(samples, 0.14, SoundSynth.midi(88), 9.0, 0.25)
	SoundSynth.add_echo(samples, 0.12, 0.3, 2)
	sounds[CLEAR] = SoundSynth.to_stream(samples, 0.55)

	samples = SoundSynth.buffer(1.0)
	var sparkle_notes: Array[int] = [91, 96, 93, 100, 98, 103, 96, 105, 100]
	for index in sparkle_notes.size():
		var note: int = sparkle_notes[index]
		SoundSynth.add_note(samples, 0.08 + index * 0.045, SoundSynth.midi(note), 14.0, 0.3)
	SoundSynth.add_echo(samples, 0.09, 0.35, 3)
	sounds[SPARKLE] = SoundSynth.to_stream(samples, 0.3)

	samples = SoundSynth.buffer(2.0)
	SoundSynth.add_whoosh(samples, 0.0, 0.5, 0.3, true, rng)
	SoundSynth.add_notes(samples, 0.0, _midis([72, 76, 79, 84, 88, 91, 96]), 0.06, 4.5, 0.45)
	SoundSynth.add_notes(samples, 0.45, _midis([48, 60]), 0.0, 3.0, 0.35)
	SoundSynth.add_echo(samples, 0.15, 0.35, 3)
	sounds[EMPTY_GRID] = SoundSynth.to_stream(samples, 0.65)

	samples = SoundSynth.buffer(2.6)
	SoundSynth.add_notes(samples, 0.0, _midis([67, 72, 76]), 0.11, 6.0, 0.5)
	for note: int in [72, 76, 79, 84]:
		SoundSynth.add_note(samples, 0.36, SoundSynth.midi(note), 2.2, 0.35)
	SoundSynth.add_note(samples, 0.36, SoundSynth.midi(48), 2.0, 0.4)
	for index in RECORD_SHIMMER.size():
		SoundSynth.add_note(
			samples, 0.5 + index * 0.07, SoundSynth.midi(96 + RECORD_SHIMMER[index]), 12.0, 0.15
		)
	SoundSynth.add_echo(samples, 0.16, 0.3, 3)
	sounds[RECORD] = SoundSynth.to_stream(samples, 0.65)

	samples = SoundSynth.buffer(1.8)
	SoundSynth.add_notes(samples, 0.0, _midis([76, 72, 69, 65]), 0.2, 4.0, 0.45)
	SoundSynth.add_note(samples, 0.6, SoundSynth.midi(53), 2.5, 0.3)
	SoundSynth.add_echo(samples, 0.2, 0.3, 2)
	sounds[GAME_OVER] = SoundSynth.to_stream(samples, 0.45)

	samples = SoundSynth.buffer(0.6)
	SoundSynth.add_whoosh(samples, 0.0, 0.35, 0.5, true, rng)
	SoundSynth.add_glide(samples, 0.0, 300.0, 900.0, 0.3, 0.3)
	SoundSynth.add_notes(samples, 0.28, _midis([79, 84]), 0.05, 20.0, 0.4, SoundSynth.WOOD)
	sounds[NEW_HAND] = SoundSynth.to_stream(samples, 0.45)

	samples = SoundSynth.buffer(0.5)
	SoundSynth.add_glide(samples, 0.0, 600.0, 1200.0, 0.18, 0.3)
	SoundSynth.add_notes(samples, 0.12, _midis([83, 88]), 0.05, 14.0, 0.4)
	SoundSynth.add_echo(samples, 0.08, 0.3, 2)
	sounds[MIRROR] = SoundSynth.to_stream(samples, 0.4)

	samples = SoundSynth.buffer(0.12)
	SoundSynth.add_note(samples, 0.0, SoundSynth.midi(76), 50.0, 0.6, SoundSynth.WOOD)
	sounds[BUTTON] = SoundSynth.to_stream(samples, 0.3)
	return sounds


static func _midis(notes: Array[int]) -> Array[float]:
	var frequencies: Array[float] = []
	for note in notes:
		frequencies.append(SoundSynth.midi(note))
	return frequencies
