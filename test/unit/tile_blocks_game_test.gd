extends GdUnitTestSuite
## Prototype 1, "tile blocks" (game/core/tile_blocks_game.gd).

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")


func _game() -> TileBlocksGame:
	return TileBlocksGame.new(RULES, 1)


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func test_a_new_game_offers_a_full_hand() -> void:
	var game: TileBlocksGame = _game()
	assert_int(game.hand.size()).is_equal(RULES.hand_size)
	assert_int(game.score()).is_equal(0)
	assert_bool(game.is_over()).is_false()


func test_a_placed_piece_is_replaced_at_once_and_scores() -> void:
	var game: TileBlocksGame = _game()
	var placed: Piece = _single(0)
	game.hand[0] = placed
	var result: MoveResult = game.place(0, Vector2i(3, 3))
	assert_object(result).is_not_null()
	assert_that(result.placed).is_equal([Vector2i(3, 3)] as Array[Vector2i])
	assert_object(game.hand[0]).is_not_null()
	assert_object(game.hand[0]).is_not_same(placed)
	assert_int(game.score()).is_equal(RULES.scoring.points_per_cell_placed)


func test_three_identical_symbols_clear() -> void:
	var game: TileBlocksGame = _game()
	game.grid.set_symbol(Vector2i(0, 0), 2)
	game.grid.set_symbol(Vector2i(1, 0), 2)
	game.hand[1] = _single(2)
	var result: MoveResult = game.place(1, Vector2i(2, 0))
	assert_int(result.clear.groups).is_equal(1)
	assert_that(result.cleared_symbols).is_equal(PackedInt32Array([2, 2, 2]))
	assert_int(game.grid.filled_count()).is_equal(0)
	assert_int(result.combo).is_equal(1)


func test_a_full_row_clears() -> void:
	var game: TileBlocksGame = _game()
	for x in 7:
		game.grid.set_symbol(Vector2i(x, 5), x % 2)
	game.hand[0] = _single(3)
	var result: MoveResult = game.place(0, Vector2i(7, 5))
	assert_int(result.clear.lines).is_equal(1)
	assert_int(game.grid.filled_count()).is_equal(0)


func test_without_refill_each_slot_the_hand_is_refilled_once_empty() -> void:
	var rules: TileBlocksRules = RULES.duplicate()
	rules.refill_each_slot = false
	var game: TileBlocksGame = TileBlocksGame.new(rules, 1)
	for slot in game.hand.size():
		game.hand[slot] = _single(slot)
	game.place(0, Vector2i(0, 0))
	game.place(1, Vector2i(2, 2))
	assert_object(game.hand[0]).is_null()
	game.place(2, Vector2i(4, 4))
	for piece in game.hand:
		assert_object(piece).is_not_null()


func test_over_when_no_piece_fits() -> void:
	var game: TileBlocksGame = _game()
	# A checkerboard of two symbols: no line, no group, one free cell.
	for y in 8:
		for x in 8:
			if Vector2i(x, y) != Vector2i(7, 7):
				game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	var bar: Piece = Piece.new([Vector2i(0, 0), Vector2i(1, 0)], PackedInt32Array([0, 1]))
	game.hand.assign([bar, null, null])
	assert_bool(game.is_over()).is_true()
	game.hand[1] = _single(2)
	assert_bool(game.is_over()).is_false()


## Fills the whole grid with alternating symbols (no trio, no full line is cleared by this).
func _fill(game: TileBlocksGame) -> void:
	for y in game.grid.size:
		for x in game.grid.size:
			game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)


func test_a_game_still_going_cannot_be_revived() -> void:
	var game: TileBlocksGame = _game()
	assert_bool(game.can_revive()).is_false()
	assert_bool(game.revive()).is_false()
	assert_int(game.revives_used).is_equal(0)


func test_a_revive_clears_a_cross_so_that_every_shape_fits() -> void:
	var game: TileBlocksGame = _game()
	_fill(game)
	assert_bool(game.is_over()).is_true()
	assert_bool(game.can_revive()).is_true()
	var score: int = game.score()
	assert_bool(game.revive()).is_true()
	var lines: int = RULES.revive_clear_lines
	var size: int = RULES.grid_size
	var expected_empty: int = 2 * lines * size - lines * lines
	assert_int(game.grid.filled_count()).is_equal(size * size - expected_empty)
	assert_int(game.score()).is_equal(score)
	for shape in RULES.shape_set.shapes:
		var symbols: PackedInt32Array = PackedInt32Array()
		symbols.resize(shape.cells.size())
		assert_bool(game.grid.fits_anywhere(Piece.new(shape.cells, symbols))).is_true()
	assert_bool(game.is_over()).is_false()


func test_revives_are_limited_per_game() -> void:
	var game: TileBlocksGame = _game()
	for _revive in RULES.revives_per_game:
		_fill(game)
		assert_bool(game.revive()).is_true()
	_fill(game)
	assert_bool(game.is_over()).is_true()
	assert_bool(game.can_revive()).is_false()
	assert_bool(game.revive()).is_false()


func test_the_pieces_are_the_seven_tetris_shapes() -> void:
	var game: TileBlocksGame = _game()
	var seen: Dictionary[String, bool] = {}
	for _move in 60:
		for slot in game.hand.size():
			seen[str(game.hand[slot].cells)] = true
		game.hand[0] = _single(0)
		game.place(0, Vector2i(7, 7))
		game.grid.remove([Vector2i(7, 7)] as Array[Vector2i])
	assert_int(seen.size()).is_equal(RULES.shape_keys.size())
	for key in RULES.shape_keys:
		assert_int(RULES.shape_set.find(key).cells.size()).is_equal(4)


func test_a_tap_turns_a_piece_a_quarter_turn() -> void:
	var game: TileBlocksGame = _game()
	var bar: Piece = Piece.new(
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)] as Array[Vector2i],
		PackedInt32Array([0, 1, 2])
	)
	game.hand[0] = bar
	assert_bool(game.rotate(0)).is_true()
	assert_that(game.hand[0].cells).is_equal(
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)] as Array[Vector2i]
	)
	assert_that(game.hand[0].symbols).is_equal(PackedInt32Array([0, 1, 2]))
	var ell: Piece = Piece.new(
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)] as Array[Vector2i],
		PackedInt32Array([3, 4, 0])
	)
	# Four quarter turns bring a piece back as it was.
	var turned: Piece = ell
	for _turn in 4:
		turned = turned.rotated()
	assert_that(turned.cells).is_equal(ell.cells)


func test_a_piece_that_fits_only_turned_does_not_end_the_game() -> void:
	var game: TileBlocksGame = _game()
	# Only a vertical gap of 3 cells is left in the last column.
	for y in 8:
		for x in 8:
			if not (x == 7 and y < 3):
				game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	var bar: Piece = Piece.new(
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)] as Array[Vector2i],
		PackedInt32Array([0, 1, 0])
	)
	game.hand.assign([bar, null, null])
	assert_bool(game.is_over()).is_false()
	var rules: TileBlocksRules = RULES.duplicate()
	rules.can_rotate = false
	game.rules = rules
	assert_bool(game.is_over()).is_true()
