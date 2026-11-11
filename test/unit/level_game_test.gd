extends GdUnitTestSuite
## The level mode (game/core/level_game.gd, level_board.gd, G17): starting grids, goals, gold,
## ice, stones, limited pieces, extra pieces, and every level won by a simple robot.

const RULES: TileBlocksRules = preload("res://game/data/tile_blocks_rules.tres")
const LEVELS: LevelSet = preload("res://game/data/levels.tres")


func _level(rows: Array[String], goal: LevelDefinition.Goal, count: int) -> LevelGame:
	var definition: LevelDefinition = LevelDefinition.new()
	definition.rows = rows
	definition.goal = goal
	definition.goal_count = count
	definition.goal_symbol = 4
	definition.pieces = 3
	return LevelGame.new(definition, RULES, LEVELS)


func _single(symbol: int) -> Piece:
	return Piece.new([Vector2i.ZERO], PackedInt32Array([symbol]))


func test_every_level_can_be_won_by_a_simple_robot() -> void:
	assert_int(LEVELS.levels.size()).is_greater_equal(10)
	for index in LEVELS.levels.size():
		var level: LevelGame = LevelGame.new(LEVELS.levels[index], RULES, LEVELS)
		var won: bool = LevelRobot.play(level)
		prints("level", index + 1, "won:", won, "pieces left:", level.pieces_left)
		assert_bool(won).override_failure_message("level %d" % (index + 1)).is_true()


func test_the_starting_grid_holds_tiles_gold_ice_and_stones() -> void:
	var level: LevelGame = _level(["0a#B...."], LevelDefinition.Goal.GOLD, 0)
	var grid: TileGrid = level.game.grid
	assert_int(grid.symbol_at(Vector2i(0, 0))).is_equal(0)
	assert_int(grid.symbol_at(Vector2i(1, 0))).is_equal(0)
	assert_bool(level.game.layer.is_gold(Vector2i(1, 0))).is_true()
	assert_int(grid.symbol_at(Vector2i(2, 0))).is_equal(TileGrid.STONE)
	assert_int(grid.symbol_at(Vector2i(3, 0))).is_equal(1)
	assert_bool(level.game.layer.has_ice(Vector2i(3, 0))).is_true()
	assert_int(level.target()).is_equal(1)


func test_a_gold_tile_is_freed_by_a_trio() -> void:
	var level: LevelGame = _level(["a0......"], LevelDefinition.Goal.GOLD, 0)
	level.game.hand[0] = _single(0)
	level.place(0, Vector2i(2, 0))
	assert_int(level.game.layer.gold_freed).is_equal(1)
	assert_bool(level.is_won()).is_true()


func test_a_stone_goes_only_with_a_full_line() -> void:
	var level: LevelGame = _level(["#33.....", "1010101."], LevelDefinition.Goal.SCORE, 1000)
	# A trio of diamonds next to the stone: the stone stays.
	level.game.hand[0] = _single(3)
	level.place(0, Vector2i(3, 0))
	assert_int(level.game.grid.symbol_at(Vector2i(0, 0))).is_equal(TileGrid.STONE)
	assert_int(level.game.grid.symbol_at(Vector2i(1, 0))).is_equal(TileGrid.EMPTY)
	# A full column takes it away.
	for y in range(2, 8):
		level.game.grid.set_symbol(Vector2i(0, y), y % 2 + 2)
	level.game.grid.set_symbol(Vector2i(0, 1), TileGrid.EMPTY)
	level.game.hand[1] = _single(4)
	level.place(1, Vector2i(0, 1))
	assert_int(level.game.grid.symbol_at(Vector2i(0, 0))).is_equal(TileGrid.EMPTY)


func test_a_tile_under_ice_needs_two_clears() -> void:
	var level: LevelGame = _level(["A0......"], LevelDefinition.Goal.SCORE, 1000)
	level.game.hand[0] = _single(0)
	level.place(0, Vector2i(2, 0))
	assert_bool(level.game.layer.has_ice(Vector2i(0, 0))).is_false()
	assert_int(level.game.grid.symbol_at(Vector2i(0, 0))).is_equal(0)
	assert_int(level.game.grid.symbol_at(Vector2i(1, 0))).is_equal(TileGrid.EMPTY)
	level.game.hand[1] = _single(0)
	level.place(1, Vector2i(1, 0))
	level.game.hand[2] = _single(0)
	level.place(2, Vector2i(2, 0))
	assert_int(level.game.grid.symbol_at(Vector2i(0, 0))).is_equal(TileGrid.EMPTY)


