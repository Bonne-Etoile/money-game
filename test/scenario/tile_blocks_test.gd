extends GdUnitTestSuite
## Prototype 1 on screen (game/proto_tiles/tile_blocks.tscn): pieces are dragged from the tray
## onto the grid with the pointer (touch is turned into mouse events), clears score, and the
## game-over panel offers to go on after a rewarded ad (a fake one here), or to play again.

const SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"

## Games played by the player of these tests: past a new player's games without ads, and
## past those where a continue is always offered.
const PLAYED: int = 10
## The ad limits themselves (the game turns them all off since 2026-11-12, Stelio: no limit).
const LIMITED: AdPacingRules = preload("res://test/fixtures/limited_ad_pacing.tres")


func before_test() -> void:
	GameState.reset()
	GameState.progress.stats.games_played = PLAYED


func after_test() -> void:
	Options.settings = GameSettings.new()


func _screen() -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	(runner.scene() as TileBlocksScreen).start(1)
	await runner.simulate_frames(2)
	return runner


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


## Simulated mouse events are in window pixels: the window (450 x 800 on desktop) is scaled
## from the 720 x 1280 game screen.
func _on_screen(runner: GdUnitSceneRunner, point: Vector2) -> Vector2:
	return runner.scene().get_viewport().get_screen_transform() * point


## Drags the piece of `slot` from the tray and drops it with its corner on `origin`.
func _drag(runner: GdUnitSceneRunner, slot: int, origin: Vector2i) -> void:
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var tray: TrayView = runner.find_child("Tray") as TrayView
	var start: Vector2 = tray.slot_center(slot)
	runner.set_mouse_position(_on_screen(runner, start))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	var target: Vector2 = screen.pointer_for(slot, origin)
	runner.simulate_mouse_move(_on_screen(runner, target.lerp(start, 0.5)))
	await runner.await_input_processed()
	runner.simulate_mouse_move(_on_screen(runner, target))
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()


func test_dragging_a_piece_completes_a_trio_and_scores() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.grid.set_symbol(Vector2i(2, 4), 1)
	screen.game.grid.set_symbol(Vector2i(3, 4), 1)
	screen.game.hand[1] = _single(1)
	screen.refresh()
	var placed: Piece = screen.game.hand[1]
	await _drag(runner, 1, Vector2i(4, 4))
	assert_object(screen.game.hand[1]).is_not_same(placed)
	assert_int(screen.game.grid.filled_count()).is_equal(0)
	assert_int(screen.game.score()).is_greater(1)
	var score: Label = runner.find_child("ScoreLabel") as Label
	assert_str(score.text).contains(str(screen.game.score()))


func test_a_piece_dropped_on_a_full_cell_goes_back_to_the_tray() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.grid.set_symbol(Vector2i(0, 0), 0)
	screen.game.hand[0] = _single(1)
	screen.refresh()
	await _drag(runner, 0, Vector2i(0, 0))
	assert_object(screen.game.hand[0]).is_not_null()
	assert_int(screen.game.score()).is_equal(0)
	assert_bool((runner.find_child("Board") as BoardView).has_ghost()).is_false()


func _fill_but_corner(screen: TileBlocksScreen) -> void:
	for y in 8:
		for x in 8:
			if Vector2i(x, y) != Vector2i(7, 7):
				screen.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)


## Fills the grid but one corner and leaves a piece of two in the hand: the game is over.
func _lose(screen: TileBlocksScreen) -> void:
	_fill_but_corner(screen)
	var bar: Piece = Piece.new([Vector2i(0, 0), Vector2i(1, 0)], PackedInt32Array([0, 1]))
	screen.game.hand.assign([bar, null, null])
	screen.refresh()


func _fake_ads() -> FakeAdsBackend:
	var fake: FakeAdsBackend = FakeAdsBackend.new()
	Ads.use_backend(fake)
	return fake


func test_game_over_then_play_again() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	_lose(screen)
	var panel: Control = runner.find_child("GameOver") as Control
	assert_bool(panel.visible).is_true()
	(runner.find_child("ReplayButton") as Button).pressed.emit()
	assert_bool(panel.visible).is_false()
	assert_int(screen.game.grid.filled_count()).is_equal(0)


func test_a_watched_ad_lets_the_game_go_on_once() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	_lose(screen)
	var panel: Control = runner.find_child("GameOver") as Control
	var button: Button = runner.find_child("ContinueButton") as Button
	assert_bool(button.visible).is_true()
	assert_bool(button.disabled).is_false()
	button.pressed.emit()
	assert_int(fake.shown).is_equal(1)
	assert_bool(panel.visible).is_false()
	assert_bool(screen.game.is_over()).is_false()
	_lose(screen)
	assert_bool(panel.visible).is_true()
	assert_bool(button.visible).is_false()


