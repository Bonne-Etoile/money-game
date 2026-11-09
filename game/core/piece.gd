class_name Piece
extends RefCounted
## A piece to place on the grid: its cells from its top-left corner, each with a symbol.

var cells: Array[Vector2i] = []
## One symbol per cell, in the order of `cells`.
var symbols: PackedInt32Array = []


func _init(
	piece_cells: Array[Vector2i] = [], piece_symbols: PackedInt32Array = PackedInt32Array()
) -> void:
	cells = piece_cells.duplicate()
	symbols = piece_symbols.duplicate()


## A piece of `shape` whose cells all carry `symbol`.
static func uniform(shape_cells: Array[Vector2i], symbol: int) -> Piece:
	var all_symbols: PackedInt32Array = []
	for _cell in shape_cells:
		all_symbols.append(symbol)
	return Piece.new(shape_cells, all_symbols)


## The piece turned a quarter turn clockwise, its corner back at the top left.
func rotated() -> Piece:
	var height: int = extent().y
	var turned: Array[Vector2i] = []
	for cell in cells:
		turned.append(Vector2i(height - 1 - cell.y, cell.x))
	return Piece.new(turned, symbols)


## The piece flipped left to right (a mirror image), its corner back at the top left: the
## only way to turn an S into a Z, or a J into an L (a bonus).
func mirrored() -> Piece:
	var width: int = extent().x
	var flipped: Array[Vector2i] = []
	for cell in cells:
		flipped.append(Vector2i(width - 1 - cell.x, cell.y))
	return Piece.new(flipped, symbols)


## Width and height in cells.
func extent() -> Vector2i:
	var corner: Vector2i = Vector2i.ZERO
	for cell in cells:
		corner = Vector2i(maxi(corner.x, cell.x + 1), maxi(corner.y, cell.y + 1))
	return corner


## Size of the largest group of identical symbols touching each other inside the piece.
func largest_group() -> int:
	var symbol_of: Dictionary[Vector2i, int] = {}
	for index in cells.size():
		symbol_of[cells[index]] = symbols[index]
	var largest: int = 0
	for cell in cells:
		largest = maxi(largest, GridGroups.group_of(cell, symbol_of).size())
	return largest
