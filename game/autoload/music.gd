extends Node
## The background music: one calm loop (composed by code, tools/assets/compose_music.py),
## played on the Music bus from the start of the game to its end, through every screen. It
## fades in at start. The player turns music and sounds on or off in the menu (Options): they
## mute the Music and Effects buses.

const TRACK: AudioStream = preload("res://assets/sounds/music_calm.ogg")
const BUS: StringName = &"Music"
const EFFECTS_BUS: StringName = &"Effects"
## Loudness of the music, in decibels (it stays under the effects), and of the fade-in.
const VOLUME_DB: float = -10.0
const FADE_IN_SECONDS: float = 2.0
const SILENT_DB: float = -40.0
## The audio server frees a stopped sound at its next mix only: wait for one before quitting
## (docs/pitfalls/godot-ligne-de-commande-et-export.md, "resources still in use at exit").
const EXIT_MIX_WAIT_MS: int = 100

var _player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	var track: AudioStreamOggVorbis = (TRACK as AudioStreamOggVorbis).duplicate()
	track.loop = true
	_player.stream = track
	_player.bus = BUS
	_player.volume_db = SILENT_DB
	add_child(_player)
	Options.changed.connect(apply_options)
	apply_options()
	_player.play()
	create_tween().tween_property(_player, "volume_db", VOLUME_DB, FADE_IN_SECONDS)


## Mutes or unmutes the music and the sounds, as the player chose.
func apply_options() -> void:
	_mute(BUS, not Options.settings.music)
	_mute(EFFECTS_BUS, not Options.settings.sounds)


## Whether the music is playing (tests).
func is_playing() -> bool:
	return _player != null and _player.playing


func _mute(bus: StringName, muted: bool) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index >= 0:
		AudioServer.set_bus_mute(index, muted)


func _exit_tree() -> void:
	if _player != null:
		_player.stop()
		_player.free()
		_player = null
		OS.delay_msec(EXIT_MIX_WAIT_MS)