func test_an_ad_closed_early_gives_nothing() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	fake.grants_reward = false
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	_lose(screen)
	(runner.find_child("ContinueButton") as Button).pressed.emit()
	assert_int(fake.shown).is_equal(1)
	assert_bool(screen.game.is_over()).is_true()
	assert_bool((runner.find_child("GameOver") as Control).visible).is_true()
	assert_bool(screen.game.can_revive()).is_true()


func test_the_continue_button_waits_for_an_ad() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	fake.ready = false
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	_lose(screen)
	var button: Button = runner.find_child("ContinueButton") as Button
	assert_bool(button.disabled).is_true()
	fake.ready = true
	assert_bool(button.disabled).is_false()


## Pieces come in each of their turns instead (TileBlocksRules.endless_can_rotate): the game
## can be lost. The levels still turn them.
func test_tapping_a_piece_does_not_turn_it_in_the_endless_game() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var bar: Piece = Piece.new(
		[Vector2i(0, 0), Vector2i(1, 0)] as Array[Vector2i], PackedInt32Array([0, 1])
	)
	screen.game.hand[2] = bar
	screen.refresh()
	var tray: TrayView = runner.find_child("Tray") as TrayView
	await Pointer.tap(runner, tray.slot_center(2))
	assert_that(screen.game.hand[2].extent()).is_equal(Vector2i(2, 1))
	assert_int(screen.game.grid.filled_count()).is_equal(0)
	assert_bool((runner.find_child("HintLabel") as Label).visible).is_false()


func test_new_pieces_are_free_once_then_cost_a_watched_ad() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.pacing = LIMITED
	var button: Button = runner.find_child("NewHandButton") as Button
	var first: Piece = screen.game.hand[0]
	button.pressed.emit()
	assert_object(screen.game.hand[0]).is_not_same(first)
	assert_int(fake.shown).is_equal(0)
	assert_str(button.text).is_equal(tr("BONUS_NEW_HAND_AD"))
	var second: Piece = screen.game.hand[0]
	button.pressed.emit()
	assert_int(fake.shown).is_equal(1)
	assert_object(screen.game.hand[0]).is_not_same(second)
	var stats: PlayerStats = GameState.progress.stats
	assert_int(stats.bonuses_used[TileBlocksGame.BONUS_NEW_HAND]).is_equal(2)
	assert_int(stats.ads_watched[TileBlocksScreen.NEW_HAND_PLACEMENT]).is_equal(1)
	# Bonus ads are spaced out: the button says when the next one comes.
	var wait: int = screen.game.pacing.moves_between_bonus_ads
	assert_str(button.text).is_equal(tr("BONUS_NEW_HAND_WAIT") % wait)
	assert_bool(button.disabled).is_true()


func test_an_ad_closed_early_gives_no_bonus() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	fake.grants_reward = false
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.bonus_charges[TileBlocksGame.BONUS_NEW_HAND] = 0
	screen.refresh()
	var piece: Piece = screen.game.hand[0]
	(runner.find_child("NewHandButton") as Button).pressed.emit()
	assert_int(fake.shown).is_equal(1)
	assert_object(screen.game.hand[0]).is_same(piece)


func test_the_mirror_flips_the_next_tapped_piece() -> void:
	_fake_ads()
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var s_shape: Piece = Piece.new(
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)] as Array[Vector2i],
		PackedInt32Array([0, 1, 2, 3])
	)
	screen.game.hand[2] = s_shape
	screen.refresh()
	var button: Button = runner.find_child("MirrorButton") as Button
	button.pressed.emit()
	assert_bool(screen.mirroring).is_true()
	assert_str((runner.find_child("HintLabel") as Label).text).is_equal("HINT_MIRROR")
	var tray: TrayView = runner.find_child("Tray") as TrayView
	await Pointer.tap(runner, tray.slot_center(2))
	assert_that(screen.game.hand[2].cells).is_equal(s_shape.mirrored().cells)
	assert_bool(screen.mirroring).is_false()
	# The next tap does nothing, as usual in the endless game (pieces do not turn).
	await Pointer.tap(runner, tray.slot_center(2))
	assert_that(screen.game.hand[2].cells).is_equal(s_shape.mirrored().cells)


func test_the_mirror_can_be_cancelled_without_using_it() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var button: Button = runner.find_child("MirrorButton") as Button
	button.pressed.emit()
	button.pressed.emit()
	assert_bool(screen.mirroring).is_false()
	var bonus: String = TileBlocksGame.BONUS_MIRROR
	assert_int(screen.game.charges(bonus)).is_equal(screen.rules.bonus_free_uses)


func test_bonuses_call_for_attention_when_pieces_stop_fitting() -> void:
	_fake_ads()
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	assert_bool(screen.is_calling_for_bonuses()).is_false()
	screen.game.bonus_charges[TileBlocksGame.BONUS_NEW_HAND] = 0
	_fill_but_corner(screen)
	# Only a piece of one cell still fits, in the last free corner: in trouble, not over.
	var bar: Piece = Piece.new([Vector2i(0, 0), Vector2i(1, 0)], PackedInt32Array([0, 1]))
	screen.game.hand.assign([bar, _single(0), null])
	screen.refresh()
	assert_bool(screen.is_calling_for_bonuses()).is_true()
	var offers: Dictionary[String, int] = GameState.progress.stats.ad_offers
	assert_int(offers[TileBlocksScreen.NEW_HAND_PLACEMENT]).is_equal(1)
	assert_bool(offers.has(TileBlocksScreen.MIRROR_PLACEMENT)).is_false()
	screen.refresh()
	assert_int(offers[TileBlocksScreen.NEW_HAND_PLACEMENT]).is_equal(1)