func test_trios_of_the_goal_symbol_are_counted() -> void:
	var level: LevelGame = _level(["44..00.."], LevelDefinition.Goal.TRIOS, 1)
	level.game.hand[0] = _single(0)
	level.place(0, Vector2i(6, 0))
	assert_int(level.trios).is_equal(0)
	level.game.hand[0] = _single(4)
	level.place(0, Vector2i(2, 0))
	assert_int(level.trios).is_equal(1)
	assert_bool(level.is_won()).is_true()


func test_the_level_is_lost_when_the_pieces_run_out_then_more_can_be_given() -> void:
	var level: LevelGame = _level([], LevelDefinition.Goal.SCORE, 100000)
	for move in 3:
		level.game.hand[0] = _single(move % 2)
		assert_object(level.place(0, Vector2i(move * 2, 4))).is_not_null()
	assert_int(level.pieces_left).is_equal(0)
	assert_bool(level.is_lost()).is_true()
	level.game.hand[0] = _single(0)
	assert_object(level.place(0, Vector2i(0, 0))).is_null()
	for _ad in LEVELS.extra_pieces_ads:
		assert_bool(level.can_add_pieces()).is_true()
		assert_bool(level.add_pieces()).is_true()
		assert_int(level.pieces_left).is_equal(LEVELS.extra_pieces)
		assert_bool(level.is_lost()).is_false()
		level.pieces_left = 0
	assert_bool(level.can_add_pieces()).is_false()


func test_the_hand_never_shows_more_pieces_than_are_left() -> void:
	var level: LevelGame = _level([], LevelDefinition.Goal.SCORE, 100000)
	level.pieces_left = 3
	level.game.pieces_cap = 3
	for left: int in [2, 1, 0]:
		var slot: int = level.game.hand.find_custom(
			func(piece: Piece) -> bool: return piece != null
		)
		level.game.hand[slot] = _single(left % 2)
		assert_object(level.place(slot, Vector2i(left * 2, 4))).is_not_null()
		var shown: int = (
			level.game.hand.filter(func(piece: Piece) -> bool: return piece != null).size()
		)
		assert_int(shown).is_equal(left)
	level.add_pieces()
	var refilled: int = (
		level.game.hand.filter(func(piece: Piece) -> bool: return piece != null).size()
	)
	assert_int(refilled).is_equal(RULES.hand_size)


func test_a_blocked_level_goes_on_once_after_an_ad() -> void:
	var level: LevelGame = _level([], LevelDefinition.Goal.SCORE, 100000)
	assert_bool(level.can_revive()).is_false()
	for y in level.game.grid.size:
		for x in level.game.grid.size:
			level.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	assert_bool(level.is_lost()).is_true()
	assert_bool(level.can_add_pieces()).is_false()
	assert_bool(level.can_revive()).is_true()
	assert_bool(level.revive()).is_true()
	assert_bool(level.is_lost()).is_false()
	assert_int(level.game.ads_used).is_equal(1)
	for y in level.game.grid.size:
		for x in level.game.grid.size:
			level.game.grid.set_symbol(Vector2i(x, y), (x + y) % 2)
	assert_bool(level.can_revive()).is_false()


func test_the_ads_of_an_attempt_count_together() -> void:
	var level: LevelGame = _level([], LevelDefinition.Goal.SCORE, 100000)
	var limit: int = level.game.pacing.ads_per_game
	level.game.ads_used = limit - 1
	level.pieces_left = 0
	assert_bool(level.add_pieces()).is_true()
	level.pieces_left = 0
	assert_bool(level.can_add_pieces()).is_false()
	assert_bool(level.add_pieces()).is_false()


func test_levels_won_are_saved_and_a_version_3_save_is_migrated() -> void:
	var stats: PlayerStats = PlayerStats.new()
	stats.win_level(2)
	stats.win_level(0)
	assert_int(stats.levels_won).is_equal(3)
	assert_int(PlayerStats.from_dict(stats.to_dict()).levels_won).is_equal(3)
	var old: Dictionary = {"version": 3, "progress": {"stats": {"daily_streak": 2}}}
	var save: SaveGame = SaveGame.from_dict(old)
	assert_int(save.progress.stats.levels_won).is_equal(0)
	assert_int(save.progress.stats.daily_streak).is_equal(2)
	var migrated: Dictionary = SaveGame.migrate(old, 3)
	var read: Dictionary = JsonRead.dictionary(JsonRead.dictionary(migrated, "progress"), "stats")
	assert_bool(read.has("levels_won")).is_true()
