extends Node
## The player's options (GameSettings): applies the vertical sync and the language at once,
## tells the player of the rest (mouse, vertical axis, field of view) through `changed`. Only
## the exported game reads and writes user://options.json: tests keep the defaults.

## An option changed (the player applies the mouse and camera ones).
signal changed

const SETTINGS_PATH: String = "user://options.json"

var settings: GameSettings = GameSettings.new()


func _ready() -> void:
	if _persists() and FileAccess.file_exists(SETTINGS_PATH):
		settings = GameSettings.from_json(FileAccess.get_file_as_string(SETTINGS_PATH))
	_apply_vsync()
	# The system's language is Godot's own choice at start: only a chosen one replaces it.
	if not settings.language.is_empty():
		TranslationServer.set_locale(settings.language)


func set_mouse_sensitivity(value: float) -> void:
	settings.set_mouse_sensitivity(value)
	_changed()


func set_invert_y(enabled: bool) -> void:
	settings.invert_y = enabled
	_changed()


func set_field_of_view(value: float) -> void:
	settings.set_field_of_view(value)
	_changed()


func set_vsync(enabled: bool) -> void:
	settings.vsync = enabled
	_changed()


func set_refill_together(enabled: bool) -> void:
	settings.refill_together = enabled
	_changed()


func set_vibration(enabled: bool) -> void:
	settings.vibration = enabled
	_changed()


func set_language(code: String) -> void:
	settings.set_language(code)
	TranslationServer.set_locale(settings.locale(OS.get_locale_language()))
	_changed()


func _changed() -> void:
	_apply_vsync()
	_save()
	changed.emit()


func _apply_vsync() -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED
	)


func _persists() -> bool:
	return OS.has_feature("template")


func _save() -> void:
	if not _persists():
		return
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(settings.to_json())
