extends GdUnitTestSuite
## Difficulty in both directions and the playability guarantee (TileBlocksGame with
## DifficultyDirector, G11).

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func _room_of_new_pieces(game: TileBlocksGame) -> int:
	for y in 4:
		for x in 8:
			if (x + y) % 3 != 0:
				game.grid.set_symbol(Vector2i(x, y), (x * 7 + y) % 5)
	var total: int = 0
	for _draw in 60:
		game.hand[0] = _single(0)
		game.place(0, Vector2i(0, 7))
		game.grid.set_symbol(Vector2i(0, 7), TileGrid.EMPTY)
		total += PieceGenerator.room(game.grid, game.hand[0], true)
	return total


func test_a_struggling_player_gets_pieces_with_more_room() -> void:
	var helped: TileBlocksGame = TileBlocksGame.new(RULES, 7, PlayerStats.new())
	assert_int(helped.level()).is_less(0)
	var chance_room: int = _room_of_new_pieces(TileBlocksGame.new(RULES, 7))
	assert_int(_room_of_new_pieces(helped)).is_greater(chance_room)


## Fills the grid but 2 x 2 holes, a few cells apart: only the square (and nothing longer)
## fits, half the grid is free.
func _square_holes_only(game: TileBlocksGame) -> void:
	for y in 8:
		for x in 8:
			var in_hole: bool = (x % 4) < 2 and (y % 4) < 2
			var symbol: int = TileGrid.EMPTY if in_hole else (x * 3 + y * 5 + (x / 2) * 2) % 5
			game.grid.set_symbol(Vector2i(x, y), symbol)


func test_a_new_hand_always_has_a_piece_that_fits_while_the_grid_has_room() -> void:
	for random_seed in 40:
		var game: TileBlocksGame = TileBlocksGame.new(RULES, random_seed)
		_square_holes_only(game)
		assert_int(game.grid.filled_count()).is_equal(48)
		var rules: DifficultyRules = RULES.difficulty.duplicate()
		rules.playable_until_fill_percent = 80
		game.difficulty.rules = rules
		game.deal_hand()
		assert_bool(game.is_over()).override_failure_message("seed %d" % random_seed).is_false()


func test_beyond_the_fill_threshold_a_hand_may_leave_no_move() -> void:
	var lost: int = 0
	for random_seed in 40:
		var game: TileBlocksGame = TileBlocksGame.new(RULES, random_seed)
		_square_holes_only(game)
		var rules: DifficultyRules = RULES.difficulty.duplicate()
		rules.playable_until_fill_percent = 50
		game.difficulty.rules = rules
		game.deal_hand()
		if game.is_over():
			lost += 1
	assert_int(lost).is_greater(0)


func test_a_new_piece_after_a_move_keeps_the_game_playable() -> void:
	for random_seed in 20:
		var game: TileBlocksGame = TileBlocksGame.new(RULES, random_seed)
		_square_holes_only(game)
		game.grid.set_symbol(Vector2i(0, 0), TileGrid.EMPTY)
		var rules: DifficultyRules = RULES.difficulty.duplicate()
		rules.playable_until_fill_percent = 80
		game.difficulty.rules = rules
		# Only singles that cannot fit in the hand but one: once it is placed, the new piece
		# must fit.
		var blocker: Piece = Piece.new(
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
			PackedInt32Array([0, 1, 0, 1])
		)
		game.hand.assign([_single(4), blocker, blocker])
		game.place(0, Vector2i(0, 0))
		assert_bool(game.is_over()).override_failure_message("seed %d" % random_seed).is_false()
