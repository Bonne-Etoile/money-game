extends GdUnitTestSuite
## The start menu (game/ui/main_menu.tscn): the play button, and the crash report after a crash.

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


func test_the_play_button_opens_the_game() -> void:
	var runner: GdUnitSceneRunner = _menu()
	await runner.simulate_frames(2)
	var menu: MainMenu = runner.scene() as MainMenu
	(runner.find_child("PlayButton") as Button).pressed.emit()
	assert_str(menu.chosen_scene).is_equal(MainMenu.TILE_BLOCKS_SCENE)
	assert_bool(ResourceLoader.exists(MainMenu.TILE_BLOCKS_SCENE)).is_true()


func test_the_menu_opens_on_the_crash_report_after_a_crash() -> void:
	Diagnostics.crash_report = "My Game - crash report\nSCRIPT ERROR: boom"
	var runner: GdUnitSceneRunner = _menu()
	await runner.simulate_frames(2)
	assert_bool((runner.find_child("Crash") as Control).visible).is_true()
	assert_str((runner.find_child("ReportText") as TextEdit).text).contains("boom")
	(runner.find_child("CrashCloseButton") as Button).pressed.emit()
	assert_bool((runner.find_child("Main") as Control).visible).is_true()
	assert_str(Diagnostics.crash_report).is_empty()
