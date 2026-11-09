class_name ScoreKeeper
extends RefCounted
## The score of a game and its combo (ScoreRules): every placed cell scores, every cleared
## cell scores more, with a bonus for several clears in one move and for moves in a row that
## clear something.

var rules: ScoreRules
var score: int = 0
## Moves in a row that cleared something (0: no combo under way).
var combo: int = 0
var _moves_without_clear: int = 0


func _init(score_rules: ScoreRules) -> void:
	rules = score_rules


## Scores a move and returns its points.
func score_move(placed_cells: int, clear: GridClear) -> int:
	var points: int = placed_cells * rules.points_per_cell_placed
	if clear.is_empty():
		_moves_without_clear += 1
		if _moves_without_clear > rules.combo_grace_moves:
			combo = 0
	else:
		combo += 1
		_moves_without_clear = 0
		var percent: int = 100 + (clear.count() - 1) * rules.multi_clear_bonus_percent
		percent += (combo - 1) * rules.combo_bonus_percent
		points += clear.cells.size() * rules.points_per_cell_cleared * percent / 100
	score += points
	return points
