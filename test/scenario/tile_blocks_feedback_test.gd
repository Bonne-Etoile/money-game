extends GdUnitTestSuite
## Prototype 1 on screen, around the moves (G10, G12, G13): the race to the record, how the
## pieces come back, and the feedback of clears.

const SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"


func before_test() -> void:
	GameState.reset()


func after_test() -> void:
	Options.settings = GameSettings.new()


func _screen() -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	(runner.scene() as TileBlocksScreen).start(1)
	await runner.simulate_frames(2)
	return runner


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func _drag(runner: GdUnitSceneRunner, slot: int, origin: Vector2i) -> void:
	await TileBlocksDriver.drag(runner, slot, origin)


func _lose(screen: TileBlocksScreen) -> void:
	TileBlocksDriver.lose(screen)


func test_the_record_is_always_shown_and_celebrated_when_beaten() -> void:
	GameState.progress.stats.best_score = 400
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var record: Label = runner.find_child("RecordLabel") as Label
	var bar: ProgressBar = runner.find_child("RecordProgress") as ProgressBar
	assert_str(record.text).is_equal(tr("HUD_BEST") % 400)
	screen.game.scores.score = 100
	screen.refresh()
	assert_float(bar.value).is_equal(25.0)
	screen.game.scores.score = 401
	screen.refresh()
	assert_str(record.text).is_equal(tr("NEW_RECORD"))
	assert_float(bar.value).is_equal(100.0)
	await runner.simulate_frames(3)
	assert_float(record.scale.x).is_greater(1.0)


func test_the_game_over_panel_says_what_was_missing_for_the_record() -> void:
	GameState.progress.stats.best_score = 400
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.scores.score = 280
	_lose(screen)
	var gap: Label = runner.find_child("RecordGapLabel") as Label
	assert_bool(gap.visible).is_true()
	assert_str(gap.text).is_equal(tr("RECORD_MISSING") % 121)


func test_with_three_pieces_at_a_time_a_placed_piece_leaves_its_slot_empty() -> void:
	Options.settings.refill_together = true
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	assert_bool(screen.game.rules.refill_each_slot).is_false()
	screen.game.hand[0] = _single(1)
	screen.refresh()
	await _drag(runner, 0, Vector2i(0, 0))
	assert_object(screen.game.hand[0]).is_null()
	assert_int(screen.game.moves).is_equal(1)


func test_with_one_piece_at_a_time_a_new_piece_takes_the_slot() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	assert_bool(screen.game.rules.refill_each_slot).is_true()
	screen.game.hand[0] = _single(1)
	screen.refresh()
	await _drag(runner, 0, Vector2i(0, 0))
	assert_object(screen.game.hand[0]).is_not_null()


func test_a_strong_clear_bursts_shakes_and_is_praised() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	# A row and a trio at once, the grid left with a tile: two clears, no empty grid.
	for x in 6:
		screen.game.grid.set_symbol(Vector2i(x, 1), x % 2)
	screen.game.grid.set_symbol(Vector2i(6, 1), 3)
	screen.game.grid.set_symbol(Vector2i(7, 2), 3)
	screen.game.grid.set_symbol(Vector2i(0, 6), 4)
	screen.game.hand[0] = _single(3)
	screen.refresh()
	await _drag(runner, 0, Vector2i(7, 1))
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	assert_int(screen.game.grid.filled_count()).is_equal(1)
	assert_int(effects.fragment_count()).is_greater(0)
	assert_bool((runner.find_child("Board") as BoardView).is_shaking()).is_true()
	assert_array(effects.praise_texts()).contains([tr("PRAISE_1")])
	# The fragments fade away.
	for _frame in 120:
		if effects.fragment_count() == 0:
			break
		await runner.simulate_frames(1, 50)
	assert_int(effects.fragment_count()).is_equal(0)


func test_beating_the_record_sets_off_fireworks() -> void:
	GameState.progress.stats.best_score = 10
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	screen.game.scores.score = 11
	screen.refresh()
	for _frame in 20:
		if effects.fragment_count() > 0:
			break
		await runner.simulate_frames(1, 50)
	assert_int(effects.fragment_count()).is_greater(0)


func test_a_hesitating_player_is_shown_a_placement_that_clears() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var board: BoardView = runner.find_child("Board") as BoardView
	screen.game.grid.set_symbol(Vector2i(2, 4), 1)
	screen.game.grid.set_symbol(Vector2i(3, 4), 1)
	screen.game.hand[1] = _single(1)
	screen.refresh()
	for _frame in 100:
		if board.has_hint():
			break
		await runner.simulate_frames(1, 250)
	assert_bool(board.has_hint()).is_true()
	assert_float(screen.idle_seconds).is_greater_equal(screen.rules.hint_after_seconds)
	# Any move takes the hint away.
	await _drag(runner, 1, Vector2i(4, 4))
	assert_bool(board.has_hint()).is_false()


func test_no_hint_before_the_wait_is_over() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.grid.set_symbol(Vector2i(2, 4), 1)
	screen.game.grid.set_symbol(Vector2i(3, 4), 1)
	screen.game.hand[1] = _single(1)
	screen.refresh()
	await runner.simulate_frames(5, 100)
	assert_bool((runner.find_child("Board") as BoardView).has_hint()).is_false()
