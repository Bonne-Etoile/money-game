extends GdUnitTestSuite
## The start menu (game/ui/main_menu.tscn): play, and the crash report after a crash.

const MENU_SCENE: String = "res://game/ui/main_menu.tscn"
const TEST_SAVES: String = "user://test_saves"


func before_test() -> void:
	GameState.reset()
	GameState.saves = SaveSlots.new(TEST_SAVES)
	for slot in GameState.saves.slots():
		GameState.saves.delete(slot)


func after_test() -> void:
	for slot in GameState.saves.slots():
		GameState.saves.delete(slot)
	GameState.saves = SaveSlots.new(GameState.SAVES_DIRECTORY)
	GameState.reset()
	Diagnostics.dismiss_crash_report()


func _menu() -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(MENU_SCENE)
	(runner.scene() as MainMenu).opens_game = false
	return runner


func test_play_starts_a_new_game_then_continues_it() -> void:
	var runner: GdUnitSceneRunner = _menu()
	await runner.simulate_frames(2)
	(runner.find_child("PlayButton") as Button).pressed.emit()
	assert_int(GameState.slot).is_equal(1)
	GameState.earn(30)
	GameState.save_game()
	GameState.reset()
	(runner.find_child("PlayButton") as Button).pressed.emit()
	assert_int(GameState.slot).is_equal(1)
	assert_int(GameState.progress.money).is_equal(30)


func test_the_menu_opens_on_the_crash_report_after_a_crash() -> void:
	Diagnostics.crash_report = "My Game - crash report\nSCRIPT ERROR: boom"
	var runner: GdUnitSceneRunner = _menu()
	await runner.simulate_frames(2)
	assert_bool((runner.find_child("Crash") as Control).visible).is_true()
	assert_str((runner.find_child("ReportText") as TextEdit).text).contains("boom")
	(runner.find_child("CrashCloseButton") as Button).pressed.emit()
	assert_bool((runner.find_child("Main") as Control).visible).is_true()
	assert_str(Diagnostics.crash_report).is_empty()
