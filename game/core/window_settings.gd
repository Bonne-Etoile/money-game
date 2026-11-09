class_name WindowSettings
extends RefCounted
## The game window as the player left it (windowed or full screen, size, position), saved in
## user://settings.json so that the game reopens in the same place (a player asked to play in
## a small window beside something else). Versioned JSON, never a Godot resource.

const VERSION: int = 1
## Smallest window the game accepts, in pixels.
const MIN_SIZE: Vector2i = Vector2i(360, 640)

var fullscreen: bool = false
var size: Vector2i = Vector2i(450, 800)
## Top-left corner of the window on the desktop; null until the player moved it.
var position: Variant = null


func to_dict() -> Dictionary:
	var data: Dictionary = {
		"version": VERSION,
		"fullscreen": fullscreen,
		"width": size.x,
		"height": size.y,
	}
	if position != null:
		var corner: Vector2i = position
		data["x"] = corner.x
		data["y"] = corner.y
	return data


## Reads saved settings; anything missing or invalid keeps its default value.
static func from_dict(data: Dictionary) -> WindowSettings:
	var settings: WindowSettings = WindowSettings.new()
	if not _is_number(data.get("version")):
		return settings
	var full: Variant = data.get("fullscreen")
	if full is bool:
		settings.fullscreen = full
	var width: Variant = data.get("width")
	var height: Variant = data.get("height")
	if _is_number(width) and _is_number(height):
		settings.size = Vector2i(
			maxi(_to_int(width), MIN_SIZE.x), maxi(_to_int(height), MIN_SIZE.y)
		)
	var x: Variant = data.get("x")
	var y: Variant = data.get("y")
	if _is_number(x) and _is_number(y):
		settings.position = Vector2i(_to_int(x), _to_int(y))
	return settings


## Whether the window, at its saved position, would be visible on one of these screen areas
## (a screen may have been unplugged since).
func fits_on(screens: Array[Rect2i]) -> bool:
	if position == null:
		return false
	var corner: Vector2i = position
	var window: Rect2i = Rect2i(corner, size)
	for screen in screens:
		if screen.has_point(window.position) and screen.intersects(window):
			return true
	return false


func to_json() -> String:
	return JSON.stringify(to_dict(), "\t")


## Reads settings from JSON text; invalid text gives the default settings.
static func from_json(text: String) -> WindowSettings:
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var data: Dictionary = parsed
		return from_dict(data)
	return WindowSettings.new()


static func _is_number(value: Variant) -> bool:
	return value is int or value is float


## JSON numbers are floats.
static func _to_int(value: Variant) -> int:
	if value is int:
		var whole: int = value
		return whole
	var number: float = value
	return roundi(number)
