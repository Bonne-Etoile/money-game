extends GdUnitTestSuite
## The placement shown to a player who hesitates (game/core/move_hint.gd, G15).

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")


func _game() -> TileBlocksGame:
	var game: TileBlocksGame = TileBlocksGame.new(RULES, 1)
	game.hand.assign([null, null, null])
	return game


func test_no_hint_when_nothing_can_clear() -> void:
	var game: TileBlocksGame = _game()
	game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([0]))
	assert_object(MoveHint.find(game)).is_null()


func test_the_hint_completes_a_trio() -> void:
	var game: TileBlocksGame = _game()
	game.grid.set_symbol(Vector2i(2, 3), 1)
	game.grid.set_symbol(Vector2i(3, 3), 1)
	game.hand[2] = Piece.new([Vector2i.ZERO], PackedInt32Array([1]))
	var hint: MoveHint = MoveHint.find(game)
	assert_int(hint.slot).is_equal(2)
	assert_int(hint.cleared).is_equal(3)
	assert_bool(hint.origin in [Vector2i(1, 3), Vector2i(4, 3), Vector2i(2, 2)]).is_true()
	# The hint does not change the game.
	assert_int(game.grid.filled_count()).is_equal(2)


func test_the_hint_may_need_a_turn() -> void:
	var game: TileBlocksGame = _game()
	for y in range(3, 8):
		game.grid.set_symbol(Vector2i(0, y), y % 2)
	# A bar lying flat: it completes the first column only standing up.
	game.hand[0] = Piece.new(
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)], PackedInt32Array([2, 3, 4])
	)
	var hint: MoveHint = MoveHint.find(game)
	assert_int(hint.turns % 2).is_equal(1)
	assert_that(hint.origin).is_equal(Vector2i(0, 0))
	assert_int(hint.cleared).is_equal(8)
	assert_that(hint.piece.extent()).is_equal(Vector2i(1, 3))


func test_the_hint_prefers_the_biggest_clear() -> void:
	var game: TileBlocksGame = _game()
	for x in 7:
		game.grid.set_symbol(Vector2i(x, 6), x % 2)
	game.grid.set_symbol(Vector2i(0, 0), 4)
	game.grid.set_symbol(Vector2i(1, 0), 4)
	game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([4]))
	var hint: MoveHint = MoveHint.find(game)
	assert_that(hint.origin).is_equal(Vector2i(7, 6))
	assert_int(hint.cleared).is_equal(8)
