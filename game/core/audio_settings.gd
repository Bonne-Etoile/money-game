class_name AudioSettings
extends RefCounted
## Volumes chosen by the player (docs/conception-du-jeu.md, § 10: general, music, effects), from
## 0 (silent) to 1 (full), saved in user://audio_settings.json. Versioned JSON, never a Godot
## resource. Ambience follows the effects volume (its bus sends to Effects).

const VERSION: int = 1
const KINDS: Array[StringName] = [&"master", &"music", &"effects"]

var _volumes: Dictionary[StringName, float] = {&"master": 1.0, &"music": 1.0, &"effects": 1.0}


func volume(kind: StringName) -> float:
	return _volumes.get(kind, 0.0)


## Unknown kinds are ignored; the value is kept between 0 and 1.
func set_volume(kind: StringName, value: float) -> void:
	if kind in KINDS:
		_volumes[kind] = clampf(value, 0.0, 1.0)


func to_dict() -> Dictionary:
	var data: Dictionary = {"version": VERSION}
	for kind in KINDS:
		data[String(kind)] = volume(kind)
	return data


## Reads saved settings; anything missing or invalid keeps its default value.
static func from_dict(data: Dictionary) -> AudioSettings:
	var settings: AudioSettings = AudioSettings.new()
	if not _is_number(data.get("version")):
		return settings
	for kind in KINDS:
		var value: Variant = data.get(String(kind))
		if _is_number(value):
			var number: float = value
			settings.set_volume(kind, number)
	return settings


func to_json() -> String:
	return JSON.stringify(to_dict(), "\t")


## Reads settings from JSON text; invalid text gives the default settings.
static func from_json(text: String) -> AudioSettings:
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var data: Dictionary = parsed
		return from_dict(data)
	return AudioSettings.new()


static func _is_number(value: Variant) -> bool:
	return value is int or value is float
