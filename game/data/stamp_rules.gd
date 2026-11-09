class_name StampRules
extends Resource
## Settings of the "stamp" prototype (G7, Stelio's idea): Tetris shapes stamped on a pile of
## tiles become tiled pieces, placed on a block-puzzle grid.

@export var pile_size: int = 6
@export var grid_size: int = 8
@export var symbol_count: int = 5
## Identical symbols touching each other that clear on the grid; 0: only full lines.
@export var match_size: int = 3
## Upcoming shapes shown after the current one.
@export var preview_count: int = 2
## Shapes that arrive, drawn at random (keys of `shape_set`): the Tetris shapes.
@export var shape_keys: Array[String] = []
## When the arriving shape fits nowhere on the pile any more, the first of these that fits
## replaces it (so that the last scattered tiles can still be taken).
@export var fallback_keys: Array[String] = []
@export var shape_set: PieceShapeSet
@export var scoring: ScoreRules
@export var levels: Array[StampLevel] = []
