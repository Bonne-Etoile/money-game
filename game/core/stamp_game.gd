class_name StampGame
extends RefCounted
## The "stamp" prototype (G7, Stelio's idea, docs/backlog.md): empty Tetris shapes arrive one
## after the other; stamped on the pile, a shape takes the top tile of each cell it covers and
## becomes a tiled piece, placed on the grid where full lines and trios clear. Won when the
## pile and the hand are empty, lost when the piece in hand fits nowhere on the grid.

## Symbol of a shape not yet stamped (no tile on it).
const BLANK: int = -1

var rules: StampRules
var level: StampLevel
var pile: StampPile
var grid: TileGrid
## The piece taken from the pile, waiting to be placed (one slot; null when empty).
var hand: Array[Piece] = [null]
## The shape to stamp now, then the upcoming ones.
var queue: Array[Piece] = []
var scores: ScoreKeeper
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(game_rules: StampRules, game_level: StampLevel, random_seed: int) -> void:
	rules = game_rules
	level = game_level
	_rng.seed = random_seed
	pile = StampPile.new(rules.pile_size)
	_fill_pile()
	grid = TileGrid.new(rules.grid_size)
	scores = ScoreKeeper.new(rules.scoring)
	for _shape in rules.preview_count + 1:
		queue.append(_draw_shape())
	_fit_current_shape()


func score() -> int:
	return scores.score


func current_shape() -> Piece:
	return queue[0] if hand[0] == null and not pile.is_empty() else null


func can_stamp(origin: Vector2i) -> bool:
	return current_shape() != null and pile.can_stamp(queue[0], origin)


## Stamps the current shape on the pile at `origin`: its tiles go into the hand and the next
## shape arrives. Null when not allowed. The result's `placed` cells are those of the pile.
func stamp(origin: Vector2i) -> MoveResult:
	if not can_stamp(origin):
		return null
	var shape: Piece = queue.pop_front()
	hand[0] = pile.stamp(shape, origin)
	queue.append(_draw_shape())
	_fit_current_shape()
	var result: MoveResult = MoveResult.new()
	for cell in shape.cells:
		result.placed.append(origin + cell)
	return result


func can_place(slot: int, origin: Vector2i) -> bool:
	return slot == 0 and grid.can_place(hand[0], origin)


## Places the piece in hand at `origin`, clears and scores; null when not allowed.
func place(slot: int, origin: Vector2i) -> MoveResult:
	if not can_place(slot, origin):
		return null
	var piece: Piece = hand[0]
	grid.place(piece, origin)
	hand[0] = null
	var result: MoveResult = MoveResult.new()
	for cell in piece.cells:
		result.placed.append(origin + cell)
	result.clear = grid.find_clears(rules.match_size)
	for cell in result.clear.cells:
		result.cleared_symbols.append(grid.symbol_at(cell))
	grid.remove(result.clear.cells)
	result.points = scores.score_move(piece.cells.size(), result.clear)
	result.combo = scores.combo
	return result


func is_won() -> bool:
	return pile.is_empty() and hand[0] == null


func is_lost() -> bool:
	return hand[0] != null and not grid.fits_anywhere(hand[0])


func _fill_pile() -> void:
	var symbols: RandomNumberGenerator = RandomNumberGenerator.new()
	symbols.seed = level.symbol_seed
	for y in mini(level.heights.size(), pile.size):
		var row: String = level.heights[y]
		for x in mini(row.length(), pile.size):
			for _tile in row[x].to_int():
				pile.push(Vector2i(x, y), symbols.randi_range(0, rules.symbol_count - 1))


func _draw_shape() -> Piece:
	var key: String = rules.shape_keys[_rng.randi_range(0, rules.shape_keys.size() - 1)]
	return _blank(key)


## When the shape to stamp fits nowhere on the pile, the first fallback shape that fits
## replaces it.
func _fit_current_shape() -> void:
	if pile.is_empty() or pile.fits_anywhere(queue[0]):
		return
	for key in rules.fallback_keys:
		var shape: Piece = _blank(key)
		if pile.fits_anywhere(shape):
			queue[0] = shape
			return


func _blank(key: String) -> Piece:
	return Piece.uniform(rules.shape_set.find(key).cells, BLANK)
