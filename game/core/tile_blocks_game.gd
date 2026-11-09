class_name TileBlocksGame
extends RefCounted
## Prototype 1, "tile blocks" (docs/etude-concurrence.md, appendix B, idea 1): pieces of tiles
## placed on a grid; the player may turn them (TileBlocksRules.can_rotate). A full row or
## column clears, and so do 3 identical symbols touching each other. A new piece takes the
## place of a placed one (or three come when the hand is empty); the game is over when
## no piece of the hand fits anywhere, unless the player revives it (after a rewarded ad).

var rules: TileBlocksRules
var grid: TileGrid
## The pieces offered; null where a piece was already placed.
var hand: Array[Piece] = []
var scores: ScoreKeeper
## Revives used in this game (at most `rules.revives_per_game`).
var revives_used: int = 0
var _generator: PieceGenerator


func _init(game_rules: TileBlocksRules, random_seed: int) -> void:
	rules = game_rules
	grid = TileGrid.new(rules.grid_size)
	scores = ScoreKeeper.new(rules.scoring)
	_generator = PieceGenerator.new(
		rules.shape_set.pick(rules.shape_keys), rules.symbol_count, rules.match_size, random_seed
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
	if rules.refill_each_slot:
		hand[slot] = _generator.next_piece()
	elif hand.all(func(waiting: Piece) -> bool: return waiting == null):
		_refill_hand()
	return result


## Turns the piece of `slot` a quarter turn clockwise; false when not allowed.
func rotate(slot: int) -> bool:
	if not rules.can_rotate or _piece_in(slot) == null:
		return false
	hand[slot] = hand[slot].rotated()
	return true


## Over when no piece left in the hand fits anywhere (in any of its turns, when the player
## can turn pieces).
func is_over() -> bool:
	for piece in hand:
		if piece != null and _fits_somehow(piece):
			return false
	return true


func _fits_somehow(piece: Piece) -> bool:
	var turned: Piece = piece
	for _turn in 4 if rules.can_rotate else 1:
		if grid.fits_anywhere(turned):
			return true
		turned = turned.rotated()
	return false


## True when the game is over and a revive is left.
func can_revive() -> bool:
	return revives_used < rules.revives_per_game and is_over()


## Goes on with a lost game: clears a cross of `rules.revive_clear_lines` rows and columns in
## the middle of the grid, without points, so that every piece of the hand fits again. False
## when no revive is allowed.
func revive() -> bool:
	if not can_revive():
		return false
	revives_used += 1
	var lines: int = mini(rules.revive_clear_lines, grid.size)
	var first: int = (grid.size - lines) >> 1
	var cells: Array[Vector2i] = []
	for line in range(first, first + lines):
		for along in grid.size:
			cells.append(Vector2i(along, line))
			cells.append(Vector2i(line, along))
	grid.remove(cells)
	return true


func _piece_in(slot: int) -> Piece:
	if slot < 0 or slot >= hand.size():
		return null
	return hand[slot]


func _refill_hand() -> void:
	hand.clear()
	for _slot in rules.hand_size:
		hand.append(_generator.next_piece())
