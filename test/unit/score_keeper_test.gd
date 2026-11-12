extends GdUnitTestSuite
## Scoring of the block puzzles (game/core/score_keeper.gd).


func _rules() -> ScoreRules:
	var rules: ScoreRules = ScoreRules.new()
	rules.points_per_cell_placed = 1
	rules.points_per_cell_cleared = 10
	rules.multi_clear_bonus_percent = 50
	rules.combo_bonus_percent = 50
	rules.combo_grace_moves = 1
	return rules


func _clear(cells: int, lines: int, groups: int) -> GridClear:
	var clear: GridClear = GridClear.new()
	for index in cells:
		clear.cells.append(Vector2i(index, 0))
	clear.lines = lines
	clear.groups = groups
	return clear


func test_placed_cells_score_one_point_each() -> void:
	var keeper: ScoreKeeper = ScoreKeeper.new(_rules())
	assert_int(keeper.score_move(4, GridClear.new())).is_equal(4)
	assert_int(keeper.score).is_equal(4)


func test_two_clears_at_once_score_more_than_twice_one() -> void:
	var keeper: ScoreKeeper = ScoreKeeper.new(_rules())
	assert_int(keeper.score_move(1, _clear(8, 1, 0))).is_equal(81)
	keeper = ScoreKeeper.new(_rules())
	assert_int(keeper.score_move(1, _clear(15, 1, 1))).is_equal(1 + 225)


func test_the_combo_grows_and_survives_the_grace_moves() -> void:
	var keeper: ScoreKeeper = ScoreKeeper.new(_rules())
	keeper.score_move(1, _clear(3, 0, 1))
	assert_int(keeper.combo).is_equal(1)
	assert_int(keeper.score_move(1, _clear(3, 0, 1))).is_equal(1 + 45)
	assert_int(keeper.combo).is_equal(2)
	keeper.score_move(1, GridClear.new())
	assert_int(keeper.combo).is_equal(2)
	keeper.score_move(1, GridClear.new())
	assert_int(keeper.combo).is_equal(0)


func test_the_combo_bonus_stops_growing_at_its_cap() -> void:
	var rules: ScoreRules = _rules()
	rules.combo_bonus_max_steps = 2
	var keeper: ScoreKeeper = ScoreKeeper.new(rules)
	for _move in 3:
		keeper.score_move(1, _clear(3, 0, 1))
	# Third move of the combo: +100 % (2 steps), the cap.
	assert_int(keeper.score_move(1, _clear(3, 0, 1))).is_equal(1 + 60)
	assert_int(keeper.combo).is_equal(4)
	assert_int(keeper.score_move(1, _clear(3, 0, 1))).is_equal(1 + 60)
