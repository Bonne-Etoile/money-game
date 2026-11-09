class_name GameSettings
extends RefCounted
## The player's options besides the volumes (AudioSettings) and the window (WindowSettings):
## mouse sensitivity, vertical axis, field of view, vertical sync, language, how the pieces
## come back (test build of G12) and vibration. Saved by the
## exported game in user://options.json. Versioned JSON, never a Godot resource.

const VERSION: int = 1
## Mouse sensitivity, as a factor of the game's own (the player scene's own setting).
const SENSITIVITY_RANGE: Vector2 = Vector2(0.25, 3.0)
## Field of view of the player's camera, in degrees.
const FIELD_OF_VIEW_RANGE: Vector2 = Vector2(60.0, 100.0)
## The languages of the game; "" follows the system's.
const LANGUAGES: Array[String] = ["", "en", "fr"]

var mouse_sensitivity: float = 1.0
var invert_y: bool = false
var field_of_view: float = 80.0
var vsync: bool = true
var language: String = ""
## Whether three new pieces come only once the three are placed (like Block Blast), instead
## of a new piece in each slot at once (G12: the player compares both on the same build).
var refill_together: bool = false
## Short vibrations on clears (phones only).
var vibration: bool = true


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = clampf(value, SENSITIVITY_RANGE.x, SENSITIVITY_RANGE.y)


func set_field_of_view(value: float) -> void:
	field_of_view = clampf(value, FIELD_OF_VIEW_RANGE.x, FIELD_OF_VIEW_RANGE.y)


## Unknown languages fall back to the system's ("").
func set_language(code: String) -> void:
	language = code if code in LANGUAGES else ""


## The locale to use: the chosen language, or the system's when it is one of the game's
## (English otherwise).
func locale(system_language: String) -> String:
	if not language.is_empty():
		return language
	return system_language if system_language in LANGUAGES else "en"


func to_dict() -> Dictionary:
	return {
		"version": VERSION,
		"mouse_sensitivity": mouse_sensitivity,
		"invert_y": invert_y,
		"field_of_view": field_of_view,
		"vsync": vsync,
		"language": language,
		"refill_together": refill_together,
		"vibration": vibration,
	}


## Reads saved options; anything missing or invalid keeps its default value.
static func from_dict(data: Dictionary) -> GameSettings:
	var settings: GameSettings = GameSettings.new()
	if JsonRead.integer(data, "version", -1) < 1:
		return settings
	settings.set_mouse_sensitivity(JsonRead.number(data, "mouse_sensitivity", 1.0))
	settings.set_field_of_view(JsonRead.number(data, "field_of_view", 80.0))
	settings.invert_y = data.get("invert_y") == true
	settings.vsync = data.get("vsync") != false
	settings.set_language(JsonRead.text(data, "language"))
	settings.refill_together = data.get("refill_together") == true
	settings.vibration = data.get("vibration") != false
	return settings


func to_json() -> String:
	return JSON.stringify(to_dict(), "\t")


static func from_json(text: String) -> GameSettings:
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return GameSettings.new()
	var data: Dictionary = json.data
	return from_dict(data)
