extends GdUnitTestSuite
## Prototypes 3 to 5 on screen (G5, G6, G7): tiles on a small grid, pairs, and the stamp on
## the pile, played with the simulated pointer.

const TRAY_GRID: String = "res://game/proto_tray_grid/tray_grid.tscn"
const PAIRS: String = "res://game/proto_pairs/pairs.tscn"
const STAMP: String = "res://game/proto_stamp/stamp.tscn"
const SQUARE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]


func test_pairs_clear_two_identical_symbols() -> void:
	var runner: GdUnitSceneRunner = scene_runner(PAIRS)
	var screen: TileBlocksScreen = runner.scene() as TileBlocksScreen
	screen.start(1)
	await runner.simulate_frames(2)
	screen.game.grid.set_symbol(Vector2i(2, 2), 4)
	screen.game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([4]))
	screen.refresh()
	var tray: TrayView = runner.find_child("Tray") as TrayView
	await Pointer.drag(runner, tray.slot_center(0), screen.pointer_for(0, Vector2i(3, 2)))
	assert_int(screen.game.grid.filled_count()).is_equal(0)
	assert_int(screen.game.rules.match_size).is_equal(2)


func test_a_tile_of_the_pile_goes_on_the_small_grid() -> void:
	var runner: GdUnitSceneRunner = scene_runner(TRAY_GRID)
	await runner.simulate_frames(2)
	var screen: PyramidScreen = runner.scene() as PyramidScreen
	assert_int(screen.game.grid.size).is_equal(5)
	var stack: StackView = runner.find_child("Stack") as StackView
	await Pointer.tap(runner, stack.tile_center(screen.game.stack.free_tiles()[0]))
	assert_object(screen.game.tray[0]).is_not_null()
	var tray: TrayView = runner.find_child("Tray") as TrayView
	await Pointer.drag(runner, tray.slot_center(0), screen.pointer_for(0, Vector2i(2, 2)))
	assert_object(screen.game.tray[0]).is_null()
	assert_bool(screen.game.grid.is_empty_cell(Vector2i(2, 2))).is_false()


func test_stamp_a_shape_on_the_pile_then_place_its_tiles() -> void:
	var runner: GdUnitSceneRunner = scene_runner(STAMP)
	var screen: StampScreen = runner.scene() as StampScreen
	screen.shape_seed = 1
	screen.start_level(0)
	screen.game.queue[0] = Piece.uniform(SQUARE, StampGame.BLANK)
	screen.refresh()
	await runner.simulate_frames(2)
	var before: int = screen.game.pile.remaining()
	var shapes: TrayView = runner.find_child("ShapeTray") as TrayView
	await Pointer.drag(runner, shapes.slot_center(0), screen.pointer_for_stamp(Vector2i(1, 0)))
	assert_int(screen.game.pile.remaining()).is_equal(before - 4)
	assert_object(screen.game.hand[0]).is_not_null()
	var hand: TrayView = runner.find_child("Hand") as TrayView
	await Pointer.drag(runner, hand.slot_center(0), screen.pointer_for_place(Vector2i(0, 6)))
	assert_object(screen.game.hand[0]).is_null()
	assert_int(screen.game.score()).is_greater_equal(4)