func test_game_over_offers_new_pieces_and_shows_the_best_score() -> void:
	_fake_ads()
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.scores.score = 42
	_lose(screen)
	var button: Button = runner.find_child("GameOverNewHandButton") as Button
	assert_bool(button.visible).is_true()
	var best: Label = runner.find_child("BestScoreLabel") as Label
	assert_str(best.text).contains("42")
	assert_int(GameState.progress.stats.ad_offers[TileBlocksScreen.CONTINUE_PLACEMENT]).is_equal(1)


func test_a_game_left_for_a_new_one_counts_as_played() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.hand[0] = _single(0)
	screen.game.place(0, Vector2i(0, 0))
	screen.start(2)
	screen.start(3)
	assert_int(GameState.progress.stats.games_played).is_equal(PLAYED + 1)
	assert_int(GameState.progress.stats.total_moves).is_equal(1)


func test_a_new_player_is_offered_no_ad_but_free_bonuses() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	GameState.progress.stats.games_played = 0
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.pacing = LIMITED
	screen.refresh()
	var button: Button = runner.find_child("NewHandButton") as Button
	button.pressed.emit()
	assert_int(fake.shown).is_equal(0)
	assert_str(button.text).is_equal(tr("BONUS_NEW_HAND") % 0)
	assert_bool(button.disabled).is_true()
	button.pressed.emit()
	assert_int(fake.shown).is_equal(0)
	_lose(screen)
	assert_bool((runner.find_child("GameOver") as Control).visible).is_true()
	assert_bool((runner.find_child("ContinueButton") as Button).visible).is_false()
	assert_bool(GameState.progress.stats.ad_offers.is_empty()).is_true()


func test_the_continue_is_offered_only_close_enough_to_the_record() -> void:
	_fake_ads()
	GameState.progress.stats.best_score = 1000
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var button: Button = runner.find_child("ContinueButton") as Button
	screen.game.scores.score = 100
	_lose(screen)
	assert_bool(button.visible).is_false()
	screen.game.scores.score = 1000 * screen.rules.ad_pacing.revive_min_record_percent / 100
	screen.refresh()
	assert_bool(button.visible).is_true()


func test_no_ad_is_offered_beyond_the_daily_limit() -> void:
	var fake: FakeAdsBackend = _fake_ads()
	GameState.day_override = 400
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.game.pacing = LIMITED
	for _ad in screen.game.pacing.rewarded_per_day:
		GameState.progress.stats.count_rewarded(400)
	screen.game.bonus_charges[TileBlocksGame.BONUS_NEW_HAND] = 0
	_lose(screen)
	assert_bool((runner.find_child("ContinueButton") as Button).visible).is_false()
	assert_bool((runner.find_child("NewHandButton") as Button).disabled).is_true()
	(runner.find_child("NewHandButton") as Button).pressed.emit()
	assert_int(fake.shown).is_equal(0)


func test_the_mirror_lights_up_when_its_flip_opens_a_great_move() -> void:
	_fake_ads()
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var setup: TileBlocksGame = MirrorChanceSetup.z_hole_game()
	screen.game.grid = setup.grid
	(runner.find_child("Board") as BoardView).grid = setup.grid
	# Pieces of one cell beside the S: they fit, so the player is not in trouble.
	screen.game.hand.assign([setup.hand[0], _single(0), _single(1)])
	screen.game.bonus_charges[TileBlocksGame.BONUS_MIRROR] = 0
	screen.refresh()
	assert_object(screen.mirror_chance).is_not_null()
	assert_bool((runner.find_child("Board") as BoardView).has_hint()).is_true()
	var mirror: Button = runner.find_child("MirrorButton") as Button
	assert_that(screen.called_buttons()).is_equal([mirror] as Array[Button])
	var offers: Dictionary[String, int] = GameState.progress.stats.ad_offers
	assert_int(offers[TileBlocksScreen.MIRROR_PLACEMENT]).is_equal(1)
	screen.refresh()
	assert_int(offers[TileBlocksScreen.MIRROR_PLACEMENT]).is_equal(1)
	# Without a way to use the mirror (no use left, no ad to buy one), nothing shows.
	screen.game.pacing = LIMITED
	screen.game.ads_used = screen.game.pacing.ads_per_game
	screen.refresh()
	assert_object(screen.mirror_chance).is_null()
	assert_bool((runner.find_child("Board") as BoardView).has_hint()).is_false()
	assert_bool(screen.is_calling_for_bonuses()).is_false()
