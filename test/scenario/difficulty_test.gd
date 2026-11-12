extends GdUnitTestSuite
## The adaptive difficulty on screen (game/proto_tiles/tile_blocks.tscn): once the player has a
## record, the level shown in the top bar stays calm far from it and climbs close to it; each
## game is kept in the games journal (Diagnostics.log_game) to tune it.

const SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"

const JOURNAL: String = "user://test_saves/scenario_games.jsonl"


func before_test() -> void:
	GameState.reset()
	GameState.progress.stats.games_played = 10
	if FileAccess.file_exists(JOURNAL):
		DirAccess.remove_absolute(JOURNAL)


func after_test() -> void:
	Diagnostics.games_path = ""
	if FileAccess.file_exists(JOURNAL):
		DirAccess.remove_absolute(JOURNAL)


func _screen() -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	(runner.scene() as TileBlocksScreen).start(1)
	await runner.simulate_frames(2)
	return runner


func test_the_difficulty_stays_calm_until_close_to_the_record() -> void:
	GameState.progress.stats.best_score = 5000
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var label: Label = runner.find_child("LevelLabel") as Label
	screen.game.scores.score = 3000
	screen.refresh()
	assert_int(screen.game.level()).is_equal(0)
	assert_str(label.text).is_equal(tr("HUD_DIFFICULTY") % 0)
	screen.game.scores.score = 4500
	screen.refresh()
	assert_int(screen.game.level()).is_equal(3)
	assert_str(label.text).is_equal(tr("HUD_DIFFICULTY") % 3)


## Drags the piece of `slot` from the tray and drops it with its corner on `origin`.
func _drag(runner: GdUnitSceneRunner, slot: int, origin: Vector2i) -> void:
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var transform: Transform2D = screen.get_viewport().get_screen_transform()
	var start: Vector2 = (runner.find_child("Tray") as TrayView).slot_center(slot)
	runner.set_mouse_position(transform * start)
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	var target: Vector2 = screen.pointer_for(slot, origin)
	runner.simulate_mouse_move(transform * target.lerp(start, 0.5))
	await runner.await_input_processed()
	runner.simulate_mouse_move(transform * target)
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()


func test_a_game_left_by_closing_the_window_is_kept_in_the_journal() -> void:
	Diagnostics.games_path = JOURNAL
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([1]))
	screen.refresh()
	await _drag(runner, 0, Vector2i(3, 3))
	assert_int(screen.game.moves).is_equal(1)
	screen.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	var line: String = FileAccess.get_file_as_string(JOURNAL).strip_edges()
	var entry: Dictionary = JSON.parse_string(line)
	assert_str(entry["mode"]).is_equal("endless")
	assert_str(entry["ended"]).is_equal("left")
	var moves: Array = entry["move_log"]
	assert_int(moves.size()).is_equal(1)
