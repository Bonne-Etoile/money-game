extends GdUnitTestSuite
## Prototype 2 on screen (game/proto_pyramid/pyramid.tscn): tap a free tile of the pile, drag
## its piece onto the grid, and the end-of-level panel.

const SCENE: String = "res://game/proto_pyramid/pyramid.tscn"


func _screen() -> GdUnitSceneRunner:
	var runner: GdUnitSceneRunner = scene_runner(SCENE)
	await runner.simulate_frames(2)
	return runner


## Simulated mouse events are in window pixels (the window is scaled from the game screen).
func _on_screen(runner: GdUnitSceneRunner, point: Vector2) -> Vector2:
	return runner.scene().get_viewport().get_screen_transform() * point


func _tap(runner: GdUnitSceneRunner, point: Vector2) -> void:
	runner.set_mouse_position(_on_screen(runner, point))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()


func _drag(runner: GdUnitSceneRunner, slot: int, origin: Vector2i) -> void:
	var screen: PyramidScreen = runner.scene() as PyramidScreen
	var start: Vector2 = (runner.find_child("Tray") as TrayView).slot_center(slot)
	var target: Vector2 = screen.pointer_for(slot, origin)
	runner.set_mouse_position(_on_screen(runner, start))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	runner.simulate_mouse_move(_on_screen(runner, target.lerp(start, 0.5)))
	await runner.await_input_processed()
	runner.simulate_mouse_move(_on_screen(runner, target))
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()


func test_tapping_a_free_tile_puts_its_piece_in_the_tray() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: PyramidScreen = runner.scene() as PyramidScreen
	var stack: StackView = runner.find_child("Stack") as StackView
	var stack_logic: TileStack = screen.game.stack
	# Upper tiles out of the way: a tile blocked only by its neighbours is not hidden.
	for tile in stack_logic.tiles:
		tile.removed = tile.layer > 0
	screen.refresh()
	var blocked: int = -1
	for index in stack_logic.tiles.size():
		if blocked < 0 and not stack_logic.is_free(index):
			blocked = index
	var before: int = stack_logic.remaining()
	await _tap(runner, stack.tile_center(blocked))
	assert_int(screen.game.stack.remaining()).is_equal(before)
	var free: int = screen.game.stack.free_tiles()[0]
	await _tap(runner, stack.tile_center(free))
	assert_int(screen.game.stack.remaining()).is_equal(before - 1)
	assert_object(screen.game.tray[0]).is_same(screen.game.stack.tiles[free].piece)


func test_a_taken_piece_is_dragged_onto_the_grid() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: PyramidScreen = runner.scene() as PyramidScreen
	var free: int = screen.game.stack.free_tiles()[0]
	screen.take(free)
	var cells: int = screen.game.tray[0].cells.size()
	await _drag(runner, 0, Vector2i(2, 2))
	assert_object(screen.game.tray[0]).is_null()
	assert_int(screen.game.grid.filled_count()).is_equal(cells)
	assert_str((runner.find_child("ScoreLabel") as Label).text).contains(str(cells))


func test_emptying_the_pile_wins_and_opens_the_next_level() -> void:
	var runner: GdUnitSceneRunner = await _screen()
	var screen: PyramidScreen = runner.scene() as PyramidScreen
	# Play the first level with a simple robot: take a free tile, place it where it fits.
	for _move in 100:
		if screen.game.is_won() or screen.game.is_lost():
			break
		screen.take(screen.game.stack.free_tiles()[0])
		var piece: Piece = screen.game.tray[0]
		for y in 8:
			if screen.game.tray[0] == null:
				break
			for x in 8:
				if screen.game.place(0, Vector2i(x, y)) != null:
					break
		(
			assert_object(screen.game.tray[0])
			. override_failure_message("no room for %s" % piece.cells)
			. is_null()
		)
	screen.refresh()
	assert_bool(screen.game.is_won()).is_true()
	assert_bool((runner.find_child("EndPanel") as Control).visible).is_true()
	var next: Button = runner.find_child("NextButton") as Button
	assert_bool(next.visible).is_true()
	next.pressed.emit()
	assert_int(screen.level_index).is_equal(1)
	assert_bool((runner.find_child("EndPanel") as Control).visible).is_false()
