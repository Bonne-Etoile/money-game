class_name PieceGenerator
extends RefCounted
## Draws pieces at random (seeded: the same seed gives the same pieces): a shape by weight,
## a random symbol on each cell. A piece never holds a clearing group by itself, otherwise
## placing it would clear it at once for free.

const MAX_SYMBOL_DRAWS: int = 50

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _shapes: Array[PieceShape] = []
var _weights: PackedFloat32Array = []
var _symbol_count: int = 1
var _match_size: int = 0


func _init(shapes: Array[PieceShape], symbol_count: int, match_size: int, random_seed: int) -> void:
	_rng.seed = random_seed
	_symbol_count = maxi(symbol_count, 1)
	_match_size = match_size
	for shape in shapes:
		if shape.weight > 0 and not shape.cells.is_empty():
			_shapes.append(shape)
			_weights.append(shape.weight)


func next_piece() -> Piece:
	var shape: PieceShape = _shapes[_rng.rand_weighted(_weights)]
	var piece: Piece = _draw_symbols(shape)
	for _draw in MAX_SYMBOL_DRAWS:
		if _match_size <= 0 or piece.largest_group() < _match_size:
			break
		piece = _draw_symbols(shape)
	return piece


## Draws `candidates` pieces and gives the one with the least room on `grid` (`hardest`), or
## the most (a bonus): the adaptive difficulty (DifficultyDirector). With one candidate, a
## piece drawn by pure chance. `can_turn`: the room of a piece counts all its turns.
func next_piece_among(grid: TileGrid, candidates: int, hardest: bool, can_turn: bool) -> Piece:
	var chosen: Piece = next_piece()
	if candidates <= 1:
		return chosen
	var chosen_room: int = room(grid, chosen, can_turn)
	for _draw in candidates - 1:
		var piece: Piece = next_piece()
		var piece_room: int = room(grid, piece, can_turn)
		var better: bool = piece_room < chosen_room if hardest else piece_room > chosen_room
		if better:
			chosen = piece
			chosen_room = piece_room
	return chosen


## A random piece that fits somewhere on `grid` (in some turn when `can_turn`): each shape is
## tried once, in a random order; null when no shape fits at all.
func piece_that_fits(grid: TileGrid, can_turn: bool) -> Piece:
	var order: Array[int] = []
	for index in _shapes.size():
		order.append(index)
	for index in range(order.size() - 1, 0, -1):
		var other: int = _rng.randi_range(0, index)
		var kept: int = order[index]
		order[index] = order[other]
		order[other] = kept
	for index in order:
		var piece: Piece = _draw_symbols(_shapes[index])
		if room(grid, piece, can_turn) > 0:
			return piece
	return null


## Places where `piece` fits on `grid`, in each of its different turns when it can turn.
static func room(grid: TileGrid, piece: Piece, can_turn: bool) -> int:
	var total: int = 0
	var seen: Array[Array] = []
	var turned: Piece = piece
	for _turn in 4 if can_turn else 1:
		var cells: Array[Vector2i] = turned.cells.duplicate()
		cells.sort()
		if not cells in seen:
			seen.append(cells)
			total += grid.count_placements(turned)
		turned = turned.rotated()
	return total


func random_symbol() -> int:
	return _rng.randi_range(0, _symbol_count - 1)


func _draw_symbols(shape: PieceShape) -> Piece:
	var symbols: PackedInt32Array = []
	for _cell in shape.cells:
		symbols.append(random_symbol())
	return Piece.new(shape.cells, symbols)
