class_name MoveHint
extends RefCounted
## A placement shown to a player who hesitates (G15): the piece of a slot, turned some quarter
## turns, at an origin where it clears something. `find` gives the one that clears the most
## cells, or null when no placement clears anything (then no hint: the challenge stays).

var slot: int = -1
## Quarter turns clockwise the player has to give the piece first.
var turns: int = 0
## The piece as it lies in the hint (already turned).
var piece: Piece
var origin: Vector2i = Vector2i.ZERO
## Cells the placement clears.
var cleared: int = 0


static func find(game: TileBlocksGame) -> MoveHint:
	var best: MoveHint = null
	for slot_index in game.hand.size():
		var turned: Piece = game.hand[slot_index]
		if turned == null:
			continue
		var seen: Array[Array] = []
		for turn in 4 if game.rules.can_rotate else 1:
			var cells: Array[Vector2i] = turned.cells.duplicate()
			cells.sort()
			if not cells in seen:
				seen.append(cells)
				best = _better(best, _best_origin(game, slot_index, turn, turned))
			turned = turned.rotated()
	return best


## The placement of `piece` that clears the most, or null when none clears anything.
static func _best_origin(game: TileBlocksGame, slot: int, turns: int, piece: Piece) -> MoveHint:
	var best: MoveHint = null
	for y in game.grid.size:
		for x in game.grid.size:
			var origin: Vector2i = Vector2i(x, y)
			if not game.grid.can_place(piece, origin):
				continue
			var trial: TileGrid = game.grid.copy()
			trial.place(piece, origin)
			var cleared: int = trial.find_clears(game.rules.match_size).cells.size()
			if cleared > 0 and (best == null or cleared > best.cleared):
				best = MoveHint.new()
				best.slot = slot
				best.turns = turns
				best.piece = piece
				best.origin = origin
				best.cleared = cleared
	return best


static func _better(current: MoveHint, candidate: MoveHint) -> MoveHint:
	if candidate == null:
		return current
	if current == null or candidate.cleared > current.cleared:
		return candidate
	return current
