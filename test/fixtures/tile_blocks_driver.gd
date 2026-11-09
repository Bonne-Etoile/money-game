class_name TileBlocksDriver
extends RefCounted
## Plays the tile blocks screen in scenario tests: drags with the simulated pointer, and a lost
## game.


## Simulated mouse events are in window pixels: the window (450 x 800 on desktop) is scaled
## from the 720 x 1280 game screen.
static func on_screen(runner: GdUnitSceneRunner, point: Vector2) -> Vector2:
	return runner.scene().get_viewport().get_screen_transform() * point


## Drags the piece of `slot` from the tray and drops it with its corner on `origin`.
static func drag(runner: GdUnitSceneRunner, slot: int, origin: Vector2i) -> void:
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	var tray: TrayView = runner.find_child("Tray") as TrayView
	var start: Vector2 = tray.slot_center(slot)
	runner.set_mouse_position(on_screen(runner, start))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()
	var target: Vector2 = screen.pointer_for(slot, origin)
	runner.simulate_mouse_move(on_screen(runner, target.lerp(start, 0.5)))
	await runner.await_input_processed()
	runner.simulate_mouse_move(on_screen(runner, target))
	await runner.await_input_processed()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_LEFT)
	await runner.await_input_processed()


## Fills the grid but one corner and leaves a piece of two in the hand: the game is over.
static func lose(screen: TileBlocksScreen) -> void:
	var size: int = screen.game.grid.size
	for y in size:
		for x in size:
			if Vector2i(x, y) != Vector2i(size - 1, size - 1):
				screen.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	var bar: Piece = Piece.new([Vector2i(0, 0), Vector2i(1, 0)], PackedInt32Array([0, 1]))
	screen.game.hand.assign([bar, null, null])
	screen.refresh()
