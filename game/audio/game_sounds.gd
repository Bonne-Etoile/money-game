class_name GameSounds
extends Node
## The sounds of a game (G13), made by SoundSynth until real ones are chosen: a soft tap when a
## piece is placed, a chime when something clears (higher at each move of the combo), a bright
## arpeggio for an empty grid and a fanfare for a new record.

## Notes in hertz (C major: never out of tune with each other).
const PLACE_NOTES: Array[float] = [220.0]
const CLEAR_NOTES: Array[float] = [523.25, 783.99]
const EMPTY_GRID_NOTES: Array[float] = [523.25, 659.25, 783.99, 1046.5]
const RECORD_NOTES: Array[float] = [392.0, 523.25, 659.25, 783.99, 1046.5]

var _place: AudioStreamPlayer
var _clear: AudioStreamPlayer
var _empty_grid: AudioStreamPlayer
var _record: AudioStreamPlayer


func _ready() -> void:
	_place = _player(SoundSynth.notes(PLACE_NOTES, 0.08, 40.0, 0.35))
	_clear = _player(SoundSynth.notes(CLEAR_NOTES, 0.12, 14.0, 0.5))
	_empty_grid = _player(SoundSynth.notes(EMPTY_GRID_NOTES, 0.1, 10.0, 0.55))
	_record = _player(SoundSynth.notes(RECORD_NOTES, 0.11, 8.0, 0.6))


func play_place() -> void:
	_place.play()


## The clear chime, `pitch` times higher (it rises with the combo).
func play_clear(pitch: float) -> void:
	_clear.pitch_scale = maxf(pitch, 0.1)
	_clear.play()


func play_empty_grid() -> void:
	_empty_grid.play()


func play_record() -> void:
	_record.play()


func _player(stream: AudioStream) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	return player
