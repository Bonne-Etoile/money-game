class_name SessionLog
extends Logger
## Everything the engine prints during a session (messages, errors with their GDScript
## backtrace, the crash handler's dump), written to a file and flushed at once: the game's own
## log (user://logs/godot.log) is only flushed on exit in the exported game, so a crash left it
## empty. A clean exit ends the file with END_LINE; a file without it means the game crashed,
## and the next start offers it to copy (CrashReport, the main menu).
## Godot may call the logger from any thread: every write takes the lock.

## The last line of a session that ended normally.
const END_LINE: String = "-- session ended normally --"
## Error types (Logger.ErrorType) as Godot prints them.
const ERROR_PREFIXES: PackedStringArray = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"]

var _file: FileAccess = null
var _lock: Mutex = Mutex.new()
## Set while writing: a failed write that reports an error does not log itself again.
var _writing: bool = false


## Starts a new log at `path` (the previous one is replaced); false when it cannot be written.
func open(path: String, header: String) -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		return false
	_write(header + "\n")
	return true


func is_open() -> bool:
	return _file != null


## Ends the log of a session that ended normally.
func close() -> void:
	_lock.lock()
	if _file != null:
		_file.store_string(END_LINE + "\n")
		_file.close()
		_file = null
	_lock.unlock()


## Adds a line of context of the game's own (a scene opened), with the time since the start.
func note(text: String) -> void:
	_write("[%.1f s] %s\n" % [Time.get_ticks_msec() / 1000.0, text])


func _log_message(message: String, _error: bool) -> void:
	_write(message)


func _log_error(
	function: String,
	file: String,
	line: int,
	code: String,
	rationale: String,
	_editor_notify: bool,
	error_type: int,
	script_backtraces: Array[ScriptBacktrace]
) -> void:
	_write(format_error(function, file, line, code, rationale, error_type, script_backtraces))


## An error as Godot prints it: type and message, where, then each script backtrace.
static func format_error(
	function: String,
	file: String,
	line: int,
	code: String,
	rationale: String,
	error_type: int,
	script_backtraces: Array[ScriptBacktrace]
) -> String:
	var prefix: String = ERROR_PREFIXES[clampi(error_type, 0, ERROR_PREFIXES.size() - 1)]
	var text: String = (
		"%s: %s\n   at: %s (%s:%d)\n"
		% [prefix, rationale if not rationale.is_empty() else code, function, file, line]
	)
	for backtrace in script_backtraces:
		if not backtrace.is_empty():
			text += backtrace.format(3) + "\n"
	return text


func _write(text: String) -> void:
	_lock.lock()
	if _file != null and not _writing:
		_writing = true
		_file.store_string(text)
		_file.flush()
		_writing = false
	_lock.unlock()
