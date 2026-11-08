extends Node
## Crash reports: the session's log (SessionLog), and the report of the previous session when
## it crashed, which the main menu offers to copy. First autoload, to catch the others' errors.
## Only the exported game writes user://logs/session.log: tests start it on their own path.

const LOG_PATH: String = "user://logs/session.log"
## Where the log of a crashed session is kept, until the next crash.
const CRASHED_LOG_PATH: String = "user://logs/crashed_session.log"

## The previous session's crash report, or empty: it ended normally (or was dismissed).
var crash_report: String = ""

var _log: SessionLog = null


func _ready() -> void:
	if OS.has_feature("template"):
		start(LOG_PATH, CRASHED_LOG_PATH)
	get_tree().scene_changed.connect(_on_scene_changed)


## Reads the previous session's log at `path` (keeps it at `crashed_path` when it crashed),
## then starts this session's log there.
func start(path: String, crashed_path: String) -> void:
	stop(false)
	crash_report = ""
	if FileAccess.file_exists(path):
		var previous: String = FileAccess.get_file_as_string(path)
		if CrashReport.crashed(previous):
			crash_report = CrashReport.build(previous)
			DirAccess.copy_absolute(path, crashed_path)
	_log = SessionLog.new()
	if _log.open(path, CrashReport.header(system_info())):
		OS.add_logger(_log)
	else:
		_log = null


## Stops logging; `ended_normally` marks the log as a normal end (not a crash).
func stop(ended_normally: bool = true) -> void:
	if _log == null:
		return
	OS.remove_logger(_log)
	if ended_normally:
		_log.close()
	_log = null


func dismiss_crash_report() -> void:
	crash_report = ""


## When, which game, which computer: the first lines of each session's log.
func system_info() -> Dictionary:
	var engine: Dictionary = Engine.get_version_info()
	return {
		"Started": Time.get_datetime_string_from_system(false, true),
		"Game": ProjectSettings.get_setting("application/config/version", ""),
		"Godot": engine.get("string", ""),
		"System": "%s %s" % [OS.get_name(), OS.get_version()],
		"Processor": OS.get_processor_name(),
		"Graphics":
		(
			"%s (%s)"
			% [
				RenderingServer.get_video_adapter_name(),
				RenderingServer.get_video_adapter_api_version()
			]
		),
		"Screen": "%s, window %s" % [DisplayServer.screen_get_size(), get_window().size],
	}


## Adds a line of context to the session's log (not printed).
func note(text: String) -> void:
	if _log != null:
		_log.note(text)


## Notes which scene opened: the report tells where the game was.
func _on_scene_changed() -> void:
	var scene: Node = get_tree().current_scene
	if scene != null:
		note("scene %s" % scene.scene_file_path)


func _exit_tree() -> void:
	stop()
