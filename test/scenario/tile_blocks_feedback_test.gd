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


func test_the_comeback_gift_continues_for_free_once() -> void:
	GameState.day_override = 500
	GameState.progress.stats.start_session(490)
	GameState.progress.stats.start_session(500)
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	Ads.use_backend(fake)
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	_lose(screen)
	var button: Button = runner.find_child("ContinueButton") as Button
	assert_str(button.text).is_equal("BUTTON_CONTINUE_FREE")
	button.pressed.emit()
	assert_int(fake.shown).is_equal(0)
	assert_bool(screen.game.is_over()).is_false()
	assert_bool(GameState.has_comeback_gift(screen.rules.comeback_days)).is_false()
	# The next game, the continue costs an ad again.
	screen.start(2)
	_lose(screen)
	assert_str(button.text).is_equal("BUTTON_CONTINUE_AD")


func test_the_daily_challenge_deals_the_same_pieces_and_keeps_the_best_of_the_day() -> void:
	GameState.day_override = 700
	var runner: GdUnitSceneRunner = scene_runner("res://game/proto_tiles/daily.tscn")
	await runner.simulate_frames(2)
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var expected: TileBlocksGame = TileBlocksGame.new(screen.rules, DailyChallenge.seed_for(700))
	for slot in expected.hand.size():
		assert_that(screen.game.hand[slot].cells).is_equal(expected.hand[slot].cells)
	assert_str((runner.find_child("LevelLabel") as Label).text).is_equal(tr("HUD_DAILY"))
	screen.game.hand[0] = _single(1)
	screen.refresh()
	await _drag(runner, 0, Vector2i(0, 0))
	screen.game.scores.score = 250
	(runner.find_child("ReplayButton") as Button).pressed.emit()
	assert_int(GameState.progress.stats.daily_best_on(700)).is_equal(250)
	assert_int(GameState.progress.stats.daily_streak_on(700)).is_equal(1)
	assert_int(screen.chase.record).is_equal(250)


func test_a_hovering_piece_lights_the_cells_it_would_clear() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var board: BoardView = runner.find_child("Board") as BoardView
	for x in 7:
		screen.game.grid.set_symbol(Vector2i(x, 5), x % 2)
	screen.game.hand[0] = _single(3)
	screen.refresh()
	var tray: TrayView = runner.find_child("Tray") as TrayView
	runner.set_mouse_position(TileBlocksDriver.on_screen(runner, tray.slot_center(0)))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	runner.simulate_mouse_move(
		TileBlocksDriver.on_screen(runner, screen.pointer_for(0, Vector2i(7, 5)))
	)
	await runner.await_input_processed()
	assert_int(board.preview_cells().size()).is_equal(8)
	assert_array(board.preview_cells()).contains([Vector2i(0, 5), Vector2i(7, 5)])
	# Elsewhere, nothing would clear: nothing glows.
	runner.simulate_mouse_move(
		TileBlocksDriver.on_screen(runner, screen.pointer_for(0, Vector2i(7, 0)))
	)
	await runner.await_input_processed()
	assert_array(board.preview_cells()).is_empty()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	assert_array(board.preview_cells()).is_empty()


func test_a_placed_piece_clacks_and_its_points_rise() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var sounds: GameSounds = runner.find_child("Sounds") as GameSounds
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	screen.game.hand[0] = _single(1)
	screen.refresh()
	await _drag(runner, 0, Vector2i(0, 0))
	assert_str(String(sounds.last_played)).is_equal(String(GameSounds.PLACE))
	assert_array(effects.points_texts()).contains([tr("POINTS_GAINED") % screen.game.score()])
	assert_int(effects.light_count()).is_equal(0)


func test_a_cleared_row_is_swept_by_light_with_a_chime() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var sounds: GameSounds = runner.find_child("Sounds") as GameSounds
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	for x in 7:
		screen.game.grid.set_symbol(Vector2i(x, 5), x % 2)
	screen.game.grid.set_symbol(Vector2i(0, 0), 4)
	screen.game.hand[0] = _single(3)
	screen.refresh()
	await _drag(runner, 0, Vector2i(7, 5))
	assert_int(screen.game.grid.filled_count()).is_equal(1)
	assert_str(String(sounds.last_played)).is_equal(String(GameSounds.CLEAR))
	# The beam along the row and the ring from the piece.
	assert_int(effects.light_count()).is_equal(2)


