class_name StampPile
extends RefCounted
## The pile of prototype "stamp" (G7): a square of columns of tiles. A shape stamped on the
## pile takes the top tile of each cell it covers, and becomes a piece of those tiles.

var size: int = 0
var _stacks: Array[PackedInt32Array] = []


func _init(pile_size: int = 6) -> void:
	size = pile_size
	for _cell in size * size:
		_stacks.append(PackedInt32Array())


func has_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size and cell.y < size


func height(cell: Vector2i) -> int:
	return _stacks[_index(cell)].size() if has_cell(cell) else 0


## The symbol on top of `cell`, or TileGrid.EMPTY.
func top_symbol(cell: Vector2i) -> int:
	if height(cell) == 0:
		return TileGrid.EMPTY
	var stack: PackedInt32Array = _stacks[_index(cell)]
	return stack[stack.size() - 1]


## Puts a tile on top of `cell`.
func push(cell: Vector2i, symbol: int) -> void:
	if has_cell(cell):
		var stack: PackedInt32Array = _stacks[_index(cell)]
		stack.append(symbol)
		_stacks[_index(cell)] = stack


func remaining() -> int:
	var count: int = 0
	for stack in _stacks:
		count += stack.size()
	return count


func is_empty() -> bool:
	return remaining() == 0


## Whether every cell of `shape`, its corner on `origin`, covers a tile.
func can_stamp(shape: Piece, origin: Vector2i) -> bool:
	if shape == null or shape.cells.is_empty():
		return false
	for cell in shape.cells:
		if height(origin + cell) == 0:
			return false
	return true


func fits_anywhere(shape: Piece) -> bool:
	var extent: Vector2i = shape.extent()
	for y in size - extent.y + 1:
		for x in size - extent.x + 1:
			if can_stamp(shape, Vector2i(x, y)):
				return true
	return false


## Takes the top tile under each cell of `shape`: the piece they make, or null when the shape
## does not lie on tiles everywhere.
func stamp(shape: Piece, origin: Vector2i) -> Piece:
	if not can_stamp(shape, origin):
		return null
	var symbols: PackedInt32Array = []
	for cell in shape.cells:
		var stack: PackedInt32Array = _stacks[_index(origin + cell)]
		symbols.append(stack[stack.size() - 1])
		stack.resize(stack.size() - 1)
		_stacks[_index(origin + cell)] = stack
	return Piece.new(shape.cells, symbols)


## The top symbols, as a grid (for drawing and for the shape's ghost).
func surface() -> TileGrid:
	var grid: TileGrid = TileGrid.new(size)
	for y in size:
		for x in size:
			grid.set_symbol(Vector2i(x, y), top_symbol(Vector2i(x, y)))
	return grid


func _index(cell: Vector2i) -> int:
	return cell.y * size + cell.x
