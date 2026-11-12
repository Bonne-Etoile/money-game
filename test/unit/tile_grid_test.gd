extends GdUnitTestSuite
## The grid of the block puzzles (game/core/tile_grid.gd): placing, full lines, symbol groups.


func _piece(cells: Array[Vector2i], symbols: Array[int]) -> Piece:
	return Piece.new(cells, PackedInt32Array(symbols))


## Fills row `y` with alternating symbols 0 and 1 (no group of 3), leaving out `skipped`.
func _fill_row(grid: TileGrid, y: int, skipped: Array[int] = []) -> void:
	for x in grid.size:
		if not x in skipped:
			grid.set_symbol(Vector2i(x, y), x % 2)


func test_a_new_grid_is_empty() -> void:
	var grid: TileGrid = TileGrid.new(8)
	assert_int(grid.filled_count()).is_equal(0)
	assert_bool(grid.is_empty_cell(Vector2i(7, 7))).is_true()
	assert_bool(grid.has_cell(Vector2i(8, 0))).is_false()


func test_a_piece_fits_only_on_empty_cells_inside_the_grid() -> void:
	var grid: TileGrid = TileGrid.new(4)
	var bar: Piece = _piece([Vector2i(0, 0), Vector2i(1, 0)], [0, 1])
	assert_bool(grid.can_place(bar, Vector2i(2, 0))).is_true()
	assert_bool(grid.can_place(bar, Vector2i(3, 0))).is_false()
	assert_bool(grid.can_place(bar, Vector2i(-1, 0))).is_false()
	assert_bool(grid.place(bar, Vector2i(0, 0))).is_true()
	assert_int(grid.symbol_at(Vector2i(1, 0))).is_equal(1)
	assert_bool(grid.can_place(bar, Vector2i(1, 0))).is_false()
	assert_bool(grid.place(bar, Vector2i(1, 0))).is_false()
	assert_int(grid.filled_count()).is_equal(2)


func test_a_full_row_and_a_full_column_clear_together() -> void:
	var grid: TileGrid = TileGrid.new(4)
	_fill_row(grid, 2)
	for y in 4:
		grid.set_symbol(Vector2i(1, y), 2 + y % 2)
	var clear: GridClear = grid.find_clears(0)
	assert_int(clear.lines).is_equal(2)
	assert_int(clear.cells.size()).is_equal(7)
	grid.remove(clear.cells)
	assert_int(grid.filled_count()).is_equal(0)


func test_three_identical_symbols_touching_clear_but_not_diagonally() -> void:
	var grid: TileGrid = TileGrid.new(8)
	grid.set_symbol(Vector2i(0, 0), 4)
	grid.set_symbol(Vector2i(1, 0), 4)
	grid.set_symbol(Vector2i(2, 1), 4)
	assert_bool(grid.find_clears(3).is_empty()).is_true()
	grid.set_symbol(Vector2i(1, 1), 4)
	var clear: GridClear = grid.find_clears(3)
	assert_int(clear.groups).is_equal(1)
	assert_int(clear.cells.size()).is_equal(4)


func test_groups_are_ignored_when_the_rule_is_off() -> void:
	var grid: TileGrid = TileGrid.new(8)
	for x in 3:
		grid.set_symbol(Vector2i(x, 0), 1)
	assert_bool(grid.find_clears(0).is_empty()).is_true()
	assert_int(grid.find_clears(3).groups).is_equal(1)


func test_a_cell_in_a_line_and_a_group_is_cleared_once() -> void:
	var grid: TileGrid = TileGrid.new(4)
	_fill_row(grid, 0)
	grid.set_symbol(Vector2i(0, 1), 0)
	grid.set_symbol(Vector2i(0, 2), 0)
	var clear: GridClear = grid.find_clears(3)
	assert_int(clear.lines).is_equal(1)
	assert_int(clear.groups).is_equal(1)
	assert_int(clear.cells.size()).is_equal(6)


func test_fits_anywhere_looks_at_every_position() -> void:
	var grid: TileGrid = TileGrid.new(3)
	var none: Array[int] = []
	var last: Array[int] = [2]
	_fill_row(grid, 0, none)
	_fill_row(grid, 1, none)
	_fill_row(grid, 2, last)
	assert_bool(grid.fits_anywhere(_piece([Vector2i(0, 0)], [0]))).is_true()
	assert_bool(grid.fits_anywhere(_piece([Vector2i(0, 0), Vector2i(1, 0)], [0, 1]))).is_false()


func test_the_cells_a_move_would_clear_are_found_without_placing_it() -> void:
	var grid: TileGrid = TileGrid.new(4)
	_fill_row(grid, 2, [3])
	var single: Piece = _piece([Vector2i.ZERO], [1])
	var cells: Array[Vector2i] = grid.clears_if_placed(single, Vector2i(3, 2), 0)
	assert_array(cells).contains_exactly_in_any_order(
		[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
	)
	assert_bool(grid.is_empty_cell(Vector2i(3, 2))).is_true()
	assert_array(grid.clears_if_placed(single, Vector2i(0, 0), 0)).is_empty()
	assert_array(grid.clears_if_placed(single, Vector2i(0, 2), 0)).is_empty()
