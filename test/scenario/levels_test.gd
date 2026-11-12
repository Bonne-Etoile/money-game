extends GdUnitTestSuite
## The level mode on screen (G17): the map opens levels as they are won, a level is won and
## the next one opens, a level is lost when the pieces run out, and "+5 pieces" after a
## rewarded ad (a fake one here) lets the player go on.

const LEVEL_SCENE: PackedScene = preload("res://game/levels/level.tscn")
const MAP_SCENE: String = "res://game/levels/level_map.tscn"


func before_test() -> void:
	GameState.reset()


func _level(index: int) -> GdUnitSceneRunner:
	var screen: LevelScreen = LEVEL_SCENE.instantiate()
	screen.level_index = index
	var runner: GdUnitSceneRunner = scene_runner(auto_free(screen))
	await runner.simulate_frames(2)
	return runner


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func test_the_map_opens_levels_as_they_are_won() -> void:
	GameState.progress.stats.levels_won = 2
	var runner: GdUnitSceneRunner = scene_runner(MAP_SCENE)
	var map: LevelMap = runner.scene() as LevelMap
	map.opens_level = false
	await runner.simulate_frames(2)
	assert_bool(map.level_button(2).disabled).is_false()
	assert_bool(map.level_button(3).disabled).is_true()
	map.level_button(2).pressed.emit()
	assert_int(map.chosen_level).is_equal(2)


func test_a_level_shows_its_goal_and_is_won() -> void:
	# Level 3: free the gold tiles.
	var runner: GdUnitSceneRunner = await _level(2)
	var screen: LevelScreen = runner.scene() as LevelScreen
	var goal: Label = runner.find_child("RecordLabel") as Label
	assert_str(goal.text).contains(tr("GOAL_GOLD"))
	var top: Label = runner.find_child("LevelLabel") as Label
	assert_str(top.text).is_equal(tr("HUD_LEVEL_PIECES") % [3, screen.level.pieces_left])
	assert_bool(LevelRobot.play(screen.level)).is_true()
	screen.refresh()
	assert_bool((runner.find_child("GameOver") as Control).visible).is_true()
	assert_str((runner.find_child("GameOverTitle") as Label).text).is_equal("LEVEL_WON")
	assert_int(GameState.progress.stats.levels_won).is_equal(3)
	var next: Button = runner.find_child("NextLevelButton") as Button
	assert_bool(next.visible).is_true()
	next.pressed.emit()
	assert_int(screen.level_index).is_equal(3)
	assert_bool((runner.find_child("GameOver") as Control).visible).is_false()


func test_out_of_pieces_then_five_more_after_an_ad() -> void:
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	Ads.use_backend(fake)
	var runner: GdUnitSceneRunner = await _level(0)
	var screen: LevelScreen = runner.scene() as LevelScreen
	await runner.simulate_frames(2)
	screen.level.pieces_left = 1
	screen.game.hand[0] = _single(0)
	screen.refresh()
	await TileBlocksDriver.drag(runner, 0, Vector2i(0, 0))
	assert_int(screen.level.pieces_left).is_equal(0)
	assert_str((runner.find_child("GameOverTitle") as Label).text).is_equal("LEVEL_NO_PIECES")
	assert_bool((runner.find_child("ContinueButton") as Button).visible).is_false()
	# No piece shows in the hand once none is left, and no "new pieces" on the end panel.
	for piece in screen.game.hand:
		assert_object(piece).is_null()
	assert_bool((runner.find_child("GameOverNewHandButton") as Button).visible).is_false()
	var extra: Button = runner.find_child("ExtraPiecesButton") as Button
	assert_bool(extra.visible).is_true()
	assert_bool(extra.disabled).is_false()
	extra.pressed.emit()
	assert_int(fake.shown).is_equal(1)
	assert_int(screen.level.pieces_left).is_equal(screen.levels.extra_pieces)
	assert_bool((runner.find_child("GameOver") as Control).visible).is_false()
	for piece in screen.game.hand:
		assert_object(piece).is_not_null()


func test_a_blocked_level_goes_on_after_an_ad() -> void:
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	Ads.use_backend(fake)
	var runner: GdUnitSceneRunner = await _level(0)
	var screen: LevelScreen = runner.scene() as LevelScreen
	for y in 8:
		for x in 8:
			screen.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	screen.refresh()
	assert_str((runner.find_child("GameOverTitle") as Label).text).is_equal("GAME_OVER")
	assert_bool((runner.find_child("ExtraPiecesButton") as Button).visible).is_false()
	var button: Button = runner.find_child("ContinueButton") as Button
	assert_bool(button.visible).is_true()
	assert_str(button.text).is_equal("BUTTON_CONTINUE_AD")
	button.pressed.emit()
	assert_int(fake.shown).is_equal(1)
	assert_bool(screen.level.is_lost()).is_false()
	assert_bool((runner.find_child("GameOver") as Control).visible).is_false()
	var offers: Dictionary[String, int] = GameState.progress.stats.ad_offers
	assert_int(offers[LevelScreen.LEVEL_CONTINUE_PLACEMENT]).is_equal(1)
	assert_bool(offers.has(TileBlocksScreen.CONTINUE_PLACEMENT)).is_false()


func test_try_again_restarts_the_level_with_the_same_pieces() -> void:
	var runner: GdUnitSceneRunner = await _level(1)
	var screen: LevelScreen = runner.scene() as LevelScreen
	var first_hand: Array[Piece] = screen.game.hand.duplicate()
	screen.game.hand[0] = _single(0)
	screen.refresh()
	await TileBlocksDriver.drag(runner, 0, Vector2i(0, 0))
	(runner.find_child("ReplayButton") as Button).pressed.emit()
	assert_int(screen.level.pieces_left).is_equal(screen.level.definition.pieces)
	for slot in first_hand.size():
		assert_that(screen.game.hand[slot].cells).is_equal(first_hand[slot].cells)
	# A level is not a game of the endless mode.
	assert_int(GameState.progress.stats.games_played).is_equal(0)
