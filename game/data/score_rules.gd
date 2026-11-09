class_name ScoreRules
extends Resource
## How a move scores (ScoreKeeper): placed cells, cleared cells, several clears at once, and
## the combo of moves in a row that clear something.

@export var points_per_cell_placed: int = 1
@export var points_per_cell_cleared: int = 10
## Extra percentage for each clear (line or group) beyond the first in the same move.
@export var multi_clear_bonus_percent: int = 50
## Extra percentage for each move of the combo beyond the first.
@export var combo_bonus_percent: int = 50
## Moves without a clear that the combo survives (0: the first one ends it).
@export var combo_grace_moves: int = 2
## Points for a move that leaves the grid empty ("grid cleared!").
@export var empty_grid_bonus: int = 300
