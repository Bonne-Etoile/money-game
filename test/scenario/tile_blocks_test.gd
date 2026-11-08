extends GdUnitTestSuite
## Prototype 1 on screen (game/proto_tiles/tile_blocks.tscn): pieces are dragged from the tray
## onto the grid with the pointer (touch is turned into mouse events), clears score, and the
## game-over panel offers to play again.

const SCENE: String = "res://game/proto_tiles/tile_blocks.tscn"


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
	await _drag(runner, 1, Vector2i(4, 4))
	assert_object(screen.game.hand[1]).is_null()
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


func test_game_over_then_play_again() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	for y in 8:
		for x in 8:
			if Vector2i(x, y) != Vector2i(7, 7):
				screen.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	var bar: Piece = Piece.new([Vector2i(0, 0), Vector2i(1, 0)], PackedInt32Array([0, 1]))
	screen.game.hand.assign([bar, null, null])
	screen.refresh()
	var panel: Control = runner.find_child("GameOver") as Control
	assert_bool(panel.visible).is_true()
	(runner.find_child("ReplayButton") as Button).pressed.emit()
	assert_bool(panel.visible).is_false()
	assert_int(screen.game.grid.filled_count()).is_equal(0)
