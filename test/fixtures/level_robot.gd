class_name LevelRobot
extends RefCounted
## A simple robot for the level mode (tests: every level can be won; screenshots): it tries
## every piece of the hand in every turn and place, and plays the move that serves the goal
## best (gold tiles freed, goal trios cleared), then cells cleared, identical neighbours, and
## low and left.


## Plays until the level is won or lost (or `max_moves`); true when won.
static func play(level: LevelGame, max_moves: int = 200) -> bool:
	for _move in max_moves:
		if level.is_won() or level.is_lost():
			break
		if not play_one(level):
			break
	return level.is_won()


## Plays the best move; false when none is possible.
static func play_one(level: LevelGame) -> bool:
	var game: TileBlocksGame = level.game
	var best_value: int = -1
	var best_slot: int = -1
	var best_turns: int = 0
	var best_origin: Vector2i = Vector2i.ZERO
	for slot in game.hand.size():
		var piece: Piece = game.hand[slot]
		if piece == null:
			continue
		for turns in 4:
			for y in game.grid.size:
				for x in game.grid.size:
					var value: int = _value(level, piece, Vector2i(x, y))
					if value > best_value:
						best_value = value
						best_slot = slot
						best_turns = turns
						best_origin = Vector2i(x, y)
			piece = piece.rotated()
	if best_slot < 0:
		return false
	for _turn in best_turns:
		game.rotate(best_slot)
	return level.place(best_slot, best_origin) != null


static func _value(level: LevelGame, piece: Piece, origin: Vector2i) -> int:
	var grid: TileGrid = level.game.grid
	if not grid.can_place(piece, origin):
		return -1
	var trial: TileGrid = grid.copy()
	trial.place(piece, origin)
	var clear: GridClear = trial.find_clears(level.game.rules.match_size)
	var value: int = clear.cells.size() * 100
	for cell in clear.cells:
		if level.game.layer.is_gold(cell) and not level.game.layer.has_ice(cell):
			value += 5000
	for symbol in clear.group_symbols:
		if (
			level.definition.goal == LevelDefinition.Goal.TRIOS
			and symbol == level.definition.goal_symbol
		):
			value += 5000
	for index in piece.cells.size():
		var cell: Vector2i = origin + piece.cells[index]
		for step in GridGroups.NEIGHBOURS:
			if grid.symbol_at(cell + step) == piece.symbols[index]:
				value += 20
				if piece.symbols[index] == level.definition.goal_symbol:
					value += 30
	return value * 100 + origin.y * grid.size + (grid.size - origin.x)
