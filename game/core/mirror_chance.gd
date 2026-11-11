class_name MirrorChance
extends RefCounted
## A great move the mirror bonus would open (Stelio, 2026-11-11): when the grid is filling up
## (TileBlocksRules.mirror_chance_fill_percent), a piece of the hand, flipped and turned some
## quarter turns, clears at least `mirror_chance_min_clears` lines and groups at once, more than
## the piece can unflipped. The screen then lights up the mirror button and shows the move.
## It only looks at the hand the player already has: the pieces never depend on it, nor on ads.

var slot: int = -1
## The piece as it lies in the move (flipped, then turned).
var piece: Piece
var origin: Vector2i = Vector2i.ZERO
## Lines and groups the move clears (GridClear.count).
var clears: int = 0


## The best such move, or null when there is none (grid not full enough, or no flip helps).
static func find(game: TileBlocksGame) -> MirrorChance:
	var rules: TileBlocksRules = game.rules
	if rules.mirror_chance_min_clears <= 0:
		return null
	var cells: int = game.grid.size * game.grid.size
	if game.grid.filled_count() * 100 < cells * rules.mirror_chance_fill_percent:
		return null
	var best: MirrorChance = null
	for slot_index in game.hand.size():
		var piece: Piece = game.hand[slot_index]
		if piece == null:
			continue
		var unflipped: MirrorChance = _best(game, slot_index, piece)
		var flipped: MirrorChance = _best(game, slot_index, piece.mirrored())
		if flipped == null or flipped.clears < rules.mirror_chance_min_clears:
			continue
		if unflipped != null and unflipped.clears >= flipped.clears:
			continue
		if best == null or flipped.clears > best.clears:
			best = flipped
	return best


## The placement of `piece`, in any of its turns, that clears the most lines and groups; null
## when none clears anything.
static func _best(game: TileBlocksGame, slot: int, piece: Piece) -> MirrorChance:
	var best: MirrorChance = null
	var turned: Piece = piece
	for _turn in 4 if game.rules.can_rotate else 1:
		for y in game.grid.size:
			for x in game.grid.size:
				var origin: Vector2i = Vector2i(x, y)
				if not game.grid.can_place(turned, origin):
					continue
				var trial: TileGrid = game.grid.copy()
				trial.place(turned, origin)
				var clears: int = trial.find_clears(game.rules.match_size).count()
				if clears > 0 and (best == null or clears > best.clears):
					best = MirrorChance.new()
					best.slot = slot
					best.piece = turned
					best.origin = origin
					best.clears = clears
		turned = turned.rotated()
	return best
