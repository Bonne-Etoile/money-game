class_name ClearPraise
extends RefCounted
## How much a move deserves praise (G13): the more clears at once, the longer the combo, and an
## empty grid, the stronger the word, the effect, the shake and the vibration. Pure logic, the
## screen shows it (JuiceRules).


## Strength of `result`: its clears, plus the combo beyond the first move, plus
## `empty_grid_strength` when the grid ends empty (0: nothing cleared).
static func strength(result: MoveResult, empty_grid_strength: int) -> int:
	if result.clear.is_empty():
		return 0
	var total: int = result.clear.count() + maxi(result.combo - 1, 0)
	if result.empty_grid:
		total += empty_grid_strength
	return total


## The word of praise for a move of `move_strength`: 0 for none, 1 for the first threshold
## reached (PRAISE_1), and so on.
static func word(move_strength: int, thresholds: Array[int]) -> int:
	var reached: int = 0
	for threshold in thresholds:
		if move_strength >= threshold:
			reached += 1
	return reached
