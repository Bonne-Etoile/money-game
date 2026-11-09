extends GdUnitTestSuite
## The "stamp" prototype (G7): the pile of columns (game/core/stamp_pile.gd) and the game
## (game/core/stamp_game.gd).

const RULES: StampRules = preload("res://game/data/stamp_rules.tres")
const SQUARE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]


func _level(heights: Array[String]) -> StampLevel:
	var level: StampLevel = StampLevel.new()
	level.heights = heights
	return level


func test_a_stamp_takes_the_top_tile_under_each_cell() -> void:
	var pile: StampPile = StampPile.new(3)
	pile.push(Vector2i(0, 0), 1)
	pile.push(Vector2i(0, 0), 2)
	pile.push(Vector2i(1, 0), 3)
	var bar: Piece = Piece.uniform([Vector2i(0, 0), Vector2i(1, 0)], StampGame.BLANK)
	assert_bool(pile.can_stamp(bar, Vector2i(1, 0))).is_false()
	var piece: Piece = pile.stamp(bar, Vector2i(0, 0))
	assert_that(piece.symbols).is_equal(PackedInt32Array([2, 3]))
	assert_int(pile.height(Vector2i(0, 0))).is_equal(1)
	assert_int(pile.top_symbol(Vector2i(0, 0))).is_equal(1)
	assert_int(pile.top_symbol(Vector2i(1, 0))).is_equal(TileGrid.EMPTY)
	assert_bool(pile.can_stamp(bar, Vector2i(0, 0))).is_false()
	assert_int(pile.remaining()).is_equal(1)


func test_the_level_fills_the_pile_column_by_column() -> void:
	var game: StampGame = StampGame.new(RULES, _level(["12", "03"]), 1)
	assert_int(game.pile.remaining()).is_equal(6)
	assert_int(game.pile.height(Vector2i(1, 1))).is_equal(3)
	assert_int(game.pile.height(Vector2i(0, 1))).is_equal(0)


func test_stamp_then_place_then_the_next_shape_comes() -> void:
	var game: StampGame = StampGame.new(RULES, _level(["2222", "2222"]), 4)
	game.queue[0] = Piece.uniform(SQUARE, StampGame.BLANK)
	var upcoming: Piece = game.queue[1]
	assert_object(game.stamp(Vector2i(0, 0))).is_not_null()
	assert_int(game.hand[0].cells.size()).is_equal(4)
	assert_object(game.queue[0]).is_same(upcoming)
	assert_object(game.current_shape()).is_null()
	assert_object(game.stamp(Vector2i(2, 0))).is_null()
	# The piece may hold a trio picked from the pile: it then clears at once.
	var result: MoveResult = game.place(0, Vector2i(3, 3))
	assert_int(result.placed.size()).is_equal(4)
	assert_int(game.grid.filled_count()).is_equal(4 - result.clear.cells.size())
	assert_int(game.pile.remaining()).is_equal(12)


func test_a_shape_that_fits_nowhere_is_replaced_by_a_smaller_one() -> void:
	var game: StampGame = StampGame.new(RULES, _level(["1.1", "...", "1.."]), 2)
	assert_int(game.current_shape().cells.size()).is_equal(1)


func test_won_when_the_pile_is_empty_and_the_piece_placed() -> void:
	var game: StampGame = StampGame.new(RULES, _level(["11", "11"]), 3)
	game.queue[0] = Piece.uniform(SQUARE, StampGame.BLANK)
	game.stamp(Vector2i(0, 0))
	assert_bool(game.is_won()).is_false()
	game.place(0, Vector2i(0, 0))
	assert_bool(game.is_won()).is_true()


func test_lost_when_the_piece_in_hand_fits_nowhere() -> void:
	var game: StampGame = StampGame.new(RULES, _level(["11", "11"]), 3)
	for y in 8:
		for x in 8:
			if (x + y) % 2 == 0:
				game.grid.set_symbol(Vector2i(x, y), x % 4)
	game.queue[0] = Piece.uniform(SQUARE, StampGame.BLANK)
	game.stamp(Vector2i(0, 0))
	assert_bool(game.is_lost()).is_true()


## Each level can be won: a greedy robot wins them all, whatever the seed of the shapes.
func test_every_level_can_be_won() -> void:
	for index in RULES.levels.size():
		for random_seed in 3:
			var game: StampGame = StampGame.new(RULES, RULES.levels[index], random_seed)
			for _move in 200:
				if game.is_won() or game.is_lost() or not _play_greedy(game):
					break
			(
				assert_bool(game.is_won())
				. override_failure_message("level %d, seed %d" % [index + 1, random_seed])
				. is_true()
			)


func _play_greedy(game: StampGame) -> bool:
	var best: int = -1
	var best_stamp: Vector2i = Vector2i.ZERO
	var best_place: Vector2i = Vector2i.ZERO
	var shape: Piece = game.current_shape()
	for sy in game.pile.size:
		for sx in game.pile.size:
			if not game.pile.can_stamp(shape, Vector2i(sx, sy)):
				continue
			var symbols: PackedInt32Array = []
			for cell in shape.cells:
				symbols.append(game.pile.top_symbol(Vector2i(sx, sy) + cell))
			var piece: Piece = Piece.new(shape.cells, symbols)
			for y in game.grid.size:
				for x in game.grid.size:
					var value: int = GridRobot.value(
						game.grid, piece, Vector2i(x, y), RULES.match_size
					)
					if value > best:
						best = value
						best_stamp = Vector2i(sx, sy)
						best_place = Vector2i(x, y)
	if best < 0:
		return false
	game.stamp(best_stamp)
	return game.place(0, best_place) != null
