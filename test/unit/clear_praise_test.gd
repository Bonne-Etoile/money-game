extends GdUnitTestSuite
## How much a move deserves praise (game/core/clear_praise.gd) and the empty-grid bonus (G13).

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")
const THRESHOLDS: Array[int] = [2, 3, 5, 7]


func _result(lines: int, groups: int, combo: int, empty_grid: bool) -> MoveResult:
	var result: MoveResult = MoveResult.new()
	result.clear.lines = lines
	result.clear.groups = groups
	if lines + groups > 0:
		result.clear.cells.append(Vector2i.ZERO)
	result.combo = combo
	result.empty_grid = empty_grid
	return result


func test_nothing_cleared_is_not_praised() -> void:
	assert_int(ClearPraise.strength(_result(0, 0, 0, false), 4)).is_equal(0)
	assert_int(ClearPraise.word(0, THRESHOLDS)).is_equal(0)


func test_one_clear_alone_gets_no_word() -> void:
	var strength: int = ClearPraise.strength(_result(1, 0, 1, false), 4)
	assert_int(strength).is_equal(1)
	assert_int(ClearPraise.word(strength, THRESHOLDS)).is_equal(0)


func _word(result: MoveResult) -> int:
	return ClearPraise.word(ClearPraise.strength(result, 4), THRESHOLDS)


func test_the_word_grows_with_clears_and_combo() -> void:
	assert_int(_word(_result(1, 1, 1, false))).is_equal(1)
	assert_int(_word(_result(2, 1, 3, false))).is_equal(3)
	assert_int(_word(_result(1, 0, 1, true))).is_equal(3)
	assert_int(ClearPraise.word(100, THRESHOLDS)).is_equal(THRESHOLDS.size())


func test_emptying_the_grid_earns_a_bonus() -> void:
	var game: TileBlocksGame = TileBlocksGame.new(RULES, 1)
	for x in 7:
		game.grid.set_symbol(Vector2i(x, 0), x % 2)
	game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([4]))
	var result: MoveResult = game.place(0, Vector2i(7, 0))
	assert_bool(result.empty_grid).is_true()
	assert_int(result.points).is_greater_equal(RULES.scoring.empty_grid_bonus)
	assert_int(game.score()).is_equal(result.points)


func test_a_clear_that_leaves_tiles_earns_no_bonus() -> void:
	var game: TileBlocksGame = TileBlocksGame.new(RULES, 1)
	for x in 7:
		game.grid.set_symbol(Vector2i(x, 0), x % 2)
	game.grid.set_symbol(Vector2i(0, 5), 3)
	game.hand[0] = Piece.new([Vector2i.ZERO], PackedInt32Array([4]))
	assert_bool(game.place(0, Vector2i(7, 0)).empty_grid).is_false()
