class_name TileGrid
extends RefCounted
## The square grid where pieces are placed: each cell is empty or holds a tile symbol.
## Pure logic (no node); the board scene only draws it.

const EMPTY: int = -1
## A stone (level mode, G17): fills its cell, belongs to no group of symbols, and goes only
## with a full row or column.
const STONE: int = -2

var size: int = 0
var _cells: PackedInt32Array = []


func _init(grid_size: int = 8) -> void:
	size = grid_size
	_cells.resize(size * size)
	_cells.fill(EMPTY)


## A copy of this grid (to try a move without changing it).
func copy() -> TileGrid:
	var other: TileGrid = TileGrid.new(size)
	other._cells = _cells.duplicate()
	return other


func has_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size and cell.y < size


## The symbol at `cell`, or EMPTY (also outside the grid).
func symbol_at(cell: Vector2i) -> int:
	if not has_cell(cell):
		return EMPTY
	return _cells[cell.y * size + cell.x]


func set_symbol(cell: Vector2i, symbol: int) -> void:
	if has_cell(cell):
		_cells[cell.y * size + cell.x] = symbol


func is_empty_cell(cell: Vector2i) -> bool:
	return has_cell(cell) and symbol_at(cell) == EMPTY


func filled_count() -> int:
	return _cells.size() - _cells.count(EMPTY)


## Whether `piece` fits with its top-left corner on `origin`.
func can_place(piece: Piece, origin: Vector2i) -> bool:
	if piece == null or piece.cells.is_empty():
		return false
	for cell in piece.cells:
		if not is_empty_cell(origin + cell):
			return false
	return true


## Puts `piece` on the grid; false (and nothing changed) when it does not fit.
func place(piece: Piece, origin: Vector2i) -> bool:
	if not can_place(piece, origin):
		return false
	for index in piece.cells.size():
		set_symbol(origin + piece.cells[index], piece.symbols[index])
	return true


## Whether `piece` fits somewhere on the grid.
func fits_anywhere(piece: Piece) -> bool:
	var extent: Vector2i = piece.extent()
	for y in size - extent.y + 1:
		for x in size - extent.x + 1:
			if can_place(piece, Vector2i(x, y)):
				return true
	return false


## Number of places where `piece` fits (top-left corners): how much room it has.
func count_placements(piece: Piece) -> int:
	var extent: Vector2i = piece.extent()
	var count: int = 0
	for y in size - extent.y + 1:
		for x in size - extent.x + 1:
			if can_place(piece, Vector2i(x, y)):
				count += 1
	return count


## The cells to clear now: full rows and columns, and (when `match_size` > 0) every group of
## at least `match_size` identical symbols touching each other.
func find_clears(match_size: int) -> GridClear:
	var clear: GridClear = GridClear.new()
	var marked: Dictionary[Vector2i, bool] = {}
	for line in size:
		var row: Array[Vector2i] = []
		var column: Array[Vector2i] = []
		for step in size:
			row.append(Vector2i(step, line))
			column.append(Vector2i(line, step))
		_mark_if_full(row, clear, marked)
		_mark_if_full(column, clear, marked)
	if match_size > 0:
		var symbol_of: Dictionary[Vector2i, int] = _symbol_map()
		var grouped: Dictionary[Vector2i, bool] = {}
		for cell: Vector2i in symbol_of:
			if grouped.has(cell):
				continue
			var group: Array[Vector2i] = GridGroups.group_of(cell, symbol_of)
			_mark(group, grouped)
			if group.size() >= match_size:
				clear.groups += 1
				clear.group_symbols.append(symbol_of[cell])
				_mark(group, marked)
	clear.cells.assign(marked.keys())
	return clear


## The cells that placing `piece` at `origin` would clear, without placing it (they glow
## while the piece hovers there); empty when it does not fit there.
func clears_if_placed(piece: Piece, origin: Vector2i, match_size: int) -> Array[Vector2i]:
	if not can_place(piece, origin):
		return []
	var trial: TileGrid = copy()
	trial.place(piece, origin)
	return trial.find_clears(match_size).cells


func remove(cells: Array[Vector2i]) -> void:
	for cell in cells:
		set_symbol(cell, EMPTY)


func _mark_if_full(
	cells: Array[Vector2i], clear: GridClear, marked: Dictionary[Vector2i, bool]
) -> void:
	for cell in cells:
		if symbol_at(cell) == EMPTY:
			return
	clear.lines += 1
	_mark(cells, marked)


func _mark(cells: Array[Vector2i], marked: Dictionary[Vector2i, bool]) -> void:
	for cell in cells:
		marked[cell] = true


func _symbol_map() -> Dictionary[Vector2i, int]:
	var symbol_of: Dictionary[Vector2i, int] = {}
	for y in size:
		for x in size:
			var symbol: int = symbol_at(Vector2i(x, y))
			if symbol >= 0:
				symbol_of[Vector2i(x, y)] = symbol
	return symbol_of
