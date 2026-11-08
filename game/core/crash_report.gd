class_name CrashReport
extends RefCounted
## The report of a session that crashed (its SessionLog has no end line): the header (game,
## system, graphics card) and the end of the log, as plain text for the player to paste to Claude.

## Lines of the log kept at most (the end of it: the crash and what led to it).
const MAX_LINES: int = 200


## Whether a session's log shows that it crashed: written to, but not ended normally.
static func crashed(log_text: String) -> bool:
	return not log_text.strip_edges().is_empty() and not log_text.contains(SessionLog.END_LINE)


## The report of a crashed session's log: its header (up to the first empty line), then its
## last `max_lines` lines.
static func build(log_text: String, max_lines: int = MAX_LINES) -> String:
	var lines: PackedStringArray = log_text.strip_edges(false, true).split("\n")
	var header_end: int = lines.find("")
	if header_end < 0:
		header_end = 0
	var header: PackedStringArray = lines.slice(0, header_end)
	var body: PackedStringArray = lines.slice(header_end + 1 if header_end > 0 else 0)
	var parts: PackedStringArray = ["%s - crash report" % game_name()]
	parts.append_array(header)
	parts.append("")
	if body.size() > max_lines:
		parts.append("[... %d earlier lines left out ...]" % (body.size() - max_lines))
		body = body.slice(body.size() - max_lines)
	parts.append_array(body)
	return "\n".join(parts)


## The game's name, from the project settings.
static func game_name() -> String:
	return str(ProjectSettings.get_setting("application/config/name", "Game"))


## The first lines of a session's log: when, which game, which computer.
static func header(values: Dictionary) -> String:
	var lines: PackedStringArray = []
	for key: String in values:
		lines.append("%s: %s" % [key, str(values[key])])
	return "\n".join(lines) + "\n"
