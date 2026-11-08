extends GdUnitTestSuite
## Prototype 2, "the pyramid gives the pieces" (game/core/pyramid_game.gd), and its levels.

const RULES: PyramidRules = preload("res://game/data/pyramid_rules.tres")


func _level(layers: Array[String]) -> PyramidLevel:
	var level: PyramidLevel = PyramidLevel.new()
	level.layers = layers
	return level


func test_the_layout_gives_one_tile_per_letter() -> void:
	var tiles: Array[StackTile] = LevelLayout.tiles_of(_level(["a.b.\n....\nc...", ".f.."]), RULES)
	assert_int(tiles.size()).is_equal(4)
	assert_that(tiles[1].position).is_equal(Vector2i(2, 0))
	assert_that(tiles[2].position).is_equal(Vector2i(0, 2))
	assert_int(tiles[3].layer).is_equal(1)
	assert_that(tiles[3].piece.extent()).is_equal(Vector2i(2, 2))


func test_take_then_place_until_the_level_is_won() -> void:
	var game: PyramidGame = PyramidGame.new(RULES, _level(["a.b."]))
	assert_bool(game.take(0)).is_true()
	assert_bool(game.take(1)).is_true()
	assert_bool(game.is_won()).is_false()
	assert_object(game.place(0, Vector2i(0, 0))).is_not_null()
	assert_object(game.place(1, Vector2i(0, 0))).is_null()
	assert_object(game.place(1, Vector2i(3, 3))).is_not_null()
	assert_bool(game.is_won()).is_true()
	assert_int(game.score()).is_equal(3 * RULES.scoring.points_per_cell_placed)


func test_the_tray_has_limited_room() -> void:
	var game: PyramidGame = PyramidGame.new(RULES, _level(["a.a.a."]))
	game.take(0)
	game.take(2)
	assert_bool(game.can_take(1)).is_false()
	assert_bool(game.take(1)).is_false()


func test_a_full_row_clears() -> void:
	var game: PyramidGame = PyramidGame.new(RULES, _level(["a."]))
	for x in 7:
		game.grid.set_symbol(Vector2i(x, 0), 0)
	game.take(0)
	var result: MoveResult = game.place(0, Vector2i(7, 0))
	assert_int(result.clear.lines).is_equal(1)
	assert_int(game.grid.filled_count()).is_equal(0)


func test_lost_when_the_tray_is_full_and_nothing_fits() -> void:
	var game: PyramidGame = PyramidGame.new(RULES, _level(["f.f.f."]))
	for y in 8:
		for x in 8:
			if (x + y) % 2 == 0:
				game.grid.set_symbol(Vector2i(x, y), 0)
	game.take(0)
	assert_bool(game.is_lost()).is_false()
	game.take(2)
	assert_bool(game.is_lost()).is_true()


func test_every_level_is_well_formed() -> void:
	assert_int(RULES.levels.size()).is_between(3, 5)
	for level in RULES.levels:
		var tiles: Array[StackTile] = LevelLayout.tiles_of(level, RULES)
		assert_int(tiles.size()).is_greater(5)
		for tile in tiles:
			for other in tiles:
				if other != tile and other.layer == tile.layer:
					(
						assert_bool(tile.overlaps(other))
						. override_failure_message("tiles overlap at %s" % tile.position)
						. is_false()
					)
			if tile.layer > 0:
				var rests: bool = tiles.any(
					func(below: StackTile) -> bool:
						return below.layer == tile.layer - 1 and tile.overlaps(below)
				)
				(
					assert_bool(rests)
					. override_failure_message("tile at %s floats" % tile.position)
					. is_true()
				)
		# Every letter of the layout names a known shape.
		var letters: int = 0
		for layer in level.layers:
			for character in layer:
				if character != "." and character != "\n":
					letters += 1
		assert_int(tiles.size()).is_equal(letters)


func test_a_starting_grid_is_filled_from_the_level() -> void:
	var level: PyramidLevel = _level(["a."])
	level.grid_rows = ["#.#", ".#"]
	var game: PyramidGame = PyramidGame.new(RULES, level)
	assert_int(game.grid.filled_count()).is_equal(3)
	assert_bool(game.grid.is_empty_cell(Vector2i(1, 0))).is_true()
	assert_bool(game.grid.is_empty_cell(Vector2i(1, 1))).is_false()


## Each level can be won: a greedy robot (best clear now, else the highest-left spot, never
## using the second slot of the tray) wins them all. A human has more options.
func test_every_level_can_be_won() -> void:
	for index in RULES.levels.size():
		var game: PyramidGame = PyramidGame.new(RULES, RULES.levels[index])
		for _move in 100:
			if game.is_won() or game.is_lost() or not _play_greedy(game):
				break
		assert_bool(game.is_won()).override_failure_message("level %d" % (index + 1)).is_true()


func _play_greedy(game: PyramidGame) -> bool:
	var best: int = -1
	var best_tile: int = -1
	var best_origin: Vector2i = Vector2i.ZERO
	for tile in game.stack.free_tiles():
		var piece: Piece = game.stack.tiles[tile].piece
		for y in game.grid.size:
			for x in game.grid.size:
				var value: int = _value(game.grid, piece, Vector2i(x, y))
				if value > best:
					best = value
					best_tile = tile
					best_origin = Vector2i(x, y)
	if best_tile < 0:
		return false
	game.take(best_tile)
	return game.place(game.tray.find(game.stack.tiles[best_tile].piece), best_origin) != null


## Cells cleared by placing `piece` at `origin` first, then how high and left it is; -1 when
## it does not fit.
func _value(grid: TileGrid, piece: Piece, origin: Vector2i) -> int:
	if not grid.can_place(piece, origin):
		return -1
	var copy: TileGrid = TileGrid.new(grid.size)
	for y in grid.size:
		for x in grid.size:
			copy.set_symbol(Vector2i(x, y), grid.symbol_at(Vector2i(x, y)))
	copy.place(piece, origin)
	return copy.find_clears(0).cells.size() * 100 + (grid.size - origin.y) * grid.size - origin.x
