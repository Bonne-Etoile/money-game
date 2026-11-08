class_name TileBlocksGame
extends RefCounted
## Prototype 1, "tile blocks" (docs/etude-concurrence.md, appendix B, idea 1): pieces of tiles
## placed on a grid, without rotation. A full row or column clears, and so do 3 identical
## symbols touching each other. New pieces come when the hand is empty; the game is over when
## no piece of the hand fits anywhere.

var rules: TileBlocksRules
var grid: TileGrid
## The pieces offered; null where a piece was already placed.
var hand: Array[Piece] = []
var scores: ScoreKeeper
var _generator: PieceGenerator


func _init(game_rules: TileBlocksRules, random_seed: int) -> void:
	rules = game_rules
	grid = TileGrid.new(rules.grid_size)
	scores = ScoreKeeper.new(rules.scoring)
	_generator = PieceGenerator.new(
		rules.shape_set.shapes, rules.symbol_count, rules.match_size, random_seed
	)
	_refill_hand()


func score() -> int:
	return scores.score


func can_place(slot: int, origin: Vector2i) -> bool:
	return _piece_in(slot) != null and grid.can_place(hand[slot], origin)


## Places the piece of `slot` at `origin`, clears what is to clear and scores; null when the
## move is not allowed.
func place(slot: int, origin: Vector2i) -> MoveResult:
	if not can_place(slot, origin):
		return null
	var piece: Piece = hand[slot]
	grid.place(piece, origin)
	hand[slot] = null
	var result: MoveResult = MoveResult.new()
	for cell in piece.cells:
		result.placed.append(origin + cell)
	result.clear = grid.find_clears(rules.match_size)
	for cell in result.clear.cells:
		result.cleared_symbols.append(grid.symbol_at(cell))
	grid.remove(result.clear.cells)
	result.points = scores.score_move(piece.cells.size(), result.clear)
	result.combo = scores.combo
	if hand.all(func(waiting: Piece) -> bool: return waiting == null):
		_refill_hand()
	return result


## Over when no piece left in the hand fits anywhere.
func is_over() -> bool:
	for piece in hand:
		if piece != null and grid.fits_anywhere(piece):
			return false
	return true


func _piece_in(slot: int) -> Piece:
	if slot < 0 or slot >= hand.size():
		return null
	return hand[slot]


func _refill_hand() -> void:
	hand.clear()
	for _slot in rules.hand_size:
		hand.append(_generator.next_piece())
