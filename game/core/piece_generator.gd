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


func random_symbol() -> int:
	return _rng.randi_range(0, _symbol_count - 1)


func _draw_symbols(shape: PieceShape) -> Piece:
	var symbols: PackedInt32Array = []
	for _cell in shape.cells:
		symbols.append(random_symbol())
	return Piece.new(shape.cells, symbols)
