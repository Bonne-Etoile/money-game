extends Node
## The game window: F11 switches between windowed and full screen, and the exported game
## reopens with the window as the player left it (WindowSettings, user://settings.json).
## Only the exported desktop game reads and writes the file: tests and screenshots keep their
## window, and on a phone the game always fills the screen.

const SETTINGS_PATH: String = "user://settings.json"

var settings: WindowSettings = WindowSettings.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if _persists():
		settings = _load()
		_apply()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		set_fullscreen(not is_fullscreen())
		get_viewport().set_input_as_handled()


func is_fullscreen() -> bool:
	return get_window().mode == Window.MODE_FULLSCREEN


func set_fullscreen(enabled: bool) -> void:
	if enabled:
		_remember_window()
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = settings.size
		if settings.position != null:
			get_window().position = settings.position
	settings.fullscreen = enabled
	_save()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()


func _exit_tree() -> void:
	_save()


func _apply() -> void:
	var window: Window = get_window()
	window.size = settings.size
	var screens: Array[Rect2i] = []
	for screen in DisplayServer.get_screen_count():
		screens.append(DisplayServer.screen_get_usable_rect(screen))
	if settings.fits_on(screens):
		window.position = settings.position
	else:
		settings.position = null
		window.move_to_center()
	if settings.fullscreen:
		window.mode = Window.MODE_FULLSCREEN


## Keeps the windowed size and position (not those of the full screen).
func _remember_window() -> void:
	var window: Window = get_window()
	if window.mode == Window.MODE_WINDOWED:
		settings.size = window.size
		settings.position = window.position


func _persists() -> bool:
	return OS.has_feature("template") and not OS.has_feature("mobile")


func _load() -> WindowSettings:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return WindowSettings.new()
	return WindowSettings.from_json(FileAccess.get_file_as_string(SETTINGS_PATH))


func _save() -> void:
	if not _persists():
		return
	_remember_window()
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(settings.to_json())
