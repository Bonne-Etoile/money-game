class_name PyramidGame
extends RefCounted
## Prototype 2, "the pyramid gives the pieces" (docs/etude-concurrence.md, appendix B, idea 2):
## free tiles of a mahjong pile are taken into a small tray; each one is a piece to place on
## the grid below, where full rows and columns clear. The level is won when the pile and the
## tray are empty, lost when no piece of the tray fits and no other can be taken.

var rules: PyramidRules
var level: PyramidLevel
var grid: TileGrid
var stack: TileStack
## Pieces taken from the pile and waiting to be placed; null for an empty slot.
var tray: Array[Piece] = []
var scores: ScoreKeeper


func _init(game_rules: PyramidRules, game_level: PyramidLevel) -> void:
	rules = game_rules
	level = game_level
	grid = TileGrid.new(rules.grid_size)
	LevelLayout.fill_grid(level, rules, grid)
	scores = ScoreKeeper.new(rules.scoring)
	stack = TileStack.new(LevelLayout.tiles_of(level, rules))
	for _slot in rules.tray_size:
		tray.append(null)


func score() -> int:
	return scores.score


## Whether a tile can be taken now: free in the pile, and room in the tray.
func can_take(index: int) -> bool:
	return tray.has(null) and stack.is_free(index)


## Takes a free tile into the first empty slot of the tray; false when not allowed.
func take(index: int) -> bool:
	if not can_take(index):
		return false
	tray[tray.find(null)] = stack.take(index)
	return true


func can_place(slot: int, origin: Vector2i) -> bool:
	return slot >= 0 and slot < tray.size() and grid.can_place(tray[slot], origin)


## Places the piece of `slot` at `origin`, clears and scores; null when not allowed.
func place(slot: int, origin: Vector2i) -> MoveResult:
	if not can_place(slot, origin):
		return null
	var piece: Piece = tray[slot]
	grid.place(piece, origin)
	tray[slot] = null
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
	return stack.is_empty() and tray.all(func(piece: Piece) -> bool: return piece == null)


func is_lost() -> bool:
	if is_won():
		return false
	for piece in tray:
		if piece != null and grid.fits_anywhere(piece):
			return false
	return not tray.has(null) or stack.free_tiles().is_empty()
