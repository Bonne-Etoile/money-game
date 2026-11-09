class_name LevelDefinition
extends Resource
## A hand-made level of the level mode (G17): a starting grid, a goal and a number of pieces.
## The grid is drawn as text, one string per row, one character per cell:
##   .        empty
##   0 to 4   a tile with that symbol (0 circle, 1 square, 2 triangle, 3 diamond, 4 star)
##   a to e   a gold tile with symbol 0 to 4 (freed by a line or a trio)
##   A to E   a tile with symbol 0 to 4 under ice (two clears: the ice, then the tile)
##   #        a stone (only a full row or column removes it)

enum Goal { SCORE, TRIOS, GOLD }

@export var rows: Array[String] = []
@export var goal: Goal = Goal.SCORE
## Points to reach (SCORE), or groups of `goal_symbol` to clear (TRIOS); GOLD frees every gold
## tile of the grid.
@export var goal_count: int = 300
@export var goal_symbol: int = 4
## Pieces the player may place.
@export var pieces: int = 20
## Seed of the pieces: the same level always deals the same pieces (tests check a robot wins).
@export var random_seed: int = 1
