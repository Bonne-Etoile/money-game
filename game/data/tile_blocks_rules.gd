class_name TileBlocksRules
extends Resource
## Settings of prototype 1, "tile blocks" (tile_blocks_rules.tres): a full row or column, or
## `match_size` identical symbols touching each other, are cleared.

@export var grid_size: int = 8
## Number of different symbols on the tiles.
@export var symbol_count: int = 5
## Pieces offered at once; new ones come when all are placed.
@export var hand_size: int = 3
## Identical symbols touching each other (sides only) that clear; 0 turns the rule off.
@export var match_size: int = 3
@export var shape_set: PieceShapeSet
@export var scoring: ScoreRules