func test_a_lost_game_greys_the_grid_with_a_falling_phrase() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var sounds: GameSounds = runner.find_child("Sounds") as GameSounds
	var board: BoardView = runner.find_child("Board") as BoardView
	_lose(screen)
	assert_str(String(sounds.last_played)).is_equal(String(GameSounds.GAME_OVER))
	for _frame in 120:
		if board.modulate.is_equal_approx(screen.art.game_over_tint):
			break
		await runner.simulate_frames(1, 50)
	assert_bool(board.modulate.is_equal_approx(screen.art.game_over_tint)).is_true()
	screen.start(2)
	assert_bool(board.modulate.is_equal_approx(Color.WHITE)).is_true()


func test_the_points_of_a_move_show_as_one_number() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	# The last tile of a row empties the grid: the points of the move and the bonus, together.
	for x in 7:
		screen.game.grid.set_symbol(Vector2i(x, 2), x % 2)
	screen.game.hand[0] = _single(3)
	screen.game.hand[1] = _single(1)
	screen.refresh()
	await _drag(runner, 0, Vector2i(7, 2))
	assert_int(screen.game.grid.filled_count()).is_equal(0)
	assert_array(effects.points_texts()).is_equal([tr("POINTS_GAINED") % screen.game.score()])
	assert_array(effects.praise_texts()).is_equal([tr("PRAISE_EMPTY_GRID")])
	assert_bool(effects.has_wave()).is_true()
	# The next move's points take the place of the ones still on screen.
	var before: int = screen.game.score()
	await _drag(runner, 1, Vector2i(0, 0))
	assert_array(effects.points_texts()).is_equal(
		[tr("POINTS_GAINED") % (screen.game.score() - before)]
	)


func test_the_end_card_opens_on_a_clean_grid() -> void:
	GameState.progress.stats.best_score = 400
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	for x in 7:
		screen.game.grid.set_symbol(Vector2i(x, 5), x % 2)
	screen.game.grid.set_symbol(Vector2i(0, 0), 4)
	screen.game.hand[0] = _single(3)
	screen.refresh()
	await _drag(runner, 0, Vector2i(7, 5))
	assert_int(effects.fragment_count()).is_greater(0)
	assert_bool((runner.find_child("ComboChip") as Control).visible).is_false()
	_lose(screen)
	# Nothing left flying under the card, and the score counts up to its value.
	assert_int(effects.fragment_count()).is_equal(0)
	assert_int(effects.light_count()).is_equal(0)
	assert_array(effects.points_texts()).is_empty()
	var final_score: Label = runner.find_child("FinalScoreLabel") as Label
	for _frame in 120:
		if final_score.text == str(screen.game.score()):
			break
		await runner.simulate_frames(1, 50)
	assert_str(final_score.text).is_equal(str(screen.game.score()))
	assert_float((runner.find_child("Card") as Control).scale.x).is_equal_approx(1.0, 0.2)


func test_a_beaten_record_shows_a_banner_and_a_golden_score() -> void:
	GameState.progress.stats.best_score = 10
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var effects: ClearEffects = runner.find_child("Effects") as ClearEffects
	var score: Label = runner.find_child("ScoreLabel") as Label
	screen.game.scores.score = 5
	screen.refresh()
	assert_array(effects.banner_texts()).is_empty()
	screen.game.scores.score = 11
	screen.refresh()
	assert_array(effects.banner_texts()).is_equal([tr("NEW_RECORD")])
	assert_that(score.get_theme_color("font_color")).is_equal(screen.art.gold_light)
	# Said once: more points do not bring another banner.
	screen.game.scores.score = 20
	screen.refresh()
	assert_int(effects.banner_texts().size()).is_equal(1)


func test_bonus_buttons_in_trouble_turn_to_the_calling_look() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var new_hand: Button = runner.find_child("NewHandButton") as Button
	assert_str(String(new_hand.theme_type_variation)).is_equal(String(TileBlocksScreen.BONUS_STYLE))
	var size: int = screen.game.grid.size
	for y in size:
		for x in size:
			if (x * 5 + y * 3) % 11 != 0:
				screen.game.grid.set_symbol(Vector2i(x, y), (x * 3 + y * 2) % 5)
	screen.refresh()
	if screen.is_calling_for_bonuses():
		assert_str(String(new_hand.theme_type_variation)).is_equal(
			String(TileBlocksScreen.CALL_STYLE)
		)
		assert_bool(new_hand.modulate.is_equal_approx(Color.WHITE)).is_true()
	screen.start(2)
	assert_str(String(new_hand.theme_type_variation)).is_equal(String(TileBlocksScreen.BONUS_STYLE))
