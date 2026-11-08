extends GdUnitTestSuite
## Crash reports (game/core/crash_report.gd, session_log.gd): a session's log without its end
## line is a crash; its report keeps the header and the end of the log.

const HEADER: String = "Started: 2026-11-06 15:17:30\nGraphics: GeForce GTX 1080 (1.4.312)\n"


func _log(lines: int) -> String:
	var body: PackedStringArray = []
	for i in lines:
		body.append("line %d" % (i + 1))
	return HEADER + "\n" + "\n".join(body) + "\n"


func test_only_a_log_without_its_end_line_is_a_crash() -> void:
	assert_bool(CrashReport.crashed("")).is_false()
	assert_bool(CrashReport.crashed(_log(3) + SessionLog.END_LINE + "\n")).is_false()
	assert_bool(CrashReport.crashed(_log(3))).is_true()
	# Only the header: the game crashed before printing anything.
	assert_bool(CrashReport.crashed(HEADER + "\n")).is_true()


func test_the_report_keeps_the_header_and_the_end_of_the_log() -> void:
	var report: String = CrashReport.build(_log(10), 4)
	var lines: PackedStringArray = report.split("\n")
	assert_str(lines[0]).is_equal("%s - crash report" % CrashReport.game_name())
	assert_str(lines[1]).is_equal("Started: 2026-11-06 15:17:30")
	assert_str(lines[2]).is_equal("Graphics: GeForce GTX 1080 (1.4.312)")
	assert_str(lines[3]).is_empty()
	assert_str(lines[4]).contains("6 earlier lines left out")
	assert_array(Array(lines.slice(5))).is_equal(["line 7", "line 8", "line 9", "line 10"])


func test_a_short_log_is_kept_whole() -> void:
	var report: String = CrashReport.build(_log(2))
	assert_str(report).contains("line 1\nline 2").not_contains("left out")


func test_the_header_lists_its_values_in_order() -> void:
	var header: String = CrashReport.header({"Game": "0.1.0", "System": "Windows 10"})
	assert_str(header).is_equal("Game: 0.1.0\nSystem: Windows 10\n")


func test_errors_are_written_as_godot_prints_them() -> void:
	var text: String = SessionLog.format_error(
		"foo", "res://game/x.gd", 12, "code", "Out of bounds", Logger.ERROR_TYPE_SCRIPT, []
	)
	assert_str(text).is_equal("SCRIPT ERROR: Out of bounds\n   at: foo (res://game/x.gd:12)\n")
	# Without a reason, the failed condition.
	text = SessionLog.format_error("bar", "core/y.cpp", 3, "Condition failed", "", 0, [])
	assert_str(text).starts_with("ERROR: Condition failed\n")
