class_name LevelGame
extends RefCounted
## A level of the level mode (G17): the rules of the endless game (TileBlocksGame, pure chance:
## no adaptive difficulty), a starting grid with gold, ice and stones (LevelBoard), a goal and
## a limited number of pieces. Won when the goal is reached; lost when the pieces run out or no
## piece fits. A rewarded ad can give `LevelSet.extra_pieces` more pieces when they run out.

var definition: LevelDefinition
var game: TileBlocksGame
var pieces_left: int = 0
## Groups of the goal's symbol cleared so far (TRIOS).
var trios: int = 0
## Times extra pieces were given in this attempt.
var extras_used: int = 0
var _extra_pieces: int = 0
var _extra_ads: int = 0


func _init(level: LevelDefinition, rules: TileBlocksRules, level_set: LevelSet) -> void:
	definition = level
	var level_rules: TileBlocksRules = rules.duplicate()
	level_rules.difficulty = null
	level_rules.revives_per_game = 0
	game = TileBlocksGame.new(level_rules, level.random_seed)
	game.layer = LevelBoard.new()
	pieces_left = level.pieces
	_extra_pieces = level_set.extra_pieces
	_extra_ads = level_set.extra_pieces_ads
	load_rows(level.rows)
	# The first hand is dealt on the level's grid, not on an empty one.
	game.deal_hand()


## Puts the starting grid of `rows` (LevelDefinition) on the grid.
func load_rows(rows: Array[String]) -> void:
	for y in mini(rows.size(), game.grid.size):
		var row: String = rows[y]
		for x in mini(row.length(), game.grid.size):
			_load_cell(Vector2i(x, y), row[x])
	game.layer.gold_total = game.layer.gold.size()


func _load_cell(cell: Vector2i, code: String) -> void:
	var lower: int = "abcde".find(code)
	var upper: int = "ABCDE".find(code)
	var digit: int = "01234".find(code)
	if code == "#":
		game.grid.set_symbol(cell, TileGrid.STONE)
	elif digit >= 0:
		game.grid.set_symbol(cell, digit)
	elif lower >= 0:
		game.grid.set_symbol(cell, lower)
		game.layer.gold[cell] = true
	elif upper >= 0:
		game.grid.set_symbol(cell, upper)
		game.layer.ice[cell] = 1


## Places a piece and counts it; null when not allowed (no piece left, the level is over, or
## the piece does not fit there).
func place(slot: int, origin: Vector2i) -> MoveResult:
	if pieces_left <= 0 or is_won():
		return null
	var result: MoveResult = game.place(slot, origin)
	if result == null:
		return null
	pieces_left -= 1
	for symbol in result.clear.group_symbols:
		if symbol == definition.goal_symbol:
			trios += 1
	return result


## How far the goal is reached (points, groups or gold tiles).
func progress() -> int:
	match definition.goal:
		LevelDefinition.Goal.SCORE:
			return game.score()
		LevelDefinition.Goal.TRIOS:
			return trios
		_:
			return game.layer.gold_freed


## What the goal asks for.
func target() -> int:
	if definition.goal == LevelDefinition.Goal.GOLD:
		return game.layer.gold_total
	return definition.goal_count


func is_won() -> bool:
	return progress() >= target()


func is_lost() -> bool:
	return not is_won() and (pieces_left <= 0 or game.is_over())


## Whether a rewarded ad can give more pieces now: they ran out, pieces still fit, and the
## attempt has ads left.
func can_add_pieces() -> bool:
	return not is_won() and pieces_left <= 0 and not game.is_over() and extras_used < _extra_ads


## More pieces (after a rewarded ad); false when not allowed.
func add_pieces() -> bool:
	if not can_add_pieces():
		return false
	extras_used += 1
	pieces_left += _extra_pieces
	return true
